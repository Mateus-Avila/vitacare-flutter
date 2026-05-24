import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitacare_flutter/core/firestore_serialization.dart';

class Patient {
  const Patient({
    required this.id,
    required this.uid,
    required this.name,
    required this.age,
    required this.chronicCondition,
    required this.caregiver,
    required this.phone,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.latestSystolic,
    this.latestDiastolic,
    this.latestGlucose,
    this.latestRecordAt,
  });

  final String id;
  final String uid;
  final String name;
  final int age;
  final String chronicCondition;
  final String caregiver;
  final String phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final int? latestSystolic;
  final int? latestDiastolic;
  final int? latestGlucose;
  final DateTime? latestRecordAt;

  factory Patient.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return Patient(
      id: snapshot.id,
      uid: data['uid'] as String? ?? '',
      name: data['nome'] as String? ?? '',
      age: firestoreInt(data['idade']),
      chronicCondition: data['condicaoCronica'] as String? ?? '',
      caregiver: data['cuidador'] as String? ?? '',
      phone: data['telefone'] as String? ?? '',
      createdAt: firestoreDate(data['criadoEm']),
      updatedAt: firestoreDate(data['atualizadoEm']),
      status: data['status'] as String? ?? 'atencao',
      latestSystolic: data['ultimaSistolica'] == null
          ? null
          : firestoreInt(data['ultimaSistolica']),
      latestDiastolic: data['ultimaDiastolica'] == null
          ? null
          : firestoreInt(data['ultimaDiastolica']),
      latestGlucose: data['ultimaGlicemia'] == null
          ? null
          : firestoreInt(data['ultimaGlicemia']),
      latestRecordAt: data['ultimoRegistroEm'] == null
          ? null
          : firestoreDate(data['ultimoRegistroEm']),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'uid': uid,
      'nome': name.trim(),
      'nomeLowercase': normalizedSearchText(name),
      'idade': age,
      'condicaoCronica': chronicCondition.trim(),
      'cuidador': caregiver.trim(),
      'telefone': phone.trim(),
      'status': status,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap({
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) {
    return {
      'nome': name.trim(),
      'nomeLowercase': normalizedSearchText(name),
      'idade': age,
      'condicaoCronica': chronicCondition.trim(),
      'cuidador': caregiver.trim(),
      'telefone': phone.trim(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}
