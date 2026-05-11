import 'dart:convert';

import '../network/google_drive_service.dart';
import '../background/background_recurring.dart';
import '../storage/recurring_storage.dart';
import '../storage/settings_storage.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/money_source.dart';
import '../../models/recurring_item.dart';
import '../../../objectbox.g.dart';

class SyncService {
  SyncService({
    required this.driveService,
    required this.settingsStorage,
    required this.transactionBox,
    required this.categoryBox,
    required this.moneySourceBox,
    required this.recurringStorage,
  });

  final DriveSyncClient driveService;
  final SettingsStorage settingsStorage;
  final Box<Transaction> transactionBox;
  final Box<Category> categoryBox;
  final Box<MoneySource> moneySourceBox;
  final RecurringStorage recurringStorage;

  Future<void> syncData() async {
    final syncStartedAt = DateTime.now();
    final remoteJsonString = await driveService.downloadData();
    final Map<String, Transaction> remoteTransactions = {};
    final Map<String, Category> remoteCategories = {};
    final Map<String, MoneySource> remoteMoneySources = {};
    final Map<String, RecurringItem> remoteRecurringItems = {};

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

      final sourceList = decoded['moneySources'] as List<dynamic>? ?? [];
      for (final sourceJson in sourceList) {
        final source = MoneySource.fromJson(sourceJson as Map<String, dynamic>);
        remoteMoneySources[source.id] = source;
      }

      final recurringList = decoded['recurringItems'] as List<dynamic>? ?? [];
      for (final recurringJson in recurringList) {
        final recurring = RecurringItem.fromJson(
          recurringJson as Map<String, dynamic>,
        );
        remoteRecurringItems[recurring.id] = recurring;
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
      localMoneySources: moneySourceBox.getAll(),
      remoteMoneySources: remoteMoneySources.values,
      localRecurringItems: recurringStorage.readItems(),
      remoteRecurringItems: remoteRecurringItems.values,
      syncStartedAt: syncStartedAt,
      shouldPurgeSoftDeleted: shouldPurgeSoftDeleted,
    );

    final exportData = {
      'categories': snapshot.categories.map((c) => c.toJson()).toList(),
      'moneySources': snapshot.moneySources.map((s) => s.toJson()).toList(),
      'transactions': snapshot.transactions.map((t) => t.toJson()).toList(),
      'recurringItems': snapshot.recurringItems
          .map((item) => item.compactedForStorage().toJson())
          .toList(),
    };

    final exportJsonString = jsonEncode(exportData);
    await driveService.uploadData(exportJsonString);

    categoryBox.removeAll();
    categoryBox.putMany(snapshot.categories);
    moneySourceBox.removeAll();
    moneySourceBox.putMany(snapshot.moneySources);
    transactionBox.removeAll();
    transactionBox.putMany(snapshot.transactions);
    await recurringStorage.saveItems(snapshot.recurringItems);
    await configureRecurringBackgroundProcessingFromStorage(recurringStorage);

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
  required Iterable<MoneySource> localMoneySources,
  required Iterable<MoneySource> remoteMoneySources,
  required Iterable<RecurringItem> localRecurringItems,
  required Iterable<RecurringItem> remoteRecurringItems,
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

  final localMoneySourceMap = {
    for (final source in localMoneySources) source.id: source,
  };
  final mergedMoneySources = <String, MoneySource>{...localMoneySourceMap};

  for (final remoteSource in remoteMoneySources) {
    final localSource = mergedMoneySources[remoteSource.id];
    if (localSource == null ||
        remoteSource.updatedAt.isAfter(localSource.updatedAt)) {
      mergedMoneySources[remoteSource.id] = remoteSource;
    }
  }

  final localRecurringItemMap = {
    for (final item in localRecurringItems) item.id: item,
  };
  final mergedRecurringItems = <String, RecurringItem>{
    ...localRecurringItemMap,
  };

  for (final remoteItem in remoteRecurringItems) {
    final localItem = mergedRecurringItems[remoteItem.id];
    if (localItem == null ||
        remoteItem.updatedAt.isAfter(localItem.updatedAt)) {
      mergedRecurringItems[remoteItem.id] = remoteItem;
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
  var compactedMoneySources = [
    for (final source in mergedMoneySources.values)
      source.compactedForStorage().copyWith(obxId: 0),
  ];
  var mergedRecurringItemList = [
    for (final item in mergedRecurringItems.values) item,
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
    compactedMoneySources = [
      for (final source in compactedMoneySources)
        if (!_shouldPurgeDeleted(
          source.isDeleted,
          source.updatedAt,
          purgeCutoff,
        ))
          source,
    ];
    mergedRecurringItemList = [
      for (final item in mergedRecurringItemList)
        if (!_shouldPurgeDeleted(item.isDeleted, item.updatedAt, purgeCutoff))
          item,
    ];
  }

  return SyncSnapshot(
    categories: compactedCategories,
    moneySources: compactedMoneySources,
    transactions: compactedTransactions,
    recurringItems: mergedRecurringItemList,
    purgedSoftDeleted: shouldPurgeSoftDeleted,
  );
}

bool _shouldPurgeDeleted(bool isDeleted, DateTime updatedAt, DateTime cutoff) {
  return isDeleted && !updatedAt.isAfter(cutoff);
}

class SyncSnapshot {
  const SyncSnapshot({
    required this.categories,
    required this.moneySources,
    required this.transactions,
    required this.recurringItems,
    required this.purgedSoftDeleted,
  });

  final List<Category> categories;
  final List<MoneySource> moneySources;
  final List<Transaction> transactions;
  final List<RecurringItem> recurringItems;
  final bool purgedSoftDeleted;
}
