#!/usr/bin/env python3
"""Encode live app recordings using the installed Apple media frameworks."""
from pathlib import Path
import subprocess
import sys
import wave

with wave.open('/private/tmp/MoodMargins-preview-silence.wav', 'wb') as silence:
    silence.setnchannels(2)
    silence.setsampwidth(2)
    silence.setframerate(48_000)
    silence.writeframes(bytes(48_000 * 30 * 4))

languages = sys.argv[1:] or ['en', 'es', 'ar']
for language in languages:
    root = Path('Marketing/AppPreviews') / language
    root.mkdir(parents=True, exist_ok=True)
    for device, width, height in [('iphone', 886, 1920), ('ipad', 1200, 1600), ('mac', 1920, 1080)]:
        source = Path('Marketing/SourceCaptures') / language / f'{device}-preview-raw.mp4'
        output = root / f'{device}.mp4'
        subprocess.run(['xcrun', 'swift', '-swift-version', '6', '-default-isolation', 'MainActor', '-module-cache-path', '/private/tmp/MoodMargins-Preview-Modules', 'Tools/Marketing/EncodeAppPreview.swift', str(source), str(output), str(width), str(height)], check=True)

for temporary in Path("Marketing/AppPreviews").glob("*/*.mp4.sb-*"):
    temporary.unlink()
