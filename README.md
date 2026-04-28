# Airline Logistics AI Demo Repo

A GitHub Pages-ready cinematic demo for an Airline Logistics Intelligence System covering cargo, baggage, people flow, damage detection, Gen BI control and dynamic cargo pricing.

## What is included

- `index.html` — cinematic browser player with scene sequencing and live overlays.
- `styles.css` — executive-grade visual styling.
- `script.js` — movie sequencing logic, playback speed control and Gen BI narrative prompts.
- `videos.config.js` — Google Drive video source map (empty placeholders to fill in).
- `videos.config.example.js` — copy-ready template with sample Drive link format.
- `assets/narration.txt` — final narration script.
- `assets/demo-narration.mp3` — generated narration audio.
- `scripts/generate_narration.py` — MP3 generator, similar to the reference repo pattern.
- `scripts/render_narrated_movie.sh` — FFmpeg script to render a narrated MP4 output.
- `.github/workflows/` — GitHub Actions to regenerate narration and render MP4.

## Connect videos from Google Drive (for GitHub Pages)

1. In Google Drive, open each video file → **Share** → set to **Anyone with the link (Viewer)**.
2. Copy `videos.config.example.js` to `videos.config.js`.
3. Paste each video share link into the matching key (for example `happy_people_flow`).
4. Commit and push `videos.config.js` with your links.
5. Publish with GitHub Pages and open the site.

The app automatically converts Drive sharing links like
`https://drive.google.com/file/d/<FILE_ID>/view?usp=sharing`
into direct URLs that the HTML5 video player can read.

## Recommended way to present

1. Upload this folder to a GitHub repository.
2. Enable GitHub Pages from repository settings.
3. Open the published `index.html` page.
4. Click **Play cinematic sequence**.

The web version is the strongest first output because it preserves all uploaded videos, controls playback speed, and keeps heavy files outside the GitHub 100 MB per-file limit by streaming from Drive.

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

- If a Google Drive URL is blank for a scene, the player falls back to local repo paths (`assets/originals/...`) for that scene.
- Keep file names/scene keys unchanged in `videos.config.js`; only replace the URL values.
- For best playback reliability, keep each Drive file in standard MP4/WebM formats.
- `scripts/render_narrated_movie.sh` defaults to `assets/originals/airline_logistics_system.webm`, but will auto-pick an available video from `assets/originals/` or `assets/` when that file is missing.
- If `videos.config.js` contains `airline_logistics_system`, the render script can automatically use that URL (Drive share links are converted to direct download URLs).
- You can override render inputs/outputs with environment variables: `SOURCE_VIDEO`, `NARRATION_AUDIO`, and `OUTPUT_VIDEO`.
- If the source file appears after a delay (for example another step is still copying it), set `WAIT_FOR_SOURCE_SECONDS=30` (or another value) before running the render script.
