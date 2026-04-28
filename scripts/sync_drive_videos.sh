#!/usr/bin/env bash
set -euo pipefail

DEST_DIR="${DEST_DIR:-assets/originals}"
VIDEO_EXT="${VIDEO_EXT:-mp4}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-0}"

SCENE_KEYS=(
  non_ideal_box_flow
  non_ideal_baggage_flow
  non_ideal_people_flow
  box_math_detection
  baggage_math_detection
  airline_logistics_system
  dynamic_pricing
  happy_box_flow
  happy_baggage_flow
  happy_people_flow
)

mkdir -p "$DEST_DIR"

if [[ ! -f videos.config.js ]]; then
  echo "Error: videos.config.js not found." >&2
  exit 1
fi

readarray -t SCENE_SOURCES < <(python3 - <<'PY'
import re
from pathlib import Path

keys = [
  "non_ideal_box_flow",
  "non_ideal_baggage_flow",
  "non_ideal_people_flow",
  "box_math_detection",
  "baggage_math_detection",
  "airline_logistics_system",
  "dynamic_pricing",
  "happy_box_flow",
  "happy_baggage_flow",
  "happy_people_flow",
]
text = Path("videos.config.js").read_text(encoding="utf-8")

def to_direct(value: str) -> str:
    v = value.strip()
    path_match = re.search(r"/file/d/([^/]+)", v)
    if path_match:
        return f"https://drive.google.com/uc?export=download&id={path_match.group(1)}"
    id_match = re.search(r"[?&]id=([^&]+)", v)
    if id_match:
        return f"https://drive.google.com/uc?export=download&id={id_match.group(1)}"
    return v

for key in keys:
    m = re.search(rf"\b{re.escape(key)}\b\s*:\s*['\"]([^'\"]+)['\"]", text)
    value = m.group(1).strip() if m else ""
    if not value:
        raise SystemExit(f"Missing videos.config.js value for key: {key}")
    print(to_direct(value))
PY
)

for i in "${!SCENE_KEYS[@]}"; do
  key="${SCENE_KEYS[$i]}"
  source="${SCENE_SOURCES[$i]}"
  destination="${DEST_DIR}/${key}.${VIDEO_EXT}"

  if [[ -f "$destination" && "$FORCE_DOWNLOAD" != "1" ]]; then
    echo "Skipping existing file: $destination"
    continue
  fi

  echo "Downloading ${key} -> ${destination}"
  curl -fL --retry 4 --retry-delay 2 --retry-all-errors "$source" -o "$destination"
done

echo "Drive video sync complete in ${DEST_DIR}"
