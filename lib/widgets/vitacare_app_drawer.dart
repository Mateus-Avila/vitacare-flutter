import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/core/vitacare_routes.dart';
import 'package:vitacare_flutter/core/vitacare_feedback.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_logo.dart';

class VitacareAppDrawer extends StatelessWidget {
  const VitacareAppDrawer({
    super.key,
    required this.selectedRoute,
    this.embedded = false,
  });

  final String selectedRoute;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final Widget content = _VitacareNavigationContent(
      selectedRoute: selectedRoute,
      embedded: embedded,
    );

    if (embedded) {
      return content;
    }

    return Drawer(child: content);
  }
}

class _VitacareNavigationContent extends StatelessWidget {
  const _VitacareNavigationContent({
    required this.selectedRoute,
    required this.embedded,
  });

  final String selectedRoute;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final List<_NavigationDestinationData> destinations =
        const <_NavigationDestinationData>[
          _NavigationDestinationData(
            label: 'Dashboard',
            route: VitacareRoutes.dashboard,
            icon: Icons.dashboard_outlined,
          ),
          _NavigationDestinationData(
            label: 'Cadastro de Paciente',
            route: VitacareRoutes.patientRegistration,
            icon: Icons.person_add_alt_1_outlined,
          ),
          _NavigationDestinationData(
            label: 'Listagem de Pacientes',
            route: VitacareRoutes.patientList,
            icon: Icons.list_alt_rounded,
          ),
          _NavigationDestinationData(
            label: 'Registro de Dados',
            route: VitacareRoutes.healthRecord,
            icon: Icons.monitor_heart_outlined,
          ),
          _NavigationDestinationData(
            label: 'Historico de Registros',
            route: VitacareRoutes.recordsHistory,
            icon: Icons.history_rounded,
          ),
          _NavigationDestinationData(
            label: 'Alertas e Status',
            route: VitacareRoutes.alerts,
            icon: Icons.warning_amber_rounded,
          ),
          _NavigationDestinationData(
            label: 'Acoes e Metas',
            route: VitacareRoutes.careManagement,
            icon: Icons.task_alt_rounded,
          ),
          _NavigationDestinationData(
            label: 'Pesquisa',
            route: VitacareRoutes.search,
            icon: Icons.search_rounded,
          ),
          _NavigationDestinationData(
            label: 'Consulta CEP',
            route: VitacareRoutes.apiCep,
            icon: Icons.travel_explore_rounded,
          ),
          _NavigationDestinationData(
            label: 'Sobre o App',
            route: VitacareRoutes.about,
            icon: Icons.info_outline_rounded,
          ),
        ];

    final int selectedIndex = destinations.indexWhere(
      (destination) => destination.route == selectedRoute,
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          embedded ? 12 : 8,
          16,
          embedded ? 12 : 8,
          12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 16),
              child: VitacareLogo(height: 54),
            ),
            Text(
              'Navegacao principal',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: VitacareColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: NavigationDrawer(
                selectedIndex: selectedIndex < 0 ? null : selectedIndex,
                onDestinationSelected: (index) {
                  final String route = destinations[index].route;
                  if (route == selectedRoute) {
                    if (!embedded) {
                      Navigator.pop(context);
                    }
                    return;
                  }

                  if (!embedded) {
                    Navigator.pop(context);
                  }

                  Navigator.of(context).pushReplacementNamed(route);
                },
                children: [
                  for (final destination in destinations)
                    NavigationDrawerDestination(
                      icon: Icon(destination.icon),
                      label: Text(destination.label),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final bool confirmed = await showVitacareConfirmationDialog(
                  context,
                  title: 'Encerrar sessao',
                  message:
                      'Deseja sair do VitaCare agora? Os dados da demonstracao continuarao disponiveis.',
                  confirmLabel: 'Sair',
                );
                if (!confirmed || !context.mounted) {
                  return;
                }
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (!context.mounted) {
                  return;
                }
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(VitacareRoutes.login, (_) => false);
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationDestinationData {
  const _NavigationDestinationData({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}
