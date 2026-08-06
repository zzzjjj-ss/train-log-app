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

  // ============ 车迷扩展字段（v2） ============

  /// 列车种类：动车组 / 普速机辆 / 其他
  TextColumn get trainKind => text().withDefault(const Constant('动车组'))();

  /// 值乘路局，如：上海局、北京局
  TextColumn get bureau => text().withDefault(const Constant(''))();

  /// 机务段 / 车辆段，如：上海机务段、广州动车段
  TextColumn get depot => text().withDefault(const Constant(''))();

  /// 最高时速（km/h），可空
  IntColumn get maxSpeed => integer().nullable()();

  // ---- 普速机辆模式：本务机车信息 ----

  /// 机车型号，如：HXD3D、SS9G、DF11
  TextColumn get locomotiveModel => text().withDefault(const Constant(''))();

  /// 机车编号，如：HXD3D-0031
  TextColumn get locomotiveNumber => text().withDefault(const Constant(''))();

  /// 机车制造厂，如：大连机车、株洲机车
  TextColumn get locomotiveFactory => text().withDefault(const Constant(''))();

  /// 牵引区间，如：北京—广州
  TextColumn get haulingSection => text().withDefault(const Constant(''))();

  // ---- 动车组模式：动车组信息 ----

  /// 动车组型号，如：CR400BF、CRH380A、CR200J
  TextColumn get emuModel => text().withDefault(const Constant(''))();

  /// 动车组编号，如：CR400BF-5033
  TextColumn get emuNumber => text().withDefault(const Constant(''))();

  /// 定员（人），可空
  IntColumn get emuCapacity => integer().nullable()();

  /// 编组数量，如：8、16
  TextColumn get emuFormation => text().withDefault(const Constant(''))();

  /// 配属动车所，如：广州南动车所
  TextColumn get emuDepot => text().withDefault(const Constant(''))();

  /// 车厢编号，如：ZYS102001（车种代码+编号，v3）
  TextColumn get carNumber => text().withDefault(const Constant(''))();

  /// 到达日偏移：0=当天，1=次日，2=第3天（跨天行程，v5）
  IntColumn get arrivalDayOffset => integer().withDefault(const Constant(0))();
}

/// 本务机车表：一趟车可有多台机车（中途换挂 / 双机重联）
class Locomotives extends Table {
  /// 主键，自增 id
  IntColumn get id => integer().autoIncrement()();

  /// 所属运转记录 id
  IntColumn get logId => integer().references(TrainLogs, #id)();

  /// 机车型号，如：HXD3D、SS9G
  TextColumn get model => text()();

  /// 机车编号，如：HXD3D-0031
  TextColumn get number => text().withDefault(const Constant(''))();

  /// 制造厂，如：大连机车
  TextColumn get factory => text().withDefault(const Constant(''))();
}

/// 数据库主体。drift 会根据这里的定义生成 _\$AppDatabase 基类。
@DriftDatabase(tables: [TrainLogs, Locomotives])
class AppDatabase extends _$AppDatabase {
  /// [executor] 可选：正常运行时用 drift_flutter 自动配置的数据库；
  /// 测试时可以传入内存数据库 NativeDatabase.memory() 来隔离数据。
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'train_log_app'));

  @override
  int get schemaVersion => 5;

  /// 数据库迁移：自愈式 —— 先检查列是否存在，缺失才添加。
  /// 解决"迁移中断导致 duplicate column"问题（列已加但版本号未更新时，
  /// 盲目再次 ALTER 会报重复列错误）。
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2 起新增的车迷扩展字段（全部做存在性检查）
      await _addColumnIfMissing(m, 'train_kind', "TEXT NOT NULL DEFAULT '动车组'");
      await _addColumnIfMissing(m, 'bureau', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'depot', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'max_speed', 'INTEGER');
      await _addColumnIfMissing(m, 'locomotive_model', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'locomotive_number', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'locomotive_factory', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'hauling_section', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'emu_model', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'emu_number', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'emu_capacity', 'INTEGER');
      await _addColumnIfMissing(m, 'emu_formation', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'emu_depot', "TEXT NOT NULL DEFAULT ''");
      // v3 车厢编号
      await _addColumnIfMissing(m, 'car_number', "TEXT NOT NULL DEFAULT ''");
      // v5 跨天到达日偏移
      await _addColumnIfMissing(m, 'arrival_day_offset', 'INTEGER NOT NULL DEFAULT 0');
      // v5 本务机车表（多台机车）
      await m.createTable(locomotives);
    },
  );

  /// 检查列是否存在，缺失才 ALTER 添加（幂等，可安全重复执行）
  Future<void> _addColumnIfMissing(
    Migrator m,
    String columnName,
    String sqlType,
  ) async {
    final rows = await m.database
        .customSelect('PRAGMA table_info(train_logs)')
        .get();
    final exists = rows.any((r) => r.data['name'] == columnName);
    if (!exists) {
      await m.database.customStatement(
        'ALTER TABLE train_logs ADD COLUMN $columnName $sqlType',
      );
    }
  }

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

  /// 按 id 删除一条记录（连带删除其本务机车记录）
  Future<void> deleteLog(int id) async {
    await (delete(locomotives)..where((l) => l.logId.equals(id))).go();
    await (delete(trainLogs)..where((t) => t.id.equals(id))).go();
  }

  /// 监听某条记录的本务机车列表（按 id 排序）
  Stream<List<Locomotive>> watchLocomotives(int logId) {
    final query = select(locomotives)
      ..where((l) => l.logId.equals(logId))
      ..orderBy([(l) => OrderingTerm.asc(l.id)]);
    return query.watch();
  }

  /// 整组替换某条记录的本务机车（先删旧、再插新）
  Future<void> replaceLocomotives(
    int logId,
    List<LocomotivesCompanion> items,
  ) async {
    await transaction(() async {
      await (delete(locomotives)..where((l) => l.logId.equals(logId))).go();
      for (final item in items) {
        await into(locomotives).insert(item.copyWith(logId: Value(logId)));
      }
    });
  }

  /// 读取某条记录的本务机车（一次性查询，非流式）
  Future<List<Locomotive>> getLocomotives(int logId) {
    final query = select(locomotives)
      ..where((l) => l.logId.equals(logId))
      ..orderBy([(l) => OrderingTerm.asc(l.id)]);
    return query.get();
  }
}
