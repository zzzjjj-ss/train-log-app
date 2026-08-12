import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/providers.dart';
import '../services/backup_service.dart';

/// 预设主题色（车迷向）
const List<({String label, int value})> kThemeSeeds = [
  (label: '绿', value: 0xFF00696D),
  (label: '金', value: 0xFFB8860B),
  (label: '蓝', value: 0xFF1565C0),
  (label: '红', value: 0xFFC62828),
  (label: '灰蓝', value: 0xFF37474F),
  (label: '紫', value: 0xFF6A1B9A),
];

/// 设置页：主题色 + 外观模式
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  /// 导出全部数据为 JSON 并调起系统分享
  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final db = ref.read(databaseProvider);
      final json = await exportAllJson(db);
      await Share.shareXFiles(
        [
          XFile.fromData(
            utf8.encode(json),
            mimeType: 'application/json',
            name: 'train_log_backup.json',
          ),
        ],
        text: '铁路运转日志备份',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('导出失败: $e')));
    }
  }

  /// 选择备份文件并导入（覆盖或合并）
  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!context.mounted) return;
    final content = await File(result.files.single.path!).readAsString();
    if (!context.mounted) return;

    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择导入方式'),
        content: const Text('覆盖会清空现有数据（等同恢复备份）；合并会保留现有数据并追加。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'merge'),
            child: const Text('合并'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'overwrite'),
            child: const Text('覆盖'),
          ),
        ],
      ),
    );
    if (mode == null) return;

    try {
      final db = ref.read(databaseProvider);
      final n =
          await importFromJson(db, content, overwrite: mode == 'overwrite');
      messenger.showSnackBar(SnackBar(content: Text('已导入 $n 条记录')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('导入失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('主题色', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            children: [
              for (final s in kThemeSeeds)
                _ColorDot(
                  color: Color(s.value),
                  label: s.label,
                  selected: settings.seedValue == s.value,
                  onTap: () => notifier.setSeed(s.value),
                ),
            ],
          ),
          const SizedBox(height: 30),
          Text('外观', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'light',
                label: Text('浅色'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: 'dark',
                label: Text('深色'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
              ButtonSegment(
                value: 'system',
                label: Text('跟随系统'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (v) => notifier.setThemeMode(v.first),
          ),
          const SizedBox(height: 30),
          Text('数据管理', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('导出备份（JSON）'),
                  subtitle: const Text('全量备份到文件，可分享/保存'),
                  onTap: () => _exportBackup(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('导入备份（JSON）'),
                  subtitle: const Text('从备份文件恢复，可选覆盖或合并'),
                  onTap: () => _importBackup(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题色圆点选择器
class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(height: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
