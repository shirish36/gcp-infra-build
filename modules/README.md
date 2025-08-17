# Terraform Modules

## 🏗️ Infrastructure Modules (step 1)

- `gcs_bucket/`: GCP Storage Bucket for state management
- `cloud_sql/`: Cloud SQL for SQL Server (PSC enabled)
- `network/`: VPC and multi-subnet architecture (us-central1)
- `psc_endpoint/`: Private Service Connect for database access
- `vpc_connector/`: VPC Access Connector for Cloud Run (GCP Best Practice)
- `project_apis/`: API management and enablement

## 🔗 VPC Connector Module

The `vpc_connector/` module implements Google Cloud's best practices for Cloud Run private connectivity:

- **Dedicated Subnet**: Uses `vpc-connector-{env}` subnet with `/28` netmask (GCP requirement)
- **Cost Optimized**: Single connector serves multiple service tiers (API + Batch)
- **Secure**: Private-only database access via PSC endpoint
- **Scalable**: Configurable instance sizing and scaling (2-3 instances for dev)

### 📊 **Communication Flow Diagram**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                             VPC: vpc-core-dev                                │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    │
│  │   Web Tier  │    │   App Tier  │    │ VPC Connect │    │   DB Tier   │    │
│  │(10.10.1.0/24)│    │(10.10.2.0/24)│    │(10.10.4.0/28)│    │(10.10.3.0/24)│    │
│  │             │    │             │    │             │    │             │    │
│  │ 🌐 API      │    │ ⚙️ Batch    │    │ 🔗 VPC      │    │ 🗄️ PSC      │    │
│  │   Services  │    │   Apps      │    │   Connector │    │   Endpoint  │    │
│  │ (Cloud Run) │    │ (Cloud Run) │    │ (e2-micro)  │    │ mydb.myorg  │    │
│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘    │
│         │                   │                   ▲                   ▲        │
│         │                   │                   │                   │        │
│         └───────────────────┼───────────────────┘                   │        │
│                             │                                       │        │
│                             └───────── Database Access ─────────────┘        │
│                                        (Professional URL)                    │
└──────────────────────────────────────────────────────────────────────────────┘

Communication Path:
API/Batch Services → VPC Connector → PSC Endpoint → Cloud SQL (mydb.myorg.com)
```

**Reference**: See `../VPC_CONNECTOR_BEST_PRACTICES.md` for full GCP compliance analysis.
