import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    if (alerts > 0) {
      _alertShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Alerta clinico'),
            content: Text(
              'Existem $alerts pacientes em estado critico. Abra "Alertas e Status" para detalhar.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/alerts');
                },
                child: const Text('Ver alertas'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final PatientProvider patientProvider = context.watch<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Dashboard VitaCare',
      selectedRoute: '/dashboard',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool wide = constraints.maxWidth > 860;
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
                          'Visao rapida de acompanhamento para pacientes cronicos e idosos.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: VitacareColors.textSoft,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatusChip(
                              label: '${patientProvider.patients.length} pacientes cadastrados',
                              color: VitacareColors.primary,
                            ),
                            _StatusChip(
                              label: '${patientProvider.allRecordsSorted.length} registros de saude',
                              color: VitacareColors.accent,
                            ),
                            _StatusChip(
                              label: '${patientProvider.criticalAlertsCount} alertas criticos',
                              color: Colors.red.shade700,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMainActions(context)),
                      const SizedBox(width: 14),
                      Expanded(child: _buildSupportActions(context)),
                    ],
                  )
                else ...[
                  _buildMainActions(context),
                  const SizedBox(height: 14),
                  _buildSupportActions(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fluxo principal',
                style: TextStyle(
                  color: VitacareColors.textStrong,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _ActionButton(
              title: 'Cadastro de Paciente',
              subtitle: 'Adicione um novo paciente com dados basicos.',
              icon: Icons.person_add_alt_1_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/patients/register'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Registro de Dados de Saude',
              subtitle: 'Registre pressao arterial, glicemia e observacoes.',
              icon: Icons.monitor_heart_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/records/register'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Historico de Registros',
              subtitle: 'Consulte a evolucao clinica rapidamente.',
              icon: Icons.timeline_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/records/history'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportActions(BuildContext context) {
    return VitacareGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Operacao e suporte',
                style: TextStyle(
                  color: VitacareColors.textStrong,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const VitacareFeatureTile(
              icon: Icons.checklist_rounded,
              title: 'Listagem organizada',
              description: 'Acompanhe todos os pacientes em uma lista objetiva.',
            ),
            const SizedBox(height: 10),
            const VitacareFeatureTile(
              icon: Icons.notifications_active_outlined,
              title: 'Alertas inteligentes',
              description: 'Destaque automatico para casos que exigem atencao.',
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Abrir Alertas e Status',
              subtitle: 'Revise prioridades de acompanhamento.',
              icon: Icons.warning_amber_rounded,
              onTap: () => Navigator.pushReplacementNamed(context, '/alerts'),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Tela Sobre',
              subtitle: 'Informacoes academicas do projeto.',
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
  const _StatusChip({
    required this.label,
    required this.color,
  });

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
