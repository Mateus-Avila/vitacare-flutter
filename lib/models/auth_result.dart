class AuthResult {
  const AuthResult._({required this.isSuccess, required this.message});

  final bool isSuccess;
  final String message;

  factory AuthResult.success(String message) {
    return AuthResult._(isSuccess: true, message: message);
  }

  factory AuthResult.error(String message) {
    return AuthResult._(isSuccess: false, message: message);
  }
}
