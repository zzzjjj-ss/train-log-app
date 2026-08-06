import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
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
              decoration: const InputDecoration(
                labelText: '车次 *',
                hintText: '例如 G1234',
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

