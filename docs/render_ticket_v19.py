#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
车票模板最终版 v19（用户已确认）— Python/PIL 参考实现
用法: python3 render_ticket_v19.py [输出路径]
结构规范见 车票模板-final-v19.md
"""
import math
import sys
from PIL import Image, ImageDraw

# ---------- 画布 ----------
SCALE = 3
X0, X1 = -10, 180          # x 方向留出连接条凸出空间
W = (X1 - X0) * SCALE
H = 190 * SCALE

# ---------- 颜色（用户确认三色） ----------
LIGHT = (147, 204, 227)    # 票面浅蓝
ARC = (116, 190, 223)      # 弧面中浅蓝
DARK = (66, 153, 190)      # 底部深蓝

# ---------- 几何 ----------
R = 6                      # 统一圆角半径
TAG_H, TAG_W = 12, 2       # 连接条统一尺寸
Y_TOP, Y_BOT = 102.68, 154.58


def px(x: float) -> int:
    return int((x - X0) * SCALE)


def sz(x: float, y: float):
    return (px(x), int(y * SCALE))


def bez(p0, c1, c2, p3, n=80):
    """三次贝塞尔采样点"""
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3 * p0[0] + 3 * mt * mt * t * c1[0] + 3 * mt * t * t * c2[0] + t**3 * p3[0]
        y = mt**3 * p0[1] + 3 * mt * mt * t * c1[1] + 3 * mt * t * t * c2[1] + t**3 * p3[1]
        pts.append(sz(x, y))
    return pts


def render(out: str) -> None:
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))  # 透明背景
    d = ImageDraw.Draw(img)

    # 1. 票面：横平竖直矩形 + 圆角 r6
    curve = bez((160.82, 146.64), (103.61, 134.62), (80, 130), (60, 130))
    curve += bez((60, 130), (27.75, 130.7), (23.53, 150.48), (31.44, 165.79))
    d.rounded_rectangle([sz(9, 93), sz(162, 180)], radius=int(R * SCALE), fill=LIGHT + (255,))

    # 2. 弧面：弧线 -> 左端向下 y167 -> 横到最右 x162 -> 右缘向上闭合
    arc_poly = curve + [sz(31.44, 167), sz(162, 167), sz(162, 146.64)]
    d.polygon(arc_poly, fill=ARC + (255,))

    # 3. 底部色带：顶部直角，底部圆角 r6
    band = [sz(9, 167), sz(162, 167), sz(162, 174)]
    for i in range(16):
        t = i / 15
        ang = math.radians(t * 90)
        band.append(sz(156 + 6 * math.cos(ang), 174 + 6 * math.sin(ang)))
    for i in range(16):
        t = i / 15
        ang = math.radians(90 + t * 90)
        band.append(sz(15 + 6 * math.cos(ang), 174 + 6 * math.sin(ang)))
    d.polygon(band, fill=DARK + (255,))

    # 4. 连接条：左右各上下一个，统一尺寸，颜色=接合处
    tags = [
        (162, Y_TOP, 162 + TAG_W, Y_TOP + TAG_H, LIGHT),   # 右上-浅蓝(接票面)
        (162, Y_BOT, 162 + TAG_W, Y_BOT + TAG_H, ARC),     # 右下-中浅蓝(接弧面)
        (9 - TAG_W, Y_TOP, 9, Y_TOP + TAG_H, LIGHT),       # 左上-浅蓝
        (9 - TAG_W, Y_BOT, 9, Y_BOT + TAG_H, LIGHT),       # 左下-浅蓝
    ]
    for (x0, y0, x1, y1, c) in tags:
        d.rectangle([sz(x0, y0), sz(x1, y1)], fill=c + (255,))

    img.resize((int(W * 0.8), int(H * 0.8)), Image.LANCZOS).save(out)
    print(f'saved: {out}')


if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else '/tmp/ticket_v19_final.png'
    render(out)
