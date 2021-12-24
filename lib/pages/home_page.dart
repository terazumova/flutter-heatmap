import 'package:flutter/material.dart';
import 'package:flutter_heatmap/treemap/treemap.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List thresholdsColors = [
    { 'threshold': 3.00, 'color': const Color(0xFF30CC5A) },
    { 'threshold': 2.00, 'color': const Color(0xFF2F9E4F) },
    { 'threshold': 1.00, 'color': const Color(0xFF31894E) },
    { 'threshold': 0.00, 'color': const Color(0xFF414554) },
    { 'threshold': -1.00, 'color': const Color(0xFF8B444E) },
    { 'threshold': -2.00, 'color': const Color(0xFFBF4045) },
    { 'threshold': -3.00, 'color': const Color(0xFFF63538) }
  ];

  final treemapData = [
    { 'title': 'MSFT', 'weight': 2, 'value': 2 },
    { 'title': 'GOOGL', 'weight': 1, 'value': -2.1 },
    { 'title': 'NVDA', 'weight': 1, 'value': 0.6 },
    { 'title': 'FB', 'weight': 1.5, 'value': -0.6 },
    { 'title': 'PG', 'weight': 0.5, 'value': -1.4 }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Treemap page")),
      body: Center (
        child: Center(
          child: Expanded (
            child: Treemap(
              data: treemapData,
              customSize: const Size(600, 600),
              thresholdsColors: thresholdsColors,
              textColor: Colors.white,
              borderColor: Colors.white
            )
          )
        )
      )
    );
  }
}
