module "bigquery_datasets" {
  source                      = "./modules/bigquery_dataset"
  for_each                    = toset(var.dataset_names)
  project                     = var.project
  dataset_id                  = each.key
  location                    = var.region
  default_table_expiration_ms = var.default_table_expiration_days > 0 ? var.default_table_expiration_days * 86400000 : null
  labels                      = var.labels
}


module "bigquery_tables" {
  source     = "./modules/bigquery_table"
  for_each   = var.tables_config
  project    = var.project
  dataset_id = each.key
  tables     = each.value
  labels     = var.labels
  depends_on = [module.bigquery_datasets]
}

