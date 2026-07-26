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

/*************************************************
  OpenCog Enterprise App - GCP Infrastructure
  
  This configuration deploys the complete infrastructure
  for the OpenCog Enterprise cognitive computing platform,
  designed for optimal cognitive grip on relevance realization.
*************************************************/

locals {
  project_prefix = var.project_prefix != "" ? var.project_prefix : "opencog"
  environment    = var.environment
  labels = {
    environment     = var.environment
    application     = "opencog-enterprise"
    managed_by      = "terraform"
    cost_center     = var.cost_center
  }
}

/******************************************
  Bootstrap - GCP Organization Setup
 ******************************************/

module "bootstrap" {
  source  = "terraform-google-modules/bootstrap/google"
  version = "~> 12.0"

  org_id               = var.org_id
  billing_account      = var.billing_account
  group_org_admins     = var.group_org_admins
  group_billing_admins = var.group_billing_admins
  default_region       = var.default_region
  project_prefix       = local.project_prefix
  folder_id            = var.folder_id

  activate_apis = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "pubsub.googleapis.com",
    "redis.googleapis.com",
    "sqladmin.googleapis.com",
    "firestore.googleapis.com",
    "aiplatform.googleapis.com",
    "cloudscheduler.googleapis.com",
    "secretmanager.googleapis.com",
    "vpcaccess.googleapis.com",
    "dns.googleapis.com",
  ]

  sa_enable_impersonation    = var.sa_enable_impersonation
  encrypt_gcs_bucket_tfstate = var.encrypt_state_bucket
  project_labels             = local.labels
}

/******************************************
  Networking Module
 ******************************************/

module "networking" {
  source = "./modules/networking"

  project_id     = module.bootstrap.seed_project_id
  project_prefix = local.project_prefix
  region         = var.default_region
  environment    = var.environment

  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
  dns_domain    = var.dns_domain

  enable_serverless_connector = var.enable_cloud_run
  serverless_connector_cidr   = var.serverless_connector_cidr

  depends_on = [module.bootstrap]
}

/******************************************
  Data Layer Module
 ******************************************/

module "data_layer" {
  source = "./modules/data-layer"

  project_id             = module.bootstrap.seed_project_id
  project_prefix         = local.project_prefix
  region                 = var.default_region
  environment            = var.environment
  network_self_link      = module.networking.network_self_link
  private_vpc_connection = module.networking.private_vpc_connection

  enable_cmek   = var.enable_cmek
  kms_key_id    = var.kms_key_id
  sql_tier      = var.sql_tier
  sql_disk_size = var.sql_disk_size
  sql_password  = var.sql_password

  firestore_location = var.firestore_location

  depends_on = [module.networking]
}

/******************************************
  OpenCog Core Module (GKE + Artifact Registry)
 ******************************************/

module "opencog_core" {
  source = "./modules/opencog-core"

  project_id     = module.bootstrap.seed_project_id
  project_prefix = local.project_prefix
  region         = var.default_region
  environment    = var.environment

  network_name        = module.networking.network_name
  subnet_name         = module.networking.subnet_name
  pods_range_name     = module.networking.pods_range_name
  services_range_name = module.networking.services_range_name

  master_cidr                = var.gke_master_cidr
  master_authorized_networks = var.gke_master_authorized_networks
  enable_binary_authorization = var.enable_binary_authorization

  # General node pool
  general_pool_machine_type = var.general_pool_machine_type
  general_pool_node_count   = var.general_pool_node_count
  general_pool_min_nodes    = var.general_pool_min_nodes
  general_pool_max_nodes    = var.general_pool_max_nodes

  # Cognitive node pool
  cognitive_pool_machine_type = var.cognitive_pool_machine_type
  cognitive_pool_node_count   = var.cognitive_pool_node_count
  cognitive_pool_min_nodes    = var.cognitive_pool_min_nodes
  cognitive_pool_max_nodes    = var.cognitive_pool_max_nodes

  # GPU node pool
  enable_gpu_nodes        = var.enable_gpu_nodes
  gpu_pool_machine_type   = var.gpu_pool_machine_type
  gpu_pool_node_count     = var.gpu_pool_node_count
  gpu_pool_min_nodes      = var.gpu_pool_min_nodes
  gpu_pool_max_nodes      = var.gpu_pool_max_nodes
  gpu_type                = var.gpu_type
  gpu_count_per_node      = var.gpu_count_per_node

  depends_on = [module.networking]
}

/******************************************
  Cognitive Services Module
 ******************************************/

module "cognitive_services" {
  source = "./modules/cognitive-services"

  project_id     = module.bootstrap.seed_project_id
  project_prefix = local.project_prefix
  region         = var.default_region
  environment    = var.environment

  enable_vertex_ai = var.enable_vertex_ai
  enable_cloud_run = var.enable_cloud_run

  serverless_connector_id    = module.networking.serverless_connector_id
  cognitive_processor_image  = var.cognitive_processor_image
  relevance_calculator_image = var.relevance_calculator_image

  depends_on = [module.networking, module.data_layer]
}

/******************************************
  Relevance Engine Module
 ******************************************/

module "relevance_engine" {
  source = "./modules/relevance-engine"

  project_id     = module.bootstrap.seed_project_id
  project_prefix = local.project_prefix
  region         = var.default_region
  environment    = var.environment

  bigquery_location     = var.bigquery_location
  bigquery_owner_email  = module.bootstrap.terraform_sa_email
  bigquery_reader_group = var.bigquery_reader_group

  network_self_link    = module.networking.network_self_link
  redis_memory_size_gb = var.redis_memory_size_gb

  enable_spanner = var.enable_spanner
  spanner_config = var.spanner_config
  spanner_nodes  = var.spanner_nodes

  depends_on = [module.networking]
}

/******************************************
  Observability Module
 ******************************************/

module "observability" {
  source = "./modules/observability"

  project_id     = module.bootstrap.seed_project_id
  project_prefix = local.project_prefix
  region         = var.default_region
  environment    = var.environment

  log_dataset_id        = module.relevance_engine.bigquery_dataset_id
  notification_channels = var.notification_channels

  enable_uptime_checks       = var.enable_uptime_checks
  cognitive_processor_domain = var.cognitive_processor_domain

  enable_slo            = var.enable_slo
  monitoring_service_id = var.monitoring_service_id

  depends_on = [module.relevance_engine, module.cognitive_services]
}

/******************************************
  Cloud Build Workspace (CI/CD)
 ******************************************/

module "cloudbuild_workspace" {
  count  = var.enable_cloudbuild ? 1 : 0
  source = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_workspace"
  version = "~> 12.0"

  project_id       = module.bootstrap.seed_project_id
  location         = var.default_region
  trigger_location = var.default_region

  tf_repo_uri  = var.tf_repo_uri
  tf_repo_type = var.tf_repo_type
  tf_repo_dir  = var.tf_repo_dir

  tf_apply_branches = var.tf_apply_branches

  cloudbuild_sa_roles = {
    (module.bootstrap.seed_project_id) = {
      project_id = module.bootstrap.seed_project_id
      roles = [
        "roles/compute.networkAdmin",
        "roles/container.admin",
        "roles/iam.serviceAccountAdmin",
        "roles/storage.admin",
        "roles/bigquery.admin",
        "roles/pubsub.admin",
        "roles/redis.admin",
        "roles/cloudsql.admin",
        "roles/run.admin",
        "roles/aiplatform.admin",
      ]
    }
  }

  depends_on = [module.bootstrap]
}
