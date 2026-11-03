import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_providers.dart';

class WishlistController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final raw = ref.read(localStoreProvider).wishlistJson;
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return {for (final id in decoded) id as String};
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _persist(Set<String> next) async {
    state = AsyncData(next);
    await ref
        .read(localStoreProvider)
        .setWishlistJson(jsonEncode(next.toList()));
  }

  Future<bool> toggle(String productId) async {
    final current = {...(state.value ?? <String>{})};
    final nowSaved = !current.contains(productId);
    if (nowSaved) {
      current.add(productId);
    } else {
      current.remove(productId);
    }
    await _persist(current);
    return nowSaved;
  }

  Future<void> remove(String productId) async {
    final current = {...(state.value ?? <String>{})}..remove(productId);
    await _persist(current);
  }
}

final wishlistControllerProvider =
    AsyncNotifierProvider<WishlistController, Set<String>>(
      WishlistController.new,
    );

final wishlistIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(wishlistControllerProvider).value ?? <String>{};
});
