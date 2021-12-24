import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_heatmap/treemap/tile_details.dart';
import 'package:flutter_heatmap/treemap/tile_widget.dart';
import 'package:flutter_heatmap/treemap/utils.dart';

const defaultThresholdsColors = [
  { 'threshold': 3.00, 'color': Color(0xFF30CC5A) },
  { 'threshold': 2.00, 'color': Color(0xFF2F9E4F) },
  { 'threshold': 1.00, 'color': Color(0xFF31894E) },
  { 'threshold': 0.00, 'color': Color(0xFF414554) },
  { 'threshold': -1.00, 'color': Color(0xFF8B444E) },
  { 'threshold': -2.00, 'color': Color(0xFFBF4045) },
  { 'threshold': -3.00, 'color': Color(0xFFF63538) }
];

const defaultTextColor = Colors.white;
const defaultBorderColor = Colors.black;

class Treemap extends StatefulWidget {
  const Treemap({Key? key,
    required this.data,
    this.customSize,
    this.thresholdsColors = defaultThresholdsColors,
    this.textColor = defaultTextColor,
    this.borderColor = defaultBorderColor
  }) : super(key: key);

  final List data;

  final List thresholdsColors;
  final Color textColor;
  final Color borderColor;

  final Size? customSize;

  @override
  State<Treemap> createState() => TreemapState();
}

class TreemapState extends State<Treemap> {
  late Size calculatedSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        calculatedSize = widget.customSize ?? Size(constraints.maxWidth, constraints.maxHeight);

        if (calculatedSize.width > constraints.maxWidth) {
          calculatedSize = Size(constraints.maxWidth, calculatedSize.height);
        }

        if (calculatedSize.height > constraints.maxHeight) {
          calculatedSize = Size(calculatedSize.width, constraints.maxHeight);
        }

        return SizedBox(
          width: calculatedSize.width,
          height: calculatedSize.height,
          child: Stack(
            children: getTiles()
          )
        );
      }
    );
  }

  List<Widget> getTiles() {
    List<TileDetails> tiles = <TileDetails>[];
    var aggregatedWeight = 0.0;

    for (int i = 0; i < widget.data.length; i++) {
      TileDetails tile = TileDetails(
        weight: widget.data[i]['weight'],
        value: widget.data[i]['value'],
        title: widget.data[i]['title'],
        textColor: widget.textColor,
        borderColor: widget.borderColor
      );

      tiles.add(tile);

      aggregatedWeight += widget.data[i]['weight'];
    }

    return buildTiles(tiles, aggregatedWeight, calculatedSize, widget.thresholdsColors);
  }
}

List<Widget> buildTiles(List<TileDetails> source, double aggregatedWeight, Size size, List thresholdsColors,
    {
      Offset offset = Offset.zero,
      int start = 0,
      int? end
    }) {

  final Size widgetSize = size;
  double groupArea = 0;
  double referenceArea;
  double? prevAspectRatio;
  double? groupInitialTileArea;
  final List<TileDetails> tiles = source;

  // Sorting the tiles in descending order.
  tiles.sort((src, target) => target.weight.compareTo(src.weight));

  end ??= tiles.length;

  final List<Widget> children = <Widget>[];
  for (int i = start; i < end; i++) {
    final TileDetails tile = tiles[i];
    // Area of rectangle = length * width.
    // Divide the tile weight with aggregatedWeight to get the area factor.
    // Multiply it with rectangular area to get the actual area of a tile.
    tile.area = widgetSize.height * widgetSize.width * (tile.weight / aggregatedWeight);

    groupInitialTileArea ??= tile.area;
    // Group start tile height or width based on the shortest side.
    //height or width of group
    final double area = (groupArea + tile.area!) / size.shortestSide;

    // width or height of group
    referenceArea = groupInitialTileArea! / area;

    final double currentAspectRatio = getAspectRatio(referenceArea, area);

    if (prevAspectRatio == null || currentAspectRatio < prevAspectRatio) {
      prevAspectRatio = currentAspectRatio;
      groupArea += tile.area!;
    } else {
      // Aligning the tiles vertically.
      if (size.width > size.height) {
        children.addAll(
          getTileWidgets(tiles, Size(groupArea / size.height, size.height),
            offset, start, i, thresholdsColors,
            axis: Axis.vertical),
        );

        offset += Offset(groupArea / size.height, 0);
        size = Size(max(0, size.width) - groupArea / size.height, size.height);
      }
      // Aligning the tiles horizontally.
      else {
        children.addAll(getTileWidgets(tiles,
          Size(size.width, groupArea / size.width), offset, start, i, thresholdsColors,
          axis: Axis.horizontal));
        offset += Offset(0, groupArea / size.width);
        size = Size(size.width, max(0, size.height) - groupArea / size.width);
      }

      start = i;

      groupInitialTileArea = groupArea = tile.area!;
      referenceArea = tile.area! / (groupInitialTileArea / size.shortestSide);
      prevAspectRatio = getAspectRatio(referenceArea, tile.area! / size.shortestSide);
    }
  }

  // Calculating the size and offset of the last tile or last group area in
  // the given source.
  if (size.width > size.height) {
    children.addAll(
      getTileWidgets(tiles, Size(groupArea / size.height, size.height),
        offset, start, end, thresholdsColors,
        axis: Axis.vertical),
    );
  } else {
    children.addAll(
      getTileWidgets(tiles, Size(groupArea / size.height, size.height),
        offset, start, end, thresholdsColors,
        axis: Axis.horizontal),
    );
  }

  return children;
}

List<Widget> getTileWidgets(
    List<TileDetails> source, Size size, Offset offset, int start, int end, List thresholdsColors,
    {Axis? axis}) {
  final List<TileWidget> tiles = <TileWidget>[];

  for (int i = start; i < end; i++) {
    final TileDetails tileDetails = source[i];

    if (axis == Axis.vertical) {
      tileDetails
        ..size = Size(size.width, tileDetails.area! / size.width)
        ..offset = offset;
      offset += Offset(0, tileDetails.size!.height);
    } else {
      tileDetails
        ..size = Size(tileDetails.area! / size.height, size.height)
        ..offset = offset;
      offset += Offset(tileDetails.size!.width, 0);
    }

    for (int j = 0; j <= thresholdsColors.length; j++) {
      double min = j == thresholdsColors.length ? double.negativeInfinity : thresholdsColors[j]['threshold'];
      double max = j == 0 ? double.infinity : thresholdsColors[j - 1]['threshold'];

      if (between(tileDetails.value, min, max)) {
        tileDetails.color = j == thresholdsColors.length ? thresholdsColors[j - 1]['color'] : thresholdsColors[j]['color'];
      }
    }

    tiles.add(TileWidget(
      details: tileDetails
    ));
  }

  return tiles;
}
