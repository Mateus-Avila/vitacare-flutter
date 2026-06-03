import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_formatters.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/cep_address.dart';
import 'package:vitacare_flutter/models/patient.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/services/api_service.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientProvider provider = context.read<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Listagem de Pacientes',
      subtitle:
          'Visualize pacientes salvos no Firestore em tempo real, separados pelo usuario logado.',
      selectedRoute: VitacareRoutes.patientList,
      child: VitacareGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<List<Patient>>(
            stream: provider.watchPatients(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: 'Erro ao carregar pacientes do Firestore.',
                  detail: snapshot.error.toString(),
                );
              }

              final patients = snapshot.data ?? <Patient>[];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pacientes cadastrados: ${patients.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: VitacareColors.textStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: patients.isEmpty
                        ? const _EmptyPatientsState()
                        : ListView.builder(
                            itemCount: patients.length,
                            itemBuilder: (context, index) {
                              final patient = patients[index];
                              final status = provider.statusFromPatient(
                                patient,
                              );
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == patients.length - 1 ? 0 : 10,
                                ),
                                child: _PatientTile(
                                  patient: patient,
                                  status: status,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PatientTile extends StatelessWidget {
  const _PatientTile({required this.patient, required this.status});

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
                    if (patient.cep.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${patient.city} - ${patient.state} | ${patient.street}',
                        style: const TextStyle(color: VitacareColors.textSoft),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      patient.latestRecordAt == null
                          ? 'Sem registro clinico ainda.'
                          : 'Ultimo registro: ${VitacareFormatters.dateTime(patient.latestRecordAt!)}',
                      style: const TextStyle(color: VitacareColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
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
                  IconButton(
                    tooltip: 'Editar paciente',
                    onPressed: () => _showEditDialog(context),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPatientDetails(BuildContext context) {
    final addressText = patient.cep.isEmpty
        ? ''
        : 'Endereco: ${patient.street}, ${patient.city} - ${patient.state}\n'
              'CEP: ${patient.cep}\n';

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Resumo do paciente'),
        content: Text(
          'Codigo Firestore: ${patient.id}\n'
          'Nome: ${patient.name}\n'
          'Idade: ${patient.age} anos\n'
          'Condicao principal: ${patient.chronicCondition}\n'
          'Cuidador responsavel: ${patient.caregiver}\n'
          'Telefone: ${patient.phone}\n'
          '$addressText'
          'Cadastro: ${VitacareFormatters.date(patient.createdAt)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(
                context,
                VitacareRoutes.recordsHistory,
                arguments: patient.id,
              );
              showVitacareSnackBar(
                context,
                'Historico filtrado para ${patient.name}.',
              );
            },
            child: const Text('Ver historico'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: patient.name);
    final ageController = TextEditingController(text: patient.age.toString());
    final conditionController = TextEditingController(
      text: patient.chronicCondition,
    );
    final caregiverController = TextEditingController(text: patient.caregiver);
    final phoneController = TextEditingController(text: patient.phone);
    final cepController = TextEditingController(text: patient.cep);
    final cityController = TextEditingController(text: patient.city);
    final stateController = TextEditingController(text: patient.state);
    final streetController = TextEditingController(text: patient.street);
    final apiService = ApiService();
    bool isSaving = false;
    bool isSearchingCep = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> save() async {
              if (!(formKey.currentState?.validate() ?? false)) {
                return;
              }

              final age = int.tryParse(ageController.text.trim());
              if (age == null || age < 1 || age > 120) {
                showVitacareSnackBar(
                  context,
                  'Informe uma idade valida entre 1 e 120.',
                  isError: true,
                );
                return;
              }

              setState(() => isSaving = true);
              try {
                await context.read<PatientProvider>().updatePatient(
                  patient: patient,
                  name: nameController.text,
                  age: age,
                  chronicCondition: conditionController.text,
                  caregiver: caregiverController.text,
                  phone: phoneController.text,
                  cep: cepController.text,
                  city: cityController.text,
                  state: stateController.text,
                  street: streetController.text,
                );
                if (context.mounted) {
                  setState(() => isSaving = false);
                  Navigator.pop(dialogContext);
                  showVitacareSnackBar(
                    context,
                    'Paciente atualizado no Firestore.',
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    'Nao foi possivel atualizar o paciente.',
                    isError: true,
                  );
                }
              } finally {
                if (isSaving && context.mounted) {
                  setState(() => isSaving = false);
                }
              }
            }

            Future<void> searchCep() async {
              setState(() => isSearchingCep = true);
              try {
                final CepAddress address = await apiService.fetchCep(
                  cepController.text,
                );
                cepController.text = address.cep;
                cityController.text = address.city;
                stateController.text = address.state;
                streetController.text = address.street;
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    'Endereco preenchido via ViaCEP.',
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  showVitacareSnackBar(
                    context,
                    vitacareFriendlyErrorMessage(
                      error,
                      'Nao foi possivel consultar o CEP.',
                    ),
                    isError: true,
                  );
                }
              } finally {
                if (context.mounted) {
                  setState(() => isSearchingCep = false);
                }
              }
            }

            return AlertDialog(
              title: const Text('Editar paciente'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: vitacareInputDecoration(
                          label: 'Nome',
                          hint: 'Nome do paciente',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Informe o nome.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: vitacareInputDecoration(
                          label: 'Idade',
                          hint: 'Ex: 72',
                          icon: Icons.calendar_today_outlined,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Informe a idade.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: conditionController,
                        decoration: vitacareInputDecoration(
                          label: 'Condicao',
                          hint: 'Doenca cronica principal',
                          icon: Icons.health_and_safety_outlined,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Informe a condicao.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: caregiverController,
                        decoration: vitacareInputDecoration(
                          label: 'Cuidador',
                          hint: 'Responsavel',
                          icon: Icons.groups_rounded,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Informe o cuidador.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneController,
                        decoration: vitacareInputDecoration(
                          label: 'Telefone',
                          hint: '(16) 99999-9999',
                          icon: Icons.phone_outlined,
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Informe o telefone.'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: cepController,
                              keyboardType: TextInputType.number,
                              decoration: vitacareInputDecoration(
                                label: 'CEP',
                                hint: 'Ex: 14010000',
                                icon: Icons.location_on_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 126,
                            height: 64,
                            child: FilledButton.icon(
                              onPressed: isSearchingCep ? null : searchCep,
                              icon: isSearchingCep
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.search_rounded),
                              label: Text(
                                isSearchingCep ? 'Buscando' : 'Buscar',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: cityController,
                        enabled: false,
                        decoration: vitacareInputDecoration(
                          label: 'Cidade',
                          hint: 'Preenchida pelo CEP',
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: stateController,
                        enabled: false,
                        decoration: vitacareInputDecoration(
                          label: 'Estado',
                          hint: 'UF',
                          icon: Icons.map_outlined,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: streetController,
                        enabled: false,
                        decoration: vitacareInputDecoration(
                          label: 'Logradouro',
                          hint: 'Preenchido pelo CEP',
                          icon: Icons.signpost_outlined,
                        ),
                      ),
                    ],
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

    nameController.dispose();
    ageController.dispose();
    conditionController.dispose();
    caregiverController.dispose();
    phoneController.dispose();
    cepController.dispose();
    cityController.dispose();
    stateController.dispose();
    streetController.dispose();
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

class _EmptyPatientsState extends StatefulWidget {
  const _EmptyPatientsState();

  @override
  State<_EmptyPatientsState> createState() => _EmptyPatientsStateState();
}

class _EmptyPatientsStateState extends State<_EmptyPatientsState> {
  bool _isSeeding = false;

  Future<void> _loadDemo() async {
    setState(() => _isSeeding = true);
    try {
      await context.read<PatientProvider>().seedDemoData();
      if (mounted) {
        showVitacareSnackBar(context, 'Dados de demonstracao carregados.');
      }
    } catch (_) {
      if (mounted) {
        showVitacareSnackBar(
          context,
          'Nao foi possivel carregar os dados de demonstracao.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add_alt_1_outlined,
              size: 52,
              color: VitacareColors.textSoft,
            ),
            const SizedBox(height: 10),
            Text(
              'Nenhum paciente cadastrado para este usuario.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: VitacareColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.patientRegistration,
              ),
              child: const Text('Cadastrar primeiro paciente'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isSeeding ? null : _loadDemo,
              child: _isSeeding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Carregar dados de demonstracao'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.detail});

  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(
              detail!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
