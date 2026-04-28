# Airline Logistics AI Demo Repo

A GitHub Pages-ready cinematic demo for an Airline Logistics Intelligence System covering cargo, baggage, people flow, damage detection, Gen BI control and dynamic cargo pricing.

## What is included

- `index.html` — cinematic browser player with scene sequencing and live overlays.
- `styles.css` — executive-grade visual styling.
- `script.js` — movie sequencing logic, playback speed control and Gen BI narrative prompts.
- `assets/originals/` — all supplied videos, renamed safely for GitHub.
- `assets/narration.txt` — final narration script.
- `assets/demo-narration.mp3` — generated narration audio.
- `scripts/generate_narration.py` — MP3 generator, similar to the reference repo pattern.
- `scripts/render_narrated_movie.sh` — FFmpeg script to render a narrated MP4 output.
- `.github/workflows/` — GitHub Actions to regenerate narration and render MP4.

## Recommended way to present

1. Upload this folder to a GitHub repository.
2. Enable GitHub Pages from repository settings.
3. Open the published `index.html` page.
4. Click **Play cinematic sequence**.

The web version is the strongest first output because it preserves all uploaded videos, controls playback speed, and keeps heavy files under GitHub's 100 MB per-file limit.

## Movie sequence

1. Non-ideal cargo flow
2. Non-ideal baggage flow
3. Non-ideal people flow with detection
4. Cargo box mathematical damage detection
5. Passenger baggage mathematical damage detection
6. Airline logistics control tower with AI and Gen BI
7. Dynamic cargo pricing intelligence
8. Happy cargo flow
9. Happy baggage flow
10. Happy people flow

## Notes

- All supplied videos are under GitHub's 100 MB per-file hard limit.
- The happy baggage file is high bitrate, so it is preserved as-is in the web sequence instead of being locally transcoded.
- The GitHub Action can render a narrated MP4 from the repo if required.

## Packaging note

The main repo zip excludes only `assets/originals/happy_baggage_flow.mp4` to keep the repository package manageable in this environment. I have provided it as a separate add-on zip. To restore the full 10-video sequence, unzip the add-on and place `happy_baggage_flow.mp4` inside `assets/originals/` before pushing to GitHub.

If the add-on file is not present, the web player will skip that scene automatically and continue the cinematic sequence.
