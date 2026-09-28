#!/usr/bin/env bash
# record-demo.sh - shot lists and a live watch for the two Milestone 2 videos.
#
#   ./scripts/record-demo.sh connectors   # video 1: MySQL + Redis sink connectors
#   ./scripts/record-demo.sh design       # video 2: the design part with proofs
#   ./scripts/record-demo.sh watch        # live kubectl watch to film alongside
#
# Both videos are audible and about 5 minutes. Record in Chrome (the console
# integration editor does not work in Firefox).
set -euo pipefail
export CLOUDSDK_ACTIVE_CONFIG_NAME="${CLOUDSDK_ACTIVE_CONFIG_NAME:-sdt-a2}"

connectors() {
  cat <<'EOF'
VIDEO 1 - MySQL and Redis sink connectors (~5 min, audible)   [rubric 9, 11]

  MySQL sink connector
   1. Integration Connectors: show the mysql-connector, status Active, nodes = 2.
   2. Application Integration mysql-integration: Cloud Pub/Sub Trigger ->
      Data Mapping -> mysql-connector (SmartMeter, Create). Show it published.
   3. Run smartMeter.py locally; show it publishing to smartMeterReadings.
   4. mysql -uusr -psofe4630u -h<MYSQL-IP>  then  use Readings; select * from SmartMeter;
      Show rows arriving = successful sink integration.

  Redis sink connector
   5. Integration Connectors: show the redis-connector, status Active, nodes = 2.
   6. Application Integration redis-integration: Trigger -> Data Mapping ->
      redis-connector (Keys, Create). Show it published.
   7. Run produceImage.py (ontarioTech.jpg -> Image2Redis, key "image").
   8. redis-cli -h <REDIS-IP> -a sofe4630u  then  select 0; keys *; then run
      ReceiveImage.py and open received.jpg = the Ontario Tech image round-trip.
   9. Say what the connector did: consumed the topic, wrote to the datastore, no code.
EOF
}

design() {
  cat <<'EOF'
VIDEO 2 - Design part with proof of integration (~5 min, audible)   [rubric 3-8]

   1. Pub/Sub: show the TWO topics  pedestrianRecords  and  pedestrianImages.   [3]
   2. kubectl get service : show MySQL and Redis both deployed with IPs.        [4]
   3. Integration Connectors + Application Integrations: show BOTH integrations
      (records -> MySQL, images -> Redis) published and Active.                 [5]
   4. Show design/publishRecords.py and design/publishImages.py briefly.        [6]
   5. Run publishRecords.py; then in MySQL: use Readings; select count(*) from
      Pedestrian; select * from Pedestrian limit 3;  = records stored.          [6,7]
   6. Run publishImages.py (IMAGE_DIR=Dataset_Occluded_Pedestrian); show it
      publishing every image with the file name as key.                        [8]
   7. redis-cli: keys * shows the image names; then run
      design/getImage.py A_001.png and open received_A_001.png = image stored.  [6,8]
   8. State the flow: producer -> topic -> Application Integration -> connector
      -> MySQL table / Redis store -> consumer reads it back.
EOF
}

watch() {
  kubectl get service mysql-service redis --watch
}

cmd="${1:-}"
case "$cmd" in
  connectors|design|watch) "$cmd" ;;
  *) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 1 ;;
esac
