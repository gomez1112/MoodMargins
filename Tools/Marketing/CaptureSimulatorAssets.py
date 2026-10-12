#!/usr/bin/env python3
"""Capture real simulator UI; all sessions use isolated fictional journal data."""
from pathlib import Path
import signal
import subprocess
import sys
import time

mode, simulator, app_path, output_path = sys.argv[1:5]
languages = sys.argv[5:] or ['en', 'es', 'ar']
bundle = 'com.transfinite.MoodMargins.watchkitapp' if mode == 'watch' else 'com.transfinite.MoodMargins'
output = Path(output_path).resolve()
def sim(*args, check=True):
    result = subprocess.run(['xcrun', 'simctl', *args], capture_output=True, text=True)
    if check and result.returncode:
        raise RuntimeError(result.stderr.strip())
    return result
state = sim('list', 'devices', 'booted', '-j').stdout
if simulator not in state:
    sim('boot', simulator)
    sim('bootstatus', simulator, '-b')
sim('install', simulator, str(Path(app_path).resolve()))
if mode in ['iphone', 'ipad', 'watch']:
    sim('status_bar', simulator, 'override', '--time', '9:41', check=False)
for language in languages:
    directory = output / language
    directory.mkdir(parents=True, exist_ok=True)
    locale = {'en': 'en_US', 'es': 'es_ES', 'ar': 'ar_SA'}[language]
    base = ['--marketing-capture', '-AppleLanguages', f'({language})', '-AppleLocale', locale]
    if mode in ['iphone', 'ipad']:
        sim('terminate', simulator, bundle, check=False)
        sim('launch', simulator, bundle, *base, '--marketing-preview')
        time.sleep(2)
        raw = directory / f'{mode}-preview-raw.mp4'
        raw.unlink(missing_ok=True)
        recording = subprocess.Popen(['xcrun', 'simctl', 'io', simulator, 'recordVideo', '--codec=h264', str(raw)], stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        try:
            # The DEBUG tour pauses on actual tabs; this is a recording interval.
            time.sleep(22)
        finally:
            recording.send_signal(signal.SIGINT)
        _, stderr = recording.communicate(timeout=20)
        if recording.returncode != 0 or not raw.exists():
            raise RuntimeError(stderr.decode())
        print(f'{language}/{raw.name}', flush=True)
    else:
        routes = [('check-in', []), ('moods', ['--marketing-focus', '1']), ('pages', ['--marketing-pages']), ('detail', ['--marketing-detail']), ('mood-sad', ['--marketing-focus', '2']), ('mood-laughing', ['--marketing-focus', '5'])] if mode == 'watch' else [('today', ['--marketing-tab', 'today']), ('pages', ['--marketing-tab', 'page']), ('insights', ['--marketing-tab', 'insights'])]
        for name, flags in routes:
            sim('launch', '--terminate-running-process', simulator, bundle, *base, *flags)
            time.sleep(12 if mode == 'vision' else 3)
            destination = directory / f'{mode}-{name}.png'
            sim('io', simulator, 'screenshot', str(destination))
            print(f'{language}/{destination.name}', flush=True)
sim('terminate', simulator, bundle, check=False)
