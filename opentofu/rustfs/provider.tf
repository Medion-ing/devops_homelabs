terraform {
  required_version = ">= 1.6.0"

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.35"
    }
  }
}

provider "minio" {
  minio_server   = local.rustfs_host
  minio_user     = var.rustfs_admin_access_key
  minio_password = var.rustfs_admin_secret_key
}