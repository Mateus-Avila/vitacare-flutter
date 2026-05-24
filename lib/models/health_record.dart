import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitacare_flutter/core/firestore_serialization.dart';

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.uid,
    required this.patientId,
    required this.patientName,
    required this.recordedAt,
    required this.updatedAt,
    required this.systolic,
    required this.diastolic,
    required this.glucose,
    required this.weight,
    required this.symptoms,
    required this.mealStatus,
    required this.mobilityStatus,
    required this.moodStatus,
    required this.sleepStatus,
    required this.medicationAdherence,
    required this.activityAdherence,
    required this.recordedBy,
    required this.notes,
  });

  final String id;
  final String uid;
  final String patientId;
  final String patientName;
  final DateTime recordedAt;
  final DateTime updatedAt;
  final int systolic;
  final int diastolic;
  final int glucose;
  final double weight;
  final String symptoms;
  final String mealStatus;
  final String mobilityStatus;
  final String moodStatus;
  final String sleepStatus;
  final String medicationAdherence;
  final String activityAdherence;
  final String recordedBy;
  final String notes;

  bool get isCritical => systolic >= 160 || diastolic >= 100 || glucose >= 200;

  bool get isAttention =>
      !isCritical && (systolic >= 140 || diastolic >= 90 || glucose >= 140);

  bool get isIdealReading =>
      systolic <= 139 && diastolic <= 89 && glucose <= 139;

  String get statusKey {
    if (isCritical) {
      return 'critico';
    }
    if (isAttention) {
      return 'atencao';
    }
    return 'estavel';
  }

  factory HealthRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return HealthRecord(
      id: snapshot.id,
      uid: data['uid'] as String? ?? '',
      patientId: data['pacienteId'] as String? ?? '',
      patientName: data['pacienteNome'] as String? ?? '',
      recordedAt: firestoreDate(data['registradoEm']),
      updatedAt: firestoreDate(data['atualizadoEm']),
      systolic: firestoreInt(data['sistolica']),
      diastolic: firestoreInt(data['diastolica']),
      glucose: firestoreInt(data['glicemia']),
      weight: firestoreDouble(data['peso']),
      symptoms: data['sintomas'] as String? ?? '',
      mealStatus: data['alimentacao'] as String? ?? '',
      mobilityStatus: data['locomocao'] as String? ?? '',
      moodStatus: data['humor'] as String? ?? '',
      sleepStatus: data['sono'] as String? ?? '',
      medicationAdherence: data['adesaoMedicacao'] as String? ?? '',
      activityAdherence: data['adesaoAtividades'] as String? ?? '',
      recordedBy: data['registradoPor'] as String? ?? '',
      notes: data['observacoes'] as String? ?? '',
    );
  }

  static Map<String, dynamic> toFirestoreMap({
    required String uid,
    required String patientId,
    required String patientName,
    required int systolic,
    required int diastolic,
    required int glucose,
    required double weight,
    required String symptoms,
    required String mealStatus,
    required String mobilityStatus,
    required String moodStatus,
    required String sleepStatus,
    required String medicationAdherence,
    required String activityAdherence,
    required String recordedBy,
    required String notes,
    bool isCreate = true,
  }) {
    final record = HealthRecord(
      id: '',
      uid: uid,
      patientId: patientId,
      patientName: patientName,
      recordedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      systolic: systolic,
      diastolic: diastolic,
      glucose: glucose,
      weight: weight,
      symptoms: symptoms,
      mealStatus: mealStatus,
      mobilityStatus: mobilityStatus,
      moodStatus: moodStatus,
      sleepStatus: sleepStatus,
      medicationAdherence: medicationAdherence,
      activityAdherence: activityAdherence,
      recordedBy: recordedBy,
      notes: notes,
    );

    return {
      'uid': uid,
      'pacienteId': patientId,
      'pacienteNome': patientName,
      'pacienteNomeLowercase': normalizedSearchText(patientName),
      'sistolica': systolic,
      'diastolica': diastolic,
      'glicemia': glucose,
      'peso': weight,
      'sintomas': symptoms.trim(),
      'alimentacao': mealStatus.trim(),
      'locomocao': mobilityStatus.trim(),
      'humor': moodStatus.trim(),
      'sono': sleepStatus.trim(),
      'adesaoMedicacao': medicationAdherence.trim(),
      'adesaoAtividades': activityAdherence.trim(),
      'registradoPor': recordedBy.trim(),
      'observacoes': notes.trim(),
      'status': record.statusKey,
      if (isCreate) 'registradoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}
