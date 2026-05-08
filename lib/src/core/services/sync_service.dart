import 'dart:convert';

import '../network/google_drive_service.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../../objectbox.g.dart';

class SyncService {
  SyncService({
    required this.driveService,
    required this.transactionBox,
    required this.categoryBox,
  });

  final GoogleDriveService driveService;
  final Box<Transaction> transactionBox;
  final Box<Category> categoryBox;

  Future<void> syncData() async {
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

    final localCategories = categoryBox.getAll();
    final localCategoryMap = {for (var cat in localCategories) cat.id: cat};
    final mergedCategories = <String, Category>{...localCategoryMap};

    for (final remoteCat in remoteCategories.values) {
      final localCat = mergedCategories[remoteCat.id];
      if (localCat == null || remoteCat.updatedAt.isAfter(localCat.updatedAt)) {
        mergedCategories[remoteCat.id] = remoteCat;
      }
    }

    final localTransactions = transactionBox.getAll();
    final localTransactionMap = {for (var tx in localTransactions) tx.id: tx};
    final mergedTransactions = <String, Transaction>{...localTransactionMap};

    for (final remoteTx in remoteTransactions.values) {
      final localTx = mergedTransactions[remoteTx.id];
      if (localTx == null || remoteTx.updatedAt.isAfter(localTx.updatedAt)) {
        mergedTransactions[remoteTx.id] = remoteTx;
      }
    }

    final finalLocalCategories = [
      for (final category in mergedCategories.values)
        category.copyWith(obxId: 0),
    ];
    final finalLocalTransactions = [
      for (final transaction in mergedTransactions.values)
        transaction.copyWith(obxId: 0),
    ];

    categoryBox.removeAll();
    categoryBox.putMany(finalLocalCategories);
    transactionBox.removeAll();
    transactionBox.putMany(finalLocalTransactions);

    final exportData = {
      'categories': finalLocalCategories.map((c) => c.toJson()).toList(),
      'transactions': finalLocalTransactions.map((t) => t.toJson()).toList(),
    };

    final exportJsonString = jsonEncode(exportData);
    await driveService.uploadData(exportJsonString);
  }
}
