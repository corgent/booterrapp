# OpenCog Enterprise App

This Terraform configuration deploys a complete GCP infrastructure for the **OpenCog Enterprise App** - an enterprise cognitive computing platform designed for optimal cognitive grip on relevance realization.

## Overview

The OpenCog Enterprise App infrastructure provides:

- **GKE Cluster** with specialized node pools for cognitive workloads
- **Vertex AI** for ML training and serving
- **BigQuery** for relevance analytics and pattern analysis
- **Memorystore (Redis)** for high-performance caching
- **Cloud SQL** for relational data storage
- **Firestore** for flexible document storage
- **Pub/Sub** for event-driven architecture
- **Cloud Run** for serverless cognitive processing
- **Comprehensive observability** with monitoring, logging, and alerting

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          OpenCog Enterprise App                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Networking    │  │   OpenCog Core  │  │ Cognitive Svcs  │             │
│  │                 │  │                 │  │                 │             │
│  │  • VPC Network  │  │  • GKE Cluster  │  │  • Vertex AI    │             │
│  │  • Subnets      │  │  • Node Pools   │  │  • Cloud Run    │             │
│  │  • Cloud NAT    │  │  • Artifact Reg │  │  • Pub/Sub      │             │
│  │  • Cloud DNS    │  │  • Workload ID  │  │  • Scheduler    │             │
│  │  • Firewall     │  │                 │  │                 │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │   Data Layer    │  │ Relevance Eng.  │  │  Observability  │             │
│  │                 │  │                 │  │                 │             │
│  │  • Cloud SQL    │  │  • BigQuery     │  │  • Dashboard    │             │
│  │  • Firestore    │  │  • Memorystore  │  │  • Alerting     │             │
│  │  • GCS Buckets  │  │  • Spanner (opt)│  │  • Log Sinks    │             │
│  │  • Secrets      │  │  • Analytics    │  │  • SLO/SLI      │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Key Features

### Cognitive Grip on Relevance Realization

The architecture specifically supports:

- **Attention Mechanisms**: Vertex AI for attention-based models
- **Salience Detection**: Real-time streaming with Pub/Sub for salient event processing
- **Context Integration**: BigQuery for contextual data warehousing
- **Pattern Recognition**: GKE workloads for cognitive pattern processing
- **Memory Consolidation**: Memorystore and Firestore for working and long-term memory

### Scalability Patterns

- Horizontal pod autoscaling for cognitive workloads
- Vertical pod autoscaling for memory-intensive tasks
- Cluster autoscaling for dynamic resource allocation
- Multi-cluster deployment for global cognitive processing (via Cloud Spanner)

## Prerequisites

1. A GCP Organization with appropriate permissions
2. Billing account linked to the organization
3. Google Groups for org admins and billing admins
4. Terraform >= 1.3
5. gcloud CLI configured with appropriate credentials

### Required Permissions

The user or service account running Terraform needs:

- `roles/resourcemanager.organizationAdmin` on GCP Organization
- `roles/billing.admin` on the billing account
- `roles/orgpolicy.policyAdmin` on GCP Organization

## Quick Start

### 1. Clone and Configure

```bash
cd examples/opencog-enterprise-app

# Copy and customize variables
cp terraform.example.tfvars terraform.tfvars
```

### 2. Edit Variables

Update `terraform.tfvars` with your values:

```hcl
org_id               = "123456789012"
billing_account      = "AAAAAA-BBBBBB-CCCCCC"
group_org_admins     = "gcp-org-admins@example.com"
group_billing_admins = "gcp-billing-admins@example.com"
sql_password         = "your-secure-password"
```

### 3. Initialize and Apply

```bash
terraform init
terraform plan
terraform apply
```

### 4. Configure kubectl

```bash
# The output provides the exact command
$(terraform output -raw kubectl_command)
```

## Module Structure

```
opencog-enterprise-app/
├── main.tf                 # Root module orchestration
├── variables.tf            # Input variable definitions
├── outputs.tf              # Output value definitions
├── versions.tf             # Provider requirements
├── terraform.example.tfvars # Example variable values
├── environments/
│   ├── dev/                # Development environment
│   ├── staging/            # Staging environment
│   └── production/         # Production environment
└── modules/
    ├── networking/         # VPC, subnets, firewall
    ├── data-layer/         # Storage, SQL, Firestore
    ├── opencog-core/       # GKE, Artifact Registry
    ├── cognitive-services/ # Vertex AI, Cloud Run, Pub/Sub
    ├── relevance-engine/   # BigQuery, Redis, Spanner
    └── observability/      # Monitoring, Logging, Alerting
```

## Environments

### Development

```bash
cd environments/dev
terraform init
terraform apply
```

Features:
- Smaller instance sizes
- Spot/preemptible nodes for cost savings
- Reduced resource allocations
- Disabled production-only features

### Staging

```bash
cd environments/staging
terraform init
terraform apply
```

Features:
- Production-like configuration at reduced scale
- SLO monitoring enabled
- CI/CD integration
- Integration testing capabilities

### Production

```bash
cd environments/production
terraform init
terraform apply
```

Features:
- Full high-availability configuration
- CMEK encryption enabled
- Binary authorization for GKE
- Multi-region Spanner (optional)
- Complete observability stack

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| org_id | GCP Organization ID | `string` | n/a | yes |
| billing_account | Billing account ID | `string` | n/a | yes |
| group_org_admins | Google Group for org admins | `string` | n/a | yes |
| group_billing_admins | Google Group for billing admins | `string` | n/a | yes |
| sql_password | Cloud SQL password | `string` | n/a | yes |
| environment | Environment (dev/staging/production) | `string` | `"dev"` | no |
| default_region | Default GCP region | `string` | `"us-central1"` | no |
| enable_gpu_nodes | Enable GPU node pool | `bool` | `false` | no |
| enable_spanner | Enable Cloud Spanner | `bool` | `false` | no |
| enable_vertex_ai | Enable Vertex AI | `bool` | `true` | no |

See `variables.tf` for the complete list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| seed_project_id | GCP project ID |
| gke_cluster_name | GKE cluster name |
| gke_cluster_endpoint | GKE cluster endpoint |
| artifact_registry_url | Container registry URL |
| bigquery_dataset_id | BigQuery dataset for analytics |
| redis_connection_string | Redis connection string |
| kubectl_command | Command to configure kubectl |

See `outputs.tf` for the complete list of outputs.

## Security Considerations

1. **Secrets Management**: Use Secret Manager for sensitive data
2. **Network Security**: Private GKE cluster with authorized networks
3. **Encryption**: Optional CMEK for data at rest
4. **IAM**: Workload Identity for secure service account binding
5. **Binary Authorization**: Optional container image verification

## Cost Optimization

For development environments:
- Use spot/preemptible nodes
- Reduce node pool sizes
- Disable Cloud Spanner
- Use smaller SQL instances

## Troubleshooting

### Common Issues

1. **API not enabled**: Ensure all required APIs are enabled
2. **Permission denied**: Verify IAM permissions
3. **Quota exceeded**: Request quota increases
4. **Network conflicts**: Check CIDR ranges for overlaps

### Logs

```bash
# GKE workload logs
kubectl logs -n opencog -l app=cognitive-processor

# Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision"
```

## Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for guidelines.

## License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.
