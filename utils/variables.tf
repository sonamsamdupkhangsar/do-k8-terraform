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

variable digitalocean_token {
  description = "The API token from your Digital Ocean control panel"
  type        = string
}

variable top_level_domains {
  description = "Top level domains to create records and pods for"
  type    = list(string)
}