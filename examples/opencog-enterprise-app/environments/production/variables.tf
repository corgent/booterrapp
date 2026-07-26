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

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with"
  type        = string
}

variable "group_org_admins" {
  description = "Google Group for GCP Organization Administrators"
  type        = string
}

variable "group_billing_admins" {
  description = "Google Group for GCP Billing Administrators"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources"
  type        = string
  default     = "us-central1"
}

variable "folder_id" {
  description = "The ID of a folder to host the project"
  type        = string
  default     = ""
}

variable "sql_password" {
  description = "Password for the Cloud SQL user"
  type        = string
  sensitive   = true
}

variable "kms_key_id" {
  description = "KMS key ID for CMEK encryption"
  type        = string
}

variable "gke_master_authorized_networks" {
  description = "CIDR blocks authorized to access GKE master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "tf_repo_uri" {
  description = "URI of the Terraform repository"
  type        = string
}

variable "tf_repo_type" {
  description = "Type of the Terraform repository"
  type        = string
  default     = "GITHUB"
}

variable "monitoring_service_id" {
  description = "Monitoring service ID for SLO"
  type        = string
}

variable "cognitive_processor_domain" {
  description = "Domain for cognitive processor"
  type        = string
}

variable "notification_channels" {
  description = "Notification channels for alerting"
  type        = list(string)
}
