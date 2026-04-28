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
If a Drive link fails at runtime, the player now automatically tries local fallback files in this order:
`assets/originals/<scene_key>.mp4|webm|mov|m4v`, then `assets/<scene_key>.<ext>`.

## Two-step render flow for large source videos (recommended)

When videos are too large to keep in git, render in two steps:

1. **Sync all scene videos from Drive to local assets**
   ```bash
   bash scripts/sync_drive_videos.sh
   ```
2. **Render narrated MP4 using local copies + narration MP3**
   ```bash
   bash scripts/render_narrated_movie.sh
   ```

This avoids remote-stream instability during FFmpeg render and guarantees the narration is aligned against local scene files.

### GitHub Actions buttons

You should now see **two separate Run workflow buttons** in GitHub Actions:

1. **Sync Drive Videos** — downloads scene videos from `videos.config.js` into `assets/originals/`.
2. **Render narrated MP4** — builds `assets/rendered/airline-logistics-ai-demo-narrated.mp4` from local scene files + narration audio.

After **Sync Drive Videos** completes successfully, you should see files like:
`assets/originals/non_ideal_box_flow.mp4`, `assets/originals/non_ideal_baggage_flow.mp4`, etc.
(`assets/originals`, not `assets/orginals`).

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

- The browser cannot enumerate an entire Google Drive folder directly from static GitHub Pages code. You should map one URL per scene key in `videos.config.js` (or pre-download files into `assets/originals/` with exact scene-key filenames).
- Use `scripts/sync_drive_videos.sh` before rendering so FFmpeg works from local files rather than live network URLs.
- GitHub does not allow very large binaries in normal git history (typically 100 MB per file), so large video sets should stay in Drive/CDN or use Git LFS/Releases artifacts.
- Keep file names/scene keys unchanged in `videos.config.js`; only replace the URL values.
- For best playback reliability, keep each Drive file in standard MP4/WebM formats.
- `scripts/render_narrated_movie.sh` auto-picks each scene video from `assets/originals/` first, then `assets/`, checking `mp4`, `webm`, `mov`, and `m4v`.
- You can override sync behavior with `DEST_DIR`, `VIDEO_EXT`, and `FORCE_DOWNLOAD=1` when running `scripts/sync_drive_videos.sh`.
- You can override render inputs/outputs with environment variables: `NARRATION_AUDIO` and `OUTPUT_VIDEO`.
