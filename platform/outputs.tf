output "cluster_endpoint" {
  value = module.core.cluster_endpoint
}

output "cluster_token" {
  value = module.core.cluster_token
  sensitive = true
}

output "cluster_ca_certificate" {
  value = module.core.cluster_ca_certificate
  sensitive = true
}

output "kube_config_filename" {
  value = module.core.kube_config_filename
}

output "kube_config_file" {
  value = module.core.kube_config_file
  sensitive = true
}
