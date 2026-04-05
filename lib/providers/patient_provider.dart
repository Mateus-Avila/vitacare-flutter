import 'package:flutter/foundation.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';

enum PatientStatus { stable, attention, critical }

class PatientProvider extends ChangeNotifier {
  PatientProvider()
      : _patients = [
          Patient(
            id: 'P001',
            name: 'Maria Helena da Silva',
            age: 74,
            chronicCondition: 'Hipertensao arterial e risco de quedas',
            caregiver: 'Ana Clara Silva',
            phone: '(16) 99123-4455',
            createdAt: DateTime.now().subtract(const Duration(days: 40)),
          ),
          Patient(
            id: 'P002',
            name: 'Jose Roberto Oliveira',
            age: 68,
            chronicCondition: 'Diabetes tipo 2',
            caregiver: 'Carlos Oliveira',
            phone: '(16) 98888-2211',
            createdAt: DateTime.now().subtract(const Duration(days: 26)),
          ),
          Patient(
            id: 'P003',
            name: 'Helena Aparecida Santos',
            age: 81,
            chronicCondition: 'Insuficiencia cardiaca e DPOC',
            caregiver: 'Livia Santos',
            phone: '(16) 97777-3434',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ],
        _records = [
          HealthRecord(
            id: 'R001',
            patientId: 'P001',
            recordedAt: DateTime.now().subtract(const Duration(days: 1)),
            systolic: 138,
            diastolic: 86,
            glucose: 122,
            notes: 'Visita domiciliar concluida sem intercorrencias. Boa adesao a medicacao e ao plano alimentar.',
          ),
          HealthRecord(
            id: 'R002',
            patientId: 'P002',
            recordedAt: DateTime.now().subtract(const Duration(hours: 18)),
            systolic: 145,
            diastolic: 92,
            glucose: 178,
            notes: 'Registro com glicemia acima da meta. Orientada revisao alimentar e reforco da hidratacao.',
          ),
          HealthRecord(
            id: 'R003',
            patientId: 'P003',
            recordedAt: DateTime.now().subtract(const Duration(hours: 9)),
            systolic: 165,
            diastolic: 102,
            glucose: 214,
            notes: 'Equipe sinalizou cansaco ao esforco e baixa adesao ao registro. Necessaria reavaliacao clinica.',
          ),
        ];

  final List<Patient> _patients;
  final List<HealthRecord> _records;

  int _patientSequence = 4;
  int _recordSequence = 4;

  List<Patient> get patients {
    final sorted = [..._patients]..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(sorted);
  }

  List<HealthRecord> get allRecordsSorted {
    final sorted = [..._records]
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(sorted);
  }

  Patient? getPatientById(String id) {
    final List<Patient> matches =
        _patients.where((patient) => patient.id == id).toList();
    return matches.isEmpty ? null : matches.first;
  }

  List<HealthRecord> recordsForPatient(String patientId) {
    final filtered =
        _records.where((record) => record.patientId == patientId).toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return List.unmodifiable(filtered);
  }

  HealthRecord? latestRecordForPatient(String patientId) {
    final records = recordsForPatient(patientId);
    return records.isEmpty ? null : records.first;
  }

  PatientStatus statusForPatient(String patientId) {
    final HealthRecord? latest = latestRecordForPatient(patientId);
    if (latest == null) {
      return PatientStatus.attention;
    }
    if (latest.isCritical) {
      return PatientStatus.critical;
    }
    if (latest.isAttention) {
      return PatientStatus.attention;
    }
    return PatientStatus.stable;
  }

  int get criticalAlertsCount =>
      _patients
          .where((patient) => statusForPatient(patient.id) == PatientStatus.critical)
          .length;

  List<Patient> get patientsWithCriticalAlerts {
    final filtered = _patients
        .where((patient) => statusForPatient(patient.id) == PatientStatus.critical)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(filtered);
  }

  String addPatient({
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) {
    final patientId = 'P${_patientSequence.toString().padLeft(3, '0')}';
    _patientSequence += 1;

    _patients.add(
      Patient(
        id: patientId,
        name: name.trim(),
        age: age,
        chronicCondition: chronicCondition.trim(),
        caregiver: caregiver.trim(),
        phone: phone.trim(),
        createdAt: DateTime.now(),
      ),
    );

    notifyListeners();
    return patientId;
  }

  HealthRecord addHealthRecord({
    required String patientId,
    required int systolic,
    required int diastolic,
    required int glucose,
    required String notes,
  }) {
    final recordId = 'R${_recordSequence.toString().padLeft(3, '0')}';
    _recordSequence += 1;

    final HealthRecord record = HealthRecord(
      id: recordId,
      patientId: patientId,
      recordedAt: DateTime.now(),
      systolic: systolic,
      diastolic: diastolic,
      glucose: glucose,
      notes: notes.trim(),
    );

    _records.add(record);
    notifyListeners();
    return record;
  }
}
