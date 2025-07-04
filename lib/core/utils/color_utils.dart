import 'package:flutter/material.dart';

Color getCategoryColor(int systolic, int diastolic) {
  if (systolic >= 160 || diastolic >= 100) {
    return Colors.red;
  } else if (systolic >= 140 || diastolic >= 90) {
    return Colors.orange;
  } else if (systolic >= 130 || diastolic >= 85) {
    return Colors.amber;
  } else {
    return Colors.green;
  }
}
