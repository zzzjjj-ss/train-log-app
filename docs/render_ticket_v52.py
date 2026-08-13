# -*- coding: utf-8 -*-
from PIL import Image, ImageDraw, ImageFont
import math, random

random.seed(7)
SCALE = 16
X0, X1 = -10, 180
W = (X1-X0)*SCALE; H = 190*SCALE
LIGHT = (147,204,227); ARC = (116,190,223); DARK = (66,153,190)
BLACK = (0,0,0); RED = (205,45,45)
R = 6
SERIF = '/usr/share/fonts/opentype/noto/NotoSerifCJK-Regular.ttc'
SANS = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc'

def font(sz, sans=False):
    try: return ImageFont.truetype(SANS if sans else SERIF, int(sz*SCALE), index=2)
    except: return ImageFont.truetype(SANS if sans else SERIF, int(sz*SCALE))
def px(x): return int((x-X0)*SCALE)
def sz(x, y): return (px(x), int(y*SCALE))
def bez(p0,c1,c2,p3,n=80):
    pts=[]
    for i in range(n+1):
        t=i/n; mt=1-t
        x=mt**3*p0[0]+3*mt*mt*t*c1[0]+3*mt*t*t*c2[0]+t**3*p3[0]
        y=mt**3*p0[1]+3*mt*mt*t*c1[1]+3*mt*t*t*c2[1]+t**3*p3[1]
        pts.append(sz(x,y))
    return pts

def text(txt, x, y, size, color=BLACK, anchor='la', sans=False):
    d.text((px(x), int(y*SCALE)), txt, font=font(size,sans), fill=(color+(255,) if len(color)==3 else color), anchor=anchor)
def w(txt, size, sans=False):
    bb = font(size,sans).getbbox(txt); return (bb[2]-bb[0])/SCALE
def mixed(parts, x, y, anchor='la'):
    total = sum(w(t,s,sn) for t,s,sn in parts) + 0.3*max(0,len(parts)-1)
    if anchor == 'ra': x -= total
    cx = x
    for (t,s,sn) in parts:
        text(t, cx, y, s, sans=sn); cx += w(t,s,sn) + 0.3
    return total
def mixed_w(parts):
    return sum(w(t,s,sn) for t,s,sn in parts) + 0.3*max(0,len(parts)-1)
def arrow_under(center_x, bottom_y, width):
    # 主体上边改平（A、B y 对齐），倒角与主体右端重合
    body = [(5.57,173.49),(187.73,173.49),(199.17,177.14),(5.76,176.88)]
    chamfer = [(199.17,177.14),(171.94,167.67),(181.63,176.67)]
    xmin, xmax = 5.57, 199.17
    yref = 173.49
    s = width / (xmax - xmin)
    top_y = bottom_y + 3.5
    def T(x, y):
        return (center_x - width/2 + (x - xmin)*s, top_y + (y - yref)*s)
    d.polygon([sz(*T(x,y)) for x,y in body], fill=BLACK+(255,))
    d.polygon([sz(*T(x,y)) for x,y in chamfer], fill=BLACK+(255,))

def dashed_rect(x0,y0,x1,y1,color,width=1,dash=2.2):
    step = max(1, int(dash*SCALE)); lw = max(1, int(width*SCALE))
    for x in range(int(x0*SCALE), int(x1*SCALE), step*2):
        xa, xb = x, min(x+step, int(x1*SCALE))
        d.line([(xa, int(y0*SCALE)), (xb, int(y0*SCALE))], fill=color+(255,), width=lw)
        d.line([(xa, int(y1*SCALE)), (xb, int(y1*SCALE))], fill=color+(255,), width=lw)
    for y in range(int(y0*SCALE), int(y1*SCALE), step*2):
        ya, yb = y, min(y+step, int(y1*SCALE))
        d.line([(int(x0*SCALE), ya), (int(x0*SCALE), yb)], fill=color+(255,), width=lw)
        d.line([(int(x1*SCALE), ya), (int(x1*SCALE), yb)], fill=color+(255,), width=lw)
def fake_qr(x0,y0,x1,y1):
    n = 21; cell_w = (x1-x0)/n; cell_h = (y1-y0)/n
    for i in range(n):
        for j in range(n):
            cx = x0+i*cell_w; cy = y0+j*cell_h
            v = None
            for (fx,fy) in [(0,0),(n-7,0),(0,n-7)]:
                if fx<=i<=fx+6 and fy<=j<=fy+6:
                    ddx = max(abs(i-(fx+3)), abs(j-(fy+3)))
                    if ddx<=1 or ddx==3: v = True
                    elif ddx==2: v = False
            if v is None: v = random.random()<0.48
            if v: d.rectangle([sz(cx,cy), sz(cx+cell_w,cy+cell_h)], fill=(0,0,0,255))

img = Image.new('RGBA', (W,H), (0,0,0,0))
d = ImageDraw.Draw(img)

curve = bez((160.82,146.64),(103.61,134.62),(80,130),(60,130))
curve += bez((60,130),(27.75,130.7),(23.53,150.48),(31.44,165.79))
d.rounded_rectangle([sz(9,93), sz(162,180)], radius=int(R*SCALE), fill=LIGHT+(255,))
arc_poly = curve + [sz(31.44,167), sz(162,167), sz(162,146.64)]
d.polygon(arc_poly, fill=ARC+(255,))
band=[sz(9,167),sz(162,167),sz(162,174)]
for i in range(16):
    t=i/15; ang=math.radians(t*90); band.append(sz(156+6*math.cos(ang),174+6*math.sin(ang)))
for i in range(16):
    t=i/15; ang=math.radians(90+t*90); band.append(sz(15+6*math.cos(ang),174+6*math.sin(ang)))
d.polygon(band, fill=DARK+(255,))

# ==== v36 ====
text('R093443', 12, 94, 6.5, (205,45,45,215), sans=True)
text('检票口22', 159, 94, 6, BLACK, anchor='ra')
BASE = 99; big = 9.5; small = 5.5
wc = w('C2565', big)
xc0 = 86 - wc/2; xc1 = 86 + wc/2
ws_bj = w('北京南', big, sans=True) + 0.5 + w('站', small)
ws_tj = w('天　津', big, sans=True) + 0.5 + w('站', small)
x_bj = (xc0 + 9 - ws_bj) / 2
x_tj = (162 + xc1 - ws_tj) / 2
text('北京南', x_bj, BASE, big, BLACK, sans=True)
text('站', x_bj + w('北京南',big,True) + 0.5, BASE + (big-small), small, BLACK)
text('C2565', 86, BASE, big, BLACK, anchor='ma')
text('天　津', x_tj, BASE, big, BLACK, sans=True)
text('站', x_tj + w('天　津',big,True) + 0.5, BASE + (big-small), small, BLACK)
arrow_under(86, BASE + big, wc)
# 拼音居中于站名主体正下方
text('Beijingnan', x_bj + (w('北京南',big,True) - w('Beijingnan',4))/2, 113.5, 4, BLACK)
text('Tianjin', x_tj + (w('天　津',big,True) - w('Tianjin',4))/2, 113.5, 4, BLACK)
L = 20
mixed([('2019',6.5,True),('年',4.5,False),('04',6.5,True),('月',4.5,False),('03',6.5,True),('日',4.5,False),(' ',5,False),('09:36',6.5,True),('开',4.5,False)], L, 119)
mixed([('02',6.5,True),('车',4.5,False),(' ',5,False),('03C',6.5,True),('号',4.5,False)], 138, 119, anchor='ra')
mixed([('￥',5,False),('54.5',6,True),('元',4.5,False)], L, 126.5)
net_x = L + mixed_w([('2019',6.5,True),('年',4.5,False),('04',6.5,True),('月',4.5,False),('03',6.5,True),('日',4.5,False),(' ',5,False)])
text('网', net_x, 126.5, 5, BLACK)
text('二等座', 138, 126.5, 5, BLACK, anchor='ra')
text('限乘当日当次车', L, 133.5, 4.5, BLACK)
mixed([('2302051998****156X',6,True),('裴瑜丽',6,False)], L, 143)
line1 = '买票请到12306发货请到95306'
line2 = '中国铁路祝您旅途愉快'
sz_t = 3.8; gap = 0.6; p = 1
w1 = w(line1, sz_t); w2 = w(line2, sz_t)
h1 = (font(sz_t).getbbox(line1)[3] - font(sz_t).getbbox(line1)[1])/SCALE
box_w = max(w1, w2) + 2*p
box_h = h1*2 + gap + 2*p
box_x0 = 28.0; box_y0 = 154.0
cx = 36.5 + box_w/2  # 文字中心固定(v52原值)，只移边框
bx1 = box_x0 + box_w + 24
ly1 = box_y0 + 0.2
ly2 = ly1 + h1 + gap
by1 = 165.7
dashed_rect(box_x0, box_y0, bx1, by1, BLACK, width=0.5)
text(line1, cx - w1/2, ly1, sz_t, BLACK)
text(line2, cx - w2/2, ly2, sz_t, BLACK)
fake_qr(138, 144, 160, 166)
text('10010301110403F067846 北京南售', 12, 169, 5, BLACK)

img = img.resize((W//2, H//2), Image.LANCZOS)
img.save('/home/zhang/Desktop/车票模板-final-v52.png')
print('saved v52', W, 'x', H)
