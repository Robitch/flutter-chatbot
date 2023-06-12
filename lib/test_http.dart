import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiPage extends StatefulWidget {
  const ApiPage({super.key});

  @override
  _ApiPageState createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> {
  String _apiResponse = '';

  Future<void> fetchData() async {
    try {
      // Effectue l'appel API
      var response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'));

      // Vérifie que la requête a réussi
      if (response.statusCode == 200) {
        // Récupère les données de la réponse
        var data = json.decode(response.body);
        // Stocke les informations que tu souhaites afficher
        String title = data['title'];
        String body = data['body'];

        setState(() {
          // Met à jour la variable d'état pour afficher les informations de la réponse
          _apiResponse = 'Title: $title\n\nBody: $body';
        });
      } else {
        setState(() {
          // En cas d'erreur de requête, affiche un message d'erreur
          _apiResponse = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        // En cas d'erreur lors de l'appel API, affiche un message d'erreur
        _apiResponse = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                fetchData();
              },
              child: const Text('Fetch Data from API'),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Response from API: $_apiResponse',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
