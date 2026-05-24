import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vitacare_flutter/core/firestore_serialization.dart';
import 'package:vitacare_flutter/models/app_user.dart';
import 'package:vitacare_flutter/models/auth_result.dart';

class AuthService {
  AuthService({firebase_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  firebase_auth.User? get firebaseUser => _auth.currentUser;

  Stream<firebase_auth.User?> authStateChanges() => _auth.authStateChanges();

  Future<AppUser?> loadCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection('usuarios')
        .doc(user.uid)
        .get();
    if (!snapshot.exists) {
      return AppUser.fromFirebaseUser(user);
    }
    return AppUser.fromFirestore(snapshot);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );
      return AuthResult.success('Login realizado com sucesso.');
    } on firebase_auth.FirebaseAuthException catch (error) {
      return AuthResult.error(_authErrorMessage(error));
    } catch (_) {
      return AuthResult.error('Nao foi possivel fazer login. Tente novamente.');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String city,
    required String profile,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.error('Cadastro criado, mas o usuario nao retornou.');
      }

      await user.updateDisplayName(name.trim());
      await _firestore.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'nome': name.trim(),
        'nomeLowercase': normalizedSearchText(name),
        'telefone': phone.trim(),
        'email': email.trim().toLowerCase(),
        'cidade': city.trim(),
        'perfil': profile.trim(),
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(
        'Cadastro realizado com sucesso. Seus dados foram salvos no Firestore.',
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      return AuthResult.error(_authErrorMessage(error));
    } catch (_) {
      return AuthResult.error(
        'Nao foi possivel concluir o cadastro. Tente novamente.',
      );
    }
  }

  Future<AuthResult> requestPasswordRecovery(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return AuthResult.success(
        'E-mail de recuperacao enviado. Verifique sua caixa de entrada.',
      );
    } on firebase_auth.FirebaseAuthException catch (error) {
      return AuthResult.error(_authErrorMessage(error));
    } catch (_) {
      return AuthResult.error(
        'Nao foi possivel enviar a recuperacao. Tente novamente.',
      );
    }
  }

  Future<void> logout() => _auth.signOut();

  String _authErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Digite um e-mail valido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Ja existe uma conta com este e-mail.';
      case 'weak-password':
        return 'A senha informada e fraca para o Firebase.';
      case 'network-request-failed':
        return 'Falha de conexao. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      default:
        return error.message ?? 'Erro de autenticacao. Tente novamente.';
    }
  }
}
