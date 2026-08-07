import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../utils/train_classify.dart';
import '../widgets/log_card.dart';

/// 主页：顶部统计 + 运转记录列表
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听数据库里的记录列表：任何增删改都会触发这里重建
    final logsAsync = ref.watch(logsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('铁路运转日志'),
        centerTitle: true,
      ),
      body: logsAsync.when(
        // 数据还没加载完
        loading: () => const Center(child: CircularProgressIndicator()),
        // 加载出错
        error: (err, _) => Center(child: Text('加载失败: $err')),
        // 加载成功
        data: (logs) {
          if (logs.isEmpty) {
            return _EmptyState();
          }
          final filter = ref.watch(trainFilterProvider);
          final filtered = filter == '全部'
              ? logs
              : logs
                  .where((l) => classifyTrainNumber(l.trainNumber) == filter)
                  .toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              _StatsSection(logs: filtered),
              const SizedBox(height: 8),
              _FilterChips(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                child: Text(
                  '共 ${filtered.length} 条记录',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              for (final log in filtered)
                // 右滑删除（左→右），confirmDismiss 弹确认框
                Dismissible(
                  key: ValueKey(log.id),
                  direction: DismissDirection.startToEnd,
                  background: _DismissBackground(),
                  confirmDismiss: (_) => _confirmDelete(context, ref, log),
                  onDismissed: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('已删除 ${log.trainNumber}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: LogCard(
                    log: log,
                    onTap: () => _openEdit(context, log),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    context.push('/add');
  }

  void _openEdit(BuildContext context, TrainLog log) {
    context.push('/edit', extra: log);
  }

  Future<bool> _confirmDelete(
      BuildContext context, WidgetRef ref, TrainLog log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条记录？'),
        content: Text('${log.trainNumber} ${log.departureStation} → ${log.arrivalStation}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteLog(log.id);
      return true;
    }
    return false;
  }
}

/// 顶部列车筛选 chips（全部/高铁G/动车D/城际C/普速）
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(trainFilterProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final option in kTrainFilterOptions)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(option.label),
                selected: filter == option.value,
                onSelected: (_) =>
                    ref.read(trainFilterProvider.notifier).state = option.value,
              ),
            ),
        ],
      ),
    );
  }
}

/// 右滑删除时的背景（红色 + 删除图标）
class _DismissBackground extends StatelessWidget {
  const _DismissBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8),
          Text('删除', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

/// 空状态：还没有任何记录时的引导界面
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.train, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text('还没有运转记录', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '点击右下角"记一笔"开始你的第一条\n铁路运转日志吧！',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计区块：总车次、总里程、最爱的车次
class _StatsSection extends StatelessWidget {
  final List<TrainLog> logs;

  const _StatsSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    // ---- 简单统计逻辑（纯 Dart 计算，便于理解）----
    final totalCount = logs.length; // 总乘坐次数

    var totalKm = 0; // 总里程
    for (final log in logs) {
      totalKm += (log.distanceKm ?? 0);
    }

    // 统计每个车次坐了多次，找出"最爱车次"
    final Map<String, int> countByTrain = {};
    for (final log in logs) {
      countByTrain[log.trainNumber] = (countByTrain[log.trainNumber] ?? 0) + 1;
    }
    String? favorite;
    var maxCount = 0;
    countByTrain.forEach((train, count) {
      if (count > maxCount) {
        maxCount = count;
        favorite = train;
      }
    });

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _StatItem(label: '乘坐次数', value: '$totalCount'),
          const SizedBox(width: 10),
          _StatItem(label: '累计里程', value: '$totalKm km'),
          const SizedBox(width: 10),
          _StatItem(label: '最爱车次', value: favorite ?? '-'),
        ],
      ),
    );
  }
}

/// 单个统计格子
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
