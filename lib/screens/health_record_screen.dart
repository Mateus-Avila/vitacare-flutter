import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
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
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _recordedByController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedPatientId;
  String _mealStatus = 'Alimentacao adequada';
  String _mobilityStatus = 'Locomocao preservada';
  String _moodStatus = 'Bem-humorado';
  String _sleepStatus = 'Sono regular';
  String _medicationAdherence = 'Completa';
  String _activityAdherence = 'Realizada';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_recordedByController.text.isNotEmpty) {
      return;
    }

    final String? currentUserName = context
        .read<AuthProvider>()
        .currentUser
        ?.name;
    if (currentUserName != null && currentUserName.isNotEmpty) {
      _recordedByController.text = currentUserName;
    }
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _glucoseController.dispose();
    _weightController.dispose();
    _symptomsController.dispose();
    _recordedByController.dispose();
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
    final double? weight = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
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

    final HealthRecord record = context.read<PatientProvider>().addHealthRecord(
      patientId: _selectedPatientId!,
      systolic: systolic,
      diastolic: diastolic,
      glucose: glucose,
      weight: weight,
      symptoms: _symptomsController.text,
      mealStatus: _mealStatus,
      mobilityStatus: _mobilityStatus,
      moodStatus: _moodStatus,
      sleepStatus: _sleepStatus,
      medicationAdherence: _medicationAdherence,
      activityAdherence: _activityAdherence,
      recordedBy: _recordedByController.text,
      notes: _notesController.text,
    );

    _systolicController.clear();
    _diastolicController.clear();
    _glucoseController.clear();
    _weightController.clear();
    _symptomsController.clear();
    _recordedByController.clear();
    _notesController.clear();
    setState(() {
      _mealStatus = 'Alimentacao adequada';
      _mobilityStatus = 'Locomocao preservada';
      _moodStatus = 'Bem-humorado';
      _sleepStatus = 'Sono regular';
      _medicationAdherence = 'Completa';
      _activityAdherence = 'Realizada';
    });

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
        Navigator.pushReplacementNamed(context, VitacareRoutes.alerts);
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
      subtitle:
          'Registre sinais clinicos e observacoes da visita para manter o historico do cuidado atualizado.',
      selectedRoute: VitacareRoutes.healthRecord,
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
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            key: ValueKey<String?>(_selectedPatientId),
                            initialValue: _selectedPatientId,
                            isExpanded: true,
                            decoration: vitacareInputDecoration(
                              label: 'Paciente',
                              hint: 'Selecione um paciente',
                              icon: Icons.person_outline_rounded,
                            ),
                            items: patients
                                .map(
                                  (patient) => DropdownMenuItem<String>(
                                    value: patient.id,
                                    child: Text(
                                      '${patient.name} (${patient.id})',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
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
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: vitacareInputDecoration(
                              label: 'Peso (kg)',
                              hint: 'Ex: 68,4',
                              icon: Icons.monitor_weight_outlined,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Informe o peso atual.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _symptomsController,
                            minLines: 2,
                            maxLines: 3,
                            decoration: vitacareInputDecoration(
                              label: 'Sintomas observados',
                              hint:
                                  'Ex: cansaco, tontura, sem queixas relevantes',
                              icon: Icons.sick_outlined,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Descreva os sintomas ou indique ausencia.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Alimentacao',
                            icon: Icons.restaurant_outlined,
                            value: _mealStatus,
                            options: const [
                              'Alimentacao adequada',
                              'Alimentacao parcial',
                              'Baixa ingestao alimentar',
                            ],
                            onChanged: (value) {
                              setState(() => _mealStatus = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Locomocao',
                            icon: Icons.accessible_forward_rounded,
                            value: _mobilityStatus,
                            options: const [
                              'Locomocao preservada',
                              'Caminhou com apoio leve',
                              'Necessita apoio frequente',
                            ],
                            onChanged: (value) {
                              setState(() => _mobilityStatus = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Humor',
                            icon: Icons.mood_outlined,
                            value: _moodStatus,
                            options: const [
                              'Bem-humorado',
                              'Atencao moderada',
                              'Apatica',
                            ],
                            onChanged: (value) {
                              setState(() => _moodStatus = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Sono',
                            icon: Icons.bedtime_outlined,
                            value: _sleepStatus,
                            options: const [
                              'Sono regular',
                              'Sono irregular',
                              'Sono ruim',
                            ],
                            onChanged: (value) {
                              setState(() => _sleepStatus = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Adesao medicamentosa',
                            icon: Icons.medication_outlined,
                            value: _medicationAdherence,
                            options: const [
                              'Completa',
                              'Parcial',
                              'Nao realizada',
                            ],
                            onChanged: (value) {
                              setState(() => _medicationAdherence = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          _StatusDropdown(
                            label: 'Atividades planejadas',
                            icon: Icons.checklist_rounded,
                            value: _activityAdherence,
                            options: const [
                              'Realizada',
                              'Parcial',
                              'Nao realizada',
                            ],
                            onChanged: (value) {
                              setState(() => _activityAdherence = value!);
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _recordedByController,
                            decoration: vitacareInputDecoration(
                              label: 'Registrado por',
                              hint: 'Ex: Cuidadora Ana ou Enfermeiro Lucas',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return 'Informe quem realizou o registro.';
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
                    VitacareRoutes.patientRegistration,
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
              child: Text(
                option,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
