import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/models/patient_progress_summary.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
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
    final PatientProvider provider = context.read<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Historico de Registros',
      subtitle:
          'Consulte registros recuperados em tempo real do Firestore e filtre por paciente.',
      selectedRoute: VitacareRoutes.recordsHistory,
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Patient>>(
            stream: provider.watchPatients(),
            builder: (context, patientSnapshot) {
              if (patientSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (patientSnapshot.hasError) {
                return const Center(child: Text('Erro ao carregar pacientes.'));
              }

              final patients = patientSnapshot.data ?? <Patient>[];
              if (_selectedPatientId != null &&
                  !patients.any(
                    (patient) => patient.id == _selectedPatientId,
                  )) {
                _selectedPatientId = null;
              }

              return StreamBuilder<List<HealthRecord>>(
                stream: provider.watchHealthRecords(
                  patientId: _selectedPatientId,
                ),
                builder: (context, recordSnapshot) {
                  if (recordSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (recordSnapshot.hasError) {
                    return const Center(
                      child: Text('Erro ao carregar registros.'),
                    );
                  }

                  final records = recordSnapshot.data ?? <HealthRecord>[];
                  final selectedMatches = _selectedPatientId == null
                      ? <Patient>[]
                      : patients
                            .where(
                              (patient) => patient.id == _selectedPatientId,
                            )
                            .toList();
                  final Patient? selectedPatient = selectedMatches.isEmpty
                      ? null
                      : selectedMatches.first;
                  final PatientProgressSummary? summary =
                      _selectedPatientId == null
                      ? provider.overallSummaryForRecords(records, patients)
                      : selectedPatient == null
                      ? null
                      : provider.summaryForRecords(
                          records,
                          selectedPatient.createdAt,
                        );

                  return ListView(
                    children: [
                      DropdownButtonFormField<String?>(
                        key: ValueKey<String?>(_selectedPatientId),
                        initialValue: _selectedPatientId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Filtro de paciente',
                          prefixIcon: Icon(Icons.filter_list_rounded),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'Todos os pacientes',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ...patients.map(
                            (patient) => DropdownMenuItem<String?>(
                              value: patient.id,
                              child: Text(
                                '${patient.name} (${patient.id})',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedPatientId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (summary != null) ...[
                        _SummaryPanel(summary: summary),
                        const SizedBox(height: 12),
                      ],
                      if (records.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: _EmptyHistoryState(
                            hasPatients: patients.isNotEmpty,
                          ),
                        )
                      else
                        ...List.generate(records.length, (index) {
                          final record = records[index];
                          final patientMatches = patients
                              .where((item) => item.id == record.patientId)
                              .toList();
                          final Patient? patient = patientMatches.isEmpty
                              ? null
                              : patientMatches.first;

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == records.length - 1 ? 0 : 10,
                            ),
                            child: _HistoryTile(
                              record: record,
                              patient: patient,
                            ),
                          );
                        }),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, required this.patient});

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
                  patient?.name ?? record.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: VitacareColors.textStrong,
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
                  color: levelColor.withValues(alpha: 0.13),
                ),
                child: Text(
                  levelText,
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Editar registro',
                onPressed: () => _showEditDialog(context),
                icon: const Icon(Icons.edit_outlined),
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
              _metricChip('Peso ${record.weight.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Indicadores: ${record.mealStatus} | ${record.mobilityStatus} | ${record.moodStatus} | ${record.sleepStatus}',
            style: const TextStyle(
              color: VitacareColors.textSoft,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adesao: medicacao ${record.medicationAdherence.toLowerCase()} | atividades ${record.activityAdherence.toLowerCase()}',
            style: const TextStyle(
              color: VitacareColors.textSoft,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sintomas: ${record.symptoms}',
            style: const TextStyle(
              color: VitacareColors.textSoft,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Registrado por: ${record.recordedBy}',
            style: const TextStyle(
              color: VitacareColors.textStrong,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
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

  Future<void> _showEditDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final systolicController = TextEditingController(
      text: record.systolic.toString(),
    );
    final diastolicController = TextEditingController(
      text: record.diastolic.toString(),
    );
    final glucoseController = TextEditingController(
      text: record.glucose.toString(),
    );
    final weightController = TextEditingController(
      text: record.weight.toStringAsFixed(1),
    );
    final symptomsController = TextEditingController(text: record.symptoms);
    final recordedByController = TextEditingController(text: record.recordedBy);
    final notesController = TextEditingController(text: record.notes);
    String mealStatus = record.mealStatus;
    String mobilityStatus = record.mobilityStatus;
    String moodStatus = record.moodStatus;
    String sleepStatus = record.sleepStatus;
    String medicationAdherence = record.medicationAdherence;
    String activityAdherence = record.activityAdherence;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final systolic = int.tryParse(systolicController.text.trim());
              final diastolic = int.tryParse(diastolicController.text.trim());
              final glucose = int.tryParse(glucoseController.text.trim());
              final weight = double.tryParse(
                weightController.text.trim().replaceAll(',', '.'),
              );

              if (systolic == null ||
                  diastolic == null ||
                  glucose == null ||
                  weight == null) {
                showVitacareSnackBar(
                  context,
                  'Pressao, glicemia e peso devem ser numericos.',
                  isError: true,
                );
                return;
              }

              setState(() => isSaving = true);
              try {
                await context.read<PatientProvider>().updateHealthRecord(
                  record: record,
                  systolic: systolic,
                  diastolic: diastolic,
                  glucose: glucose,
                  weight: weight,
                  symptoms: symptomsController.text,
                  mealStatus: mealStatus,
                  mobilityStatus: mobilityStatus,
                  moodStatus: moodStatus,
                  sleepStatus: sleepStatus,
                  medicationAdherence: medicationAdherence,
                  activityAdherence: activityAdherence,
                  recordedBy: recordedByController.text,
                  notes: notesController.text,
                );
                if (context.mounted) {
                  Navigator.pop(dialogContext);
                  showVitacareSnackBar(
                    context,
                    'Registro atualizado no Firestore.',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    'Nao foi possivel atualizar o registro.',
                    isError: true,
                  );
                }
              } finally {
                setState(() => isSaving = false);
              }
            }

            return AlertDialog(
              title: const Text('Editar registro de saude'),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _numberField(
                          controller: systolicController,
                          label: 'Pressao sistolica',
                          icon: Icons.favorite_border_rounded,
                        ),
                        const SizedBox(height: 10),
                        _numberField(
                          controller: diastolicController,
                          label: 'Pressao diastolica',
                          icon: Icons.favorite_outline_rounded,
                        ),
                        const SizedBox(height: 10),
                        _numberField(
                          controller: glucoseController,
                          label: 'Glicemia',
                          icon: Icons.water_drop_outlined,
                        ),
                        const SizedBox(height: 10),
                        _numberField(
                          controller: weightController,
                          label: 'Peso',
                          icon: Icons.monitor_weight_outlined,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: symptomsController,
                          minLines: 2,
                          maxLines: 3,
                          decoration: vitacareInputDecoration(
                            label: 'Sintomas',
                            hint: 'Sintomas observados',
                            icon: Icons.sick_outlined,
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Informe os sintomas.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Alimentacao',
                          icon: Icons.restaurant_outlined,
                          value: mealStatus,
                          options: const [
                            'Alimentacao adequada',
                            'Alimentacao parcial',
                            'Baixa ingestao alimentar',
                          ],
                          onChanged: (value) =>
                              setState(() => mealStatus = value!),
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Locomocao',
                          icon: Icons.accessible_forward_rounded,
                          value: mobilityStatus,
                          options: const [
                            'Locomocao preservada',
                            'Caminhou com apoio leve',
                            'Necessita apoio frequente',
                          ],
                          onChanged: (value) =>
                              setState(() => mobilityStatus = value!),
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Humor',
                          icon: Icons.mood_outlined,
                          value: moodStatus,
                          options: const [
                            'Bem-humorado',
                            'Atencao moderada',
                            'Apatica',
                          ],
                          onChanged: (value) =>
                              setState(() => moodStatus = value!),
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Sono',
                          icon: Icons.bedtime_outlined,
                          value: sleepStatus,
                          options: const [
                            'Sono regular',
                            'Sono irregular',
                            'Sono ruim',
                          ],
                          onChanged: (value) =>
                              setState(() => sleepStatus = value!),
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Adesao medicamentosa',
                          icon: Icons.medication_outlined,
                          value: medicationAdherence,
                          options: const [
                            'Completa',
                            'Parcial',
                            'Nao realizada',
                          ],
                          onChanged: (value) =>
                              setState(() => medicationAdherence = value!),
                        ),
                        const SizedBox(height: 10),
                        _StatusDropdown(
                          label: 'Atividades planejadas',
                          icon: Icons.checklist_rounded,
                          value: activityAdherence,
                          options: const [
                            'Realizada',
                            'Parcial',
                            'Nao realizada',
                          ],
                          onChanged: (value) =>
                              setState(() => activityAdherence = value!),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: recordedByController,
                          decoration: vitacareInputDecoration(
                            label: 'Registrado por',
                            hint: 'Responsavel',
                            icon: Icons.badge_outlined,
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Informe o responsavel.'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: notesController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: vitacareInputDecoration(
                            label: 'Observacoes',
                            hint: 'Observacoes clinicas',
                            icon: Icons.note_alt_outlined,
                          ),
                          validator: (value) => (value ?? '').trim().isEmpty
                              ? 'Informe uma observacao.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving ? null : save,
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    systolicController.dispose();
    diastolicController.dispose();
    glucoseController.dispose();
    weightController.dispose();
    symptomsController.dispose();
    recordedByController.dispose();
    notesController.dispose();
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: vitacareInputDecoration(
        label: label,
        hint: label,
        icon: icon,
      ),
      validator: (value) =>
          (value ?? '').trim().isEmpty ? 'Campo obrigatorio.' : null,
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

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: vitacareInputDecoration(
        label: label,
        hint: label,
        icon: icon,
      ),
      items: options
          .map(
            (option) => DropdownMenuItem<String>(
              value: option,
              child: Text(option, overflow: TextOverflow.ellipsis, maxLines: 1),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.summary});

  final PatientProgressSummary summary;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (summary.clinicalStatusLabel) {
      'Melhora' => Colors.green.shade700,
      'Piora' => Colors.red.shade700,
      _ => Colors.orange.shade800,
    };

    final String trendLabel = summary.trendSlope > 4
        ? 'Crescente'
        : summary.trendSlope < -4
        ? 'Decrescente'
        : 'Estavel';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VitacareColors.surfaceTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VitacareColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _summaryChip(
                'Media do periodo',
                'PA ${summary.averageSystolic.toStringAsFixed(0)}/${summary.averageDiastolic.toStringAsFixed(0)} | Glicemia ${summary.averageGlucose.toStringAsFixed(0)}',
              ),
              _summaryChip(
                'Variacao',
                '${summary.absoluteVariation >= 0 ? '+' : ''}${summary.absoluteVariation.toStringAsFixed(0)} mg/dL | ${summary.percentageVariation.toStringAsFixed(1)}%',
              ),
              _summaryChip(
                'Dentro da faixa ideal',
                '${summary.idealReadingsPercent.toStringAsFixed(1)}%',
              ),
              _summaryChip(
                'Adesao aos registros',
                '${summary.adherencePercent.toStringAsFixed(1)}%',
              ),
              _summaryChip(
                'Peso medio',
                '${summary.averageWeight.toStringAsFixed(1)} kg',
              ),
              _summaryChip('Tendencia linear', trendLabel),
              _summaryChip('Total de registros', '${summary.totalRecords}'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: statusColor.withValues(alpha: 0.12),
            ),
            child: Text(
              'Classificacao automatica: ${summary.clinicalStatusLabel}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VitacareColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: VitacareColors.textSoft,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: VitacareColors.textStrong,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({required this.hasPatients});

  final bool hasPatients;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timeline_outlined,
            color: VitacareColors.textSoft,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            hasPatients
                ? 'Nenhum registro encontrado para o filtro selecionado.'
                : 'Cadastre um paciente antes de criar registros.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: VitacareColors.textSoft,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context,
              hasPatients
                  ? VitacareRoutes.healthRecord
                  : VitacareRoutes.patientRegistration,
            ),
            child: Text(hasPatients ? 'Criar registro' : 'Cadastrar paciente'),
          ),
        ],
      ),
    );
  }
}
