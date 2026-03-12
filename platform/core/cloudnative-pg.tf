# 4. Install CloudNativePG Operator via Helm
resource "helm_release" "pg_operator" {
  name             = "cnpg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  namespace        = "cnpg-system"
  create_namespace = true
  depends_on = [ digitalocean_kubernetes_cluster.default_cluster ]
}

