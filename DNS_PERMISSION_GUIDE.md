# DNS Permission Resolution Guide

## 🔴 Current Issue

The infrastructure deployment is failing when attempting to create the DNS managed zone with the following error:

```
Error: Error creating ManagedZone: googleapi: Error 403: Forbidden
```

## 🎯 Root Cause

The GitHub Actions service account lacks the necessary permissions to create DNS managed zones. While the Cloud DNS API has been enabled, the service account needs the **DNS Administrator** role.

## 🛠️ Resolution Steps

### Option 1: Grant DNS Administrator Role (Recommended)

Grant the DNS Administrator role to the GitHub Actions service account:

```bash
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
  --member="serviceAccount:github-actions@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="roles/dns.admin"
```

### Option 2: Custom Role with Minimal Permissions

Create a custom role with only the necessary DNS permissions:

```bash
# Create custom role
gcloud iam roles create customDNSManager \
  --project=gifted-palace-468618-q5 \
  --title="Custom DNS Manager" \
  --description="Minimal permissions for DNS zone management" \
  --permissions="dns.managedZones.create,dns.managedZones.delete,dns.managedZones.get,dns.managedZones.list,dns.changes.create,dns.changes.get,dns.changes.list,dns.resourceRecordSets.create,dns.resourceRecordSets.delete,dns.resourceRecordSets.list,dns.resourceRecordSets.update"

# Assign custom role
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
  --member="serviceAccount:github-actions@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="projects/gifted-palace-468618-q5/roles/customDNSManager"
```

## 🔄 After Permission Grant

Once the permissions are granted:

1. **Uncomment DNS Resources**:
   - In `modules/network/main.tf` - uncomment the `google_dns_managed_zone` resource
   - In `modules/network/outputs.tf` - uncomment the `database_zone_name` output
   - In `main.tf` - uncomment the `google_dns_record_set` resource
   - In `outputs.tf` - uncomment the DNS-related outputs

2. **Re-run Deployment**:
   ```bash
   # Via GitHub Actions
   git commit -am "Enable DNS zone creation after permission grant"
   git push origin feature-exp
   
   # Or manually
   terraform plan -var-file=environments/dev/terraform.tfvars
   terraform apply -var-file=environments/dev/terraform.tfvars
   ```

## 📋 DNS Resources Being Created

### 1. Private DNS Zone
- **Name**: `database.vpc-core-{env}.internal`
- **Purpose**: Internal DNS resolution for database access
- **Visibility**: Private (VPC-scoped)

### 2. DNS Record
- **Name**: `sql-server.database.vpc-core-{env}.internal`
- **Type**: A record
- **Value**: PSC endpoint IP address
- **TTL**: 300 seconds

## 🔍 Verification Steps

After successful deployment with DNS:

1. **Check DNS Zone**:
   ```bash
   gcloud dns managed-zones list --filter="name:database-zone-*"
   ```

2. **Verify DNS Record**:
   ```bash
   gcloud dns record-sets list --zone=database-zone-dev
   ```

3. **Test DNS Resolution** (from a VM in the VPC):
   ```bash
   nslookup sql-server.database.vpc-core-dev.internal
   ```

## 🚨 Current Workaround

Until DNS permissions are resolved, use the PSC endpoint IP directly:

1. **Get PSC IP**:
   ```bash
   terraform output psc_endpoint_ip
   ```

2. **Use in Applications**:
   ```yaml
   env:
   - name: DB_HOST
     value: "10.10.3.5"  # Replace with actual PSC IP
   ```

## 🔗 Related Files

- `modules/network/main.tf` - DNS zone resource (commented)
- `modules/network/outputs.tf` - DNS outputs (commented)  
- `main.tf` - DNS record resource (commented)
- `outputs.tf` - DNS outputs (commented)

## 📞 Support

If you encounter issues after following this guide:

1. Check service account permissions in IAM console
2. Verify Cloud DNS API is enabled
3. Review Terraform state for any conflicting resources
4. Contact the DevOps team via Slack #devops-gcp

---

**Last Updated**: Current session  
**Status**: DNS zone creation disabled pending permissions  
**Next Action**: Grant DNS Administrator role to GitHub Actions service account
