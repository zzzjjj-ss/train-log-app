import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:intl/intl.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:qr/qr.dart';

import '../data/database.dart';

/// 车票上所有可覆盖的文字元素（编辑模式逐个可改，留空 = 保持原数据）
const List<({String key, String label})> kTicketTextFieldKeys = [
  (key: 'trainNumber', label: '车次'),
  (key: 'departureStation', label: '出发站'),
  (key: 'arrivalStation', label: '到达站'),
  (key: 'date', label: '日期'),
  (key: 'departureTime', label: '发车时间'),
  (key: 'carriage', label: '车厢'),
  (key: 'seatNumber', label: '座位号'),
  (key: 'seatClass', label: '席别'),
  (key: 'price', label: '票价'),
  (key: 'gate', label: '检票口'),
  (key: 'buyMarks', label: '购票标记'),
  (key: 'serialNumber', label: '流水号'),
  (key: 'ticketNumber', label: '编号'),
  (key: 'saleLocation', label: '发售地'),
  (key: 'idCard', label: '身份证'),
  (key: 'passengerName', label: '姓名'),
  (key: 'limitNote', label: '限乘提示'),
  (key: 'adLine1', label: '广告第一行'),
  (key: 'adLine2', label: '广告第二行'),
];

/// 车票卡片：按定稿模板（几何 v19 + 文字排版 v52）渲染一条运转记录。
///
/// 画布采用模板 viewBox：宽 190（含连接条凸出）、高 190，
/// 票面实际区域 (9,93)-(162,180)，圆角 r6，透明背景。
class TicketCard extends StatelessWidget {
  final TrainLog log;
  final double width;

  /// 身份证显示串（如 2302051998****156X，由设置页拼好传入）
  final String idCardText;

  /// 乘车人姓名（设置页）
  final String passengerName;

  /// 文字覆盖（自定义车票显示，不改原记录）：字段key→自定义文本
  final Map<String, String>? textOverrides;

  /// 背景图（已解码），null 用默认浅蓝
  final ui.Image? bgImage;

  /// 背景映射模式：cover / contain / fill
  final String bgMode;

  /// 绘制完成后回调（各文字元素的 viewBox 区域，编辑模式红框用）
  final void Function(Map<String, Rect>)? onTextRects;

  const TicketCard({
    super.key,
    required this.log,
    this.width = 320,
    this.idCardText = '',
    this.passengerName = '',
    this.textOverrides,
    this.bgImage,
    this.bgMode = 'cover',
    this.onTextRects,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * _TicketPainter._vh / _TicketPainter._vw,
      child: CustomPaint(
        painter: _TicketPainter(
          log,
          idCardText,
          passengerName,
          textOverrides ?? const {},
          bgImage,
          bgMode,
          onTextRects,
        ),
      ),
    );
  }
}

/// 模板三色（定稿）
const _kLight = Color(0xFF93CCE3); // 票面浅蓝
const _kArc = Color(0xFF74BEDF); // 弧面中浅蓝
const _kDark = Color(0xFF4299BE); // 底部深蓝
const _kInk = Color(0xFF000000); // 文字黑
const _kRed = Color(0x80CD2D2D); // 流水号半透明红（α215）

class _TicketPainter extends CustomPainter {
  final TrainLog log;
  final String idCardText;
  final String passengerName;
  final Map<String, String> textOverrides;
  final ui.Image? bgImage;
  final String bgMode;

  /// 各文字元素的 viewBox 区域（编辑模式红框定位），paint 时更新
  final Map<String, Rect> textRects = {};

  /// 绘制完成后回调（key → viewBox Rect）
  final void Function(Map<String, Rect>)? onTextRects;

  _TicketPainter(
    this.log, [
    this.idCardText = '',
    this.passengerName = '',
    this.textOverrides = const {},
    this.bgImage,
    this.bgMode = 'cover',
    this.onTextRects,
  ]);

  /// 读取覆盖文字：有覆盖值用之，否则回退到原数据
  String _ov(String key, String fallback) =>
      textOverrides[key]?.isNotEmpty == true ? textOverrides[key]! : fallback;

  /// 记录某文字元素的 viewBox 区域（供编辑模式画红框）
  void _mark(String key, TextPainter tp, double xv, double yv, double scaleX,
      double scaleY) {
    textRects[key] = Rect.fromLTWH(
      xv,
      yv,
      tp.width / scaleX,
      tp.height / scaleY,
    );
  }

  static const _vw = 190.0; // viewBox 宽（x: -10..180）
  // 裁剪画布：y 只保留内容区 88..186（98 高），去掉上方大片空白
  static const _vy0 = 88.0;
  static const _vh = 98.0;

  // 票面
  static const _fx0 = 9.0, _fy0 = 93.0, _fx1 = 162.0, _fy1 = 180.0;
  static const _r = 6.0; // 圆角

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _vw;
    final sy = size.height / _vh;
    double X(double v) => v * sx;
    double Y(double v) => (v - _vy0) * sy;

    _paintFace(canvas, X, Y); // 票面 + 弧面 + 色带 + 连接条
    _paintTexts(canvas, size, X, Y); // 文字
    _paintArrow(canvas, size, X, Y); // 箭头
    _paintDashedBox(canvas, size, X, Y); // 虚线框
    _paintQr(canvas, X, Y); // 二维码

    // 色带：编号 + 空格 + 发售地（黑字）
    var bx = 14.0;
    final tn = _ov('ticketNumber', log.ticketNumber);
    if (tn.isNotEmpty) {
      final tnTp = _tp(tn, 5, sx, family: 'NotoSerifSC');
      _mark('ticketNumber', tnTp, bx, 170, X(1) - X(0), Y(1) - Y(0));
      tnTp.paint(canvas, Offset(X(bx), Y(170)));
      bx += tnTp.width / (X(1) - X(0)) + 1;
    }
    final sl = _ov('saleLocation', log.saleLocation);
    if (sl.isNotEmpty) {
      final slTp = _tp(sl, 5, sx, family: 'NotoSerifSC');
      _mark('saleLocation', slTp, bx, 170, X(1) - X(0), Y(1) - Y(0));
      slTp.paint(canvas, Offset(X(bx), Y(170)));
    }
  }

  // ---------------- 几何 ----------------

  void _paintFace(Canvas canvas, double Function(double) X, double Function(double) Y) {
    // 票面区域
    final faceRect = Rect.fromLTRB(X(_fx0), Y(_fy0), X(_fx1), Y(_fy1));
    final face = RRect.fromRectAndRadius(faceRect, Radius.circular(X(_r)));

    if (bgImage != null) {
      // 自定义背景图：裁剪进圆角票面，cover/contain/fill 映射
      canvas.save();
      canvas.clipRRect(face);
      final imgW = bgImage!.width.toDouble();
      final imgH = bgImage!.height.toDouble();
      if (bgMode == 'fill') {
        canvas.drawImageRect(
          bgImage!,
          Rect.fromLTWH(0, 0, imgW, imgH),
          faceRect,
          Paint()..filterQuality = FilterQuality.medium,
        );
      } else {
        final scale = bgMode == 'contain'
            ? min(faceRect.width / imgW, faceRect.height / imgH)
            : max(faceRect.width / imgW, faceRect.height / imgH);
        final drawW = imgW * scale;
        final drawH = imgH * scale;
        if (bgMode == 'contain') {
          // contain：完整显示，居中（可能留边）
          final dst = Rect.fromLTWH(
            faceRect.center.dx - drawW / 2,
            faceRect.center.dy - drawH / 2,
            drawW,
            drawH,
          );
          canvas.drawImageRect(
            bgImage!,
            Rect.fromLTWH(0, 0, imgW, imgH),
            dst,
            Paint()..filterQuality = FilterQuality.medium,
          );
        } else {
          // cover：等比放大填满，从图中心裁剪
          final src = Rect.fromLTWH(
            (imgW - faceRect.width / scale) / 2,
            (imgH - faceRect.height / scale) / 2,
            faceRect.width / scale,
            faceRect.height / scale,
          );
          canvas.drawImageRect(bgImage!, src, faceRect,
              Paint()..filterQuality = FilterQuality.medium);
        }
      }
      canvas.restore();
    } else {
      // 默认浅蓝票面
      canvas.drawRRect(face, Paint()..color = _kLight);
    }

    // 弧面：弧线 + [(31.44,167),(162,167),(162,146.64)] 闭合
    final arcPath = Path()
      ..moveTo(X(160.82), Y(146.64))
      ..cubicTo(X(103.61), Y(134.62), X(80), Y(130), X(60), Y(130))
      ..cubicTo(X(27.75), Y(130.7), X(23.53), Y(150.48), X(31.44), Y(165.79))
      ..lineTo(X(31.44), Y(167))
      ..lineTo(X(162), Y(167))
      ..lineTo(X(162), Y(146.64))
      ..close();
    canvas.drawPath(arcPath, Paint()..color = _kArc);

    // 底部色带：顶部直角、底部圆角 r6（quadTo 平滑圆角）
    final band = Path()
      ..moveTo(X(9), Y(167))
      ..lineTo(X(162), Y(167))
      ..lineTo(X(162), Y(174))
      ..quadraticBezierTo(X(162), Y(180), X(156), Y(180)) // 右下圆角
      ..lineTo(X(15), Y(180))
      ..quadraticBezierTo(X(9), Y(180), X(9), Y(174)) // 左下圆角
      ..close();
    canvas.drawPath(band, Paint()..color = _kDark);

    // 连接条：左右各上下一个，高12 凸出2，颜色=接合处
    const tagTop = 102.68, tagBot = 154.58, tagH = 12.0, tagW = 2.0;
    final tags = <Rect>[
      Rect.fromLTRB(X(162), Y(tagTop), X(162 + tagW), Y(tagTop + tagH)),
      Rect.fromLTRB(X(9 - tagW), Y(tagTop), X(9), Y(tagTop + tagH)),
      Rect.fromLTRB(X(9 - tagW), Y(tagBot), X(9), Y(tagBot + tagH)),
    ];
    final tagPaint = Paint()..color = _kLight;
    for (final r in tags) {
      canvas.drawRect(r, tagPaint);
    }
    // 右下连接条接弧面 → 中浅蓝
    canvas.drawRect(
      Rect.fromLTRB(X(162), Y(tagBot), X(162 + tagW), Y(tagBot + tagH)),
      Paint()..color = _kArc,
    );
  }

  // ---------------- 文字 ----------------

  TextPainter _tp(String text, double size, double sx,
      {Color color = _kInk,
      FontWeight weight = FontWeight.normal,
      String family = 'NotoSansSC'}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size * sx,
          color: color,
          fontWeight: weight,
          fontFamily: family,
        ),
      ),
      textDirection: painting.TextDirection.ltr,
    )..layout();
  }

  /// 富文本：segment = (文本, 字号, 字重, 是否宋体)。
  /// 逐个 segment 绘制，小字相对行内最大字号**底部对齐**（解决小字偏上）。
  double _drawRich(
      Canvas canvas,
      List<(String, double, FontWeight, bool)> segs,
      double x,
      double y,
      double sx,
      double Function(double) X,
      double Function(double) Y,
      {String? key}) {
    final scaleX = X(1) - X(0);
    var cx = x;
    var total = 0.0;
    final maxSize = segs.fold(0.0, (m, s) => max(m, s.$2));
    for (final s in segs) {
      final tp = _tp(s.$1, s.$2, sx,
          weight: s.$3, family: s.$4 ? 'NotoSerifSC' : 'NotoSansSC');
      // 小字垂直居中于大字（不偏高不偏低）
      tp.paint(canvas, Offset(X(cx), Y(y + (maxSize - s.$2) * 0.58)));
      final w = tp.width / scaleX;
      cx += w + 0.3;
      total += w + 0.3;
    }
    if (key != null) {
      textRects[key] = Rect.fromLTWH(x, y, total - 0.3, maxSize * 1.3);
    }
    return total - 0.3;
  }

  /// 富文本总宽度（viewBox 单位）
  double _richW(List<(String, double, FontWeight, bool)> segs, double sx,
      double scaleX) {
    return segs.fold(0.0, (sum, s) =>
            sum + _tp(s.$1, s.$2, sx, weight: s.$3, family: s.$4 ? 'NotoSerifSC' : 'NotoSansSC').width / scaleX) +
        0.3 * (segs.length - 1);
  }

  void _paintTexts(Canvas canvas, Size size,
      double Function(double) X, double Function(double) Y) {
    final sx = size.width / _vw;
    final scaleX = X(1) - X(0);
    final scaleY = Y(1) - Y(0);

    // L1 流水号（半透明红）+ 检票口
    if (_ov('serialNumber', log.serialNumber).isNotEmpty) {
      final snTp = _tp(_ov('serialNumber', log.serialNumber), 6.5, sx,
          color: _kRed);
      _mark('serialNumber', snTp, 14, 96.5, scaleX, scaleY);
      snTp.paint(canvas, Offset(X(14), Y(96.5)));
    }
    if (_ov('gate', log.gate).isNotEmpty) {
      final gate = _tp('检票口${_ov('gate', log.gate)}', 6, sx, family: 'NotoSerifSC');
      _mark('gate', gate, 157 - gate.width / scaleX, 96.5, scaleX, scaleY);
      gate.paint(canvas, Offset(X(157) - gate.width, Y(96.5)));
    }

    // L2 站名 + 车次（站名以"站"结尾时拆"站"小字）
    final dep = _ov('departureStation', log.departureStation).trim();
    final arr = _ov('arrivalStation', log.arrivalStation).trim();
    // 站名主体：2 字时中间加空格，视觉中心平衡（如"天津"→"天 津"）
    final depRaw = dep.endsWith('站') ? dep.substring(0, dep.length - 1) : dep;
    final depMain = depRaw.length == 2 ? '${depRaw[0]}　${depRaw[1]}' : depRaw;
    final depTail = '站'; // 模板固定显示站字小字
    final arrRaw = arr.endsWith('站') ? arr.substring(0, arr.length - 1) : arr;
    final arrMain = arrRaw.length == 2 ? '${arrRaw[0]}　${arrRaw[1]}' : arrRaw;
    final arrTail = '站';
    final trainNo = _ov('trainNumber', log.trainNumber).trim();

    final tMain = _tp(depMain, 9.5, sx);
    final wMain = tMain.width / scaleX;
    final wTail = depTail.isEmpty ? 0.0 : (_tp(depTail, 5.5, sx, family: 'NotoSerifSC').width / scaleX + 1.5);
    final ws = wMain + wTail;

    final tc = _tp(trainNo, 9.5, sx, family: 'NotoSerifSC');
    final wc = tc.width / scaleX;
    final xc0 = 86 - wc / 2;
    final xc1 = 86 + wc / 2;

    // 出发站（左）：到票边距 = 到车次距
    final xDep = (xc0 + 9 - ws) / 2;
    _mark('departureStation', tMain, xDep, 104, scaleX, scaleY);
    tMain.paint(canvas, Offset(X(xDep), Y(104)));
    if (depTail.isNotEmpty) {
      final depTp = _tp(depTail, 5.5, sx, family: 'NotoSerifSC');
      _mark('departureStation', depTp, xDep + wMain + 1.5, 104 + (9.5 - 5.5),
          scaleX, scaleY);
      depTp.paint(canvas, Offset(X(xDep + wMain + 1.5), Y(104 + (9.5 - 5.5))));
    }

    // 到达站（右）：对称
    final wm2 = _tp(arrMain, 9.5, sx).width / scaleX;
    final wt2 =
        arrTail.isEmpty ? 0.0 : (_tp(arrTail, 5.5, sx, family: 'NotoSerifSC').width / scaleX + 1.5);
    final xArr = (162 + xc1 - (wm2 + wt2)) / 2;
    final arrTp = _tp(arrMain, 9.5, sx);
    _mark('arrivalStation', arrTp, xArr, 104, scaleX, scaleY);
    arrTp.paint(canvas, Offset(X(xArr), Y(104)));
    if (arrTail.isNotEmpty) {
      final arrTailTp = _tp(arrTail, 5.5, sx, family: 'NotoSerifSC');
      _mark('arrivalStation', arrTailTp, xArr + wm2 + 1.5, 104 + (9.5 - 5.5),
          scaleX, scaleY);
      arrTailTp.paint(
          canvas, Offset(X(xArr + wm2 + 1.5), Y(104 + (9.5 - 5.5))));
    }

    // 车次
    _mark('trainNumber', tc, 86 - wc / 2, 104, scaleX, scaleY);
    tc.paint(canvas, Offset(X(86 - wc / 2), Y(104)));

    // L3 拼音：站名主体正下方（自动生成，首字母大写）
    String capFirst(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    if (depRaw.isNotEmpty) {
      final py = PinyinHelper.getPinyin(depRaw, separator: '');
      if (py.isNotEmpty) {
        final pyTp = _tp(capFirst(py), 4, sx, family: 'NotoSerifSC');
        // 拼音居中于站名主体正下方
        final pyX = xDep + (wMain - pyTp.width / scaleX) / 2;
        pyTp.paint(canvas, Offset(X(pyX), Y(115)));
      }
    }
    if (arrRaw.isNotEmpty) {
      final py = PinyinHelper.getPinyin(arrRaw, separator: '');
      if (py.isNotEmpty) {
        final pyTp = _tp(capFirst(py), 4, sx, family: 'NotoSerifSC');
        final pyX = xArr + (wm2 - pyTp.width / scaleX) / 2;
        pyTp.paint(canvas, Offset(X(pyX), Y(115)));
      }
    }

    // L4 日期时间（数字粗汉字小）+ 席位（右对齐）
    final timeStr = _ov('departureTime', log.departureTime).trim();
    final List<(String, double, FontWeight, bool)> dateSegs;
    final ovDate = textOverrides['date'];
    if (ovDate?.isNotEmpty == true) {
      dateSegs = [(ovDate!, 6.5, FontWeight.normal, false)];
    } else {
      dateSegs = [
        (DateFormat('yyyy').format(log.date), 6.5, FontWeight.normal, false),
        ('年', 4.0, FontWeight.normal, true),
        (DateFormat('MM').format(log.date), 6.5, FontWeight.normal, false),
        ('月', 4.0, FontWeight.normal, true),
        (DateFormat('dd').format(log.date), 6.5, FontWeight.normal, false),
        ('日', 4.0, FontWeight.normal, true),
      ];
    }
    final dateW = _drawRich(canvas, dateSegs, 20, 121, sx, X, Y, key: 'date');
    if (timeStr.isNotEmpty) {
      final timeSegs = <(String, double, FontWeight, bool)>[
        (' ', 6, FontWeight.normal, false),
        (timeStr, 6.5, FontWeight.normal, false),
        ('开', 4.0, FontWeight.normal, true),
      ];
      _drawRich(canvas, timeSegs, 20 + dateW, 121, sx, X, Y,
          key: 'departureTime');
    }

    // 席位：座位号右对齐 x138，车厢号在其左侧（不重叠）
    final seatSegs = <(String, double, FontWeight, bool)>[];
    final carriage = _ov('carriage', log.carriage).trim();
    final seat = _ov('seatNumber', log.seatNumber).trim();
    if (seat.isNotEmpty) {
      if (carriage.isNotEmpty) {
        seatSegs.add((' ', 5, FontWeight.normal, false));
      }
      seatSegs.add((seat, 6.5, FontWeight.normal, false));
      seatSegs.add(('号', 4.0, FontWeight.normal, true));
    }
    final sw = seatSegs.isEmpty ? 0.0 : _richW(seatSegs, sx, scaleX);
    if (carriage.isNotEmpty) {
      final c = carriage.endsWith('车')
          ? carriage.substring(0, carriage.length - 1)
          : carriage;
      final carSegs = <(String, double, FontWeight, bool)>[
        (c, 6.5, FontWeight.normal, false),
        ('车', 4.0, FontWeight.normal, true),
      ];
      final cw = _richW(carSegs, sx, scaleX);
      // 车厢号右端 = 座位号左端 - 0.5；无座位时右对齐 138
      final carRight = seat.isNotEmpty ? 138 - sw - 0.5 : 138.0;
      _drawRich(canvas, carSegs, carRight - cw, 121, sx, X, Y,
          key: 'carriage');
    }
    if (seat.isNotEmpty) {
      _drawRich(canvas, seatSegs, 138 - sw, 121, sx, X, Y,
          key: 'seatNumber');
    }

    // L5 价格 + 购票标记 + 席别
    if (_ov('price', log.price).isNotEmpty) {
      final price = _ov('price', log.price).trim();
      final priceSegs = <(String, double, FontWeight, bool)>[
        ('￥', 5, FontWeight.normal, true),
        (price.endsWith('元') ? price.substring(0, price.length - 1) : price,
            6, FontWeight.normal, false),
        (price.endsWith('元') ? '元' : '', 5, FontWeight.normal, true),
      ];
      _drawRich(canvas, priceSegs, 20, 128.5, sx, X, Y, key: 'price');
    }
    if (_ov('buyMarks', log.buyMarks).isNotEmpty) {
      final bmTp = _tp(_ov('buyMarks', log.buyMarks), 5, sx,
          family: 'NotoSerifSC');
      _mark('buyMarks', bmTp, 20 + 6.5 * 8 + 6, 128.5, scaleX, scaleY);
      bmTp.paint(canvas, Offset(X(20 + 6.5 * 8 + 6), Y(128.5)));
    }
    if (_ov('seatClass', log.seatClass).isNotEmpty) {
      final sc = _tp(_ov('seatClass', log.seatClass), 5, sx, family: 'NotoSerifSC');
      _mark('seatClass', sc, 138 - sc.width / scaleX, 128.5, scaleX, scaleY);
      sc.paint(canvas, Offset(X(138) - sc.width, Y(128.5)));
    }

    // L6 限乘
        final limitTp = _tp(_ov('limitNote', '限乘当日当次车'), 4.5, sx,
        family: 'NotoSerifSC');
    _mark('limitNote', limitTp, 20, 135.5, scaleX, scaleY);
    limitTp.paint(canvas, Offset(X(20), Y(135.5)));

    // L8 乘车人：身份证（前10****后4）+ 姓名（设置页，本地保存）
    final idCard = _ov('idCard', idCardText);
    final name = _ov('passengerName', passengerName);
    if (idCard.isNotEmpty || name.isNotEmpty) {
      final idSegs = <(String, double, FontWeight, bool)>[
        if (idCard.isNotEmpty) (idCard, 6, FontWeight.normal, false),
      ];
      if (idSegs.isNotEmpty) {
        _drawRich(canvas, idSegs, 20, 146, sx, X, Y, key: 'idCard');
      }
      if (name.isNotEmpty) {
        final nameSegs = <(String, double, FontWeight, bool)>[
          (' ', 6, FontWeight.normal, false),
          (name, 6, FontWeight.normal, true),
        ];
        _drawRich(canvas, nameSegs,
            idSegs.isEmpty ? 20 : 20 + _richW(idSegs, sx, scaleX), 146, sx, X, Y,
            key: 'passengerName');
      }
    }
  }

  // ---------------- 箭头（用户精确 path） ----------------

  void _paintArrow(Canvas canvas, Size size,
      double Function(double) X, double Function(double) Y) {
    final trainNo = _ov('trainNumber', log.trainNumber).trim();
    final sx = size.width / _vw;
    if (trainNo.isEmpty) return;
    final tc = _tp(trainNo, 9.5, sx, family: 'NotoSerifSC');
    final wc = tc.width / (X(1) - X(0));
    if (wc <= 0) return;

    const body = [
      (5.57, 173.49),
      (187.73, 173.49),
      (199.17, 177.14),
      (5.76, 176.88),
    ];
    const chamfer = [
      (199.17, 177.14),
      (171.94, 167.67),
      (181.63, 176.67),
    ];
    const xmin = 5.57, xmax = 199.17, yref = 173.49;
    final s = wc / (xmax - xmin);
    final topY = 104 + 9.5 + 3.5;
    Offset T(double x, double y) =>
        Offset(X(86 - wc / 2 + (x - xmin) * s), Y(topY + (y - yref) * s));

    final bodyPath = Path();
    for (var i = 0; i < body.length; i++) {
      final p = T(body[i].$1, body[i].$2);
      i == 0 ? bodyPath.moveTo(p.dx, p.dy) : bodyPath.lineTo(p.dx, p.dy);
    }
    bodyPath.close();
    canvas.drawPath(bodyPath, Paint()..color = _kInk);

    final chPath = Path();
    for (var i = 0; i < chamfer.length; i++) {
      final p = T(chamfer[i].$1, chamfer[i].$2);
      i == 0 ? chPath.moveTo(p.dx, p.dy) : chPath.lineTo(p.dx, p.dy);
    }
    chPath.close();
    canvas.drawPath(chPath, Paint()..color = _kInk);
  }

  // ---------------- 虚线框 ----------------

  void _paintDashedBox(Canvas canvas, Size size,
      double Function(double) X, double Function(double) Y) {
    final sx = size.width / _vw;
    final line1 = _ov('adLine1', '买票请到12306发货请到95306');
    final line2 = _ov('adLine2', '中国铁路祝您旅途愉快');
    final l1 = _tp(line1, 3.8, sx, family: 'NotoSerifSC');
    final l2 = _tp(line2, 3.8, sx, family: 'NotoSerifSC');
    final h1 = l1.height / (Y(1) - Y(0));
    const gap = 0.6, p = 0.2;
    final boxW = max(l1.width, l2.width) / (X(1) - X(0)) + 2 * p;
    const boxX0 = 28.0, boxY0 = 154.0; // 边框：往回移一点，文字保持原位
    final ly1 = boxY0 + p;
    final ly2 = ly1 + h1 + gap;
    const by1 = 165.7;
    final bx1 = 45 + boxW; // 右边往里收，与左边框对称
    final textCxVb = 36.5 + boxW / 2; // 文字中心（v52 原值，不随边框移动）

    final dashPaint = Paint()
      ..color = _kInk
      ..strokeWidth = 0.5 * sx;
    const dashLen = 2.2, gapLen = 2.2;
    void dashLine(Offset a, Offset b) {
      final total = (b - a).distance;
      final n = (total / ((dashLen + gapLen) * sx)).floor();
      for (var i = 0; i <= n; i++) {
        final t0 = i * (dashLen + gapLen) * sx;
        if (t0 > total) break;
        final t1 = min(t0 + dashLen * sx, total);
        canvas.drawLine(
          a + (b - a) * (t0 / total),
          a + (b - a) * (t1 / total),
          dashPaint,
        );
      }
    }

    dashLine(Offset(X(boxX0), Y(boxY0)), Offset(X(bx1), Y(boxY0)));
    dashLine(Offset(X(boxX0), Y(by1)), Offset(X(bx1), Y(by1)));
    dashLine(Offset(X(boxX0), Y(boxY0)), Offset(X(boxX0), Y(by1)));
    dashLine(Offset(X(bx1), Y(boxY0)), Offset(X(bx1), Y(by1)));

    final cx = X(textCxVb);
    _mark('adLine1', l1, textCxVb - l1.width / (X(1) - X(0)), ly1,
        X(1) - X(0), Y(1) - Y(0));
    l1.paint(canvas, Offset(cx - l1.width / 2, Y(ly1)));
    _mark('adLine2', l2, textCxVb - l2.width / (X(1) - X(0)), ly2,
        X(1) - X(0), Y(1) - Y(0));
    l2.paint(canvas, Offset(cx - l2.width / 2, Y(ly2)));
  }

  // ---------------- 二维码（模拟） ----------------

    void _paintQr(Canvas canvas,
      double Function(double) X, double Function(double) Y) {
    const x0 = 138.0, y0 = 144.0, x1 = 160.0, y1 = 166.0;
    // 项目 GitHub 地址二维码
    final qrCode = QrCode(
      payload: QrPayload.fromString(
          'https://github.com/zzzjjj-ss/train-log-app'),
      errorCorrectLevel: QrErrorCorrectLevel.medium,
    );
    final qrImage = QrImage(qrCode);
    final n = qrImage.moduleCount;
    final cellW = (x1 - x0) / n, cellH = (y1 - y0) / n;
    final paint = Paint()..color = _kInk;
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        if (qrImage.isDark(j, i)) {
          canvas.drawRect(
            Rect.fromLTRB(X(x0 + i * cellW), Y(y0 + j * cellH),
                X(x0 + (i + 1) * cellW), Y(y0 + (j + 1) * cellH)),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) => oldDelegate.log != log;
}
