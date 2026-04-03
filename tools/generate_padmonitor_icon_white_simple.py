from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (249, 250, 252, 255))
d = ImageDraw.Draw(img)

# Very subtle background tone
for y in range(SIZE):
    t = y / (SIZE - 1)
    v = int(252 - 8 * t)
    d.line([(0, y), (SIZE, y)], fill=(v, v, v, 255))

# Soft shadow
shadow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.ellipse((210, 770, 830, 950), fill=(0, 0, 0, 38))
shadow = shadow.filter(ImageFilter.GaussianBlur(34))
img.alpha_composite(shadow)

d = ImageDraw.Draw(img)

# Monitor
monitor_outer = (160, 210, 864, 690)
monitor_inner = (190, 240, 834, 660)
d.rounded_rectangle(monitor_outer, radius=52, fill=(45, 50, 58, 255))

# Simple screen gradient
screen = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sc = ImageDraw.Draw(screen)
for y in range(monitor_inner[1], monitor_inner[3]):
    t = (y - monitor_inner[1]) / (monitor_inner[3] - monitor_inner[1])
    r = int(84 + 38 * (1 - t))
    g = int(132 + 48 * (1 - t))
    b = int(206 + 28 * (1 - t))
    sc.line([(monitor_inner[0], y), (monitor_inner[2], y)], fill=(r, g, b, 255))

# One minimal card panel
sc.rounded_rectangle((290, 365, 734, 540), radius=24, fill=(245, 248, 255, 210))
sc.rounded_rectangle((320, 405, 704, 430), radius=10, fill=(175, 188, 210, 230))
sc.rounded_rectangle((320, 447, 640, 470), radius=10, fill=(186, 198, 218, 220))

img.alpha_composite(screen)
d = ImageDraw.Draw(img)

# Top highlight
d.rounded_rectangle((205, 255, 819, 298), radius=16, fill=(255, 255, 255, 38))

# iPad silhouette (simple)
ipad_outer = (620, 380, 838, 840)
ipad_inner = (638, 406, 820, 815)
d.rounded_rectangle(ipad_outer, radius=30, fill=(34, 39, 48, 255))
for y in range(ipad_inner[1], ipad_inner[3]):
    t = (y - ipad_inner[1]) / (ipad_inner[3] - ipad_inner[1])
    d.line([(ipad_inner[0], y), (ipad_inner[2], y)], fill=(int(94 + 30*(1-t)), int(150 + 28*(1-t)), int(224 + 10*(1-t)), 255))

# Minimal stand
d.rounded_rectangle((468, 690, 556, 828), radius=22, fill=(172, 180, 194, 255))
d.rounded_rectangle((360, 822, 672, 890), radius=28, fill=(160, 168, 183, 255))

img = img.filter(ImageFilter.GaussianBlur(0.10))
out = Image.new('RGB', (SIZE, SIZE), (250, 251, 253))
out.paste(img, mask=img.split()[3])
out.save('/tmp/padmonitor-apple-style-white-simple-1024.png', 'PNG')
print('/tmp/padmonitor-apple-style-white-simple-1024.png')
