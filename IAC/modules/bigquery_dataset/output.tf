output "dataset_id" {
  description = "ID del dataset creado"
  value       = google_bigquery_dataset.dataset.dataset_id
}

output "self_link" {
  description = "Self link del dataset"
  value       = google_bigquery_dataset.dataset.self_link
}

output "creation_time" {
  description = "Tiempo de creación del dataset"
  value       = google_bigquery_dataset.dataset.creation_time
}