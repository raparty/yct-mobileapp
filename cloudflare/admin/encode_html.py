#!/usr/bin/env python3
"""Encode index.html as base64 into worker.js HTML_B64 constant."""
import base64, re, sys

with open('index.html', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()

with open('worker.js', 'r') as f:
    content = f.read()

new_content = re.sub(
    r'(const HTML_B64 = ")[^"]+(";\s*)',
    lambda m: m.group(1) + b64 + m.group(2),
    content
)

if new_content == content:
    print('ERROR: HTML_B64 pattern not found in worker.js', file=sys.stderr)
    sys.exit(1)

with open('worker.js', 'w') as f:
    f.write(new_content)

print(f'OK: encoded {len(b64)} chars into worker.js')
