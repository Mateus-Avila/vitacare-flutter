import 'package:flutter/material.dart';

class VitacareGlassCard extends StatelessWidget {
  const VitacareGlassCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        child: child,
      ),
    );
  }
}
