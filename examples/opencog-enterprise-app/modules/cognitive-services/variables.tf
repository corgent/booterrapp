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
  description = "GCP project ID for cognitive services"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for cognitive services resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for cognitive services"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "enable_vertex_ai" {
  description = "Enable Vertex AI Feature Store"
  type        = bool
  default     = true
}

variable "enable_cloud_run" {
  description = "Enable Cloud Run services"
  type        = bool
  default     = true
}

variable "serverless_connector_id" {
  description = "VPC connector ID for serverless services"
  type        = string
  default     = null
}

variable "cognitive_processor_image" {
  description = "Container image for cognitive processor Cloud Run service"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}

variable "relevance_calculator_image" {
  description = "Container image for relevance calculator Cloud Run service"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}
