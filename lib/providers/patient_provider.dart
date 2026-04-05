import 'package:flutter/foundation.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/models/patient_progress_summary.dart';

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
          weight: 67.4,
          symptoms: 'Sem tontura ou falta de ar.',
          mealStatus: 'Alimentacao adequada',
          mobilityStatus: 'Caminhou com apoio leve',
          moodStatus: 'Bem-humorada',
          sleepStatus: 'Sono regular',
          medicationAdherence: 'Completa',
          activityAdherence: 'Realizada',
          recordedBy: 'Cuidadora Ana Clara',
          notes:
              'Visita domiciliar concluida sem intercorrencias. Boa adesao a medicacao e ao plano alimentar.',
        ),
        HealthRecord(
          id: 'R002',
          patientId: 'P002',
          recordedAt: DateTime.now().subtract(const Duration(hours: 18)),
          systolic: 145,
          diastolic: 92,
          glucose: 178,
          weight: 81.2,
          symptoms: 'Relatou sede aumentada e cansaco leve.',
          mealStatus: 'Alimentacao parcial',
          mobilityStatus: 'Locomocao preservada',
          moodStatus: 'Atencao moderada',
          sleepStatus: 'Sono irregular',
          medicationAdherence: 'Parcial',
          activityAdherence: 'Parcial',
          recordedBy: 'Enfermeiro Carlos',
          notes:
              'Registro com glicemia acima da meta. Orientada revisao alimentar e reforco da hidratacao.',
        ),
        HealthRecord(
          id: 'R003',
          patientId: 'P003',
          recordedAt: DateTime.now().subtract(const Duration(hours: 9)),
          systolic: 165,
          diastolic: 102,
          glucose: 214,
          weight: 59.6,
          symptoms: 'Cansaco ao esforco e falta de ar leve.',
          mealStatus: 'Baixa ingestao alimentar',
          mobilityStatus: 'Necessita apoio frequente',
          moodStatus: 'Apatica',
          sleepStatus: 'Sono ruim',
          medicationAdherence: 'Parcial',
          activityAdherence: 'Nao realizada',
          recordedBy: 'Tecnica de enfermagem Livia',
          notes:
              'Equipe sinalizou cansaco ao esforco e baixa adesao ao registro. Necessaria reavaliacao clinica.',
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
    final List<Patient> matches = _patients
        .where((patient) => patient.id == id)
        .toList();
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

  int get criticalAlertsCount => _patients
      .where(
        (patient) => statusForPatient(patient.id) == PatientStatus.critical,
      )
      .length;

  List<Patient> get patientsWithCriticalAlerts {
    final filtered =
        _patients
            .where(
              (patient) =>
                  statusForPatient(patient.id) == PatientStatus.critical,
            )
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
      weight: weight,
      symptoms: symptoms.trim(),
      mealStatus: mealStatus.trim(),
      mobilityStatus: mobilityStatus.trim(),
      moodStatus: moodStatus.trim(),
      sleepStatus: sleepStatus.trim(),
      medicationAdherence: medicationAdherence.trim(),
      activityAdherence: activityAdherence.trim(),
      recordedBy: recordedBy.trim(),
      notes: notes.trim(),
    );

    _records.add(record);
    notifyListeners();
    return record;
  }

  PatientProgressSummary? summaryForPatient(String patientId) {
    final Patient? patient = getPatientById(patientId);
    if (patient == null) {
      return null;
    }
    return _buildSummary(recordsForPatient(patientId), patient.createdAt);
  }

  PatientProgressSummary? overallSummary() {
    if (_records.isEmpty) {
      return null;
    }

    final DateTime oldestPatientDate = _patients
        .map((patient) => patient.createdAt)
        .reduce((value, element) => value.isBefore(element) ? value : element);

    return _buildSummary(allRecordsSorted, oldestPatientDate);
  }

  PatientProgressSummary? _buildSummary(
    List<HealthRecord> records,
    DateTime monitoringStart,
  ) {
    if (records.isEmpty) {
      return null;
    }

    final List<HealthRecord> ascendingRecords = [...records]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final double averageSystolic =
        ascendingRecords
            .map((record) => record.systolic)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final double averageDiastolic =
        ascendingRecords
            .map((record) => record.diastolic)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final double averageGlucose =
        ascendingRecords
            .map((record) => record.glucose)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final double averageWeight =
        ascendingRecords
            .map((record) => record.weight)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;

    final double firstGlucose = ascendingRecords.first.glucose.toDouble();
    final double lastGlucose = ascendingRecords.last.glucose.toDouble();
    final double absoluteVariation = lastGlucose - firstGlucose;
    final double percentageVariation = firstGlucose == 0
        ? 0
        : (absoluteVariation / firstGlucose) * 100;

    final int idealReadingsCount = ascendingRecords
        .where((record) => record.isIdealReading)
        .length;
    final double idealReadingsPercent =
        (idealReadingsCount / ascendingRecords.length) * 100;

    final int monitoredDays =
        DateTime.now().difference(monitoringStart).inDays.clamp(0, 9999) + 1;
    final double adherencePercent =
        (ascendingRecords.length / monitoredDays) * 100;

    final double trendSlope = _calculateLinearTrend(ascendingRecords);

    final String clinicalStatusLabel;
    if (absoluteVariation <= -10 && idealReadingsPercent >= 60) {
      clinicalStatusLabel = 'Melhora';
    } else if (absoluteVariation >= 10 || trendSlope > 8) {
      clinicalStatusLabel = 'Piora';
    } else {
      clinicalStatusLabel = 'Estabilidade';
    }

    return PatientProgressSummary(
      totalRecords: ascendingRecords.length,
      averageSystolic: averageSystolic,
      averageDiastolic: averageDiastolic,
      averageGlucose: averageGlucose,
      averageWeight: averageWeight,
      absoluteVariation: absoluteVariation,
      percentageVariation: percentageVariation,
      idealReadingsPercent: idealReadingsPercent.clamp(0, 100),
      adherencePercent: adherencePercent.clamp(0, 100),
      trendSlope: trendSlope,
      clinicalStatusLabel: clinicalStatusLabel,
    );
  }

  double _calculateLinearTrend(List<HealthRecord> records) {
    if (records.length < 2) {
      return 0;
    }

    final int count = records.length;
    final double meanX = (count - 1) / 2;
    final double meanY =
        records.map((record) => record.glucose).reduce((a, b) => a + b) / count;

    double numerator = 0;
    double denominator = 0;

    for (int index = 0; index < count; index++) {
      final double x = index.toDouble();
      final double y = records[index].glucose.toDouble();
      numerator += (x - meanX) * (y - meanY);
      denominator += (x - meanX) * (x - meanX);
    }

    if (denominator == 0) {
      return 0;
    }

    return numerator / denominator;
  }
}
