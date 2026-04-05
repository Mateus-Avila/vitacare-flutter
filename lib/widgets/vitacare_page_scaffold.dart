import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';
import 'package:vitacare_flutter/widgets/vitacare_app_drawer.dart';
import 'package:vitacare_flutter/widgets/vitacare_background.dart';

class VitacarePageScaffold extends StatelessWidget {
  const VitacarePageScaffold({
    super.key,
    required this.title,
    required this.selectedRoute,
    required this.child,
    this.actions,
  });

  final String title;
  final String selectedRoute;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        foregroundColor: VitacareColors.primaryStrong,
        actions: actions,
      ),
      drawer: VitacareAppDrawer(selectedRoute: selectedRoute),
      body: Stack(
        children: [
          const VitacareBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
