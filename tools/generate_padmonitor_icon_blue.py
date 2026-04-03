from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (16, 28, 52, 255))
d = ImageDraw.Draw(img)

# Brighter blue gradient background
for y in range(SIZE):
    t = y / (SIZE - 1)
    r = int(20 + 20 * (1 - t))
    g = int(58 + 65 * (1 - t))
    b = int(120 + 95 * (1 - t))
    d.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

# Soft radial light
glow = Image.new('L', (SIZE, SIZE), 0)
gd = ImageDraw.Draw(glow)
gd.ellipse((110, 80, 930, 900), fill=210)
glow = glow.filter(ImageFilter.GaussianBlur(120))
img = Image.composite(Image.new('RGBA', (SIZE, SIZE), (18, 46, 92, 255)), img, glow)
d = ImageDraw.Draw(img)

# Monitor shell
monitor_outer = (120, 210, 904, 720)
monitor_inner = (160, 250, 864, 680)
d.rounded_rectangle(monitor_outer, radius=64, fill=(29, 34, 46, 255))

# Monitor screen (bright cyan/blue)
screen = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(screen)
for y in range(monitor_inner[1], monitor_inner[3]):
    t = (y - monitor_inner[1]) / (monitor_inner[3] - monitor_inner[1])
    r = int(60 + 50 * (1 - t))
    g = int(145 + 85 * (1 - t))
    b = int(220 + 35 * (1 - t))
    sd.line([(monitor_inner[0], y), (monitor_inner[2], y)], fill=(r, g, b, 255))

sd.ellipse((230, 270, 780, 620), fill=(180, 235, 255, 80))
img.alpha_composite(screen)
d = ImageDraw.Draw(img)

# Highlight
d.rounded_rectangle((170, 260, 854, 330), radius=24, fill=(255, 255, 255, 48))

# iPad in front
ipad_outer = (590, 360, 840, 870)
ipad_inner = (612, 390, 818, 838)
d.rounded_rectangle(ipad_outer, radius=36, fill=(24, 28, 36, 255))

for y in range(ipad_inner[1], ipad_inner[3]):
    t = (y - ipad_inner[1]) / (ipad_inner[3] - ipad_inner[1])
    d.line([(ipad_inner[0], y), (ipad_inner[2], y)], fill=(int(78 + 48*(1-t)), int(170 + 55*(1-t)), int(248 + 7*(1-t)), 255))

# USB-C cue
d.rounded_rectangle((490, 760, 655, 792), radius=12, fill=(230, 236, 248, 230))
d.rounded_rectangle((470, 748, 500, 804), radius=9, fill=(246, 250, 255, 245))

# Stand
d.rounded_rectangle((460, 720, 565, 860), radius=28, fill=(197, 205, 220, 210))
d.rounded_rectangle((340, 850, 690, 912), radius=28, fill=(182, 191, 208, 220))

img = img.filter(ImageFilter.GaussianBlur(0.15))
out = Image.new('RGB', (SIZE, SIZE), (15, 30, 58))
out.paste(img, mask=img.split()[3])
out.save('/tmp/padmonitor-apple-style-blue-1024.png', 'PNG')
print('/tmp/padmonitor-apple-style-blue-1024.png')
