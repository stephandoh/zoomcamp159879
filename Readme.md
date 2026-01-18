# Module 1 Homework: Docker & SQL

This repository contains my solution for **Module 1 Homework** from the Data Engineering Zoomcamp.  
---
## Docker
### Question 1: Understanding Docker images

Run a Python container using:

```bash
docker run -it --rm --entrypoint=bash python:3.13
```

Check the pip version:
```
pip --version
```
#### Answer: 25.3

---

### Question 2: Docker Networking & Docker Compose

Given the docker-compose.yaml:
```
services:
  db:
    container_name: postgres
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: 'postgres'
      POSTGRES_PASSWORD: 'postgres'
      POSTGRES_DB: 'ny_taxi'
    ports:
      - '5433:5432'
    volumes:
      - vol-pgdata:/var/lib/postgresql/data
```
Since pgAdmin and Postgres are on the same Docker network, containers communicate using the service name and the internal container port.

Hostname: db

Port: 5432

The host mapping 5433:5432 is only for host-to-container access and does not apply to container-to-container communication.

#### Answer: db:5432
---
### Prepare the Data
Download taxi trips data for November 2025:

wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet

Download the NYC taxi zones dataset:


wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv

#### My Data Architecture
<img width="1436" height="805" alt="image" src="https://github.com/user-attachments/assets/a8269916-2960-4c5f-b18a-c6db709bf8d6" />

#### Steps
```
docker compose up -d 
 - here take note of the network name created by docker compose!
```
```
docker compose ps
```
```
docker build -t taxi_ingestion-python .
```
```
docker run -it --rm --network module13_taxi_ingestion --name taxi_ingestion-python-container taxi_ingestion-python
```
```
uv run python green_taxi.py
uv run python zones_taxi.py
```
```
login to pgadmin4 at http://localhost:8086 with these  credential "admin@taxi.com : root"

connect pgadmin4 to the database with:
  Host name/address: taxi_ingestion_db
  Port: 5432
  Maintenance database: taxi_db
  Username: root
  Password: root
```
```
write queries and answer questions 3 to 6
```
---
### SQL Queries
### Question 3: Counting short trips
```
SELECT 
    COUNT(*) AS Trips_less_1mile
FROM green_taxi_table
WHERE lpep_pickup_datetime >= '2025-11-01' 
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;
```
#### Answer: 8007
---
### Question 4: Longest trip for each day
```
SELECT 
    pickup_date
FROM
    (SELECT
         DATE(lpep_pickup_datetime) AS pickup_date,
         SUM(trip_distance) AS TotalDist
     FROM green_taxi_table
     WHERE trip_distance < 100
     GROUP BY DATE(lpep_pickup_datetime)
     ORDER BY SUM(trip_distance) DESC) AS T
LIMIT 1;
```
#### Answer: 2025-11-20
---
### Question 5: Biggest pickup zone
```
SELECT 
    Z."Zone",
    SUM(G.total_amount) AS SumofMoneyPaid
FROM green_taxi_table AS G
JOIN zones Z ON G."PULocationID" = Z."LocationID"
WHERE DATE(lpep_pickup_datetime) = '2025-11-18'
GROUP BY Z."Zone"
ORDER BY SumofMoneyPaid DESC;
```
#### Answer: East Harlem North
---
### Question 6: Largest tip
```
SELECT 
    Z1."Zone" AS dropoff_zone,
    G.tip_amount
FROM green_taxi_table AS G
JOIN zones Z1 ON G."DOLocationID" = Z1."LocationID"
JOIN zones Z2 ON G."PULocationID" = Z2."LocationID"
WHERE 
    Z2."Zone" = 'East Harlem North'
    AND G.lpep_pickup_datetime >= '2025-11-01'
    AND G.lpep_pickup_datetime < '2025-12-01'
ORDER BY G.tip_amount DESC  -- This finds the single highest value
LIMIT 1;
```
### Answer: Yorkville West
---
```
docker compose down
```
---
## Terraform
In this section homework we'll prepare the environment by creating resources in GCP with Terraform.

In your VM on GCP/Laptop/GitHub Codespace install Terraform. Copy the files from the course repo [here](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/01-docker-terraform/terraform/terraform)
 to your VM/Laptop/GitHub Codespace.

Modify the files as necessary to create a GCP Bucket and Big Query Dataset.
Setup
```
- Created the following Terraform files: 
    - main.tf 
    - variables.tf
    - outputs.tf
    - terraform.tfvars

- Added access controls in GCP project

- Used Terraform commands:
    - terraform init
    - terraform plan
    - terraform apply
```
---
### Question 7: Terraform Workflow
```
Workflow sequence for Terraform:

Download provider plugins & set up backend: terraform init

Generate proposed changes & auto-apply plan: terraform apply -auto-approve

Remove all resources managed by Terraform: terraform destroy
```
#### Answer: terraform init, terraform apply -auto-approve, terraform destroy
---
### Terraform & BigQuery Resources

- **google_bigquery_dataset**  
  Terraform resource for managing BigQuery datasets  
  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset

- **terraform-google bigquery module**  
  Community-supported Terraform module for provisioning BigQuery resources  
  https://registry.terraform.io/modules/terraform-google-modules/bigquery/google/latest

- **bigquery-terraform-module (Google Blog)**  
  Official Google Cloud blog introducing the BigQuery Terraform module  
  https://cloud.google.com/blog/products/data-analytics/introducing-the-bigquery-terraform-module

- **google_storage_bucket**  
  Terraform resource for managing Google Cloud Storage buckets  
  https://registry.terraform.io/providers/hashicorp/google/4.35.0/docs/resources/storage_bucket

### Other solution using local host to populate data in database
https://github.com/stephandoh/zoomcamp57877
