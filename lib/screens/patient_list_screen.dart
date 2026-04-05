import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientProvider provider = context.watch<PatientProvider>();
    final List<Patient> patients = provider.patients;

    return VitacarePageScaffold(
      title: 'Listagem de Pacientes',
      selectedRoute: '/patients/list',
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pacientes ativos (${patients.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: VitacareColors.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualize rapidamente o estado atual e os dados cadastrais.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VitacareColors.textSoft,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: patients.isEmpty
                    ? const _EmptyPatientsState()
                    : ListView.separated(
                        itemCount: patients.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final Patient patient = patients[index];
                          final PatientStatus status =
                              provider.statusForPatient(patient.id);
                          return _PatientTile(
                            patient: patient,
                            status: status,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({
    required this.patient,
    required this.status,
  });

  final Patient patient;
  final PatientStatus status;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status);
    final String statusLabel = _statusLabel(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showPatientDetails(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: VitacareColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: VitacareColors.accent.withValues(alpha: 0.16),
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: VitacareColors.primaryStrong,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(
                        color: VitacareColors.textStrong,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${patient.age} anos | ${patient.chronicCondition}',
                      style: const TextStyle(
                        color: VitacareColors.textSoft,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cuidador: ${patient.caregiver}',
                      style: const TextStyle(color: VitacareColors.textSoft),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resumo do paciente'),
        content: Text(
          'Codigo: ${patient.id}\n'
          'Nome: ${patient.name}\n'
          'Idade: ${patient.age} anos\n'
          'Condicao: ${patient.chronicCondition}\n'
          'Cuidador: ${patient.caregiver}\n'
          'Telefone: ${patient.phone}\n'
          'Cadastro: ${VitacareFormatters.date(patient.createdAt)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/records/history');
            },
            child: const Text('Ver historico'),
          ),
        ],
      ),
    );
  }

  Color _statusColor(PatientStatus status) {
    switch (status) {
      case PatientStatus.stable:
        return Colors.green.shade700;
      case PatientStatus.attention:
        return Colors.orange.shade800;
      case PatientStatus.critical:
        return Colors.red.shade700;
    }
  }

  String _statusLabel(PatientStatus status) {
    switch (status) {
      case PatientStatus.stable:
        return 'Estavel';
      case PatientStatus.attention:
        return 'Atencao';
      case PatientStatus.critical:
        return 'Critico';
    }
  }
}

class _EmptyPatientsState extends StatelessWidget {
  const _EmptyPatientsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum paciente cadastrado ainda.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: VitacareColors.textSoft,
            ),
      ),
    );
  }
}
