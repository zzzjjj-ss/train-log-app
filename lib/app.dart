import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/providers.dart';
import 'screens/about_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_form_screen.dart';
import 'screens/settings_screen.dart';

/// 全局路由表：集中管理所有页面地址
final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        // 新增记录
        GoRoute(
          path: 'add',
          builder: (context, state) => const LogFormScreen(),
        ),
        // 编辑记录（用 extra 把原记录对象传进来）
        GoRoute(
          path: 'edit',
          builder: (context, state) =>
              LogFormScreen(editing: state.extra as dynamic),
        ),
        // 设置
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        // 关于
        GoRoute(
          path: 'about',
          builder: (context, state) => const AboutScreen(),
        ),
      ],
    ),
  ],
);

/// App 根组件：主题（响应设置）+ 路由
class TrainLogApp extends ConsumerWidget {
  const TrainLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听用户设置：主题色 + 外观模式
    final settings = ref.watch(settingsProvider);
    final seed = Color(settings.seedValue);
    final themeMode = switch (settings.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: '铁路运转日志',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        // 让输入框更圆润
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
