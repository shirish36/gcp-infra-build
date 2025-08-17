# Database DNS Configuration Guide

## 🎯 Multiple DNS Options for Database Access

Your Cloud SQL database is accessible via multiple DNS names to provide flexibility for different use cases:

## 📋 Available DNS Names

### 1. **Short DNS (Recommended for Cloud Run)**
```
db.database.vpc-core-{env}.internal
```
- **Best for**: Cloud Run, Cloud Functions, short environment variable names
- **Example**: `db.database.vpc-core-dev.internal`
- **Use case**: When you want concise, readable connection strings

### 2. **Simple DNS (Shortest Option)**
```
sqlserver.database.vpc-core-{env}.internal
```
- **Best for**: Applications requiring the shortest possible DNS name
- **Example**: `sqlserver.database.vpc-core-dev.internal`
- **Use case**: Legacy applications or when character limits are a concern

### 3. **Full DNS (Default/Descriptive)**
```
sql-server.database.vpc-core-{env}.internal
```
- **Best for**: Documentation, explicit naming, enterprise standards
- **Example**: `sql-server.database.vpc-core-dev.internal`
- **Use case**: When you need descriptive, self-documenting names

## 🚀 Cloud Run Implementation Examples

### Option 1: Short DNS (Recommended)
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-app
spec:
  template:
    metadata:
      annotations:
        run.googleapis.com/vpc-access-connector: projects/gifted-palace-468618-q5/locations/us-central1/connectors/vpc-connector-dev
    spec:
      containers:
      - name: app
        image: gcr.io/gifted-palace-468618-q5/my-app:latest
        env:
        - name: DB_HOST
          value: "db.database.vpc-core-dev.internal"
        - name: DB_PORT
          value: "1433"
        - name: DB_NAME
          value: "myapp_db"
        - name: DB_USER
          value: "sqlserver"
```

### Option 2: Simple DNS (Shortest)
```yaml
env:
- name: DATABASE_URL
  value: "sqlserver://sqlserver:password@sqlserver.database.vpc-core-dev.internal:1433/myapp_db"
```

### Option 3: Environment-Specific Configuration
```yaml
# Development
env:
- name: DB_HOST
  value: "db.database.vpc-core-dev.internal"

# Production  
env:
- name: DB_HOST
  value: "db.database.vpc-core-prod.internal"
```

## 🔧 Terraform Outputs

You can reference these DNS names in your Terraform configurations:

```hcl
# Get the short DNS name
output "db_connection_string" {
  value = "Data Source=${module.infrastructure.database_dns_short};Initial Catalog=myapp_db;User ID=sqlserver;Password=${var.db_password}"
}

# Get the simple DNS name
output "db_host_simple" {
  value = module.infrastructure.database_dns_simple
}

# Get the full DNS name
output "db_host_full" {
  value = module.infrastructure.database_dns_fqdn
}
```

## 🧪 Testing DNS Resolution

Test each DNS name from a Compute Engine VM in your VPC:

```bash
# Test short DNS
nslookup db.database.vpc-core-dev.internal

# Test simple DNS
nslookup sqlserver.database.vpc-core-dev.internal

# Test full DNS
nslookup sql-server.database.vpc-core-dev.internal

# All should resolve to the same PSC endpoint IP
```

## 💡 Best Practices

### For Cloud Run:
- **Use**: `db.database.vpc-core-{env}.internal`
- **Why**: Short, clear, environment-aware

### For Cloud Functions:
- **Use**: `sqlserver.database.vpc-core-{env}.internal`
- **Why**: Minimal character count for environment variables

### For Documentation:
- **Use**: `sql-server.database.vpc-core-{env}.internal`
- **Why**: Self-documenting and explicit

### For Connection Strings:
```bash
# SQL Server connection string examples
sqlserver://user:pass@db.database.vpc-core-dev.internal:1433/database
sqlserver://user:pass@sqlserver.database.vpc-core-dev.internal:1433/database
```

## 🔄 Migration Path

If you're currently using IP addresses, migrate gradually:

1. **Phase 1**: Add DNS name alongside IP
2. **Phase 2**: Test DNS resolution
3. **Phase 3**: Replace IP with DNS name
4. **Phase 4**: Remove IP configuration

Example migration:
```yaml
# Before (IP only)
env:
- name: DB_HOST
  value: "10.10.3.5"

# During migration (both)
env:
- name: DB_HOST
  value: "db.database.vpc-core-dev.internal"
- name: DB_HOST_FALLBACK  
  value: "10.10.3.5"

# After (DNS only)
env:
- name: DB_HOST
  value: "db.database.vpc-core-dev.internal"
```

---

**Last Updated**: August 17, 2025  
**DNS Zone**: `database.vpc-core-{env}.internal`  
**All DNS names resolve to**: PSC endpoint private IP
