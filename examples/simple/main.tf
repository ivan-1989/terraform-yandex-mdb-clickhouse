data "yandex_client_config" "client" {}

resource "random_id" "rand_id" {
  byte_length = 2
}
  

resource "random_id" "admin_password" {
  byte_length = 4
}

locals {
  prefix = "ch"
}


module "iam_accounts" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-iam.git//modules/iam-account?ref=v1.0.0"

#  name = "iam-${random_id.rand_id.hex}"
  name = "${local.prefix}-sa-${random_id.rand_id.hex}"
  folder_roles = [
    "admin",
  ]
  cloud_roles              = []
  enable_static_access_key = false
  enable_api_key           = false
  enable_account_key       = false

}

module "network" {
  source = "git::https://github.com/terraform-yacloud-modules/terraform-yandex-vpc.git?ref=v1.0.0"

  folder_id = data.yandex_client_config.client.folder_id

  blank_name = "${local.prefix}-vpc-nat-gateway-${random_id.rand_id.hex}"
#  blank_name = "clickhouse-vpc-nat-gateway"
  labels = {
    repo = "terraform-yacloud-modules/terraform-yandex-vpc"
  }

  azs = ["ru-central1-a","ru-central1-b","ru-central1-d"]

  private_subnets = [["10.3.0.0/24"],["10.3.1.0/24"],["10.3.2.0/24"]]

  create_vpc         = true
  create_nat_gateway = true
}


module "clickhouse" {
  source = "../../"

  network_id = module.network.vpc_id
  admin_password = "${random_id.admin_password.hex}"
  sql_user_management = true
  sql_database_management = true
#  admin_password = "${random_id.rand_id.hex}"

#  users = [
#    {
#      name     = "user1"
#      password = "password1"
#    }
#  ]

#  databases = [
#    {
#      name = "db_name"
#    }
#  ]

  hosts = [
    {
      type             = "CLICKHOUSE"
      zone             = "ru-central1-a"
      subnet_id        = module.network.private_subnets_ids[0]
      assign_public_ip = true
    }
  ]

  # Optional variables
  name                          = "${local.prefix}-cluster-${random_id.rand_id.hex}"
  clickhouse_disk_size          = 10
  clickhouse_disk_type_id       = "network-ssd"
  clickhouse_resource_preset_id = "s3-c2-m8"
  environment                   = "PRODUCTION"
  clickhouse_version            = "24.8"
  description                   = "ClickHouse cluster description"
  folder_id                     = data.yandex_client_config.client.folder_id

  depends_on = [module.iam_accounts, module.network]
}
