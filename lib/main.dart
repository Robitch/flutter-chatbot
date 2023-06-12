import 'package:flutter/material.dart';
import 'login_page.dart';
import 'test_http.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'universes_page.dart';
import 'characters_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Chatbot App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // inputDecorationTheme: InputDecorationTheme(
        //   border: OutlineInputBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   enabledBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(
        //       color: Colors.blue,
        //     ),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   focusedBorder: OutlineInputBorder(
        //     borderSide: const BorderSide(
        //       color: Colors.blue,
        //     ),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        // ),
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/api': (context) => const ApiPage(),
        '/home': (context) => const HomePage(),
        '/universes': (context) => const UniversesPage(),
        '/characters': (context) => const CharactersPage(),
      },
    );
  }
}
