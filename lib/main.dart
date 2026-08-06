import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// 程序入口。
/// ProviderScope 是 Riverpod 的"总开关"：
/// 整个 App 的数据共享（数据库等）都从这里开始分发。
void main() {
  runApp(const ProviderScope(child: TrainLogApp()));
}
