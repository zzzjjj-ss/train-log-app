/// 记录关键词搜索匹配
library;

import '../data/database.dart';

/// 判断记录是否匹配关键词（车次/站点/车型/编号/路局/车厢编号/备注）
bool matchKeyword(TrainLog log, String keyword) {
  final k = keyword.trim().toLowerCase();
  if (k.isEmpty) return true;
  final fields = <String>[
    log.trainNumber,
    log.departureStation,
    log.arrivalStation,
    log.emuModel,
    log.emuNumber,
    log.emuDepot,
    log.locomotiveModel,
    log.locomotiveNumber,
    log.bureau,
    log.carNumber,
    log.notes,
  ];
  return fields.any((f) => f.toLowerCase().contains(k));
}
