import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:vitacare_flutter/core/vitacare_validators.dart';
import 'package:vitacare_flutter/models/app_user.dart';
import 'package:vitacare_flutter/models/auth_result.dart';
import 'package:vitacare_flutter/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _authSubscription = _authService.authStateChanges().listen((user) async {
      if (user == null) {
        _currentUser = null;
        notifyListeners();
        return;
      }
      _currentUser = await _authService.loadCurrentUserProfile();
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription _authSubscription;

  AppUser? _currentUser;
  bool _isLoading = false;

  AppUser? get currentUser =>
      _currentUser ??
      (_authService.firebaseUser == null
          ? null
          : AppUser.fromFirebaseUser(_authService.firebaseUser!));

  bool get isLoggedIn => _authService.firebaseUser != null;

  bool get isLoading => _isLoading;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPassword = password.trim();

    if (normalizedEmail.isEmpty || normalizedPassword.isEmpty) {
      return AuthResult.error('Preencha e-mail e senha para continuar.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error('Digite um e-mail valido para fazer login.');
    }

    return _runLoading(
      () => _authService.login(
        email: normalizedEmail,
        password: normalizedPassword,
      ),
    );
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String profile,
    required String password,
    required String confirmPassword,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim();
    final normalizedCity = city.trim();
    final normalizedProfile = profile.trim();
    final normalizedPassword = password.trim();
    final normalizedConfirmPassword = confirmPassword.trim();

    if (normalizedName.isEmpty ||
        normalizedEmail.isEmpty ||
        normalizedPhone.isEmpty ||
        normalizedCity.isEmpty ||
        normalizedProfile.isEmpty ||
        normalizedPassword.isEmpty ||
        normalizedConfirmPassword.isEmpty) {
      return AuthResult.error('Todos os campos sao obrigatorios.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error('Informe um e-mail valido.');
    }

    final passwordError = VitacareValidators.strongPasswordError(
      normalizedPassword,
    );
    if (passwordError != null) {
      return AuthResult.error(passwordError);
    }

    if (normalizedPassword != normalizedConfirmPassword) {
      return AuthResult.error('Senha e confirmacao precisam ser iguais.');
    }

    return _runLoading(
      () => _authService.register(
        name: normalizedName,
        email: normalizedEmail,
        phone: normalizedPhone,
        city: normalizedCity,
        profile: normalizedProfile,
        password: normalizedPassword,
      ),
    );
  }

  Future<AuthResult> requestPasswordRecovery(String email) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      return AuthResult.error('Informe seu e-mail para recuperar a senha.');
    }

    if (!VitacareValidators.isValidEmail(normalizedEmail)) {
      return AuthResult.error(
        'Digite um e-mail valido para recuperar a senha.',
      );
    }

    return _runLoading(
      () => _authService.requestPasswordRecovery(normalizedEmail),
    );
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<AuthResult> _runLoading(Future<AuthResult> Function() action) async {
    _isLoading = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
