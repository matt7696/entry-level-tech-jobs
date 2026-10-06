import requests

BOARD_TOKEN = "stripe"  # swap for any company that uses Greenhouse
url = f"https://boards-api.greenhouse.io/v1/boards/{BOARD_TOKEN}/jobs"

response = requests.get(url, timeout=30)
response.raise_for_status()
data = response.json()

jobs = data["jobs"]
print(f"Found {len(jobs)} jobs at {BOARD_TOKEN}\n")

for job in jobs[:10]:
    print(job["title"], "|", job["location"]["name"])