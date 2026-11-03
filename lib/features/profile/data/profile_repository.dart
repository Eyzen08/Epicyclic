import '../domain/address.dart';
import '../../auth/domain/app_user.dart';

abstract interface class ProfileRepository {
  Future<AppUser?> getProfile();
  Future<AppUser> updateProfile({required String fullName, String? phone});

  Future<List<Address>> getAddresses();
  Future<Address> saveAddress(Address address);
  Future<void> deleteAddress(String id);
  Future<void> setDefaultAddress(String id);
}
