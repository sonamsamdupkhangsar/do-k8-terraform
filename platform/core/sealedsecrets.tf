# Pre-define the master key secret
 resource "kubernetes_secret_v1" "sealed_secrets_key" {
   metadata {
     name      = "sealed-secrets-key"
     namespace = kubernetes_namespace_v1.sealed_secrets.metadata[0].name
    
     labels = {
       "sealedsecrets.bitnami.com/sealed-secrets-key" = "active"
     }

   }

  # IMPORTANT: Store these values in a secure vault (e.g., Doppler, 1Password, or ENV)
  # Do NOT hardcode these in your Terraform files.
   binary_data = {
     "tls.crt" = var.sealed_secrets_certificate
     "tls.key" = var.sealed_secrets_private_key
   }

   type = "kubernetes.io/tls"
 }

resource "helm_release" "sealed_secrets" {  
  name       = "sealed-secrets-controller"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = kubernetes_namespace_v1.sealed_secrets.metadata[0].name

 # Wait for the cluster to be fully operational
  depends_on = [digitalocean_kubernetes_cluster.default_cluster]

# Pass the existing TLS secret to the Helm chart
   set = [
     {
      name  = "secretName"
      value = kubernetes_secret_v1.sealed_secrets_key.metadata[0].name
      },
     # DISABLE AUTOMATIC KEY RENEWAL
     {
      name  = "keyrenewperiod"
      value = "0"
     }
   ]
}

# Create a dedicated namespace
resource "kubernetes_namespace_v1" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
}
