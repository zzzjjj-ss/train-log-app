import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show decodeImageFromList;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';

/// 数据库实例的全局单例。
/// Riverpod 的 Provider：整个 App 里都能拿到同一个数据库对象，
/// App 关闭时自动调用 db.close() 释放资源。
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 运转记录列表的响应式数据源。
/// StreamProvider 订阅数据库的变化：
/// 只要数据库有增删改，watchAllLogs() 的 Stream 就会推送新列表，
/// 界面用 ref.watch(logsProvider) 就会自动刷新。
final logsProvider = StreamProvider<List<TrainLog>>((ref) {
  return ref.watch(databaseProvider).watchAllLogs();
});

/// 当前列车筛选条件（大类 majors + 小类 subs，均支持多选）
/// majors: 已选大类集合（'动车组'/'普速'）；subs: 已选小类集合（如'高铁'）
/// 全部为空 = 显示全部
final trainFilterProvider = StateProvider<({Set<String> majors, Set<String> subs})>(
  (ref) => (majors: <String>{}, subs: <String>{}),
);

/// SharedPreferences 单例（main() 里 override 注入）
final prefsProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

/// 应用设置（主题色 + 外观模式 + 卡片样式）
class AppSettings {
  /// 主题色 seed 值（int 形式的 Color 值）
  final int seedValue;

  /// 外观模式：light / dark / system
  final String themeMode;

  /// 记录卡片样式：normal=常规卡片，ticket=车票样式
  final String cardStyle;

  /// 身份证号前 10 位（仅本地保存，不出现在导出）
  final String idCardPrefix;

  /// 身份证号后 4 位（仅本地保存，不出现在导出）
  final String idCardSuffix;

  /// 乘车人姓名（仅本地保存，不出现在导出）
  final String passengerName;

  const AppSettings({
    this.seedValue = 0xFF00696D,
    this.themeMode = 'system',
    this.cardStyle = 'normal',
    this.idCardPrefix = '',
    this.idCardSuffix = '',
    this.passengerName = '',
  });
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(prefsProvider);
    return AppSettings(
      seedValue: prefs.getInt('seedValue') ?? 0xFF00696D,
      themeMode: prefs.getString('themeMode') ?? 'system',
      cardStyle: prefs.getString('cardStyle') ?? 'normal',
      idCardPrefix: prefs.getString('idCardPrefix') ?? '',
      idCardSuffix: prefs.getString('idCardSuffix') ?? '',
      passengerName: prefs.getString('passengerName') ?? '',
    );
  }

  /// 切换主题色并持久化
  void setSeed(int value) {
    state = AppSettings(
      seedValue: value,
      themeMode: state.themeMode,
      cardStyle: state.cardStyle,
      idCardPrefix: state.idCardPrefix,
      idCardSuffix: state.idCardSuffix,
      passengerName: state.passengerName,
    );
    ref.read(prefsProvider).setInt('seedValue', value);
  }

  /// 切换外观模式（浅色/深色/跟随系统）并持久化
  void setThemeMode(String mode) {
    state = AppSettings(
      seedValue: state.seedValue,
      themeMode: mode,
      cardStyle: state.cardStyle,
      idCardPrefix: state.idCardPrefix,
      idCardSuffix: state.idCardSuffix,
      passengerName: state.passengerName,
    );
    ref.read(prefsProvider).setString('themeMode', mode);
  }

  /// 切换卡片样式（常规 / 车票）并持久化
  void setCardStyle(String style) {
    state = AppSettings(
      seedValue: state.seedValue,
      themeMode: state.themeMode,
      cardStyle: style,
      idCardPrefix: state.idCardPrefix,
      idCardSuffix: state.idCardSuffix,
      passengerName: state.passengerName,
    );
    ref.read(prefsProvider).setString('cardStyle', style);
  }

  /// 保存乘车人信息（身份证前10/后4 + 姓名），仅本地
  void setPassengerInfo({
    required String idCardPrefix,
    required String idCardSuffix,
    required String passengerName,
  }) {
    state = AppSettings(
      seedValue: state.seedValue,
      themeMode: state.themeMode,
      cardStyle: state.cardStyle,
      idCardPrefix: idCardPrefix,
      idCardSuffix: idCardSuffix,
      passengerName: passengerName,
    );
    final prefs = ref.read(prefsProvider);
    prefs.setString('idCardPrefix', idCardPrefix);
    prefs.setString('idCardSuffix', idCardSuffix);
    prefs.setString('passengerName', passengerName);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// 搜索关键词（主页搜索栏输入）
final searchKeywordProvider = StateProvider<String>((ref) => '');

/// 搜索栏是否展开
final searchExpandedProvider = StateProvider<bool>((ref) => false);

/// 全部本务机车按记录分组（搜索多台机车用）
final locomotivesMapProvider = FutureProvider<Map<int, List<Locomotive>>>(
  (ref) => ref.watch(databaseProvider).getAllLocomotivesByLog(),
);

// ============ 车票自定义覆盖层（v8） ============

/// 单张车票的渲染数据：文字覆盖 + 背景图 + 映射模式
class TicketRenderData {
  final Map<String, String> textOverrides;
  final ui.Image? bgImage;
  final String bgMode;

  const TicketRenderData({
    required this.textOverrides,
    this.bgImage,
    this.bgMode = 'cover',
  });

  /// 是否有任何自定义（用于决定是否显示"重置"按钮）
  bool get hasCustom =>
      textOverrides.values.any((v) => v.isNotEmpty) || bgImage != null;
}

/// 加载某条记录的车票覆盖层（文字覆盖 + 背景图解码）。
/// 无覆盖返回 null；编辑保存后调用 ref.invalidate 刷新。
/// 加载某条记录的车票覆盖层（文字覆盖 + 背景图解码）。
/// 用 StreamProvider 监听覆盖表，DB 变化自动推送，无需手动 invalidate。
final ticketRenderProvider =
    StreamProvider.family<TicketRenderData?, int>((ref, logId) async* {
  final db = ref.watch(databaseProvider);
  yield* db.watchTicketOverrides(logId).asyncMap((ov) async {
    if (ov == null) return null;

    Map<String, String> text = {};
    if (ov.overridesJson.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(ov.overridesJson);
        if (decoded is Map) {
          text = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
        }
      } catch (_) {}
    }

    ui.Image? img;
    if (ov.bgImagePath.isNotEmpty) {
      try {
        final bytes = await File(ov.bgImagePath).readAsBytes();
        img = await decodeImageFromList(bytes);
      } catch (_) {}
    }
    return TicketRenderData(
      textOverrides: text,
      bgImage: img,
      bgMode: ov.bgMode,
    );
  });
});
