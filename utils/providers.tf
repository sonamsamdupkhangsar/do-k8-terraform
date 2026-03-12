provider "kubernetes" {
  host                   = var.cluster_endpoint
  token                  = var.cluster_token
  cluster_ca_certificate =  base64decode(var.cluster_ca_certificate)
  #config_path = var.kubeconfig_file.filename
}

provider "helm" {
  kubernetes = {
    host                   = var.cluster_endpoint
    token                  = var.cluster_token
    cluster_ca_certificate = base64decode(var.cluster_ca_certificate)
  }
}

terraform {
   required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.4.0"
    }
   }
}

provider "digitalocean" {
  token = var.digitalocean_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}
