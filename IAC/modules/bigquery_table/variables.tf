variable "project" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "dataset_id" {
  description = "ID del dataset donde crear las tablas"
  type        = string
}

variable "tables" {
  description = "Lista de configuraciones de tablas"
  type = list(object({
    table_id    = string
    schema_file = string
    description = optional(string, "")
    time_partitioning = optional(object({
      type          = string # DAY, HOUR, MONTH, YEAR
      field         = optional(string)
      expiration_ms = optional(number)
    }))
    range_partitioning = optional(object({
      field = string
      range = object({
        start    = number
        end      = number
        interval = number
      })
    }))
    clustering_fields   = optional(list(string), [])
    expiration_days     = optional(number, 0)
    deletion_protection = optional(bool, false)
  }))
  default = []
}

variable "policy_tag_confidencial" {
  type    = string
  default = ""
}

variable "labels" {
  description = "Etiquetas para las tablas"
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "Nombre de la clave KMS para encriptación"
  type        = string
  default     = ""
}
