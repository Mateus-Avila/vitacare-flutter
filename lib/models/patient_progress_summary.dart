class PatientProgressSummary {
  const PatientProgressSummary({
    required this.totalRecords,
    required this.averageSystolic,
    required this.averageDiastolic,
    required this.averageGlucose,
    required this.averageWeight,
    required this.absoluteVariation,
    required this.percentageVariation,
    required this.idealReadingsPercent,
    required this.adherencePercent,
    required this.trendSlope,
    required this.clinicalStatusLabel,
  });

  final int totalRecords;
  final double averageSystolic;
  final double averageDiastolic;
  final double averageGlucose;
  final double averageWeight;
  final double absoluteVariation;
  final double percentageVariation;
  final double idealReadingsPercent;
  final double adherencePercent;
  final double trendSlope;
  final String clinicalStatusLabel;
}
