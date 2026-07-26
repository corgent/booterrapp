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
  vertex_sa_name     = "${var.project_prefix}-vertex-ai"
  cloud_run_sa_name  = "${var.project_prefix}-cloud-run"
}

/******************************************
  Service Account for Vertex AI
 ******************************************/

resource "google_service_account" "vertex_ai" {
  project      = var.project_id
  account_id   = local.vertex_sa_name
  display_name = "OpenCog Vertex AI Service Account"
  description  = "Service account for Vertex AI ML operations"
}

resource "google_project_iam_member" "vertex_ai_user" {
  project = var.project_id
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.vertex_ai.email}"
}

resource "google_project_iam_member" "vertex_storage_access" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.vertex_ai.email}"
}

resource "google_project_iam_member" "vertex_bigquery_access" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.vertex_ai.email}"
}

/******************************************
  Service Account for Cloud Run
 ******************************************/

resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = local.cloud_run_sa_name
  display_name = "OpenCog Cloud Run Service Account"
  description  = "Service account for serverless cognitive processing"
}

resource "google_project_iam_member" "cloud_run_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_storage" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

/******************************************
  Pub/Sub Topics for Event Streaming
 ******************************************/

resource "google_pubsub_topic" "cognitive_events" {
  project = var.project_id
  name    = "${var.project_prefix}-cognitive-events-${var.environment}"

  message_retention_duration = var.environment == "production" ? "604800s" : "86400s"

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "event-streaming"
  }
}

resource "google_pubsub_topic" "relevance_updates" {
  project = var.project_id
  name    = "${var.project_prefix}-relevance-updates-${var.environment}"

  message_retention_duration = var.environment == "production" ? "604800s" : "86400s"

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "relevance-engine"
  }
}

resource "google_pubsub_topic" "model_predictions" {
  project = var.project_id
  name    = "${var.project_prefix}-model-predictions-${var.environment}"

  message_retention_duration = var.environment == "production" ? "604800s" : "86400s"

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "ml-pipeline"
  }
}

resource "google_pubsub_topic" "dead_letter" {
  project = var.project_id
  name    = "${var.project_prefix}-dead-letter-${var.environment}"

  message_retention_duration = "604800s"

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "error-handling"
  }
}

/******************************************
  Pub/Sub Subscriptions
 ******************************************/

resource "google_pubsub_subscription" "cognitive_events_processor" {
  project = var.project_id
  name    = "${var.project_prefix}-cognitive-events-processor-${var.environment}"
  topic   = google_pubsub_topic.cognitive_events.id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s"
  retain_acked_messages      = var.environment == "production"

  expiration_policy {
    ttl = ""
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

resource "google_pubsub_subscription" "relevance_updates_processor" {
  project = var.project_id
  name    = "${var.project_prefix}-relevance-updates-processor-${var.environment}"
  topic   = google_pubsub_topic.relevance_updates.id

  ack_deadline_seconds       = 60
  message_retention_duration = "604800s"
  retain_acked_messages      = var.environment == "production"

  expiration_policy {
    ttl = ""
  }

  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

/******************************************
  Vertex AI Feature Store (Optional)
 ******************************************/

resource "google_vertex_ai_featurestore" "relevance_features" {
  count    = var.enable_vertex_ai ? 1 : 0
  provider = google-beta
  project  = var.project_id
  name     = "${replace(var.project_prefix, "-", "_")}_relevance_features_${var.environment}"
  region   = var.region

  online_serving_config {
    fixed_node_count = var.environment == "production" ? 2 : 1
  }

  force_destroy = var.environment != "production"

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "feature-store"
  }
}

resource "google_vertex_ai_featurestore_entitytype" "cognitive_entity" {
  count        = var.enable_vertex_ai ? 1 : 0
  provider     = google-beta
  name         = "cognitive_entity"
  featurestore = google_vertex_ai_featurestore.relevance_features[0].id

  monitoring_config {
    snapshot_analysis {
      disabled = false
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

/******************************************
  Cloud Run Service - Cognitive Processor
 ******************************************/

resource "google_cloud_run_v2_service" "cognitive_processor" {
  count    = var.enable_cloud_run ? 1 : 0
  project  = var.project_id
  name     = "${var.project_prefix}-cognitive-processor-${var.environment}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.environment == "production" ? 1 : 0
      max_instance_count = var.environment == "production" ? 100 : 10
    }

    containers {
      image = var.cognitive_processor_image

      resources {
        limits = {
          cpu    = var.environment == "production" ? "4" : "2"
          memory = var.environment == "production" ? "8Gi" : "2Gi"
        }
        cpu_idle          = var.environment != "production"
        startup_cpu_boost = true
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "PUBSUB_TOPIC"
        value = google_pubsub_topic.cognitive_events.name
      }

      startup_probe {
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
        http_get {
          path = "/health"
          port = 8080
        }
      }

      liveness_probe {
        timeout_seconds   = 5
        period_seconds    = 30
        failure_threshold = 3
        http_get {
          path = "/health"
          port = 8080
        }
      }
    }

    vpc_access {
      connector = var.serverless_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    timeout = "300s"
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "cognitive-processor"
  }
}

/******************************************
  Cloud Run Service - Relevance Calculator
 ******************************************/

resource "google_cloud_run_v2_service" "relevance_calculator" {
  count    = var.enable_cloud_run ? 1 : 0
  project  = var.project_id
  name     = "${var.project_prefix}-relevance-calculator-${var.environment}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.environment == "production" ? 1 : 0
      max_instance_count = var.environment == "production" ? 50 : 5
    }

    containers {
      image = var.relevance_calculator_image

      resources {
        limits = {
          cpu    = var.environment == "production" ? "2" : "1"
          memory = var.environment == "production" ? "4Gi" : "1Gi"
        }
        cpu_idle          = var.environment != "production"
        startup_cpu_boost = true
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      env {
        name  = "PROJECT_ID"
        value = var.project_id
      }

      env {
        name  = "RELEVANCE_TOPIC"
        value = google_pubsub_topic.relevance_updates.name
      }

      startup_probe {
        initial_delay_seconds = 5
        timeout_seconds       = 3
        period_seconds        = 5
        failure_threshold     = 3
        http_get {
          path = "/health"
          port = 8080
        }
      }

      liveness_probe {
        timeout_seconds   = 3
        period_seconds    = 15
        failure_threshold = 3
        http_get {
          path = "/health"
          port = 8080
        }
      }
    }

    vpc_access {
      connector = var.serverless_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    timeout = "60s"
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "relevance-calculator"
  }
}

/******************************************
  Cloud Scheduler Jobs
 ******************************************/

resource "google_cloud_scheduler_job" "model_refresh" {
  count     = var.enable_cloud_run ? 1 : 0
  project   = var.project_id
  name      = "${var.project_prefix}-model-refresh-${var.environment}"
  region    = var.region
  schedule  = var.environment == "production" ? "0 */6 * * *" : "0 0 * * *"
  time_zone = "UTC"

  retry_config {
    retry_count          = 3
    min_backoff_duration = "30s"
    max_backoff_duration = "300s"
    max_doublings        = 3
  }

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_v2_service.cognitive_processor[0].uri}/refresh"

    oidc_token {
      service_account_email = google_service_account.cloud_run.email
    }
  }
}
