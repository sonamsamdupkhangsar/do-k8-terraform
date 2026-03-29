variable "app_name" {
  description = "Short application name used for generated resource names."
  type        = string
}

variable "cluster_name" {
  description = "CloudNativePG cluster name."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the application and Postgres cluster."
  type        = string
}

variable "instances" {
  description = "Number of PostgreSQL instances in the cluster."
  type        = number
}

variable "storage_size" {
  description = "PVC size for each PostgreSQL instance."
  type        = string
}

variable "storage_class" {
  description = "Kubernetes storage class for PostgreSQL volumes."
  type        = string
  default     = "do-block-storage"
}

variable "backup_bucket_name" {
  description = "Existing DigitalOcean Spaces bucket name used for backups."
  type        = string
}

variable "backup_path_prefix" {
  description = "Optional path prefix inside the shared backup bucket."
  type        = string
  default     = null
}

variable "backup_schedule" {
  description = "Cron schedule for the ScheduledBackup resource."
  type        = string
  default     = "0 0 * * *"
}

variable "backup_retention_policy" {
  description = "Retention policy for CloudNativePG backups."
  type        = string
  default     = "30d"
}

variable "pvc_wait_duration" {
  description = "How long to wait before resolving PVC-backed volumes."
  type        = string
  default     = "90s"
}

variable "project_id" {
  description = "DigitalOcean project ID for volume attachment."
  type        = string
}

variable "spaces_access_id" {
  description = "DigitalOcean Spaces access key ID."
  type        = string
}

variable "spaces_secret_key" {
  description = "DigitalOcean Spaces secret access key."
  type        = string
}

variable "bucket_endpoint_url" {
  description = "Endpoint URL for the Spaces bucket."
  type        = string
}

variable "spaces_region" {
  description = "Spaces region."
  type        = string
}
