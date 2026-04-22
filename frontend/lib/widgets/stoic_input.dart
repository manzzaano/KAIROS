import 'package:flutter/material.dart';

import '../utils/theme.dart';

class StoicInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;

  const StoicInput({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: KairosTheme.mono(size: 10, color: KairosColors.neutral400, letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          cursorColor: KairosColors.neutral50,
          cursorWidth: 1,
          style: KairosTheme.serif(size: 16, color: KairosColors.neutral50),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: KairosColors.neutral700.withOpacity(0.25),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            hintStyle: KairosTheme.serif(size: 16, color: KairosColors.neutral400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: KairosColors.neutral50, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
