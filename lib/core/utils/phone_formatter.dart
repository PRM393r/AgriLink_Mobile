class PhoneFormatter {
  const PhoneFormatter._();

  /// Validates if a phone number is a valid Vietnamese phone number.
  /// Accepts format like: 0987654321, +84987654321, 84987654321, or 987654321
  static bool isValidVietnamesePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
    final regex = RegExp(r'^(0|\+84|84)?([35789]\d{8})$');
    return regex.hasMatch(cleanPhone);
  }

  /// Formats any valid Vietnamese phone number to E.164 format (+84...)
  static String formatToE164(String phone) {
    var cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
    
    if (cleanPhone.startsWith('+84')) {
      return cleanPhone;
    }
    if (cleanPhone.startsWith('84')) {
      return '+$cleanPhone';
    }
    if (cleanPhone.startsWith('0')) {
      return '+84${cleanPhone.substring(1)}';
    }
    // E.g. 987654321 -> +84987654321
    return '+84$cleanPhone';
  }

  /// Formats a phone number for display (e.g. 0987 654 321 or +84 987 654 321)
  static String formatForDisplay(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+|-'), '');
    if (cleanPhone.startsWith('+84') && cleanPhone.length == 12) {
      return '+84 ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6, 9)} ${cleanPhone.substring(9)}';
    }
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return '0${cleanPhone.substring(1, 4)} ${cleanPhone.substring(4, 7)} ${cleanPhone.substring(7)}';
    }
    return phone;
  }
}
