import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../screens/ticket_preview_screen.dart';
import '../utils/search.dart';
import 'ticket_card.dart';

/// 单条运转记录的卡片组件。
/// 传入一条 TrainLog，渲染成一站漂亮的卡片。
class LogCard extends ConsumerWidget {
  final TrainLog log;
  final VoidCallback? onTap;
  final List<SearchHit> searchHits;

  const LogCard({
    super.key,
    required this.log,
    this.onTap,
    this.searchHits = const <SearchHit>[],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy年M月d日').format(log.date);

    // 车票样式：设置里开启后，整张卡片渲染为车票模板
    if (ref.watch(settingsProvider).cardStyle == 'ticket') {
      return _buildTicketCard(context, ref);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行：车次徽章 + 日期 + 评分
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.trainNumber,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dateStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Colors.amber.shade600,
                  ),
                  Text(
                    ' ${log.rating}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 第二行：出发站 → 到达站（带箭头）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      log.departureStation,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      log.arrivalStation,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 第三行：时间 / 席别 / 里程
              Row(
                children: [
                  _InfoChip(icon: Icons.schedule, text: _timeRange()),
                  const SizedBox(width: 8),
                  _InfoChip(icon: Icons.airline_seat_recline_normal, text: log.seatClass),
                  if (log.distanceKm != null && log.distanceKm! > 0) ...[
                    const SizedBox(width: 8),
                    _InfoChip(icon: Icons.straighten, text: '${log.distanceKm} km'),
                  ],
                ],
              ),
              // 第四行：车型信息（车迷重点关注）
              if (log.trainKind == '普速机辆' ||
                  _rollingStockLine(log) != null) ...[
                const SizedBox(height: 8),
                if (log.trainKind == '普速机辆')
                  // 本务机车可能多台（换挂/重联），从数据库加载显示
                  _LocomotiveList(logId: log.id, fallback: _rollingStockLine(log))
                else
                  Row(
                    children: [
                      _InfoChip(icon: Icons.directions_railway, text: _rollingStockLine(log)!),
                      if (log.maxSpeed != null && log.maxSpeed! > 0) ...[
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.speed, text: '${log.maxSpeed} km/h'),
                      ],
                      if (log.bureau.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.account_balance, text: log.bureau),
                      ],
                      if (log.carNumber.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _InfoChip(icon: Icons.qr_code_2, text: log.carNumber),
                      ],
                    ],
                  ),
              ],
              // 搜索高亮标签（搜索时显示匹配原因）
              if (searchHits.isNotEmpty) ...[_SearchHighlight(hits: searchHits)],
            ],
          ),
        ),
      ),
    );
  }

  /// 车票样式卡片：渲染为定稿车票模板，点击仍进入编辑
  Widget _buildTicketCard(BuildContext context, WidgetRef ref) {
    final screenW = MediaQuery.sizeOf(context).width;
    final w = (screenW - 32 - 16).clamp(240.0, 480.0); // 留出卡片边距，限制最大宽
    final settings = ref.watch(settingsProvider);
    final render = ref.watch(ticketRenderProvider(log.id)).valueOrNull;
    final idCard = [
      if (settings.idCardPrefix.isNotEmpty) settings.idCardPrefix,
      if (settings.idCardPrefix.isNotEmpty) '****',
      if (settings.idCardSuffix.isNotEmpty) settings.idCardSuffix,
    ].join();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      color: Colors.transparent,
      clipBehavior: Clip.none,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TicketPreviewScreen(log: log),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Center(
            child: TicketCard(
              log: log,
              width: w,
              idCardText: idCard,
              passengerName: settings.passengerName,
              textOverrides: render?.textOverrides,
              bgImage: render?.bgImage,
              bgMode: render?.bgMode ?? 'cover',
            ),
          ),
        ),
      ),
    );
  }

  String _timeRange() {
    final dep = log.departureTime;
    final arr = log.arrivalTime;
    if (dep.isEmpty && arr.isEmpty) return '--:--';
    // 跨天行程：到达时间前加"次日/第3天"等标记
    String arrLabel = arr;
    if (log.arrivalDayOffset > 0 && arr.isNotEmpty) {
      const dayNames = ['', '次日', '第3天', '第4天', '第5天'];
      final offset = log.arrivalDayOffset;
      final tag = offset < dayNames.length ? dayNames[offset] : '第${offset + 1}天';
      arrLabel = '$tag $arr';
    }
    if (dep.isEmpty) return '→ $arrLabel';
    if (arr.isEmpty) return '$dep →';
    return '$dep → $arrLabel';
  }

  /// 生成车型信息：动车组/机车 的 型号+编号 智能拼接
  /// 例：CR400BF + 5033 → CR400BF-5033；CR400BF-5033 → CR400BF-5033（不重复拼）
  String? _rollingStockLine(TrainLog log) {
    if (log.trainKind == '动车组') {
      final model = log.emuModel.trim();
      final num = log.emuNumber.trim();
      if (model.isEmpty && num.isEmpty) return null;
      if (model.isEmpty) return num;
      if (num.isEmpty) return model;
      // 编号已含型号（CR400BF-5033）时不重复拼接
      final modelPrefix = model.split('-').first;
      if (num.startsWith(model) || num.startsWith(modelPrefix)) return num;
      return '$model-$num';
    }
    if (log.trainKind == '普速机辆') {
      final model = log.locomotiveModel.trim();
      final num = log.locomotiveNumber.trim();
      if (model.isEmpty && num.isEmpty) return null;
      if (model.isEmpty) return num;
      if (num.isEmpty) return model;
      if (num.startsWith(model) || num.contains(model)) return num;
      return '$model-$num';
    }
    return null;
  }
}

/// 底部小标签（时间/席别/里程）
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

/// 本务机车列表展示（支持多台：换挂/重联）
class _LocomotiveList extends ConsumerWidget {
  final int logId;
  final String? fallback;

  const _LocomotiveList({required this.logId, this.fallback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    return FutureBuilder<List<Locomotive>>(
      future: db.getLocomotives(logId),
      builder: (context, snap) {
        final locos = snap.data;
        // 旧数据兜底：locomotives 表无记录时用同步的旧字段
        if (locos == null || locos.isEmpty) {
          if (fallback == null || fallback!.isEmpty) {
            return const SizedBox.shrink();
          }
          return Row(
            children: [
              _InfoChip(icon: Icons.directions_railway, text: fallback!),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final l in locos)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoChip(
                      icon: Icons.directions_railway,
                      text: l.number.isNotEmpty
                          ? '${l.model}·${l.number}'
                          : l.model,
                    ),
                    if (l.haulingSection.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      _InfoChip(icon: Icons.route, text: l.haulingSection),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
/// 搜索高亮标签（主题色，备注关键词高亮加粗下划线）
class _SearchHighlight extends StatelessWidget {
  final List<SearchHit> hits;
  const _SearchHighlight({required this.hits});

  Widget _buildText(BuildContext context, SearchHit hit) {
    final theme = Theme.of(context);
    final base = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
    );
    final hl = hit.highlight;
    if (hl == null || !hit.text.contains(hl)) {
      return Text(hit.text, style: base);
    }
    final idx = hit.text.indexOf(hl);
    final spans = <TextSpan>[];
    if (idx > 0) spans.add(TextSpan(text: hit.text.substring(0, idx)));
    spans.add(TextSpan(
      text: hl,
      style: base?.copyWith(
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
        decorationColor: theme.colorScheme.primary,
      ),
    ));
    if (idx + hl.length < hit.text.length) {
      spans.add(TextSpan(text: hit.text.substring(idx + hl.length)));
    }
    return Text.rich(TextSpan(children: spans, style: base));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            for (final hit in hits)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.45),
                  ),
                ),
                child: _buildText(context, hit),
              ),
          ],
        ),
      ],
    );
  }
}
