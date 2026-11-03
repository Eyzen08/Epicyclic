import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/domain/app_user.dart';
import '../domain/address.dart';
import 'profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client, this._auth);

  final SupabaseClient _client;
  final AuthRepository _auth;

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw const AuthFailure('Sign in to continue.');
    return user.id;
  }

  @override
  Future<AppUser?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row == null) {
        return AppUser(
          id: user.id,
          email: user.email ?? '',
          fullName: (user.userMetadata?['full_name'] as String?) ?? 'Customer',
          phone: user.phone,
        );
      }
      return AppUser(
        id: user.id,
        email: user.email ?? '',
        fullName: (row['full_name'] as String?) ?? 'Customer',
        phone: row['phone'] as String?,
        avatarUrl: row['avatar_url'] as String?,
      );
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<AppUser> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    final updated = await _auth.updateProfile(fullName: fullName, phone: phone);
    try {
      await _client.from('profiles').upsert({
        'id': updated.id,
        'full_name': fullName.trim(),
        'phone': phone?.trim(),
      });
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
    return updated;
  }

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final rows = await _client
          .from('addresses')
          .select()
          .eq('user_id', _userId)
          .order('is_default', ascending: false);
      return [for (final row in rows) _mapAddress(row)];
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<Address> saveAddress(Address address) async {
    final payload = <String, dynamic>{
      'user_id': _userId,
      'full_name': address.fullName.trim(),
      'line1': address.line1.trim(),
      'line2': address.line2?.trim(),
      'city': address.city.trim(),
      'state': address.state.trim(),
      'postal_code': address.postalCode.trim(),
      'country': address.country.trim(),
      'phone': address.phone.trim(),
      'is_default': address.isDefault,
    };
    try {
      if (address.isDefault) {
        await _client
            .from('addresses')
            .update({'is_default': false})
            .eq('user_id', _userId);
      }
      final row = address.id.trim().isEmpty
          ? await _client.from('addresses').insert(payload).select().single()
          : await _client
                .from('addresses')
                .update(payload)
                .eq('id', address.id)
                .eq('user_id', _userId)
                .select()
                .single();
      return _mapAddress(row);
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<void> deleteAddress(String id) async {
    try {
      await _client
          .from('addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  @override
  Future<void> setDefaultAddress(String id) async {
    try {
      await _client
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', _userId);
      await _client
          .from('addresses')
          .update({'is_default': true})
          .eq('id', id)
          .eq('user_id', _userId);
    } on PostgrestException catch (error) {
      throw AuthFailure(error.message);
    }
  }

  Address _mapAddress(Map<String, dynamic> row) {
    return Address(
      id: row['id'] as String,
      fullName: (row['full_name'] as String?) ?? '',
      line1: (row['line1'] as String?) ?? '',
      line2: row['line2'] as String?,
      city: (row['city'] as String?) ?? '',
      state: (row['state'] as String?) ?? '',
      postalCode: (row['postal_code'] as String?) ?? '',
      country: (row['country'] as String?) ?? 'United States',
      phone: (row['phone'] as String?) ?? '',
      isDefault: (row['is_default'] as bool?) ?? false,
    );
  }
}
