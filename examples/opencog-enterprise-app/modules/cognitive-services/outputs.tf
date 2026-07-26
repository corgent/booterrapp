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

output "vertex_ai_sa_email" {
  description = "Email of the Vertex AI service account"
  value       = google_service_account.vertex_ai.email
}

output "cloud_run_sa_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloud_run.email
}

output "cognitive_events_topic_id" {
  description = "ID of the cognitive events Pub/Sub topic"
  value       = google_pubsub_topic.cognitive_events.id
}

output "cognitive_events_topic_name" {
  description = "Name of the cognitive events Pub/Sub topic"
  value       = google_pubsub_topic.cognitive_events.name
}

output "relevance_updates_topic_id" {
  description = "ID of the relevance updates Pub/Sub topic"
  value       = google_pubsub_topic.relevance_updates.id
}

output "relevance_updates_topic_name" {
  description = "Name of the relevance updates Pub/Sub topic"
  value       = google_pubsub_topic.relevance_updates.name
}

output "model_predictions_topic_id" {
  description = "ID of the model predictions Pub/Sub topic"
  value       = google_pubsub_topic.model_predictions.id
}

output "model_predictions_topic_name" {
  description = "Name of the model predictions Pub/Sub topic"
  value       = google_pubsub_topic.model_predictions.name
}

output "dead_letter_topic_id" {
  description = "ID of the dead letter Pub/Sub topic"
  value       = google_pubsub_topic.dead_letter.id
}

output "featurestore_id" {
  description = "ID of the Vertex AI Feature Store"
  value       = var.enable_vertex_ai ? google_vertex_ai_featurestore.relevance_features[0].id : null
}

output "featurestore_name" {
  description = "Name of the Vertex AI Feature Store"
  value       = var.enable_vertex_ai ? google_vertex_ai_featurestore.relevance_features[0].name : null
}

output "cognitive_processor_url" {
  description = "URL of the cognitive processor Cloud Run service"
  value       = var.enable_cloud_run ? google_cloud_run_v2_service.cognitive_processor[0].uri : null
}

output "relevance_calculator_url" {
  description = "URL of the relevance calculator Cloud Run service"
  value       = var.enable_cloud_run ? google_cloud_run_v2_service.relevance_calculator[0].uri : null
}
