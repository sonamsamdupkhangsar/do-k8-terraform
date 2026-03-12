terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.1"
    }
  }
}

module "core" {
  source = "./core"

  cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  region = var.region
  min_nodes = var.min_nodes
  max_nodes = var.max_nodes
  default_node_size = var.default_node_size
  domain_name = var.domain_name
  digitalocean_token = var.digitalocean_token
  letsencrypt_email = var.letsencrypt_email

  sealed_secrets_certificate = var.sealed_secrets_certificate
  sealed_secrets_private_key = var.sealed_secrets_private_key

  bucket_endpoint_url = var.bucket_endpoint_url
  spaces_region = var.spaces_region

  spaces_access_id = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
  bucket = var.bucket
}