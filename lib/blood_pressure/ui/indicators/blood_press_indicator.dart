import 'package:flutter/material.dart';
import 'package:tonometr/core/utils/color_utils.dart';

class BloodPressureCategoryIndicator extends StatelessWidget {
  final int systolic;
  final int diastolic;
  const BloodPressureCategoryIndicator({
    super.key,
    required this.systolic,
    required this.diastolic,
  });

  @override
  Widget build(BuildContext context) {
    final color = getCategoryColor(systolic, diastolic);
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
