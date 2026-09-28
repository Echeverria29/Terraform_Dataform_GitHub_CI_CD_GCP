
variable "project" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "dataset_id" {
  description = "ID único del dataset"
  type        = string
  validation {
    condition     = can(regex("^[0-9A-Za-z_]+$", var.dataset_id))
    error_message = "El dataset_id solo puede contener letras, números y guiones bajos."
  }
}

variable "location" {
  description = "Ubicación geográfica del dataset"
  type        = string
  default     = "US"
}

variable "friendly_name" {
  description = "Nombre descriptivo del dataset"
  type        = string
  default     = ""
}

variable "description" {
  description = "Descripción del dataset"
  type        = string
  default     = ""
}

variable "default_table_expiration_ms" {
  description = "Tiempo de expiración por defecto de las tablas en milisegundos"
  type        = number
  default     = null
}

variable "labels" {
  description = "Etiquetas para el dataset"
  type        = map(string)
  default     = {}
}

variable "kms_key_name" {
  description = "Nombre de la clave KMS para encriptación"
  type        = string
  default     = ""
}

variable "delete_contents_on_destroy" {
  description = "Si es true, elimina el contenido del dataset al destruirlo"
  type        = bool
  default     = false
}

variable "access_entries" {
  description = "Lista de entradas de acceso al dataset"
  type = list(object({
    role           = string
    user_by_email  = optional(string)
    group_by_email = optional(string)
    domain         = optional(string)
    special_group  = optional(string)
    iam_member     = optional(string)
    view = optional(object({
      project_id = string
      dataset_id = string
      table_id   = string
    }))
    dataset = optional(object({
      target_types = list(string)
      dataset = object({
        project_id = string
        dataset_id = string
      })
    }))
    routine = optional(object({
      project_id = string
      dataset_id = string
      routine_id = string
    }))
  }))
  default = []
}
