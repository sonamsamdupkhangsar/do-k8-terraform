
# 5. Define the PostgreSQL Cluster using Kubernetes Manifest
# This creates a 3-node HA cluster using DigitalOcean Block Storage
resource "kubernetes_manifest" "postgres_cluster" {
  #depends_on = [helm_release.pg_operator, kubernetes_secret_v1.spaces_creds]

  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"
    metadata = {
      name      = "production-db"
      namespace = "default"
    }
    spec = {
      instances = 3
      storage = {
        size         = "2Gi"
        storageClass = "do-block-storage"
      }
      
      monitoring = {
        enablePodMonitor = true # Automatically creates the PodMonitor resource
      }

      # Backup Configuration
      backup = {
        barmanObjectStore = {
          destinationPath = "s3://${digitalocean_spaces_bucket.pg_backups.name}/"
          endpointURL     = var.bucket_endpoint_url # Match your bucket region
          s3Credentials = {
            accessKeyId = {
              name = kubernetes_secret_v1.spaces_creds.metadata[0].name
              key  = var.spaces_access_id
            }
            secretAccessKey = {
              name = kubernetes_secret_v1.spaces_creds.metadata[0].name
              key  = var.spaces_secret_key
            }
          }
          wal = {
            compression = "gzip"
          }
        }
        retentionPolicy = "30d"
      }
    }
  }
}


resource "digitalocean_spaces_bucket" "pg_backups" {
  name   = "my-pg-backups-unique-name"
  region = var.spaces_region # Must be a region that supports Spaces
}

# Secret for PG to access Spaces
resource "kubernetes_secret_v1" "spaces_creds" {
  metadata {
    name      = "spaces-credentials"
    namespace = "default"
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
      name      = "daily-full-backup"
      namespace = "default"
    }
    spec = {
      schedule = "0 0 * * *" # Every night at midnight
      cluster = {
        name = "production-db"
      }
    }
  }
}