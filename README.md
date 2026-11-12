# ADM — BMW Stand · Photobooth

Built from the BYD Ti 7 booth. Same backend (background removal on Replicate + Cloudflare R2 for the QR),
new ADM look and the two approved photo outcomes from Production Playbook 02B.

**Flow:** Begin → choose Option A (BMW X5) or Option B (BMW iX3) → countdown with stand-here outline →
review (Retake / Looks good) → background removed, guest placed into the chosen scene →
**AI regeneration** (Nano Banana redraws the guest standing in the chosen scene, keeps the face) → can switch X5/iX3 →
QR to download + Print → auto-reset (also resets after 90 s idle).

**Print:** 1200 × 1800 px = 4×6 in at 300 dpi. The ADM frame `assets/overlay.png` sits on top of every photo:
white keyline, BMW roundel top-right, black Abu Dhabi Motors footer. Regenerate it with `python3 make_overlay.py`,
or drop in a designer's 1200×1800 transparent PNG with the same name, then `python3 build.py`.

**AI regeneration:** `netlify/functions/harmonize.js` (start job + poll, so it never hits Netlify's time limit).
The booth sends the clean scene + the cut-out guest; the model draws a new photo of the guest standing by the car.
~$0.04 per photo on the same Replicate token. If it fails or takes longer than `AI_TIMEOUT_SECONDS` (60),
the guest gets the normal cut-out composite. Prompt is `CONFIG.AI_PROMPT` (`{MODEL}` = X5 / iX3);
`AI_ENDPOINT:""` turns it off; env `HARMONIZE_MODEL` swaps the model.

## Files
```
adm_photobooth.html            the kiosk — BUILT file, don't edit by hand
build.py                       rebuilds adm_photobooth.html from src/ + assets/
src/adm_photobooth.template.html   edit this
src/*_source.webp, ADM_lockup.png  original key visuals + logo
assets/                        cropped scenes, thumbnails, white logo pieces
netlify/functions/cutout.js    background removal (Replicate)
netlify/functions/harmonize.js AI regeneration: scene + guest -> new photo (Replicate google/nano-banana)
netlify/functions/upload.js    upload final photo to R2 -> QR link (folder "adm-bmw/")
make_overlay.py                draws assets/overlay.png (ADM frame)
```

## Tweaking on site
Placement and colour per scene are in `PLATES` in the template (`cx`, `feet`, `height`, `grade`).
Other switches are in `CONFIG` — e.g. `PRINT_ENABLED:false` for a QR-only booth, `COUNTDOWN_FROM`.
After any edit: `python3 build.py`.

## Deploy
Quickest (Netlify CLI, from this folder): `npm install`, `npx netlify-cli login`, `npx netlify-cli deploy --prod`.
Drag-and-drop on app.netlify.com does NOT work — it skips the functions.
Or: push this folder to GitHub, import into Netlify (no build command, publish dir `.`).

Then:
1. Set env vars from `.env.example` in Netlify. A new R2 bucket (`adm-photobooth`) with a public
   r2.dev URL is assumed — or reuse the BYD bucket by using its name and public URL.
2. Kiosk PC: Chrome with `--kiosk --kiosk-printing`, photo printer set as Windows default, paper 4×6.

> Licensing: Bria RMBG (the default model) is non-commercial unless licensed. For this commercial
> activation set `REPLICATE_MODEL` to a commercially-cleared remover (e.g. `851-labs/background-remover`).
