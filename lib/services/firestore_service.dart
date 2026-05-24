import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:vitacare_flutter/models/care_goal.dart';
import 'package:vitacare_flutter/models/care_task.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';

class FirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  static const usersCollection = 'usuarios';
  static const patientsCollection = 'pacientes';
  static const recordsCollection = 'registros_saude';
  static const tasksCollection = 'atividades_cuidado';
  static const goalsCollection = 'metas_cuidado';

  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  String get currentUid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuario nao autenticado.');
    }
    return user.uid;
  }

  Stream<List<Patient>> watchPatients() {
    return _firestore
        .collection(patientsCollection)
        .where('uid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
          final patients = snapshot.docs.map(Patient.fromFirestore).toList()
            ..sort((a, b) => a.name.compareTo(b.name));
          return patients;
        });
  }

  Stream<List<HealthRecord>> watchHealthRecords({String? patientId}) {
    return _firestore
        .collection(recordsCollection)
        .where('uid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
          final records = snapshot.docs.map(HealthRecord.fromFirestore).where((
            record,
          ) {
            return patientId == null || record.patientId == patientId;
          }).toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
          return records;
        });
  }

  Stream<List<CareTask>> watchCareTasks() {
    return _firestore
        .collection(tasksCollection)
        .where('uid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
          final tasks = snapshot.docs.map(CareTask.fromFirestore).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return tasks;
        });
  }

  Stream<List<CareGoal>> watchCareGoals() {
    return _firestore
        .collection(goalsCollection)
        .where('uid', isEqualTo: currentUid)
        .snapshots()
        .map((snapshot) {
          final goals = snapshot.docs.map(CareGoal.fromFirestore).toList()
            ..sort((a, b) => a.endDate.compareTo(b.endDate));
          return goals;
        });
  }

  Stream<List<Patient>> searchPatients() => watchPatients();

  Future<String> addPatient({
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) async {
    final uid = currentUid;
    final reference = await _firestore
        .collection(patientsCollection)
        .add(
          Patient(
            id: '',
            uid: uid,
            name: name.trim(),
            age: age,
            chronicCondition: chronicCondition.trim(),
            caregiver: caregiver.trim(),
            phone: phone.trim(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            status: 'atencao',
          ).toCreateMap(),
        );
    return reference.id;
  }

  Future<void> updatePatient({
    required Patient patient,
    required String name,
    required int age,
    required String chronicCondition,
    required String caregiver,
    required String phone,
  }) async {
    await _ensureOwnedDocument(patientsCollection, patient.id);
    await _firestore
        .collection(patientsCollection)
        .doc(patient.id)
        .update(
          patient.toUpdateMap(
            name: name,
            age: age,
            chronicCondition: chronicCondition,
            caregiver: caregiver,
            phone: phone,
          ),
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
  }) async {
    final uid = currentUid;
    await _ensureOwnedDocument(patientsCollection, patientId);
    final data = HealthRecord.toFirestoreMap(
      uid: uid,
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

    final reference = await _firestore.collection(recordsCollection).add(data);
    final snapshot = await reference.get();
    final record = HealthRecord.fromFirestore(snapshot);
    await _updatePatientLatestRecord(patientId, record);
    return record;
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
  }) async {
    await _ensureOwnedDocument(recordsCollection, record.id);
    await _firestore
        .collection(recordsCollection)
        .doc(record.id)
        .update(
          HealthRecord.toFirestoreMap(
            uid: currentUid,
            patientId: record.patientId,
            patientName: record.patientName,
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
            isCreate: false,
          ),
        );
    await _refreshPatientLatestRecord(record.patientId);
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
  }) async {
    await _ensureOwnedDocument(patientsCollection, patientId);
    final reference = await _firestore
        .collection(tasksCollection)
        .add(
          CareTask.toFirestoreMap(
            uid: currentUid,
            patientId: patientId,
            patientName: patientName,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            completed: completed,
          ),
        );
    return reference.id;
  }

  Future<void> updateCareTask({
    required CareTask task,
    required String title,
    required String description,
    required String priority,
    required String status,
    required DateTime dueDate,
    required bool completed,
  }) async {
    await _ensureOwnedDocument(tasksCollection, task.id);
    await _firestore
        .collection(tasksCollection)
        .doc(task.id)
        .update(
          CareTask.toFirestoreMap(
            uid: currentUid,
            patientId: task.patientId,
            patientName: task.patientName,
            title: title,
            description: description,
            priority: priority,
            status: status,
            dueDate: dueDate,
            completed: completed,
            isCreate: false,
          ),
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
  }) async {
    await _ensureOwnedDocument(patientsCollection, patientId);
    final reference = await _firestore
        .collection(goalsCollection)
        .add(
          CareGoal.toFirestoreMap(
            uid: currentUid,
            patientId: patientId,
            patientName: patientName,
            title: title,
            description: description,
            progress: progress,
            startDate: startDate,
            endDate: endDate,
            status: status,
          ),
        );
    return reference.id;
  }

  Future<void> updateCareGoal({
    required CareGoal goal,
    required String title,
    required String description,
    required int progress,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
  }) async {
    await _ensureOwnedDocument(goalsCollection, goal.id);
    await _firestore
        .collection(goalsCollection)
        .doc(goal.id)
        .update(
          CareGoal.toFirestoreMap(
            uid: currentUid,
            patientId: goal.patientId,
            patientName: goal.patientName,
            title: title,
            description: description,
            progress: progress,
            startDate: startDate,
            endDate: endDate,
            status: status,
            isCreate: false,
          ),
        );
  }

  Future<void> seedDemoData() async {
    final uid = currentUid;
    final now = DateTime.now();

    final demoPatients = [
      {
        'uid': uid,
        'nome': 'Maria da Silva',
        'nomeLowercase': 'maria da silva',
        'idade': 72,
        'condicaoCronica': 'Diabetes tipo 2',
        'cuidador': 'Ana Souza',
        'telefone': '(16) 99123-4567',
        'status': 'atencao',
        'criadoEm': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        'atualizadoEm': Timestamp.fromDate(now),
        'ultimaSistolica': 148,
        'ultimaDiastolica': 92,
        'ultimaGlicemia': 210,
        'ultimoRegistroEm': Timestamp.fromDate(now.subtract(const Duration(days: 1))),
      },
      {
        'uid': uid,
        'nome': 'João Ferreira',
        'nomeLowercase': 'joao ferreira',
        'idade': 68,
        'condicaoCronica': 'Hipertensão arterial',
        'cuidador': 'Carlos Ferreira',
        'telefone': '(16) 98765-4321',
        'status': 'critico',
        'criadoEm': Timestamp.fromDate(now.subtract(const Duration(days: 45))),
        'atualizadoEm': Timestamp.fromDate(now),
        'ultimaSistolica': 180,
        'ultimaDiastolica': 110,
        'ultimaGlicemia': 145,
        'ultimoRegistroEm': Timestamp.fromDate(now.subtract(const Duration(hours: 6))),
      },
      {
        'uid': uid,
        'nome': 'Ana Oliveira',
        'nomeLowercase': 'ana oliveira',
        'idade': 75,
        'condicaoCronica': 'Insuficiência cardíaca',
        'cuidador': 'Pedro Oliveira',
        'telefone': '(16) 97654-3210',
        'status': 'estavel',
        'criadoEm': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
        'atualizadoEm': Timestamp.fromDate(now),
        'ultimaSistolica': 120,
        'ultimaDiastolica': 78,
        'ultimaGlicemia': 98,
        'ultimoRegistroEm': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      },
      {
        'uid': uid,
        'nome': 'Carlos Santos',
        'nomeLowercase': 'carlos santos',
        'idade': 65,
        'condicaoCronica': 'DPOC',
        'cuidador': 'Lucia Santos',
        'telefone': '(16) 96543-2109',
        'status': 'atencao',
        'criadoEm': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
        'atualizadoEm': Timestamp.fromDate(now),
        'ultimaSistolica': 135,
        'ultimaDiastolica': 85,
        'ultimaGlicemia': 120,
        'ultimoRegistroEm': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      },
    ];

    final batch = _firestore.batch();
    final patientRefs = <DocumentReference>[];

    for (final patient in demoPatients) {
      final ref = _firestore.collection(patientsCollection).doc();
      batch.set(ref, patient);
      patientRefs.add(ref);
    }

    await batch.commit();

    final recordsBatch = _firestore.batch();
    final offsets = [1, 3, 7, 14, 21, 30];

    for (int pi = 0; pi < patientRefs.length; pi++) {
      final patientRef = patientRefs[pi];
      final patientData = demoPatients[pi];

      for (final dayOffset in offsets) {
        final recordRef = _firestore.collection(recordsCollection).doc();
        final sistolica = (patientData['ultimaSistolica'] as int) + (dayOffset % 3 == 0 ? 5 : -3);
        final diastolica = (patientData['ultimaDiastolica'] as int) + (dayOffset % 2 == 0 ? 3 : -2);
        final glicemia = (patientData['ultimaGlicemia'] as int) + (dayOffset % 4 == 0 ? 10 : -5);
        final String statusKey;
        if (sistolica >= 160 || diastolica >= 100 || glicemia >= 200) {
          statusKey = 'critico';
        } else if (sistolica >= 140 || diastolica >= 90 || glicemia >= 140) {
          statusKey = 'atencao';
        } else {
          statusKey = 'estavel';
        }
        recordsBatch.set(recordRef, {
          'uid': uid,
          'pacienteId': patientRef.id,
          'pacienteNome': patientData['nome'],
          'pacienteNomeLowercase': (patientData['nomeLowercase'] as String),
          'sistolica': sistolica,
          'diastolica': diastolica,
          'glicemia': glicemia,
          'peso': 70.0 + pi * 5,
          'sintomas': 'Nenhum sintoma relevante.',
          'alimentacao': 'completa',
          'locomocao': 'independente',
          'humor': 'bom',
          'sono': 'adequado',
          'adesaoMedicacao': 'total',
          'adesaoAtividades': 'parcial',
          'registradoPor': patientData['cuidador'],
          'observacoes': '',
          'status': statusKey,
          'registradoEm': Timestamp.fromDate(now.subtract(Duration(days: dayOffset))),
          'atualizadoEm': Timestamp.fromDate(now.subtract(Duration(days: dayOffset))),
        });
      }
    }

    await recordsBatch.commit();
  }

  Future<void> _ensureOwnedDocument(String collection, String id) async {
    final snapshot = await _firestore.collection(collection).doc(id).get();
    if (!snapshot.exists || snapshot.data()?['uid'] != currentUid) {
      throw StateError('Documento nao pertence ao usuario logado.');
    }
  }

  Future<void> _refreshPatientLatestRecord(String patientId) async {
    final recordsSnapshot = await _firestore
        .collection(recordsCollection)
        .where('uid', isEqualTo: currentUid)
        .get();

    final records =
        recordsSnapshot.docs
            .map(HealthRecord.fromFirestore)
            .where((record) => record.patientId == patientId)
            .toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    if (records.isEmpty) {
      await _firestore.collection(patientsCollection).doc(patientId).update({
        'status': 'atencao',
        'ultimaSistolica': FieldValue.delete(),
        'ultimaDiastolica': FieldValue.delete(),
        'ultimaGlicemia': FieldValue.delete(),
        'ultimoRegistroEm': FieldValue.delete(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      return;
    }

    await _updatePatientLatestRecord(patientId, records.first);
  }

  Future<void> _updatePatientLatestRecord(
    String patientId,
    HealthRecord record,
  ) {
    return _firestore.collection(patientsCollection).doc(patientId).update({
      'status': record.statusKey,
      'ultimaSistolica': record.systolic,
      'ultimaDiastolica': record.diastolic,
      'ultimaGlicemia': record.glucose,
      'ultimoRegistroEm': Timestamp.fromDate(record.recordedAt),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }
}
