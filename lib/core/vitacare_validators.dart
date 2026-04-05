class VitacareValidators {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }
}
