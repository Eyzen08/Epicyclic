import 'dart:convert';

import '../../../core/storage/local_store.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/app_user.dart';
import '../domain/address.dart';
import 'profile_repository.dart';

class DemoProfileRepository implements ProfileRepository {
  DemoProfileRepository(this._store, this._auth);

  final LocalStore _store;
  final AuthRepository _auth;

  @override
  Future<AppUser?> getProfile() async => _auth.currentUser;

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    return _auth.updateProfile(fullName: fullName, phone: phone);
  }

  @override
  Future<List<Address>> getAddresses() async {
    final user = _auth.currentUser;
    if (user == null) return const [];
    final raw = _store.demoAddressesJson;
    if (raw == null) {
      final seeded = <Address>[
        Address(
          id: 'addr-home',
          fullName: user.fullName,
          line1: 'Unit 12, 123 Sample Street',
          line2: 'Barangay San Lorenzo',
          city: 'Makati City',
          state: 'Metro Manila',
          postalCode: '1223',
          country: 'Philippines',
          phone: user.phone ?? '+63 917 555 0147',
          isDefault: true,
        ),
      ];
      await _persist(seeded);
      return seeded;
    }
    return [
      for (final item in jsonDecode(raw) as List<dynamic>)
        Address.fromJson(item as Map<String, dynamic>),
    ];
  }

  @override
  Future<Address> saveAddress(Address address) async {
    final addresses = await getAddresses();
    final normalizedId = address.id.trim().isEmpty
        ? 'addr-${DateTime.now().millisecondsSinceEpoch}'
        : address.id;
    var saved = address.copyWith(isDefault: address.isDefault);
    if (addresses.isEmpty) saved = saved.copyWith(isDefault: true);

    final updated = <Address>[
      for (final existing in addresses)
        if (existing.id != normalizedId)
          saved.isDefault ? existing.copyWith(isDefault: false) : existing,
      Address(
        id: normalizedId,
        fullName: saved.fullName,
        line1: saved.line1,
        line2: saved.line2,
        city: saved.city,
        state: saved.state,
        postalCode: saved.postalCode,
        country: saved.country,
        phone: saved.phone,
        isDefault: saved.isDefault,
      ),
    ];
    await _persist(updated);
    return updated.firstWhere((item) => item.id == normalizedId);
  }

  @override
  Future<void> deleteAddress(String id) async {
    final addresses = await getAddresses();
    final remaining = addresses.where((address) => address.id != id).toList();
    if (remaining.isNotEmpty &&
        !remaining.any((address) => address.isDefault)) {
      remaining[0] = remaining.first.copyWith(isDefault: true);
    }
    await _persist(remaining);
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    final addresses = await getAddresses();
    await _persist([
      for (final address in addresses)
        address.copyWith(isDefault: address.id == id),
    ]);
  }

  Future<void> _persist(List<Address> addresses) {
    return _store.setDemoAddressesJson(
      jsonEncode(addresses.map((address) => address.toJson()).toList()),
    );
  }
}
