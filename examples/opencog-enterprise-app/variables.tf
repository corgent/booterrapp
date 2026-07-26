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

/******************************************
  Required Variables
 ******************************************/

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with"
  type        = string
}

variable "group_org_admins" {
  description = "Google Group for GCP Organization Administrators"
  type        = string
}

variable "group_billing_admins" {
  description = "Google Group for GCP Billing Administrators"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, production"
  }
}

variable "sql_password" {
  description = "Password for the Cloud SQL user"
  type        = string
  sensitive   = true
}

/******************************************
  Optional Variables - General
 ******************************************/

variable "project_prefix" {
  description = "Name prefix to use for projects and resources created"
  type        = string
  default     = "opencog"
}

variable "folder_id" {
  description = "The ID of a folder to host the project"
  type        = string
  default     = ""
}

variable "cost_center" {
  description = "Cost center for resource labeling"
  type        = string
  default     = "cognitive-computing"
}

variable "sa_enable_impersonation" {
  description = "Allow org_admins group to impersonate service account"
  type        = bool
  default     = true
}

variable "encrypt_state_bucket" {
  description = "Encrypt bucket used for storing terraform state files"
  type        = bool
  default     = true
}

variable "enable_cmek" {
  description = "Enable Customer-Managed Encryption Keys"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for CMEK encryption"
  type        = string
  default     = null
}

/******************************************
  Networking Variables
 ******************************************/

variable "subnet_cidr" {
  description = "CIDR range for the primary subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "CIDR range for GKE services"
  type        = string
  default     = "10.8.0.0/20"
}

variable "dns_domain" {
  description = "Private DNS domain for service discovery"
  type        = string
  default     = "opencog.internal"
}

variable "serverless_connector_cidr" {
  description = "CIDR range for serverless VPC connector"
  type        = string
  default     = "10.10.0.0/28"
}

/******************************************
  GKE Variables
 ******************************************/

variable "gke_master_cidr" {
  description = "CIDR range for GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "gke_master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the GKE master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for GKE"
  type        = bool
  default     = false
}

# General node pool
variable "general_pool_machine_type" {
  description = "Machine type for general purpose node pool"
  type        = string
  default     = "e2-standard-4"
}

variable "general_pool_node_count" {
  description = "Initial node count for general pool"
  type        = number
  default     = 1
}

variable "general_pool_min_nodes" {
  description = "Minimum nodes for general pool autoscaling"
  type        = number
  default     = 1
}

variable "general_pool_max_nodes" {
  description = "Maximum nodes for general pool autoscaling"
  type        = number
  default     = 5
}

# Cognitive node pool
variable "cognitive_pool_machine_type" {
  description = "Machine type for cognitive workload node pool"
  type        = string
  default     = "n2-highmem-8"
}

variable "cognitive_pool_node_count" {
  description = "Initial node count for cognitive pool"
  type        = number
  default     = 1
}

variable "cognitive_pool_min_nodes" {
  description = "Minimum nodes for cognitive pool autoscaling"
  type        = number
  default     = 0
}

variable "cognitive_pool_max_nodes" {
  description = "Maximum nodes for cognitive pool autoscaling"
  type        = number
  default     = 10
}

# GPU node pool
variable "enable_gpu_nodes" {
  description = "Enable GPU node pool for ML workloads"
  type        = bool
  default     = false
}

variable "gpu_pool_machine_type" {
  description = "Machine type for GPU node pool"
  type        = string
  default     = "n1-standard-8"
}

variable "gpu_pool_node_count" {
  description = "Initial node count for GPU pool"
  type        = number
  default     = 0
}

variable "gpu_pool_min_nodes" {
  description = "Minimum nodes for GPU pool autoscaling"
  type        = number
  default     = 0
}

variable "gpu_pool_max_nodes" {
  description = "Maximum nodes for GPU pool autoscaling"
  type        = number
  default     = 4
}

variable "gpu_type" {
  description = "Type of GPU accelerator"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count_per_node" {
  description = "Number of GPUs per node"
  type        = number
  default     = 1
}

/******************************************
  Data Layer Variables
 ******************************************/

variable "sql_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-2-8192"
}

variable "sql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 100
}

variable "firestore_location" {
  description = "Location for Firestore database"
  type        = string
  default     = "us-central"
}

/******************************************
  Cognitive Services Variables
 ******************************************/

variable "enable_vertex_ai" {
  description = "Enable Vertex AI Feature Store"
  type        = bool
  default     = true
}

variable "enable_cloud_run" {
  description = "Enable Cloud Run services"
  type        = bool
  default     = true
}

variable "cognitive_processor_image" {
  description = "Container image for cognitive processor Cloud Run service"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "relevance_calculator_image" {
  description = "Container image for relevance calculator Cloud Run service"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

/******************************************
  Relevance Engine Variables
 ******************************************/

variable "bigquery_location" {
  description = "Location for BigQuery dataset"
  type        = string
  default     = "US"
}

variable "bigquery_reader_group" {
  description = "Google Group for BigQuery readers"
  type        = string
  default     = ""
}

variable "redis_memory_size_gb" {
  description = "Memory size in GB for Redis instance"
  type        = number
  default     = 4
}

variable "enable_spanner" {
  description = "Enable Cloud Spanner for global cognitive state"
  type        = bool
  default     = false
}

variable "spanner_config" {
  description = "Cloud Spanner instance configuration"
  type        = string
  default     = "regional-us-central1"
}

variable "spanner_nodes" {
  description = "Number of Cloud Spanner nodes"
  type        = number
  default     = 1
}

/******************************************
  Observability Variables
 ******************************************/

variable "notification_channels" {
  description = "List of notification channel IDs for alerting"
  type        = list(string)
  default     = []
}

variable "enable_uptime_checks" {
  description = "Enable uptime checks for external endpoints"
  type        = bool
  default     = false
}

variable "cognitive_processor_domain" {
  description = "Domain for cognitive processor uptime check"
  type        = string
  default     = ""
}

variable "enable_slo" {
  description = "Enable SLO configuration"
  type        = bool
  default     = false
}

variable "monitoring_service_id" {
  description = "Monitoring service ID for SLO configuration"
  type        = string
  default     = ""
}

/******************************************
  CI/CD Variables
 ******************************************/

variable "enable_cloudbuild" {
  description = "Enable Cloud Build CI/CD pipeline"
  type        = bool
  default     = false
}

variable "tf_repo_uri" {
  description = "URI of the Terraform configuration repository"
  type        = string
  default     = ""
}

variable "tf_repo_type" {
  description = "Type of repository (CLOUD_SOURCE_REPOSITORIES, GITHUB, CLOUDBUILD_V2_REPOSITORY)"
  type        = string
  default     = "GITHUB"
}

variable "tf_repo_dir" {
  description = "Directory inside the repo where Terraform configs are located"
  type        = string
  default     = ""
}

variable "tf_apply_branches" {
  description = "List of git branches configured to run terraform apply"
  type        = list(string)
  default     = ["main"]
}
