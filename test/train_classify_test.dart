// 车次前缀分类与筛选匹配单元测试
import 'package:flutter_test/flutter_test.dart';

import 'package:train_log_app/utils/train_classify.dart';

void main() {
  group('车次前缀分类（小类）', () {
    test('G→高铁、D→动车、C→城际、S→市郊', () {
      expect(classifyTrainNumber('G1371'), '高铁');
      expect(classifyTrainNumber('g1371'), '高铁'); // 小写也识别
      expect(classifyTrainNumber('D311'), '动车');
      expect(classifyTrainNumber('C2021'), '城际');
      expect(classifyTrainNumber('S1001'), '市郊');
    });
    test('Z/T/K/Y/L → 直达/特快/快速/旅游/临客', () {
      expect(classifyTrainNumber('Z98'), '直达');
      expect(classifyTrainNumber('T110'), '特快');
      expect(classifyTrainNumber('K519'), '快速');
      expect(classifyTrainNumber('Y511'), '旅游');
      expect(classifyTrainNumber('L123'), '临客');
    });
    test('纯数字/空 → 普客', () {
      expect(classifyTrainNumber('1450'), '普客');
      expect(classifyTrainNumber('6001'), '普客');
      expect(classifyTrainNumber(''), '普客');
    });
  });

  group('小类 → 大类', () {
    test('高铁/动车/城际/市郊 → 动车组', () {
      for (final s in ['高铁', '动车', '城际', '市郊']) {
        expect(majorOf(s), '动车组');
      }
    });
    test('直达/特快/快速/旅游/临客/普客 → 普速', () {
      for (final s in ['直达', '特快', '快速', '旅游', '临客', '普客']) {
        expect(majorOf(s), '普速');
      }
    });
  });

  group('筛选匹配（大类/小类均多选）', () {
    test('全部未选 → 全部匹配', () {
      expect(matchTrainFilter('G1371', {}, {}), isTrue);
      expect(matchTrainFilter('K519', {}, {}), isTrue);
    });
    test('只选大类动车组 → 动车组全匹配，普速不匹配', () {
      expect(matchTrainFilter('G1371', {'动车组'}, {}), isTrue);
      expect(matchTrainFilter('S1001', {'动车组'}, {}), isTrue);
      expect(matchTrainFilter('K519', {'动车组'}, {}), isFalse);
    });
    test('大类动车组 + 小类高铁 → 只匹配高铁', () {
      expect(matchTrainFilter('G1371', {'动车组'}, {'高铁'}), isTrue);
      expect(matchTrainFilter('D311', {'动车组'}, {'高铁'}), isFalse);
    });
    test('跨大类多选：动车组高铁 + 普速直达', () {
      expect(matchTrainFilter('G1371', {'动车组', '普速'}, {'高铁', '直达'}), isTrue);
      expect(matchTrainFilter('Z98', {'动车组', '普速'}, {'高铁', '直达'}), isTrue);
      expect(matchTrainFilter('K519', {'动车组', '普速'}, {'高铁', '直达'}), isFalse);
    });
  });
}

