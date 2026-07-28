variable "bucket_list" {
  description = "Buckets à gérer sur le endpoint S3-compatible"
  type = map(object({
    name       = string
    quota_gb   = number
    versioning = bool
    anonymous  = bool
    tags       = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for b in values(var.bucket_list) : b.quota_gb > 0
    ])
    error_message = "Chaque bucket doit avoir un quota_gb strictement supérieur à 0."
  }
}

variable "policy_list" {
  description = "Policies IAM à créer"
  type = map(object({
    name        = string
    bucket_keys = list(string)
    actions_rw  = bool
  }))
  default = {}
}

variable "group_list" {
  description = "Groups IAM optionnels"
  type = map(object({
    name        = string
    policy_keys = optional(list(string), [])
  }))
  default = {}
}

variable "user_list" {
  description = "Users IAM à créer"
  type = map(object({
    name       = string
    policy_key = string
  }))
  default = {}
}