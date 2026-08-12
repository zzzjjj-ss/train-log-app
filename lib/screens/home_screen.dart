import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../utils/train_classify.dart';
import '../utils/search.dart';
import '../widgets/log_card.dart';

/// 主页：顶部统计 + 运转记录列表
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听数据库里的记录列表：任何增删改都会触发这里重建
    final logsAsync = ref.watch(logsProvider);
    final locoMapAsync = ref.watch(locomotivesMapProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: '设置',
          onPressed: () => context.push('/settings'),
        ),
        title: const Text('铁路运转日志'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '关于',
            onPressed: () => context.push('/about'),
          ),
        ],
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
          final locoMap = locoMapAsync.maybeWhen(
            data: (m) => m,
            orElse: () => const <int, List<Locomotive>>{},
          );
          final keyword = ref.watch(searchKeywordProvider);
          final searchExpanded = ref.watch(searchExpandedProvider);
          final filter = ref.watch(trainFilterProvider);
          final hitsMap = <int, List<String>>{};
          final filtered = logs.where((l) {
            final hits =
                matchKeywordFields(l, locoMap[l.id] ?? const [], keyword);
            hitsMap[l.id] = hits;
            if (keyword.trim().isNotEmpty && hits.isEmpty) {
              return false;
            }
            if (filter.majors.isNotEmpty || filter.subs.isNotEmpty) {
              return matchTrainFilter(
                  l.trainNumber, filter.majors, filter.subs);
            }
            return true;
          }).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              _StatsSection(logs: filtered),
              const SizedBox(height: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: searchExpanded
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          _SearchBar(),
                          SizedBox(height: 8),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
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
                    searchHits: hitsMap[log.id] ?? const [],
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

/// 顶部关键词搜索栏（带输入控制器，清除时同步清空输入框）
class _SearchBar extends ConsumerStatefulWidget {
  const _SearchBar();

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(searchKeywordProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(searchKeywordProvider.notifier).state = '';
  }

  @override
  Widget build(BuildContext context) {
    final keyword = ref.watch(searchKeywordProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: _controller,
        onChanged: (v) => ref.read(searchKeywordProvider.notifier).state = v,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '搜索车次、车站、车型、编号…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: keyword.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: '清除',
                  onPressed: _clear,
                ),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// 列车筛选 chips：大类（动车组/普速）与小类均可多选
class _FilterChips extends ConsumerWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(trainFilterProvider);
    final searchExpanded = ref.watch(searchExpandedProvider);
    final notifier = ref.read(trainFilterProvider.notifier);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- 大类行（全部/动车组/普速，多选）----
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(searchExpanded ? Icons.search_off : Icons.search),
                  tooltip: searchExpanded ? '收起搜索' : '展开搜索',
                  onPressed: () =>
                      ref.read(searchExpandedProvider.notifier).state =
                          !searchExpanded,
                  style: IconButton.styleFrom(
                    backgroundColor: searchExpanded
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('全部'),
                  selected: f.majors.isEmpty,
                  onSelected: (_) => notifier.state = (majors: <String>{}, subs: <String>{}),
                ),
              ),
              for (final major in kTrainMajorOptions)
                if (major != '全部')
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(major),
                      selected: f.majors.contains(major),
                      onSelected: (sel) {
                        final majors = Set<String>.of(f.majors);
                        if (sel) {
                          majors.add(major);
                        } else {
                          majors.remove(major);
                        }
                        notifier.state = (majors: majors, subs: f.subs);
                      },
                    ),
                  ),
            ],
          ),
        ),
        // ---- 每个已选大类的下小类行（多选）----
        for (final major in kTrainMajorOptions)
          if (major != '全部' && f.majors.contains(major))
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '$major：',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final sub in kTrainSubOptions[major]!)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(kTrainSubLabels[sub] ?? sub),
                        visualDensity: VisualDensity.compact,
                        selected: f.subs.contains(sub),
                        onSelected: (sel) {
                          final subs = Set<String>.of(f.subs);
                          if (sel) {
                            subs.add(sub);
                          } else {
                            subs.remove(sub);
                          }
                          notifier.state = (majors: f.majors, subs: subs);
                        },
                      ),
                    ),
                ],
              ),
            ),
      ],
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
