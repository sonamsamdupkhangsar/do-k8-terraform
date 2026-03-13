resource "kubernetes_manifest" "letsencrypt_certificate" {
  manifest = {
    # Corresponds to apiVersion: cert-manager.io/v1 and kind: Certificate
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    # Corresponds to metadata
    metadata = {
      name = "letsencrypt-certificate"
      # IMPORTANT: This must be in the SAME namespace as your Issuer (e.g., "default" or "cert-manager")
      namespace = var.project_namespace
    }

    # Corresponds to spec
    spec = {
      # The name of the Secret that will be created and hold the TLS certificate data
      secretName = "gateway-tls-secret"
      
      #commonName = "*.springauth.com" # Optional, but can be set to the base domain
      # The hostnames the certificate will be valid for
      dnsNames = var.top_level_domains

      # Reference to the Issuer defined previously
      
      issuerRef = {
        name = "letsencrypt-gateway"
        kind = "ClusterIssuer"
      }  
    }
  }

}
