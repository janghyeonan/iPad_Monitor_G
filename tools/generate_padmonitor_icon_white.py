from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new('RGBA', (SIZE, SIZE), (245, 247, 250, 255))
d = ImageDraw.Draw(img)

# Subtle white background depth
for y in range(SIZE):
    t = y / (SIZE - 1)
    v = int(250 - 10 * t)
    d.line([(0, y), (SIZE, y)], fill=(v, v, v, 255))

# Soft shadow under monitor
shadow = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sd = ImageDraw.Draw(shadow)
sd.ellipse((180, 760, 860, 960), fill=(0, 0, 0, 48))
shadow = shadow.filter(ImageFilter.GaussianBlur(40))
img.alpha_composite(shadow)

# Monitor frame
d = ImageDraw.Draw(img)
monitor_outer = (150, 190, 874, 690)
monitor_inner = (182, 222, 842, 658)
d.rounded_rectangle(monitor_outer, radius=52, fill=(52, 58, 68, 255))

# Generic monitor content (wallpaper + windows)
screen = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
sc = ImageDraw.Draw(screen)
for y in range(monitor_inner[1], monitor_inner[3]):
    t = (y - monitor_inner[1]) / (monitor_inner[3] - monitor_inner[1])
    r = int(76 + 45 * (1 - t))
    g = int(124 + 62 * (1 - t))
    b = int(210 + 35 * (1 - t))
    sc.line([(monitor_inner[0], y), (monitor_inner[2], y)], fill=(r, g, b, 255))

# Desktop dock-ish strip
sc.rounded_rectangle((210, 610, 814, 644), radius=12, fill=(245, 248, 255, 120))

# Window 1
sc.rounded_rectangle((230, 276, 528, 500), radius=18, fill=(248, 250, 255, 230))
sc.rounded_rectangle((230, 276, 528, 320), radius=18, fill=(230, 236, 247, 240))
sc.ellipse((248, 290, 260, 302), fill=(255, 95, 86, 255))
sc.ellipse((266, 290, 278, 302), fill=(255, 189, 46, 255))
sc.ellipse((284, 290, 296, 302), fill=(39, 201, 63, 255))
for i in range(6):
    y = 338 + i * 22
    sc.rounded_rectangle((252, y, 505, y + 10), radius=5, fill=(174, 186, 205, 220))

# Window 2
sc.rounded_rectangle((548, 336, 792, 560), radius=18, fill=(248, 250, 255, 220))
sc.rounded_rectangle((548, 336, 792, 376), radius=18, fill=(228, 236, 248, 236))
for i in range(5):
    y = 392 + i * 28
    sc.rounded_rectangle((570, y, 770, y + 12), radius=6, fill=(170, 185, 210, 220))

img.alpha_composite(screen)

# Screen highlight
d.rounded_rectangle((194, 234, 830, 290), radius=18, fill=(255, 255, 255, 40))

# iPad silhouette (as external display concept)
ipad_outer = (600, 360, 842, 852)
ipad_inner = (620, 390, 822, 824)
d.rounded_rectangle(ipad_outer, radius=34, fill=(34, 40, 48, 255))
for y in range(ipad_inner[1], ipad_inner[3]):
    t = (y - ipad_inner[1]) / (ipad_inner[3] - ipad_inner[1])
    d.line([(ipad_inner[0], y), (ipad_inner[2], y)], fill=(int(88 + 36*(1-t)), int(146 + 40*(1-t)), int(228 + 12*(1-t)), 255))

# USB-C connection cue
d.rounded_rectangle((504, 758, 656, 792), radius=10, fill=(206, 212, 226, 255))
d.rounded_rectangle((484, 748, 512, 804), radius=8, fill=(232, 236, 245, 255))

# Stand
d.rounded_rectangle((460, 688, 560, 838), radius=26, fill=(176, 183, 196, 255))
d.rounded_rectangle((340, 834, 686, 900), radius=30, fill=(162, 170, 184, 255))

# Slight polish blur
img = img.filter(ImageFilter.GaussianBlur(0.12))

out = Image.new('RGB', (SIZE, SIZE), (248, 249, 251))
out.paste(img, mask=img.split()[3])
out.save('/tmp/padmonitor-apple-style-white-1024.png', 'PNG')
print('/tmp/padmonitor-apple-style-white-1024.png')
