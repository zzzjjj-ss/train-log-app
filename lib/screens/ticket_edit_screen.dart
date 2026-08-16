import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../widgets/ticket_card.dart';

/// 车票自定义编辑页（列表形式）：可编辑票面所有文字 + 替换背景图。
/// 只影响车票显示，不修改原记录数据。
class TicketEditScreen extends ConsumerStatefulWidget {
  final TrainLog log;
  final TicketOverride? existing;

  const TicketEditScreen({super.key, required this.log, this.existing});

  @override
  ConsumerState<TicketEditScreen> createState() => _TicketEditScreenState();
}

class _TicketEditScreenState extends ConsumerState<TicketEditScreen> {
  late final Map<String, TextEditingController> _controllers;
  late String _bgPath; // 背景图源路径
  late String _bgMode;
  ui.Image? _bgPreview; // 预览背景图

  @override
  void initState() {
    super.initState();
    final ov = widget.existing;
    Map<String, String> existing = {};
    if (ov != null && ov.overridesJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(ov.overridesJson);
        if (decoded is Map) {
          existing =
              decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
    }
    _controllers = {
      for (final f in kTicketTextFieldKeys)
        f.key: TextEditingController(text: existing[f.key] ?? ''),
    };
    _bgPath = ov?.bgImagePath ?? '';
    _bgMode = ov?.bgMode ?? 'cover';
    _loadPreviewBg(_bgPath);
  }

  Future<void> _loadPreviewBg(String path) async {
    if (path.isEmpty) return;
    try {
      final bytes = await File(path).readAsBytes();
      final img = await decodeImageFromList(bytes);
      if (mounted) setState(() => _bgPreview = img);
    } catch (_) {}
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 选择背景图 → 解码预览（保存时复制到应用目录）
  Future<void> _pickBackground() async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result == null || result.files.single.path == null) return;
    try {
      final path = result.files.single.path!;
      final bytes = await File(path).readAsBytes();
      final img = await decodeImageFromList(bytes);
      if (mounted) {
        setState(() {
          _bgPath = path;
          _bgPreview = img;
        });
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('背景导入失败: $e')));
    }
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(databaseProvider);
      // 背景图复制到应用文档目录 ticket_bg/
      String finalBg = '';
      if (_bgPath.isNotEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        final bgDir = Directory('${dir.path}/ticket_bg');
        await bgDir.create(recursive: true);
        final dest = File('${bgDir.path}/ticket_${widget.log.id}.png');
        if (dest.path != _bgPath) {
          await File(_bgPath).copy(dest.path);
        }
        finalBg = dest.path;
      }
      final overrides = <String, String>{};
      for (final f in kTicketTextFieldKeys) {
        final v = _controllers[f.key]!.text.trim();
        if (v.isNotEmpty) overrides[f.key] = v;
      }
      await db.saveTicketOverrides(TicketOverridesCompanion(
        logId: Value(widget.log.id),
        overridesJson: Value(jsonEncode(overrides)),
        bgImagePath: Value(finalBg),
        bgMode: Value(_bgMode),
      ));
      // 强制刷新（Stream 自动刷新的双保险）
      ref.invalidate(ticketRenderProvider(widget.log.id));
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          const SnackBar(content: Text('已保存车票自定义（不影响实际记录）')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final idCard = [
      if (settings.idCardPrefix.isNotEmpty) settings.idCardPrefix,
      if (settings.idCardPrefix.isNotEmpty) '****',
      if (settings.idCardSuffix.isNotEmpty) settings.idCardSuffix,
    ].join();
    final width = MediaQuery.sizeOf(context).width - 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑车票'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- 实时预览 ----
          Center(
            child: TicketCard(
              log: widget.log,
              width: width,
              idCardText: idCard,
              passengerName: settings.passengerName,
              textOverrides: _currentOverrides(),
              bgImage: _bgPreview,
              bgMode: _bgMode,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '仅修改车票显示，不会更改实际记录；留空 = 保持原数据。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const Divider(height: 30),
          Text('票面文字', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final f in kTicketTextFieldKeys)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _controllers[f.key],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: f.label,
                  hintText: _originalValue(f.key),
                  counterText: '',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          const Divider(height: 30),
          // ---- 背景图按钮放下面 ----
          Text('背景图', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'cover', label: Text('铺满(cover)')),
              ButtonSegment(value: 'contain', label: Text('完整(contain)')),
              ButtonSegment(value: 'fill', label: Text('拉伸(fill)')),
            ],
            selected: {_bgMode},
            onSelectionChanged: (v) => setState(() => _bgMode = v.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: _pickBackground,
                icon: const Icon(Icons.image),
                label: Text(_bgPath.isEmpty ? '选择背景图' : '更换背景图'),
              ),
              if (_bgPath.isNotEmpty) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => setState(() {
                    _bgPath = '';
                    _bgPreview = null;
                  }),
                  child: const Text('清除背景'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 当前编辑中的覆盖（实时预览用）
  Map<String, String> _currentOverrides() {
    final m = <String, String>{};
    for (final f in kTicketTextFieldKeys) {
      final v = _controllers[f.key]!.text.trim();
      if (v.isNotEmpty) m[f.key] = v;
    }
    return m;
  }

  /// 各字段的原始值（作为 hint 提示）
  String _originalValue(String key) {
    final l = widget.log;
    switch (key) {
      case 'trainNumber':
        return '原: ${l.trainNumber}';
      case 'departureStation':
        return '原: ${l.departureStation}';
      case 'arrivalStation':
        return '原: ${l.arrivalStation}';
      case 'depSuffix':
        return '原: 站';
      case 'arrSuffix':
        return '原: 站';
      case 'date':
        return '原: ${_fmtDate(l.date)}';
      case 'departureTime':
        return '原: ${l.departureTime}';
      case 'carriage':
        return '原: ${l.carriage}';
      case 'seatNumber':
        return '原: ${l.seatNumber}';
      case 'seatClass':
        return '原: ${l.seatClass}';
      case 'price':
        return '原: ${l.price}';
      case 'gate':
        return '原: ${l.gate}';
      case 'buyMarks':
        return '原: ${l.buyMarks}';
      case 'serialNumber':
        return '原: ${l.serialNumber}';
      case 'ticketNumber':
        return '原: ${l.ticketNumber}';
      case 'saleLocation':
        return '原: ${l.saleLocation}';
      case 'limitNote':
        return '原: 限乘当日当次车';
      case 'adLine1':
        return '原: 买票请到12306发货请到95306';
      case 'adLine2':
        return '原: 中国铁路祝您旅途愉快';
      default:
        return '';
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}年${d.month.toString().padLeft(2, '0')}月'
      '${d.day.toString().padLeft(2, '0')}日';
}
