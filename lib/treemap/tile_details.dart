import 'dart:ui';

import 'package:flutter/material.dart';

class TileDetails {
  TileDetails({
    required this.weight,
    required this.value,
    required this.title,
    required this.textColor,
    required this.borderColor,
  });

  final double weight;
  final double value;
  final String title;
  final Color textColor;
  final Color borderColor;

  Color? color;
  double? area;
  Offset? offset;
  Size? size;
}
