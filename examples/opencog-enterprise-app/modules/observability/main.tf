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
  dashboard_name   = "${var.project_prefix}-cognitive-dashboard-${var.environment}"
  log_bucket_name  = "${var.project_prefix}-audit-logs-${var.environment}"
}

/******************************************
  Log Sink - Audit Logs to BigQuery
 ******************************************/

resource "google_logging_project_sink" "audit_logs_bq" {
  project     = var.project_id
  name        = "${var.project_prefix}-audit-logs-bq-${var.environment}"
  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${var.log_dataset_id}"
  filter      = <<-EOT
    logName:"cloudaudit.googleapis.com" OR
    logName:"activity" OR
    logName:"data_access"
  EOT

  unique_writer_identity = true

  bigquery_options {
    use_partitioned_tables = true
  }
}

resource "google_bigquery_dataset_iam_member" "log_sink_writer" {
  project    = var.project_id
  dataset_id = var.log_dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_logging_project_sink.audit_logs_bq.writer_identity
}

/******************************************
  Log Sink - Application Logs to Storage
 ******************************************/

resource "google_storage_bucket" "log_archive" {
  project                     = var.project_id
  name                        = local.log_bucket_name
  location                    = var.region
  force_destroy               = var.environment != "production"
  uniform_bucket_level_access = true
  storage_class               = "NEARLINE"

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  lifecycle_rule {
    condition {
      age = 2555 # 7 years for compliance
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    application = "opencog"
    component   = "log-archive"
  }
}

resource "google_logging_project_sink" "app_logs_storage" {
  project     = var.project_id
  name        = "${var.project_prefix}-app-logs-storage-${var.environment}"
  destination = "storage.googleapis.com/${google_storage_bucket.log_archive.name}"
  filter      = <<-EOT
    resource.type="k8s_container" AND
    resource.labels.namespace_name="opencog" OR
    resource.type="cloud_run_revision" AND
    labels."opencog/component" != ""
  EOT

  unique_writer_identity = true
}

resource "google_storage_bucket_iam_member" "log_sink_writer_storage" {
  bucket = google_storage_bucket.log_archive.name
  role   = "roles/storage.objectCreator"
  member = google_logging_project_sink.app_logs_storage.writer_identity
}

/******************************************
  Log-Based Metrics
 ******************************************/

resource "google_logging_metric" "relevance_calculation_errors" {
  project     = var.project_id
  name        = "opencog/relevance_calculation_errors"
  description = "Count of relevance calculation errors"
  filter      = <<-EOT
    resource.type="k8s_container" AND
    resource.labels.namespace_name="opencog" AND
    severity>=ERROR AND
    jsonPayload.component="relevance-engine"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "error_type"
      value_type  = "STRING"
      description = "Type of error"
    }
  }

  label_extractors = {
    "error_type" = "EXTRACT(jsonPayload.error_type)"
  }
}

resource "google_logging_metric" "cognitive_event_latency" {
  project     = var.project_id
  name        = "opencog/cognitive_event_latency"
  description = "Latency distribution for cognitive event processing"
  filter      = <<-EOT
    resource.type="k8s_container" AND
    resource.labels.namespace_name="opencog" AND
    jsonPayload.component="cognitive-processor" AND
    jsonPayload.event="processing_complete"
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "DISTRIBUTION"
    unit        = "ms"
  }

  value_extractor = "EXTRACT(jsonPayload.latency_ms)"

  bucket_options {
    explicit_buckets {
      bounds = [10, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
    }
  }
}

resource "google_logging_metric" "attention_weight_distribution" {
  project     = var.project_id
  name        = "opencog/attention_weight_distribution"
  description = "Distribution of attention weights in cognitive processing"
  filter      = <<-EOT
    resource.type="k8s_container" AND
    resource.labels.namespace_name="opencog" AND
    jsonPayload.component="attention-mechanism" AND
    jsonPayload.attention_weight!=""
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "DISTRIBUTION"
    unit        = "1"
  }

  value_extractor = "EXTRACT(jsonPayload.attention_weight)"

  bucket_options {
    explicit_buckets {
      bounds = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    }
  }
}

/******************************************
  Monitoring Dashboard
 ******************************************/

resource "google_monitoring_dashboard" "cognitive_dashboard" {
  project        = var.project_id
  dashboard_json = jsonencode({
    displayName = "OpenCog Cognitive Services Dashboard - ${title(var.environment)}"
    gridLayout = {
      columns = 2
      widgets = [
        {
          title = "Relevance Score Distribution"
          scorecard = {
            timeSeriesQuery = {
              timeSeriesFilter = {
                filter = "metric.type=\"custom.googleapis.com/opencog/relevance_score\" resource.type=\"global\""
                aggregation = {
                  alignmentPeriod  = "300s"
                  perSeriesAligner = "ALIGN_MEAN"
                }
              }
            }
            thresholds = [
              { value = 0.3, color = "RED", direction = "BELOW" }
              { value = 0.7, color = "YELLOW", direction = "BELOW" }
              { value = 1.0, color = "GREEN", direction = "BELOW" }
            ]
          }
        },
        {
          title = "Cognitive Event Processing Rate"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/opencog/cognitive_event_latency\" resource.type=\"k8s_container\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
            yAxis = {
              scale = "LINEAR"
            }
          }
        },
        {
          title = "Relevance Calculation Errors"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/opencog/relevance_calculation_errors\" resource.type=\"k8s_container\""
                    aggregation = {
                      alignmentPeriod    = "300s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["metric.label.error_type"]
                    }
                  }
                }
                plotType = "STACKED_BAR"
              }
            ]
          }
        },
        {
          title = "GKE Cluster CPU Utilization"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/cpu/core_usage_time\" resource.type=\"k8s_container\" resource.label.namespace_name=\"opencog\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_RATE"
                      crossSeriesReducer = "REDUCE_SUM"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Memory Usage by Pod"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"kubernetes.io/container/memory/used_bytes\" resource.type=\"k8s_container\" resource.label.namespace_name=\"opencog\""
                    aggregation = {
                      alignmentPeriod    = "60s"
                      perSeriesAligner   = "ALIGN_MEAN"
                      crossSeriesReducer = "REDUCE_SUM"
                      groupByFields      = ["resource.label.pod_name"]
                    }
                  }
                }
                plotType = "STACKED_AREA"
              }
            ]
          }
        },
        {
          title = "Attention Weight Distribution"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"logging.googleapis.com/user/opencog/attention_weight_distribution\" resource.type=\"k8s_container\""
                    aggregation = {
                      alignmentPeriod  = "300s"
                      perSeriesAligner = "ALIGN_DELTA"
                    }
                  }
                }
                plotType = "HEATMAP"
              }
            ]
          }
        },
        {
          title = "Cloud Run Latency (Cognitive Processor)"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.service_name=starts_with(\"${var.project_prefix}-cognitive-processor\")"
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_PERCENTILE_99"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        },
        {
          title = "Redis Cache Hit Rate"
          xyChart = {
            dataSets = [
              {
                timeSeriesQuery = {
                  timeSeriesFilter = {
                    filter = "metric.type=\"redis.googleapis.com/stats/cache_hit_ratio\" resource.type=\"redis_instance\""
                    aggregation = {
                      alignmentPeriod  = "60s"
                      perSeriesAligner = "ALIGN_MEAN"
                    }
                  }
                }
                plotType = "LINE"
              }
            ]
          }
        }
      ]
    }
  })
}

/******************************************
  Alerting Policies
 ******************************************/

resource "google_monitoring_alert_policy" "high_error_rate" {
  project      = var.project_id
  display_name = "OpenCog High Error Rate - ${title(var.environment)}"
  combiner     = "OR"

  conditions {
    display_name = "Relevance Calculation Error Rate > 1%"
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/opencog/relevance_calculation_errors\" resource.type=\"k8s_container\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.01

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = <<-EOT
      ## High Error Rate Alert
      
      The relevance calculation error rate has exceeded 1%.
      
      ### Investigation Steps
      1. Check the Cloud Logging console for recent errors
      2. Review the cognitive-processor pod logs in GKE
      3. Verify database connectivity
      4. Check for any recent deployments
      
      ### Runbook
      See: https://docs.opencog.internal/runbooks/high-error-rate
    EOT
    mime_type = "text/markdown"
  }

  user_labels = {
    environment = var.environment
    application = "opencog"
    severity    = "critical"
  }
}

resource "google_monitoring_alert_policy" "low_relevance_score" {
  project      = var.project_id
  display_name = "OpenCog Low Relevance Scores - ${title(var.environment)}"
  combiner     = "OR"

  conditions {
    display_name = "Average Relevance Score < 0.3"
    condition_threshold {
      filter          = "metric.type=\"custom.googleapis.com/opencog/relevance_score\" resource.type=\"global\""
      duration        = "600s"
      comparison      = "COMPARISON_LT"
      threshold_value = 0.3

      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_MEAN"
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels

  alert_strategy {
    auto_close = "3600s"
  }

  documentation {
    content   = <<-EOT
      ## Low Relevance Score Alert
      
      Average relevance scores have dropped below 0.3, indicating potential issues with cognitive processing.
      
      ### Investigation Steps
      1. Check feature store data freshness
      2. Review model performance metrics
      3. Verify input data quality
      4. Check for data pipeline issues
      
      ### Runbook
      See: https://docs.opencog.internal/runbooks/low-relevance
    EOT
    mime_type = "text/markdown"
  }

  user_labels = {
    environment = var.environment
    application = "opencog"
    severity    = "warning"
  }
}

resource "google_monitoring_alert_policy" "gke_pod_crash_loop" {
  project      = var.project_id
  display_name = "OpenCog GKE Pod CrashLoopBackOff - ${title(var.environment)}"
  combiner     = "OR"

  conditions {
    display_name = "Pod in CrashLoopBackOff"
    condition_threshold {
      filter          = "metric.type=\"kubernetes.io/container/restart_count\" resource.type=\"k8s_container\" resource.label.namespace_name=\"opencog\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 3

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_DELTA"
        group_by_fields    = ["resource.label.pod_name"]
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = var.notification_channels

  alert_strategy {
    auto_close = "1800s"
  }

  documentation {
    content   = <<-EOT
      ## Pod CrashLoopBackOff Alert
      
      A pod in the opencog namespace has restarted more than 3 times in 5 minutes.
      
      ### Investigation Steps
      1. kubectl describe pod <pod-name> -n opencog
      2. kubectl logs <pod-name> -n opencog --previous
      3. Check for OOM kills or resource constraints
      4. Review recent configuration changes
    EOT
    mime_type = "text/markdown"
  }

  user_labels = {
    environment = var.environment
    application = "opencog"
    severity    = "critical"
  }
}

/******************************************
  Uptime Checks
 ******************************************/

resource "google_monitoring_uptime_check_config" "cognitive_processor_health" {
  count        = var.enable_uptime_checks ? 1 : 0
  project      = var.project_id
  display_name = "OpenCog Cognitive Processor Health - ${title(var.environment)}"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path           = "/health"
    port           = 443
    use_ssl        = true
    validate_ssl   = true
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = var.cognitive_processor_domain
    }
  }

  content_matchers {
    content = "healthy"
    matcher = "CONTAINS_STRING"
  }

  checker_type = "STATIC_IP_CHECKERS"
}

/******************************************
  SLO Configuration
 ******************************************/

resource "google_monitoring_slo" "cognitive_processor_availability" {
  count        = var.enable_slo ? 1 : 0
  project      = var.project_id
  service      = var.monitoring_service_id
  slo_id       = "cognitive-processor-availability-${var.environment}"
  display_name = "Cognitive Processor Availability SLO - ${title(var.environment)}"

  goal                = var.environment == "production" ? 0.999 : 0.99
  rolling_period_days = 30

  request_based_sli {
    good_total_ratio {
      good_service_filter = <<-EOT
        metric.type="run.googleapis.com/request_count"
        resource.type="cloud_run_revision"
        resource.label.service_name=starts_with("${var.project_prefix}-cognitive-processor")
        metric.label.response_code_class="2xx"
      EOT
      total_service_filter = <<-EOT
        metric.type="run.googleapis.com/request_count"
        resource.type="cloud_run_revision"
        resource.label.service_name=starts_with("${var.project_prefix}-cognitive-processor")
      EOT
    }
  }
}

resource "google_monitoring_slo" "relevance_latency" {
  count        = var.enable_slo ? 1 : 0
  project      = var.project_id
  service      = var.monitoring_service_id
  slo_id       = "relevance-latency-${var.environment}"
  display_name = "Relevance Calculation Latency SLO - ${title(var.environment)}"

  goal                = var.environment == "production" ? 0.95 : 0.90
  rolling_period_days = 30

  request_based_sli {
    distribution_cut {
      distribution_filter = <<-EOT
        metric.type="logging.googleapis.com/user/opencog/cognitive_event_latency"
        resource.type="k8s_container"
      EOT
      range {
        max = var.environment == "production" ? 500 : 1000
      }
    }
  }
}
