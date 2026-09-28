resource "google_bigquery_routine" "sproc" {
  project         = var.project
  dataset_id      = var.dataset_id
  routine_type    = var.routine_type
  language        = var.language
  for_each        = local.tsfp
  routine_id      = each.value.routine_id
  definition_body = file(each.value.sp)

  dynamic "arguments" {
    for_each = each.value.sp_arguments != null && each.value.sp_arguments != "" ? jsondecode(each.value.sp_arguments) : []
    content {
      name      = arguments.value["name"]
      data_type = "{\"typeKind\" :  \"${arguments.value["data_type"]}\"}"
    }
  }

}
