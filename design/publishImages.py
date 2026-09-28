from google.cloud import pubsub_v1      # pip install google-cloud-pubsub  ##to install
import glob                             # for searching for json file
import base64
import os
import sys

# Search the current directory for the JSON file (including the service account key)
# to set the GOOGLE_APPLICATION_CREDENTIALS environment variable.
files = glob.glob("*.json")

# Set the project_id with your project ID
project_id = "my-first-test-235715";
topic_name = "pedestrianImages";   # change it for your topic name if needed

# folder of images from GeorgeDaoud3/SOFE4630U-Design. Clone that repo and point
# IMAGE_DIR at its Dataset_Occluded_Pedestrian folder, or drop the folder here.
image_dir = os.environ.get("IMAGE_DIR", "Dataset_Occluded_Pedestrian")


def image_paths(directory):
    """All .png images in the folder, sorted so the run is reproducible.
    MAX_IMAGES caps the count (handy for a short demo); unset means all."""
    paths = sorted(glob.glob(os.path.join(directory, "*.png")))
    cap = os.environ.get("MAX_IMAGES")
    return paths[:int(cap)] if cap else paths


def selftest():
    assert os.path.basename("Dataset_Occluded_Pedestrian/A_001.png") == "A_001.png"
    assert base64.b64decode(base64.b64encode(b"abc")) == b"abc"  # round-trips
    print("selftest ok")


if __name__ == "__main__" and "--selftest" in sys.argv:
    selftest()
    sys.exit(0)

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = files[0];

# ordering must be enabled to publish with an ordering key (the image name).
publisher = pubsub_v1.PublisherClient(
    publisher_options=pubsub_v1.types.PublisherOptions(enable_message_ordering=True)
)
topic_path = publisher.topic_path(project_id, topic_name)
print(f"Publishing images from {image_dir} to {topic_path}.")

published = 0
for path in image_paths(image_dir):
    name = os.path.basename(path)          # image name is the Redis key
    with open(path, "rb") as f:
        value = base64.b64encode(f.read())  # serialize the image to base64

    try:
        # the image name is the message key -> becomes the Redis key
        future = publisher.publish(topic_path, value, ordering_key=name)
        future.result()
        published += 1
        print("The image {} has been published successfully".format(name))
    except Exception as error:
        print("Failed to publish {}: {}".format(name, error))

print("{} images published to {}".format(published, topic_name))
