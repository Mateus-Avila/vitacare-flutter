class VitacareValidators {
  static final RegExp _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');
  static final RegExp _specialRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=;]');

  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(value.trim());
  }

  static String? strongPasswordError(String value) {
    final password = value.trim();
    if (password.isEmpty) {
      return 'Informe a senha.';
    }
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres.';
    }
    if (!_uppercaseRegex.hasMatch(password)) {
      return 'Inclua ao menos uma letra maiuscula.';
    }
    if (!_lowercaseRegex.hasMatch(password)) {
      return 'Inclua ao menos uma letra minuscula.';
    }
    if (!_numberRegex.hasMatch(password)) {
      return 'Inclua ao menos um numero.';
    }
    if (!_specialRegex.hasMatch(password)) {
      return 'Inclua ao menos um caractere especial.';
    }
    return null;
  }
}
