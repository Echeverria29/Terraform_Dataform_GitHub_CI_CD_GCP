resource "time_static" "current" {}

resource "google_bigquery_table" "view" {
  for_each = { for idx, view in var.views : view.view_id => view }

  project     = var.project
  dataset_id  = var.dataset_id
  table_id    = each.value.view_id
  description = each.value.description
  labels      = var.labels

  deletion_protection = each.value.deletion_protection

  view {
    query          = file("./resources/${each.value.query_file}")
    use_legacy_sql = each.value.use_legacy_sql
  }

  dynamic "encryption_configuration" {
    for_each = var.kms_key_name != "" ? [1] : []
    content {
      kms_key_name = var.kms_key_name
    }
  }

  expiration_time = each.value.expiration_days > 0 ? (
    (time_static.current.unix * 1000) + (each.value.expiration_days * 86400000)
  ) : null
}