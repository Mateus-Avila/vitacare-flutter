import 'package:flutter/foundation.dart';
import 'package:vitacare_flutter/core/vitacare_validators.dart';
import 'package:vitacare_flutter/models/app_user.dart';
import 'package:vitacare_flutter/models/auth_result.dart';

class AuthProvider extends ChangeNotifier {
  final List<AppUser> _users = const [
    AppUser(
      name: 'Equipe Academica VitaCare',
      email: 'admin@vitacare.com',
      phone: '(16) 99999-0000',
      password: '123456',
    ),
  ].toList();

  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  bool accountExists(String email) {
    final normalizedEmail = _normalizeEmail(email);
    return _users.any((user) => user.email == normalizedEmail);
  }

  AuthResult login({required String email, required String password}) {
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return AuthResult.error('Preencha e-mail e senha para continuar.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error('Digite um e-mail valido para fazer login.');
    }

    final AppUser? account = _users.cast<AppUser?>().firstWhere(
      (user) => user?.email == normalizedEmail,
      orElse: () => null,
    );

    if (account == null) {
      return AuthResult.error(
        'Conta inexistente. Verifique o e-mail ou faca seu cadastro.',
      );
    }

    if (account.password != normalizedPassword) {
      return AuthResult.error('Senha incorreta para este e-mail.');
    }

    _currentUser = account;
    notifyListeners();
    return AuthResult.success(
      'Login realizado com sucesso. Bem-vindo ao painel academico do VitaCare.',
    );
  }

  AuthResult register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) {
    final normalizedName = name.trim();
    final normalizedEmail = _normalizeEmail(email);
    final normalizedPhone = phone.trim();
    final normalizedPassword = password.trim();
    final normalizedConfirmPassword = confirmPassword.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPhone.isEmpty ||
        normalizedPassword.isEmpty ||
        normalizedConfirmPassword.isEmpty) {
      return AuthResult.error('Todos os campos sao obrigatorios.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error('Informe um e-mail valido.');
    }

    if (normalizedPassword != normalizedConfirmPassword) {
      return AuthResult.error('Senha e confirmacao precisam ser iguais.');
    }

    if (normalizedPassword.length < 6) {
      return AuthResult.error('A senha deve ter pelo menos 6 caracteres.');
    }

    if (accountExists(normalizedEmail)) {
      return AuthResult.error('Ja existe uma conta com este e-mail.');
    }

    final AppUser user = AppUser(
      name: normalizedName,
      email: normalizedEmail,
      phone: normalizedPhone,
      password: normalizedPassword,
    );

    _users.add(user);
    _currentUser = user;
    notifyListeners();
    return AuthResult.success(
      'Cadastro realizado com sucesso. Sua conta demonstrativa ja esta ativa.',
    );
  }

  AuthResult requestPasswordRecovery(String email) {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty) {
      return AuthResult.error('Informe seu e-mail para recuperar a senha.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error('Digite um e-mail valido para recuperar a senha.');
    }

    if (!accountExists(normalizedEmail)) {
      return AuthResult.error('Nao encontramos conta para este e-mail.');
    }

    return AuthResult.success(
      'Simulacao concluida. As instrucoes de redefinicao foram enviadas para o e-mail informado.',
    );
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
}
