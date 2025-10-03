import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:rotax/features/authentication/presentation/pages/login_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Image.asset(
      'assets/images/logo_1.png',
      width: 400,
      height: 400
      ),
      nextScreen: const LoginPage(),
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.black,
      duration: 3000,


    );
  }

}