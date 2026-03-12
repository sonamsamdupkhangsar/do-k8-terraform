# cert-manager resources

resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.19.1" 
  namespace        = "backend"
  create_namespace = true
  timeout          = 600
  depends_on = [
    digitalocean_kubernetes_cluster.default_cluster
  ]
  # This replaces all the separate 'set' blocks with a single HCL map
  values = [
    yamlencode({
      crds = {
        enabled = true
      }
      config = {
        apiVersion      = "controller.config.cert-manager.io/v1alpha1"
        kind            = "ControllerConfiguration"
        enableGatewayAPI = true
      }
    })
  ]
}
