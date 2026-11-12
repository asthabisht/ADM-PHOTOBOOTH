"""Build the kiosk page: inlines images + the QR library into adm_photobooth.html.

Run from this folder:   python3 build.py
Edit src/adm_photobooth.template.html, never the built adm_photobooth.html.
"""
import base64, pathlib, re

HERE = pathlib.Path(__file__).resolve().parent
A = HERE / "assets"

def uri(name, mime):
    return f"data:{mime};base64," + base64.b64encode((A / name).read_bytes()).decode()

html = (HERE / "src" / "adm_photobooth.template.html").read_text()
qr = (HERE / "src" / "qrcode.min.js").read_text()
html = html.replace("/*QRCODE_LIB*/", qr)
for key, (name, mime) in {
    "PLATE_A": ("plate_a.jpg", "image/jpeg"),
    "PLATE_B": ("plate_b.jpg", "image/jpeg"),
    "THUMB_A": ("plate_a_thumb.jpg", "image/jpeg"),
    "THUMB_B": ("plate_b_thumb.jpg", "image/jpeg"),
    "ROUNDEL": ("bmw_roundel_white.png", "image/png"),
    "WORDMARK": ("adm_wordmark_white.png", "image/png"),
    "LOCKUP": ("adm_lockup_white.png", "image/png"),
    "OVERLAY": ("overlay.png", "image/png"),
}.items():
    html = html.replace("{{" + key + "}}", uri(name, mime))
left = re.findall(r"\{\{[A-Z_]+\}\}", html)
assert not left, f"unfilled placeholders: {left}"
out = HERE / "adm_photobooth.html"
out.write_text(html)
print(f"built {out.name}  ({out.stat().st_size // 1024} KB)")
