import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/providers/patient_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_feature_tile.dart';
import 'package:vitacare_flutter/widgets/vitacare_glass_card.dart';
import 'package:vitacare_flutter/widgets/vitacare_page_scaffold.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _alertShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_alertShown) {
      return;
    }

    final int alerts = context.read<PatientProvider>().criticalAlertsCount;
    if (alerts <= 0) {
      return;
    }

    _alertShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final bool openAlerts = await showVitacareConfirmationDialog(
        context,
        title: 'Alerta clinico',
        message:
            'Existem $alerts pacientes com prioridade alta na base demonstrativa. Deseja abrir a tela de Alertas e Status agora?',
        confirmLabel: 'Ver alertas',
        cancelLabel: 'Agora nao',
      );

      if (openAlerts && mounted) {
        Navigator.pushReplacementNamed(context, '/alerts');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final PatientProvider patientProvider = context.watch<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Painel do VitaCare',
      selectedRoute: '/dashboard',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 980;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VitacareGlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bem-vindo, ${authProvider.currentUser?.name ?? 'Profissional'}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: VitacareColors.textStrong,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'O VitaCare organiza o acompanhamento de pacientes cronicos e idosos com dados mockados, alertas e historico acessivel para a equipe.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: VitacareColors.textSoft,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatusChip(
                              label:
                                  '${patientProvider.patients.length} pacientes acompanhados',
                              color: VitacareColors.primary,
                            ),
                            _StatusChip(
                              label:
                                  '${patientProvider.allRecordsSorted.length} registros de saude',
                              color: VitacareColors.accent,
                            ),
                            _StatusChip(
                              label:
                                  '${patientProvider.criticalAlertsCount} alertas prioritarios',
                              color: Colors.red.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildModules(context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAcademicSupport(context)),
                    ],
                  )
                else ...[
                  _buildModules(context),
                  const SizedBox(height: 16),
                  _buildAcademicSupport(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModules(BuildContext context) {
    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Funcionalidades especificas do projeto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: VitacareColors.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Os cinco modulos abaixo atendem ao RF005 e representam o fluxo principal de acompanhamento no VitaCare.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: VitacareColors.textSoft,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 16),
            _ActionButton(
              title: '1. Cadastro de paciente',
              subtitle: 'Registra dados basicos do paciente e do cuidador responsavel.',
              icon: Icons.person_add_alt_1_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/patients/register'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '2. Listagem de pacientes',
              subtitle: 'Exibe a lista principal com status e acesso rapido ao acompanhamento.',
              icon: Icons.list_alt_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/patients/list'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '3. Registro de dados de saude',
              subtitle: 'Salva pressao arterial, glicemia e observacoes clinicas.',
              icon: Icons.monitor_heart_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/records/register'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '4. Historico de registros',
              subtitle: 'Mostra a evolucao dos registros de forma ordenada e filtravel.',
              icon: Icons.timeline_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/records/history'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '5. Alertas e status',
              subtitle: 'Destaca pacientes em prioridade alta para apoio da equipe.',
              icon: Icons.warning_amber_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/alerts'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicSupport(BuildContext context) {
    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contexto do projeto',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: VitacareColors.textStrong,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            const VitacareFeatureTile(
              icon: Icons.elderly_outlined,
              title: 'Publico de cuidado continuo',
              description:
                  'Foco em idosos e pacientes com doencas cronicas que precisam de monitoramento frequente entre consultas.',
            ),
            const SizedBox(height: 10),
            const VitacareFeatureTile(
              icon: Icons.groups_2_outlined,
              title: 'Coordenacao entre equipe e cuidadores',
              description:
                  'A proposta centraliza informacoes para profissionais, familiares e cuidadores com historico auditavel.',
            ),
            const SizedBox(height: 10),
            const VitacareFeatureTile(
              icon: Icons.data_usage_rounded,
              title: 'Dados mockados para demonstracao',
              description:
                  'Nesta etapa academica, autenticacao, pacientes e registros sao simulados para demonstrar interface, navegacao e listagem.',
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Tela Sobre',
              subtitle: 'Consulte o resumo academico, objetivos e escopo atual do VitaCare.',
              icon: Icons.info_outline_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: VitacareColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: VitacareColors.accent.withValues(alpha: 0.13),
                ),
                child: Icon(icon, color: VitacareColors.primaryStrong),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: VitacareColors.textStrong,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: VitacareColors.textSoft,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: VitacareColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
