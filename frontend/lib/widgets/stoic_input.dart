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
          style: KairosTheme.mono(size: 10, color: KairosColors.bronze, letterSpacing: 3),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          cursorColor: KairosColors.bronzeLight,
          cursorWidth: 1,
          style: KairosTheme.serif(size: 22, color: KairosColors.bone),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
            border: UnderlineInputBorder(borderSide: BorderSide(color: KairosColors.muted)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: KairosColors.muted)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: KairosColors.bronzeLight, width: 2)),
          ),
        ),
      ],
    );
  }
}
