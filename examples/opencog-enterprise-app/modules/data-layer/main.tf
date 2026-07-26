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
  storage_bucket_name = "${var.project_prefix}-cognitive-artifacts-${var.environment}"
  sql_instance_name   = "${var.project_prefix}-cognitive-db-${var.environment}"
  firestore_database  = "${var.project_prefix}-cognitive-docs"
}

/******************************************
  Cloud Storage - Cognitive Artifacts
 ******************************************/

resource "google_storage_bucket" "cognitive_artifacts" {
  project                     = var.project_id
  name                        = local.storage_bucket_name
  location                    = var.region
  force_destroy               = var.environment != "production"
  uniform_bucket_level_access = true
  storage_class               = var.environment == "production" ? "STANDARD" : "NEARLINE"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = var.environment == "production" ? 365 : 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = var.environment == "production" ? 730 : 180
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  dynamic "encryption" {
    for_each = var.enable_cmek ? [1] : []
    content {
      default_kms_key_name = var.kms_key_id
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "data-layer"
  }
}

/******************************************
  Cloud Storage - ML Models Bucket
 ******************************************/

resource "google_storage_bucket" "ml_models" {
  project                     = var.project_id
  name                        = "${var.project_prefix}-ml-models-${var.environment}"
  location                    = var.region
  force_destroy               = var.environment != "production"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"

  versioning {
    enabled = true
  }

  dynamic "encryption" {
    for_each = var.enable_cmek ? [1] : []
    content {
      default_kms_key_name = var.kms_key_id
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "ml-models"
  }
}

/******************************************
  Cloud SQL - PostgreSQL
 ******************************************/

resource "google_sql_database_instance" "cognitive_db" {
  project             = var.project_id
  name                = local.sql_instance_name
  database_version    = "POSTGRES_15"
  region              = var.region
  deletion_protection = var.environment == "production"

  settings {
    tier              = var.sql_tier
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"
    disk_size         = var.sql_disk_size
    disk_type         = "PD_SSD"
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.environment == "production"
      start_time                     = "03:00"
      transaction_log_retention_days = var.environment == "production" ? 7 : 1

      backup_retention_settings {
        retained_backups = var.environment == "production" ? 30 : 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_self_link
      enable_private_path_for_google_cloud_services = true
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4
      update_track = "stable"
    }

    database_flags {
      name  = "max_connections"
      value = var.environment == "production" ? "500" : "100"
    }

    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }

    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    user_labels = {
      environment = var.environment
      application = "opencog"
      component   = "cognitive-db"
    }
  }

  depends_on = [var.private_vpc_connection]
}

resource "google_sql_database" "cognitive_database" {
  project  = var.project_id
  name     = "opencog_cognitive"
  instance = google_sql_database_instance.cognitive_db.name
}

resource "google_sql_database" "relevance_database" {
  project  = var.project_id
  name     = "opencog_relevance"
  instance = google_sql_database_instance.cognitive_db.name
}

resource "google_sql_user" "cognitive_user" {
  project  = var.project_id
  name     = "opencog_app"
  instance = google_sql_database_instance.cognitive_db.name
  password = var.sql_password
}

/******************************************
  Firestore Database
 ******************************************/

resource "google_firestore_database" "cognitive_docs" {
  project                     = var.project_id
  name                        = local.firestore_database
  location_id                 = var.firestore_location
  type                        = "FIRESTORE_NATIVE"
  concurrency_mode            = "OPTIMISTIC"
  app_engine_integration_mode = "DISABLED"

  point_in_time_recovery_enablement = var.environment == "production" ? "POINT_IN_TIME_RECOVERY_ENABLED" : "POINT_IN_TIME_RECOVERY_DISABLED"
  delete_protection_state           = var.environment == "production" ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"
}

/******************************************
  Secret Manager - Database Credentials
 ******************************************/

resource "google_secret_manager_secret" "db_password" {
  project   = var.project_id
  secret_id = "${var.project_prefix}-db-password-${var.environment}"

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.sql_password
}

resource "google_secret_manager_secret" "db_connection_string" {
  project   = var.project_id
  secret_id = "${var.project_prefix}-db-connection-${var.environment}"

  replication {
    auto {}
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

resource "google_secret_manager_secret_version" "db_connection_string" {
  secret      = google_secret_manager_secret.db_connection_string.id
  secret_data = "postgresql://opencog_app:${var.sql_password}@${google_sql_database_instance.cognitive_db.private_ip_address}:5432/opencog_cognitive"
}
