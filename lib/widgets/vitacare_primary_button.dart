import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';

class VitacarePrimaryButton extends StatefulWidget {
  const VitacarePrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  final VoidCallback onPressed;
  final String label;

  @override
  State<VitacarePrimaryButton> createState() => _VitacarePrimaryButtonState();
}

class _VitacarePrimaryButtonState extends State<VitacarePrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              VitacareColors.primary,
              VitacareColors.primaryStrong,
              VitacareColors.accent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? const Color(0x4538B8BB)
                  : const Color(0x3338B8BB),
              blurRadius: _isHovered ? 24 : 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 58),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
