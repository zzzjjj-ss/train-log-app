import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';

/// 数据库实例的全局单例。
/// Riverpod 的 Provider：整个 App 里都能拿到同一个数据库对象，
/// App 关闭时自动调用 db.close() 释放资源。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 运转记录列表的响应式数据源。
/// StreamProvider 订阅数据库的变化：
/// 只要数据库有增删改，watchAllLogs() 的 Stream 就会推送新列表，
/// 界面用 ref.watch(logsProvider) 就会自动刷新。
final logsProvider = StreamProvider<List<TrainLog>>((ref) {
  return ref.watch(databaseProvider).watchAllLogs();
});
