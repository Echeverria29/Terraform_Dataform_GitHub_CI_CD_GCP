
resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = var.dataset_id
  project                     = var.project
  location                    = var.location
  friendly_name               = var.friendly_name != "" ? var.friendly_name : var.dataset_id
  description                 = var.description
  default_table_expiration_ms = var.default_table_expiration_ms
  labels                      = var.labels
  delete_contents_on_destroy  = var.delete_contents_on_destroy

  dynamic "default_encryption_configuration" {
    for_each = var.kms_key_name != "" ? [1] : []
    content {
      kms_key_name = var.kms_key_name
    }
  }

  dynamic "access" {
    for_each = var.access_entries
    content {
      role           = access.value.role
      user_by_email  = lookup(access.value, "user_by_email", null)
      group_by_email = lookup(access.value, "group_by_email", null)
      domain         = lookup(access.value, "domain", null)
      special_group  = lookup(access.value, "special_group", null)
      iam_member     = lookup(access.value, "iam_member", null)

      dynamic "view" {
        for_each = lookup(access.value, "view", null) != null ? [access.value.view] : []
        content {
          project_id = view.value.project_id
          dataset_id = view.value.dataset_id
          table_id   = view.value.table_id
        }
      }

      dynamic "dataset" {
        for_each = lookup(access.value, "dataset", null) != null ? [access.value.dataset] : []
        content {
          target_types = dataset.value.target_types
          dataset {
            project_id = dataset.value.dataset.project_id
            dataset_id = dataset.value.dataset.dataset_id
          }
        }
      }

      dynamic "routine" {
        for_each = lookup(access.value, "routine", null) != null ? [access.value.routine] : []
        content {
          project_id = routine.value.project_id
          dataset_id = routine.value.dataset_id
          routine_id = routine.value.routine_id
        }
      }
    }
  }
}
