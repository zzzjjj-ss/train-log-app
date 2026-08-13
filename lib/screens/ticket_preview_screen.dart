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
  bool _busy = false;

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

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: RepaintBoundary(
            key: _boundaryKey,
            child: TicketCard(
              log: widget.log,
              width: width,
              idCardText: idCard,
              passengerName: settings.passengerName,
            ),
          ),
        ),
      ),
    );
  }
}
