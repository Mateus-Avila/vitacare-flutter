import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitacare_flutter/core/firestore_serialization.dart';

class CareTask {
  const CareTask({
    required this.id,
    required this.uid,
    required this.patientId,
    required this.patientName,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String uid;
  final String patientId;
  final String patientName;
  final String title;
  final String description;
  final String priority;
  final String status;
  final DateTime dueDate;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CareTask.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? <String, dynamic>{};
    return CareTask(
      id: snapshot.id,
      uid: data['uid'] as String? ?? '',
      patientId: data['pacienteId'] as String? ?? '',
      patientName: data['pacienteNome'] as String? ?? '',
      title: data['titulo'] as String? ?? '',
      description: data['descricao'] as String? ?? '',
      priority: data['prioridade'] as String? ?? 'Media',
      status: data['status'] as String? ?? 'Pendente',
      dueDate: firestoreDate(data['dataLimite']),
      completed: data['concluida'] as bool? ?? false,
      createdAt: firestoreDate(data['criadoEm']),
      updatedAt: firestoreDate(data['atualizadoEm']),
    );
  }

  static Map<String, dynamic> toFirestoreMap({
    required String uid,
    required String patientId,
    required String patientName,
    required String title,
    required String description,
    required String priority,
    required String status,
    required DateTime dueDate,
    required bool completed,
    bool isCreate = true,
  }) {
    return {
      'uid': uid,
      'pacienteId': patientId,
      'pacienteNome': patientName,
      'titulo': title.trim(),
      'tituloLowercase': normalizedSearchText(title),
      'descricao': description.trim(),
      'prioridade': priority,
      'status': status,
      'dataLimite': Timestamp.fromDate(dueDate),
      'concluida': completed,
      if (isCreate) 'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
  }
}
