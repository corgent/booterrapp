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
  dataset_id    = "${replace(var.project_prefix, "-", "_")}_relevance_${var.environment}"
  redis_name    = "${var.project_prefix}-relevance-cache-${var.environment}"
  spanner_name  = "${var.project_prefix}-cognitive-state-${var.environment}"
}

/******************************************
  BigQuery Dataset for Relevance Analytics
 ******************************************/

resource "google_bigquery_dataset" "relevance_analytics" {
  project                    = var.project_id
  dataset_id                 = local.dataset_id
  friendly_name              = "OpenCog Relevance Analytics"
  description                = "Data warehouse for relevance realization analytics and cognitive pattern analysis"
  location                   = var.bigquery_location
  delete_contents_on_destroy = var.environment != "production"

  default_table_expiration_ms = var.environment == "production" ? null : 7776000000 # 90 days

  access {
    role          = "OWNER"
    user_by_email = var.bigquery_owner_email
  }

  dynamic "access" {
    for_each = var.bigquery_reader_group != "" ? [1] : []
    content {
      role           = "READER"
      group_by_email = var.bigquery_reader_group
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "relevance-engine"
  }
}

/******************************************
  BigQuery Tables
 ******************************************/

resource "google_bigquery_table" "cognitive_events" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.relevance_analytics.dataset_id
  table_id            = "cognitive_events"
  deletion_protection = var.environment == "production"

  time_partitioning {
    type  = "DAY"
    field = "event_timestamp"
  }

  clustering = ["event_type", "source_system"]

  schema = jsonencode([
    {
      name        = "event_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique identifier for the cognitive event"
    },
    {
      name        = "event_timestamp"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "Timestamp when the event occurred"
    },
    {
      name        = "event_type"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Type of cognitive event"
    },
    {
      name        = "source_system"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Source system that generated the event"
    },
    {
      name        = "relevance_score"
      type        = "FLOAT64"
      mode        = "NULLABLE"
      description = "Calculated relevance score"
    },
    {
      name        = "attention_weight"
      type        = "FLOAT64"
      mode        = "NULLABLE"
      description = "Attention mechanism weight"
    },
    {
      name        = "salience_indicator"
      type        = "FLOAT64"
      mode        = "NULLABLE"
      description = "Salience detection indicator"
    },
    {
      name        = "context_vector"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "JSON encoded context vector"
    },
    {
      name        = "metadata"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Additional event metadata"
    }
  ])

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

resource "google_bigquery_table" "relevance_scores" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.relevance_analytics.dataset_id
  table_id            = "relevance_scores"
  deletion_protection = var.environment == "production"

  time_partitioning {
    type  = "DAY"
    field = "calculated_at"
  }

  clustering = ["entity_type", "entity_id"]

  schema = jsonencode([
    {
      name        = "score_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique identifier for the relevance score"
    },
    {
      name        = "entity_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "ID of the entity being scored"
    },
    {
      name        = "entity_type"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Type of entity"
    },
    {
      name        = "calculated_at"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "When the score was calculated"
    },
    {
      name        = "relevance_score"
      type        = "FLOAT64"
      mode        = "REQUIRED"
      description = "The calculated relevance score"
    },
    {
      name        = "confidence_level"
      type        = "FLOAT64"
      mode        = "NULLABLE"
      description = "Confidence in the relevance score"
    },
    {
      name        = "context_factors"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Factors used in relevance calculation"
    },
    {
      name        = "model_version"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Version of the relevance model used"
    }
  ])

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

resource "google_bigquery_table" "cognitive_patterns" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.relevance_analytics.dataset_id
  table_id            = "cognitive_patterns"
  deletion_protection = var.environment == "production"

  time_partitioning {
    type  = "DAY"
    field = "detected_at"
  }

  schema = jsonencode([
    {
      name        = "pattern_id"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Unique identifier for the cognitive pattern"
    },
    {
      name        = "pattern_type"
      type        = "STRING"
      mode        = "REQUIRED"
      description = "Type of cognitive pattern"
    },
    {
      name        = "detected_at"
      type        = "TIMESTAMP"
      mode        = "REQUIRED"
      description = "When the pattern was detected"
    },
    {
      name        = "pattern_strength"
      type        = "FLOAT64"
      mode        = "REQUIRED"
      description = "Strength of the detected pattern"
    },
    {
      name        = "related_events"
      type        = "STRING"
      mode        = "REPEATED"
      description = "IDs of related cognitive events"
    },
    {
      name        = "pattern_data"
      type        = "JSON"
      mode        = "NULLABLE"
      description = "Detailed pattern information"
    }
  ])

  labels = {
    environment = var.environment
    application = "opencog"
  }
}

/******************************************
  BigQuery Materialized Views
 ******************************************/

resource "google_bigquery_table" "relevance_summary_mv" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.relevance_analytics.dataset_id
  table_id            = "relevance_summary_mv"
  deletion_protection = false

  materialized_view {
    query               = <<-EOT
      SELECT
        entity_type,
        DATE(calculated_at) as score_date,
        COUNT(*) as total_scores,
        AVG(relevance_score) as avg_relevance,
        MAX(relevance_score) as max_relevance,
        MIN(relevance_score) as min_relevance,
        STDDEV(relevance_score) as stddev_relevance
      FROM `${var.project_id}.${local.dataset_id}.relevance_scores`
      GROUP BY entity_type, DATE(calculated_at)
    EOT
    enable_refresh      = true
    refresh_interval_ms = 3600000 # 1 hour
  }

  depends_on = [google_bigquery_table.relevance_scores]
}

/******************************************
  Memorystore Redis for Caching
 ******************************************/

resource "google_redis_instance" "relevance_cache" {
  project            = var.project_id
  name               = local.redis_name
  tier               = var.environment == "production" ? "STANDARD_HA" : "BASIC"
  memory_size_gb     = var.redis_memory_size_gb
  region             = var.region
  redis_version      = "REDIS_7_0"
  display_name       = "OpenCog Relevance Cache"
  authorized_network = var.network_self_link

  redis_configs = {
    maxmemory-policy = "allkeys-lru"
    notify-keyspace-events = "Ex"
  }

  maintenance_policy {
    weekly_maintenance_window {
      day = "SUNDAY"
      start_time {
        hours   = 4
        minutes = 0
      }
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "relevance-cache"
  }
}

/******************************************
  Cloud Spanner (Optional - Global Scale)
 ******************************************/

resource "google_spanner_instance" "cognitive_state" {
  count        = var.enable_spanner ? 1 : 0
  project      = var.project_id
  name         = local.spanner_name
  config       = var.spanner_config
  display_name = "OpenCog Cognitive State"
  num_nodes    = var.spanner_nodes
  
  labels = {
    environment = var.environment
    application = "opencog"
    component   = "cognitive-state"
  }
}

resource "google_spanner_database" "cognitive_state_db" {
  count                   = var.enable_spanner ? 1 : 0
  project                 = var.project_id
  instance                = google_spanner_instance.cognitive_state[0].name
  name                    = "cognitive_state"
  version_retention_period = var.environment == "production" ? "7d" : "1d"
  deletion_protection     = var.environment == "production"

  ddl = [
    <<-EOT
      CREATE TABLE CognitiveEntities (
        EntityId STRING(36) NOT NULL,
        EntityType STRING(100) NOT NULL,
        CreatedAt TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
        UpdatedAt TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
        StateData JSON,
        RelevanceScore FLOAT64,
        AttentionWeight FLOAT64
      ) PRIMARY KEY (EntityId)
    EOT,
    <<-EOT
      CREATE TABLE RelevanceHistory (
        EntityId STRING(36) NOT NULL,
        CalculatedAt TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
        Score FLOAT64 NOT NULL,
        Confidence FLOAT64,
        ModelVersion STRING(50)
      ) PRIMARY KEY (EntityId, CalculatedAt),
        INTERLEAVE IN PARENT CognitiveEntities ON DELETE CASCADE
    EOT,
    <<-EOT
      CREATE INDEX RelevanceHistoryByScore ON RelevanceHistory(Score DESC)
    EOT
  ]
}

/******************************************
  Service Account for Relevance Engine
 ******************************************/

resource "google_service_account" "relevance_engine" {
  project      = var.project_id
  account_id   = "${var.project_prefix}-relevance-engine"
  display_name = "OpenCog Relevance Engine Service Account"
  description  = "Service account for relevance engine operations"
}

resource "google_project_iam_member" "relevance_bigquery_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.relevance_engine.email}"
}

resource "google_project_iam_member" "relevance_bigquery_job" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.relevance_engine.email}"
}

resource "google_project_iam_member" "relevance_redis_editor" {
  project = var.project_id
  role    = "roles/redis.editor"
  member  = "serviceAccount:${google_service_account.relevance_engine.email}"
}

resource "google_spanner_database_iam_member" "relevance_spanner_access" {
  count    = var.enable_spanner ? 1 : 0
  project  = var.project_id
  instance = google_spanner_instance.cognitive_state[0].name
  database = google_spanner_database.cognitive_state_db[0].name
  role     = "roles/spanner.databaseUser"
  member   = "serviceAccount:${google_service_account.relevance_engine.email}"
}
