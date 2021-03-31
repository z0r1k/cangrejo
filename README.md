# Cangrejo the Crab

Welcome to Cangrejo SA Digital Transformation

## Folders

`docs/` contains documentation in PDF format.
Miro link: https://miro.com/app/board/o9J_lM4TqRY=/

The rest contains Terraform code. I should have put it in some sort of `src/` folder, I guess 🤔

## Requirements 

* `terraform` >= 0.13 should be installed.
* `make`

## How to run

`make` will do the job. YOLO.

Sample output:

```shell
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

grafana_service_uri = "https://dashboard-dev-cangrejo-sa.aivencloud.com:443"
influx_service_uri = "https+influxdb://avnadmin:xyz@metrics-db-dev-cangrejo-sa.aivencloud.com:19891/defaultdb"
kafka_service_uri = "kafka-dev-cangrejo-sa.aivencloud.com:19893"
pg_service_uri = "postgres://avnadmin:xyz1337@db-dev-cangrejo-sa.aivencloud.com:19891/defaultdb?sslmode=require"
```

## TODOs

* GitHub Actions Pipeline for PR-based SDLC
* Terraform Cloud integration for state management, versioning, rollback and apply
