import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';

class RecentSearchesController extends Notifier<List<String>> {
  static const _maxEntries = 8;

  @override
  List<String> build() {
    return ref.read(localStoreProvider).recentSearches;
  }

  Future<void> add(String term) async {
    final normalized = term.trim();
    if (normalized.isEmpty) return;
    final next = <String>[
      normalized,
      for (final existing in state)
        if (existing.toLowerCase() != normalized.toLowerCase()) existing,
    ].take(_maxEntries).toList();
    state = next;
    await ref.read(localStoreProvider).setRecentSearches(next);
  }

  Future<void> clear() async {
    state = const [];
    await ref.read(localStoreProvider).setRecentSearches(const []);
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesController, List<String>>(
      RecentSearchesController.new,
    );
