# Environments

## 🏗️ Environment Configuration

- `dev/`: Development environment (10.10.x.x/24 subnets)
- `prod/`: Production environment (10.20.x.x/24 subnets)

## 🔗 VPC Connector Configuration

Each environment deploys a VPC connector following GCP best practices with dedicated /28 subnets:

- **Dev**: `vpc-connector-dev` in dedicated `vpc-connector-dev` subnet (10.10.4.0/28)
- **Prod**: `vpc-connector-prod` in dedicated `vpc-connector-prod` subnet (10.20.4.0/28)

Both environments use the same GCP-compliant architecture pattern for Cloud Run database connectivity.

**Reference**: See `../VPC_CONNECTOR_BEST_PRACTICES.md` for compliance validation.
