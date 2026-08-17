#!/usr/bin/env bash
#
# Print the UDID of the best available iPhone simulator.
#
# Exists because pinning a device name does not survive: GitHub rotated the macos-latest
# simulator set to the iPhone 17 family and every run pinned to "iPhone 16" started failing
# in ~2 minutes with "Unable to find a device matching the provided destination specifier".
# Addressing a simulator by UDID sidesteps name *and* OS resolution entirely.
#
# Selection order, newest runtime first:
#   1. a plain iPhone (e.g. "iPhone 17")      — preferred: smallest surprise for UI tests
#   2. any other iPhone (Pro / Max / e / Air)  — fallback
# Ties broken by highest model number. The chosen device is reported on stderr so CI logs
# record what actually ran; only the UDID goes to stdout.
#
# Usage:  xcodebuild test -destination "id=$(scripts/pick-simulator.sh)"
set -euo pipefail

for tool in xcrun python3; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    # Both ship with the Xcode command line tools, so in practice either both are present or
    # neither is. Named explicitly anyway: a bare "python3: command not found" mid-pipeline
    # gives no hint that it came from here.
    echo "pick-simulator: $tool not found (install the Xcode command line tools: xcode-select --install)" >&2
    exit 1
  fi
done

udid=$(xcrun simctl list devices available --json | python3 -c "
import json, re, sys

data = json.load(sys.stdin)
best = None

def runtime_key(identifier):
    # com.apple.CoreSimulator.SimRuntime.iOS-26-5 -> (26, 5)
    tail = identifier.rsplit(\".\", 1)[-1]
    return tuple(int(n) for n in re.findall(r\"\d+\", tail))

for runtime, devices in data.get(\"devices\", {}).items():
    if \"iOS\" not in runtime:
        continue
    for device in devices:
        name = device.get(\"name\", \"\")
        udid = device.get(\"udid\")
        if not udid or not name.startswith(\"iPhone\"):
            continue
        model = re.search(r\"iPhone\s+(\d+)\", name)
        rank = (
            runtime_key(runtime),
            1 if re.fullmatch(r\"iPhone\s+\d+\", name) else 0,
            int(model.group(1)) if model else 0,
        )
        if best is None or rank > best[0]:
            best = (rank, udid, name, runtime.rsplit(\".\", 1)[-1])

if best is None:
    sys.exit(\"pick-simulator: no available iPhone simulator found\")

sys.stderr.write(\"pick-simulator: selected \" + best[2] + \" on \" + best[3] + \"\n\")
print(best[1])
")

if [ -z "$udid" ]; then
  echo "pick-simulator: could not resolve a simulator UDID" >&2
  exit 1
fi

echo "$udid"
