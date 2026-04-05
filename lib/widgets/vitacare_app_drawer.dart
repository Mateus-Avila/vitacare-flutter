import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacare_flutter/providers/auth_provider.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_logo.dart';

class VitacareAppDrawer extends StatelessWidget {
  const VitacareAppDrawer({
    super.key,
    required this.selectedRoute,
  });

  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: VitacareLogo(height: 58),
            ),
            const Divider(height: 0),
            _DrawerRouteTile(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              route: '/dashboard',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.person_add_alt_1_outlined,
              label: 'Cadastro de Paciente',
              route: '/patients/register',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.list_alt_rounded,
              label: 'Listagem de Pacientes',
              route: '/patients/list',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.monitor_heart_outlined,
              label: 'Registro de Dados',
              route: '/records/register',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.history_rounded,
              label: 'Historico de Registros',
              route: '/records/history',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.warning_amber_rounded,
              label: 'Alertas e Status',
              route: '/alerts',
              selectedRoute: selectedRoute,
            ),
            _DrawerRouteTile(
              icon: Icons.info_outline_rounded,
              label: 'Sobre o App',
              route: '/about',
              selectedRoute: selectedRoute,
            ),
            const Spacer(),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: VitacareColors.primary,
              ),
              title: const Text('Sair'),
              onTap: () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerRouteTile extends StatelessWidget {
  const _DrawerRouteTile({
    required this.icon,
    required this.label,
    required this.route,
    required this.selectedRoute,
  });

  final IconData icon;
  final String label;
  final String route;
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = route == selectedRoute;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? VitacareColors.primaryStrong : VitacareColors.textSoft,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? VitacareColors.primaryStrong : VitacareColors.textStrong,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      selectedTileColor: VitacareColors.accent.withValues(alpha: 0.14),
      onTap: () {
        if (route != selectedRoute) {
          Navigator.of(context).pushReplacementNamed(route);
          return;
        }
        Navigator.pop(context);
      },
    );
  }
}
