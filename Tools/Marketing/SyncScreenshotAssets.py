#!/usr/bin/env python3
"""Copy verified artwork into Bitrig's documented listing asset directories."""
from pathlib import Path
import json
import shutil

devices = {
    'iphone': ('iOS', 'app-iphone-67', 6),
    'ipad': ('iOS', 'app-ipad-pro-3gen-129', 6),
    'watch': ('iOS', 'app-watch-series-10', 6),
    'mac': ('macOS', 'app-desktop', 6),
    'vision': ('visionOS', 'app-apple-vision-pro', 3),
}
for language, locale in [('en', 'en-US'), ('es', 'es-ES'), ('ar', 'ar-SA')]:
    for device, (platform, display, count) in devices.items():
        source = Path('Marketing/Rendered') / language / device
        files = sorted(source.glob('*.png'))
        if len(files) != count:
            raise ValueError(f'{source}: expected {count} exports, found {len(files)}')
        target = Path('appStoreConnect/appStoreVersion') / platform / 'screenshots' / locale / display
        assets = target / 'assets'
        assets.mkdir(parents=True, exist_ok=True)
        for image in files:
            shutil.copyfile(image, assets / image.name)
        (target / 'manifest.json').write_text(json.dumps({'screenshots': [p.name for p in files]}, indent=2) + '\n')
        print(f'{locale}/{display}: {len(files)} screenshots')
