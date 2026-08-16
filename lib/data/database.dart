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

  // ============ 购票信息（v7） ============

  /// 票价，如 "54.5元"（存文本，保留 ￥ 等格式）
  TextColumn get price => text().withDefault(const Constant(''))();

  /// 检票口，如 "22"（对应车票右上"检票口22"）
  TextColumn get gate => text().withDefault(const Constant(''))();

  /// 购票标记：可组合 "网"(网购)/"孩"(儿童)/"折"(折扣)，如 "孩网折"
  TextColumn get buyMarks => text().withDefault(const Constant(''))();

  /// 发售地，如 "北京南售"
  TextColumn get saleLocation => text().withDefault(const Constant(''))();

  /// 流水号，如 "R093443"（随机生成，可手工改）
  TextColumn get serialNumber => text().withDefault(const Constant(''))();

  /// 车票编号，如 "10010301110403F067846"（随机生成，可手工改）
  TextColumn get ticketNumber => text().withDefault(const Constant(''))();
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

  /// 该台机车的牵引区间，如：北京—郑州（换挂/重联时各车不同，v6）
  TextColumn get haulingSection => text().withDefault(const Constant(''))();
}

/// 车票自定义覆盖层（v8）：每张票一条，只影响车票显示，不改原记录。
/// overridesJson 存票面文字覆盖（字段名→自定义文本）；bgImagePath/bgMode 存背景图。
class TicketOverrides extends Table {
  /// 所属运转记录 id（主键，每票一条）
  IntColumn get logId => integer().references(TrainLogs, #id)();

  /// 文字覆盖 JSON：{"trainNumber":"G1234","price":"88元",...}，空 {} 表示无覆盖
  TextColumn get overridesJson => text().withDefault(const Constant('{}'))();

  /// 背景图文件路径（应用文档目录），空表示用默认浅蓝背景
  TextColumn get bgImagePath => text().withDefault(const Constant(''))();

  /// 背景映射模式：cover / contain / fill
  TextColumn get bgMode => text().withDefault(const Constant('cover'))();

  @override
  Set<Column> get primaryKey => {logId};
}

/// 数据库主体。drift 会根据这里的定义生成 _\$AppDatabase 基类。
@DriftDatabase(tables: [TrainLogs, Locomotives, TicketOverrides])
class AppDatabase extends _$AppDatabase {
  /// [executor] 可选：正常运行时用 drift_flutter 自动配置的数据库；
  /// 测试时可以传入内存数据库 NativeDatabase.memory() 来隔离数据。
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'train_log_app'));

  @override
  int get schemaVersion => 8;

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
      if (from < 5) {
        await m.createTable(locomotives);
      } else {
        // v6：机车表补"牵引区间"列（已有表时自愈添加）
        await _addLocomotiveColumnIfMissing(
          m, 'hauling_section', "TEXT NOT NULL DEFAULT ''");
      }
      // v6：旧数据搬迁 —— 把整趟车的牵引区间写入该趟车第一台机车
      await _migrateOldHaulingSection(m);
      // v7：购票信息字段（票价/检票口/购票标记/发售地/流水号/编号）
      await _addColumnIfMissing(m, 'price', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'gate', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'buy_marks', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'sale_location', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'serial_number', "TEXT NOT NULL DEFAULT ''");
      await _addColumnIfMissing(m, 'ticket_number', "TEXT NOT NULL DEFAULT ''");
      // v8：车票自定义覆盖层表
      if (from < 8) {
        await m.createTable(ticketOverrides);
      }
    },
  );

  /// 把 v5 及以前的 train_logs.hauling_section 同步到对应记录的第一台机车
  Future<void> _migrateOldHaulingSection(Migrator m) async {
    await m.database.customStatement(
      'UPDATE locomotives '
      'SET hauling_section = ('
      '  SELECT hauling_section FROM train_logs WHERE train_logs.id = locomotives.log_id'
      ') '
      'WHERE hauling_section = \'\' '
      'AND log_id IN (SELECT MIN(id) FROM locomotives GROUP BY log_id) '
      'AND (SELECT hauling_section FROM train_logs WHERE train_logs.id = locomotives.log_id) != \'\'',
    );
  }

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

  /// 机车表专用：检查列是否存在，缺失才 ALTER 添加（自愈、幂等）
  Future<void> _addLocomotiveColumnIfMissing(
    Migrator m,
    String columnName,
    String sqlType,
  ) async {
    final rows = await m.database
        .customSelect('PRAGMA table_info(locomotives)')
        .get();
    final exists = rows.any((r) => r.data['name'] == columnName);
    if (!exists) {
      await m.database.customStatement(
        'ALTER TABLE locomotives ADD COLUMN $columnName $sqlType',
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
    await (delete(ticketOverrides)..where((t) => t.logId.equals(id))).go();
    await (delete(trainLogs)..where((t) => t.id.equals(id))).go();
  }

  // ============ 车票自定义覆盖层（v8） ============

  /// 读取某条记录的车票覆盖层（无则返回 null）
  Future<TicketOverride?> getTicketOverrides(int logId) async {
    final query = select(ticketOverrides)..where((t) => t.logId.equals(logId));
    return query.getSingleOrNull();
  }

  /// 监听某条记录的车票覆盖层（覆盖表变化自动推送，无需手动刷新）
  Stream<TicketOverride?> watchTicketOverrides(int logId) {
    final query = select(ticketOverrides)..where((t) => t.logId.equals(logId));
    return query.watchSingleOrNull();
  }

  /// 保存/更新覆盖层（按 logId upsert）
  Future<void> saveTicketOverrides(TicketOverridesCompanion entry) async {
    await into(ticketOverrides).insertOnConflictUpdate(entry);
  }

  /// 清除某条记录的覆盖层（重置回原始车票）
  Future<void> clearTicketOverrides(int logId) async {
    await (delete(ticketOverrides)..where((t) => t.logId.equals(logId))).go();
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

  /// 获取全部本务机车，按 logId 分组（搜索多台机车用，一次查询）
  Future<Map<int, List<Locomotive>>> getAllLocomotivesByLog() async {
    final all = await select(locomotives).get();
    final map = <int, List<Locomotive>>{};
    for (final l in all) {
      map.putIfAbsent(l.logId, () => []).add(l);
    }
    return map;
  }

  /// 获取全部记录（导出用）
  Future<List<TrainLog>> getAllLogs() {
    final query = select(trainLogs)
      ..orderBy([(t) => OrderingTerm.asc(t.id)]);
    return query.get();
  }

  /// 清空全部记录与机车（覆盖导入用）
  Future<void> deleteAllLogs() async {
    await delete(locomotives).go();
    await delete(trainLogs).go();
  }

  /// 新增一条本务机车（导入用）
  Future<int> addLocomotive(LocomotivesCompanion item) {
    return into(locomotives).insert(item);
  }
}
