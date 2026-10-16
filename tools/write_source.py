#!/usr/bin/env python3
"""Prints a SideStore/AltStore source listing the newly built .ipa, so SideStore can offer updates."""
import argparse
import datetime
import json
import os

p = argparse.ArgumentParser()
p.add_argument("--repo", required=True)
p.add_argument("--build", required=True)
p.add_argument("--ipa", required=True)
p.add_argument("--notes", default="")
a = p.parse_args()

version = f"1.0.{a.build}"
download = f"https://github.com/{a.repo}/releases/download/build-{a.build}/KBWorkout.ipa"
icon = f"https://raw.githubusercontent.com/{a.repo}/main/KBWorkout/Resources/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
date = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
size = os.path.getsize(a.ipa)

print(json.dumps({
    "name": "KB Workout",
    "identifier": "com.adesai.kbworkout.source",
    "apps": [{
        "name": "KB Workout",
        "bundleIdentifier": "com.adesai.kbworkout",
        "developerName": "Personal",
        "localizedDescription": "Personal kettlebell workout coach.",
        "iconURL": icon,
        "tintColor": "C4F23A",
        "version": version,
        "versionDate": date,
        "downloadURL": download,
        "size": size,
        "versions": [{
            "version": version,
            "buildVersion": a.build,
            "date": date,
            "localizedDescription": a.notes,
            "downloadURL": download,
            "size": size,
            "minOSVersion": "17.0",
        }],
        "appPermissions": {"entitlements": [], "privacy": {}},
    }],
    "news": [],
}, indent=2))
