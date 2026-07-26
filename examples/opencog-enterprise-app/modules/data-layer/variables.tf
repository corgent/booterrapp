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
  description = "GCP project ID for data layer resources"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for data layer resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for data layer resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "network_self_link" {
  description = "Self-link of the VPC network for private connectivity"
  type        = string
}

variable "private_vpc_connection" {
  description = "Private VPC connection ID for managed services"
  type        = string
}

variable "enable_cmek" {
  description = "Enable Customer-Managed Encryption Keys"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for CMEK encryption"
  type        = string
  default     = null
}

variable "sql_tier" {
  description = "Cloud SQL machine tier"
  type        = string
  default     = "db-custom-2-8192"
}

variable "sql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 100
}

variable "sql_password" {
  description = "Password for the Cloud SQL user"
  type        = string
  sensitive   = true
}

variable "firestore_location" {
  description = "Location for Firestore database"
  type        = string
  default     = "us-central"
}
