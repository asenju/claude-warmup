#!/usr/bin/env bash

set -euo pipefail

python3 - <<'PY'
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
import os
import sys

TARGET_HOUR = 6
TARGET_MINUTE = 15
PACIFIC = ZoneInfo("America/Los_Angeles")

now_utc_raw = os.environ.get("NOW_UTC")

if now_utc_raw:
    normalized = now_utc_raw.replace("Z", "+00:00")
    try:
        now_utc = datetime.fromisoformat(normalized)
    except ValueError:
        print(f"Invalid NOW_UTC value: {now_utc_raw}", file=sys.stderr)
        sys.exit(2)

    if now_utc.tzinfo is None:
        now_utc = now_utc.replace(tzinfo=timezone.utc)
    else:
        now_utc = now_utc.astimezone(timezone.utc)
else:
    now_utc = datetime.now(timezone.utc)

local_time = now_utc.astimezone(PACIFIC)

if local_time.weekday() >= 5:
    print(
        f"Skipping warmup: local Pacific time is {local_time.strftime('%Y-%m-%d %H:%M %Z')} and it is a weekend."
    )
    sys.exit(78)

if (local_time.hour, local_time.minute) != (TARGET_HOUR, TARGET_MINUTE):
    print(
        "Skipping warmup: "
        f"local Pacific time is {local_time.strftime('%Y-%m-%d %H:%M %Z')} instead of "
        f"{TARGET_HOUR:02d}:{TARGET_MINUTE:02d}."
    )
    sys.exit(78)

print(f"Proceeding with warmup: local Pacific time is {local_time.strftime('%Y-%m-%d %H:%M %Z')}.")
PY
