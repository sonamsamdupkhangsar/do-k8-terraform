resource "kubernetes_manifest" "tls_gateway" {
  manifest = {
    # Corresponds to apiVersion: gateway.networking.k8s.io/v1 and kind: Gateway
    apiVersion = "gateway.networking.k8s.io/v1"
    kind       = "Gateway"

    # Corresponds to metadata
    metadata = {
      name      = "tls-gateway"
      # If you use a specific namespace for your gateways, specify it here:
      namespace = var.project_namespace
    }

    # Corresponds to spec
    spec = {
      gatewayClassName = "cilium" # Ensure this matches your installed GatewayClass

      listeners = [
        # Listener https-1
        {
          name     = "https-1"
          protocol = "HTTPS"
          port     = 443
          hostname = "bookinfo.springauth.com"
          tls = {
            certificateRefs = [
              {
                kind = "Secret"
                name = "gateway-tls-secret"
                namespace = var.cert_manager_namespace
                # If the secret is in a different namespace than the Gateway,
                # you must also specify 'namespace' here (e.g., namespace = "cert-manager")
              }
            ]
          }
        },

        # Listener https-2
        {
          name     = "https-2"
          protocol = "HTTPS"
          port     = 443
          hostname = "hipstershop.springauth.com"
          tls = {
            certificateRefs = [
              {
                kind = "Secret"
                name = "gateway-tls-secret"
                namespace = var.cert_manager_namespace
              }
            ]
          }
        },

        # Listener http (for ACME challenges)
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          hostname = "bookinfo.springauth.com"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
            # Add this to ensure Cilium allows the HTTPRoute kind specifically
            kinds = [
              {
                group = "gateway.networking.k8s.io"
                kind  = "HTTPRoute"
              }
            ]
          }
        },

        # Listener http-2 (for ACME challenges)
        {
          name     = "http-2"
          protocol = "HTTP"
          port     = 80
          hostname = "hipstershop.springauth.com"
          allowedRoutes = {
            namespaces = {
              from = "All"
            }
            # Add this to ensure Cilium allows the HTTPRoute kind specifically
            kinds = [
              {
                group = "gateway.networking.k8s.io"
                kind  = "HTTPRoute"
              }
            ]
          }
        },
      ]
    }
  }
# depends_on = [ digitalocean_kubernetes_cluster.default_cluster, helm_release.cert-manager ]
}


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
        group = "" # Core API group
        kind  = "Service" # Allow the Gateway to reach the Solver Service
      }]
    }
  }
}