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

output "seed_project_id" {
  description = "Project ID where OpenCog staging infrastructure is deployed"
  value       = module.opencog_staging.seed_project_id
}

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.opencog_staging.gke_cluster_name
}

output "kubectl_command" {
  description = "Command to configure kubectl"
  value       = module.opencog_staging.kubectl_command
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry"
  value       = module.opencog_staging.artifact_registry_url
}

output "monitoring_dashboard_id" {
  description = "ID of the monitoring dashboard"
  value       = module.opencog_staging.monitoring_dashboard_id
}
