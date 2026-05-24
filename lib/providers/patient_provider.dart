import 'package:flutter/foundation.dart';
import 'package:vitacare_flutter/models/care_goal.dart';
import 'package:vitacare_flutter/models/care_task.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/models/patient_progress_summary.dart';
import 'package:vitacare_flutter/services/firestore_service.dart';

enum PatientStatus { stable, attention, critical }

class PatientProvider extends ChangeNotifier {
  PatientProvider({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<List<Patient>> watchPatients() => _firestoreService.watchPatients();

  Stream<List<HealthRecord>> watchHealthRecords({String? patientId}) =>
      _firestoreService.watchHealthRecords(patientId: patientId);

  Stream<List<CareTask>> watchCareTasks() => _firestoreService.watchCareTasks();

  Stream<List<CareGoal>> watchCareGoals() => _firestoreService.watchCareGoals();

  Stream<List<Patient>> searchPatients() => _firestoreService.searchPatients();

  Future<void> seedDemoData() => _firestoreService.seedDemoData();

  Future<String> addPatient({
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) {
    return _firestoreService.addPatient(
      name: name,
      age: age,
      chronicCondition: chronicCondition,
      caregiver: caregiver,
      phone: phone,
    );
  }

  Future<void> updatePatient({
    required Patient patient,
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) {
    return _firestoreService.updatePatient(
      patient: patient,
      name: name,
      age: age,
      chronicCondition: chronicCondition,
      caregiver: caregiver,
      phone: phone,
    );
  }

  Future<HealthRecord> addHealthRecord({
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
  }) {
    return _firestoreService.addHealthRecord(
      patientId: patientId,
      patientName: patientName,
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
  }

  Future<void> updateHealthRecord({
    required HealthRecord record,
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
    return _firestoreService.updateHealthRecord(
      record: record,
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
  }

  Future<String> addCareTask({
    required String patientId,
    required String patientName,
    required String title,
    required String description,
    required String priority,
    required String status,
    required DateTime dueDate,
    required bool completed,
  }) {
    return _firestoreService.addCareTask(
      patientId: patientId,
      patientName: patientName,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      completed: completed,
    );
  }

  Future<void> updateCareTask({
    required CareTask task,
    required String title,
    required String description,
    required String priority,
    required String status,
    required DateTime dueDate,
    required bool completed,
  }) {
    return _firestoreService.updateCareTask(
      task: task,
      title: title,
      description: description,
      priority: priority,
      status: status,
      dueDate: dueDate,
      completed: completed,
    );
  }

  Future<String> addCareGoal({
    required String patientId,
    required String patientName,
    required String title,
    required String description,
    required int progress,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
  }) {
    return _firestoreService.addCareGoal(
      patientId: patientId,
      patientName: patientName,
      title: title,
      description: description,
      progress: progress,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }

  Future<void> updateCareGoal({
    required CareGoal goal,
    required String title,
    required String description,
    required int progress,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
  }) {
    return _firestoreService.updateCareGoal(
      goal: goal,
      title: title,
      description: description,
      progress: progress,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }

  PatientStatus statusFromPatient(Patient patient) {
    switch (patient.status) {
      case 'critico':
        return PatientStatus.critical;
      case 'estavel':
        return PatientStatus.stable;
      default:
        return PatientStatus.attention;
    }
  }

  int criticalAlertsCountFrom(List<Patient> patients) => patients
      .where((patient) => statusFromPatient(patient) == PatientStatus.critical)
      .length;

  List<Patient> criticalPatientsFrom(List<Patient> patients) {
    final filtered =
        patients
            .where(
              (patient) => statusFromPatient(patient) == PatientStatus.critical,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return filtered;
  }

  PatientProgressSummary? summaryForRecords(
    List<HealthRecord> records,
    DateTime monitoringStart,
  ) {
    return _buildSummary(records, monitoringStart);
  }

  PatientProgressSummary? overallSummaryForRecords(
    List<HealthRecord> records,
    List<Patient> patients,
  ) {
    if (records.isEmpty || patients.isEmpty) {
      return null;
    }

    final oldestPatientDate = patients
        .map((patient) => patient.createdAt)
        .reduce((value, element) => value.isBefore(element) ? value : element);

    return _buildSummary(records, oldestPatientDate);
  }

  PatientProgressSummary? _buildSummary(
    List<HealthRecord> records,
    DateTime monitoringStart,
  ) {
    if (records.isEmpty) {
      return null;
    }

    final ascendingRecords = [...records]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    final averageSystolic =
        ascendingRecords
            .map((record) => record.systolic)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final averageDiastolic =
        ascendingRecords
            .map((record) => record.diastolic)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final averageGlucose =
        ascendingRecords
            .map((record) => record.glucose)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;
    final averageWeight =
        ascendingRecords
            .map((record) => record.weight)
            .reduce((a, b) => a + b) /
        ascendingRecords.length;

    final firstGlucose = ascendingRecords.first.glucose.toDouble();
    final lastGlucose = ascendingRecords.last.glucose.toDouble();
    final absoluteVariation = lastGlucose - firstGlucose;
    final percentageVariation = firstGlucose == 0
        ? 0.0
        : (absoluteVariation / firstGlucose) * 100;

    final idealReadingsCount = ascendingRecords
        .where((record) => record.isIdealReading)
        .length;
    final idealReadingsPercent =
        (idealReadingsCount / ascendingRecords.length) * 100;

    final monitoredDays =
        DateTime.now().difference(monitoringStart).inDays.clamp(0, 9999) + 1;
    final adherencePercent = (ascendingRecords.length / monitoredDays) * 100;
    final trendSlope = _calculateLinearTrend(ascendingRecords);

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

    final count = records.length;
    final meanX = (count - 1) / 2;
    final meanY =
        records.map((record) => record.glucose).reduce((a, b) => a + b) / count;

    double numerator = 0;
    double denominator = 0;

    for (int index = 0; index < count; index++) {
      final x = index.toDouble();
      final y = records[index].glucose.toDouble();
      numerator += (x - meanX) * (y - meanY);
      denominator += (x - meanX) * (x - meanX);
    }

    if (denominator == 0) {
      return 0;
    }

    return numerator / denominator;
  }
}
