module "postgres_clusters" {
  for_each = var.postgres_clusters

  source = "./pg-clusters"

  app_name                = each.key
  cluster_name            = each.value.cluster_name
  namespace               = each.value.namespace
  instances               = each.value.instances
  storage_size            = each.value.storage_size
  storage_class           = each.value.storage_class
  backup_bucket_name      = each.value.backup_bucket_name
  backup_path_prefix      = each.value.backup_path_prefix
  backup_schedule         = each.value.backup_schedule
  backup_retention_policy = each.value.backup_retention_policy
  pvc_wait_duration       = each.value.pvc_wait_duration

  project_id          = var.project_id
  spaces_access_id    = var.spaces_access_id
  spaces_secret_key   = var.spaces_secret_key
  bucket_endpoint_url = var.bucket_endpoint_url
  spaces_region       = var.spaces_region
}
