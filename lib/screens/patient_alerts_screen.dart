import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class PatientAlertsScreen extends StatelessWidget {
  const PatientAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientProvider provider = context.watch<PatientProvider>();
    final List<Patient> alerts = provider.patientsWithCriticalAlerts;

    return VitacarePageScaffold(
      title: 'Alertas e Status do Paciente',
      selectedRoute: '/alerts',
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pacientes com prioridade alta (${alerts.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: VitacareColors.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use esta tela para monitorar estados criticos e agir rapidamente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VitacareColors.textSoft,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: alerts.isEmpty
                    ? const _NoCriticalAlertsState()
                    : ListView.separated(
                        itemCount: alerts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final Patient patient = alerts[index];
                          final HealthRecord? latest =
                              provider.latestRecordForPatient(patient.id);

                          return _AlertTile(patient: patient, latest: latest);
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

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.patient,
    required this.latest,
  });

  final Patient patient;
  final HealthRecord? latest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade200),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patient.name,
                  style: const TextStyle(
                    color: VitacareColors.textStrong,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.red.shade100,
                ),
                child: Text(
                  'Critico',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Condicao: ${patient.chronicCondition}',
            style: const TextStyle(color: VitacareColors.textSoft),
          ),
          const SizedBox(height: 4),
          Text(
            'Cuidador: ${patient.caregiver} | Contato: ${patient.phone}',
            style: const TextStyle(color: VitacareColors.textSoft),
          ),
          const SizedBox(height: 8),
          if (latest != null)
            Text(
              'Ultimo registro -> Sistolica ${latest!.systolic}, Diastolica ${latest!.diastolic}, Glicemia ${latest!.glucose}',
              style: const TextStyle(
                color: VitacareColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => _showClinicalGuidance(context),
              icon: const Icon(Icons.assignment_late_outlined),
              label: const Text('Orientacao'),
            ),
          ),
        ],
      ),
    );
  }

  void _showClinicalGuidance(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plano rapido de acao'),
        content: Text(
          'Paciente: ${patient.name}\n\n'
          '1. Confirmar sinais vitais novamente.\n'
          '2. Notificar responsavel clinico.\n'
          '3. Registrar condutas no historico.\n'
          '4. Reavaliar em ate 30 minutos.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _NoCriticalAlertsState extends StatelessWidget {
  const _NoCriticalAlertsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            color: Colors.green.shade700,
            size: 52,
          ),
          const SizedBox(height: 10),
          Text(
            'Nenhum alerta critico no momento.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: VitacareColors.textStrong,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Continue registrando dados para manter o monitoramento ativo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: VitacareColors.textSoft,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
