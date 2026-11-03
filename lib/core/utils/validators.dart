class Validators {
  const Validators._();

  static final RegExp _email = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  static String? required(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  static String? email(String? value) {
    final base = required(value, label: 'Email address');
    if (base != null) return base;
    if (!_email.hasMatch(value!.trim())) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    final base = required(value, label: 'Password');
    if (base != null) return base;
    if (value!.length < 8) return 'Password must be at least 8 characters.';
    return null;
  }

  static String? name(String? value) {
    final base = required(value, label: 'Full name');
    if (base != null) return base;
    if (value!.trim().length < 2) return 'Enter your full name.';
    return null;
  }

  static String? phone(String? value) {
    final base = required(value, label: 'Phone number');
    if (base != null) return base;
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7) return 'Enter a valid phone number.';
    return null;
  }

  static String? postalCode(String? value) {
    final base = required(value, label: 'Postal code');
    if (base != null) return base;
    if (value!.trim().length < 3) return 'Enter a valid postal code.';
    return null;
  }
}
