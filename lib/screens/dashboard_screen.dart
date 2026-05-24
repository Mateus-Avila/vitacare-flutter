import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/models/health_record.dart';
import 'package:vitacare_flutter/models/patient.dart';
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

  Future<void> _maybeShowCriticalAlert(
    PatientProvider provider,
    List<Patient> patients,
  ) async {
    if (_alertShown) {
      return;
    }

    final alerts = provider.criticalAlertsCountFrom(patients);
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
            'Existem $alerts pacientes com prioridade alta no Firestore para este usuario. Deseja abrir a tela de Alertas e Status agora?',
        confirmLabel: 'Ver alertas',
        cancelLabel: 'Agora nao',
      );

      if (openAlerts && mounted) {
        Navigator.pushReplacementNamed(context, VitacareRoutes.alerts);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final PatientProvider patientProvider = context.read<PatientProvider>();

    return VitacarePageScaffold(
      title: 'Painel do VitaCare',
      subtitle:
          'Panorama em tempo real dos dados gravados no Firebase para o usuario logado.',
      selectedRoute: VitacareRoutes.dashboard,
      child: StreamBuilder<List<Patient>>(
        stream: patientProvider.watchPatients(),
        builder: (context, patientSnapshot) {
          if (patientSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (patientSnapshot.hasError) {
            return const Center(
              child: Text('Nao foi possivel carregar os pacientes.'),
            );
          }

          final patients = patientSnapshot.data ?? <Patient>[];
          _maybeShowCriticalAlert(patientProvider, patients);

          return StreamBuilder<List<HealthRecord>>(
            stream: patientProvider.watchHealthRecords(),
            builder: (context, recordSnapshot) {
              final records = recordSnapshot.data ?? <HealthRecord>[];
              return LayoutBuilder(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: VitacareColors.textStrong,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'O VitaCare agora usa Firebase Authentication e Cloud Firestore com dados isolados por usuario.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
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
                                          '${patients.length} pacientes acompanhados',
                                      color: VitacareColors.primary,
                                    ),
                                    _StatusChip(
                                      label:
                                          '${records.length} registros de saude',
                                      color: VitacareColors.accent,
                                    ),
                                    _StatusChip(
                                      label:
                                          '${patientProvider.criticalAlertsCountFrom(patients)} alertas prioritarios',
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
              );
            },
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
              'Funcionalidades principais',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: VitacareColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Os modulos abaixo cobrem autenticacao, Firestore, StreamBuilder, pesquisa e API REST.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: VitacareColors.textSoft,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            _ActionButton(
              title: '1. Cadastro de paciente',
              subtitle: 'Insere documentos na colecao pacientes.',
              icon: Icons.person_add_alt_1_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.patientRegistration,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '2. Listagem de pacientes',
              subtitle: 'StreamBuilder com ListView e edicao em tempo real.',
              icon: Icons.list_alt_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.patientList,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '3. Registro de dados de saude',
              subtitle: 'Insere documentos na colecao registros_saude.',
              icon: Icons.monitor_heart_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.healthRecord,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '4. Historico de registros',
              subtitle: 'Recupera e atualiza registros em tempo real.',
              icon: Icons.timeline_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.recordsHistory,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '5. Alertas e status',
              subtitle: 'Lista pacientes criticos filtrados pelo usuario.',
              icon: Icons.warning_amber_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.alerts,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '6. Acoes e metas',
              subtitle: 'Gerencia atividades_cuidado e metas_cuidado.',
              icon: Icons.task_alt_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.careManagement,
              ),
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: '7. Pesquisa e API',
              subtitle: 'Busca ordenada e consulta ViaCEP.',
              icon: Icons.search_rounded,
              onTap: () => Navigator.pushReplacementNamed(
                context,
                VitacareRoutes.search,
              ),
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
              'Contexto avaliativo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: VitacareColors.textStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            const VitacareFeatureTile(
              icon: Icons.verified_user_outlined,
              title: 'Firebase Authentication',
              description:
                  'Login, cadastro e recuperacao de senha usam o projeto Firebase ja configurado.',
            ),
            const SizedBox(height: 10),
            const VitacareFeatureTile(
              icon: Icons.cloud_done_outlined,
              title: 'Cloud Firestore',
              description:
                  'Pacientes, registros, atividades e metas sao salvos com uid e consultados por usuario.',
            ),
            const SizedBox(height: 10),
            const VitacareFeatureTile(
              icon: Icons.travel_explore_rounded,
              title: 'API REST publica',
              description:
                  'A consulta de CEP usa ViaCEP em uma tela propria com loading, erro e resultado.',
            ),
            const SizedBox(height: 10),
            _ActionButton(
              title: 'Tela Sobre',
              subtitle: 'Resumo academico, objetivos e escopo atual.',
              icon: Icons.info_outline_rounded,
              onTap: () =>
                  Navigator.pushReplacementNamed(context, VitacareRoutes.about),
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
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
