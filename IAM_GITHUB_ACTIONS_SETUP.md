# IAM Configuration for GitHub Actions - MANUAL SETUP REQUIRED

## � Important: Manual Setup Required

The GitHub Actions service account needs specific IAM permissions to deploy infrastructure, but these permissions **CANNOT** be granted via Terraform because of a chicken-and-egg problem: the service account needs IAM admin permissions to grant itself other permissions.

**These permissions must be set up manually by a project owner/admin BEFORE running the CI/CD pipeline.**

## � Service Account Details

The GitHub Actions workflow uses Workload Identity Federation to authenticate to Google Cloud using the service account:
```
githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com
```

## 🛡️ Required IAM Roles - MANUAL SETUP

The following IAM roles must be manually assigned to the GitHub Actions service account by a project owner/admin:

### 1. VPC Access Admin (`roles/vpcaccess.admin`)
- **Purpose**: Create and manage VPC Access Connectors for Cloud Run
- **Permissions**: 
  - `vpcaccess.connectors.create`
  - `vpcaccess.connectors.delete`
  - `vpcaccess.connectors.get`
  - `vpcaccess.connectors.list`
  - `vpcaccess.connectors.update`

### 2. Compute Admin (`roles/compute.admin`)
- **Purpose**: Manage compute resources including VPC networks, subnets, and instances
- **Permissions**:
  - `compute.*` (comprehensive compute permissions)
  - Required for VPC connector instance management

### 3. Service Usage Admin (`roles/serviceusage.serviceUsageAdmin`)
- **Purpose**: Enable and disable Google Cloud APIs
- **Permissions**:
  - `serviceusage.services.enable`
  - `serviceusage.services.disable`
  - `serviceusage.services.get`
  - `serviceusage.services.list`

## 🔧 REQUIRED: Manual Setup Commands

**A project owner/admin must run these commands to grant the necessary permissions:**

```bash
# Set project ID
export PROJECT_ID="gifted-palace-468618-q5"

# Grant VPC Access Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/vpcaccess.admin"

# Grant Compute Admin role  
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# Grant Service Usage Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"

# Verify the roles were assigned
gcloud projects get-iam-policy $PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:githubaction@${PROJECT_ID}.iam.gserviceaccount.com"
```

## ⚠️ Why Manual Setup is Required

Terraform cannot grant these permissions because:
1. The service account needs IAM admin permissions to modify IAM policies
2. But the service account doesn't have IAM admin permissions initially
3. This creates a chicken-and-egg bootstrap problem
4. Manual setup by a project owner/admin breaks this cycle

## 🔄 Post-Setup Verification

After manual setup, the VPC connector will be deployed automatically via Terraform:

```hcl
# VPC Connector module in main.tf
module "vpc_connector" {
  source                = "./modules/vpc_connector"
  project_id            = var.project_id
  env_name              = var.env_name
  region                = var.region
  connector_subnet_name = "shared-${var.env_name}"
  min_instances         = 2
  max_instances         = 3
  machine_type          = "e2-micro"
  
  depends_on = [module.network, module.project_apis]
}
```

## 🚨 Security Notes

- **Principle of Least Privilege**: These roles provide the minimum permissions needed for infrastructure deployment
- **Service Account Scope**: Permissions are scoped to the specific project only
- **Workload Identity**: Uses federated authentication instead of service account keys
- **Audit Trail**: All actions are logged through Google Cloud Audit Logs

## 🔍 Troubleshooting

If you encounter permission errors:

1. **Check IAM Bindings**:
   ```bash
   gcloud projects get-iam-policy gifted-palace-468618-q5 \
     --flatten="bindings[].members" \
     --filter="bindings.members:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com"
   ```

2. **Verify Service Account**:
   ```bash
   gcloud iam service-accounts describe \
     githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com
   ```

3. **Check API Status**:
   ```bash
   gcloud services list --enabled --filter="name:vpcaccess.googleapis.com"
   ```

## 📋 Manual Setup (Required Before CI/CD)

**These commands MUST be run by a project owner/admin before the first deployment:**

```bash
# Grant VPC Access Admin role
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
  --member="serviceAccount:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="roles/vpcaccess.admin"

# Grant Compute Admin role  
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
  --member="serviceAccount:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# Grant Service Usage Admin role
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
  --member="serviceAccount:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"
```

**After running these commands, the CI/CD pipeline will work successfully.**

---

**Last Updated**: August 17, 2025  
**Service Account**: `githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com`  
**Status**: ✅ Automated via Terraform
