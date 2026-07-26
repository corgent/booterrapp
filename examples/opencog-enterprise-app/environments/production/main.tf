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
  OpenCog Enterprise App - Production Environment
  
  This configuration provides a fully hardened,
  highly available production environment for
  cognitive computing workloads with optimal
  relevance realization capabilities.
*************************************************/

module "opencog_production" {
  source = "../../"

  # Required variables
  org_id               = var.org_id
  billing_account      = var.billing_account
  group_org_admins     = var.group_org_admins
  group_billing_admins = var.group_billing_admins
  sql_password         = var.sql_password

  # Environment configuration
  environment    = "production"
  project_prefix = "opencog-prod"
  default_region = var.default_region
  folder_id      = var.folder_id

  # Production-grade node pools
  general_pool_machine_type   = "e2-standard-8"
  general_pool_node_count     = 3
  general_pool_min_nodes      = 3
  general_pool_max_nodes      = 20
  
  cognitive_pool_machine_type = "n2-highmem-16"
  cognitive_pool_node_count   = 2
  cognitive_pool_min_nodes    = 1
  cognitive_pool_max_nodes    = 20

  # Enable GPU for production ML workloads
  enable_gpu_nodes       = true
  gpu_pool_machine_type  = "n1-standard-8"
  gpu_type               = "nvidia-tesla-t4"
  gpu_count_per_node     = 2
  gpu_pool_node_count    = 0
  gpu_pool_min_nodes     = 0
  gpu_pool_max_nodes     = 10

  # Production-sized resources
  sql_tier             = "db-custom-8-32768"
  sql_disk_size        = 500
  redis_memory_size_gb = 16

  # Enable Cloud Spanner for global scale
  enable_spanner = true
  spanner_config = "nam3"  # North America multi-region
  spanner_nodes  = 3

  # Enable all services
  enable_vertex_ai = true
  enable_cloud_run = true

  # Security features
  enable_cmek                 = true
  kms_key_id                  = var.kms_key_id
  enable_binary_authorization = true

  # GKE security
  gke_master_authorized_networks = var.gke_master_authorized_networks

  # Enable full observability
  enable_slo                    = true
  enable_uptime_checks          = true
  monitoring_service_id         = var.monitoring_service_id
  cognitive_processor_domain    = var.cognitive_processor_domain
  notification_channels         = var.notification_channels

  # Enable CI/CD
  enable_cloudbuild = true
  tf_repo_uri       = var.tf_repo_uri
  tf_repo_type      = var.tf_repo_type
  tf_apply_branches = ["main"]
}
