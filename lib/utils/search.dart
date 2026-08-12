/// 记录关键词搜索：全字段匹配，返回匹配标签
library;

import '../data/database.dart';

/// 返回记录匹配关键词的标签列表（如 ['机车型号:HXD3D', '车厢编号:ZYS102001']）
/// 按记录类型分流：动车组只匹配动车组字段，普速机辆匹配机车字段（含多台）。
List<String> matchKeywordFields(
  TrainLog log,
  List<Locomotive> locos,
  String keyword,
) {
  final k = keyword.trim().toLowerCase();
  if (k.isEmpty) return const [];
  final hits = <String>[];

  void hit(String field, String value) {
    if (value.isEmpty) return;
    final tag = '$field:$value';
    if (value.toLowerCase().contains(k) && !hits.contains(tag)) {
      hits.add(tag);
    }
  }

  // ---- 通用字段（所有记录）----
  hit('车次', log.trainNumber);
  hit('出发站', log.departureStation);
  hit('到达站', log.arrivalStation);
  hit('席别', log.seatClass);
  hit('车厢', log.carriage);
  hit('座位号', log.seatNumber);
  hit('车厢编号', log.carNumber);
  hit('路局', log.bureau);
  hit('机务段', log.depot);
  if (log.maxSpeed != null) hit('最高时速', '${log.maxSpeed}');
  hit('备注', log.notes);

  // ---- 动车组专属字段（仅动车组记录）----
  if (log.trainKind == '动车组') {
    hit('动车组型号', log.emuModel);
    hit('动车组编号', log.emuNumber);
    hit('配属', log.emuDepot);
    hit('编组', log.emuFormation);
  }

  // ---- 机车专属字段（仅普速机辆，含全部多台机车）----
  if (log.trainKind == '普速机辆') {
    for (final l in locos) {
      hit('机车型号', l.model);
      hit('机车编号', l.number);
      hit('制造厂', l.factory);
      hit('牵引区间', l.haulingSection);
    }
  }

  return hits;
}
