#!/usr/bin/env python3
"""Upload only the byte ranges reserved by App Store Connect; never use API keys."""
from pathlib import Path
import hashlib
import json
import sys
import urllib.request

reservation = json.loads(Path(sys.argv[1]).read_text())
source = Path(reservation['path'])
with source.open('rb') as stream:
    for operation in reservation['operations']:
        if operation['method'] != 'PUT' or not operation['url'].startswith('https://'):
            raise ValueError('Unexpected asset upload operation')
        stream.seek(operation['offset'])
        part = stream.read(operation['length'])
        if len(part) != operation['length']:
            raise ValueError('The file does not match its reserved byte range')
        headers = {header['name']:header['value'] for header in operation['requestHeaders']}
        request = urllib.request.Request(operation['url'], data=part, headers=headers, method='PUT')
        with urllib.request.urlopen(request, timeout=90) as response:
            if response.status not in [200, 201, 204]:
                raise RuntimeError(f'Asset upload returned {response.status}')
print(json.dumps({'id':reservation['id'],'bytes':source.stat().st_size,'md5':hashlib.md5(source.read_bytes()).hexdigest()}))
Path(sys.argv[1]).unlink()
