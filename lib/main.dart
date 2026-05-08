import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';
import 'src/providers/storage_provider.dart';
import 'src/core/storage/objectbox_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN');

  final sharedPreferences = await SharedPreferences.getInstance();
  final objectBoxDb = await ObjectBoxDatabase.create();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        objectBoxProvider.overrideWithValue(objectBoxDb),
      ],
      child: const ExpenseManagerApp(),
    ),
  );
}
