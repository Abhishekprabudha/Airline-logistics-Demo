#!/usr/bin/env bash
set -euo pipefail
mkdir -p assets/rendered
# Lightweight stitched export. GitHub Actions is recommended for this step because local browser playback already gives the cinematic sequence.
ffmpeg -y -stream_loop 1 -i assets/originals/airline_logistics_system.webm -i assets/demo-narration.mp3 \
  -map 0:v:0 -map 1:a:0 \
  -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:black,fps=24" \
  -c:v libx264 -pix_fmt yuv420p -preset medium -crf 24 -c:a aac -b:a 160k -shortest \
  assets/rendered/airline-logistics-ai-demo-narrated.mp4
