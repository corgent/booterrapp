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

output "bigquery_dataset_id" {
  description = "ID of the BigQuery dataset"
  value       = google_bigquery_dataset.relevance_analytics.dataset_id
}

output "bigquery_dataset_location" {
  description = "Location of the BigQuery dataset"
  value       = google_bigquery_dataset.relevance_analytics.location
}

output "cognitive_events_table_id" {
  description = "ID of the cognitive events BigQuery table"
  value       = google_bigquery_table.cognitive_events.table_id
}

output "relevance_scores_table_id" {
  description = "ID of the relevance scores BigQuery table"
  value       = google_bigquery_table.relevance_scores.table_id
}

output "cognitive_patterns_table_id" {
  description = "ID of the cognitive patterns BigQuery table"
  value       = google_bigquery_table.cognitive_patterns.table_id
}

output "redis_host" {
  description = "Hostname of the Redis instance"
  value       = google_redis_instance.relevance_cache.host
}

output "redis_port" {
  description = "Port of the Redis instance"
  value       = google_redis_instance.relevance_cache.port
}

output "redis_connection_string" {
  description = "Connection string for Redis"
  value       = "${google_redis_instance.relevance_cache.host}:${google_redis_instance.relevance_cache.port}"
}

output "spanner_instance_id" {
  description = "ID of the Cloud Spanner instance"
  value       = var.enable_spanner ? google_spanner_instance.cognitive_state[0].name : null
}

output "spanner_database_name" {
  description = "Name of the Cloud Spanner database"
  value       = var.enable_spanner ? google_spanner_database.cognitive_state_db[0].name : null
}

output "relevance_engine_sa_email" {
  description = "Email of the relevance engine service account"
  value       = google_service_account.relevance_engine.email
}
