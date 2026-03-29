resource "kubernetes_manifest" "solver_reference_grant" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1beta1"
    kind       = "ReferenceGrant"
    metadata = {
      name      = "allow-gw-to-solver-svc"
      namespace = var.project_namespace # Where the Solver Service lives
    }
    spec = {
      from = [{
        group     = "gateway.networking.k8s.io"
        kind      = "Gateway"
        namespace = var.project_namespace # Where your Gateway now lives
      }]
      to = [{
        group = ""        # Core API group
        kind  = "Service" # Allow the Gateway to reach the Solver Service
      }]
    }
  }
}

resource "kubernetes_manifest" "tls_gateway" {
  manifest = {
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"
    metadata = {
      name      = var.gateway_name
      namespace = var.project_namespace
    }

    spec = {
      gatewayClassName = "cilium"

      listeners = concat(
        # HTTPS Listeners
        [for site in var.gateway_sites : {
          name     = "https-${site.name}"
          protocol = "HTTPS"
          port     = var.gateway_listener_https_port
          hostname = site.host
          tls = {
            certificateRefs = [{
              kind      = "Secret"
              name      = site.secret
              namespace = var.project_namespace
            }]
          }
        }],
        # HTTP Listeners
        [for site in var.gateway_sites : {
          name     = "http-${site.name}"
          protocol = "HTTP"
          port     = var.gateway_listener_http_port
          hostname = site.host
          allowedRoutes = {
            namespaces = { from = "All" }
            kinds      = [{ group = "gateway.networking.k8s.io", kind = "HTTPRoute" }]
          }
        }]
      )
    }
  }
}

resource "digitalocean_project_resources" "gateway_attachment" {
  count = var.gateway_loadbalancer_id != null ? 1 : 0

  project = var.project_id

  resources = [
    "do:loadbalancer:${var.gateway_loadbalancer_id}"
  ]
}
