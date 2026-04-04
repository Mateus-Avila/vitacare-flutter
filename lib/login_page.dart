import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/theme/vitacare_input_decoration.dart';
import 'package:vitacare_flutter/widgets/vitacare_background.dart';
import 'package:vitacare_flutter/widgets/vitacare_feature_tile.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_logo.dart';
import 'package:vitacare_flutter/widgets/vitacare_primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _obscurePassword = true;

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const LoginSuccessPage(),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: VitacareColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 900;
    final contentWidth = isWide ? 980.0 : 520.0;

    return Scaffold(
      body: Stack(
        children: [
          const VitacareBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      40,
                ),
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentWidth),
                        child: VitacareGlassCard(
                          child: isWide
                              ? Row(
                                  children: [
                                    Expanded(child: _buildBrandPanel(theme)),
                                    Expanded(child: _buildFormPanel(theme)),
                                  ],
                                )
                              : _buildFormPanel(theme),
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

  Widget _buildBrandPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 40, 30, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [VitacareColors.primary, VitacareColors.primaryStrong],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBrandContent(
            theme,
            textColor: Colors.white,
            supportColor: Colors.white.withValues(alpha: 0.78),
          ),
          const SizedBox(height: 32),
          const VitacareFeatureTile(
            icon: Icons.favorite_outline_rounded,
            title: 'Rotina segura',
            description: 'Acompanhe idosos e pacientes cronicos com clareza e cuidado continuo.',
            light: true,
          ),
          const SizedBox(height: 14),
          const VitacareFeatureTile(
            icon: Icons.monitor_heart_outlined,
            title: 'Visao centralizada',
            description: 'Sinais, historico e observacoes em uma experiencia simples para a equipe.',
            light: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandContent(
              theme,
              textColor: VitacareColors.textStrong,
              supportColor: VitacareColors.textSoft,
            ),
            const SizedBox(height: 24),
            Text(
              'Entrar',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: VitacareColors.textStrong,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use seu e-mail profissional para acessar a central Vitacare.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: VitacareColors.textSoft,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                label: 'E-mail',
                hint: 'voce@clinica.com',
                icon: Icons.mail_outline_rounded,
              ),
              validator: (value) {
                final email = (value ?? '').trim();
                if (email.isEmpty) {
                  return 'Informe seu e-mail.';
                }
                if (!_emailRegex.hasMatch(email)) {
                  return 'Digite um e-mail valido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: _fieldDecoration(
                label: 'Senha',
                hint: 'Digite sua senha',
                icon: Icons.lock_outline_rounded,
              ).copyWith(
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      key: ValueKey(_obscurePassword),
                      color: VitacareColors.textMuted,
                    ),
                  ),
                ),
              ),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Informe sua senha.';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _showInfoSnackBar('Recuperacao de senha em breve.');
                },
                child: const Text('Esqueceu a senha?'),
              ),
            ),
            const SizedBox(height: 12),
            VitacarePrimaryButton(
              onPressed: _handleLogin,
              label: 'Entrar',
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ainda nao tem conta?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: VitacareColors.textSoft,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _showInfoSnackBar('Cadastro em breve.');
                  },
                  child: const Text('Cadastrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandContent(
    ThemeData theme, {
    required Color textColor,
    required Color supportColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const VitacareLogo(),
        const SizedBox(height: 18),
        Text(
          'Cuidado inteligente e humano para sua operacao.',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
            height: 1.18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'A plataforma para acompanhamento continuo de pacientes cronicos e idosos.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: supportColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return vitacareInputDecoration(label: label, hint: hint, icon: icon);
  }
}

class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitacare'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VitacareColors.accent.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 46,
                  color: VitacareColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao Vitacare!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: VitacareColors.textStrong,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Login validado com sucesso.\nEsta e uma tela placeholder para a apresentacao.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: VitacareColors.textSoft,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
