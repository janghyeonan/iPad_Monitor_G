from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
img = Image.new('RGB', (SIZE, SIZE), (255, 255, 255))
d = ImageDraw.Draw(img)

# ---- iPad Pro (top-left) ----
ipad_outer = (100, 110, 540, 430)
ipad_inner = (124, 134, 516, 406)
d.rounded_rectangle(ipad_outer, radius=30, fill=(18, 18, 20))
d.rounded_rectangle(ipad_inner, radius=20, fill=(145, 210, 255))

# ---- Nintendo Switch (bottom-right, angular, same height pieces) ----
sx1, sy1, sx2, sy2 = 455, 560, 945, 900
h = sy2 - sy1

# Left Joy-Con (angular rectangle)
left_joy = (sx1, sy1, sx1 + 120, sy2)
d.rounded_rectangle(left_joy, radius=14, fill=(0, 188, 255))

# Center screen block (same top/bottom as controllers)
screen_outer = (sx1 + 120, sy1, sx2 - 120, sy2)
screen_inner = (screen_outer[0] + 14, screen_outer[1] + 14, screen_outer[2] - 14, screen_outer[3] - 14)
d.rounded_rectangle(screen_outer, radius=10, fill=(32, 34, 38))
d.rounded_rectangle(screen_inner, radius=6, fill=(52, 56, 68))

# Right Joy-Con (angular rectangle)
right_joy = (sx2 - 120, sy1, sx2, sy2)
d.rounded_rectangle(right_joy, radius=14, fill=(255, 63, 72))

# Joy-Con details
cx_l, cy_l = left_joy[0] + 60, sy1 + 120
d.ellipse((cx_l - 24, cy_l - 24, cx_l + 24, cy_l + 24), fill=(28, 34, 42))
d.ellipse((cx_l - 12, sy2 - 92, cx_l + 12, sy2 - 68), fill=(28, 34, 42))

cx_r, cy_r = right_joy[0] + 60, sy1 + 230
d.ellipse((cx_r - 24, cy_r - 24, cx_r + 24, cy_r + 24), fill=(28, 34, 42))
btn_center = (right_joy[0] + 60, sy1 + 112)
for dx, dy in [(0, -18), (18, 0), (0, 18), (-18, 0)]:
    x, y = btn_center[0] + dx, btn_center[1] + dy
    d.ellipse((x - 9, y - 9, x + 9, y + 9), fill=(28, 34, 42))

# ---- Diagonal double arrows (black) ----
# Arrow 1: ↘ (top-left to bottom-right)
d.line((350, 450, 620, 640), fill=(20, 20, 20), width=22)
d.polygon([(620, 640), (575, 638), (604, 598)], fill=(20, 20, 20))
d.polygon([(350, 450), (395, 452), (366, 492)], fill=(20, 20, 20))

# Arrow 2: ↖ (bottom-right to top-left), slightly offset
d.line((680, 520, 410, 330), fill=(20, 20, 20), width=22)
d.polygon([(410, 330), (455, 332), (426, 372)], fill=(20, 20, 20))
d.polygon([(680, 520), (635, 518), (664, 478)], fill=(20, 20, 20))

# subtle polish
img = img.filter(ImageFilter.GaussianBlur(0.08))

out_path = '/tmp/padmonitor-custom-1024.png'
img.save(out_path, 'PNG')
print(out_path)
