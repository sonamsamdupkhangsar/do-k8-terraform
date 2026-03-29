terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}

locals {
  secret_name           = "${var.app_name}-spaces-credentials"
  scheduled_backup_name = "${var.app_name}-daily-full-backup"
  backup_path_prefix    = coalesce(var.backup_path_prefix, var.app_name)
  bound_pv_names = {
    for key, pvc in data.kubernetes_persistent_volume_claim_v1.postgres_data :
    key => try(pvc.spec[0].volume_name, "")
    if try(pvc.spec[0].volume_name, "") != ""
  }
}

resource "kubernetes_manifest" "postgres_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = var.cluster_name
      namespace = var.namespace
    }
    spec = {
      instances = var.instances
      storage = {
        size         = var.storage_size
        storageClass = var.storage_class
      }

      monitoring = {
        enablePodMonitor = true
      }

      backup = {
        barmanObjectStore = {
          destinationPath = "s3://${var.backup_bucket_name}/${local.backup_path_prefix}/"
          endpointURL     = var.bucket_endpoint_url
          s3Credentials = {
            accessKeyId = {
              name = kubernetes_secret_v1.spaces_creds.metadata[0].name
              key  = "ACCESS_KEY_ID"
            }
            secretAccessKey = {
              name = kubernetes_secret_v1.spaces_creds.metadata[0].name
              key  = "ACCESS_SECRET_KEY"
            }
          }
          wal = {
            compression = "gzip"
          }
        }
        retentionPolicy = var.backup_retention_policy
      }
    }
  }
}

resource "kubernetes_secret_v1" "spaces_creds" {
  metadata {
    name      = local.secret_name
    namespace = var.namespace
  }

  data = {
    ACCESS_KEY_ID     = var.spaces_access_id
    ACCESS_SECRET_KEY = var.spaces_secret_key
  }
}

resource "kubernetes_manifest" "daily_backup" {
  depends_on = [kubernetes_manifest.postgres_cluster]

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "ScheduledBackup"
    metadata = {
      name      = local.scheduled_backup_name
      namespace = var.namespace
    }
    spec = {
      schedule = var.backup_schedule
      cluster = {
        name = var.cluster_name
      }
    }
  }
}

resource "time_sleep" "wait_for_postgres_pvcs" {
  depends_on      = [kubernetes_manifest.postgres_cluster]
  create_duration = var.pvc_wait_duration
}

data "kubernetes_persistent_volume_claim_v1" "postgres_data" {
  for_each = {
    for index in range(var.instances) :
    tostring(index + 1) => format("%s-%d", var.cluster_name, index + 1)
  }

  metadata {
    name      = each.value
    namespace = var.namespace
  }

  depends_on = [time_sleep.wait_for_postgres_pvcs]
}

data "kubernetes_persistent_volume_v1" "postgres_data" {
  for_each = local.bound_pv_names

  metadata {
    name = each.value
  }
}

resource "digitalocean_project_resources" "postgres_volume_attachment" {
  count = length(local.bound_pv_names) > 0 ? 1 : 0

  project = var.project_id

  resources = tolist(toset([
    for pv in data.kubernetes_persistent_volume_v1.postgres_data :
    format("do:volume:%s", pv.spec[0].persistent_volume_source[0].csi[0].volume_handle)
  ]))
}
