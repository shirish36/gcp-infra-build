# Terraform Modules

## 🏗️ Infrastructure Modules

- `gcs_bucket/`: GCP Storage Bucket for state management
- `cloud_sql/`: Cloud SQL for SQL Server (PSC enabled)
- `network/`: VPC and multi-subnet architecture (us-central1)
- `psc_endpoint/`: Private Service Connect for database access
- `vpc_connector/`: VPC Access Connector for Cloud Run (GCP Best Practice)
- `project_apis/`: API management and enablement

## 🔗 VPC Connector Module

The `vpc_connector/` module implements Google Cloud's best practices for Cloud Run private connectivity:

- **Dedicated Subnet**: Uses `shared-{env}` subnet exclusively
- **Cost Optimized**: Single connector serves multiple service tiers
- **Secure**: Private-only database access via PSC endpoint
- **Scalable**: Configurable instance sizing and scaling

**Reference**: See `../VPC_CONNECTOR_BEST_PRACTICES.md` for full GCP compliance analysis.
