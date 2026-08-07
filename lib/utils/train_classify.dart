/// 车次前缀分类体系：两大类别（动车组/普速）+ 细分小类
library;

/// 大类选项（第一行 chips）
const List<String> kTrainMajorOptions = ['全部', '动车组', '普速'];

/// 各大小类（第二行 chips 按大类展开）
const Map<String, List<String>> kTrainSubOptions = {
  '动车组': ['高铁', '动车', '城际', '市郊'],
  '普速': ['直达', '特快', '快速', '旅游', '临客', '普客'],
};

/// 小类显示标签（带车次字母）
const Map<String, String> kTrainSubLabels = {
  '高铁': '高铁 G',
  '动车': '动车 D',
  '城际': '城际 C',
  '市郊': '市郊 S',
  '直达': '直达 Z',
  '特快': '特快 T',
  '快速': '快速 K',
  '旅游': '旅游 Y',
  '临客': '临客 L',
  '普客': '普客(数字)',
};

/// 根据车次前缀判断列车小类：
/// G→高铁、D→动车、C→城际、S→市郊（市域铁路，多为动车组如 CRH6A）、
/// Z→直达、T→特快、K→快速、Y→旅游、L→临客、纯数字→普客
String classifyTrainNumber(String trainNumber) {
  final v = trainNumber.trim().toUpperCase();
  if (v.isEmpty) return '普客';
  const map = {
    'G': '高铁', 'D': '动车', 'C': '城际', 'S': '市郊',
    'Z': '直达', 'T': '特快', 'K': '快速', 'Y': '旅游', 'L': '临客',
  };
  final first = v[0];
  if (map.containsKey(first)) return map[first]!;
  if (RegExp(r'^\d').hasMatch(v)) return '普客';
  return '普客'; // 未知字母车次默认归普速
}

/// 小类 → 大类
String majorOf(String subtype) {
  return kTrainSubOptions['动车组']!.contains(subtype) ? '动车组' : '普速';
}

/// 筛选匹配：majors 已选大类集合，subs 已选小类集合（均支持多选）
/// - 大类没选中的 → 不匹配
/// - 某大类下没勾小类 → 该大类全部匹配
/// - 某大类下勾了若干小类 → 只匹配这些小类
bool matchTrainFilter(
  String trainNumber,
  Set<String> majors,
  Set<String> subs,
) {
  final s = classifyTrainNumber(trainNumber);
  final m = majorOf(s);
  if (majors.isEmpty && subs.isEmpty) return true;
  if (!majors.contains(m)) return false;
  final majorSubs = subs.where((x) => majorOf(x) == m).toSet();
  if (majorSubs.isEmpty) return true;
  return majorSubs.contains(s);
}
