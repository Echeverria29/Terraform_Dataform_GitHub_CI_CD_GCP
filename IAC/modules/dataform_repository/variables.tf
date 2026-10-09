variable "project" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Región donde se creará el repositorio de Dataform"
  type        = string
}

variable "repository_id" {
  description = "Nombre o ID del repositorio de Dataform"
  type        = string
}

variable "git_remote_url" {
  description = "URL HTTPS del repositorio de GitHub"
  type        = string
}

variable "git_default_branch" {
  description = "Rama por defecto (main / master)"
  type        = string
  default     = "main"
}

variable "secret_github_token" {
  description = "Personal Access Token (PAT) de GitHub para autenticar Dataform"
  type        = string
  sensitive   = true
}

variable "project_number" {
  description = "Número numérico del proyecto de GCP (para IAM de la SA de Dataform)"
  type        = string
}