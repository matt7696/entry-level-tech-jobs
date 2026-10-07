import json
from datetime import datetime, timezone
from pathlib import Path

import requests

BOARD_TOKEN = "stripe"  # swap for any company that uses Greenhouse
url = f"https://boards-api.greenhouse.io/v1/boards/{BOARD_TOKEN}/jobs"

response = requests.get(url, timeout=30)
response.raise_for_status()
data = response.json()

jobs = data["jobs"]
print(f"Found {len(jobs)} jobs at {BOARD_TOKEN}\n")

# Save the data to a JSON file
out_dir = Path("data/raw")
out_dir.mkdir(parents=True, exist_ok=True)

timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
out_file = out_dir / f"{BOARD_TOKEN}_{timestamp}.json"

with open(out_file, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print(f"Saved to {out_file}")