/// 数据备份服务：全量导出 JSON / 从 JSON 导入（覆盖或合并）
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';

/// 导出全部数据（记录 + 机车）为 JSON 字符串
Future<String> exportAllJson(AppDatabase db) async {
  final logs = await db.getAllLogs();
  final locoMap = await db.getAllLocomotivesByLog();
  final data = <String, dynamic>{
    'app': 'train_log',
    'format': '1',
    'exported_at': DateTime.now().toIso8601String(),
    'logs': [for (final l in logs) _logToJson(l)],
    'locomotives': [
      for (final e in locoMap.entries)
        for (final l in e.value) _locoToJson(l, e.key),
    ],
  };
  return const JsonEncoder.withIndent('  ').convert(data);
}

/// 从 JSON 导入。overwrite=true 覆盖现有数据，false 合并。返回导入的记录数。
Future<int> importFromJson(
  AppDatabase db,
  String jsonStr, {
  required bool overwrite,
}) async {
  final data = jsonDecode(jsonStr) as Map<String, dynamic>;
  final logsRaw =
      (data['logs'] as List? ?? const []).cast<Map<String, dynamic>>();
  final locosRaw =
      (data['locomotives'] as List? ?? const []).cast<Map<String, dynamic>>();

  return db.transaction(() async {
    if (overwrite) {
      await db.deleteAllLogs();
    }
    final idMap = <int, int>{};
    for (final m in logsRaw) {
      final newId = await db.addLog(_logFromJson(m));
      idMap[m['id'] as int? ?? -1] = newId;
    }
    for (final m in locosRaw) {
      final oldLogId = m['logId'] as int? ?? -1;
      final newLogId = idMap[oldLogId];
      if (newLogId == null) continue;
      await db.addLocomotive(_locoFromJson(m, newLogId));
    }
    return logsRaw.length;
  });
}

// ---- 序列化 ----

Map<String, dynamic> _logToJson(TrainLog l) => {
      'id': l.id,
      'trainNumber': l.trainNumber,
      'departureStation': l.departureStation,
      'arrivalStation': l.arrivalStation,
      'date': l.date.toIso8601String(),
      'departureTime': l.departureTime,
      'arrivalTime': l.arrivalTime,
      'seatClass': l.seatClass,
      'carriage': l.carriage,
      'seatNumber': l.seatNumber,
      'distanceKm': l.distanceKm,
      'rating': l.rating,
      'notes': l.notes,
      'trainKind': l.trainKind,
      'bureau': l.bureau,
      'depot': l.depot,
      'maxSpeed': l.maxSpeed,
      'locomotiveModel': l.locomotiveModel,
      'locomotiveNumber': l.locomotiveNumber,
      'locomotiveFactory': l.locomotiveFactory,
      'haulingSection': l.haulingSection,
      'emuModel': l.emuModel,
      'emuNumber': l.emuNumber,
      'emuCapacity': l.emuCapacity,
      'emuFormation': l.emuFormation,
      'emuDepot': l.emuDepot,
      'carNumber': l.carNumber,
      'arrivalDayOffset': l.arrivalDayOffset,
      // v7 购票信息
      'price': l.price,
      'gate': l.gate,
      'buyMarks': l.buyMarks,
      'saleLocation': l.saleLocation,
      'serialNumber': l.serialNumber,
      'ticketNumber': l.ticketNumber,
    };

Map<String, dynamic> _locoToJson(Locomotive l, int logId) => {
      'logId': logId,
      'model': l.model,
      'number': l.number,
      'factory': l.factory,
      'haulingSection': l.haulingSection,
    };

// ---- 反序列化 ----

TrainLogsCompanion _logFromJson(Map<String, dynamic> m) {
  return TrainLogsCompanion.insert(
    trainNumber: (m['trainNumber'] as String?) ?? '',
    departureStation: (m['departureStation'] as String?) ?? '',
    arrivalStation: (m['arrivalStation'] as String?) ?? '',
    date: DateTime.tryParse((m['date'] as String?) ?? '') ?? DateTime.now(),
    departureTime: Value((m['departureTime'] as String?) ?? ''),
    arrivalTime: Value((m['arrivalTime'] as String?) ?? ''),
    seatClass: Value((m['seatClass'] as String?) ?? '二等座'),
    carriage: Value((m['carriage'] as String?) ?? ''),
    seatNumber: Value((m['seatNumber'] as String?) ?? ''),
    distanceKm: Value(m['distanceKm'] as int?),
    rating: Value((m['rating'] as int?) ?? 5),
    notes: Value((m['notes'] as String?) ?? ''),
    trainKind: Value((m['trainKind'] as String?) ?? '动车组'),
    bureau: Value((m['bureau'] as String?) ?? ''),
    depot: Value((m['depot'] as String?) ?? ''),
    maxSpeed: Value(m['maxSpeed'] as int?),
    locomotiveModel: Value((m['locomotiveModel'] as String?) ?? ''),
    locomotiveNumber: Value((m['locomotiveNumber'] as String?) ?? ''),
    locomotiveFactory: Value((m['locomotiveFactory'] as String?) ?? ''),
    haulingSection: Value((m['haulingSection'] as String?) ?? ''),
    emuModel: Value((m['emuModel'] as String?) ?? ''),
    emuNumber: Value((m['emuNumber'] as String?) ?? ''),
    emuCapacity: Value(m['emuCapacity'] as int?),
    emuFormation: Value((m['emuFormation'] as String?) ?? ''),
    emuDepot: Value((m['emuDepot'] as String?) ?? ''),
    carNumber: Value((m['carNumber'] as String?) ?? ''),
    arrivalDayOffset: Value((m['arrivalDayOffset'] as int?) ?? 0),
    // v7 购票信息
    price: Value((m['price'] as String?) ?? ''),
    gate: Value((m['gate'] as String?) ?? ''),
    buyMarks: Value((m['buyMarks'] as String?) ?? ''),
    saleLocation: Value((m['saleLocation'] as String?) ?? ''),
    serialNumber: Value((m['serialNumber'] as String?) ?? ''),
    ticketNumber: Value((m['ticketNumber'] as String?) ?? ''),
  );
}

LocomotivesCompanion _locoFromJson(Map<String, dynamic> m, int newLogId) {
  return LocomotivesCompanion(
    logId: Value(newLogId),
    model: Value((m['model'] as String?) ?? ''),
    number: Value((m['number'] as String?) ?? ''),
    factory: Value((m['factory'] as String?) ?? ''),
    haulingSection: Value((m['haulingSection'] as String?) ?? ''),
  );
}
