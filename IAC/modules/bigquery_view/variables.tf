variable "project" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "dataset_id" {
  description = "ID del dataset donde crear las vistas"
  type        = string
}

variable "views" {
  description = "Lista de configuraciones de vistas"
  type = list(object({
    view_id             = string
    query_file          = string
    description         = optional(string, "")
    use_legacy_sql      = optional(bool, false)
    expiration_days     = optional(number, 0)
    deletion_protection = optional(bool, false)
  }))
  default = []
}

variable "labels" {
  description = "Etiquetas para las vistas"
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "Nombre de la clave KMS para encriptación"
  type        = string
  default     = ""
}
