import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  static const double _fieldWidth = 300.0;
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final double width;
  final TextAlign textAlign;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.width = _fieldWidth,
    this.textAlign = TextAlign.center,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textAlign: textAlign,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }
}
