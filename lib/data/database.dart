import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// 运转记录表（每一行 = 一次乘坐火车的记录）
class TrainLogs extends Table {
  /// 主键，自增 id
  IntColumn get id => integer().autoIncrement()();

  /// 车次，例如 G1234、Z98
  TextColumn get trainNumber => text()();

  /// 出发站
  TextColumn get departureStation => text()();

  /// 到达站
  TextColumn get arrivalStation => text()();

  /// 乘车日期（存年月日，用于排序和统计）
  DateTimeColumn get date => dateTime()();

  /// 发车时间，格式 "HH:mm"（用文本存最简单，避免时区坑）
  TextColumn get departureTime => text().withDefault(const Constant(''))();

  /// 到达时间，格式 "HH:mm"
  TextColumn get arrivalTime => text().withDefault(const Constant(''))();

  /// 席别，如：二等座、硬卧、无座
  TextColumn get seatClass => text().withDefault(const Constant('二等座'))();

  /// 车厢号，如 08 车
  TextColumn get carriage => text().withDefault(const Constant(''))();

  /// 座位号，如 12F
  TextColumn get seatNumber => text().withDefault(const Constant(''))();

  /// 里程（公里），可空
  IntColumn get distanceKm => integer().nullable()();

  /// 体验评分 1~5 星
  IntColumn get rating => integer().withDefault(const Constant(5))();

  /// 备注/心情
  TextColumn get notes => text().withDefault(const Constant(''))();
}

/// 数据库主体。drift 会根据这里的定义生成 _\$AppDatabase 基类。
@DriftDatabase(tables: [TrainLogs])
class AppDatabase extends _$AppDatabase {
  /// [executor] 可选：正常运行时用 drift_flutter 自动配置的数据库；
  /// 测试时可以传入内存数据库 NativeDatabase.memory() 来隔离数据。
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'train_log_app'));

  @override
  int get schemaVersion => 1;

  /// 监听所有记录（按日期倒序，最新在前）
  /// 返回 Stream：数据库变化时，界面会自动刷新（这就是"响应式"）
  Stream<List<TrainLog>> watchAllLogs() {
    final query = select(trainLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.date), (t) => OrderingTerm.desc(t.id)]);
    return query.watch();
  }

  /// 新增一条记录，返回新记录的自增 id
  Future<int> addLog(TrainLogsCompanion entry) {
    return into(trainLogs).insert(entry);
  }

  /// 更新一条记录（按主键替换整行）
  Future<void> updateLog(TrainLogsCompanion entry) {
    return update(trainLogs).replace(entry);
  }

  /// 按 id 删除一条记录
  Future<void> deleteLog(int id) {
    return (delete(trainLogs)..where((t) => t.id.equals(id))).go();
  }
}
