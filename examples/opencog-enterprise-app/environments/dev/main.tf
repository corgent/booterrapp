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
  OpenCog Enterprise App - Development Environment
  
  This configuration provides a cost-optimized
  development environment for iterative development
  and testing of cognitive computing features.
*************************************************/

module "opencog_dev" {
  source = "../../"

  # Required variables
  org_id               = var.org_id
  billing_account      = var.billing_account
  group_org_admins     = var.group_org_admins
  group_billing_admins = var.group_billing_admins
  sql_password         = var.sql_password

  # Environment configuration
  environment    = "dev"
  project_prefix = "opencog-dev"
  default_region = var.default_region
  folder_id      = var.folder_id

  # Cost optimization settings for dev
  general_pool_machine_type   = "e2-standard-2"
  general_pool_node_count     = 1
  general_pool_min_nodes      = 1
  general_pool_max_nodes      = 3
  
  cognitive_pool_machine_type = "n2-highmem-4"
  cognitive_pool_node_count   = 0
  cognitive_pool_min_nodes    = 0
  cognitive_pool_max_nodes    = 3

  # Disable expensive features for dev
  enable_gpu_nodes = false
  enable_spanner   = false

  # Reduced resources
  sql_tier             = "db-custom-1-4096"
  sql_disk_size        = 50
  redis_memory_size_gb = 1

  # Enable essential services
  enable_vertex_ai = true
  enable_cloud_run = true

  # Disable production features
  enable_cmek           = false
  enable_slo            = false
  enable_uptime_checks  = false
  enable_cloudbuild     = false
}
