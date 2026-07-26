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

output "dashboard_id" {
  description = "ID of the monitoring dashboard"
  value       = google_monitoring_dashboard.cognitive_dashboard.id
}

output "log_archive_bucket" {
  description = "Name of the log archive storage bucket"
  value       = google_storage_bucket.log_archive.name
}

output "audit_logs_sink_name" {
  description = "Name of the audit logs sink"
  value       = google_logging_project_sink.audit_logs_bq.name
}

output "app_logs_sink_name" {
  description = "Name of the application logs sink"
  value       = google_logging_project_sink.app_logs_storage.name
}

output "error_rate_alert_policy_id" {
  description = "ID of the high error rate alert policy"
  value       = google_monitoring_alert_policy.high_error_rate.id
}

output "low_relevance_alert_policy_id" {
  description = "ID of the low relevance score alert policy"
  value       = google_monitoring_alert_policy.low_relevance_score.id
}

output "pod_crash_alert_policy_id" {
  description = "ID of the pod crash loop alert policy"
  value       = google_monitoring_alert_policy.gke_pod_crash_loop.id
}

output "uptime_check_id" {
  description = "ID of the uptime check"
  value       = var.enable_uptime_checks ? google_monitoring_uptime_check_config.cognitive_processor_health[0].uptime_check_id : null
}

output "availability_slo_id" {
  description = "ID of the availability SLO"
  value       = var.enable_slo ? google_monitoring_slo.cognitive_processor_availability[0].id : null
}

output "latency_slo_id" {
  description = "ID of the latency SLO"
  value       = var.enable_slo ? google_monitoring_slo.relevance_latency[0].id : null
}

output "relevance_error_metric_name" {
  description = "Name of the relevance calculation errors metric"
  value       = google_logging_metric.relevance_calculation_errors.name
}

output "cognitive_latency_metric_name" {
  description = "Name of the cognitive event latency metric"
  value       = google_logging_metric.cognitive_event_latency.name
}

output "attention_weight_metric_name" {
  description = "Name of the attention weight distribution metric"
  value       = google_logging_metric.attention_weight_distribution.name
}
