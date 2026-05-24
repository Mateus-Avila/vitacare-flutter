import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vitacare_flutter/core/firestore_serialization.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.profile,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String name;
  final String email;
  final String phone;
  final String city;
  final String profile;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory AppUser.fromFirebaseUser(firebase_auth.User user) {
    final now = DateTime.now();
    return AppUser(
      uid: user.uid,
      name: user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : 'Profissional VitaCare',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      city: '',
      profile: 'Profissional de saude',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AppUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return AppUser(
      uid: data['uid'] as String? ?? snapshot.id,
      name: data['nome'] as String? ?? 'Profissional VitaCare',
      email: data['email'] as String? ?? '',
      phone: data['telefone'] as String? ?? '',
      city: data['cidade'] as String? ?? '',
      profile: data['perfil'] as String? ?? 'Profissional de saude',
      createdAt: firestoreDate(data['criadoEm']),
      updatedAt: firestoreDate(data['atualizadoEm']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'nome': name,
      'telefone': phone,
      'email': email,
      'cidade': city,
      'perfil': profile,
      'criadoEm': Timestamp.fromDate(createdAt),
      'atualizadoEm': Timestamp.fromDate(updatedAt),
      'nomeLowercase': normalizedSearchText(name),
    };
  }
}
