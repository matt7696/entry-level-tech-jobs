import time
import requests

with open("candidates.txt") as f:
    tokens = [line.strip() for line in f if line.strip()]

working = []
for token in tokens:
    url = f"https://boards-api.greenhouse.io/v1/boards/{token}/jobs"
    try:
        r = requests.get(url, timeout=30)
    except requests.RequestException as e:
        print(f"{token}: error ({e})")
        continue

    if r.status_code == 200:
        n = len(r.json()["jobs"])
        print(f"{token}: OK, {n} jobs")
        working.append(token)
    else:
        print(f"{token}: {r.status_code}")
    time.sleep(1)

with open("boards.txt", "w") as f:
    f.write("\n".join(working))

print(f"\n{len(working)} of {len(tokens)} boards work. Saved to boards.txt")