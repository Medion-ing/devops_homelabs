# =============================================================================
# variables.tf — Secrets uniquement
# Toute la configuration métier est dans locals.tf.
# Ces valeurs sont fournies via terraform.tfvars (non commité) ou ansible-vault.
# =============================================================================

variable "rustfs_admin_access_key" {
  type        = string
  description = "Access key du compte admin RustFS"
  sensitive   = true
}

variable "rustfs_admin_secret_key" {
  type        = string
  description = "Secret key du compte admin RustFS"
  sensitive   = true
}

variable "app_rw_user_secret" {
  type        = string
  description = "Secret key de l'utilisateur app-rw-user"
  sensitive   = true
}

variable "app_ro_user_secret" {
  type        = string
  description = "Secret key de l'utilisateur app-ro-user"
  sensitive   = true
}

variable "test_import_user_secret" {
  type        = string
  description = "Secret key de l'utilisateur test-import-user"
  sensitive   = true
}
