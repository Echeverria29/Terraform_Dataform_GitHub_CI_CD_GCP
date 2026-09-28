resource "time_static" "current" {}

resource "google_bigquery_table" "table" {
  for_each = { for idx, table in var.tables : table.table_id => table }

  project     = var.project
  dataset_id  = var.dataset_id
  table_id    = each.value.table_id
  description = each.value.description
  schema      = templatefile("./resources/${each.value.schema_file}", {
    policy_tag_confidencial = var.policy_tag_confidencial
  })
  labels      = var.labels

  clustering          = length(each.value.clustering_fields) > 0 ? each.value.clustering_fields : null
  deletion_protection = each.value.deletion_protection

  dynamic "time_partitioning" {
    for_each = each.value.time_partitioning != null ? [each.value.time_partitioning] : []
    content {
      type          = time_partitioning.value.type
      field         = time_partitioning.value.field
      expiration_ms = time_partitioning.value.expiration_ms
    }
  }

  dynamic "range_partitioning" {
    for_each = each.value.range_partitioning != null ? [each.value.range_partitioning] : []
    content {
      field = range_partitioning.value.field
      range {
        start    = range_partitioning.value.range.start
        end      = range_partitioning.value.range.end
        interval = range_partitioning.value.range.interval
      }
    }
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
