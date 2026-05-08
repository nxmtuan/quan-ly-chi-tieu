import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'src/app.dart';
import 'src/providers/storage_provider.dart';
import 'src/core/storage/objectbox_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');

  final objectBoxDb = await ObjectBoxDatabase.create();

  runApp(
    ProviderScope(
      overrides: [
        objectBoxProvider.overrideWithValue(objectBoxDb),
      ],
      child: const ExpenseManagerApp(),
    ),
  );
}
