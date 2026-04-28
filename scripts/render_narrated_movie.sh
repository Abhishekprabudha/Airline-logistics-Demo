#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/rendered

DEFAULT_SOURCE="assets/originals/airline_logistics_system.webm"
SOURCE_VIDEO="${SOURCE_VIDEO:-$DEFAULT_SOURCE}"
NARRATION_AUDIO="${NARRATION_AUDIO:-assets/demo-narration.mp3}"
OUTPUT_VIDEO="${OUTPUT_VIDEO:-assets/rendered/airline-logistics-ai-demo-narrated.mp4}"
WAIT_FOR_SOURCE_SECONDS="${WAIT_FOR_SOURCE_SECONDS:-0}"

is_http_url() {
  [[ "${1:-}" =~ ^https?:// ]]
}

to_direct_drive_url() {
  local raw="${1:-}"
  if [[ "$raw" =~ /file/d/([^/]+) ]]; then
    echo "https://drive.google.com/uc?export=download&id=${BASH_REMATCH[1]}"
    return
  fi
  if [[ "$raw" =~ [\?\&]id=([^&]+) ]]; then
    echo "https://drive.google.com/uc?export=download&id=${BASH_REMATCH[1]}"
    return
  fi
  echo "$raw"
}

if [[ ! -f "$SOURCE_VIDEO" && "$SOURCE_VIDEO" == "$DEFAULT_SOURCE" && -f videos.config.js ]]; then
  CONFIG_SOURCE="$(python3 - <<'PY'
import re
from pathlib import Path
text = Path("videos.config.js").read_text(encoding="utf-8")
match = re.search(r"airline_logistics_system\s*:\s*['\"]([^'\"]+)['\"]", text)
print(match.group(1).strip() if match else "")
PY
)"
  if [[ -n "${CONFIG_SOURCE:-}" ]]; then
    SOURCE_VIDEO="$(to_direct_drive_url "$CONFIG_SOURCE")"
  fi
fi

if ! is_http_url "$SOURCE_VIDEO" && [[ ! -f "$SOURCE_VIDEO" && "$WAIT_FOR_SOURCE_SECONDS" =~ ^[0-9]+$ && "$WAIT_FOR_SOURCE_SECONDS" -gt 0 ]]; then
  for ((elapsed=0; elapsed<WAIT_FOR_SOURCE_SECONDS; elapsed++)); do
    if [[ -f "$SOURCE_VIDEO" ]]; then
      break
    fi
    sleep 1
  done
fi

if ! is_http_url "$SOURCE_VIDEO" && [[ ! -f "$SOURCE_VIDEO" && "$SOURCE_VIDEO" == "$DEFAULT_SOURCE" ]]; then
  for candidate in \
    assets/originals/airline_logistics_system.mp4 \
    assets/originals/*.mp4 \
    assets/originals/*.webm \
    assets/*.mp4 \
    assets/*.webm; do
    if [[ -f "$candidate" ]]; then
      SOURCE_VIDEO="$candidate"
      break
    fi
  done
fi

if ! is_http_url "$SOURCE_VIDEO" && [[ ! -f "$SOURCE_VIDEO" ]]; then
  echo "Error: source video not found: $SOURCE_VIDEO" >&2
  echo "Place a video under assets/originals/ (or assets/), or set SOURCE_VIDEO to a local path/HTTP(S) URL before running this script." >&2
  echo "Tip: if videos.config.js contains airline_logistics_system, this script will use that URL automatically." >&2
  echo "If your build copies video files asynchronously, set WAIT_FOR_SOURCE_SECONDS=30 (or another value) to wait before failing." >&2
  exit 1
fi

if [[ ! -f "$NARRATION_AUDIO" ]]; then
  echo "Error: narration audio not found: $NARRATION_AUDIO" >&2
  echo "Generate it with scripts/generate_narration.py or set NARRATION_AUDIO=/path/to/audio." >&2
  exit 1
fi

# Lightweight stitched export. GitHub Actions is recommended for this step because local browser playback already gives the cinematic sequence.
SOURCE_INPUT_OPTS=()
if is_http_url "$SOURCE_VIDEO"; then
  SOURCE_INPUT_OPTS=(-reconnect 1 -reconnect_streamed 1 -reconnect_delay_max 5)
fi

ffmpeg -y -stream_loop 1 "${SOURCE_INPUT_OPTS[@]}" -i "$SOURCE_VIDEO" -i "$NARRATION_AUDIO" \
  -map 0:v:0 -map 1:a:0 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:black,fps=24" \
  -c:v libx264 -pix_fmt yuv420p -preset medium -crf 24 -c:a aac -b:a 160k -shortest \
  "$OUTPUT_VIDEO"
