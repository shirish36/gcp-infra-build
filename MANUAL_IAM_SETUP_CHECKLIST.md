# 🚨 MANDATORY: Manual IAM Setup Checklist

## ⚠️ BEFORE RUNNING CI/CD PIPELINE

**A project owner/admin MUST complete these steps before the GitHub Actions pipeline can succeed:**

### 📋 Pre-Deployment Checklist

- [ ] **Project Owner/Admin Access**: Confirm you have Owner or Project IAM Admin role
- [ ] **Service Account Exists**: Verify `githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com` exists
- [ ] **Workload Identity Federation**: Confirm WIF is configured for GitHub Actions

### 🔧 Required IAM Commands

**Copy and run these commands (requires project owner/admin privileges):**

```bash
# Set project ID for convenience
export PROJECT_ID="gifted-palace-468618-q5"

# Grant VPC Access Admin role (required for VPC connector creation)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/vpcaccess.admin"

# Grant Compute Admin role (required for network/compute resources)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# Grant Service Usage Admin role (required for API management)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:githubaction@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"
```

### ✅ Verification

**Verify the roles were assigned correctly:**

```bash
gcloud projects get-iam-policy gifted-palace-468618-q5 \
  --flatten="bindings[].members" \
  --filter="bindings.members:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com"
```

**Expected output should include:**
- `roles/vpcaccess.admin`
- `roles/compute.admin` 
- `roles/serviceusage.serviceUsageAdmin`

### 🎯 Post-Setup Actions

- [ ] **Mark as Complete**: Check this box when IAM setup is finished
- [ ] **Trigger Pipeline**: Push to `feature-exp` branch or manually trigger GitHub Actions
- [ ] **Monitor Deployment**: Verify VPC connector creation succeeds
- [ ] **Document Completion**: Update team that manual setup is complete

### 🚨 Critical Notes

1. **One-Time Setup**: This only needs to be done once per project
2. **Admin Required**: Only project owners/admins can grant these permissions
3. **Pipeline Dependency**: CI/CD will fail without these permissions
4. **Security**: These are minimal permissions needed for infrastructure deployment

### 📞 Support

If you encounter issues:
1. Check that you have sufficient privileges in the GCP project
2. Verify the service account exists and WIF is configured
3. Review `IAM_GITHUB_ACTIONS_SETUP.md` for detailed troubleshooting
4. Contact DevOps team if problems persist

---

**Status**: 🔴 INCOMPLETE - Manual setup required before deployment  
**Target**: 🟢 COMPLETE - Pipeline ready for deployment  
**Updated**: August 17, 2025
