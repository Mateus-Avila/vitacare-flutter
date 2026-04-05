import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class RecordsHistoryScreen extends StatefulWidget {
  const RecordsHistoryScreen({super.key, this.initialPatientId});

  final String? initialPatientId;

  @override
  State<RecordsHistoryScreen> createState() => _RecordsHistoryScreenState();
}

class _RecordsHistoryScreenState extends State<RecordsHistoryScreen> {
  String? _selectedPatientId;

  @override
  void initState() {
    super.initState();
    _selectedPatientId = widget.initialPatientId;
  }

  @override
  Widget build(BuildContext context) {
    final PatientProvider provider = context.watch<PatientProvider>();
    final List<Patient> patients = provider.patients;

    final List<HealthRecord> records = _selectedPatientId == null
        ? provider.allRecordsSorted
        : provider.recordsForPatient(_selectedPatientId!);

    return VitacarePageScaffold(
      title: 'Historico de Registros',
      selectedRoute: '/records/history',
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolucao dos pacientes',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: VitacareColors.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Filtre por paciente para acompanhar tendencias de saude.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VitacareColors.textSoft,
                    ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: ValueKey<String?>(_selectedPatientId),
                initialValue: _selectedPatientId,
                decoration: const InputDecoration(
                  labelText: 'Filtro de paciente',
                  prefixIcon: Icon(Icons.filter_list_rounded),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todos os pacientes'),
                  ),
                  ...patients.map(
                    (patient) => DropdownMenuItem<String?>(
                      value: patient.id,
                      child: Text('${patient.name} (${patient.id})'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _selectedPatientId = value);
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: records.isEmpty
                    ? const _EmptyHistoryState()
                    : ListView.separated(
                        itemCount: records.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final HealthRecord record = records[index];
                          final Patient? patient =
                              provider.getPatientById(record.patientId);
                          return _HistoryTile(record: record, patient: patient);
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
    required this.patient,
  });

  final HealthRecord record;
  final Patient? patient;

  @override
  Widget build(BuildContext context) {
    final Color levelColor = record.isCritical
        ? Colors.red.shade700
        : record.isAttention
            ? Colors.orange.shade800
            : Colors.green.shade700;

    final String levelText = record.isCritical
        ? 'Critico'
        : record.isAttention
            ? 'Atencao'
            : 'Estavel';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VitacareColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  patient?.name ?? 'Paciente nao encontrado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: VitacareColors.textStrong,
                    fontSize: 15.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: levelColor.withValues(alpha: 0.13),
                ),
                child: Text(
                  levelText,
                  style: TextStyle(color: levelColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Data: ${VitacareFormatters.dateTime(record.recordedAt)}',
            style: const TextStyle(color: VitacareColors.textSoft),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metricChip('Sistolica ${record.systolic}'),
              _metricChip('Diastolica ${record.diastolic}'),
              _metricChip('Glicemia ${record.glucose}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Observacoes: ${record.notes}',
            style: const TextStyle(
              color: VitacareColors.textSoft,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: VitacareColors.accent.withValues(alpha: 0.12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: VitacareColors.primaryStrong,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Nenhum registro encontrado para o filtro selecionado.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: VitacareColors.textSoft,
            ),
      ),
    );
  }
}
