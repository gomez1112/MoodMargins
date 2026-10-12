#!/usr/bin/env python3
"""Transfer an approved PNG using the short-lived operations returned by Apple's API."""
from pathlib import Path
import hashlib
import json
import sys
import urllib.parse
import urllib.request

job_path = Path(sys.argv[1])
job = json.loads(job_path.read_text())
source = Path(job["path"])
data = source.read_bytes()
if len(data) != job["bytes"] or hashlib.sha256(data).hexdigest() != job["sha256"]:
    raise ValueError("The PNG has changed since approval; upload stopped.")
operations = job["operations"]
ranges = []
for operation in operations:
    url = urllib.parse.urlparse(operation["url"])
    host = url.hostname or ""
    if operation["method"] != "PUT" or url.scheme != "https" or not host.endswith(".apple.com"):
        raise ValueError("Apple's reservation returned an unexpected upload destination.")
    offset, length = operation["offset"], operation["length"]
    if offset < 0 or length <= 0 or offset + length > len(data):
        raise ValueError("The reserved byte range does not fit the approved PNG.")
    ranges.append((offset, offset + length))
cursor = 0
for start, end in sorted(ranges):
    if start != cursor:
        raise ValueError("The upload operations do not cover the PNG exactly once.")
    cursor = end
if cursor != len(data):
    raise ValueError("The upload operations do not cover the whole PNG.")
for operation in operations:
    headers = {item["name"]: item["value"] for item in operation["requestHeaders"]}
    start = operation["offset"]
    payload = data[start:start + operation["length"]]
    request = urllib.request.Request(operation["url"], data=payload, headers=headers, method="PUT")
    with urllib.request.urlopen(request, timeout=60) as response:
        if response.status not in (200, 201, 204):
            raise RuntimeError(f"Image transfer returned HTTP {response.status}.")
job_path.unlink()
print(json.dumps({"id": job["id"], "bytes": len(data), "sha256": job["sha256"]}))

