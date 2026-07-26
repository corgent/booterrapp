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

variable "project_id" {
  description = "GCP project ID for observability resources"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for observability resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for observability resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "log_dataset_id" {
  description = "BigQuery dataset ID for log sinks"
  type        = string
}

variable "notification_channels" {
  description = "List of notification channel IDs for alerting"
  type        = list(string)
  default     = []
}

variable "enable_uptime_checks" {
  description = "Enable uptime checks for external endpoints"
  type        = bool
  default     = false
}

variable "cognitive_processor_domain" {
  description = "Domain for cognitive processor uptime check"
  type        = string
  default     = ""
}

variable "enable_slo" {
  description = "Enable SLO configuration"
  type        = bool
  default     = false
}

variable "monitoring_service_id" {
  description = "Monitoring service ID for SLO configuration"
  type        = string
  default     = ""
}
