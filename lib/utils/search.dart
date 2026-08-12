/// 记录关键词搜索：全字段匹配，返回匹配标签（支持关键词高亮）
library;

import '../data/database.dart';

/// 一条搜索匹配：text 为显示文本，highlight 为要高亮的子串（备注场景用）
class SearchHit {
  final String text;
  final String? highlight;
  const SearchHit(this.text, [this.highlight]);
}

/// 返回记录匹配关键词的标签列表。
/// 按记录类型分流：动车组只匹配动车组字段，普速机辆匹配机车字段（含多台）。
List<SearchHit> matchKeywordFields(
  TrainLog log,
  List<Locomotive> locos,
  String keyword,
) {
  final k = keyword.trim().toLowerCase();
  if (k.isEmpty) return const [];
  final hits = <SearchHit>[];

  void add(String field, String value, {String? highlight}) {
    if (value.isEmpty) return;
    if (!value.toLowerCase().contains(k)) return;
    final t = '$field:$value';
    if (!hits.any((h) => h.text == t)) {
      hits.add(SearchHit(t, highlight));
    }
  }

  // ---- 通用字段（所有记录）----
  add('车次', log.trainNumber);
  add('出发站', log.departureStation);
  add('到达站', log.arrivalStation);
  add('席别', log.seatClass);
  add('车厢', log.carriage);
  add('座位号', log.seatNumber);
  add('车厢编号', log.carNumber);
  add('路局', log.bureau);
  add('机务段', log.depot);
  if (log.maxSpeed != null) add('最高时速', '${log.maxSpeed}');
  // 备注：长文本截断上下文 + 关键词高亮
  if (log.notes.toLowerCase().contains(k) && log.notes.isNotEmpty) {
    if (log.notes.length > 24) {
      final sn = _snippet(log.notes, k);
      add('备注', sn.text, highlight: sn.keyword);
    } else {
      add('备注', log.notes);
    }
  }

  // ---- 动车组专属字段（仅动车组记录）----
  if (log.trainKind == '动车组') {
    add('动车组型号', log.emuModel);
    add('动车组编号', log.emuNumber);
    add('配属', log.emuDepot);
    add('编组', log.emuFormation);
  }

  // ---- 机车专属字段（仅普速机辆，含全部多台机车）----
  if (log.trainKind == '普速机辆') {
    for (final l in locos) {
      add('机车型号', l.model);
      add('机车编号', l.number);
      add('制造厂', l.factory);
      add('牵引区间', l.haulingSection);
    }
  }

  return hits;
}

/// 截取关键词上下文片段：…前文关键词后文…
({String text, String keyword}) _snippet(String text, String keyword) {
  const radius = 8;
  final idx = text.toLowerCase().indexOf(keyword.toLowerCase());
  if (idx == -1) return (text: text, keyword: keyword);
  final start = idx > radius ? idx - radius : 0;
  final end = (idx + keyword.length + radius) < text.length
      ? idx + keyword.length + radius
      : text.length;
  final pre = start > 0 ? '…' : '';
  final post = end < text.length ? '…' : '';
  final kw = text.substring(idx, idx + keyword.length);
  final body = text.substring(start, idx) +
      kw +
      text.substring(idx + keyword.length, end);
  return (text: '$pre$body$post', keyword: kw);
}
