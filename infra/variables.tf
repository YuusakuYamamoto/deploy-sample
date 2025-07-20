# Variable definitions for OCI infrastructure

variable "region" {
  description = "OCI region where resources will be created"
  type        = string
  default     = "ap-tokyo-1"
}

variable "user_ocid" {
  description = "OCI User OCID"
  type        = string
  sensitive   = true
}

variable "tenancy_ocid" {
  description = "OCI Tenancy OCID"
  type        = string
  sensitive   = true
}

variable "fingerprint" {
  description = "API Key Fingerprint"
  type        = string
  sensitive   = true
}

variable "private_key" {
  description = "API Private Key Content"
  type        = string
  sensitive   = true
}

variable "compartment_id" {
  description = "OCID of the compartment where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
  default     = "sdb-sample"
}

variable "ocir_repository" {
  description = "OCIR repository URL (e.g., nrt.ocir.io/namespace/repository)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "database_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "sdb_production"
}

variable "database_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "sdbuser"
}

variable "database_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "frontend_shape_ocpus" {
  description = "Number of OCPUs for frontend container instance"
  type        = number
  default     = 2
}

variable "frontend_shape_memory" {
  description = "Memory in GBs for frontend container instance"
  type        = number
  default     = 4
}

variable "backend_shape_ocpus" {
  description = "Number of OCPUs for backend container instance"
  type        = number
  default     = 2
}

variable "backend_shape_memory" {
  description = "Memory in GBs for backend container instance"
  type        = number
  default     = 4
}

variable "load_balancer_min_bandwidth" {
  description = "Minimum bandwidth for load balancer in Mbps"
  type        = number
  default     = 10
}

variable "load_balancer_max_bandwidth" {
  description = "Maximum bandwidth for load balancer in Mbps"
  type        = number
  default     = 100
}

variable "enable_https" {
  description = "Enable HTTPS listener (requires SSL certificate configuration)"
  type        = bool
  default     = false
}

variable "ssl_certificate_id" {
  description = "OCID of SSL certificate for HTTPS (required if enable_https is true)"
  type        = string
  default     = ""
}