class Validation {
  static bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegExp = RegExp(r"^\+?1?\d{9,15}$");
    return phoneRegExp.hasMatch(phone);
  }

  static bool isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$",
    );
    return emailRegExp.hasMatch(email);
  }
}
