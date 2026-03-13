resource "kubernetes_namespace_v1" "project_namespace" {
  metadata {
    name = var.project_namespace
  }
}
