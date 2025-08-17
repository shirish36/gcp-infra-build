# IAM Configuration for GitHub Actions

## 🔐 Service Account Setup

The GitHub Actions workflow uses Workload Identity Federation to authenticate to Google Cloud using the service account:
```
githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com
```

## 🛡️ Required IAM Roles

The following IAM roles are automatically assigned to the GitHub Actions service account by Terraform:

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

## 🏗️ Implementation

The IAM configuration is implemented in `main.tf`:

```hcl
# IAM configuration for GitHub Actions service account
resource "google_project_iam_member" "github_actions_vpc_access_admin" {
  project = var.project_id
  role    = "roles/vpcaccess.admin"
  member  = "serviceAccount:githubaction@${var.project_id}.iam.gserviceaccount.com"
  depends_on = [module.project_apis]
}

resource "google_project_iam_member" "github_actions_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:githubaction@${var.project_id}.iam.gserviceaccount.com"
  depends_on = [module.project_apis]
}

resource "google_project_iam_member" "github_actions_service_usage_admin" {
  project = var.project_id
  role    = "roles/serviceusage.serviceUsageAdmin"
  member  = "serviceAccount:githubaction@${var.project_id}.iam.gserviceaccount.com"
  depends_on = [module.project_apis]
}
```

## 🔄 Dependency Management

The VPC connector module explicitly depends on these IAM configurations:

```hcl
depends_on = [
  module.network, 
  module.project_apis, 
  google_project_iam_member.github_actions_vpc_access_admin,
  google_project_iam_member.github_actions_compute_admin
]
```

This ensures that:
1. APIs are enabled first
2. IAM permissions are granted 
3. VPC connector is created with proper permissions

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

## 📋 Manual Setup (If Needed)

If the IAM configuration needs to be set up manually:

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

---

**Last Updated**: August 17, 2025  
**Service Account**: `githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com`  
**Status**: ✅ Automated via Terraform
