import 'package:cloud_firestore/cloud_firestore.dart';

DateTime firestoreDate(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}

int firestoreInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

double firestoreDouble(dynamic value, {double fallback = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? fallback;
  }
  return fallback;
}

String normalizedSearchText(String value) => value.trim().toLowerCase();

List<String> normalizedSearchTokens(Iterable<String> values) {
  final tokens = <String>{};
  for (final value in values) {
    final normalized = normalizedSearchText(value);
    if (normalized.isEmpty) {
      continue;
    }

    tokens.add(normalized);
    tokens.addAll(
      normalized
          .split(RegExp(r'[^a-zA-Z0-9À-ÿ]+'))
          .map((token) => token.trim())
          .where((token) => token.isNotEmpty),
    );
  }
  return tokens.toList()..sort();
}
