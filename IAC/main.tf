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

# ─── MÓDULO DATAFORM ──────────────────────────────────────────────────────────
module "dataform_repository" {
  source              = "./modules/dataform_repository"
  project             = var.project
  project_number      = var.project_number
  region              = var.region
  repository_id       = var.dataform_repository_id
  git_remote_url      = var.git_remote_url
  git_default_branch  = "main"
  secret_github_token = var.github_token
}