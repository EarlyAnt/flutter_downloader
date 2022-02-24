import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

import 'splash_screen_page.dart';

void main() {
  Fimber.plantTree(DebugTree());
  runApp(const MyApp());
  Fimber.i("----App Run----");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreenPage(),
    );
  }
}
