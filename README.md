# ADM — BMW Stand · Photobooth

Built from the BYD Ti 7 booth. Same backend (background removal on Replicate + Cloudflare R2 for the QR),
new ADM look and the two approved photo outcomes from Production Playbook 02B.

**Flow:** Begin → choose Option A (BMW X5) or Option B (BMW iX3) → countdown with stand-here outline →
review (Retake / Looks good) → background removed, guest placed into the chosen scene (can switch X5/iX3) →
QR to download + Print → auto-reset (also resets after 90 s idle).

**Print:** 1200 × 1800 px = 4×6 in at 300 dpi. Scene on top, black Abu Dhabi Motors footer
(BMW roundel + wordmark) at the bottom.

## Files
```
adm_photobooth.html            the kiosk — BUILT file, don't edit by hand
build.py                       rebuilds adm_photobooth.html from src/ + assets/
src/adm_photobooth.template.html   edit this
src/*_source.webp, ADM_lockup.png  original key visuals + logo
assets/                        cropped scenes, thumbnails, white logo pieces
netlify/functions/cutout.js    background removal (Replicate)
netlify/functions/upload.js    upload final photo to R2 -> QR link (folder "adm-bmw/")
```

## Tweaking on site
Placement and colour per scene are in `PLATES` in the template (`cx`, `feet`, `height`, `grade`).
Other switches are in `CONFIG` — e.g. `PRINT_ENABLED:false` for a QR-only booth, `COUNTDOWN_FROM`.
After any edit: `python3 build.py`.

## Deploy (same as BYD)
1. Push this folder to GitHub, import into Netlify (no build command, publish dir `.`).
2. Set env vars from `.env.example` in Netlify. A new R2 bucket (`adm-photobooth`) with a public
   r2.dev URL is assumed — or reuse the BYD bucket by using its name and public URL.
3. Kiosk PC: Chrome with `--kiosk --kiosk-printing`, photo printer set as Windows default, paper 4×6.

> Licensing: Bria RMBG (the default model) is non-commercial unless licensed. For this commercial
> activation set `REPLICATE_MODEL` to a commercially-cleared remover (e.g. `851-labs/background-remover`).
