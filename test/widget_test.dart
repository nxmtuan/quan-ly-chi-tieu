// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quan_ly_chi_tieu/objectbox.g.dart';
import 'package:quan_ly_chi_tieu/src/app.dart';
import 'package:quan_ly_chi_tieu/src/core/storage/objectbox_database.dart';
import 'package:quan_ly_chi_tieu/src/features/home/widgets/recent_transactions.dart';
import 'package:quan_ly_chi_tieu/src/features/home/widgets/summary_card.dart';
import 'package:quan_ly_chi_tieu/src/models/auth_user.dart';
import 'package:quan_ly_chi_tieu/src/providers/storage_provider.dart';

void main() {
  testWidgets('Expense manager home screen renders current dashboard', (
    tester,
  ) async {
    final store = await openStore(directory: 'memory:test-db-${DateTime.now().millisecondsSinceEpoch}');
    final objectBoxDb = ObjectBoxDatabase.createForTest(store);

    final authUser = AuthUser(
      id: "test",
      email: "test@example.com",
      name: "Test User",
      lastLoginAt: DateTime.parse("2026-05-06T10:00:00.000"),
    );
    store.box<AuthUser>().put(authUser);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          objectBoxProvider.overrideWithValue(objectBoxDb),
        ],
        child: const ExpenseManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Quản lý tài chính'), findsOneWidget);
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.byType(RecentTransactions), findsOneWidget);
    
    store.close();
  }, skip: Platform.isWindows);
}
