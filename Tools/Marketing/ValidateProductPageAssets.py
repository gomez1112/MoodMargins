#!/usr/bin/env python3
"""Validate the prepared PNGs against the Apple specifications captured for this package."""
from pathlib import Path
import argparse
import hashlib
import json
import struct

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("directory", nargs="?", default="Marketing/ProductPage")
parser.add_argument("--write-manifest", action="store_true", help="Rebuild the local export manifest after rendering.")
args = parser.parse_args()
root = Path(args.directory)
reference = json.loads((root / "AppleSpecifications.json").read_text())
plan = json.loads((root / "PagePlan.json").read_text())
assets = []

for localization in plan["localizations"]:
    locale = localization["locale"]
    if not 0 < len(localization["promotionalText"]) <= 170:
        raise ValueError(f"{locale}: promotional text exceeds Apple's limit")
    files = [root / locale / "header.png", root / locale / "search.png"]
    for device in ["iphone", "ipad"]:
        files.extend(root / locale / device / file for file in plan["screenshots"][device]["orderedFiles"])
    for path in files:
        data = path.read_bytes()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError(f"{path}: expected a PNG")
        width, height, depth, color_type = struct.unpack_from(">IIBB", data, 16)
        if depth != 8 or color_type != 2:
            raise ValueError(f"{path}: expected 8-bit RGB without alpha")
        offset = 8
        while offset < len(data):
            length = struct.unpack_from(">I", data, offset)[0]
            if data[offset + 4:offset + 8] == b"tRNS":
                raise ValueError(f"{path}: transparent color is not permitted")
            offset += length + 12

        if path.name == "header.png":
            kind = plan["creativeAssets"]["header"]
        elif path.name == "search.png":
            kind = plan["creativeAssets"]["search"]
        else:
            device = "ipad" if "ipad" in path.parts else "iphone"
            kind = {"placementType": "APP_SCREENSHOT", "placementGroup": plan["screenshots"][device]["placementGroup"]}
        placement = kind["placementType"]
        group = kind["placementGroup"]
        policy = next(item for item in reference["placementTypes"] if item["placementTypeId"] == placement)
        accepted = next(mapping["specs"] for mapping in policy["specMappings"] if mapping["placementGroupId"] == group)
        matches = []
        for spec in reference["imageSpecs"]:
            dimensions = spec["dimensions"]
            if (spec["specId"] in accepted
                and dimensions["minWidth"] <= width <= dimensions["maxWidth"]
                and dimensions["minHeight"] <= height <= dimensions["maxHeight"]
                and len(data) <= spec["maxFileSize"]):
                matches.append(spec["specId"])
        if not matches:
            raise ValueError(f"{path}: no compatible Apple specification")
        assets.append({"file": str(path.relative_to(root)), "locale": locale, "width": width, "height": height,
                       "bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(), "alpha": False,
                       "colorSpace": "sRGB", "placementType": placement, "placementGroup": group,
                       "specificationIds": matches,
                       "category": "APP_SCREENSHOTS_AND_PREVIEWS" if placement == "APP_SCREENSHOT" else "CREATIVE_ASSETS"})

manifest = {"appId": plan["appId"], "bundleId": plan["bundleId"], "status": "PREPARED_LOCALLY",
            "referenceName": plan["referenceName"], "validatedOn": reference["checkedOn"],
            "assets": sorted(assets, key=lambda item: (item["locale"], item["file"]))}
path = root / "AssetManifest.json"
if args.write_manifest:
    path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
else:
    recorded = json.loads(path.read_text())
    if sorted(recorded["assets"], key=lambda item: (item["locale"], item["file"])) != manifest["assets"]:
        raise ValueError("Exported files differ from the manifest; inspect the changes before rebuilding it.")
print(f"Verified {len(assets)} final PNGs and {len(plan['localizations'])} localized promotional texts.")

