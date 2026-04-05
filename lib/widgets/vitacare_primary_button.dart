import 'package:flutter/material.dart';

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
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _isPressed ? 0.99 : 1,
      child: SizedBox(
        width: double.infinity,
        child: Listener(
          onPointerDown: (_) => setState(() => _isPressed = true),
          onPointerUp: (_) => setState(() => _isPressed = false),
          onPointerCancel: (_) => setState(() => _isPressed = false),
          child: FilledButton(
            onPressed: widget.onPressed,
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
