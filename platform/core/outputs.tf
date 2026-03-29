output "cluster_id" {
  value = digitalocean_kubernetes_cluster.default_cluster.id
}

output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.default_cluster.endpoint
}

output "cluster_token" {
  value = digitalocean_kubernetes_cluster.default_cluster.kube_config[0].token
}

output "cluster_ca_certificate" {
  value = digitalocean_kubernetes_cluster.default_cluster.kube_config[0].cluster_ca_certificate
}
output "kube_config_filename" {
  value = local_file.kubeconfig.filename
}
output "kube_config_file" {
  value = local_file.kubeconfig
}
output "project_id" {
  value = digitalocean_project.IdentityAccessManagementProject.id
}
