/// 车票流水号 / 编号随机生成器。
///
/// 格式参考真实 12306 车票：
/// - 流水号：字母（R/F/P/C）+ 6 位数字，如 `R093443`
/// - 编号：14 位数字 + 流水号，如 `10010301110403F067846`
library;

import 'dart:math';

class TicketGen {
  static const _serialPrefixes = ['R', 'F', 'P', 'C'];

  /// 生成流水号：R/F/P/C + 6 位数字（如 R093443）
  static String serialNumber([Random? random]) {
    final r = random ?? Random();
    final prefix = _serialPrefixes[r.nextInt(_serialPrefixes.length)];
    final digits = r.nextInt(1000000).toString().padLeft(6, '0');
    return '$prefix$digits';
  }

  /// 生成车票编号：14 位数字 + 流水号（如 10010301110403F067846）。
  /// 不传流水号时内部随机生成一个。
  static String ticketNumber({Random? random, String? serial}) {
    final r = random ?? Random();
    final sn = serial ?? serialNumber(r);
    // 14 位数字：逐位生成，避免 nextInt 超 2^32 上限
    final sb = StringBuffer()..write(1 + r.nextInt(9));
    for (var i = 0; i < 13; i++) {
      sb.write(r.nextInt(10));
    }
    return '$sb$sn';
  }
}
