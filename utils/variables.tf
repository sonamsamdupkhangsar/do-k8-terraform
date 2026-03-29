variable "cluster_endpoint" {
  description = "Kubernetes cluster endpoint from core module"
  type        = string
}

variable "cluster_token" {
  description = "Kubernetes cluster token from core module"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate from core module"
  type        = string
}

variable "kube_config_filename" {
  description = "The filename of the generated kubeconfig file"
  type        = string
}

# or, if you want the whole local_file object:
variable "kube_config_file" {
  description = "The local_file resource object"
  type        = any
}

variable "spaces_access_id" {
  description = "DigitalOcean Spaces access key ID"
  type        = string
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces secret access key"
  type        = string
}

variable "bucket_endpoint_url" {
  description = "Endpoint URL for the Spaces bucket (e.g., https://nyc3.digitaloceanspaces.com)"
  type        = string
  sensitive   = true
}

variable "spaces_region" {
  description = "Spaces region (e.g., nyc3, sfo2)"
  type        = string
}

variable "digitalocean_token" {
  description = "The API token from your Digital Ocean control panel"
  type        = string
}

variable "top_level_domains" {
  description = "Top level domains to create records and pods for"
  type        = list(string)
  default     = ["hipstershop.springauth.com", "bookinfo.springauth.com"]
}

variable "project_namespace" {
  description = "The namespace for the project"
  type        = string
}

variable "cert_manager_namespace" {
  description = "The namespace for cert-manager"
  type        = string
}

variable "gateway_name" {
  description = "The name of the Kubernetes Gateway resource"
  type        = string
  default     = "shared-tls-gateway"
}

variable "gateway_sites" {
  description = "List of sites to configure on the gateway"
  type = list(object({
    name   = string
    host   = string
    secret = string
  }))
  default = [
    {
      name   = "bookinfo"
      host   = "bookinfo.springauth.com"
      secret = "gateway-tls-secret"
    },
    {
      name   = "hipstershop"
      host   = "hipstershop.springauth.com"
      secret = "gateway-tls-secret"
    }
  ]
}
variable "gateway_listener_https_port" {
  type    = number
  default = 443
}

variable "gateway_listener_http_port" {
  type    = number
  default = 80
}

variable "gateway_loadbalancer_id" {
  description = "Existing DigitalOcean load balancer ID for the gateway. Set this after the gateway has been provisioned if you want Terraform to attach it to the project."
  type        = string
  default     = null
}

variable "project_id" {
  type        = string
  description = "The ID of the DigitalOcean project from utils.auto.tfvars"
}

variable "postgres_clusters" {
  description = "Map of application PostgreSQL clusters to create."
  type = map(object({
    cluster_name            = string
    namespace               = string
    instances               = number
    storage_size            = string
    backup_bucket_name      = string
    backup_path_prefix      = optional(string)
    storage_class           = optional(string, "do-block-storage")
    backup_schedule         = optional(string, "0 0 * * *")
    backup_retention_policy = optional(string, "30d")
    pvc_wait_duration       = optional(string, "90s")
  }))
  default = {
    main = {
      cluster_name       = "production-db"
      namespace          = "main"
      instances          = 1
      storage_size       = "1Gi"
      backup_bucket_name = "my-shared-pg-backups"
      backup_path_prefix = "main"
    }
  }
}
