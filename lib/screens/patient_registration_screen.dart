import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() => _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _caregiverController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _caregiverController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _savePatient() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      showVitacareSnackBar(
        context,
        'Preencha os dados obrigatorios do paciente.',
        isError: true,
      );
      return;
    }

    final int? age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      showVitacareSnackBar(
        context,
        'Informe uma idade valida entre 1 e 120.',
        isError: true,
      );
      return;
    }

    final String patientId = context.read<PatientProvider>().addPatient(
          name: _nameController.text,
          age: age,
          chronicCondition: _conditionController.text,
          caregiver: _caregiverController.text,
          phone: _phoneController.text,
        );

    await showVitacareInfoDialog(
      context,
      title: 'Paciente cadastrado',
      message:
          'Cadastro concluido com sucesso.\nCodigo gerado: $patientId.\n\nO paciente ja pode receber novos registros e aparecer nas listagens do projeto.',
      actionLabel: 'Continuar',
    );

    if (!mounted) {
      return;
    }

    _formKey.currentState?.reset();
    _nameController.clear();
    _ageController.clear();
    _conditionController.clear();
    _caregiverController.clear();
    _phoneController.clear();

    showVitacareSnackBar(
      context,
      'Paciente adicionado com sucesso na listagem demonstrativa.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return VitacarePageScaffold(
      title: 'Cadastro de Paciente',
      selectedRoute: '/patients/register',
      child: SingleChildScrollView(
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
                      'Novo paciente',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: VitacareColors.textStrong,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cadastre pacientes idosos ou cronicos para centralizar informacoes basicas de cuidado e acompanhamento continuo.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: VitacareColors.textSoft,
                          ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: _nameController,
                      decoration: vitacareInputDecoration(
                        label: 'Nome do paciente',
                        hint: 'Ex: Maria da Silva',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o nome do paciente.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: vitacareInputDecoration(
                        label: 'Idade',
                        hint: 'Ex: 72',
                        icon: Icons.calendar_today_outlined,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe a idade.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _conditionController,
                      decoration: vitacareInputDecoration(
                        label: 'Doenca cronica principal',
                        hint: 'Ex: Diabetes tipo 2',
                        icon: Icons.health_and_safety_outlined,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe a condicao principal.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _caregiverController,
                      decoration: vitacareInputDecoration(
                        label: 'Cuidador responsavel',
                        hint: 'Ex: Ana Souza',
                        icon: Icons.groups_rounded,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o cuidador responsavel.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: vitacareInputDecoration(
                        label: 'Telefone para contato',
                        hint: '(16) 99999-9999',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Informe o telefone de contato.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    VitacarePrimaryButton(
                      onPressed: _savePatient,
                      label: 'Salvar paciente',
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
}
