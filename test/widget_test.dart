// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quan_ly_chi_tieu/src/app.dart';
import 'package:quan_ly_chi_tieu/src/features/home/widgets/recent_transactions.dart';
import 'package:quan_ly_chi_tieu/src/features/home/widgets/summary_card.dart';
import 'package:quan_ly_chi_tieu/src/providers/storage_provider.dart';

void main() {
  testWidgets('Expense manager home screen renders current dashboard', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
      'authUser',
      '{"id":"test","email":"test@example.com","name":"Test User","lastLoginAt":"2026-05-06T10:00:00.000","photoUrl":null}',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const ExpenseManagerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tổng quan'), findsWidgets);
    expect(find.text('Quản lý tài chính'), findsOneWidget);
    expect(find.byType(SummaryCard), findsOneWidget);
    expect(find.byType(RecentTransactions), findsOneWidget);
  });
}
