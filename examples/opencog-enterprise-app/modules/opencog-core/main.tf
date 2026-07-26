/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_name        = "${var.project_prefix}-gke-${var.environment}"
  artifact_repo_name  = "${var.project_prefix}-containers-${var.environment}"
  gke_sa_name         = "${var.project_prefix}-gke-nodes"
  workload_sa_name    = "${var.project_prefix}-workload"
}

/******************************************
  Service Accounts
 ******************************************/

resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = local.gke_sa_name
  display_name = "OpenCog GKE Node Service Account"
  description  = "Service account for GKE node pools running cognitive workloads"
}

resource "google_project_iam_member" "gke_nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_artifact_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_service_account" "workload_identity" {
  project      = var.project_id
  account_id   = local.workload_sa_name
  display_name = "OpenCog Workload Identity Service Account"
  description  = "Service account for cognitive workloads via Workload Identity"
}

/******************************************
  Artifact Registry
 ******************************************/

resource "google_artifact_registry_repository" "containers" {
  project       = var.project_id
  location      = var.region
  repository_id = local.artifact_repo_name
  description   = "Container images for OpenCog cognitive services"
  format        = "DOCKER"

  docker_config {
    immutable_tags = var.environment == "production"
  }

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = var.environment == "production" ? 10 : 5
    }
  }

  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    condition {
      older_than = var.environment == "production" ? "2592000s" : "604800s" # 30 days or 7 days
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

/******************************************
  GKE Cluster
 ******************************************/

resource "google_container_cluster" "opencog" {
  provider = google-beta
  project  = var.project_id
  name     = local.cluster_name
  location = var.region

  # Use a separately managed node pool
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.environment == "production"
    master_ipv4_cidr_block  = var.master_cidr
  }

  # Master authorized networks
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Addons configuration
  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
    dns_cache_config {
      enabled = true
    }
  }

  # Release channel for automated upgrades
  release_channel {
    channel = var.environment == "production" ? "STABLE" : "REGULAR"
  }

  # Maintenance window
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T04:00:00Z"
      end_time   = "2024-01-01T08:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  # Logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Security configuration
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = var.environment == "production" ? "VULNERABILITY_ENTERPRISE" : "VULNERABILITY_BASIC"
  }

  # Binary authorization
  dynamic "binary_authorization" {
    for_each = var.enable_binary_authorization ? [1] : []
    content {
      evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
    }
  }

  # Network policy
  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  # Enable Dataplane V2
  datapath_provider = "ADVANCED_DATAPATH"

  # Cluster resource labels
  resource_labels = {
    environment = var.environment
    application = "opencog"
    component   = "gke-cluster"
  }

  # Deletion protection for production
  deletion_protection = var.environment == "production"
}

/******************************************
  GKE Node Pool - General Purpose
 ******************************************/

resource "google_container_node_pool" "general" {
  provider   = google-beta
  project    = var.project_id
  name       = "general-pool"
  cluster    = google_container_cluster.opencog.id
  location   = var.region
  node_count = var.general_pool_node_count

  autoscaling {
    min_node_count = var.general_pool_min_nodes
    max_node_count = var.general_pool_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.environment != "production"
    spot         = var.environment != "production"
    machine_type = var.general_pool_machine_type
    disk_size_gb = 100
    disk_type    = "pd-ssd"

    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      environment = var.environment
      pool-type   = "general"
    }

    tags = ["gke-node", "opencog-general"]
  }
}

/******************************************
  GKE Node Pool - Cognitive Workloads (High Memory)
 ******************************************/

resource "google_container_node_pool" "cognitive" {
  provider   = google-beta
  project    = var.project_id
  name       = "cognitive-pool"
  cluster    = google_container_cluster.opencog.id
  location   = var.region
  node_count = var.cognitive_pool_node_count

  autoscaling {
    min_node_count = var.cognitive_pool_min_nodes
    max_node_count = var.cognitive_pool_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.environment != "production"
    spot         = var.environment != "production"
    machine_type = var.cognitive_pool_machine_type
    disk_size_gb = 200
    disk_type    = "pd-ssd"

    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      environment = var.environment
      pool-type   = "cognitive"
    }

    taint {
      key    = "cognitive-workload"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    tags = ["gke-node", "opencog-cognitive"]
  }
}

/******************************************
  GKE Node Pool - GPU (Optional)
 ******************************************/

resource "google_container_node_pool" "gpu" {
  count      = var.enable_gpu_nodes ? 1 : 0
  provider   = google-beta
  project    = var.project_id
  name       = "gpu-pool"
  cluster    = google_container_cluster.opencog.id
  location   = var.region
  node_count = var.gpu_pool_node_count

  autoscaling {
    min_node_count = var.gpu_pool_min_nodes
    max_node_count = var.gpu_pool_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.environment != "production"
    spot         = var.environment != "production"
    machine_type = var.gpu_pool_machine_type
    disk_size_gb = 200
    disk_type    = "pd-ssd"

    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    guest_accelerator {
      type  = var.gpu_type
      count = var.gpu_count_per_node
      gpu_driver_installation_config {
        gpu_driver_version = "DEFAULT"
      }
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = {
      environment = var.environment
      pool-type   = "gpu"
    }

    taint {
      key    = "nvidia.com/gpu"
      value  = "present"
      effect = "NO_SCHEDULE"
    }

    tags = ["gke-node", "opencog-gpu"]
  }
}

/******************************************
  Workload Identity Binding
 ******************************************/

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.workload_identity.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[opencog/opencog-app]"
}
