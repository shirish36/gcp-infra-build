# Manual DNS API Enablement Guide

## Issue
The GitHub Actions service account does not have sufficient permissions to enable the Cloud DNS API automatically. This requires `Service Usage Admin` or `Project Editor` role.

## Required Manual Steps

### Option 1: Enable DNS API via Console (Recommended)
1. Navigate to [Google Cloud Console - APIs & Services](https://console.cloud.google.com/apis/dashboard)
2. Select project: `gifted-palace-468618-q5`
3. Click "Enable APIs and Services"
4. Search for "Cloud DNS API"
5. Click "Enable"

### Option 2: Enable via gcloud CLI
```bash
gcloud services enable dns.googleapis.com --project=gifted-palace-468618-q5
```

### Option 3: Grant Additional Permissions to Service Account
Add one of these roles to the GitHub Actions service account:
- `roles/serviceusage.serviceUsageAdmin` (Service Usage Admin)
- `roles/editor` (Editor) - More permissive

```bash
# Grant Service Usage Admin role
gcloud projects add-iam-policy-binding gifted-palace-468618-q5 \
    --member="serviceAccount:githubaction@gifted-palace-468618-q5.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageAdmin"
```

## Verification
After enabling the DNS API, verify it's working:
```bash
gcloud services list --enabled --filter="name:dns.googleapis.com" --project=gifted-palace-468618-q5
```

## Re-run Deployment
Once DNS API is enabled, re-run the GitHub Actions workflow or Terraform deployment.
