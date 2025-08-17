# Subnet Architecture Alignment

## 🎯 Network Topology Overview

This document confirms the proper alignment of database connectivity with your defined subnet architecture.

## 🏗️ Subnet Allocation

```
VPC: vpc-core-dev (Development Environment)
├── dmz-dev      (10.10.0.0/24) - DMZ/Load Balancer tier
├── web-dev      (10.10.1.0/24) - API services
├── app-dev      (10.10.2.0/24) - Batch applications  
├── db-dev       (10.10.3.0/24) - Database tier
└── shared-dev   (10.10.4.0/24) - Shared services
```

## 🔗 Component Placement

### Database Infrastructure
- **Cloud SQL Instance**: Private, no subnet assignment (managed by Google)
- **PSC Endpoint**: Deployed in `db-dev` subnet (10.10.3.0/24)
- **Custom DNS**: `mydb.myorg.com` → PSC endpoint IP in `db-dev`

### Cloud Run Infrastructure
- **VPC Connector**: Deployed in `shared-dev` subnet (10.10.4.0/24)
- **API Services**: Logical `web-dev` tier, connects via VPC connector
- **Batch Services**: Logical `app-dev` tier, connects via VPC connector

### Network Flow
```
API Service (web-dev tier)     ─┐
                               │
Batch Service (app-dev tier)   ─┼─► VPC Connector (shared-dev) ─► PSC Endpoint (db-dev) ─► Cloud SQL
                               │
[Future Services]              ─┘
```

## ✅ Configuration Verification

### 1. PSC Endpoint Subnet Assignment
```hcl
# main.tf - Correctly configured
module "psc_endpoint" {
  source                      = "./modules/psc_endpoint"
  subnetwork_id               = module.network.subnets["db-${var.env_name}"].id  # ✅ db-dev subnet
  psc_service_attachment_link = module.cloud_sql.psc_service_attachment_link
}
```

### 2. VPC Connector Subnet Assignment  
```hcl
# main.tf - Correctly configured
module "vpc_connector" {
  source                = "./modules/vpc_connector"
  connector_subnet_name = "shared-${var.env_name}"  # ✅ shared-dev subnet
  vpc_id                = module.network.vpc_id
}
```

### 3. Cloud Run Service Configuration
```yaml
# Both API and Batch services use the same VPC connector
annotations:
  run.googleapis.com/vpc-access-connector: vpc-connector-dev  # ✅ shared-dev subnet
  run.googleapis.com/vpc-access-egress: private-ranges-only
```

## 🎯 Service Tier Mapping

| Service Type | Logical Tier | Subnet | Cloud Run Config | Database Access |
|--------------|-------------|---------|------------------|-----------------|
| **API Services** | `web-dev` | Conceptual | VPC Connector | `mydb.myorg.com` |
| **Batch Apps** | `app-dev` | Conceptual | VPC Connector | `mydb.myorg.com` |
| **VPC Connector** | `shared-dev` | `10.10.4.0/24` | Infrastructure | Bridge to VPC |
| **PSC Endpoint** | `db-dev` | `10.10.3.0/24` | Infrastructure | Database proxy |

## 📋 Deployment Examples

### API Service (web-dev tier)
```bash
gcloud run deploy api-service \
  --image=gcr.io/gifted-palace-468618-q5/api-service:latest \
  --vpc-connector=vpc-connector-dev \
  --set-env-vars="DB_HOST=mydb.myorg.com,TIER=web-dev" \
  --labels="tier=web,subnet=web-dev"
```

### Batch Service (app-dev tier)
```bash
gcloud run deploy batch-processor \
  --image=gcr.io/gifted-palace-468618-q5/batch-processor:latest \
  --vpc-connector=vpc-connector-dev \
  --set-env-vars="DB_HOST=mydb.myorg.com,TIER=app-dev" \
  --labels="tier=app,subnet=app-dev"
```

## 🔍 Verification Commands

### Check PSC Endpoint in db-dev subnet
```bash
# Verify PSC endpoint location
gcloud compute forwarding-rules list --filter="name:psc-endpoint-dev" --format="table(name,region,subnetwork)"

# Should show: subnetwork = .../subnets/db-dev
```

### Check VPC Connector in shared-dev subnet
```bash
# Verify VPC connector location
gcloud compute networks vpc-access connectors describe vpc-connector-dev \
  --region=us-central1 \
  --format="value(subnet.name)"

# Should show: shared-dev
```

### Test Database Connectivity
```bash
# Test from Cloud Run (simulated)
gcloud run deploy connectivity-test \
  --image=busybox \
  --vpc-connector=vpc-connector-dev \
  --command="nslookup mydb.myorg.com"

# Should resolve to PSC endpoint IP in db-dev subnet
```

## 🛡️ Security & Isolation

### Subnet Isolation
- **DMZ subnet**: Isolated for load balancers/public-facing resources
- **Web/App subnets**: Conceptual tiers, services connect via shared VPC connector
- **DB subnet**: Contains PSC endpoint only, no direct external access
- **Shared subnet**: VPC connector instances only

### Network Security
- **Private Connectivity**: Cloud Run → VPC Connector → PSC Endpoint → Cloud SQL
- **No Public IPs**: Database and PSC endpoint are fully private
- **DNS Security**: Custom domain resolves only within VPC
- **Subnet Segmentation**: Clear separation of infrastructure components

## 📊 Summary

✅ **Database (PSC Endpoint)**: Correctly placed in `db-dev` subnet  
✅ **VPC Connector**: Correctly placed in `shared-dev` subnet  
✅ **API Services**: Use VPC connector, logical `web-dev` tier  
✅ **Batch Services**: Use VPC connector, logical `app-dev` tier  
✅ **Custom DNS**: `mydb.myorg.com` resolves to `db-dev` subnet  
✅ **Network Flow**: Private connectivity through proper subnet hierarchy  

The infrastructure is properly aligned with your subnet architecture and ready for production workloads! 🚀

---

**VPC**: `vpc-core-dev`  
**Database Access**: `mydb.myorg.com` (PSC in `db-dev`)  
**Cloud Run Connectivity**: VPC Connector in `shared-dev`  
**Service Tiers**: API (`web-dev`) + Batch (`app-dev`)
