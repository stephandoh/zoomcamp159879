terraform {
  required_version = ">= 1.0"

  required_providers {
  google = {
    source = "hashicorp/google"
  }
}
}

provider "google" {
  project = var.project_id
  region  = var.location
  credentials = file("${path.module}/solar-router-483810-s0-ed83e3d054aa.json")
}

module "bigquery" {
  source  = "terraform-google-modules/bigquery/google"
  version = "~> 10.2"

  project_id  = var.project_id
  dataset_id  = var.dataset_id
  dataset_name = "NY Taxi Analytics"
  location    = var.location
  description = "Analytics dataset for NY Taxi data"

  dataset_labels = {
    env      = "dev"
    pipeline = "taxi"
  }

  tables = [
    {
      table_id = "rides_raw"
      schema   = file("${path.module}/schemas/rides_raw.json")
      labels = {
        layer = "raw"
      }
    },
    {
      table_id = "rides_cleaned"
      schema   = file("${path.module}/schemas/rides_cleaned.json")
      time_partitioning = {
        type  = "DAY"
        field = "pickup_datetime"
        expiration_ms            = null
        require_partition_filter = false
      }
      clustering = ["pickup_zone"]
      labels = {
        layer = "clean"
      }
    },
    {
      table_id = "zones_dim"
      schema   = file("${path.module}/schemas/zones_dim.json")
      labels = {
        layer = "dimension"
      }
    }
  ]

  views = [
    {
      view_id        = "daily_revenue_view"
      use_legacy_sql = false
      query = <<EOF
      SELECT
        DATE(pickup_datetime) AS ride_date,
        pickup_zone,
        SUM(total_amount) AS total_revenue,
        COUNT(*) AS total_rides
      FROM
        `${var.project_id}.${var.dataset_id}.rides_cleaned`
      GROUP BY
        ride_date, pickup_zone
      EOF
      labels = {
        type = "aggregation"
      }
    }
  ]
}

# ------------------------
# GCP Storage Bucket
# ------------------------
resource "google_storage_bucket" "data_lake_bucket" {
  name                        = "${var.project_id}-ny-taxi-data"
  location                    = var.location
  force_destroy               = true   # allows deleting bucket even if objects exist
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = {
    env      = "dev"
    pipeline = "taxi"
  }
}


