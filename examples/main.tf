module "iam_accounts" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-iam.git//modules/iam-account"

  name      = "iam"
  folder_id = "xxx"
  folder_roles = [
    "admin",
  ]
  cloud_roles              = []
  enable_static_access_key = false
  enable_api_key           = false
  enable_account_key       = false

}

module "clickhouse" {
  source = "../"

  folder_id    = "xxx"

  cluster_name = "test-clickhouse-cluster"

  database_name = "db_name"
  user_name     = "user"
  user_password = "your_password"

  service_account_id = module.iam_accounts.id
}
