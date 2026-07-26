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
  Bootstrap Outputs
 ******************************************/

output "seed_project_id" {
  description = "Project ID where OpenCog infrastructure is deployed"
  value       = module.bootstrap.seed_project_id
}

output "terraform_sa_email" {
  description = "Email of the Terraform service account"
  value       = module.bootstrap.terraform_sa_email
}

output "gcs_bucket_tfstate" {
  description = "GCS bucket for storing Terraform state"
  value       = module.bootstrap.gcs_bucket_tfstate
}

/******************************************
  Networking Outputs
 ******************************************/

output "network_name" {
  description = "Name of the VPC network"
  value       = module.networking.network_name
}

output "network_self_link" {
  description = "Self-link of the VPC network"
  value       = module.networking.network_self_link
}

output "subnet_name" {
  description = "Name of the primary subnet"
  value       = module.networking.subnet_name
}

output "dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = module.networking.dns_zone_name
}

/******************************************
  GKE Outputs
 ******************************************/

output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = module.opencog_core.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = module.opencog_core.cluster_endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "CA certificate of the GKE cluster"
  value       = module.opencog_core.cluster_ca_certificate
  sensitive   = true
}

output "artifact_registry_url" {
  description = "URL of the Artifact Registry repository"
  value       = module.opencog_core.artifact_registry_url
}

output "gke_service_account_email" {
  description = "Email of the GKE node service account"
  value       = module.opencog_core.gke_service_account_email
}

output "workload_identity_sa_email" {
  description = "Email of the workload identity service account"
  value       = module.opencog_core.workload_identity_sa_email
}

/******************************************
  Data Layer Outputs
 ******************************************/

output "artifacts_bucket_name" {
  description = "Name of the cognitive artifacts storage bucket"
  value       = module.data_layer.artifacts_bucket_name
}

output "ml_models_bucket_name" {
  description = "Name of the ML models storage bucket"
  value       = module.data_layer.ml_models_bucket_name
}

output "sql_instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = module.data_layer.sql_instance_connection_name
}

output "sql_instance_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = module.data_layer.sql_instance_private_ip
}

output "firestore_database_name" {
  description = "Name of the Firestore database"
  value       = module.data_layer.firestore_database_name
}

output "db_connection_secret_id" {
  description = "Secret Manager ID for database connection string"
  value       = module.data_layer.db_connection_secret_id
}

/******************************************
  Cognitive Services Outputs
 ******************************************/

output "cognitive_events_topic_name" {
  description = "Name of the cognitive events Pub/Sub topic"
  value       = module.cognitive_services.cognitive_events_topic_name
}

output "relevance_updates_topic_name" {
  description = "Name of the relevance updates Pub/Sub topic"
  value       = module.cognitive_services.relevance_updates_topic_name
}

output "model_predictions_topic_name" {
  description = "Name of the model predictions Pub/Sub topic"
  value       = module.cognitive_services.model_predictions_topic_name
}

output "featurestore_id" {
  description = "ID of the Vertex AI Feature Store"
  value       = module.cognitive_services.featurestore_id
}

output "cognitive_processor_url" {
  description = "URL of the cognitive processor Cloud Run service"
  value       = module.cognitive_services.cognitive_processor_url
}

output "relevance_calculator_url" {
  description = "URL of the relevance calculator Cloud Run service"
  value       = module.cognitive_services.relevance_calculator_url
}

/******************************************
  Relevance Engine Outputs
 ******************************************/

output "bigquery_dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = module.relevance_engine.bigquery_dataset_id
}

output "cognitive_events_table_id" {
  description = "ID of the cognitive events BigQuery table"
  value       = module.relevance_engine.cognitive_events_table_id
}

output "relevance_scores_table_id" {
  description = "ID of the relevance scores BigQuery table"
  value       = module.relevance_engine.relevance_scores_table_id
}

output "redis_connection_string" {
  description = "Connection string for Redis"
  value       = module.relevance_engine.redis_connection_string
}

output "spanner_instance_id" {
  description = "ID of the Cloud Spanner instance"
  value       = module.relevance_engine.spanner_instance_id
}

output "relevance_engine_sa_email" {
  description = "Email of the relevance engine service account"
  value       = module.relevance_engine.relevance_engine_sa_email
}

/******************************************
  Observability Outputs
 ******************************************/

output "monitoring_dashboard_id" {
  description = "ID of the monitoring dashboard"
  value       = module.observability.dashboard_id
}

output "log_archive_bucket" {
  description = "Name of the log archive storage bucket"
  value       = module.observability.log_archive_bucket
}

output "error_rate_alert_policy_id" {
  description = "ID of the high error rate alert policy"
  value       = module.observability.error_rate_alert_policy_id
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = module.observability.availability_slo_id
}

/******************************************
  CI/CD Outputs
 ******************************************/

output "cloudbuild_state_bucket" {
  description = "GCS bucket for Cloud Build state"
  value       = var.enable_cloudbuild ? module.cloudbuild_workspace[0].state_bucket : null
}

output "cloudbuild_plan_trigger_id" {
  description = "ID of the Cloud Build plan trigger"
  value       = var.enable_cloudbuild ? module.cloudbuild_workspace[0].cloudbuild_plan_trigger_id : null
}

output "cloudbuild_apply_trigger_id" {
  description = "ID of the Cloud Build apply trigger"
  value       = var.enable_cloudbuild ? module.cloudbuild_workspace[0].cloudbuild_apply_trigger_id : null
}

/******************************************
  Connection Information
 ******************************************/

output "kubectl_command" {
  description = "Command to configure kubectl for the GKE cluster"
  value       = "gcloud container clusters get-credentials ${module.opencog_core.cluster_name} --region ${var.default_region} --project ${module.bootstrap.seed_project_id}"
}

output "docker_push_command" {
  description = "Command to push images to Artifact Registry"
  value       = "docker push ${module.opencog_core.artifact_registry_url}/<IMAGE_NAME>:<TAG>"
}
