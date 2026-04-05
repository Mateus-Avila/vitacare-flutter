class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.chronicCondition,
    required this.caregiver,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int age;
  final String chronicCondition;
  final String caregiver;
  final String phone;
  final DateTime createdAt;
}
