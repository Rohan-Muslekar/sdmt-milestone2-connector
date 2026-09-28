# sdmt-milestone2-connector

SOFE4630U Milestone 2 (Data Storage and Integration Connectors) for ENGR 5520G. Two Google Cloud Pub/Sub sink connectors, built with Integration Connectors and Application Integration, that automatically store published messages: smart-meter and Occluded-Pedestrian records into a **MySQL** server, and images into a **Redis** server, both running on Google Kubernetes Engine.

Student: Rohan Muslekar, 101006689.

## Layout

| Path | What it is |
| --- | --- |
| `mySQL/` | MySQL deployment and LoadBalancer service (lab source, verbatim) |
| `Redis/` | Redis deployment and service, plus `code/` image test scripts (lab source) |
| `MySQL-connector/smartMeter.py` | lab producer: publishes smart-meter readings to `smartMeterReadings` |
| `Redis-connector/` | lab producer/consumer: `produceImage.py`, `ReceiveImage.py`, `ontarioTech.jpg` |
| `design/publishRecords.py` | Design: reads `Labels.csv`, publishes each record to `pedestrianRecords` (MySQL sink) |
| `design/publishImages.py` | Design: reads every image in `Dataset_Occluded_Pedestrian/`, publishes it with the file name as key to `pedestrianImages` (Redis sink) |
| `design/getImage.py` | Design consumer: reads one image back from Redis by key, as proof of integration |
| `design/create_table.sql` | the `Pedestrian` table, columns matching `Labels.csv` one-to-one |
| `design/Labels.csv` | the Occluded-Pedestrian records dataset |
| `scripts/setup-ms2.sh` | reproducible GKE setup: cluster, MySQL, Redis, the two topics |
| `scripts/record-demo.sh` | shot lists for the two videos and a live kube watch |
| `REPORT.md` | the report source (discussion + design) |
| `build_report.py` | renders `REPORT.md` to a self-contained printable HTML report |

## Quick start

```bash
./scripts/setup-ms2.sh all     # GKE cluster + MySQL + Redis + the two topics
./scripts/setup-ms2.sh ip      # read the MySQL and Redis external IPs
python3 build_report.py        # build the report
```

The Integration Connectors and Application Integrations are built in the Cloud console (Toronto region, `northamerica-northeast2`); `REPORT.md` documents every step. The image dataset is not committed: clone [GeorgeDaoud3/SOFE4630U-Design](https://github.com/GeorgeDaoud3/SOFE4630U-Design) and point `IMAGE_DIR` at its `Dataset_Occluded_Pedestrian` folder before running `publishImages.py`.

The `mySQL/`, `Redis/`, `MySQL-connector/`, and `Redis-connector/` files are the lab-provided sources, kept verbatim. The `design/`, `scripts/`, and report tooling are added for the Design part and reproducibility.
