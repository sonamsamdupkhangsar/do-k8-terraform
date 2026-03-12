terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.4.0"
    }
  }
}


provider "digitalocean" {
  token = var.digitalocean_token
}

provider "kubernetes" {
  host    = digitalocean_kubernetes_cluster.default_cluster.endpoint
  token   = digitalocean_kubernetes_cluster.default_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.default_cluster.kube_config[0].cluster_ca_certificate
  )
  #config_path = local_file.kubeconfig.filename
}

provider "helm" {
  kubernetes = {
    host  = digitalocean_kubernetes_cluster.default_cluster.endpoint
    token = digitalocean_kubernetes_cluster.default_cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.default_cluster.kube_config[0].cluster_ca_certificate
    )
    #config_path = local_file.kubeconfig.filename
  }
}


resource "digitalocean_kubernetes_cluster" "default_cluster" {
  name   = var.cluster_name
  region = var.region
  version = var.cluster_version
  node_pool {
    name       = "${var.cluster_name}-default-pool"
    size       = var.default_node_size
    auto_scale = true
    min_nodes  = var.min_nodes
    max_nodes  = var.max_nodes
  }
}

# Data source to retrieve cluster details and generate local kubeconfig file
data "digitalocean_kubernetes_cluster" "primary" {
  name = digitalocean_kubernetes_cluster.default_cluster.name
}

resource "local_file" "kubeconfig" {
  content  = data.digitalocean_kubernetes_cluster.primary.kube_config.0.raw_config
  filename = "kubeconfig_${digitalocean_kubernetes_cluster.default_cluster.name}.yaml" #"~/.kube/config-vault-cluster" # Use a dedicated config file
}
