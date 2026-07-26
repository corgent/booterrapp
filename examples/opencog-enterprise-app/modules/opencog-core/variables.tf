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
  description = "GCP project ID for OpenCog core resources"
  type        = string
}

variable "project_prefix" {
  description = "Name prefix for OpenCog core resources"
  type        = string
  default     = "opencog"
}

variable "region" {
  description = "GCP region for OpenCog core resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "dev"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "pods_range_name" {
  description = "Name of the secondary IP range for GKE pods"
  type        = string
}

variable "services_range_name" {
  description = "Name of the secondary IP range for GKE services"
  type        = string
}

variable "master_cidr" {
  description = "CIDR range for GKE master"
  type        = string
  default     = "172.16.0.0/28"
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the GKE master"
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "enable_binary_authorization" {
  description = "Enable Binary Authorization for GKE"
  type        = bool
  default     = false
}

# General node pool configuration
variable "general_pool_machine_type" {
  description = "Machine type for general purpose node pool"
  type        = string
  default     = "e2-standard-4"
}

variable "general_pool_node_count" {
  description = "Initial node count for general pool"
  type        = number
  default     = 1
}

variable "general_pool_min_nodes" {
  description = "Minimum nodes for general pool autoscaling"
  type        = number
  default     = 1
}

variable "general_pool_max_nodes" {
  description = "Maximum nodes for general pool autoscaling"
  type        = number
  default     = 5
}

# Cognitive node pool configuration
variable "cognitive_pool_machine_type" {
  description = "Machine type for cognitive workload node pool"
  type        = string
  default     = "n2-highmem-8"
}

variable "cognitive_pool_node_count" {
  description = "Initial node count for cognitive pool"
  type        = number
  default     = 1
}

variable "cognitive_pool_min_nodes" {
  description = "Minimum nodes for cognitive pool autoscaling"
  type        = number
  default     = 0
}

variable "cognitive_pool_max_nodes" {
  description = "Maximum nodes for cognitive pool autoscaling"
  type        = number
  default     = 10
}

# GPU node pool configuration
variable "enable_gpu_nodes" {
  description = "Enable GPU node pool"
  type        = bool
  default     = false
}

variable "gpu_pool_machine_type" {
  description = "Machine type for GPU node pool"
  type        = string
  default     = "n1-standard-8"
}

variable "gpu_pool_node_count" {
  description = "Initial node count for GPU pool"
  type        = number
  default     = 0
}

variable "gpu_pool_min_nodes" {
  description = "Minimum nodes for GPU pool autoscaling"
  type        = number
  default     = 0
}

variable "gpu_pool_max_nodes" {
  description = "Maximum nodes for GPU pool autoscaling"
  type        = number
  default     = 4
}

variable "gpu_type" {
  description = "Type of GPU accelerator"
  type        = string
  default     = "nvidia-tesla-t4"
}

variable "gpu_count_per_node" {
  description = "Number of GPUs per node"
  type        = number
  default     = 1
}
