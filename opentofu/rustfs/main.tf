module "rustfs" {
  source = "../rustfs_module"

  bucket_list = local.bucket_list
  policy_list = local.policy_list
  group_list  = local.group_list
  user_list   = local.user_list
}