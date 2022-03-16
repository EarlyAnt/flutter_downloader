import 'package:fimber_io/fimber_io.dart';
import 'package:flutter/material.dart';

import 'log_file_util.dart';
import 'splash_screen_page.dart';

void main() async {
  runApp(const MyApp());

  var logFileName = await getLogFileName();
  Fimber.plantTree(FimberFileTree(logFileName,
      logFormat:
          "${CustomFormatTree.timeStampToken}: ${CustomFormatTree.messageToken}"));
  Fimber.plantTree(DebugTree());

  Fimber.i("----App Run----");
  Fimber.i("log file path: $logFileName");
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
