# Environments

## 🏗️ Environment Configuration

- `dev/`: Development environment (10.10.x.x/24 subnets)
- `prod/`: Production environment (10.20.x.x/24 subnets)

## 🔗 VPC Connector Configuration

Each environment deploys a VPC connector following GCP best practices:

- **Dev**: `vpc-connector-dev` in `shared-dev` subnet
- **Prod**: `vpc-connector-prod` in `shared-prod` subnet

Both environments use the same GCP-compliant architecture pattern for Cloud Run database connectivity.

**Reference**: See `../VPC_CONNECTOR_BEST_PRACTICES.md` for compliance validation.
