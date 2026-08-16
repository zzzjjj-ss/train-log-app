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

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  /// 缩放控制（1x ~ 6x）
  void _zoomBy(double factor) {
    final scale =
        (_transform.value.getMaxScaleOnAxis() * factor).clamp(1.0, 6.0);
    _transform.value = Matrix4.diagonal3Values(scale, scale, 1);
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: 6,
            boundaryMargin: const EdgeInsets.all(40),
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
      ),
    );
  }
}
