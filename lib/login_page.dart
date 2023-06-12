import 'package:flutter/material.dart';
import 'api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _apiResponse = '';
  String username = '';

  Future<void> login() async {
    username = _usernameController.text;
    String password = _passwordController.text;

    final apiResponse = await API.login(username, password);

    // si la connexion est réussie, on va sur la page d'accueil, sinon on affiche un message d'erreur avec snackbar
    if (apiResponse['success']) {
      Navigator.pushNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(apiResponse['error']),
        ),
      );
    }

    // setState(() {
    //   Navigator.pushNamed(context, '/home');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false,
        leading: null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Create an account'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/api');
              },
              child: const Text('Go to API Page'),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
