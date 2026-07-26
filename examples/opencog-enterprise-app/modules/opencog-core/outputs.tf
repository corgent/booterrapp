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

output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.opencog.id
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.opencog.name
}

output "cluster_endpoint" {
  description = "The endpoint of the GKE cluster"
  value       = google_container_cluster.opencog.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "The CA certificate of the GKE cluster"
  value       = google_container_cluster.opencog.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "The location of the GKE cluster"
  value       = google_container_cluster.opencog.location
}

output "gke_service_account_email" {
  description = "Email of the GKE node service account"
  value       = google_service_account.gke_nodes.email
}

output "workload_identity_sa_email" {
  description = "Email of the workload identity service account"
  value       = google_service_account.workload_identity.email
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.containers.repository_id}"
}

output "artifact_registry_id" {
  description = "ID of the Artifact Registry repository"
  value       = google_artifact_registry_repository.containers.id
}

output "general_node_pool_name" {
  description = "Name of the general purpose node pool"
  value       = google_container_node_pool.general.name
}

output "cognitive_node_pool_name" {
  description = "Name of the cognitive workload node pool"
  value       = google_container_node_pool.cognitive.name
}

output "gpu_node_pool_name" {
  description = "Name of the GPU node pool"
  value       = var.enable_gpu_nodes ? google_container_node_pool.gpu[0].name : null
}
