resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "../helm_charts/cluster-issuer"
  namespace = var.cert_manager_namespace
  depends_on = [
    helm_release.cert-manager,
  ]
  set = [
    {
      name  = "letsencrypt_email"
      value = var.letsencrypt_email
    },
    {
      name  = "digitalocean_api_token"
      value = var.digitalocean_token
    },
    {
      name  = "project_namespace"
      value = var.project_namespace
    },
    {
      name  = "cert_manager_namespace"
      value = var.cert_manager_namespace
    },
    {
      name  = "gateway_name"
      value = var.gateway_name
    }
  ]
}
