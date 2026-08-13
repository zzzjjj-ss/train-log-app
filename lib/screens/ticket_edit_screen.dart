import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../widgets/ticket_card.dart';

/// 各可编辑文字在票面 viewBox 中的近似区域（红框定位）。
/// viewBox：x -10..180，y 88..186。
const Map<String, Rect> kEditRects = {
  'serialNumber': Rect.fromLTWH(12, 93, 60, 14),
  'gate': Rect.fromLTWH(138, 93, 32, 14),
  'departureStation': Rect.fromLTWH(16, 100, 55, 16),
  'trainNumber': Rect.fromLTWH(68, 100, 40, 16),
  'arrivalStation': Rect.fromLTWH(108, 100, 48, 16),
  'date': Rect.fromLTWH(20, 118, 60, 14),
  'departureTime': Rect.fromLTWH(82, 118, 42, 14),
  'carriage': Rect.fromLTWH(96, 118, 26, 14),
  'seatNumber': Rect.fromLTWH(124, 118, 26, 14),
  'price': Rect.fromLTWH(20, 125, 52, 14),
  'buyMarks': Rect.fromLTWH(76, 125, 22, 14),
  'seatClass': Rect.fromLTWH(112, 125, 40, 14),
  'limitNote': Rect.fromLTWH(20, 133, 62, 12),
  'idCard': Rect.fromLTWH(20, 144, 92, 12),
  'passengerName': Rect.fromLTWH(114, 144, 44, 12),
  'adLine1': Rect.fromLTWH(28, 154, 92, 11),
  'adLine2': Rect.fromLTWH(36, 160, 68, 11),
  'ticketNumber': Rect.fromLTWH(12, 168, 95, 12),
  'saleLocation': Rect.fromLTWH(110, 168, 48, 12),
};

/// 车票自定义编辑页（WYSIWYG）：红框点击文字 → 输入框 → 实时预览。
/// 只影响车票显示，不修改原记录数据。
class TicketEditScreen extends ConsumerStatefulWidget {
  final TrainLog log;
  final TicketOverride? existing;

  const TicketEditScreen({super.key, required this.log, this.existing});

  @override
  ConsumerState<TicketEditScreen> createState() => _TicketEditScreenState();
}

class _TicketEditScreenState extends ConsumerState<TicketEditScreen> {
  /// 当前编辑中的覆盖（key → 自定义文本），实时反映到票面
  late Map<String, String> _overrides;

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
    _overrides = existing;
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

  /// 点击红框 → 弹出输入框编辑该文字
  Future<void> _editField(String key) async {
    final label = kTicketTextFieldKeys.firstWhere((f) => f.key == key).label;
    final controller = TextEditingController(text: _overrides[key] ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('编辑 $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: '留空 = 保持原数据',
            counterText: '',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() {
        if (result.isNotEmpty) {
          _overrides[key] = result;
        } else {
          _overrides.remove(key);
        }
      });
    }
    controller.dispose();
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
        final dest =
            File('${bgDir.path}/ticket_${widget.log.id}.png');
        if (dest.path != _bgPath) {
          await File(_bgPath).copy(dest.path);
        }
        finalBg = dest.path;
      }
      await db.saveTicketOverrides(TicketOverridesCompanion(
        logId: Value(widget.log.id),
        overridesJson: Value(jsonEncode(_overrides)),
        bgImagePath: Value(finalBg),
        bgMode: Value(_bgMode),
      ));
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
    final ticketHeight = width * 98 / 190;

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑车票'),
        centerTitle: true,
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Center(
            child: Text(
              '点击红色框编辑文字，实时生效（仅影响显示，不改记录）',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 8),
          // ---- 实时预览 + 红框 ----
          SizedBox(
            width: width,
            height: ticketHeight,
            child: Stack(
              children: [
                TicketCard(
                  log: widget.log,
                  width: width,
                  idCardText: idCard,
                  passengerName: settings.passengerName,
                  textOverrides: _overrides,
                  bgImage: _bgPreview,
                  bgMode: _bgMode,
                ),
                // 红框覆盖层
                for (final e in kEditRects.entries) _buildEditBox(e.key, e.value),
              ],
            ),
          ),
          const Divider(height: 30),
          // ---- 背景图按钮（放下面） ----
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
        ],
      ),
    );
  }

  /// 单个红框（可点击弹出输入框），viewBox rect → widget 坐标
  Widget _buildEditBox(String key, Rect vb) {
    final left = (vb.left + 10) / 190;
    final top = (vb.top - 88) / 98;
    final w = vb.width / 190;
    final h = vb.height / 98;
    return Positioned(
      left: left * (MediaQuery.sizeOf(context).width - 16),
      top: top * ((MediaQuery.sizeOf(context).width - 16) * 98 / 190),
      width: w * (MediaQuery.sizeOf(context).width - 16),
      height: h * ((MediaQuery.sizeOf(context).width - 16) * 98 / 190),
      child: GestureDetector(
        onTap: () => _editField(key),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.red.shade400, width: 1.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: _overrides[key]?.isNotEmpty == true
              ? const Icon(Icons.edit, size: 10, color: Colors.red)
              : null,
        ),
      ),
    );
  }
}
