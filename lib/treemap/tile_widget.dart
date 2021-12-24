import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap/treemap/tile_details.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    Key? key,
    required this.details
  }) : super(key: key);

  final TileDetails details;

  @override
  Widget build(BuildContext context) {
    return Positioned (
      width: details.size?.width,
      height: details.size?.height,
      left: details.offset!.dx,
      top: details.offset!.dy,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: details.borderColor),
          color: details.color,
        ),
        child: Center (
          child: ListTile(
            title: Text(
              details.title,
              textAlign: TextAlign.center,
              style: TextStyle(color: details.textColor)
            ),
            subtitle: Text(
              details.value.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: details.textColor)
            )
          ),
        )
      )
    );
  }
}