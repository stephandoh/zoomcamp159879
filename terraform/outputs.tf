output "bigquery_dataset_id" {
  description = "BigQuery dataset ID"
  value       = module.bigquery.bigquery_dataset.dataset_id
}

output "bigquery_table_ids" {
  description = "IDs of BigQuery tables created"
  value       = module.bigquery.table_ids
}

output "bigquery_view_ids" {
  description = "IDs of BigQuery views created"
  value       = module.bigquery.view_ids
}

output "gcs_bucket_name" {
  description = "Name of the GCP Storage bucket for data lake"
  value       = google_storage_bucket.data_lake_bucket.name
}