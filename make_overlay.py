"""Draws assets/overlay.png — the 1200x1800 frame laid over every booth photo.

Run from this folder:  python3 make_overlay.py   then   python3 build.py
A designer can also replace assets/overlay.png with their own 1200x1800 transparent PNG
(keep the photo area transparent) and just run build.py.
"""
import pathlib
from PIL import Image, ImageDraw

HERE = pathlib.Path(__file__).resolve().parent
A = HERE / "assets"
S = 2                                   # draw at 2x, scale down for clean edges
W, H, SCENEH = 1200, 1800, 1530
w, h, sh = W * S, H * S, SCENEH * S

roundel = Image.open(A / "bmw_roundel_white.png").convert("RGBA")
wordmark = Image.open(A / "adm_wordmark_white.png").convert("RGBA")

def fit(img, width):
    return img.resize((width, round(img.height * width / img.width)), Image.LANCZOS)

def alpha(img, a):
    img = img.copy()
    img.putalpha(img.getchannel("A").point(lambda v: int(v * a)))
    return img

ov = Image.new("RGBA", (w, h), (0, 0, 0, 0))
d = ImageDraw.Draw(ov)

# soft dark fade at the top so the corner roundel reads on bright skies/glass
fade = 300 * S
for y in range(fade):
    d.line([(0, y), (w, y)], fill=(0, 0, 0, int(115 * (1 - y / fade) ** 1.6)))

# fine white keyline around the scene
m, t = 48 * S, 2 * S
d.rectangle([m, m, w - m, sh - m], outline=(255, 255, 255, 150), width=t)

# BMW roundel, top-right inside the keyline
rs = 104 * S
ov.alpha_composite(fit(roundel, rs), (w - m - 34 * S - rs, m + 34 * S))

# footer: black band, hairline, roundel + Abu Dhabi Motors wordmark
d.rectangle([0, sh, w, h], fill=(0, 0, 0, 255))
d.line([(0, sh), (w, sh)], fill=(255, 255, 255, 70), width=2 * S)
# kept well inside the footer: borderless printing trims a few mm off every edge
rs, ry = 100 * S, sh + 50 * S
ov.alpha_composite(fit(roundel, rs), ((w - rs) // 2, ry))
wm = fit(wordmark, 360 * S)
ov.alpha_composite(wm, ((w - wm.width) // 2, ry + rs + 22 * S))

ov = ov.resize((W, H), Image.LANCZOS)
ov.save(A / "overlay.png", optimize=True)
print("wrote assets/overlay.png", ov.size)
