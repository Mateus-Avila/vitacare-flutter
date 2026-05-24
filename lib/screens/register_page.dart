import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/core/vitacare_validators.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_background.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_logo.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _profileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _profileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      showVitacareSnackBar(
        context,
        'Revise os campos obrigatorios.',
        isError: true,
      );
      return;
    }

    final AuthProvider authProvider = context.read<AuthProvider>();
    final result = await authProvider.register(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      city: _cityController.text,
      profile: _profileController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      showVitacareSnackBar(context, result.message, isError: true);
      return;
    }

    showVitacareSnackBar(context, result.message);
    Navigator.pushNamedAndRemoveUntil(
      context,
      VitacareRoutes.dashboard,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Stack(
        children: [
          const VitacareBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: VitacareGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const VitacareLogo(height: 92),
                            const SizedBox(height: 14),
                            Text(
                              'Cadastro de conta',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: VitacareColors.textStrong,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crie sua conta para acessar os modulos academicos de cadastro, registros, historico e alertas do VitaCare.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: VitacareColors.textSoft,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: vitacareInputDecoration(
                                label: 'Nome completo',
                                hint: 'Ex: Ana Souza',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Informe seu nome.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: vitacareInputDecoration(
                                label: 'E-mail',
                                hint: 'voce@instituicao.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                              validator: (value) {
                                final String email = (value ?? '').trim();
                                if (email.isEmpty) {
                                  return 'Informe o e-mail.';
                                }
                                if (!VitacareValidators.isValidEmail(email)) {
                                  return 'Digite um e-mail valido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: vitacareInputDecoration(
                                label: 'Telefone',
                                hint: '(16) 99999-9999',
                                icon: Icons.phone_outlined,
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Informe o telefone.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _cityController,
                              textInputAction: TextInputAction.next,
                              decoration: vitacareInputDecoration(
                                label: 'Cidade',
                                hint: 'Ex: Ribeirao Preto',
                                icon: Icons.location_city_outlined,
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Informe sua cidade.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _profileController,
                              textInputAction: TextInputAction.next,
                              decoration: vitacareInputDecoration(
                                label: 'Perfil ou area',
                                hint: 'Ex: Cuidador, enfermagem, familiar',
                                icon: Icons.badge_outlined,
                              ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Informe seu perfil ou area.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  vitacareInputDecoration(
                                    label: 'Senha',
                                    hint: '8+ caracteres, numero e simbolo',
                                    icon: Icons.lock_outline_rounded,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(
                                          () => _hidePassword = !_hidePassword,
                                        );
                                      },
                                      icon: Icon(
                                        _hidePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                              validator: (value) {
                                return VitacareValidators.strongPasswordError(
                                  value ?? '',
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _hideConfirmPassword,
                              textInputAction: TextInputAction.done,
                              decoration:
                                  vitacareInputDecoration(
                                    label: 'Confirmacao de senha',
                                    hint: 'Repita a senha',
                                    icon: Icons.verified_user_outlined,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _hideConfirmPassword =
                                              !_hideConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _hideConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                    ),
                                  ),
                              validator: (value) {
                                if ((value ?? '').trim().isEmpty) {
                                  return 'Confirme a senha.';
                                }
                                if (value!.trim() !=
                                    _passwordController.text.trim()) {
                                  return 'As senhas precisam ser iguais.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            VitacarePrimaryButton(
                              onPressed: _submit,
                              label: isLoading ? 'Cadastrando...' : 'Cadastrar',
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Voltar para login'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
