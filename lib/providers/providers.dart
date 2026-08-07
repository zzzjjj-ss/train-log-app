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

/// 应用设置（主题色 + 外观模式）
class AppSettings {
  /// 主题色 seed 值（int 形式的 Color 值）
  final int seedValue;

  /// 外观模式：light / dark / system
  final String themeMode;

  const AppSettings({
    this.seedValue = 0xFF00696D,
    this.themeMode = 'system',
  });
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(prefsProvider);
    return AppSettings(
      seedValue: prefs.getInt('seedValue') ?? 0xFF00696D,
      themeMode: prefs.getString('themeMode') ?? 'system',
    );
  }

  /// 切换主题色并持久化
  void setSeed(int value) {
    state = AppSettings(seedValue: value, themeMode: state.themeMode);
    ref.read(prefsProvider).setInt('seedValue', value);
  }

  /// 切换外观模式（浅色/深色/跟随系统）并持久化
  void setThemeMode(String mode) {
    state = AppSettings(seedValue: state.seedValue, themeMode: mode);
    ref.read(prefsProvider).setString('themeMode', mode);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
