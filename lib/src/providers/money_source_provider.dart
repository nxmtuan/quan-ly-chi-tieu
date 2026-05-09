import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/money_source.dart';
import 'storage_provider.dart';

class MoneySourcesNotifier extends Notifier<List<MoneySource>> {
  @override
  List<MoneySource> build() {
    final storedSources = ref
        .read(moneySourceStorageProvider)
        .readMoneySources(includeDeleted: true);

    final mergedSources = _mergeWithDefaultMoneySources(storedSources);
    final compactedSources = [
      for (final source in mergedSources) source.compactedForStorage(),
    ];
    final needsRewrite = !_listEqualsByContent(storedSources, mergedSources);

    if (needsRewrite) {
      unawaited(
        ref.read(moneySourceStorageProvider).replaceAllMoneySources([
          for (final source in compactedSources) source.copyWith(),
        ]),
      );
    }

    return _visibleMoneySources(needsRewrite ? compactedSources : mergedSources);
  }

  Future<void> addMoneySource(MoneySource source) async {
    state = [...state, source];
    await ref.read(moneySourceStorageProvider).putMoneySource(source);
  }

  Future<void> updateMoneySource(MoneySource source) async {
    if (isDefaultMoneySourceId(source.id)) {
      return;
    }

    state = [
      for (final item in state)
        if (item.id == source.id) source else item,
    ];
    await ref.read(moneySourceStorageProvider).putMoneySource(source);
  }

  Future<void> deleteMoneySource(String id) async {
    if (isDefaultMoneySourceId(id)) {
      return;
    }

    state = state.where((source) => source.id != id).toList();
    await ref.read(moneySourceStorageProvider).markMoneySourceDeleted(id);
  }

  static List<MoneySource> _visibleMoneySources(List<MoneySource> sources) {
    return [
      for (final source in sources)
        if (!source.isDeleted) source,
    ];
  }

  static List<MoneySource> _mergeWithDefaultMoneySources(
    List<MoneySource> storedSources,
  ) {
    final storedById = {
      for (final source in storedSources) source.id: source,
    };
    final merged = <MoneySource>[];

    for (final defaultSource in defaultMoneySources) {
      final storedSource = storedById.remove(defaultSource.id);
      if (storedSource == null) {
        merged.add(defaultSource.copyWith());
        continue;
      }

      final needsUpdate =
          storedSource.name != defaultSource.name ||
          storedSource.iconData.codePoint != defaultSource.iconData.codePoint ||
          storedSource.isDeleted;

      merged.add(
        needsUpdate
            ? storedSource.copyWith(
                name: defaultSource.name,
                iconData: defaultSource.iconData,
                updatedAt: DateTime.now(),
                isDeleted: false,
              )
            : storedSource,
      );
    }

    merged.addAll(storedById.values);
    return merged;
  }

  static bool _listEqualsByContent(List<MoneySource> a, List<MoneySource> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }

    for (var index = 0; index < a.length; index++) {
      final left = a[index];
      final right = b[index];
      if (left.id != right.id ||
          left.name != right.name ||
          left.iconData.codePoint != right.iconData.codePoint ||
          left.isDeleted != right.isDeleted) {
        return false;
      }
    }

    return true;
  }
}

final moneySourcesProvider =
    NotifierProvider<MoneySourcesNotifier, List<MoneySource>>(
  MoneySourcesNotifier.new,
);

final moneySourceByIdProvider = Provider.family<MoneySource?, String>((
  ref,
  id,
) {
  for (final source in ref.watch(moneySourcesProvider)) {
    if (source.id == id) {
      return source;
    }
  }

  return null;
});

final moneySourceLabelProvider = Provider.family<String, String>((ref, id) {
  final source = ref.watch(moneySourceByIdProvider(id));
  return source?.name ?? defaultMoneySources.first.name;
});
