import 'package:flutter_test/flutter_test.dart';

import 'package:quan_ly_chi_tieu/src/core/services/sync_service.dart';
import 'package:quan_ly_chi_tieu/src/models/category.dart';
import 'package:quan_ly_chi_tieu/src/models/money_source.dart';
import 'package:quan_ly_chi_tieu/src/models/transaction.dart';

void main() {
  group('buildSyncSnapshot', () {
    test('purges expired soft-deleted records and compacts legacy fields', () {
      final now = DateTime.now();
      final expiredDeletedAt = now.subtract(const Duration(days: 45));
      final recentDeletedAt = now.subtract(const Duration(days: 7));

      final snapshot = buildSyncSnapshot(
        localCategories: [
          Category(
            id: 'keep-category',
            name: 'Keep',
            colorHex: 0xFF10B981,
            dbType: TransactionType.income.name,
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          Category(
            id: 'purge-category-local',
            name: 'Old deleted local',
            colorHex: 0xFFEF4444,
            dbType: TransactionType.expense.name,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteCategories: [
          Category(
            id: 'purge-category-remote',
            name: 'Old deleted remote',
            colorHex: 0xFF2563EB,
            type: TransactionType.expense,
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        localTransactions: [
          Transaction(
            id: 'keep-local',
            amount: 150000,
            dbType: TransactionType.income.name,
            categoryId: 'keep-category',
            date: now.subtract(const Duration(days: 3)),
            note: '',
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          Transaction(
            id: 'purge-local',
            amount: 50000,
            dbType: TransactionType.expense.name,
            categoryId: 'purge-category-local',
            date: expiredDeletedAt,
            note: '',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteTransactions: [
          Transaction(
            id: 'keep-remote',
            amount: 250000,
            type: TransactionType.expense,
            categoryId: 'keep-category',
            date: now.subtract(const Duration(days: 1)),
            note: '',
            updatedAt: now.subtract(const Duration(hours: 12)),
          ),
          Transaction(
            id: 'purge-remote',
            amount: 100000,
            type: TransactionType.expense,
            categoryId: 'purge-category-remote',
            date: expiredDeletedAt,
            note: '',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
          Transaction(
            id: 'keep-recent-delete',
            amount: 80000,
            type: TransactionType.expense,
            categoryId: 'keep-category',
            date: recentDeletedAt,
            note: '',
            updatedAt: recentDeletedAt,
            isDeleted: true,
          ),
        ],
        localMoneySources: [
          MoneySource(
            id: defaultMoneySourceId,
            name: 'Tiền mặt',
            updatedAt: now.subtract(const Duration(days: 2)),
          ),
          MoneySource(
            id: 'purge-source-local',
            name: 'Old deleted source local',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        remoteMoneySources: [
          MoneySource(
            id: 'bank',
            name: 'Ngân hàng',
            updatedAt: now.subtract(const Duration(days: 1)),
          ),
          MoneySource(
            id: 'purge-source-remote',
            name: 'Old deleted source remote',
            updatedAt: expiredDeletedAt,
            isDeleted: true,
          ),
        ],
        syncStartedAt: now,
        shouldPurgeSoftDeleted: true,
      );

      expect(
        snapshot.categories.map((category) => category.id),
        contains('keep-category'),
      );
      expect(
        snapshot.categories.map((category) => category.id),
        isNot(contains('purge-category-local')),
      );
      expect(
        snapshot.categories.map((category) => category.id),
        isNot(contains('purge-category-remote')),
      );

      expect(
        snapshot.moneySources.map((source) => source.id),
        containsAll([defaultMoneySourceId, 'bank']),
      );
      expect(
        snapshot.moneySources.map((source) => source.id),
        isNot(contains('purge-source-local')),
      );
      expect(
        snapshot.moneySources.map((source) => source.id),
        isNot(contains('purge-source-remote')),
      );

      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        containsAll(['keep-local', 'keep-remote', 'keep-recent-delete']),
      );
      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        isNot(contains('purge-local')),
      );
      expect(
        snapshot.transactions.map((transaction) => transaction.id),
        isNot(contains('purge-remote')),
      );

      final keepLocal = snapshot.transactions.firstWhere(
        (transaction) => transaction.id == 'keep-local',
      );
      expect(keepLocal.dbType, isNull);
      expect(keepLocal.note, isNull);
      expect(keepLocal.type, TransactionType.income);

      final keepCategory = snapshot.categories.firstWhere(
        (category) => category.id == 'keep-category',
      );
      expect(keepCategory.dbType, isNull);
      expect(keepCategory.type, TransactionType.income);

      expect(snapshot.purgedSoftDeleted, isTrue);
    });
  });
}
