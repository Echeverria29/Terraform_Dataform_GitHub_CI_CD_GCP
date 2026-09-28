variable "dataset_id" {}
variable "project" {}

variable "routine_type" {
  default = "PROCEDURE"
}
variable "language" {
  default = "SQL"
}

variable "sp_config" {}

locals {
  tsfp = { for iterator in toset(var.sp_config) :
    "${iterator[0]}-${iterator[1]}-${length(iterator) > 2 ? jsonencode(iterator[2]) : "default_sp_arguments"}" => {
      routine_id   = iterator[0]
      sp           = "./resources/${iterator[1]}"
      sp_arguments = length(iterator) > 2 ? jsonencode(iterator[2]) : null
    }
  }
}