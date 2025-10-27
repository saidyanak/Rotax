import 'package:flutter/material.dart';
import 'package:rotaxx/register/registerPage.dart';
import 'HomePage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

        initialRoute: '/',

      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => Homepage(),
        '/register/registerPage': (context) => registerPage(),
      },

    );
  }
}
