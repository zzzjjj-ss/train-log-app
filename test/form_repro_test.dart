// 复现测试：打开表单页
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:train_log_app/data/database.dart';
import 'package:train_log_app/providers/providers.dart';
import 'package:train_log_app/screens/log_form_screen.dart';

void main() {
  testWidgets('打开新增表单页', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LogFormScreen()),
      ),
    );
    await tester.pump();
    expect(find.text('新增记录'), findsOneWidget);
  });
}

