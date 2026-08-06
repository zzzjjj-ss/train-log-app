import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/log_form_screen.dart';

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
      ],
    ),
  ],
);

/// App 根组件：主题 + 路由
class TrainLogApp extends StatelessWidget {
  const TrainLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Material 3 主题，seedColor 决定整个 App 的主色调
    return MaterialApp.router(
      title: '铁路运转日志',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00696D), // 铁路青绿色
        ),
        // 让输入框更圆润
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}
