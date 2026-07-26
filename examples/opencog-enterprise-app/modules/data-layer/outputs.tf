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

output "artifacts_bucket_name" {
  description = "Name of the cognitive artifacts storage bucket"
  value       = google_storage_bucket.cognitive_artifacts.name
}

output "artifacts_bucket_url" {
  description = "URL of the cognitive artifacts storage bucket"
  value       = google_storage_bucket.cognitive_artifacts.url
}

output "ml_models_bucket_name" {
  description = "Name of the ML models storage bucket"
  value       = google_storage_bucket.ml_models.name
}

output "ml_models_bucket_url" {
  description = "URL of the ML models storage bucket"
  value       = google_storage_bucket.ml_models.url
}

output "sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.cognitive_db.name
}

output "sql_instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.cognitive_db.connection_name
}

output "sql_instance_private_ip" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.cognitive_db.private_ip_address
}

output "cognitive_database_name" {
  description = "Name of the cognitive database"
  value       = google_sql_database.cognitive_database.name
}

output "relevance_database_name" {
  description = "Name of the relevance database"
  value       = google_sql_database.relevance_database.name
}

output "firestore_database_name" {
  description = "Name of the Firestore database"
  value       = google_firestore_database.cognitive_docs.name
}

output "db_password_secret_id" {
  description = "Secret Manager ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "db_connection_secret_id" {
  description = "Secret Manager ID for database connection string"
  value       = google_secret_manager_secret.db_connection_string.secret_id
}
