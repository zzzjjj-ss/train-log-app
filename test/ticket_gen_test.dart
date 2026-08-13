import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:train_log_app/utils/ticket_gen.dart';

void main() {
  group('TicketGen 流水号/编号', () {
    test('流水号：字母 R/F/P/C + 6 位数字', () {
      final rnd = Random(42);
      for (var i = 0; i < 200; i++) {
        final sn = TicketGen.serialNumber(rnd);
        expect(RegExp(r'^[RFPC]\d{6}$').hasMatch(sn), isTrue, reason: sn);
      }
    });

    test('编号：14 位数字 + 流水号', () {
      final rnd = Random(7);
      for (var i = 0; i < 200; i++) {
        final tn = TicketGen.ticketNumber(random: rnd);
        expect(RegExp(r'^\d{14}[RFPC]\d{6}$').hasMatch(tn), isTrue,
            reason: tn);
      }
    });

    test('指定流水号时编号复用该流水号', () {
      final tn = TicketGen.ticketNumber(serial: 'R093443');
      expect(tn.endsWith('R093443'), isTrue);
      expect(tn.length, 21); // 14 + 7
    });
  });
}
