# Define the Kubernetes secret resource
resource "kubernetes_secret_v1" "digitalocean_dns" {
  metadata {
    # The name of the secret must match the kubectl command's name
    name = "digitalocean-dns"
    # You may also specify a namespace if needed, e.g.:
    namespace = kubernetes_namespace_v1.project_namespace.metadata[0].name
  }

  # Data map stores the literal values. 
  # Terraform automatically Base64 encodes these for the API call.
  data = {
    # Key name must match the --from-literal key 'access-token'
    "access-token" = var.digitalocean_token
  }

  # Optional: Define the type of secret if necessary, e.g., Opaque (default)
  # type = "Opaque"
  depends_on = [ kubernetes_namespace_v1.project_namespace ]
}

