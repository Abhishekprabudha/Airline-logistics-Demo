#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/rendered

NARRATION_AUDIO="${NARRATION_AUDIO:-assets/demo-narration.mp3}"
OUTPUT_VIDEO="${OUTPUT_VIDEO:-assets/rendered/airline-logistics-ai-demo-narrated.mp4}"
TARGET_WIDTH="${TARGET_WIDTH:-1280}"
TARGET_HEIGHT="${TARGET_HEIGHT:-720}"
TARGET_FPS="${TARGET_FPS:-24}"
CROSSFADE_SECONDS="${CROSSFADE_SECONDS:-0.45}"

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

SCENE_NAMES=(
  "Opening risk - non ideal box flow"
  "Opening risk - non ideal baggage flow"
  "Opening risk - non ideal people flow"
  "Cargo damage intelligence"
  "Baggage damage intelligence"
  "Integrated AI logistics command"
  "Dynamic pricing optimization"
  "Transformation - happy box flow"
  "Transformation - happy baggage flow"
  "Transformation - happy people flow"
)

SECTION_SECONDS=(
  13
  13
  13
  17
  17
  32
  18
  13
  13
  13
)

TRIM_START_SECONDS=(
  0.25
  0.20
  0.15
  0.20
  0.20
  0.15
  0.10
  0.10
  0.10
  0.10
)

if [[ ! -f "$NARRATION_AUDIO" ]]; then
  echo "Error: narration audio not found: $NARRATION_AUDIO" >&2
  echo "Generate it with scripts/generate_narration.py or set NARRATION_AUDIO=/path/to/audio." >&2
  exit 1
fi

resolve_local_source() {
  local key="$1"
  local ext
  for ext in mp4 webm mov m4v; do
    if [[ -f "assets/originals/${key}.${ext}" ]]; then
      echo "assets/originals/${key}.${ext}"
      return 0
    fi
    if [[ -f "assets/${key}.${ext}" ]]; then
      echo "assets/${key}.${ext}"
      return 0
    fi
  done
  return 1
}

SCENE_SOURCES=()
for key in "${SCENE_KEYS[@]}"; do
  if source="$(resolve_local_source "$key")"; then
    SCENE_SOURCES+=("$source")
  else
    echo "Error: missing local source for scene key '${key}'." >&2
    echo "Run scripts/sync_drive_videos.sh first or place files in assets/originals/." >&2
    exit 1
  fi
done

if [[ "${#SCENE_SOURCES[@]}" -ne "${#SCENE_KEYS[@]}" ]]; then
  echo "Error: expected ${#SCENE_KEYS[@]} scene sources, got ${#SCENE_SOURCES[@]}." >&2
  exit 1
fi

echo "Scene -> local video mapping used by renderer:"
for i in "${!SCENE_KEYS[@]}"; do
  printf '  %02d. %s -> %s\n' "$((i + 1))" "${SCENE_NAMES[$i]}" "${SCENE_KEYS[$i]}"
  printf '      local source: %s\n' "${SCENE_SOURCES[$i]}"
done

echo "Source diagnostics (codec, fps, time_base, pixel format):"
for i in "${!SCENE_SOURCES[@]}"; do
  diag="$(ffprobe -v error -select_streams v:0 \
    -show_entries stream=codec_name,r_frame_rate,time_base,pix_fmt,width,height \
    -of default=noprint_wrappers=1:nokey=1 "${SCENE_SOURCES[$i]}" | tr '\n' ' ' || true)"
  printf '  %02d. %s -> %s\n' "$((i + 1))" "${SCENE_KEYS[$i]}" "${diag:-unavailable}"
done

NARRATION_DURATION="$(ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$NARRATION_AUDIO")"
TOTAL_VISUAL_SECONDS=0
for s in "${SECTION_SECONDS[@]}"; do
  TOTAL_VISUAL_SECONDS=$((TOTAL_VISUAL_SECONDS + s))
done
VISUAL_SCALE="$(python3 - <<PY
narr=float("$NARRATION_DURATION")
base=float($TOTAL_VISUAL_SECONDS)
print(narr/base if base > 0 else 1.0)
PY
)"

INPUT_ARGS=()
FILTER_LINES=()
TOTAL_OFFSET="0.0"

for i in "${!SCENE_SOURCES[@]}"; do
  source="${SCENE_SOURCES[$i]}"
  trim_start="${TRIM_START_SECONDS[$i]}"
  target_scaled="$(python3 - <<PY
base=float("${SECTION_SECONDS[$i]}")
scale=float("$VISUAL_SCALE")
print(max(4.0, base*scale))
PY
)"

  INPUT_ARGS+=(
    -ss "$trim_start"
    -i "$source"
  )

  safe_title="${SCENE_NAMES[$i]//:/ -}"
  FILTER_LINES+=(
    "[$i:v]scale=${TARGET_WIDTH}:${TARGET_HEIGHT}:force_original_aspect_ratio=decrease,pad=${TARGET_WIDTH}:${TARGET_HEIGHT}:(ow-iw)/2:(oh-ih)/2:black,tpad=stop_mode=clone:stop_duration=600,trim=duration=${target_scaled},setpts=PTS-STARTPTS,fps=${TARGET_FPS},settb=AVTB,format=yuv420p,drawtext=text='${safe_title}':x=60:y=h-110:fontsize=38:fontcolor=white:box=1:boxcolor=black@0.45:boxborderw=14[v$i]"
  )

  if [[ "$i" -eq 0 ]]; then
    TOTAL_OFFSET="$target_scaled"
  else
    prev_label="vxf$((i-1))"
    if [[ "$i" -eq 1 ]]; then
      prev_label="v0"
    fi
    xfade_offset="$(python3 - <<PY
total=float("${TOTAL_OFFSET}")
cross=float("${CROSSFADE_SECONDS}")
print(max(0.0, total - cross))
PY
)"
    FILTER_LINES+=("[${prev_label}][v$i]xfade=transition=fade:duration=${CROSSFADE_SECONDS}:offset=${xfade_offset}[vxf$i]")
    TOTAL_OFFSET="$(python3 - <<PY
total=float("${TOTAL_OFFSET}")
duration=float("${target_scaled}")
cross=float("${CROSSFADE_SECONDS}")
print(total + duration - cross)
PY
)"
  fi

done

if [[ "${#SCENE_SOURCES[@]}" -eq 1 ]]; then
  VIDEO_LABEL="[v0]"
else
  VIDEO_LABEL="[vxf$(( ${#SCENE_SOURCES[@]} - 1 ))]"
fi

FILTER_COMPLEX="$(printf '%s;' "${FILTER_LINES[@]}")${VIDEO_LABEL}fps=${TARGET_FPS},format=yuv420p[vout]"
echo "Resolved filter graph:"
echo "$FILTER_COMPLEX"

ffmpeg -y \
  "${INPUT_ARGS[@]}" \
  -i "$NARRATION_AUDIO" \
  -filter_complex "$FILTER_COMPLEX" \
  -map '[vout]' -map "$(( ${#SCENE_SOURCES[@]} )):a:0" \
  -c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p \
  -c:a aac -b:a 160k -t "$NARRATION_DURATION" \
  "$OUTPUT_VIDEO"

echo "Rendered narrated film: $OUTPUT_VIDEO"
