/// 车次前缀分类：高铁 / 动车 / 城际 / 市郊 / 普速
library;

/// 筛选 chips 选项（label 显示用，value 用于过滤比较）
const List<({String label, String value})> kTrainFilterOptions = [
  (label: '全部', value: '全部'),
  (label: '高铁 G', value: '高铁'),
  (label: '动车 D', value: '动车'),
  (label: '城际 C', value: '城际'),
  (label: '市郊 S', value: '市郊'),
  (label: '普速', value: '普速'),
];

/// 根据车次前缀判断列车类别：
/// G→高铁、D→动车、C→城际、S→市郊（市域铁路，多为动车组如 CRH6A），
/// 其余（K/T/Z/Y/L/N/纯数字等）→普速
String classifyTrainNumber(String trainNumber) {
  final v = trainNumber.trim().toUpperCase();
  if (v.isEmpty) return '普速';
  if (v.startsWith('G')) return '高铁';
  if (v.startsWith('D')) return '动车';
  if (v.startsWith('C')) return '城际';
  if (v.startsWith('S')) return '市郊';
  return '普速';
}
