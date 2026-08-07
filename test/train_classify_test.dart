// 车次前缀分类单元测试
import 'package:flutter_test/flutter_test.dart';

import 'package:train_log_app/utils/train_classify.dart';

void main() {
  group('车次前缀分类', () {
    test('G 开头 → 高铁', () {
      expect(classifyTrainNumber('G1371'), '高铁');
      expect(classifyTrainNumber('g1371'), '高铁'); // 小写也识别
    });
    test('D 开头 → 动车', () {
      expect(classifyTrainNumber('D311'), '动车');
    });
    test('C 开头 → 城际', () {
      expect(classifyTrainNumber('C2021'), '城际');
    });
    test('S 开头 → 市郊（市域铁路，动车组）', () {
      expect(classifyTrainNumber('S1001'), '市郊');
      expect(classifyTrainNumber('S505'), '市郊');
    });
    test('K/T/Z/Y/L/纯数字 → 普速', () {
      expect(classifyTrainNumber('K519'), '普速');
      expect(classifyTrainNumber('Z98'), '普速');
      expect(classifyTrainNumber('T110'), '普速');
      expect(classifyTrainNumber('1450'), '普速');
      expect(classifyTrainNumber('6001'), '普速');
      expect(classifyTrainNumber('Y511'), '普速');
      expect(classifyTrainNumber('L123'), '普速');
    });
    test('空值 → 普速', () {
      expect(classifyTrainNumber(''), '普速');
    });
  });
}
