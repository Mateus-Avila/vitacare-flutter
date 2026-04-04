import 'package:flutter/material.dart';
import 'package:vitacare_flutter/theme/vitacare_colors.dart';

InputDecoration vitacareInputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(icon, color: VitacareColors.textMuted),
    filled: true,
    fillColor: VitacareColors.inputFill,
    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
  );
}
