# Configure OCI Provider
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
}

# Configure the OCI Provider
provider "oci" {
  region = var.region
}

# Get the current compartment
data "oci_identity_compartment" "compartment" {
  id = var.compartment_id
}

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Create VCN
resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_blocks    = ["10.0.0.0/16"]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "sdbvcn"
}

# Create Internet Gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-igw"
}

# Create Route Table
resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Create Security List
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.project_name}-sl"

  # Allow outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  # Allow inbound HTTP/HTTPS
  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6" # TCP
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "6" # TCP
    tcp_options {
      min = 443
      max = 443
    }
  }

  # Allow inbound for container ports (for Load Balancer health checks)
  ingress_security_rules {
    source   = "10.0.0.0/16"
    protocol = "6" # TCP
    tcp_options {
      min = 3000
      max = 3001
    }
  }
}

# Create Public Subnet
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = "10.0.1.0/24"
  display_name      = "${var.project_name}-public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.route_table.id
  security_list_ids = [oci_core_security_list.security_list.id]
}

# Frontend Container Instance
resource "oci_container_instances_container_instance" "frontend" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-frontend"

  shape = "CI.Standard.E4.Flex"
  shape_config {
    ocpus         = 2
    memory_in_gbs = 4
  }

  containers {
    display_name = "nextjs"
    image_url    = "${var.ocir_repository}/frontend:${var.image_tag}"

    environment_variables = {
      NODE_ENV = "production"
      PORT     = "3000"
    }
  }

  vnics {
    subnet_id              = oci_core_subnet.public_subnet.id
    is_public_ip_assigned  = false
    display_name           = "frontend-vnic"
    skip_source_dest_check = false
  }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# PostgreSQL Container Instance
resource "oci_container_instances_container_instance" "postgresql" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-postgresql"

  shape = "CI.Standard.E4.Flex"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  containers {
    display_name = "postgresql"
    image_url    = "postgres:15"

    environment_variables = {
      POSTGRES_DB       = var.database_name
      POSTGRES_USER     = var.database_user
      POSTGRES_PASSWORD = var.database_password
    }

    volume_mounts {
      mount_path  = "/var/lib/postgresql/data"
      volume_name = "postgres-data"
    }
  }

  volumes {
    name        = "postgres-data"
    volume_type = "EMPTYDIR"
  }

  vnics {
    subnet_id              = oci_core_subnet.public_subnet.id
    is_public_ip_assigned  = false
    display_name           = "postgresql-vnic"
    skip_source_dest_check = false
  }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
}

# Backend Container Instance
resource "oci_container_instances_container_instance" "backend" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-backend"

  shape = "CI.Standard.E4.Flex"
  shape_config {
    ocpus         = 2
    memory_in_gbs = 4
  }

  containers {
    display_name = "nestjs"
    image_url    = "${var.ocir_repository}/backend:${var.image_tag}"

    environment_variables = {
      NODE_ENV     = "production"
      PORT         = "3001"
      DATABASE_URL = "postgresql://${var.database_user}:${var.database_password}@${oci_container_instances_container_instance.postgresql.vnics[0].private_ip}:5432/${var.database_name}"
    }
  }

  vnics {
    subnet_id              = oci_core_subnet.public_subnet.id
    is_public_ip_assigned  = false
    display_name           = "backend-vnic"
    skip_source_dest_check = false
  }

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

  depends_on = [oci_container_instances_container_instance.postgresql]
}

# Load Balancer
resource "oci_load_balancer_load_balancer" "load_balancer" {
  compartment_id = var.compartment_id
  display_name   = "${var.project_name}-lb"
  shape          = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 100
  }

  subnet_ids = [oci_core_subnet.public_subnet.id]
  is_private = false
}

# Backend Set for Frontend
resource "oci_load_balancer_backend_set" "frontend_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "frontend-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 3000
    url_path          = "/"
    return_code       = 200
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

# Backend Set for Backend API
resource "oci_load_balancer_backend_set" "backend_backend_set" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "backend-backend-set"
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 3001
    url_path          = "/health"
    return_code       = 200
    interval_ms       = 10000
    timeout_in_millis = 3000
    retries           = 3
  }
}

# Backend for Frontend Container Instance
resource "oci_load_balancer_backend" "frontend_backend" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.frontend_backend_set.name
  ip_address       = oci_container_instances_container_instance.frontend.vnics[0].private_ip
  port             = 3000
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Backend for Backend Container Instance
resource "oci_load_balancer_backend" "backend_backend" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  backendset_name  = oci_load_balancer_backend_set.backend_backend_set.name
  ip_address       = oci_container_instances_container_instance.backend.vnics[0].private_ip
  port             = 3001
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# Listener for HTTPS
resource "oci_load_balancer_listener" "https_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "https-listener"
  default_backend_set_name = oci_load_balancer_backend_set.frontend_backend_set.name
  port                     = 443
  protocol                 = "HTTP"

  # Note: In production, you would want to configure SSL certificates
}

# Listener for HTTP (redirect to HTTPS in production)
resource "oci_load_balancer_listener" "http_listener" {
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "http-listener"
  default_backend_set_name = oci_load_balancer_backend_set.frontend_backend_set.name
  port                     = 80
  protocol                 = "HTTP"
}

# Path Route Set for API routing
resource "oci_load_balancer_path_route_set" "path_route_set" {
  load_balancer_id = oci_load_balancer_load_balancer.load_balancer.id
  name             = "api-path-routes"

  path_routes {
    path = "/api*"
    path_match_type {
      match_type = "PREFIX_MATCH"
    }
    backend_set_name = oci_load_balancer_backend_set.backend_backend_set.name
  }
}

# Update listeners to use path routing
resource "oci_load_balancer_listener" "https_listener_with_routing" {
  load_balancer_id         = oci_load_balancer_load_balancer.load_balancer.id
  name                     = "https-listener-routing"
  default_backend_set_name = oci_load_balancer_backend_set.frontend_backend_set.name
  port                     = 443
  protocol                 = "HTTP"
  path_route_set_name      = oci_load_balancer_path_route_set.path_route_set.name

  depends_on = [oci_load_balancer_listener.https_listener]
}

# Outputs
output "load_balancer_public_ip" {
  description = "Public IP address of the Load Balancer"
  value       = oci_load_balancer_load_balancer.load_balancer.ip_address_details[0].ip_address
}

output "frontend_container_instance_id" {
  description = "OCID of the Frontend Container Instance"
  value       = oci_container_instances_container_instance.frontend.id
}

output "backend_container_instance_id" {
  description = "OCID of the Backend Container Instance"
  value       = oci_container_instances_container_instance.backend.id
}