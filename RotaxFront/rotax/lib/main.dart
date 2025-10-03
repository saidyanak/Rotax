import 'package:flutter/material.dart';
import 'package:rotax/features/splash/splash_screen.dart';

void main() {
  runApp(const RotaxApp());
}
class RotaxApp extends StatelessWidget {
  const RotaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Rotax",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}