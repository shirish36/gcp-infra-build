env_name   = "prod"
project_id = "gifted-palace-468618-q5"
region     = "us-central1"

labels = { env = "prod", owner = "platform" }

network = {
  name         = "vpc-core-prod"
  routing_mode = "GLOBAL"
  subnets = [
    { name = "dmz-prod", ip_cidr_range = "10.20.0.0/24", region = "us-central1" },
    { name = "web-prod", ip_cidr_range = "10.20.1.0/24", region = "us-central1" },
    { name = "app-prod", ip_cidr_range = "10.20.2.0/24", region = "us-central1" },
    { name = "db-prod", ip_cidr_range = "10.20.3.0/24", region = "us-central1" },
    { name = "shared-prod", ip_cidr_range = "10.20.4.0/24", region = "us-central1" }
  ]
}

cloud_sql = {
  instance_name = "sql-std-prod"
  tier          = "db-custom-4-7680"
}
