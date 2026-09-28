#!/usr/bin/env bash
# setup-ms2.sh - reproducible GCP/GKE setup for SOFE4630U Milestone 2.
#
# Deploys the MySQL and Redis servers on GKE and creates the two Pub/Sub topics
# the sink connectors consume from. The Integration Connectors and Application
# Integrations themselves are built in the Cloud console (see REPORT.md); this
# script covers every step that has a CLI equivalent.
#
#   ./scripts/setup-ms2.sh all        # zone + cluster + creds + mysql + redis + topics
#   ./scripts/setup-ms2.sh cluster    # just the GKE cluster
#   ./scripts/setup-ms2.sh mysql      # deploy MySQL (deployment + LoadBalancer)
#   ./scripts/setup-ms2.sh redis      # deploy Redis (deployment + LoadBalancer)
#   ./scripts/setup-ms2.sh topics     # create the two Pub/Sub topics
#   ./scripts/setup-ms2.sh ip         # print the MySQL and Redis external IPs
#   ./scripts/setup-ms2.sh teardown   # delete servers and cluster (stop billing)
#
# Env:
#   PROJECT    GCP project id      (default: my-first-test-235715)
#   ZONE       GKE compute zone    (default: northamerica-northeast1-b)
#   CLUSTER    GKE cluster name    (default: sofe4630u)
# gcloud/kubectl run under the personal config so work configs stay untouched.
set -euo pipefail

PROJECT="${PROJECT:-${GOOGLE_CLOUD_PROJECT:-my-first-test-235715}}"
ZONE="${ZONE:-northamerica-northeast1-b}"
CLUSTER="${CLUSTER:-sofe4630u}"
export CLOUDSDK_ACTIVE_CONFIG_NAME="${CLOUDSDK_ACTIVE_CONFIG_NAME:-sdt-a2}"

here="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
gc() { gcloud --project "$PROJECT" "$@"; }

zone() {
  gc config set compute/zone "$ZONE"
}

cluster() {
  zone
  gc services enable container.googleapis.com
  if gc container clusters describe "$CLUSTER" --zone "$ZONE" >/dev/null 2>&1; then
    echo "cluster $CLUSTER already exists"
  else
    gc container clusters create "$CLUSTER" --num-nodes=3 --zone "$ZONE"
  fi
  creds
}

creds() {
  gc container clusters get-credentials "$CLUSTER" --zone "$ZONE"
}

mysql() {
  kubectl apply -f "$here/mySQL/mysql-deploy.yaml"
  kubectl apply -f "$here/mySQL/mysql-service.yaml"
  echo "waiting for the mysql deployment to become available..."
  kubectl rollout status deployment/mysql-deployment
}

redis() {
  kubectl apply -f "$here/Redis/redis.yaml"
  echo "waiting for the redis deployment to become available..."
  kubectl rollout status deployment/redis
}

topics() {
  for t in pedestrianRecords pedestrianImages; do
    if gc pubsub topics describe "$t" >/dev/null 2>&1; then
      echo "topic $t already exists"
    else
      gc pubsub topics create "$t"
    fi
  done
}

ip() {
  echo "waiting for external IPs (Ctrl+C once both are assigned)..."
  kubectl get service mysql-service redis --watch
}

teardown() {
  kubectl delete -f "$here/mySQL/mysql-deploy.yaml" --ignore-not-found
  kubectl delete -f "$here/mySQL/mysql-service.yaml" --ignore-not-found
  kubectl delete -f "$here/Redis/redis.yaml" --ignore-not-found
  gc container clusters delete "$CLUSTER" --zone "$ZONE" --quiet
}

all() { cluster; mysql; redis; topics; ip; }

cmd="${1:-}"
case "$cmd" in
  zone|cluster|creds|mysql|redis|topics|ip|teardown|all) "$cmd" ;;
  *) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
