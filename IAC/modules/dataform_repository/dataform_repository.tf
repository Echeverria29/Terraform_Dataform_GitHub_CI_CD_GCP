# 1. Secreto en Secret Manager para guardar el Token de GitHub
resource "google_secret_manager_secret" "github_token" {
  project   = var.project
  secret_id = "dataform-github-token-${var.repository_id}"

  replication {
    auto {}
  }
}

# 2. Guardar la versión del Secreto
resource "google_secret_manager_secret_version" "github_token_version" {
  secret      = google_secret_manager_secret.github_token.id
  secret_data = var.secret_github_token
}

# 3. Dar permisos a la Service Account oficial de Dataform en GCP para leer el secreto
resource "google_secret_manager_secret_iam_member" "dataform_secret_access" {
  project   = var.project
  secret_id = google_secret_manager_secret.github_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${var.project_number}@gcp-sa-dataform.iam.gserviceaccount.com"
}

# 4. Crear el Repositorio de Dataform en BigQuery vinculado a GitHub
resource "google_dataform_repository" "repository" {
  provider = google-beta
  project  = var.project
  region   = var.region
  name     = var.repository_id

  git_remote_settings {
    url                                 = var.git_remote_url
    default_branch                      = var.git_default_branch
    authentication_token_secret_version = google_secret_manager_secret_version.github_token_version.id
  }

  depends_on = [
    google_secret_manager_secret_iam_member.dataform_secret_access
  ]
}