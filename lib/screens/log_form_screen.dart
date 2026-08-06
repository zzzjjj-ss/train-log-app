import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/emu_models.dart';
import '../providers/providers.dart';

/// 常见席别选项（供下拉选择）
const List<String> kSeatClasses = [
  '二等座', '一等座', '商务座', '硬座', '软座',
  '硬卧', '软卧', '动卧', '无座', '其他',
];

/// 添加 / 编辑运转记录的表单页。
/// - 不传 editing：新增
/// - 传 editing：编辑（表单里预填原数据）
class LogFormScreen extends ConsumerStatefulWidget {
  final TrainLog? editing;

  const LogFormScreen({super.key, this.editing});

  @override
  ConsumerState<LogFormScreen> createState() => _LogFormScreenState();
}

class _LogFormScreenState extends ConsumerState<LogFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _trainNumber;
  late final TextEditingController _departureStation;
  late final TextEditingController _arrivalStation;
  late final TextEditingController _carriage;
  late final TextEditingController _seatNumber;
  late final TextEditingController _distance;
  late final TextEditingController _notes;

  late DateTime _date;
  late String _departureTime;
  late String _arrivalTime;
  late String _seatClass;
  late int _rating;

  // ===== 车迷扩展字段（v2） =====
  late final TextEditingController _bureau;          // 路局
  late final TextEditingController _depot;           // 段
  late final TextEditingController _maxSpeed;        // 最高时速
  late final TextEditingController _locomotiveModel; // 机车型号
  late final TextEditingController _locomotiveNumber; // 机车编号
  late final TextEditingController _locomotiveFactory; // 制造厂
  late final TextEditingController _haulingSection; // 牵引区间
  late final TextEditingController _emuModel;       // 动车组型号
  late final TextEditingController _emuNumber;      // 动车组编号
  late final TextEditingController _emuCapacity;    // 定员
  late final TextEditingController _emuFormation;   // 编组
  late final TextEditingController _emuDepot;       // 配属
  late final TextEditingController _carNumber;      // 车厢编号

  late String _trainKind; // 列车种类

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _trainNumber = TextEditingController(text: e?.trainNumber ?? '');
    _departureStation = TextEditingController(text: e?.departureStation ?? '');
    _arrivalStation = TextEditingController(text: e?.arrivalStation ?? '');
    _carriage = TextEditingController(text: e?.carriage ?? '');
    _seatNumber = TextEditingController(text: e?.seatNumber ?? '');
    _distance = TextEditingController(text: e?.distanceKm?.toString() ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _date = e?.date ?? DateTime.now();
    _departureTime = e?.departureTime ?? '';
    _arrivalTime = e?.arrivalTime ?? '';
    _seatClass = e?.seatClass ?? '二等座';
    _rating = e?.rating ?? 5;

    // ===== v2 字段初始化 =====
    _trainKind = e?.trainKind ?? '动车组';
    _bureau = TextEditingController(text: e?.bureau ?? '');
    _depot = TextEditingController(text: e?.depot ?? '');
    _maxSpeed = TextEditingController(text: e?.maxSpeed?.toString() ?? '');
    _locomotiveModel = TextEditingController(text: e?.locomotiveModel ?? '');
    _locomotiveNumber = TextEditingController(text: e?.locomotiveNumber ?? '');
    _locomotiveFactory = TextEditingController(text: e?.locomotiveFactory ?? '');
    _haulingSection = TextEditingController(text: e?.haulingSection ?? '');
    _emuModel = TextEditingController(text: e?.emuModel ?? '');
    _emuNumber = TextEditingController(text: e?.emuNumber ?? '');
    _emuCapacity = TextEditingController(text: e?.emuCapacity?.toString() ?? '');
    _emuFormation = TextEditingController(text: e?.emuFormation ?? '');
    _emuDepot = TextEditingController(text: e?.emuDepot ?? '');
  }

  @override
  void dispose() {
    _trainNumber.dispose();
    _departureStation.dispose();
    _arrivalStation.dispose();
    _carriage.dispose();
    _seatNumber.dispose();
    _distance.dispose();
    _notes.dispose();
    _bureau.dispose();
    _depot.dispose();
    _maxSpeed.dispose();
    _locomotiveModel.dispose();
    _locomotiveNumber.dispose();
    _locomotiveFactory.dispose();
    _haulingSection.dispose();
    _emuModel.dispose();
    _emuNumber.dispose();
    _emuCapacity.dispose();
    _emuFormation.dispose();
    _emuDepot.dispose();
    _carNumber.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime({required bool isDeparture}) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: now.hour, minute: now.minute),
    );
    if (picked != null) {
      final formatted = DateFormat('HH:mm').format(
        DateTime(2024, 1, 1, picked.hour, picked.minute),
      );
      setState(() {
        if (isDeparture) {
          _departureTime = formatted;
        } else {
          _arrivalTime = formatted;
        }
      });
    }
  }

  /// 根据车次前缀自动识别列车种类：
  /// G/D/C → 动车组；K/T/Z/Y/L/S/N/纯数字 → 普速机辆
  void _autoDetectTrainKind(String value) {
    final v = value.trim().toUpperCase();
    if (v.isEmpty) return;

    String? kind;
    if (v.startsWith('G') || v.startsWith('D') || v.startsWith('C')) {
      kind = '动车组';
    } else if (v.startsWith('K') || v.startsWith('T') || v.startsWith('Z') ||
        v.startsWith('Y') || v.startsWith('L') || v.startsWith('S') ||
        v.startsWith('N')) {
      kind = '普速机辆';
    } else if (RegExp(r'^\d').hasMatch(v)) {
      kind = '普速机辆'; // 纯数字车次（普通旅客列车）
    }

    if (kind != null && kind != _trainKind) {
      setState(() => _trainKind = kind!);
    }
  }

  Future<void> _save() async {
    // 表单校验：必填项是否合法
    if (!_formKey.currentState!.validate()) return;

    final db = ref.read(databaseProvider);

    // 把表单数据组装成数据库可接受的"增量行"
    final companion = TrainLogsCompanion(
      id: _isEditing ? Value(widget.editing!.id) : const Value.absent(),
      trainNumber: Value(_trainNumber.text.trim()),
      departureStation: Value(_departureStation.text.trim()),
      arrivalStation: Value(_arrivalStation.text.trim()),
      date: Value(_date),
      departureTime: Value(_departureTime),
      arrivalTime: Value(_arrivalTime),
      seatClass: Value(_seatClass),
      carriage: Value(_carriage.text.trim()),
      seatNumber: Value(_seatNumber.text.trim()),
      distanceKm: Value(int.tryParse(_distance.text.trim())),
      rating: Value(_rating),
      notes: Value(_notes.text.trim()),
      // ===== v2 车迷字段 =====
      trainKind: Value(_trainKind),
      bureau: Value(_bureau.text.trim()),
      depot: Value(_depot.text.trim()),
      maxSpeed: Value(int.tryParse(_maxSpeed.text.trim())),
      locomotiveModel: Value(_locomotiveModel.text.trim()),
      locomotiveNumber: Value(_locomotiveNumber.text.trim()),
      locomotiveFactory: Value(_locomotiveFactory.text.trim()),
      haulingSection: Value(_haulingSection.text.trim()),
      emuModel: Value(_emuModel.text.trim()),
      emuNumber: Value(_emuNumber.text.trim()),
      emuCapacity: Value(int.tryParse(_emuCapacity.text.trim())),
      emuFormation: Value(_emuFormation.text.trim()),
      emuDepot: Value(_emuDepot.text.trim()),
      carNumber: Value(_carNumber.text.trim()),
    );

    if (_isEditing) {
      await db.updateLog(companion);
    } else {
      await db.addLog(companion);
    }

    if (mounted) Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑记录' : '新增记录'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- 车次（必填）----
            TextFormField(
              controller: _trainNumber,
              onChanged: _autoDetectTrainKind,
              decoration: const InputDecoration(
                labelText: '车次 *',
                hintText: '例如 G1234（自动识别动车/普速）',
                prefixIcon: Icon(Icons.train),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '请输入车次' : null,
            ),
            const SizedBox(height: 14),

            // ---- 乘车日期 ----
            _FieldLabel(
              label: '乘车日期',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: Text(DateFormat('yyyy年M月d日').format(_date)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDate,
              ),
            ),

            // ---- 出发站 → 到达站 ----
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _departureStation,
                    decoration: const InputDecoration(
                      labelText: '出发站',
                      prefixIcon: Icon(Icons.trip_origin),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _arrivalStation,
                    decoration: const InputDecoration(
                      labelText: '到达站',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ---- 发车/到达时间 ----
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: '发车时间',
                    value: _departureTime,
                    onTap: () => _pickTime(isDeparture: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TimeField(
                    label: '到达时间',
                    value: _arrivalTime,
                    onTap: () => _pickTime(isDeparture: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ---- 席别下拉 ----
            DropdownButtonFormField<String>(
              initialValue: _seatClass,
              decoration: const InputDecoration(
                labelText: '席别',
                prefixIcon: Icon(Icons.airline_seat_recline_normal),
                border: OutlineInputBorder(),
              ),
              items: kSeatClasses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _seatClass = v ?? '二等座'),
            ),
            const SizedBox(height: 14),

            // ---- 列车种类（决定显示机车还是动车组字段）----
            DropdownButtonFormField<String>(
              initialValue: _trainKind,
              decoration: const InputDecoration(
                labelText: '列车种类',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: const ['动车组', '普速机辆', '其他']
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _trainKind = v ?? '动车组'),
            ),
            const SizedBox(height: 18),

            // ---- 乘务信息（通用） ----
            const _SectionTitle(title: '乘务信息'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bureau,
                    decoration: const InputDecoration(
                      labelText: '值乘路局',
                      hintText: '如 上海局',
                      prefixIcon: Icon(Icons.account_balance),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _depot,
                    decoration: const InputDecoration(
                      labelText: '机务段 / 车辆段',
                      hintText: '如 上海机务段',
                      prefixIcon: Icon(Icons.factory),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _maxSpeed,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '最高时速',
                suffixText: 'km/h',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),


            // ---- 根据列车种类动态显示：动车组 或 本务机车 ----
            if (_trainKind == '动车组') ...[
              const _SectionTitle(title: '动车组信息'),
              Row(
                children: [
                  // 车型自动补全：输入即过滤内置车型库，选中自动填编组/定员
                  Expanded(
                    flex: 3,
                    child: Autocomplete<EmuModel>(
                      initialValue: TextEditingValue(text: _emuModel.text),
                      optionsBuilder: (TextEditingValue v) {
                        if (v.text.isEmpty) return kEmuModels.take(8);
                        final kw = v.text.trim().toUpperCase();
                        return kEmuModels
                            .where((m) =>
                                m.name.toUpperCase().contains(kw) ||
                                m.note.contains(kw))
                            .toList()
                            .take(8);
                      },
                      displayStringForOption: (m) => m.name,
                      onSelected: (m) {
                        // 自动补全编组和定员
                        _emuModel.text = m.name;
                        if (_emuFormation.text.trim().isEmpty) {
                          _emuFormation.text = m.formation;
                        }
                        if (m.capacity != null &&
                            _emuCapacity.text.trim().isEmpty) {
                          _emuCapacity.text = m.capacity.toString();
                        }
                        setState(() {});
                      },
                      fieldViewBuilder: (context, controller, focusNode,
                          onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: '动车组型号',
                            hintText: '如 CR400BF',
                            prefixIcon: Icon(Icons.directions_railway),
                            border: OutlineInputBorder(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _emuNumber,
                      decoration: const InputDecoration(
                        labelText: '动车组编号',
                        hintText: '如 CR400BF-5033',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _emuFormation,
                      decoration: const InputDecoration(
                        labelText: '编组',
                        hintText: '如 8、16',
                        prefixIcon: Icon(Icons.view_day),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _emuCapacity,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '定员',
                        suffixText: '人',
                        prefixIcon: Icon(Icons.groups),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emuDepot,
                decoration: const InputDecoration(
                  labelText: '配属动车所',
                  hintText: '如 广州南动车所',
                  prefixIcon: Icon(Icons.home_work),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
            ] else if (_trainKind == '普速机辆') ...[
              const _SectionTitle(title: '本务机车信息'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locomotiveModel,
                      decoration: const InputDecoration(
                        labelText: '机车型号',
                        hintText: '如 HXD3D、SS9G',
                        prefixIcon: Icon(Icons.directions_railway),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _locomotiveNumber,
                      decoration: const InputDecoration(
                        labelText: '机车编号',
                        hintText: '如 HXD3D-0031',
                        prefixIcon: Icon(Icons.tag),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locomotiveFactory,
                      decoration: const InputDecoration(
                        labelText: '制造厂',
                        hintText: '如 大连机车',
                        prefixIcon: Icon(Icons.build),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _haulingSection,
                      decoration: const InputDecoration(
                        labelText: '牵引区间',
                        hintText: '如 北京—广州',
                        prefixIcon: Icon(Icons.route),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],

            // ---- 车厢 / 座位 ----
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _carriage,
                    decoration: const InputDecoration(
                      labelText: '车厢',
                      hintText: '如 08 车',
                      prefixIcon: Icon(Icons.door_sliding),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _seatNumber,
                    decoration: const InputDecoration(
                      labelText: '座位号',
                      hintText: '如 12F',
                      prefixIcon: Icon(Icons.event_seat),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ---- 车厢编号（车种代码+编号，如 ZYS102001）----
            TextFormField(
              controller: _carNumber,
              decoration: const InputDecoration(
                labelText: '车厢编号',
                hintText: '如 ZYS102001（车种代码+编号）',
                prefixIcon: Icon(Icons.qr_code_2),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            // ---- 里程 ----
            TextFormField(
              controller: _distance,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '里程（公里）',
                prefixIcon: Icon(Icons.straighten),
                suffixText: 'km',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            // ---- 评分 ----
            _FieldLabel(
              label: '体验评分',
              child: Row(
                children: List.generate(5, (i) {
                  final starIndex = i + 1;
                  return IconButton(
                    icon: Icon(
                      starIndex <= _rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber.shade600,
                      size: 30,
                    ),
                    onPressed: () => setState(() => _rating = starIndex),
                  );
                }),
              ),
            ),

            // ---- 备注 ----
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '备注 / 心情',
                hintText: '这趟车印象如何？',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // ---- 保存按钮 ----
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 区块标题（用于乘务信息、动车组信息等大分组）
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 小节标题（用于日期、评分这类非输入框字段）
class _FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldLabel({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        child,
        const SizedBox(height: 6),
      ],
    );
  }
}

/// 时间选择卡片（点一下弹时间选择器）
class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          value.isEmpty ? '--:--' : value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

