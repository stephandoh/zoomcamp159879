variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "location" {
  description = "BigQuery dataset location"
  type        = string
  default     = "US"
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "ny_taxi_analytics"
}

variable "bucket_name" {
  description = "Name of the GCP Storage bucket for the data lake"
  type        = string
  default     = "ny-taxi-data-lake"
}