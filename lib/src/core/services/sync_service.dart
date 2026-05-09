import 'dart:convert';

import '../network/google_drive_service.dart';
import '../storage/settings_storage.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../../objectbox.g.dart';

class SyncService {
  SyncService({
    required this.driveService,
    required this.settingsStorage,
    required this.transactionBox,
    required this.categoryBox,
  });

  final DriveSyncClient driveService;
  final SettingsStorage settingsStorage;
  final Box<Transaction> transactionBox;
  final Box<Category> categoryBox;

  Future<void> syncData() async {
    final syncStartedAt = DateTime.now();
    final remoteJsonString = await driveService.downloadData();
    final Map<String, Transaction> remoteTransactions = {};
    final Map<String, Category> remoteCategories = {};

    if (remoteJsonString != null && remoteJsonString.isNotEmpty) {
      final decoded = jsonDecode(remoteJsonString) as Map<String, dynamic>;

      final txList = decoded['transactions'] as List<dynamic>? ?? [];
      for (final txJson in txList) {
        final tx = Transaction.fromJson(txJson as Map<String, dynamic>);
        remoteTransactions[tx.id] = tx;
      }

      final catList = decoded['categories'] as List<dynamic>? ?? [];
      for (final catJson in catList) {
        final cat = Category.fromJson(catJson as Map<String, dynamic>);
        remoteCategories[cat.id] = cat;
      }
    }

    final shouldPurgeSoftDeleted = settingsStorage.isSoftDeletePurgeDue(
      now: syncStartedAt,
    );
    final snapshot = buildSyncSnapshot(
      localCategories: categoryBox.getAll(),
      remoteCategories: remoteCategories.values,
      localTransactions: transactionBox.getAll(),
      remoteTransactions: remoteTransactions.values,
      syncStartedAt: syncStartedAt,
      shouldPurgeSoftDeleted: shouldPurgeSoftDeleted,
    );

    final exportData = {
      'categories': snapshot.categories.map((c) => c.toJson()).toList(),
      'transactions': snapshot.transactions.map((t) => t.toJson()).toList(),
    };

    final exportJsonString = jsonEncode(exportData);
    await driveService.uploadData(exportJsonString);

    categoryBox.removeAll();
    categoryBox.putMany(snapshot.categories);
    transactionBox.removeAll();
    transactionBox.putMany(snapshot.transactions);

    if (snapshot.purgedSoftDeleted) {
      await settingsStorage.saveLastSoftDeletePurgeAt(syncStartedAt);
    }
  }

  Future<bool> deleteRemoteData() {
    return driveService.deleteData();
  }
}

SyncSnapshot buildSyncSnapshot({
  required Iterable<Category> localCategories,
  required Iterable<Category> remoteCategories,
  required Iterable<Transaction> localTransactions,
  required Iterable<Transaction> remoteTransactions,
  required DateTime syncStartedAt,
  required bool shouldPurgeSoftDeleted,
}) {
  final localCategoryMap = {for (final cat in localCategories) cat.id: cat};
  final mergedCategories = <String, Category>{...localCategoryMap};

  for (final remoteCat in remoteCategories) {
    final localCat = mergedCategories[remoteCat.id];
    if (localCat == null || remoteCat.updatedAt.isAfter(localCat.updatedAt)) {
      mergedCategories[remoteCat.id] = remoteCat;
    }
  }

  final localTransactionMap = {
    for (final transaction in localTransactions) transaction.id: transaction,
  };
  final mergedTransactions = <String, Transaction>{...localTransactionMap};

  for (final remoteTx in remoteTransactions) {
    final localTx = mergedTransactions[remoteTx.id];
    if (localTx == null || remoteTx.updatedAt.isAfter(localTx.updatedAt)) {
      mergedTransactions[remoteTx.id] = remoteTx;
    }
  }

  var compactedCategories = [
    for (final category in mergedCategories.values)
      category.compactedForStorage().copyWith(obxId: 0),
  ];
  var compactedTransactions = [
    for (final transaction in mergedTransactions.values)
      transaction.compactedForStorage().copyWith(obxId: 0),
  ];

  if (shouldPurgeSoftDeleted) {
    final purgeCutoff = syncStartedAt.subtract(
      SettingsStorage.softDeleteRetention,
    );
    compactedCategories = [
      for (final category in compactedCategories)
        if (!_shouldPurgeDeleted(
          category.isDeleted,
          category.updatedAt,
          purgeCutoff,
        ))
          category,
    ];
    compactedTransactions = [
      for (final transaction in compactedTransactions)
        if (!_shouldPurgeDeleted(
          transaction.isDeleted,
          transaction.updatedAt,
          purgeCutoff,
        ))
          transaction,
    ];
  }

  return SyncSnapshot(
    categories: compactedCategories,
    transactions: compactedTransactions,
    purgedSoftDeleted: shouldPurgeSoftDeleted,
  );
}

bool _shouldPurgeDeleted(bool isDeleted, DateTime updatedAt, DateTime cutoff) {
  return isDeleted && !updatedAt.isAfter(cutoff);
}

class SyncSnapshot {
  const SyncSnapshot({
    required this.categories,
    required this.transactions,
    required this.purgedSoftDeleted,
  });

  final List<Category> categories;
  final List<Transaction> transactions;
  final bool purgedSoftDeleted;
}
