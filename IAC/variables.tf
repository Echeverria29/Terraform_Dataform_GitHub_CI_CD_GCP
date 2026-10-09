#GLOBAL
variable "labels" {}


#PROVIDER
variable "project" {}
variable "region" {}


#BIGQUERY
variable "dataset_names" {
  default = [
    "bronze_retail",
    "silver_retail",
    "gold_retail"
  ]
}

variable "bucket_name" {}

# BIGQUERY
variable "tables_config" {
  type = map(list(object({
    table_id    = string
    schema_file = string
    time_partitioning = optional(object({
      type          = string # DAY, HOUR, MONTH, YEAR
      field         = optional(string)
      expiration_ms = optional(number)
    }))
    clustering_fields        = optional(list(string), [])
    require_partition_filter = optional(bool, false)
  })))
  default = {
    "bronze_retail" : [
      {
        "table_id" : "clientes",
        "schema_file" : "bigquery/schemas/bronze/clientes.json",
        "time_partitioning" = {
          "type"          = "DAY"
          "field"         = "load_timestamp_cl"
          "expiration_ms" = 691200000
        }
      }
    ]
  }
}

variable "default_table_expiration_days" { default = 0 }

# DATAFORM
variable "project_number" {
  description = "Número del proyecto de GCP"
  type        = string
}

variable "dataform_repository_id" {
  description = "ID del repositorio de Dataform"
  type        = string
  default     = "dataform-retail"
}

variable "git_remote_url" {
  description = "URL remota de GitHub"
  type        = string
}

variable "github_token" {
  description = "Personal Access Token de GitHub para Dataform"
  type        = string
  sensitive   = true
}