import redis        # pip install redis
import base64
import os
import sys

# proof-of-integration consumer for the Design part: read one image back from
# Redis by its key (the image name) and save it, to confirm the sink connector
# stored what publishImages.py published.
ip = os.environ.get("REDIS_IP", "")            # set the Redis LoadBalancer IP
key = sys.argv[1] if len(sys.argv) > 1 else "A_001.png"

r = redis.Redis(host=ip, port=6379, db=0, password='sofe4630u')

value = r.get(key)
if value is None:
    print(f"key '{key}' not found in Redis")
    sys.exit(1)

decoded_value = base64.b64decode(value)
out = "received_" + key
with open(out, "wb") as f:
    f.write(decoded_value)

print(f"Image received for key '{key}', check ./{out}")
