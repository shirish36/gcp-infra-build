# VPC Connector Subnet Requirements - GCP Best Practices

## 🎯 **GCP VPC Connector Subnet Requirements**

### **Official Google Cloud Requirements:**

1. **Dedicated Subnet**: VPC connector must have its own dedicated subnet
2. **Netmask Requirement**: Subnet must have a netmask of `/28` or smaller (e.g., `/29`, `/30`)
3. **Exclusive Use**: No other resources can be deployed in the VPC connector subnet
4. **IP Range**: Must use RFC 1918 private IP address ranges
5. **Regional**: Subnet must be in the same region as the VPC connector

### **Why `/28` Netmask is Required:**

- **Google Cloud Specification**: Hard requirement by Google Cloud VPC Access service
- **Instance Management**: VPC connector deploys 2-10 VM instances in the subnet
- **Network Overhead**: Requires space for network, broadcast, and gateway addresses
- **Scaling**: Allows connector to scale instances within the allocated range

### **IP Address Allocation:**

A `/28` subnet provides:
- **16 total IP addresses** (10.x.x.0 to 10.x.x.15)
- **13 usable IP addresses** (excluding network, broadcast, gateway)
- **Sufficient for maximum 10 connector instances + overhead**

## 🏗️ **Updated Network Architecture**

### **Before (Incorrect):**
```
VPC: vpc-core-dev
├── dmz-dev      (10.10.0.0/24) - DMZ subnet
├── web-dev      (10.10.1.0/24) - API services
├── app-dev      (10.10.2.0/24) - Batch applications
├── db-dev       (10.10.3.0/24) - Database tier
└── shared-dev   (10.10.4.0/24) - VPC connector ❌ /24 not allowed
```

### **After (GCP Compliant):**
```
VPC: vpc-core-dev
├── dmz-dev            (10.10.0.0/24) - DMZ subnet
├── web-dev            (10.10.1.0/24) - API services
├── app-dev            (10.10.2.0/24) - Batch applications
├── db-dev             (10.10.3.0/24) - Database tier
├── vpc-connector-dev  (10.10.4.0/28) - VPC connector ✅ /28 dedicated
└── shared-dev         (10.10.5.0/24) - Shared services
```

## 📋 **Configuration Changes Made**

### **1. Environment Configurations Updated:**

**Development (`environments/dev/terraform.tfvars`):**
```hcl
network = {
  name = "vpc-core-dev"
  routing_mode = "GLOBAL"
  subnets = [
    { name = "dmz-dev", ip_cidr_range = "10.10.0.0/24", region = "us-central1" },
    { name = "web-dev", ip_cidr_range = "10.10.1.0/24", region = "us-central1" },
    { name = "app-dev", ip_cidr_range = "10.10.2.0/24", region = "us-central1" },
    { name = "db-dev", ip_cidr_range = "10.10.3.0/24", region = "us-central1" },
    { name = "vpc-connector-dev", ip_cidr_range = "10.10.4.0/28", region = "us-central1" },
    { name = "shared-dev", ip_cidr_range = "10.10.5.0/24", region = "us-central1" }
  ]
}
```

**Production (`environments/prod/terraform.tfvars`):**
```hcl
network = {
  name = "vpc-core-prod"
  routing_mode = "GLOBAL"
  subnets = [
    { name = "dmz-prod", ip_cidr_range = "10.20.0.0/24", region = "us-central1" },
    { name = "web-prod", ip_cidr_range = "10.20.1.0/24", region = "us-central1" },
    { name = "app-prod", ip_cidr_range = "10.20.2.0/24", region = "us-central1" },
    { name = "db-prod", ip_cidr_range = "10.20.3.0/24", region = "us-central1" },
    { name = "vpc-connector-prod", ip_cidr_range = "10.20.4.0/28", region = "us-central1" },
    { name = "shared-prod", ip_cidr_range = "10.20.5.0/24", region = "us-central1" }
  ]
}
```

### **2. VPC Connector Module Updated (`main.tf`):**
```hcl
module "vpc_connector" {
  source                = "./modules/vpc_connector"
  project_id            = var.project_id
  env_name              = var.env_name
  region                = var.region
  connector_subnet_name = "vpc-connector-${var.env_name}"  # Changed from shared-{env}
  min_instances         = 2
  max_instances         = 3
  machine_type          = "e2-micro"
  
  depends_on = [module.network, module.project_apis]
}
```

## 🔍 **Verification Commands**

### **Check Subnet CIDR:**
```bash
# Verify VPC connector subnet has /28 netmask
gcloud compute networks subnets describe vpc-connector-dev \
  --region=us-central1 \
  --format="value(ipCidrRange)"
# Expected: 10.10.4.0/28
```

### **Verify VPC Connector Creation:**
```bash
# Check VPC connector status
gcloud compute networks vpc-access connectors describe vpc-connector-dev \
  --region=us-central1 \
  --format="table(name,subnet.name,subnet.projectId,minInstances,maxInstances)"
```

### **Validate Network Architecture:**
```bash
# List all subnets in VPC
gcloud compute networks subnets list \
  --filter="network:vpc-core-dev" \
  --format="table(name,ipCidrRange,region)"
```

## 🚨 **Important Notes**

### **Subnet Dedication:**
- VPC connector subnet (`vpc-connector-{env}`) is exclusively for VPC connector
- No other resources (VMs, load balancers, etc.) can be deployed in this subnet
- Google Cloud enforces this restriction

### **IP Planning:**
- `/28` provides exactly 16 IP addresses
- 3 addresses reserved (network, gateway, broadcast)
- 13 usable addresses for up to 10 connector instances
- No additional capacity for other resources

### **Cost Implications:**
- VPC connector instances are billable compute resources
- `/28` subnet minimizes IP waste while meeting requirements
- Shared subnet moved to `/24` for other shared resources

## 🛡️ **Security & Best Practices**

### **Network Segmentation:**
- VPC connector isolated in dedicated subnet
- Clear separation from application and database subnets
- Proper subnet sizing for security and compliance

### **Firewall Considerations:**
- VPC connector subnet requires specific firewall rules
- Google Cloud auto-creates necessary connector rules
- Custom rules should target connector subnet specifically

### **Monitoring:**
- Monitor VPC connector subnet utilization
- Track connector instance scaling
- Alert on subnet capacity issues

## 📚 **References**

- [Google Cloud VPC Connector Documentation](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access)
- [Subnet Requirements for VPC Connectors](https://cloud.google.com/vpc/docs/configure-serverless-vpc-access#connector_subnet_requirements)
- [VPC Connector Best Practices](https://cloud.google.com/run/docs/configuring/vpc-connectors)

---

**Status**: ✅ Configuration Updated to GCP Requirements  
**VPC Connector Subnet**: `10.{env}.4.0/28` (16 IPs, dedicated)  
**Shared Subnet**: `10.{env}.5.0/24` (256 IPs, for other resources)  
**Compliance**: Fully aligned with Google Cloud specifications
