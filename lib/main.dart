import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const TreemapApp());
}

class TreemapApp extends StatelessWidget {
  const TreemapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heatmap App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: HomePage(),
    );
  }
}
