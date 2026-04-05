import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';

class VitacareBackground extends StatelessWidget {
  const VitacareBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            VitacareColors.background,
            Color(0xFFF3FBFC),
            Color(0xFFE8F6FB),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: const [
          _BackgroundOrb(
            size: 320,
            top: -100,
            right: -80,
            colors: [Color(0x4227B1B6), Color(0x0027B1B6)],
          ),
          _BackgroundOrb(
            size: 300,
            bottom: -120,
            left: -70,
            colors: [Color(0x26163B6C), Color(0x00163B6C)],
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({
    required this.size,
    required this.colors,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final double size;
  final List<Color> colors;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors),
          ),
        ),
      ),
    );
  }
}
