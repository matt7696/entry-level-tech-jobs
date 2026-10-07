import json
import time
from datetime import datetime, timezone
from pathlib import Path

import requests

BOARD_TOKENS = ["stripe", "airbnb", "figma", "cloudflare", "datadog"]

out_dir = Path("data/raw")
out_dir.mkdir(parents=True, exist_ok=True)

timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")


for token in BOARD_TOKENS:
    url = f"https://boards-api.greenhouse.io/v1/boards/{token}/jobs?content=true"
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Error fetching jobs for {token}: {e}")
        continue

    data = response.json()
    print(f"{token}: {len(data['jobs'])} jobs")
    
    with open(out_dir / f"{token}_{timestamp}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
    
    time.sleep(1) # Be polite and avoid hitting the API too quickly
    


