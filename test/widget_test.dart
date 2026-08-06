// 冒烟测试：验证 App 能正常启动并显示主标题
import 'package:flutter/widgets.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:train_log_app/app.dart';
import 'package:train_log_app/data/database.dart';
import 'package:train_log_app/providers/providers.dart';

void main() {
  testWidgets('App 启动后显示标题', (WidgetTester tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    // runAsync: 让数据库的真实异步（计时器）能在测试里正常执行
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const TrainLogApp(),
        ),
      );
      await tester.pump();

      expect(find.text("铁路运转日志"), findsOneWidget);

      // 卸载组件树，让 drift 流清理计时器在真实异步里跑完
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  });
}

