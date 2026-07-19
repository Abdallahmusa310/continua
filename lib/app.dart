import 'package:continua/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';

class ContinuaApp extends StatelessWidget {
  const ContinuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'PlusJakartaSans',
      ),
      home: const SplashScreen(),
    );
  }
}
