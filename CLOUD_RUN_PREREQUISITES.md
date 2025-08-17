# Cloud Run Prerequisites for Database Access

## 🎯 Overview

This guide provides all the prerequisites and configuration needed for Cloud Run applications to access your database using the custom domain `mydb.myorg.com`.

## 🏗️ Infrastructure Prerequisites (Automatically Deployed)

The following infrastructure components are automatically created by this Terraform configuration:

### 1. Network Topology
```
VPC: vpc-core-{env}
├── dmz-{env}     (10.{env}.0.0/24) - DMZ/Load Balancer tier
├── web-{env}     (10.{env}.1.0/24) - API services (Cloud Run)
├── app-{env}     (10.{env}.2.0/24) - Batch applications (Cloud Run)
├── db-{env}      (10.{env}.3.0/24) - Database tier (PSC endpoint)
└── shared-{env}  (10.{env}.4.0/24) - Shared services (VPC connector)
```

### 2. VPC Access Connector
- **Purpose**: Allows Cloud Run to access private VPC resources
- **Name**: `vpc-connector-{env}`
- **Subnet**: Uses `shared-{env}` subnet (10.{env}.4.0/24) for connector instances
- **Capacity**: 2-3 instances of e2-micro
- **Access**: Enables connectivity to all VPC subnets including `db-{env}`

### 3. Database PSC Endpoint
- **Location**: `db-{env}` subnet (10.{env}.3.0/24)
- **Purpose**: Private Service Connect endpoint for Cloud SQL
- **IP Range**: Allocated from `db-{env}` subnet
- **Access**: Reachable from `web-{env}` and `app-{env}` subnets via VPC connector

## 🚀 Cloud Run Deployment Configuration

### 1. API Service Deployment (web-{env} subnet conceptually)

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: api-service
  namespace: default
  labels:
    app: api-service
    tier: web
    env: dev
spec:
  template:
    metadata:
      annotations:
        # REQUIRED: VPC Access Connector (deployed in shared-{env} subnet)
        run.googleapis.com/vpc-access-connector: projects/gifted-palace-468618-q5/locations/us-central1/connectors/vpc-connector-dev
        # Route only private traffic through VPC to access db-{env} subnet
        run.googleapis.com/vpc-access-egress: private-ranges-only
    spec:
      containerConcurrency: 80
      timeoutSeconds: 300
      containers:
      - name: api
        image: gcr.io/gifted-palace-468618-q5/api-service:latest
        ports:
        - containerPort: 8080
        env:
        # Database Configuration (connects to db-dev subnet via PSC)
        - name: DB_HOST
          value: "mydb.myorg.com"  # Resolves to PSC endpoint in db-dev subnet
        - name: DB_PORT
          value: "1433"
        - name: DB_NAME
          value: "api_database"
        - name: SERVICE_TYPE
          value: "api"
        - name: SUBNET_CONTEXT
          value: "web-dev"  # Logical tier identification
```

### 2. Batch Application Deployment (app-{env} subnet conceptually)

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: batch-processor
  namespace: default
  labels:
    app: batch-processor
    tier: app
    env: dev
spec:
  template:
    metadata:
      annotations:
        # REQUIRED: Same VPC connector (shared-{env} subnet)
        run.googleapis.com/vpc-access-connector: projects/gifted-palace-468618-q5/locations/us-central1/connectors/vpc-connector-dev
        # Private connectivity to access db-{env} subnet
        run.googleapis.com/vpc-access-egress: private-ranges-only
        # Batch-specific configurations
        autoscaling.knative.dev/maxScale: "5"
        autoscaling.knative.dev/minScale: "0"
    spec:
      containerConcurrency: 1  # Process one job at a time
      timeoutSeconds: 900      # 15 minutes for batch processing
      containers:
      - name: batch
        image: gcr.io/gifted-palace-468618-q5/batch-processor:latest
        env:
        # Database Configuration (same PSC endpoint in db-dev subnet)
        - name: DB_HOST
          value: "mydb.myorg.com"  # Same database, different logical tier
        - name: DB_PORT
          value: "1433"
        - name: DB_NAME
          value: "batch_database"
        - name: SERVICE_TYPE
          value: "batch"
        - name: SUBNET_CONTEXT
          value: "app-dev"  # Logical tier identification
        - name: BATCH_SIZE
          value: "100"
        resources:
          limits:
            cpu: 2000m     # More CPU for batch processing
            memory: 1Gi
          requests:
            cpu: 500m
            memory: 256Mi
```

### 3. Terraform Multi-Service Deployment

```hcl
# API Service (web tier)
resource "google_cloud_run_service" "api_service" {
  name     = "api-service"
  location = var.region
  project  = var.project_id

  metadata {
    labels = {
      tier = "web"
      env  = var.env_name
    }
  }

  template {
    metadata {
      annotations = {
        # VPC connector from shared-{env} subnet to access db-{env} subnet
        "run.googleapis.com/vpc-access-connector" = module.vpc_connector.connector_id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "autoscaling.knative.dev/maxScale"       = "10"
        "autoscaling.knative.dev/minScale"       = "1"
      }
    }

    spec {
      container_concurrency = 80
      timeout_seconds      = 300

      containers {
        image = "gcr.io/${var.project_id}/api-service:latest"

        ports {
          container_port = 8080
        }

        env {
          name  = "DB_HOST"
          value = module.infrastructure.database_dns_custom  # mydb.myorg.com
        }
        env {
          name  = "DB_PORT"
          value = "1433"
        }
        env {
          name  = "SERVICE_TYPE"
          value = "api"
        }
        env {
          name  = "SUBNET_CONTEXT"
          value = "web-${var.env_name}"
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }
    }
  }

  depends_on = [module.vpc_connector]
}

# Batch Service (app tier)
resource "google_cloud_run_service" "batch_service" {
  name     = "batch-processor"
  location = var.region
  project  = var.project_id

  metadata {
    labels = {
      tier = "app"
      env  = var.env_name
    }
  }

  template {
    metadata {
      annotations = {
        # Same VPC connector, different logical service tier
        "run.googleapis.com/vpc-access-connector" = module.vpc_connector.connector_id
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "autoscaling.knative.dev/maxScale"       = "5"
        "autoscaling.knative.dev/minScale"       = "0"  # Scale to zero when no jobs
      }
    }

    spec {
      container_concurrency = 1    # One job per container
      timeout_seconds      = 900   # 15 minutes for batch processing

      containers {
        image = "gcr.io/${var.project_id}/batch-processor:latest"

        env {
          name  = "DB_HOST"
          value = module.infrastructure.database_dns_custom  # Same database
        }
        env {
          name  = "DB_PORT"
          value = "1433"
        }
        env {
          name  = "SERVICE_TYPE"
          value = "batch"
        }
        env {
          name  = "SUBNET_CONTEXT"
          value = "app-${var.env_name}"
        }
        env {
          name  = "BATCH_SIZE"
          value = "100"
        }

        resources {
          limits = {
            cpu    = "2000m"  # More resources for batch processing
            memory = "1Gi"
          }
        }
      }
    }
  }

  depends_on = [module.vpc_connector]
}
```

### 4. gcloud CLI Deployments

```bash
# Deploy API Service (web tier)
gcloud run deploy api-service \
  --image=gcr.io/gifted-palace-468618-q5/api-service:latest \
  --platform=managed \
  --region=us-central1 \
  --vpc-connector=vpc-connector-dev \
  --vpc-egress=private-ranges-only \
  --set-env-vars="DB_HOST=mydb.myorg.com,DB_PORT=1433,SERVICE_TYPE=api,SUBNET_CONTEXT=web-dev" \
  --set-secrets="DB_PASSWORD=db-credentials:latest" \
  --memory=512Mi \
  --cpu=1 \
  --concurrency=80 \
  --timeout=300 \
  --max-instances=10 \
  --min-instances=1 \
  --port=8080 \
  --labels="tier=web,env=dev" \
  --allow-unauthenticated

# Deploy Batch Service (app tier)
gcloud run deploy batch-processor \
  --image=gcr.io/gifted-palace-468618-q5/batch-processor:latest \
  --platform=managed \
  --region=us-central1 \
  --vpc-connector=vpc-connector-dev \
  --vpc-egress=private-ranges-only \
  --set-env-vars="DB_HOST=mydb.myorg.com,DB_PORT=1433,SERVICE_TYPE=batch,SUBNET_CONTEXT=app-dev,BATCH_SIZE=100" \
  --set-secrets="DB_PASSWORD=db-credentials:latest" \
  --memory=1Gi \
  --cpu=2 \
  --concurrency=1 \
  --timeout=900 \
  --max-instances=5 \
  --min-instances=0 \
  --labels="tier=app,env=dev" \
  --no-allow-unauthenticated  # Batch jobs typically don't need public access
```

## � Network Connectivity Flow

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Service   │    │  Batch Service   │    │  VPC Connector  │
│  (web-dev tier) │    │  (app-dev tier)  │    │ (shared-dev)    │
│                 │    │                  │    │   10.10.4.0/24  │
│  Cloud Run      │    │   Cloud Run      │    │                 │
│  Managed        │    │   Managed        │    │  e2-micro       │
└─────────┬───────┘    └─────────┬────────┘    │  instances      │
          │                      │             └─────────┬───────┘
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                          ┌──────▼──────┐
                          │     VPC     │
                          │ vpc-core-dev│
                          │             │
                          └──────┬──────┘
                                 │
                    ┌────────────▼────────────┐
                    │    db-dev subnet        │
                    │    10.10.3.0/24        │
                    │                        │
                    │  ┌─────────────────┐   │
                    │  │ PSC Endpoint    │   │
                    │  │ mydb.myorg.com  │   │
                    │  │ (Private IP)    │   │
                    │  └─────────┬───────┘   │
                    └────────────┼───────────┘
                                 │
                         ┌───────▼────────┐
                         │  Cloud SQL     │
                         │ SQL Server 2019│
                         │  (Private)     │
                         └────────────────┘
```

**Connectivity Explanation:**
1. **API & Batch Services** run on Cloud Run managed infrastructure
2. **VPC Connector** (in `shared-dev` subnet) provides private network bridge
3. **Both services** connect through VPC connector to access VPC resources
4. **PSC Endpoint** (in `db-dev` subnet) provides private database access
5. **DNS Resolution** resolves `mydb.myorg.com` to PSC endpoint IP
6. **No Public IPs** - all communication is private within VPC

## �🔐 Database Credentials Management

### 1. Create Secret Manager Secret

```bash
# Create the secret
gcloud secrets create db-credentials --data-file=-

# Add the password
echo -n "SecureP@ssw0rd123!" | gcloud secrets versions add db-credentials --data-file=-

# Grant Cloud Run access to the secret
gcloud secrets add-iam-policy-binding db-credentials \
  --member="serviceAccount:your-cloud-run-sa@gifted-palace-468618-q5.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

### 2. Terraform Secret Management

```hcl
# Create secret for database password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-credentials"
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = var.cloud_sql.root_password
}

# Grant Cloud Run service account access to secret
resource "google_secret_manager_secret_iam_member" "cloud_run_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
```

## 🔧 Application Code Examples

### 1. Node.js/Express Application

```javascript
const express = require('express');
const sql = require('mssql');

const app = express();

// Database configuration
const dbConfig = {
  server: process.env.DB_HOST || 'mydb.myorg.com',
  port: parseInt(process.env.DB_PORT) || 1433,
  database: process.env.DB_NAME || 'application_db',
  user: process.env.DB_USER || 'sqlserver',
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: true,
    trustServerCertificate: true
  }
};

// Initialize database connection
async function initializeDatabase() {
  try {
    await sql.connect(dbConfig);
    console.log('Connected to database:', process.env.DB_HOST);
  } catch (err) {
    console.error('Database connection failed:', err);
    process.exit(1);
  }
}

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    const result = await sql.query`SELECT 1 as healthy`;
    res.json({ 
      status: 'healthy', 
      database: 'connected',
      host: process.env.DB_HOST 
    });
  } catch (err) {
    res.status(500).json({ 
      status: 'unhealthy', 
      database: 'disconnected',
      error: err.message 
    });
  }
});

// Start server
const PORT = process.env.PORT || 8080;
app.listen(PORT, async () => {
  await initializeDatabase();
  console.log(`Server running on port ${PORT}`);
});
```

### 2. Python/Flask Application

```python
import os
import pyodbc
from flask import Flask, jsonify

app = Flask(__name__)

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'mydb.myorg.com')
DB_PORT = os.getenv('DB_PORT', '1433')
DB_NAME = os.getenv('DB_NAME', 'application_db')
DB_USER = os.getenv('DB_USER', 'sqlserver')
DB_PASSWORD = os.getenv('DB_PASSWORD')

# Connection string
CONNECTION_STRING = (
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={DB_HOST},{DB_PORT};"
    f"DATABASE={DB_NAME};"
    f"UID={DB_USER};"
    f"PWD={DB_PASSWORD};"
    f"TrustServerCertificate=yes;"
)

def get_db_connection():
    try:
        conn = pyodbc.connect(CONNECTION_STRING)
        return conn
    except Exception as e:
        print(f"Database connection failed: {e}")
        return None

@app.route('/health')
def health_check():
    try:
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            conn.close()
            return jsonify({
                'status': 'healthy',
                'database': 'connected',
                'host': DB_HOST
            })
        else:
            return jsonify({
                'status': 'unhealthy',
                'database': 'disconnected'
            }), 500
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8080))
    app.run(host='0.0.0.0', port=port, debug=False)
```

### 3. Java/Spring Boot Application

```java
// application.yml
spring:
  datasource:
    url: jdbc:sqlserver://${DB_HOST:mydb.myorg.com}:${DB_PORT:1433};databaseName=${DB_NAME:application_db};trustServerCertificate=true
    username: ${DB_USER:sqlserver}
    password: ${DB_PASSWORD}
    driver-class-name: com.microsoft.sqlserver.jdbc.SQLServerDriver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

server:
  port: ${PORT:8080}

// HealthController.java
@RestController
public class HealthController {
    
    @Autowired
    private DataSource dataSource;
    
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        
        try (Connection conn = dataSource.getConnection()) {
            PreparedStatement stmt = conn.prepareStatement("SELECT 1");
            stmt.executeQuery();
            
            response.put("status", "healthy");
            response.put("database", "connected");
            response.put("host", System.getenv("DB_HOST"));
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            response.put("status", "unhealthy");
            response.put("database", "disconnected");
            response.put("error", e.getMessage());
            
            return ResponseEntity.status(500).body(response);
        }
    }
}
```

## 🧪 Testing and Verification

### 1. Test VPC Connectivity

```bash
# Deploy a test container to verify connectivity
gcloud run deploy db-test \
  --image=gcr.io/cloud-sql-connectors/cloud-sql-proxy:latest \
  --platform=managed \
  --region=us-central1 \
  --vpc-connector=vpc-connector-dev \
  --vpc-egress=private-ranges-only \
  --set-env-vars="DB_HOST=mydb.myorg.com" \
  --command="sh" \
  --args="-c,nslookup $DB_HOST && telnet $DB_HOST 1433"
```

### 2. DNS Resolution Test

```bash
# Test DNS resolution from Cloud Run
gcloud run deploy dns-test \
  --image=busybox \
  --platform=managed \
  --region=us-central1 \
  --vpc-connector=vpc-connector-dev \
  --command="sh" \
  --args="-c,nslookup mydb.myorg.com"
```

### 3. Database Connection Test

```bash
# Test database connection
gcloud run deploy connection-test \
  --image=mcr.microsoft.com/mssql-tools \
  --platform=managed \
  --region=us-central1 \
  --vpc-connector=vpc-connector-dev \
  --set-env-vars="DB_HOST=mydb.myorg.com,DB_USER=sqlserver" \
  --set-secrets="DB_PASSWORD=db-credentials:latest" \
  --command="sh" \
  --args="-c,sqlcmd -S $DB_HOST -U $DB_USER -P $DB_PASSWORD -Q 'SELECT @@VERSION'"
```

## 🔍 Troubleshooting

### Common Issues and Solutions

1. **VPC Connector Not Found**:
   ```bash
   # Check if VPC connector exists
   gcloud compute networks vpc-access connectors list --region=us-central1
   ```

2. **DNS Resolution Fails**:
   ```bash
   # Verify DNS zone and records
   gcloud dns managed-zones list
   gcloud dns record-sets list --zone=vpc-core-dev-custom-domain-zone
   ```

3. **Database Connection Timeout**:
   - Verify PSC endpoint is running
   - Check Cloud SQL instance is running
   - Ensure VPC connector is in READY state

4. **Permission Denied**:
   - Check Secret Manager permissions
   - Verify Cloud Run service account has database access
   - Ensure VPC Access API is enabled

### Useful Commands

```bash
# Check VPC connector status
gcloud compute networks vpc-access connectors describe vpc-connector-dev --region=us-central1

# Check Cloud Run service configuration
gcloud run services describe my-app --region=us-central1

# Check logs for connectivity issues
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=my-app" --limit=50

# Test from Cloud Shell (simulate Cloud Run environment)
gcloud alpha cloud-shell ssh --command="nslookup mydb.myorg.com"
```

## 📋 Deployment Checklist

Before deploying your Cloud Run application:

- [ ] ✅ VPC connector is created and in READY state
- [ ] ✅ Custom DNS zone exists with database record
- [ ] ✅ Database credentials are stored in Secret Manager
- [ ] ✅ Cloud Run service account has Secret Manager access
- [ ] ✅ VPC Access API is enabled
- [ ] ✅ Application code uses environment variables for configuration
- [ ] ✅ Health check endpoint tests database connectivity
- [ ] ✅ VPC connector annotation is included in Cloud Run config
- [ ] ✅ Database connection string uses `mydb.myorg.com`

---

**VPC Connector**: `vpc-connector-{env}`  
**Database URL**: `mydb.myorg.com:1433`  
**Connection Method**: Private via VPC Access Connector  
**DNS Resolution**: Internal VPC only
