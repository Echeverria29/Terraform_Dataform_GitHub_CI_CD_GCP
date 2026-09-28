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
    ],
    "silver_retail" : [
      {
        "table_id" : "clientes",
        "schema_file" : "bigquery/schemas/silver/clientes.json",
        "time_partitioning" = {
          "type"  = "DAY"
          "field" = "fecha_registro"
        }
      }
    ]
  }
}

variable "views_config" {
  type = map(list(object({
    view_id = string
    query_file = string
  })))
  default = {
    "gold_retail" = [
      {
        "view_id" : "xxxxxxxxxxxxxxx",
        "query_file" : "bigquery/views/xxxxxxxxxxxxxxxxxxx.sql"
      }
    ]
  }
}
variable "default_table_expiration_days" { default = 0 }
variable "routines_config" {
  type = map(list(tuple([string, string, list(any)])))
  default = {
    "bronze_retail" : [
      [
        "sp_retail_clientes",
        "bigquery/routines/sp_retail_clientes.sql",
        []
      ]
    ]
  }
}