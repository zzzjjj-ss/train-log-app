import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

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
