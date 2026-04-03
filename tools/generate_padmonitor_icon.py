from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (8, 10, 14, 255))
d = ImageDraw.Draw(img)

# Background gradient + vignette
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = int(10 + 20 * (1 - t))
    g = int(12 + 24 * (1 - t))
    b = int(18 + 35 * (1 - t))
    d.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

vignette = Image.new('L', (SIZE, SIZE), 0)
vd = ImageDraw.Draw(vignette)
vd.ellipse((-180, -120, SIZE + 180, SIZE + 220), fill=200)
vignette = vignette.filter(ImageFilter.GaussianBlur(120))
img = Image.composite(img, Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 255)), vignette)
d = ImageDraw.Draw(img)

# Monitor body
monitor_outer = (120, 210, 904, 720)
monitor_inner = (160, 250, 864, 680)
d.rounded_rectangle(monitor_outer, radius=64, fill=(30, 34, 42, 255))

# Monitor screen gradient
screen = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(screen)
for y in range(monitor_inner[1], monitor_inner[3]):
    t = (y - monitor_inner[1]) / (monitor_inner[3] - monitor_inner[1])
    r = int(28 + 35 * (1 - t))
    g = int(75 + 70 * (1 - t))
    b = int(125 + 95 * (1 - t))
    sd.line([(monitor_inner[0], y), (monitor_inner[2], y)], fill=(r, g, b, 255))

# Soft glow on screen
sd.ellipse((220, 280, 760, 620), fill=(130, 210, 255, 55))
img.alpha_composite(screen)

d = ImageDraw.Draw(img)
# Screen highlight
d.rounded_rectangle((170, 260, 854, 330), radius=24, fill=(255, 255, 255, 30))

# iPad silhouette in front (sidecar concept)
ipad_outer = (590, 360, 840, 870)
ipad_inner = (612, 390, 818, 838)
d.rounded_rectangle(ipad_outer, radius=36, fill=(20, 22, 28, 255))
d.rounded_rectangle(ipad_inner, radius=26, fill=(42, 132, 210, 255))
# iPad screen shine
for y in range(ipad_inner[1], ipad_inner[3]):
    t = (y - ipad_inner[1]) / (ipad_inner[3] - ipad_inner[1])
    d.line([(ipad_inner[0], y), (ipad_inner[2], y)], fill=(int(55 + 40*(1-t)), int(140 + 50*(1-t)), int(220 + 25*(1-t)), 255))

# USB-C cable cue
d.rounded_rectangle((490, 760, 655, 792), radius=12, fill=(215, 220, 230, 220))
d.rounded_rectangle((470, 748, 500, 804), radius=9, fill=(245, 248, 255, 240))

# Monitor stand
d.rounded_rectangle((460, 720, 565, 860), radius=28, fill=(190, 196, 208, 200))
d.rounded_rectangle((340, 850, 690, 912), radius=28, fill=(175, 182, 194, 210))

# Global polish
img = img.filter(ImageFilter.GaussianBlur(0.2))

# Save with solid background (no alpha)
out = Image.new('RGB', (SIZE, SIZE), (0, 0, 0))
out.paste(img, mask=img.split()[3])
out.save('/tmp/padmonitor-apple-style-1024.png', 'PNG')
print('/tmp/padmonitor-apple-style-1024.png')
