// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TrainLogsTable extends TrainLogs
    with TableInfo<$TrainLogsTable, TrainLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _trainNumberMeta = const VerificationMeta(
    'trainNumber',
  );
  @override
  late final GeneratedColumn<String> trainNumber = GeneratedColumn<String>(
    'train_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureStationMeta = const VerificationMeta(
    'departureStation',
  );
  @override
  late final GeneratedColumn<String> departureStation = GeneratedColumn<String>(
    'departure_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalStationMeta = const VerificationMeta(
    'arrivalStation',
  );
  @override
  late final GeneratedColumn<String> arrivalStation = GeneratedColumn<String>(
    'arrival_station',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureTimeMeta = const VerificationMeta(
    'departureTime',
  );
  @override
  late final GeneratedColumn<String> departureTime = GeneratedColumn<String>(
    'departure_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _arrivalTimeMeta = const VerificationMeta(
    'arrivalTime',
  );
  @override
  late final GeneratedColumn<String> arrivalTime = GeneratedColumn<String>(
    'arrival_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seatClassMeta = const VerificationMeta(
    'seatClass',
  );
  @override
  late final GeneratedColumn<String> seatClass = GeneratedColumn<String>(
    'seat_class',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('二等座'),
  );
  static const VerificationMeta _carriageMeta = const VerificationMeta(
    'carriage',
  );
  @override
  late final GeneratedColumn<String> carriage = GeneratedColumn<String>(
    'carriage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seatNumberMeta = const VerificationMeta(
    'seatNumber',
  );
  @override
  late final GeneratedColumn<String> seatNumber = GeneratedColumn<String>(
    'seat_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<int> distanceKm = GeneratedColumn<int>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _trainKindMeta = const VerificationMeta(
    'trainKind',
  );
  @override
  late final GeneratedColumn<String> trainKind = GeneratedColumn<String>(
    'train_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('动车组'),
  );
  static const VerificationMeta _bureauMeta = const VerificationMeta('bureau');
  @override
  late final GeneratedColumn<String> bureau = GeneratedColumn<String>(
    'bureau',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _depotMeta = const VerificationMeta('depot');
  @override
  late final GeneratedColumn<String> depot = GeneratedColumn<String>(
    'depot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _maxSpeedMeta = const VerificationMeta(
    'maxSpeed',
  );
  @override
  late final GeneratedColumn<int> maxSpeed = GeneratedColumn<int>(
    'max_speed',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locomotiveModelMeta = const VerificationMeta(
    'locomotiveModel',
  );
  @override
  late final GeneratedColumn<String> locomotiveModel = GeneratedColumn<String>(
    'locomotive_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locomotiveNumberMeta = const VerificationMeta(
    'locomotiveNumber',
  );
  @override
  late final GeneratedColumn<String> locomotiveNumber = GeneratedColumn<String>(
    'locomotive_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _locomotiveFactoryMeta = const VerificationMeta(
    'locomotiveFactory',
  );
  @override
  late final GeneratedColumn<String> locomotiveFactory =
      GeneratedColumn<String>(
        'locomotive_factory',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _haulingSectionMeta = const VerificationMeta(
    'haulingSection',
  );
  @override
  late final GeneratedColumn<String> haulingSection = GeneratedColumn<String>(
    'hauling_section',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emuModelMeta = const VerificationMeta(
    'emuModel',
  );
  @override
  late final GeneratedColumn<String> emuModel = GeneratedColumn<String>(
    'emu_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emuNumberMeta = const VerificationMeta(
    'emuNumber',
  );
  @override
  late final GeneratedColumn<String> emuNumber = GeneratedColumn<String>(
    'emu_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emuCapacityMeta = const VerificationMeta(
    'emuCapacity',
  );
  @override
  late final GeneratedColumn<int> emuCapacity = GeneratedColumn<int>(
    'emu_capacity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emuFormationMeta = const VerificationMeta(
    'emuFormation',
  );
  @override
  late final GeneratedColumn<String> emuFormation = GeneratedColumn<String>(
    'emu_formation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emuDepotMeta = const VerificationMeta(
    'emuDepot',
  );
  @override
  late final GeneratedColumn<String> emuDepot = GeneratedColumn<String>(
    'emu_depot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    trainNumber,
    departureStation,
    arrivalStation,
    date,
    departureTime,
    arrivalTime,
    seatClass,
    carriage,
    seatNumber,
    distanceKm,
    rating,
    notes,
    trainKind,
    bureau,
    depot,
    maxSpeed,
    locomotiveModel,
    locomotiveNumber,
    locomotiveFactory,
    haulingSection,
    emuModel,
    emuNumber,
    emuCapacity,
    emuFormation,
    emuDepot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'train_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('train_number')) {
      context.handle(
        _trainNumberMeta,
        trainNumber.isAcceptableOrUnknown(
          data['train_number']!,
          _trainNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trainNumberMeta);
    }
    if (data.containsKey('departure_station')) {
      context.handle(
        _departureStationMeta,
        departureStation.isAcceptableOrUnknown(
          data['departure_station']!,
          _departureStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureStationMeta);
    }
    if (data.containsKey('arrival_station')) {
      context.handle(
        _arrivalStationMeta,
        arrivalStation.isAcceptableOrUnknown(
          data['arrival_station']!,
          _arrivalStationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalStationMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('departure_time')) {
      context.handle(
        _departureTimeMeta,
        departureTime.isAcceptableOrUnknown(
          data['departure_time']!,
          _departureTimeMeta,
        ),
      );
    }
    if (data.containsKey('arrival_time')) {
      context.handle(
        _arrivalTimeMeta,
        arrivalTime.isAcceptableOrUnknown(
          data['arrival_time']!,
          _arrivalTimeMeta,
        ),
      );
    }
    if (data.containsKey('seat_class')) {
      context.handle(
        _seatClassMeta,
        seatClass.isAcceptableOrUnknown(data['seat_class']!, _seatClassMeta),
      );
    }
    if (data.containsKey('carriage')) {
      context.handle(
        _carriageMeta,
        carriage.isAcceptableOrUnknown(data['carriage']!, _carriageMeta),
      );
    }
    if (data.containsKey('seat_number')) {
      context.handle(
        _seatNumberMeta,
        seatNumber.isAcceptableOrUnknown(data['seat_number']!, _seatNumberMeta),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('train_kind')) {
      context.handle(
        _trainKindMeta,
        trainKind.isAcceptableOrUnknown(data['train_kind']!, _trainKindMeta),
      );
    }
    if (data.containsKey('bureau')) {
      context.handle(
        _bureauMeta,
        bureau.isAcceptableOrUnknown(data['bureau']!, _bureauMeta),
      );
    }
    if (data.containsKey('depot')) {
      context.handle(
        _depotMeta,
        depot.isAcceptableOrUnknown(data['depot']!, _depotMeta),
      );
    }
    if (data.containsKey('max_speed')) {
      context.handle(
        _maxSpeedMeta,
        maxSpeed.isAcceptableOrUnknown(data['max_speed']!, _maxSpeedMeta),
      );
    }
    if (data.containsKey('locomotive_model')) {
      context.handle(
        _locomotiveModelMeta,
        locomotiveModel.isAcceptableOrUnknown(
          data['locomotive_model']!,
          _locomotiveModelMeta,
        ),
      );
    }
    if (data.containsKey('locomotive_number')) {
      context.handle(
        _locomotiveNumberMeta,
        locomotiveNumber.isAcceptableOrUnknown(
          data['locomotive_number']!,
          _locomotiveNumberMeta,
        ),
      );
    }
    if (data.containsKey('locomotive_factory')) {
      context.handle(
        _locomotiveFactoryMeta,
        locomotiveFactory.isAcceptableOrUnknown(
          data['locomotive_factory']!,
          _locomotiveFactoryMeta,
        ),
      );
    }
    if (data.containsKey('hauling_section')) {
      context.handle(
        _haulingSectionMeta,
        haulingSection.isAcceptableOrUnknown(
          data['hauling_section']!,
          _haulingSectionMeta,
        ),
      );
    }
    if (data.containsKey('emu_model')) {
      context.handle(
        _emuModelMeta,
        emuModel.isAcceptableOrUnknown(data['emu_model']!, _emuModelMeta),
      );
    }
    if (data.containsKey('emu_number')) {
      context.handle(
        _emuNumberMeta,
        emuNumber.isAcceptableOrUnknown(data['emu_number']!, _emuNumberMeta),
      );
    }
    if (data.containsKey('emu_capacity')) {
      context.handle(
        _emuCapacityMeta,
        emuCapacity.isAcceptableOrUnknown(
          data['emu_capacity']!,
          _emuCapacityMeta,
        ),
      );
    }
    if (data.containsKey('emu_formation')) {
      context.handle(
        _emuFormationMeta,
        emuFormation.isAcceptableOrUnknown(
          data['emu_formation']!,
          _emuFormationMeta,
        ),
      );
    }
    if (data.containsKey('emu_depot')) {
      context.handle(
        _emuDepotMeta,
        emuDepot.isAcceptableOrUnknown(data['emu_depot']!, _emuDepotMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      trainNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}train_number'],
      )!,
      departureStation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departure_station'],
      )!,
      arrivalStation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arrival_station'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      departureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departure_time'],
      )!,
      arrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arrival_time'],
      )!,
      seatClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seat_class'],
      )!,
      carriage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}carriage'],
      )!,
      seatNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seat_number'],
      )!,
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_km'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      trainKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}train_kind'],
      )!,
      bureau: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bureau'],
      )!,
      depot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}depot'],
      )!,
      maxSpeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_speed'],
      ),
      locomotiveModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locomotive_model'],
      )!,
      locomotiveNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locomotive_number'],
      )!,
      locomotiveFactory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locomotive_factory'],
      )!,
      haulingSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hauling_section'],
      )!,
      emuModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emu_model'],
      )!,
      emuNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emu_number'],
      )!,
      emuCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emu_capacity'],
      ),
      emuFormation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emu_formation'],
      )!,
      emuDepot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emu_depot'],
      )!,
    );
  }

  @override
  $TrainLogsTable createAlias(String alias) {
    return $TrainLogsTable(attachedDatabase, alias);
  }
}

class TrainLog extends DataClass implements Insertable<TrainLog> {
  /// 主键，自增 id
  final int id;

  /// 车次，例如 G1234、Z98
  final String trainNumber;

  /// 出发站
  final String departureStation;

  /// 到达站
  final String arrivalStation;

  /// 乘车日期（存年月日，用于排序和统计）
  final DateTime date;

  /// 发车时间，格式 "HH:mm"（用文本存最简单，避免时区坑）
  final String departureTime;

  /// 到达时间，格式 "HH:mm"
  final String arrivalTime;

  /// 席别，如：二等座、硬卧、无座
  final String seatClass;

  /// 车厢号，如 08 车
  final String carriage;

  /// 座位号，如 12F
  final String seatNumber;

  /// 里程（公里），可空
  final int? distanceKm;

  /// 体验评分 1~5 星
  final int rating;

  /// 备注/心情
  final String notes;

  /// 列车种类：动车组 / 普速机辆 / 其他
  final String trainKind;

  /// 值乘路局，如：上海局、北京局
  final String bureau;

  /// 机务段 / 车辆段，如：上海机务段、广州动车段
  final String depot;

  /// 最高时速（km/h），可空
  final int? maxSpeed;

  /// 机车型号，如：HXD3D、SS9G、DF11
  final String locomotiveModel;

  /// 机车编号，如：HXD3D-0031
  final String locomotiveNumber;

  /// 机车制造厂，如：大连机车、株洲机车
  final String locomotiveFactory;

  /// 牵引区间，如：北京—广州
  final String haulingSection;

  /// 动车组型号，如：CR400BF、CRH380A、CR200J
  final String emuModel;

  /// 动车组编号，如：CR400BF-5033
  final String emuNumber;

  /// 定员（人），可空
  final int? emuCapacity;

  /// 编组数量，如：8、16
  final String emuFormation;

  /// 配属动车所，如：广州南动车所
  final String emuDepot;
  const TrainLog({
    required this.id,
    required this.trainNumber,
    required this.departureStation,
    required this.arrivalStation,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.seatClass,
    required this.carriage,
    required this.seatNumber,
    this.distanceKm,
    required this.rating,
    required this.notes,
    required this.trainKind,
    required this.bureau,
    required this.depot,
    this.maxSpeed,
    required this.locomotiveModel,
    required this.locomotiveNumber,
    required this.locomotiveFactory,
    required this.haulingSection,
    required this.emuModel,
    required this.emuNumber,
    this.emuCapacity,
    required this.emuFormation,
    required this.emuDepot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['train_number'] = Variable<String>(trainNumber);
    map['departure_station'] = Variable<String>(departureStation);
    map['arrival_station'] = Variable<String>(arrivalStation);
    map['date'] = Variable<DateTime>(date);
    map['departure_time'] = Variable<String>(departureTime);
    map['arrival_time'] = Variable<String>(arrivalTime);
    map['seat_class'] = Variable<String>(seatClass);
    map['carriage'] = Variable<String>(carriage);
    map['seat_number'] = Variable<String>(seatNumber);
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<int>(distanceKm);
    }
    map['rating'] = Variable<int>(rating);
    map['notes'] = Variable<String>(notes);
    map['train_kind'] = Variable<String>(trainKind);
    map['bureau'] = Variable<String>(bureau);
    map['depot'] = Variable<String>(depot);
    if (!nullToAbsent || maxSpeed != null) {
      map['max_speed'] = Variable<int>(maxSpeed);
    }
    map['locomotive_model'] = Variable<String>(locomotiveModel);
    map['locomotive_number'] = Variable<String>(locomotiveNumber);
    map['locomotive_factory'] = Variable<String>(locomotiveFactory);
    map['hauling_section'] = Variable<String>(haulingSection);
    map['emu_model'] = Variable<String>(emuModel);
    map['emu_number'] = Variable<String>(emuNumber);
    if (!nullToAbsent || emuCapacity != null) {
      map['emu_capacity'] = Variable<int>(emuCapacity);
    }
    map['emu_formation'] = Variable<String>(emuFormation);
    map['emu_depot'] = Variable<String>(emuDepot);
    return map;
  }

  TrainLogsCompanion toCompanion(bool nullToAbsent) {
    return TrainLogsCompanion(
      id: Value(id),
      trainNumber: Value(trainNumber),
      departureStation: Value(departureStation),
      arrivalStation: Value(arrivalStation),
      date: Value(date),
      departureTime: Value(departureTime),
      arrivalTime: Value(arrivalTime),
      seatClass: Value(seatClass),
      carriage: Value(carriage),
      seatNumber: Value(seatNumber),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      rating: Value(rating),
      notes: Value(notes),
      trainKind: Value(trainKind),
      bureau: Value(bureau),
      depot: Value(depot),
      maxSpeed: maxSpeed == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSpeed),
      locomotiveModel: Value(locomotiveModel),
      locomotiveNumber: Value(locomotiveNumber),
      locomotiveFactory: Value(locomotiveFactory),
      haulingSection: Value(haulingSection),
      emuModel: Value(emuModel),
      emuNumber: Value(emuNumber),
      emuCapacity: emuCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(emuCapacity),
      emuFormation: Value(emuFormation),
      emuDepot: Value(emuDepot),
    );
  }

  factory TrainLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainLog(
      id: serializer.fromJson<int>(json['id']),
      trainNumber: serializer.fromJson<String>(json['trainNumber']),
      departureStation: serializer.fromJson<String>(json['departureStation']),
      arrivalStation: serializer.fromJson<String>(json['arrivalStation']),
      date: serializer.fromJson<DateTime>(json['date']),
      departureTime: serializer.fromJson<String>(json['departureTime']),
      arrivalTime: serializer.fromJson<String>(json['arrivalTime']),
      seatClass: serializer.fromJson<String>(json['seatClass']),
      carriage: serializer.fromJson<String>(json['carriage']),
      seatNumber: serializer.fromJson<String>(json['seatNumber']),
      distanceKm: serializer.fromJson<int?>(json['distanceKm']),
      rating: serializer.fromJson<int>(json['rating']),
      notes: serializer.fromJson<String>(json['notes']),
      trainKind: serializer.fromJson<String>(json['trainKind']),
      bureau: serializer.fromJson<String>(json['bureau']),
      depot: serializer.fromJson<String>(json['depot']),
      maxSpeed: serializer.fromJson<int?>(json['maxSpeed']),
      locomotiveModel: serializer.fromJson<String>(json['locomotiveModel']),
      locomotiveNumber: serializer.fromJson<String>(json['locomotiveNumber']),
      locomotiveFactory: serializer.fromJson<String>(json['locomotiveFactory']),
      haulingSection: serializer.fromJson<String>(json['haulingSection']),
      emuModel: serializer.fromJson<String>(json['emuModel']),
      emuNumber: serializer.fromJson<String>(json['emuNumber']),
      emuCapacity: serializer.fromJson<int?>(json['emuCapacity']),
      emuFormation: serializer.fromJson<String>(json['emuFormation']),
      emuDepot: serializer.fromJson<String>(json['emuDepot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'trainNumber': serializer.toJson<String>(trainNumber),
      'departureStation': serializer.toJson<String>(departureStation),
      'arrivalStation': serializer.toJson<String>(arrivalStation),
      'date': serializer.toJson<DateTime>(date),
      'departureTime': serializer.toJson<String>(departureTime),
      'arrivalTime': serializer.toJson<String>(arrivalTime),
      'seatClass': serializer.toJson<String>(seatClass),
      'carriage': serializer.toJson<String>(carriage),
      'seatNumber': serializer.toJson<String>(seatNumber),
      'distanceKm': serializer.toJson<int?>(distanceKm),
      'rating': serializer.toJson<int>(rating),
      'notes': serializer.toJson<String>(notes),
      'trainKind': serializer.toJson<String>(trainKind),
      'bureau': serializer.toJson<String>(bureau),
      'depot': serializer.toJson<String>(depot),
      'maxSpeed': serializer.toJson<int?>(maxSpeed),
      'locomotiveModel': serializer.toJson<String>(locomotiveModel),
      'locomotiveNumber': serializer.toJson<String>(locomotiveNumber),
      'locomotiveFactory': serializer.toJson<String>(locomotiveFactory),
      'haulingSection': serializer.toJson<String>(haulingSection),
      'emuModel': serializer.toJson<String>(emuModel),
      'emuNumber': serializer.toJson<String>(emuNumber),
      'emuCapacity': serializer.toJson<int?>(emuCapacity),
      'emuFormation': serializer.toJson<String>(emuFormation),
      'emuDepot': serializer.toJson<String>(emuDepot),
    };
  }

  TrainLog copyWith({
    int? id,
    String? trainNumber,
    String? departureStation,
    String? arrivalStation,
    DateTime? date,
    String? departureTime,
    String? arrivalTime,
    String? seatClass,
    String? carriage,
    String? seatNumber,
    Value<int?> distanceKm = const Value.absent(),
    int? rating,
    String? notes,
    String? trainKind,
    String? bureau,
    String? depot,
    Value<int?> maxSpeed = const Value.absent(),
    String? locomotiveModel,
    String? locomotiveNumber,
    String? locomotiveFactory,
    String? haulingSection,
    String? emuModel,
    String? emuNumber,
    Value<int?> emuCapacity = const Value.absent(),
    String? emuFormation,
    String? emuDepot,
  }) => TrainLog(
    id: id ?? this.id,
    trainNumber: trainNumber ?? this.trainNumber,
    departureStation: departureStation ?? this.departureStation,
    arrivalStation: arrivalStation ?? this.arrivalStation,
    date: date ?? this.date,
    departureTime: departureTime ?? this.departureTime,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    seatClass: seatClass ?? this.seatClass,
    carriage: carriage ?? this.carriage,
    seatNumber: seatNumber ?? this.seatNumber,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    rating: rating ?? this.rating,
    notes: notes ?? this.notes,
    trainKind: trainKind ?? this.trainKind,
    bureau: bureau ?? this.bureau,
    depot: depot ?? this.depot,
    maxSpeed: maxSpeed.present ? maxSpeed.value : this.maxSpeed,
    locomotiveModel: locomotiveModel ?? this.locomotiveModel,
    locomotiveNumber: locomotiveNumber ?? this.locomotiveNumber,
    locomotiveFactory: locomotiveFactory ?? this.locomotiveFactory,
    haulingSection: haulingSection ?? this.haulingSection,
    emuModel: emuModel ?? this.emuModel,
    emuNumber: emuNumber ?? this.emuNumber,
    emuCapacity: emuCapacity.present ? emuCapacity.value : this.emuCapacity,
    emuFormation: emuFormation ?? this.emuFormation,
    emuDepot: emuDepot ?? this.emuDepot,
  );
  TrainLog copyWithCompanion(TrainLogsCompanion data) {
    return TrainLog(
      id: data.id.present ? data.id.value : this.id,
      trainNumber: data.trainNumber.present
          ? data.trainNumber.value
          : this.trainNumber,
      departureStation: data.departureStation.present
          ? data.departureStation.value
          : this.departureStation,
      arrivalStation: data.arrivalStation.present
          ? data.arrivalStation.value
          : this.arrivalStation,
      date: data.date.present ? data.date.value : this.date,
      departureTime: data.departureTime.present
          ? data.departureTime.value
          : this.departureTime,
      arrivalTime: data.arrivalTime.present
          ? data.arrivalTime.value
          : this.arrivalTime,
      seatClass: data.seatClass.present ? data.seatClass.value : this.seatClass,
      carriage: data.carriage.present ? data.carriage.value : this.carriage,
      seatNumber: data.seatNumber.present
          ? data.seatNumber.value
          : this.seatNumber,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      rating: data.rating.present ? data.rating.value : this.rating,
      notes: data.notes.present ? data.notes.value : this.notes,
      trainKind: data.trainKind.present ? data.trainKind.value : this.trainKind,
      bureau: data.bureau.present ? data.bureau.value : this.bureau,
      depot: data.depot.present ? data.depot.value : this.depot,
      maxSpeed: data.maxSpeed.present ? data.maxSpeed.value : this.maxSpeed,
      locomotiveModel: data.locomotiveModel.present
          ? data.locomotiveModel.value
          : this.locomotiveModel,
      locomotiveNumber: data.locomotiveNumber.present
          ? data.locomotiveNumber.value
          : this.locomotiveNumber,
      locomotiveFactory: data.locomotiveFactory.present
          ? data.locomotiveFactory.value
          : this.locomotiveFactory,
      haulingSection: data.haulingSection.present
          ? data.haulingSection.value
          : this.haulingSection,
      emuModel: data.emuModel.present ? data.emuModel.value : this.emuModel,
      emuNumber: data.emuNumber.present ? data.emuNumber.value : this.emuNumber,
      emuCapacity: data.emuCapacity.present
          ? data.emuCapacity.value
          : this.emuCapacity,
      emuFormation: data.emuFormation.present
          ? data.emuFormation.value
          : this.emuFormation,
      emuDepot: data.emuDepot.present ? data.emuDepot.value : this.emuDepot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainLog(')
          ..write('id: $id, ')
          ..write('trainNumber: $trainNumber, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('date: $date, ')
          ..write('departureTime: $departureTime, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('seatClass: $seatClass, ')
          ..write('carriage: $carriage, ')
          ..write('seatNumber: $seatNumber, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('trainKind: $trainKind, ')
          ..write('bureau: $bureau, ')
          ..write('depot: $depot, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('locomotiveModel: $locomotiveModel, ')
          ..write('locomotiveNumber: $locomotiveNumber, ')
          ..write('locomotiveFactory: $locomotiveFactory, ')
          ..write('haulingSection: $haulingSection, ')
          ..write('emuModel: $emuModel, ')
          ..write('emuNumber: $emuNumber, ')
          ..write('emuCapacity: $emuCapacity, ')
          ..write('emuFormation: $emuFormation, ')
          ..write('emuDepot: $emuDepot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    trainNumber,
    departureStation,
    arrivalStation,
    date,
    departureTime,
    arrivalTime,
    seatClass,
    carriage,
    seatNumber,
    distanceKm,
    rating,
    notes,
    trainKind,
    bureau,
    depot,
    maxSpeed,
    locomotiveModel,
    locomotiveNumber,
    locomotiveFactory,
    haulingSection,
    emuModel,
    emuNumber,
    emuCapacity,
    emuFormation,
    emuDepot,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainLog &&
          other.id == this.id &&
          other.trainNumber == this.trainNumber &&
          other.departureStation == this.departureStation &&
          other.arrivalStation == this.arrivalStation &&
          other.date == this.date &&
          other.departureTime == this.departureTime &&
          other.arrivalTime == this.arrivalTime &&
          other.seatClass == this.seatClass &&
          other.carriage == this.carriage &&
          other.seatNumber == this.seatNumber &&
          other.distanceKm == this.distanceKm &&
          other.rating == this.rating &&
          other.notes == this.notes &&
          other.trainKind == this.trainKind &&
          other.bureau == this.bureau &&
          other.depot == this.depot &&
          other.maxSpeed == this.maxSpeed &&
          other.locomotiveModel == this.locomotiveModel &&
          other.locomotiveNumber == this.locomotiveNumber &&
          other.locomotiveFactory == this.locomotiveFactory &&
          other.haulingSection == this.haulingSection &&
          other.emuModel == this.emuModel &&
          other.emuNumber == this.emuNumber &&
          other.emuCapacity == this.emuCapacity &&
          other.emuFormation == this.emuFormation &&
          other.emuDepot == this.emuDepot);
}

class TrainLogsCompanion extends UpdateCompanion<TrainLog> {
  final Value<int> id;
  final Value<String> trainNumber;
  final Value<String> departureStation;
  final Value<String> arrivalStation;
  final Value<DateTime> date;
  final Value<String> departureTime;
  final Value<String> arrivalTime;
  final Value<String> seatClass;
  final Value<String> carriage;
  final Value<String> seatNumber;
  final Value<int?> distanceKm;
  final Value<int> rating;
  final Value<String> notes;
  final Value<String> trainKind;
  final Value<String> bureau;
  final Value<String> depot;
  final Value<int?> maxSpeed;
  final Value<String> locomotiveModel;
  final Value<String> locomotiveNumber;
  final Value<String> locomotiveFactory;
  final Value<String> haulingSection;
  final Value<String> emuModel;
  final Value<String> emuNumber;
  final Value<int?> emuCapacity;
  final Value<String> emuFormation;
  final Value<String> emuDepot;
  const TrainLogsCompanion({
    this.id = const Value.absent(),
    this.trainNumber = const Value.absent(),
    this.departureStation = const Value.absent(),
    this.arrivalStation = const Value.absent(),
    this.date = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.arrivalTime = const Value.absent(),
    this.seatClass = const Value.absent(),
    this.carriage = const Value.absent(),
    this.seatNumber = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.trainKind = const Value.absent(),
    this.bureau = const Value.absent(),
    this.depot = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.locomotiveModel = const Value.absent(),
    this.locomotiveNumber = const Value.absent(),
    this.locomotiveFactory = const Value.absent(),
    this.haulingSection = const Value.absent(),
    this.emuModel = const Value.absent(),
    this.emuNumber = const Value.absent(),
    this.emuCapacity = const Value.absent(),
    this.emuFormation = const Value.absent(),
    this.emuDepot = const Value.absent(),
  });
  TrainLogsCompanion.insert({
    this.id = const Value.absent(),
    required String trainNumber,
    required String departureStation,
    required String arrivalStation,
    required DateTime date,
    this.departureTime = const Value.absent(),
    this.arrivalTime = const Value.absent(),
    this.seatClass = const Value.absent(),
    this.carriage = const Value.absent(),
    this.seatNumber = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.rating = const Value.absent(),
    this.notes = const Value.absent(),
    this.trainKind = const Value.absent(),
    this.bureau = const Value.absent(),
    this.depot = const Value.absent(),
    this.maxSpeed = const Value.absent(),
    this.locomotiveModel = const Value.absent(),
    this.locomotiveNumber = const Value.absent(),
    this.locomotiveFactory = const Value.absent(),
    this.haulingSection = const Value.absent(),
    this.emuModel = const Value.absent(),
    this.emuNumber = const Value.absent(),
    this.emuCapacity = const Value.absent(),
    this.emuFormation = const Value.absent(),
    this.emuDepot = const Value.absent(),
  }) : trainNumber = Value(trainNumber),
       departureStation = Value(departureStation),
       arrivalStation = Value(arrivalStation),
       date = Value(date);
  static Insertable<TrainLog> custom({
    Expression<int>? id,
    Expression<String>? trainNumber,
    Expression<String>? departureStation,
    Expression<String>? arrivalStation,
    Expression<DateTime>? date,
    Expression<String>? departureTime,
    Expression<String>? arrivalTime,
    Expression<String>? seatClass,
    Expression<String>? carriage,
    Expression<String>? seatNumber,
    Expression<int>? distanceKm,
    Expression<int>? rating,
    Expression<String>? notes,
    Expression<String>? trainKind,
    Expression<String>? bureau,
    Expression<String>? depot,
    Expression<int>? maxSpeed,
    Expression<String>? locomotiveModel,
    Expression<String>? locomotiveNumber,
    Expression<String>? locomotiveFactory,
    Expression<String>? haulingSection,
    Expression<String>? emuModel,
    Expression<String>? emuNumber,
    Expression<int>? emuCapacity,
    Expression<String>? emuFormation,
    Expression<String>? emuDepot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trainNumber != null) 'train_number': trainNumber,
      if (departureStation != null) 'departure_station': departureStation,
      if (arrivalStation != null) 'arrival_station': arrivalStation,
      if (date != null) 'date': date,
      if (departureTime != null) 'departure_time': departureTime,
      if (arrivalTime != null) 'arrival_time': arrivalTime,
      if (seatClass != null) 'seat_class': seatClass,
      if (carriage != null) 'carriage': carriage,
      if (seatNumber != null) 'seat_number': seatNumber,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (rating != null) 'rating': rating,
      if (notes != null) 'notes': notes,
      if (trainKind != null) 'train_kind': trainKind,
      if (bureau != null) 'bureau': bureau,
      if (depot != null) 'depot': depot,
      if (maxSpeed != null) 'max_speed': maxSpeed,
      if (locomotiveModel != null) 'locomotive_model': locomotiveModel,
      if (locomotiveNumber != null) 'locomotive_number': locomotiveNumber,
      if (locomotiveFactory != null) 'locomotive_factory': locomotiveFactory,
      if (haulingSection != null) 'hauling_section': haulingSection,
      if (emuModel != null) 'emu_model': emuModel,
      if (emuNumber != null) 'emu_number': emuNumber,
      if (emuCapacity != null) 'emu_capacity': emuCapacity,
      if (emuFormation != null) 'emu_formation': emuFormation,
      if (emuDepot != null) 'emu_depot': emuDepot,
    });
  }

  TrainLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? trainNumber,
    Value<String>? departureStation,
    Value<String>? arrivalStation,
    Value<DateTime>? date,
    Value<String>? departureTime,
    Value<String>? arrivalTime,
    Value<String>? seatClass,
    Value<String>? carriage,
    Value<String>? seatNumber,
    Value<int?>? distanceKm,
    Value<int>? rating,
    Value<String>? notes,
    Value<String>? trainKind,
    Value<String>? bureau,
    Value<String>? depot,
    Value<int?>? maxSpeed,
    Value<String>? locomotiveModel,
    Value<String>? locomotiveNumber,
    Value<String>? locomotiveFactory,
    Value<String>? haulingSection,
    Value<String>? emuModel,
    Value<String>? emuNumber,
    Value<int?>? emuCapacity,
    Value<String>? emuFormation,
    Value<String>? emuDepot,
  }) {
    return TrainLogsCompanion(
      id: id ?? this.id,
      trainNumber: trainNumber ?? this.trainNumber,
      departureStation: departureStation ?? this.departureStation,
      arrivalStation: arrivalStation ?? this.arrivalStation,
      date: date ?? this.date,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      seatClass: seatClass ?? this.seatClass,
      carriage: carriage ?? this.carriage,
      seatNumber: seatNumber ?? this.seatNumber,
      distanceKm: distanceKm ?? this.distanceKm,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      trainKind: trainKind ?? this.trainKind,
      bureau: bureau ?? this.bureau,
      depot: depot ?? this.depot,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      locomotiveModel: locomotiveModel ?? this.locomotiveModel,
      locomotiveNumber: locomotiveNumber ?? this.locomotiveNumber,
      locomotiveFactory: locomotiveFactory ?? this.locomotiveFactory,
      haulingSection: haulingSection ?? this.haulingSection,
      emuModel: emuModel ?? this.emuModel,
      emuNumber: emuNumber ?? this.emuNumber,
      emuCapacity: emuCapacity ?? this.emuCapacity,
      emuFormation: emuFormation ?? this.emuFormation,
      emuDepot: emuDepot ?? this.emuDepot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (trainNumber.present) {
      map['train_number'] = Variable<String>(trainNumber.value);
    }
    if (departureStation.present) {
      map['departure_station'] = Variable<String>(departureStation.value);
    }
    if (arrivalStation.present) {
      map['arrival_station'] = Variable<String>(arrivalStation.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (departureTime.present) {
      map['departure_time'] = Variable<String>(departureTime.value);
    }
    if (arrivalTime.present) {
      map['arrival_time'] = Variable<String>(arrivalTime.value);
    }
    if (seatClass.present) {
      map['seat_class'] = Variable<String>(seatClass.value);
    }
    if (carriage.present) {
      map['carriage'] = Variable<String>(carriage.value);
    }
    if (seatNumber.present) {
      map['seat_number'] = Variable<String>(seatNumber.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<int>(distanceKm.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (trainKind.present) {
      map['train_kind'] = Variable<String>(trainKind.value);
    }
    if (bureau.present) {
      map['bureau'] = Variable<String>(bureau.value);
    }
    if (depot.present) {
      map['depot'] = Variable<String>(depot.value);
    }
    if (maxSpeed.present) {
      map['max_speed'] = Variable<int>(maxSpeed.value);
    }
    if (locomotiveModel.present) {
      map['locomotive_model'] = Variable<String>(locomotiveModel.value);
    }
    if (locomotiveNumber.present) {
      map['locomotive_number'] = Variable<String>(locomotiveNumber.value);
    }
    if (locomotiveFactory.present) {
      map['locomotive_factory'] = Variable<String>(locomotiveFactory.value);
    }
    if (haulingSection.present) {
      map['hauling_section'] = Variable<String>(haulingSection.value);
    }
    if (emuModel.present) {
      map['emu_model'] = Variable<String>(emuModel.value);
    }
    if (emuNumber.present) {
      map['emu_number'] = Variable<String>(emuNumber.value);
    }
    if (emuCapacity.present) {
      map['emu_capacity'] = Variable<int>(emuCapacity.value);
    }
    if (emuFormation.present) {
      map['emu_formation'] = Variable<String>(emuFormation.value);
    }
    if (emuDepot.present) {
      map['emu_depot'] = Variable<String>(emuDepot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainLogsCompanion(')
          ..write('id: $id, ')
          ..write('trainNumber: $trainNumber, ')
          ..write('departureStation: $departureStation, ')
          ..write('arrivalStation: $arrivalStation, ')
          ..write('date: $date, ')
          ..write('departureTime: $departureTime, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('seatClass: $seatClass, ')
          ..write('carriage: $carriage, ')
          ..write('seatNumber: $seatNumber, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('rating: $rating, ')
          ..write('notes: $notes, ')
          ..write('trainKind: $trainKind, ')
          ..write('bureau: $bureau, ')
          ..write('depot: $depot, ')
          ..write('maxSpeed: $maxSpeed, ')
          ..write('locomotiveModel: $locomotiveModel, ')
          ..write('locomotiveNumber: $locomotiveNumber, ')
          ..write('locomotiveFactory: $locomotiveFactory, ')
          ..write('haulingSection: $haulingSection, ')
          ..write('emuModel: $emuModel, ')
          ..write('emuNumber: $emuNumber, ')
          ..write('emuCapacity: $emuCapacity, ')
          ..write('emuFormation: $emuFormation, ')
          ..write('emuDepot: $emuDepot')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrainLogsTable trainLogs = $TrainLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [trainLogs];
}

typedef $$TrainLogsTableCreateCompanionBuilder =
    TrainLogsCompanion Function({
      Value<int> id,
      required String trainNumber,
      required String departureStation,
      required String arrivalStation,
      required DateTime date,
      Value<String> departureTime,
      Value<String> arrivalTime,
      Value<String> seatClass,
      Value<String> carriage,
      Value<String> seatNumber,
      Value<int?> distanceKm,
      Value<int> rating,
      Value<String> notes,
      Value<String> trainKind,
      Value<String> bureau,
      Value<String> depot,
      Value<int?> maxSpeed,
      Value<String> locomotiveModel,
      Value<String> locomotiveNumber,
      Value<String> locomotiveFactory,
      Value<String> haulingSection,
      Value<String> emuModel,
      Value<String> emuNumber,
      Value<int?> emuCapacity,
      Value<String> emuFormation,
      Value<String> emuDepot,
    });
typedef $$TrainLogsTableUpdateCompanionBuilder =
    TrainLogsCompanion Function({
      Value<int> id,
      Value<String> trainNumber,
      Value<String> departureStation,
      Value<String> arrivalStation,
      Value<DateTime> date,
      Value<String> departureTime,
      Value<String> arrivalTime,
      Value<String> seatClass,
      Value<String> carriage,
      Value<String> seatNumber,
      Value<int?> distanceKm,
      Value<int> rating,
      Value<String> notes,
      Value<String> trainKind,
      Value<String> bureau,
      Value<String> depot,
      Value<int?> maxSpeed,
      Value<String> locomotiveModel,
      Value<String> locomotiveNumber,
      Value<String> locomotiveFactory,
      Value<String> haulingSection,
      Value<String> emuModel,
      Value<String> emuNumber,
      Value<int?> emuCapacity,
      Value<String> emuFormation,
      Value<String> emuDepot,
    });

class $$TrainLogsTableFilterComposer
    extends Composer<_$AppDatabase, $TrainLogsTable> {
  $$TrainLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainNumber => $composableBuilder(
    column: $table.trainNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seatClass => $composableBuilder(
    column: $table.seatClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get carriage => $composableBuilder(
    column: $table.carriage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seatNumber => $composableBuilder(
    column: $table.seatNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trainKind => $composableBuilder(
    column: $table.trainKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bureau => $composableBuilder(
    column: $table.bureau,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get depot => $composableBuilder(
    column: $table.depot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locomotiveModel => $composableBuilder(
    column: $table.locomotiveModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locomotiveNumber => $composableBuilder(
    column: $table.locomotiveNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locomotiveFactory => $composableBuilder(
    column: $table.locomotiveFactory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get haulingSection => $composableBuilder(
    column: $table.haulingSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emuModel => $composableBuilder(
    column: $table.emuModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emuNumber => $composableBuilder(
    column: $table.emuNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emuCapacity => $composableBuilder(
    column: $table.emuCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emuFormation => $composableBuilder(
    column: $table.emuFormation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emuDepot => $composableBuilder(
    column: $table.emuDepot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrainLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainLogsTable> {
  $$TrainLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainNumber => $composableBuilder(
    column: $table.trainNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seatClass => $composableBuilder(
    column: $table.seatClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get carriage => $composableBuilder(
    column: $table.carriage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seatNumber => $composableBuilder(
    column: $table.seatNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trainKind => $composableBuilder(
    column: $table.trainKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bureau => $composableBuilder(
    column: $table.bureau,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get depot => $composableBuilder(
    column: $table.depot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxSpeed => $composableBuilder(
    column: $table.maxSpeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locomotiveModel => $composableBuilder(
    column: $table.locomotiveModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locomotiveNumber => $composableBuilder(
    column: $table.locomotiveNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locomotiveFactory => $composableBuilder(
    column: $table.locomotiveFactory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get haulingSection => $composableBuilder(
    column: $table.haulingSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emuModel => $composableBuilder(
    column: $table.emuModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emuNumber => $composableBuilder(
    column: $table.emuNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emuCapacity => $composableBuilder(
    column: $table.emuCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emuFormation => $composableBuilder(
    column: $table.emuFormation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emuDepot => $composableBuilder(
    column: $table.emuDepot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrainLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainLogsTable> {
  $$TrainLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get trainNumber => $composableBuilder(
    column: $table.trainNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get departureStation => $composableBuilder(
    column: $table.departureStation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalStation => $composableBuilder(
    column: $table.arrivalStation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seatClass =>
      $composableBuilder(column: $table.seatClass, builder: (column) => column);

  GeneratedColumn<String> get carriage =>
      $composableBuilder(column: $table.carriage, builder: (column) => column);

  GeneratedColumn<String> get seatNumber => $composableBuilder(
    column: $table.seatNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get trainKind =>
      $composableBuilder(column: $table.trainKind, builder: (column) => column);

  GeneratedColumn<String> get bureau =>
      $composableBuilder(column: $table.bureau, builder: (column) => column);

  GeneratedColumn<String> get depot =>
      $composableBuilder(column: $table.depot, builder: (column) => column);

  GeneratedColumn<int> get maxSpeed =>
      $composableBuilder(column: $table.maxSpeed, builder: (column) => column);

  GeneratedColumn<String> get locomotiveModel => $composableBuilder(
    column: $table.locomotiveModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locomotiveNumber => $composableBuilder(
    column: $table.locomotiveNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locomotiveFactory => $composableBuilder(
    column: $table.locomotiveFactory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get haulingSection => $composableBuilder(
    column: $table.haulingSection,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emuModel =>
      $composableBuilder(column: $table.emuModel, builder: (column) => column);

  GeneratedColumn<String> get emuNumber =>
      $composableBuilder(column: $table.emuNumber, builder: (column) => column);

  GeneratedColumn<int> get emuCapacity => $composableBuilder(
    column: $table.emuCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emuFormation => $composableBuilder(
    column: $table.emuFormation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emuDepot =>
      $composableBuilder(column: $table.emuDepot, builder: (column) => column);
}

class $$TrainLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainLogsTable,
          TrainLog,
          $$TrainLogsTableFilterComposer,
          $$TrainLogsTableOrderingComposer,
          $$TrainLogsTableAnnotationComposer,
          $$TrainLogsTableCreateCompanionBuilder,
          $$TrainLogsTableUpdateCompanionBuilder,
          (TrainLog, BaseReferences<_$AppDatabase, $TrainLogsTable, TrainLog>),
          TrainLog,
          PrefetchHooks Function()
        > {
  $$TrainLogsTableTableManager(_$AppDatabase db, $TrainLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> trainNumber = const Value.absent(),
                Value<String> departureStation = const Value.absent(),
                Value<String> arrivalStation = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> departureTime = const Value.absent(),
                Value<String> arrivalTime = const Value.absent(),
                Value<String> seatClass = const Value.absent(),
                Value<String> carriage = const Value.absent(),
                Value<String> seatNumber = const Value.absent(),
                Value<int?> distanceKm = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> trainKind = const Value.absent(),
                Value<String> bureau = const Value.absent(),
                Value<String> depot = const Value.absent(),
                Value<int?> maxSpeed = const Value.absent(),
                Value<String> locomotiveModel = const Value.absent(),
                Value<String> locomotiveNumber = const Value.absent(),
                Value<String> locomotiveFactory = const Value.absent(),
                Value<String> haulingSection = const Value.absent(),
                Value<String> emuModel = const Value.absent(),
                Value<String> emuNumber = const Value.absent(),
                Value<int?> emuCapacity = const Value.absent(),
                Value<String> emuFormation = const Value.absent(),
                Value<String> emuDepot = const Value.absent(),
              }) => TrainLogsCompanion(
                id: id,
                trainNumber: trainNumber,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                date: date,
                departureTime: departureTime,
                arrivalTime: arrivalTime,
                seatClass: seatClass,
                carriage: carriage,
                seatNumber: seatNumber,
                distanceKm: distanceKm,
                rating: rating,
                notes: notes,
                trainKind: trainKind,
                bureau: bureau,
                depot: depot,
                maxSpeed: maxSpeed,
                locomotiveModel: locomotiveModel,
                locomotiveNumber: locomotiveNumber,
                locomotiveFactory: locomotiveFactory,
                haulingSection: haulingSection,
                emuModel: emuModel,
                emuNumber: emuNumber,
                emuCapacity: emuCapacity,
                emuFormation: emuFormation,
                emuDepot: emuDepot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String trainNumber,
                required String departureStation,
                required String arrivalStation,
                required DateTime date,
                Value<String> departureTime = const Value.absent(),
                Value<String> arrivalTime = const Value.absent(),
                Value<String> seatClass = const Value.absent(),
                Value<String> carriage = const Value.absent(),
                Value<String> seatNumber = const Value.absent(),
                Value<int?> distanceKm = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> trainKind = const Value.absent(),
                Value<String> bureau = const Value.absent(),
                Value<String> depot = const Value.absent(),
                Value<int?> maxSpeed = const Value.absent(),
                Value<String> locomotiveModel = const Value.absent(),
                Value<String> locomotiveNumber = const Value.absent(),
                Value<String> locomotiveFactory = const Value.absent(),
                Value<String> haulingSection = const Value.absent(),
                Value<String> emuModel = const Value.absent(),
                Value<String> emuNumber = const Value.absent(),
                Value<int?> emuCapacity = const Value.absent(),
                Value<String> emuFormation = const Value.absent(),
                Value<String> emuDepot = const Value.absent(),
              }) => TrainLogsCompanion.insert(
                id: id,
                trainNumber: trainNumber,
                departureStation: departureStation,
                arrivalStation: arrivalStation,
                date: date,
                departureTime: departureTime,
                arrivalTime: arrivalTime,
                seatClass: seatClass,
                carriage: carriage,
                seatNumber: seatNumber,
                distanceKm: distanceKm,
                rating: rating,
                notes: notes,
                trainKind: trainKind,
                bureau: bureau,
                depot: depot,
                maxSpeed: maxSpeed,
                locomotiveModel: locomotiveModel,
                locomotiveNumber: locomotiveNumber,
                locomotiveFactory: locomotiveFactory,
                haulingSection: haulingSection,
                emuModel: emuModel,
                emuNumber: emuNumber,
                emuCapacity: emuCapacity,
                emuFormation: emuFormation,
                emuDepot: emuDepot,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrainLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainLogsTable,
      TrainLog,
      $$TrainLogsTableFilterComposer,
      $$TrainLogsTableOrderingComposer,
      $$TrainLogsTableAnnotationComposer,
      $$TrainLogsTableCreateCompanionBuilder,
      $$TrainLogsTableUpdateCompanionBuilder,
      (TrainLog, BaseReferences<_$AppDatabase, $TrainLogsTable, TrainLog>),
      TrainLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrainLogsTableTableManager get trainLogs =>
      $$TrainLogsTableTableManager(_db, _db.trainLogs);
}
