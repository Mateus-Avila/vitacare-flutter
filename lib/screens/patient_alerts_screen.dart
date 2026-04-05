import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/models/patient_progress_summary.dart';
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
      subtitle:
          'Monitore pacientes em prioridade alta e acione orientacoes de acompanhamento quando necessario.',
      selectedRoute: VitacareRoutes.alerts,
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pacientes com prioridade alta: ${alerts.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: VitacareColors.textStrong,
                  fontWeight: FontWeight.w700,
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
                          final HealthRecord? latest = provider
                              .latestRecordForPatient(patient.id);
                          final PatientProgressSummary? summary = provider
                              .summaryForPatient(patient.id);

                          return _AlertTile(
                            patient: patient,
                            latest: latest,
                            summary: summary,
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

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.patient,
    required this.latest,
    required this.summary,
  });

  final Patient patient;
  final HealthRecord? latest;
  final PatientProgressSummary? summary;

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
          if (latest != null) ...[
            const SizedBox(height: 4),
            Text(
              'Indicadores complementares -> Peso ${latest!.weight.toStringAsFixed(1)} kg | ${latest!.symptoms}',
              style: const TextStyle(
                color: VitacareColors.textSoft,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ultimo responsavel pelo registro: ${latest!.recordedBy}',
              style: const TextStyle(
                color: VitacareColors.textStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (summary != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoChip('Classificacao ${summary!.clinicalStatusLabel}'),
                _infoChip(
                  'Faixa ideal ${summary!.idealReadingsPercent.toStringAsFixed(0)}%',
                ),
                _infoChip(
                  'Adesao ${summary!.adherencePercent.toStringAsFixed(0)}%',
                ),
              ],
            ),
          ],
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
    showVitacareInfoDialog(
      context,
      title: 'Plano rapido de acao',
      message:
          'Paciente: ${patient.name}\n\n1. Confirmar sinais vitais novamente.\n2. Notificar o responsavel clinico.\n3. Registrar condutas no historico.\n4. Reavaliar em ate 30 minutos.',
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: VitacareColors.accent.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: VitacareColors.primaryStrong,
          fontWeight: FontWeight.w700,
        ),
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
          Icon(Icons.verified_rounded, color: Colors.green.shade700, size: 52),
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
            'Continue registrando dados para manter o monitoramento ativo na demonstracao.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: VitacareColors.textSoft),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
