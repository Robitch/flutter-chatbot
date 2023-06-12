import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  void register() async {
    try {
      String username = _usernameController.text;
      String password = _passwordController.text;
      String email = _emailController.text;
      String firstname = _firstnameController.text;
      String lastname = _lastnameController.text;
      String _apiResponse = '';

      // Effectue la requête POST
      var response = await http.post(
        Uri.https('192.168.93.52:8000', '/api/users'),
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
          'email': email,
          'firstname': firstname,
          'lastname': lastname,
        }),
      );

      // Vérifie que la requête a réussi
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Connexion réussie

        setState(() {
          _apiResponse = 'Register successful!';
        });
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // Connexion échouée
        setState(() {
          _apiResponse = 'Register failed: ${response.statusCode}';
        });
        // Affiche un dialog d'erreur
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Register failed'),
            content: Text('Error: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Children fields: Username, Password, Email, Firstname, Lastname
        // Children buttons: Register, Cancel
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _firstnameController,
              decoration: const InputDecoration(
                labelText: 'Firstname',
              ),
            ),
            TextField(
              controller: _lastnameController,
              decoration: const InputDecoration(
                labelText: 'Lastname',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                register();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
