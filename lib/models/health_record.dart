class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.patientId,
    required this.recordedAt,
    required this.systolic,
    required this.diastolic,
    required this.glucose,
    required this.notes,
  });

  final String id;
  final String patientId;
  final DateTime recordedAt;
  final int systolic;
  final int diastolic;
  final int glucose;
  final String notes;

  bool get isCritical => systolic >= 160 || diastolic >= 100 || glucose >= 200;

  bool get isAttention =>
      !isCritical && (systolic >= 140 || diastolic >= 90 || glucose >= 140);
}
