# Custom Domain DNS Setup Guide

## 🎯 Overview

This guide explains how to configure and use custom domain names for your database, allowing you to use clean URLs like `mydb.myorg.com` instead of long internal DNS names.

## 🏗️ Architecture

The custom domain setup creates:

1. **Private DNS Zone**: `myorg.com` (internal only)
2. **Custom DNS Record**: `mydb.myorg.com` → PSC Endpoint IP
3. **Environment-Specific Hostnames**: 
   - Dev: `mydb.myorg.com`
   - Prod: `mydb-prod.myorg.com`

## ⚙️ Configuration

### 1. Domain and Hostname Settings

Edit your environment-specific `terraform.tfvars` files:

**Development (`environments/dev/terraform.tfvars`):**
```hcl
custom_domain = {
  domain_name = "myorg.com"
  db_hostname = "mydb"
}
```

**Production (`environments/prod/terraform.tfvars`):**
```hcl
custom_domain = {
  domain_name = "myorg.com"
  db_hostname = "mydb-prod"
}
```

### 2. Custom Domain Options

You can customize both the domain and hostname:

```hcl
# Example: company.internal
custom_domain = {
  domain_name = "company.internal"
  db_hostname = "database"
}
# Result: database.company.internal

# Example: corp.local
custom_domain = {
  domain_name = "corp.local"
  db_hostname = "sql"
}
# Result: sql.corp.local

# Example: dev.example.com
custom_domain = {
  domain_name = "dev.example.com"
  db_hostname = "db"
}
# Result: db.dev.example.com
```

## 🚀 Cloud Run Usage Examples

### Basic Configuration
```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: my-application
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
          value: "mydb.myorg.com"
        - name: DB_PORT
          value: "1433"
        - name: DB_NAME
          value: "application_db"
        - name: DB_USER
          value: "sqlserver"
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: password
```

### Connection String Examples
```yaml
# SQL Server Connection String
env:
- name: CONNECTION_STRING
  value: "Server=mydb.myorg.com,1433;Database=myapp_db;User Id=sqlserver;Password=$(DB_PASSWORD);TrustServerCertificate=true;"

# ADO.NET Connection String
env:
- name: DATABASE_URL
  value: "Data Source=mydb.myorg.com;Initial Catalog=myapp_db;User ID=sqlserver;Password=$(DB_PASSWORD)"

# JDBC Connection String (for Java apps)
env:
- name: JDBC_URL
  value: "jdbc:sqlserver://mydb.myorg.com:1433;databaseName=myapp_db;user=sqlserver;password=$(DB_PASSWORD)"
```

### Environment-Specific Configuration
```yaml
# Development deployment
env:
- name: DB_HOST
  value: "mydb.myorg.com"

# Production deployment  
env:
- name: DB_HOST
  value: "mydb-prod.myorg.com"
```

## 🔧 Terraform Outputs

Access the custom domain name in your Terraform configurations:

```hcl
# Reference in other modules
output "app_db_connection" {
  value = "Server=${module.infrastructure.database_dns_custom};Database=myapp_db"
}

# Use in Cloud Run deployment
resource "google_cloud_run_service" "app" {
  # ... other configuration ...
  
  template {
    spec {
      containers {
        env {
          name  = "DB_HOST"
          value = module.infrastructure.database_dns_custom
        }
      }
    }
  }
}
```

## 🧪 Testing and Verification

### DNS Resolution Test
```bash
# Test from a VM in your VPC
nslookup mydb.myorg.com

# Expected output:
# Name:    mydb.myorg.com
# Address: 10.10.3.5  (your PSC endpoint IP)
```

### Connection Test
```bash
# Test database connectivity (from VM in VPC)
telnet mydb.myorg.com 1433

# Test with SQL Server tools
sqlcmd -S mydb.myorg.com -U sqlserver -P yourpassword
```

### Cloud Run Environment Test
```bash
# Check environment variables in your Cloud Run service
gcloud run services describe my-app --region=us-central1 --format="value(spec.template.spec.template.spec.containers[0].env[].name,spec.template.spec.template.spec.containers[0].env[].value)"
```

## 🔍 Troubleshooting

### Common Issues

1. **DNS Not Resolving**:
   ```bash
   # Check if custom DNS zone exists
   gcloud dns managed-zones list --filter="name:*custom-domain*"
   
   # Check if DNS record exists
   gcloud dns record-sets list --zone=vpc-core-dev-custom-domain-zone
   ```

2. **Wrong IP Resolution**:
   ```bash
   # Verify PSC endpoint IP
   terraform output psc_endpoint_ip
   
   # Compare with DNS resolution
   nslookup mydb.myorg.com
   ```

3. **Cloud Run Can't Connect**:
   - Verify VPC connector is properly configured
   - Check that Cloud Run service is in the same VPC
   - Ensure firewall rules allow traffic on port 1433

### Useful Commands
```bash
# List all DNS zones
gcloud dns managed-zones list

# List records in custom domain zone
gcloud dns record-sets list --zone=vpc-core-dev-custom-domain-zone

# Check DNS from specific resolver
dig @8.8.8.8 mydb.myorg.com  # Should not resolve (private only)
dig @10.10.0.1 mydb.myorg.com  # Should resolve (from VPC)
```

## 🛡️ Security Considerations

1. **Private DNS Only**: The custom domain only resolves within your VPC
2. **No External Access**: `mydb.myorg.com` won't resolve from the internet
3. **Environment Isolation**: Each environment has its own DNS zone
4. **PSC Security**: Database remains private with no public IP

## 📋 Best Practices

### Domain Naming
- Use meaningful domain names: `company.internal`, `corp.local`
- Environment-specific hostnames: `db-dev`, `db-prod`
- Service-specific names: `auth-db`, `user-db`, `analytics-db`

### Application Configuration
- Use environment variables for database hostnames
- Implement connection retry logic
- Use connection pooling for better performance
- Monitor DNS resolution metrics

### Operations
- Document custom domain mappings for team members
- Include DNS testing in deployment verification
- Monitor DNS query logs for troubleshooting
- Set up alerts for DNS resolution failures

---

**DNS Zone Created**: `{domain_name}` (private)  
**Custom Record**: `{db_hostname}.{domain_name}`  
**Resolves To**: PSC Endpoint Private IP  
**Visibility**: VPC-internal only
