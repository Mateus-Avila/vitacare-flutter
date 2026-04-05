import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedPatientId;

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _glucoseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    FocusScope.of(context).unfocus();

    if (_selectedPatientId == null) {
      showVitacareSnackBar(
        context,
        'Selecione um paciente para registrar.',
        isError: true,
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      showVitacareSnackBar(
        context,
        'Revise os dados de saude informados.',
        isError: true,
      );
      return;
    }

    final int? systolic = int.tryParse(_systolicController.text.trim());
    final int? diastolic = int.tryParse(_diastolicController.text.trim());
    final int? glucose = int.tryParse(_glucoseController.text.trim());

    if (systolic == null || diastolic == null || glucose == null) {
      showVitacareSnackBar(
        context,
        'Todos os valores devem ser numericos.',
        isError: true,
      );
      return;
    }

    final HealthRecord record = context.read<PatientProvider>().addHealthRecord(
          patientId: _selectedPatientId!,
          systolic: systolic,
          diastolic: diastolic,
          glucose: glucose,
          notes: _notesController.text,
        );

    _systolicController.clear();
    _diastolicController.clear();
    _glucoseController.clear();
    _notesController.clear();

    if (record.isCritical) {
      final bool openAlerts = await showVitacareConfirmationDialog(
        context,
        title: 'Alerta critico detectado',
        message:
            'Os dados registrados indicam risco elevado. Priorize a reavaliacao do paciente e acompanhe o caso na tela de alertas.',
        confirmLabel: 'Abrir alertas',
        cancelLabel: 'Fechar',
      );
      if (openAlerts && mounted) {
        Navigator.pushReplacementNamed(context, '/alerts');
      }
      return;
    }

    showVitacareSnackBar(
      context,
      'Registro salvo com sucesso no historico demonstrativo.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Patient> patients = context.watch<PatientProvider>().patients;

    return VitacarePageScaffold(
      title: 'Registro de Dados de Saude',
      selectedRoute: '/records/register',
      child: patients.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: VitacareGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Novo registro clinico',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: VitacareColors.textStrong,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Registre pressao arterial, glicemia e observacoes para apoiar a equipe no acompanhamento continuo do paciente.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: VitacareColors.textSoft,
                                ),
                          ),
                          const SizedBox(height: 18),
                          DropdownButtonFormField<String>(
                            key: ValueKey<String?>(_selectedPatientId),
                            initialValue: _selectedPatientId,
                            decoration: vitacareInputDecoration(
                              label: 'Paciente',
                              hint: 'Selecione um paciente',
                              icon: Icons.person_outline_rounded,
                            ),
                            items: patients
                                .map(
                                  (patient) => DropdownMenuItem<String>(
                                    value: patient.id,
                                    child: Text('${patient.name} (${patient.id})'),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedPatientId = value);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _systolicController,
                            keyboardType: TextInputType.number,
                            decoration: vitacareInputDecoration(
                              label: 'Pressao sistolica (mmHg)',
                              hint: 'Ex: 130',
                              icon: Icons.favorite_border_rounded,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Informe a pressao sistolica.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _diastolicController,
                            keyboardType: TextInputType.number,
                            decoration: vitacareInputDecoration(
                              label: 'Pressao diastolica (mmHg)',
                              hint: 'Ex: 85',
                              icon: Icons.favorite_outline_rounded,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Informe a pressao diastolica.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _glucoseController,
                            keyboardType: TextInputType.number,
                            decoration: vitacareInputDecoration(
                              label: 'Glicemia (mg/dL)',
                              hint: 'Ex: 118',
                              icon: Icons.water_drop_outlined,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Informe o valor da glicemia.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            minLines: 3,
                            maxLines: 5,
                            decoration: vitacareInputDecoration(
                              label: 'Observacoes',
                              hint:
                                  'Descreva sintomas, adesao, humor ou orientacoes da visita.',
                              icon: Icons.note_alt_outlined,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Registre uma observacao clinica.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          VitacarePrimaryButton(
                            onPressed: _saveRecord,
                            label: 'Salvar registro',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: VitacareGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 52,
                  color: VitacareColors.textSoft,
                ),
                const SizedBox(height: 12),
                Text(
                  'Cadastre ao menos um paciente para registrar parametros de saude, observacoes e sinais de risco.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: VitacareColors.textStrong,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    '/patients/register',
                  ),
                  child: const Text('Ir para cadastro'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
