
variable digitalocean_token {
  description = "The API token from your Digital Ocean control panel"
  type        = string
}

variable cluster_name {
  description = "The name of the kubernetes cluster to create"
  type        = string
}

variable cluster_version {
  description = "The version of the kubernetes cluster to create"
  type        = string
}

variable region {
  description = "The digital ocean region slug for where to create resources"
  type        = string
  default     = "tor1"
}

variable top_level_domains {
  description = "Top level domains to create records and pods for"
  type    = list(string)
}

variable letsencrypt_email {
  type = string
}

variable min_nodes {
  description = "The minimum number of nodes in the default pool"
  type        = number
  default     = 1
}

variable max_nodes {
  description = "The maximum number of nodes in the default pool"
  type        = number
  default     = 3
}

variable default_node_size {
  description = "The default digital ocean node slug for each node in the default pool"
  type        = string
  default     = "s-1vcpu-2gb-amd"
}

variable "helm_chart_nginx" {
  default = "4.0.13"
}

variable domain_name {
    description = "The domain to create records and pods for"
    type        = string    
}

variable "spaces_access_id" {
    description = "DigitalOcean Spaces access key ID"
    type        = string
  }

  variable "spaces_secret_key" {
    description = "DigitalOcean Spaces secret access key"
    type        = string
  }

  variable "sealed_secrets_private_key" {
  type      = string
  sensitive = true
}

variable "sealed_secrets_certificate" {
  type      = string
  sensitive = true
}

variable "spaces_region" {
  description = "Spaces region (e.g., nyc3, sfo2)"
  type        = string
}

variable "bucket_endpoint_url" {
  description = "Endpoint URL for the Spaces bucket (e.g., https://nyc3.digitaloceanspaces.com)"
  type        = string
  sensitive   = true
}

variable "bucket" {
  description = "space bucket"
  type = string
}

variable "project_namespace" {
  description = "The namespace for the project"
  type        = string
}

variable "cert_manager_namespace" {
  description = "The namespace for cert-manager"
  type        = string
}