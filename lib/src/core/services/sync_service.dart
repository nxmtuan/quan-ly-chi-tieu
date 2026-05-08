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
    // 1. Download
    final remoteJsonString = await driveService.downloadData();
    
    // Remote data structures
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

    // 2. Merge Categories
    final localCategories = categoryBox.getAll();
    final localCategoryMap = {for (var cat in localCategories) cat.id: cat};

    for (final remoteCat in remoteCategories.values) {
      final localCat = localCategoryMap[remoteCat.id];
      if (localCat == null) {
        // Exists on remote, not local -> Insert
        categoryBox.put(remoteCat);
      } else {
        // Exists on both -> Merge based on updatedAt
        if (remoteCat.updatedAt.isAfter(localCat.updatedAt)) {
          remoteCat.obxId = localCat.obxId; // Preserve local ObjectBox ID
          categoryBox.put(remoteCat);
        }
      }
    }

    // 3. Merge Transactions
    final localTransactions = transactionBox.getAll();
    final localTransactionMap = {for (var tx in localTransactions) tx.id: tx};

    for (final remoteTx in remoteTransactions.values) {
      final localTx = localTransactionMap[remoteTx.id];
      if (localTx == null) {
        // Exists on remote, not local -> Insert
        transactionBox.put(remoteTx);
      } else {
        // Exists on both -> Merge based on updatedAt
        if (remoteTx.updatedAt.isAfter(localTx.updatedAt)) {
          remoteTx.obxId = localTx.obxId; // Preserve local ObjectBox ID
          transactionBox.put(remoteTx);
        }
      }
    }

    // 4. Clean up (Optional: Hard delete items marked as isDeleted > 30 days)
    // _cleanupDeletedItems();

    // 5. Push
    final finalLocalCategories = categoryBox.getAll();
    final finalLocalTransactions = transactionBox.getAll();

    final exportData = {
      'categories': finalLocalCategories.map((c) => c.toJson()).toList(),
      'transactions': finalLocalTransactions.map((t) => t.toJson()).toList(),
    };

    final exportJsonString = jsonEncode(exportData);
    await driveService.uploadData(exportJsonString);
  }
}
