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

locals {
  network_name    = "${var.project_prefix}-opencog-vpc"
  subnet_name     = "${var.project_prefix}-opencog-subnet"
  router_name     = "${var.project_prefix}-opencog-router"
  nat_name        = "${var.project_prefix}-opencog-nat"
  dns_zone_name   = "${var.project_prefix}-opencog-dns"
}

/******************************************
  VPC Network
 ******************************************/

resource "google_compute_network" "opencog_vpc" {
  project                 = var.project_id
  name                    = local.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  description             = "VPC network for OpenCog Enterprise App cognitive computing workloads"
}

/******************************************
  Primary Subnet
 ******************************************/

resource "google_compute_subnetwork" "opencog_subnet" {
  project                  = var.project_id
  name                     = local.subnet_name
  ip_cidr_range            = var.subnet_cidr
  region                   = var.region
  network                  = google_compute_network.opencog_vpc.id
  private_ip_google_access = true
  description              = "Primary subnet for OpenCog cognitive services"

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = var.services_cidr
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

/******************************************
  Cloud Router for NAT
 ******************************************/

resource "google_compute_router" "opencog_router" {
  project = var.project_id
  name    = local.router_name
  region  = var.region
  network = google_compute_network.opencog_vpc.id

  bgp {
    asn = 64514
  }
}

/******************************************
  Cloud NAT for Egress
 ******************************************/

resource "google_compute_router_nat" "opencog_nat" {
  project = var.project_id
  name    = local.nat_name
  router  = google_compute_router.opencog_router.name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

/******************************************
  Private DNS Zone
 ******************************************/

resource "google_dns_managed_zone" "opencog_dns" {
  project     = var.project_id
  name        = local.dns_zone_name
  dns_name    = "${var.dns_domain}."
  description = "Private DNS zone for OpenCog cognitive service discovery"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.opencog_vpc.id
    }
  }
}

/******************************************
  Firewall Rules
 ******************************************/

resource "google_compute_firewall" "allow_internal" {
  project     = var.project_id
  name        = "${var.project_prefix}-allow-internal"
  network     = google_compute_network.opencog_vpc.name
  description = "Allow internal communication within VPC"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr, var.pods_cidr, var.services_cidr]
  priority      = 1000
}

resource "google_compute_firewall" "allow_iap" {
  project     = var.project_id
  name        = "${var.project_prefix}-allow-iap"
  network     = google_compute_network.opencog_vpc.name
  description = "Allow IAP tunneling for secure access"

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  # IAP's IP range
  source_ranges = ["35.235.240.0/20"]
  priority      = 1000
}

resource "google_compute_firewall" "allow_health_checks" {
  project     = var.project_id
  name        = "${var.project_prefix}-allow-health-checks"
  network     = google_compute_network.opencog_vpc.name
  description = "Allow GCP health check probes"

  allow {
    protocol = "tcp"
  }

  # GCP Health Check IP ranges
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  priority      = 1000
}

/******************************************
  Private Service Access for Managed Services
 ******************************************/

resource "google_compute_global_address" "private_ip_range" {
  project       = var.project_id
  name          = "${var.project_prefix}-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.opencog_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.opencog_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

/******************************************
  Serverless VPC Connector
 ******************************************/

resource "google_vpc_access_connector" "serverless_connector" {
  count         = var.enable_serverless_connector ? 1 : 0
  project       = var.project_id
  name          = "${var.project_prefix}-serverless-connector"
  region        = var.region
  network       = google_compute_network.opencog_vpc.name
  ip_cidr_range = var.serverless_connector_cidr
  min_instances = var.environment == "production" ? 2 : 1
  max_instances = var.environment == "production" ? 10 : 3
}
