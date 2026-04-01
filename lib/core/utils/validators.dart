class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Nepal phone: starts with 97 or 98, total 10 digits
    final cleaned = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    final nepaliPhone = RegExp(r'^(977)?(97|98)\d{8}$');
    if (!nepaliPhone.hasMatch(cleaned) && cleaned.length != 10) {
      return 'Enter a valid Nepal phone number';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (value.trim().length != 6) return 'Enter the 6-digit OTP';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'OTP must be 6 digits';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) return 'Price is required';
    final n = num.tryParse(value.trim());
    if (n == null) return 'Enter a valid amount';
    if (n <= 0) return 'Price must be greater than 0';
    return null;
  }

  static String? description(String? value) {
    if (value == null || value.trim().isEmpty) return 'Description is required';
    if (value.trim().length < 20) {
      return 'Description too short (min 20 characters)';
    }
    return null;
  }
}
