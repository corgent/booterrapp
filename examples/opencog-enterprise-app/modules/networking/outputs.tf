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

output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.opencog_vpc.id
}

output "network_name" {
  description = "The name of the VPC network"
  value       = google_compute_network.opencog_vpc.name
}

output "network_self_link" {
  description = "The self-link of the VPC network"
  value       = google_compute_network.opencog_vpc.self_link
}

output "subnet_id" {
  description = "The ID of the primary subnet"
  value       = google_compute_subnetwork.opencog_subnet.id
}

output "subnet_name" {
  description = "The name of the primary subnet"
  value       = google_compute_subnetwork.opencog_subnet.name
}

output "subnet_self_link" {
  description = "The self-link of the primary subnet"
  value       = google_compute_subnetwork.opencog_subnet.self_link
}

output "pods_range_name" {
  description = "The name of the secondary IP range for GKE pods"
  value       = "gke-pods"
}

output "services_range_name" {
  description = "The name of the secondary IP range for GKE services"
  value       = "gke-services"
}

output "router_name" {
  description = "The name of the Cloud Router"
  value       = google_compute_router.opencog_router.name
}

output "nat_name" {
  description = "The name of the Cloud NAT"
  value       = google_compute_router_nat.opencog_nat.name
}

output "dns_zone_name" {
  description = "The name of the private DNS zone"
  value       = google_dns_managed_zone.opencog_dns.name
}

output "dns_name_servers" {
  description = "The DNS name servers for the zone"
  value       = google_dns_managed_zone.opencog_dns.name_servers
}

output "private_vpc_connection" {
  description = "The private VPC connection for managed services"
  value       = google_service_networking_connection.private_vpc_connection.id
}

output "serverless_connector_id" {
  description = "The ID of the serverless VPC connector"
  value       = var.enable_serverless_connector ? google_vpc_access_connector.serverless_connector[0].id : null
}
