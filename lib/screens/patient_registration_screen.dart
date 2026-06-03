import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/cep_address.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/services/api_service.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class PatientRegistrationScreen extends StatefulWidget {
  const PatientRegistrationScreen({super.key});

  @override
  State<PatientRegistrationScreen> createState() =>
      _PatientRegistrationScreenState();
}

class _PatientRegistrationScreenState extends State<PatientRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _caregiverController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isSaving = false;
  bool _isSearchingCep = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _caregiverController.dispose();
    _phoneController.dispose();
    _cepController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _searchCep() async {
    FocusScope.of(context).unfocus();
    setState(() => _isSearchingCep = true);

    try {
      final CepAddress address = await _apiService.fetchCep(
        _cepController.text,
      );
      if (!mounted) {
        return;
      }
      _cepController.text = address.cep;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _streetController.text = address.street;
      showVitacareSnackBar(context, 'Endereco preenchido via ViaCEP.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      showVitacareSnackBar(
        context,
        vitacareFriendlyErrorMessage(
          error,
          'Nao foi possivel consultar o CEP.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSearchingCep = false);
      }
    }
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

    setState(() => _isSaving = true);

    try {
      final String patientId = await context.read<PatientProvider>().addPatient(
        name: _nameController.text,
        age: age,
        chronicCondition: _conditionController.text,
        caregiver: _caregiverController.text,
        phone: _phoneController.text,
        cep: _cepController.text,
        city: _cityController.text,
        state: _stateController.text,
        street: _streetController.text,
      );

      if (!mounted) {
        return;
      }

      await showVitacareInfoDialog(
        context,
        title: 'Paciente cadastrado',
        message:
            'Cadastro concluido com sucesso.\nCodigo Firestore: $patientId.\n\nO paciente ja pode receber novos registros e aparecer nas listagens em tempo real.',
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
      _cepController.clear();
      _cityController.clear();
      _stateController.clear();
      _streetController.clear();

      showVitacareSnackBar(
        context,
        'Paciente salvo no Firestore com separacao por usuario.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      showVitacareSnackBar(
        context,
        'Nao foi possivel salvar o paciente. Tente novamente.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VitacarePageScaffold(
      title: 'Cadastro de Paciente',
      subtitle:
          'Registre os dados basicos do paciente e do cuidador para iniciar o acompanhamento no sistema.',
      selectedRoute: VitacareRoutes.patientRegistration,
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
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cepController,
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
                          width: 132,
                          height: 64,
                          child: FilledButton.icon(
                            onPressed: _isSearchingCep ? null : _searchCep,
                            icon: _isSearchingCep
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.search_rounded),
                            label: Text(_isSearchingCep ? 'Buscando' : 'Buscar'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      enabled: false,
                      decoration: vitacareInputDecoration(
                        label: 'Cidade',
                        hint: 'Preenchida pelo CEP',
                        icon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _stateController,
                      enabled: false,
                      decoration: vitacareInputDecoration(
                        label: 'Estado',
                        hint: 'UF',
                        icon: Icons.map_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _streetController,
                      enabled: false,
                      decoration: vitacareInputDecoration(
                        label: 'Logradouro',
                        hint: 'Preenchido pelo CEP',
                        icon: Icons.signpost_outlined,
                      ),
                    ),
                    const SizedBox(height: 18),
                    VitacarePrimaryButton(
                      onPressed: _savePatient,
                      label: _isSaving ? 'Salvando...' : 'Salvar paciente',
                      isLoading: _isSaving,
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
