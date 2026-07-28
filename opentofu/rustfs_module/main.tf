locals {
  read_actions  = ["s3:GetObject"]
  write_actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

  anonymous_policies = {
    for key, bucket in var.bucket_list : key => jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid       = "AllowAnonymousRead"
          Effect    = "Allow"
          Principal = "*"
          Action    = ["s3:GetObject"]
          Resource  = ["arn:aws:s3:::${bucket.name}/*"]
        }
      ]
    }) if bucket.anonymous
  }

  policies_expanded = {
    for key, policy in var.policy_list : key => {
      name   = policy.name
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = flatten([
          for bucket_key in policy.bucket_keys : [
            {
              Sid      = "ListBucket${bucket_key}"
              Effect   = "Allow"
              Action   = ["s3:ListBucket"]
              Resource = ["arn:aws:s3:::${var.bucket_list[bucket_key].name}"]
            },
            {
              Sid      = "Objects${bucket_key}"
              Effect   = "Allow"
              Action   = policy.actions_rw ? local.write_actions : local.read_actions
              Resource = ["arn:aws:s3:::${var.bucket_list[bucket_key].name}/*"]
            }
          ]
        ])
      })
    }
  }

  user_direct_policy_map = {
    for key, user in var.user_list : key => user
    if try(user.policy_key, null) != null
  }

  user_group_pairs = merge([
    for user_key, user in var.user_list : {
      for group_key in try(user.group_keys, []) :
      "${user_key}__${group_key}" => {
        user_key  = user_key
        group_key = group_key
      }
    }
  ]...)

  group_policy_pairs = merge([
    for group_key, group in var.group_list : {
      for policy_key in try(group.policy_keys, []) :
      "${group_key}__${policy_key}" => {
        group_key  = group_key
        policy_key = policy_key
      }
    }
  ]...)
}

resource "minio_s3_bucket" "buckets" {
  for_each = var.bucket_list

  bucket         = each.value.name
  acl            = each.value.anonymous ? "public" : "private"
  object_locking = false
}

resource "minio_s3_bucket_quota" "buckets" {
  for_each = var.bucket_list

  bucket = minio_s3_bucket.buckets[each.key].bucket
  quota  = each.value.quota_gb * 1024 * 1024 * 1024
}

resource "minio_s3_bucket_versioning" "buckets" {
  for_each = {
    for key, bucket in var.bucket_list : key => bucket if bucket.versioning
  }

  bucket = minio_s3_bucket.buckets[each.key].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "minio_s3_bucket_tags" "buckets" {
  for_each = {
    for key, bucket in var.bucket_list : key => bucket if length(try(bucket.tags, {})) > 0
  }

  bucket = minio_s3_bucket.buckets[each.key].bucket
  tags   = each.value.tags
}

resource "minio_s3_bucket_policy" "anonymous_read" {
  for_each = local.anonymous_policies

  bucket = minio_s3_bucket.buckets[each.key].bucket
  policy = each.value
}

resource "minio_iam_policy" "policies" {
  for_each = local.policies_expanded

  name   = each.value.name
  policy = each.value.policy
}

resource "minio_iam_user" "users" {
  for_each = var.user_list

  name = each.value.name
}

resource "minio_iam_user_policy_attachment" "users" {
  for_each = local.user_direct_policy_map

  user_name   = minio_iam_user.users[each.key].name
  policy_name = minio_iam_policy.policies[each.value.policy_key].name
}

resource "minio_iam_group" "groups" {
  for_each = var.group_list

  name = each.value.name
}

resource "minio_iam_group_user_attachment" "memberships" {
  for_each = local.user_group_pairs

  group_name = minio_iam_group.groups[each.value.group_key].name
  user_name  = minio_iam_user.users[each.value.user_key].name
}

resource "minio_iam_group_policy_attachment" "groups" {
  for_each = local.group_policy_pairs

  group_name  = minio_iam_group.groups[each.value.group_key].name
  policy_name = minio_iam_policy.policies[each.value.policy_key].name
}