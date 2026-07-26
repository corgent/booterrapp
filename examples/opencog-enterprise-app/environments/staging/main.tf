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
  OpenCog Enterprise App - Staging Environment
  
  This configuration provides a production-like
  staging environment for integration testing
  and performance validation.
*************************************************/

module "opencog_staging" {
  source = "../../"

  # Required variables
  org_id               = var.org_id
  billing_account      = var.billing_account
  group_org_admins     = var.group_org_admins
  group_billing_admins = var.group_billing_admins
  sql_password         = var.sql_password

  # Environment configuration
  environment    = "staging"
  project_prefix = "opencog-staging"
  default_region = var.default_region
  folder_id      = var.folder_id

  # Production-like but scaled down
  general_pool_machine_type   = "e2-standard-4"
  general_pool_node_count     = 2
  general_pool_min_nodes      = 1
  general_pool_max_nodes      = 5
  
  cognitive_pool_machine_type = "n2-highmem-8"
  cognitive_pool_node_count   = 1
  cognitive_pool_min_nodes    = 0
  cognitive_pool_max_nodes    = 5

  # Enable GPU for testing ML workloads
  enable_gpu_nodes       = var.enable_gpu_nodes
  gpu_pool_machine_type  = "n1-standard-4"
  gpu_pool_node_count    = 0
  gpu_pool_min_nodes     = 0
  gpu_pool_max_nodes     = 2

  # Medium-sized resources
  sql_tier             = "db-custom-2-8192"
  sql_disk_size        = 100
  redis_memory_size_gb = 4

  # Enable Spanner for testing global distribution
  enable_spanner = false

  # Enable all services
  enable_vertex_ai = true
  enable_cloud_run = true

  # Enable observability
  enable_slo           = true
  enable_uptime_checks = true
  monitoring_service_id     = var.monitoring_service_id
  cognitive_processor_domain = var.cognitive_processor_domain
  notification_channels      = var.notification_channels

  # Enable CI/CD
  enable_cloudbuild = var.enable_cloudbuild
  tf_repo_uri       = var.tf_repo_uri
  tf_repo_type      = var.tf_repo_type
  tf_apply_branches = ["staging"]
}
