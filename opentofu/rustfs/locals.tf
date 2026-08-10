locals {
  rustfs_host = "192.168.1.124:9000"

  bucket_list = {
    app_data = {
      name       = "rustfs-app-data"
      versioning = true
      quota_gb   = 50
      anonymous  = false
      tags = {
        app_data = "writing"
      }
    }

   k8s_int_legacy_poc = {
      name       = "k8s-int-legacy-poc"
      versioning = true
      quota_gb   = 5
      anonymous  = false
      tags = {
        app_data = "mount-s3-k8s"
      }
    }

    docs_data = {
      name       = "rustfs-docs-data"
      versioning = true
      quota_gb   = 20
      anonymous  = false
      tags = {
        docs_data = "reading"
      }
    }

    test_data = {
      name       = "test-imports"
      versioning = true
      quota_gb   = 5
      anonymous  = false
      tags = {
        test_data = "importing"
      }
    }

    public_assets = {
      name       = "rustfs-public-assets"
      versioning = false
      quota_gb   = 10
      anonymous  = true
      tags = {
        public_assets = "anonymous"
      }
    }
  }

  policy_list = {
    app_rw = {
      name        = "app-rw-policy"
      bucket_keys = ["app_data"]
      actions_rw  = true
    }

    k8s_int_legacy_poc_rw = {
      name        = "k8s-int-legacy-poc-rw"
      bucket_keys = ["k8s_int_legacy_poc"]
      actions_rw  = true
    }

    app_ro = {
      name        = "app-ro-policy"
      bucket_keys = ["docs_data"]
      actions_rw  = false
    }

    test_import = {
      name        = "test-import-policy"
      bucket_keys = ["test_data"]
      actions_rw  = true
    }
  }

  group_list = {

    readers = {
      name        = "readers"
      policy_keys = ["app_ro"]
    }
  }

  user_list = {
    app_rw_user = {
      name       = "app-rw-user"
      secret_key = var.app_rw_user_secret
      policy_key = "app_rw"
      group_keys = []
    }

    app_ro_user = {
      name       = "app-ro-user"
      secret_key = var.app_ro_user_secret
      policy_key = "app_ro"
      group_keys = ["readers"]
    }

    test_import_user = {
      name       = "test-import-user"
      secret_key = var.test_import_user_secret
      policy_key = "test_import"
      group_keys = []
    }

    k8s_int_legacy_poc_user = {
      name       = "k8s-int-legacy-poc-user"
      secret_key = var.k8s_int_legacy_poc_user_secret
      policy_key = "k8s_int_legacy_poc_rw"
      group_keys = []
    }

  }
}
