#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/rendered

DEFAULT_SOURCE="assets/originals/airline_logistics_system.webm"
SOURCE_VIDEO="${SOURCE_VIDEO:-$DEFAULT_SOURCE}"
NARRATION_AUDIO="${NARRATION_AUDIO:-assets/demo-narration.mp3}"
OUTPUT_VIDEO="${OUTPUT_VIDEO:-assets/rendered/airline-logistics-ai-demo-narrated.mp4}"

if [[ ! -f "$SOURCE_VIDEO" && "$SOURCE_VIDEO" == "$DEFAULT_SOURCE" ]]; then
  for candidate in assets/originals/airline_logistics_system.mp4 assets/originals/*.mp4 assets/originals/*.webm; do
    if [[ -f "$candidate" ]]; then
      SOURCE_VIDEO="$candidate"
      break
    fi
  done
fi

if [[ ! -f "$SOURCE_VIDEO" ]]; then
  echo "Error: source video not found: $SOURCE_VIDEO" >&2
  echo "Place a video under assets/originals/ or set SOURCE_VIDEO=/path/to/video before running this script." >&2
  exit 1
fi

if [[ ! -f "$NARRATION_AUDIO" ]]; then
  echo "Error: narration audio not found: $NARRATION_AUDIO" >&2
  echo "Generate it with scripts/generate_narration.py or set NARRATION_AUDIO=/path/to/audio." >&2
  exit 1
fi

# Lightweight stitched export. GitHub Actions is recommended for this step because local browser playback already gives the cinematic sequence.
ffmpeg -y -stream_loop 1 -i "$SOURCE_VIDEO" -i "$NARRATION_AUDIO" \
  -map 0:v:0 -map 1:a:0 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:black,fps=24" \
  -c:v libx264 -pix_fmt yuv420p -preset medium -crf 24 -c:a aac -b:a 160k -shortest \
  "$OUTPUT_VIDEO"
