import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_validators.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_background.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_logo.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecovery() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      showVitacareSnackBar(context, 'Informe um e-mail valido.', isError: true);
      return;
    }

    final String email = _emailController.text.trim();
    final result = context.read<AuthProvider>().requestPasswordRecovery(email);

    if (!result.isSuccess) {
      showVitacareSnackBar(context, result.message, isError: true);
      return;
    }

    await showVitacareInfoDialog(
      context,
      title: 'Recuperacao solicitada',
      message:
          '${result.message}\n\nNesta etapa academica, o envio e apenas ilustrativo.',
    );

    if (!mounted) {
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const VitacareBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 510),
                  child: VitacareGlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const VitacareLogo(height: 86),
                            const SizedBox(height: 16),
                            Text(
                              'Esqueceu a senha?',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: VitacareColors.textStrong,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Informe seu e-mail para simular a recuperacao de senha exigida pelo RF005.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: VitacareColors.textSoft,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: vitacareInputDecoration(
                                label: 'E-mail cadastrado',
                                hint: 'voce@instituicao.com',
                                icon: Icons.mail_outline_rounded,
                              ),
                              validator: (value) {
                                final String email = (value ?? '').trim();
                                if (email.isEmpty) {
                                  return 'Informe seu e-mail.';
                                }
                                if (!VitacareValidators.isValidEmail(email)) {
                                  return 'Digite um e-mail valido.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            VitacarePrimaryButton(
                              onPressed: _sendRecovery,
                              label: 'Enviar recuperacao',
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
