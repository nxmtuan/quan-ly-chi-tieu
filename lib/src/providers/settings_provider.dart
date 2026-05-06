import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeToggleNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled({required bool value}) {
    state = value;
  }
}

final themeToggleProvider = NotifierProvider<ThemeToggleNotifier, bool>(
  ThemeToggleNotifier.new,
);
