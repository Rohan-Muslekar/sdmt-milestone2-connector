from google.cloud import pubsub_v1      # pip install google-cloud-pubsub  ##to install
import glob                             # for searching for json file
import json
import os
import csv
import sys

# Search the current directory for the JSON file (including the service account key)
# to set the GOOGLE_APPLICATION_CREDENTIALS environment variable.
files = glob.glob("*.json")

# Set the project_id with your project ID
project_id = "my-first-test-235715";
topic_name = "pedestrianRecords";   # change it for your topic name if needed
csv_file = "Labels.csv";

# The five columns of Labels.csv that hold image / lidar file names. Everything
# else is numeric. A blank numeric cell becomes None so the MySQL connector
# stores a NULL instead of failing the insert.
string_fields = {
    "Occluded_Image_View", "Occluded_Image_Lidar",
    "Occluding_Image_View", "Occluding_Image_Lidar",
    "Ground_Truth_View",
}


def to_record(row):
    """Turn a CSV row (all strings) into a typed dict whose keys match the
    MySQL SmartMeter/PedestrianReadings column names one-to-one."""
    record = {}
    for field, value in row.items():
        if field in string_fields:
            record[field] = value
        else:
            record[field] = float(value) if value not in (None, "") else None
    return record


def selftest():
    header = ["Timestamp", "Car1_Location_X", "Occluded_Image_View"]
    row = dict(zip(header, ["1741128439.11", "", "A_001.png"]))
    rec = to_record(row)
    assert rec["Timestamp"] == 1741128439.11
    assert rec["Car1_Location_X"] is None      # blank numeric -> NULL
    assert rec["Occluded_Image_View"] == "A_001.png"  # name kept as string
    print("selftest ok")


if __name__ == "__main__" and "--selftest" in sys.argv:
    selftest()
    sys.exit(0)

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = files[0];

# create a publisher and get the topic path for the publisher. Ordering is
# enabled so records arrive in the order they were published.
publisher = pubsub_v1.PublisherClient(
    publisher_options=pubsub_v1.types.PublisherOptions(enable_message_ordering=True)
)
topic_path = publisher.topic_path(project_id, topic_name)
print(f"Publishing the records of {csv_file} to {topic_path}.")

published = 0
with open(csv_file, newline='') as f:
    # read the CSV file, each row is read as a dictionary keyed by the header
    for row in csv.DictReader(f):
        record = to_record(row)

        record_value = json.dumps(record).encode('utf-8')   # serialize the record

        try:
            # the ground-truth view name is used as the ordering key
            future = publisher.publish(topic_path, record_value,
                                       ordering_key=str(record["Ground_Truth_View"]))

            # ensure that the publishing has been completed successfully
            future.result()
            published += 1
            print("The record {} has been published successfully".format(record))
        except Exception as error:
            print("Failed to publish the record: {}".format(error))

print("{} records published to {}".format(published, topic_name))
