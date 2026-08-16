import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../providers/providers.dart';
import '../widgets/ticket_card.dart';
import 'ticket_edit_screen.dart';

/// 车票大图预览页：长按车票卡片进入。
/// 右上角提供「保存为图片」和「分享」。
class TicketPreviewScreen extends ConsumerStatefulWidget {
  final TrainLog log;

  const TicketPreviewScreen({super.key, required this.log});

  @override
  ConsumerState<TicketPreviewScreen> createState() =>
      _TicketPreviewScreenState();
}

class _TicketPreviewScreenState extends ConsumerState<TicketPreviewScreen> {
  final _boundaryKey = GlobalKey();
  final _transform = TransformationController();
  bool _busy = false;

  /// 视口尺寸（LayoutBuilder 时更新，按钮缩放以视口中心为锚点）
  Size _viewportSize = Size.zero;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// 缩放控制（1x ~ 6x），以视口中心为锚点（车票保持居中，不会偏移）
  void _zoomBy(double factor) {
    if (_viewportSize.isEmpty) return;
    final scale =
        (_transform.value.getMaxScaleOnAxis() * factor).clamp(1.0, 6.0);
    final c = Offset(_viewportSize.width / 2, _viewportSize.height / 2);
    // M' = T(c) * S(scale) * T(-c) * M：绕视口中心缩放，保留已有平移
    final m = Matrix4.identity()
      ..translateByDouble(c.dx, c.dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-c.dx, -c.dy, 0, 1)
      ..multiply(_transform.value);
    _transform.value = m;
  }

  /// 把车票渲染成 PNG 字节
  Future<Uint8List?> _capture() async {
    final r = _boundaryKey.currentContext?.findRenderObject();
    final RenderRepaintBoundary? boundary =
        r is RenderRepaintBoundary ? r : null;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 4);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  /// 保存为图片（应用文档目录）
  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception('渲染失败');
      await Gal.putImageBytes(
        bytes,
        name: 'ticket_${widget.log.trainNumber}.png',
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('已保存到相册')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('保存失败: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 分享图片
  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception('渲染失败');
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'ticket_${widget.log.trainNumber}.png',
          ),
        ],
        text: '${widget.log.trainNumber} ${widget.log.departureStation}'
            '→${widget.log.arrivalStation}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('分享失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }


  /// 打开编辑页；返回后 Stream 自动刷新
  Future<void> _openEditor() async {
    final existing =
        await ref.read(databaseProvider).getTicketOverrides(widget.log.id);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TicketEditScreen(log: widget.log, existing: existing),
      ),
    );
    ref.invalidate(ticketRenderProvider(widget.log.id));
  }

  /// 重置：确认后清除覆盖层，恢复原始车票（Stream 自动刷新）
  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重置车票？'),
        content: const Text('将清除所有自定义文字和背景图，恢复原始车票。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('重置'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(databaseProvider).clearTicketOverrides(widget.log.id);
    ref.invalidate(ticketRenderProvider(widget.log.id));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final render = ref.watch(ticketRenderProvider(widget.log.id)).valueOrNull;

    final idCard = [
      if (settings.idCardPrefix.isNotEmpty) settings.idCardPrefix,
      if (settings.idCardPrefix.isNotEmpty) '****',
      if (settings.idCardSuffix.isNotEmpty) settings.idCardSuffix,
    ].join();
    final width = MediaQuery.sizeOf(context).width - 16;

    return Scaffold(
      backgroundColor: const Color(0xFF101418),
      appBar: AppBar(
        title: const Text('车票预览'),
        centerTitle: true,
        actions: [
          if (render?.hasCustom == true)
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: '重置为原始车票',
              onPressed: _busy ? null : _reset,
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑车票',
            onPressed: _busy ? null : _openEditor,
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: '保存为图片',
            onPressed: _busy ? null : _save,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '分享',
            onPressed: _busy ? null : _share,
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_out),
              tooltip: '缩小',
              onPressed: () => _zoomBy(0.8),
            ),
            IconButton(
              icon: const Icon(Icons.crop_square),
              tooltip: '完整视图(1:1)',
              onPressed: () => _transform.value = Matrix4.identity(),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in),
              tooltip: '放大',
              onPressed: () => _zoomBy(1.25),
            ),
          ],
        ),
      ),
      // 视口撑满整个 body：InteractiveViewer 内部 ClipRect 会收缩到子组件
      // 大小，若直接包车票会导致缩放时车票只占据屏幕中间一条（上下露深色底）。
      // 因此子组件用视口等大的 SizedBox + Center，车票居中，缩放/平移以整个
      // 屏幕为视口。
      body: LayoutBuilder(
        builder: (context, constraints) {
          _viewportSize = constraints.biggest;
          return InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: 6,
            // 无限边界：放大后可自由平移，不会卡在初始位置
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: TicketCard(
                    log: widget.log,
                    width: width,
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
        },
      ),
    );
  }
}
