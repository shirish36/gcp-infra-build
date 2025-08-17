env_name = "dev"
project_id = "gifted-palace-468618-q5"
region     = "us-central1"

labels = { env = "dev", owner = "platform" }

network = {
  name         = "vpc-core-dev"
  routing_mode = "GLOBAL"
  subnets = [
    { name = "dmz-dev",    ip_cidr_range = "10.10.0.0/24", region = "us-central1" },
    { name = "web-dev",    ip_cidr_range = "10.10.1.0/24", region = "us-central1" },
    { name = "app-dev",    ip_cidr_range = "10.10.2.0/24", region = "us-central1" },
    { name = "db-dev",     ip_cidr_range = "10.10.3.0/24", region = "us-central1" },
    { name = "shared-dev", ip_cidr_range = "10.10.4.0/24", region = "us-central1" }
  ]
}

psc_db_subnet_name = "db-dev"

vpc_connector = {
  name          = "run-conn-usc1-dev"
  ip_cidr_range = "10.10.8.0/28"
}

cloud_sql = {
  instance_name = "sql-std-dev"
  tier          = "db-custom-2-4096"
}
