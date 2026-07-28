import {
  to = module.rustfs.minio_s3_bucket.buckets["test_data"]
  id = "test-imports"
}

import {
  to = module.rustfs.minio_s3_bucket_quota.buckets["test_data"]
  id = "test-imports"
}

import {
  to = module.rustfs.minio_s3_bucket_tags.buckets["test_data"]
  id = "test-imports"
}

import {
  to = module.rustfs.minio_iam_policy.policies["test_import"]
  id = "test-import-policy"
}

import {
  to = module.rustfs.minio_iam_user.users["test_import_user"]
  id = "test-import-user"
}

import {
  to = module.rustfs.minio_iam_user_policy_attachment.users["test_import_user"]
  id = "test-import-user/test-import-policy"
}