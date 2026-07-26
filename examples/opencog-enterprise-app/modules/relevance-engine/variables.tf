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
  description = "GCP project ID for relevance engine resources"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for relevance engine resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for relevance engine resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "bigquery_location" {
  description = "Location for BigQuery dataset"
  type        = string
  default     = "US"
}

variable "bigquery_owner_email" {
  description = "Email of the BigQuery dataset owner"
  type        = string
}

variable "bigquery_reader_group" {
  description = "Google Group for BigQuery readers"
  type        = string
  default     = ""
}

variable "network_self_link" {
  description = "Self-link of the VPC network"
  type        = string
}

variable "redis_memory_size_gb" {
  description = "Memory size in GB for Redis instance"
  type        = number
  default     = 4
}

variable "enable_spanner" {
  description = "Enable Cloud Spanner for global cognitive state"
  type        = bool
  default     = false
}

variable "spanner_config" {
  description = "Cloud Spanner instance configuration"
  type        = string
  default     = "regional-us-central1"
}

variable "spanner_nodes" {
  description = "Number of Cloud Spanner nodes"
  type        = number
  default     = 1
}
