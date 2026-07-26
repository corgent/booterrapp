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
  description = "GCP project ID for networking resources"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for networking resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for networking resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "subnet_cidr" {
  description = "CIDR range for the primary subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "CIDR range for GKE pods"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "CIDR range for GKE services"
  type        = string
  default     = "10.8.0.0/20"
}

variable "dns_domain" {
  description = "Private DNS domain for service discovery"
  type        = string
  default     = "opencog.internal"
}

variable "enable_serverless_connector" {
  description = "Enable VPC connector for serverless services"
  type        = bool
  default     = true
}

variable "serverless_connector_cidr" {
  description = "CIDR range for serverless VPC connector"
  type        = string
  default     = "10.10.0.0/28"
}
