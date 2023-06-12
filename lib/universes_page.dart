import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

class UniversesPage extends StatefulWidget {
  const UniversesPage({Key? key}) : super(key: key);

  @override
  State<UniversesPage> createState() => _UniversesPageState();
}

class _UniversesPageState extends State<UniversesPage> {
  final TextEditingController _characterController = TextEditingController();
  List _apiResponse = [];
  final storage = const FlutterSecureStorage();
  int universeId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      universeId = args['id'];
      getCharacters(universeId);
    });
  }

  Future<void> getCharacters(int universeId) async {
    final characters = await API.getCharacters(universeId);
    setState(() {
      _apiResponse = characters;
    });
  }

  Future<void> loadCharacters() async {
    await API.createCharacter(universeId, _characterController.text);
    getCharacters(universeId);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create character'),
          content: TextField(
            controller: _characterController,
            decoration: const InputDecoration(
              labelText: 'Nom du Personnage',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                loadCharacters();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer les arguments passés lors de la navigation
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    int universeId = args['id'];

    // Utiliser l'ID de la conversation pour charger les données spécifiques à la conversation

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 218, 139, 211),
      appBar: AppBar(
        title: Text('Univers #$universeId'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // floating button pour ajouter un nouvel univers

        child: ListView(
          children: <Widget>[
            for (var n in _apiResponse.isNotEmpty ? _apiResponse : [])
              Card(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/characters',
                      arguments: {
                        'id': n['id'],
                        'name': n['name'],
                      }, // Passer l'ID de la conversation comme argument
                    );
                  },
                  // child: Badge(
                  //   label: const Text(
                  //     '0',
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  child: ListTile(
                    leading: const FlutterLogo(),
                    title: Text(n['name']),
                    trailing: PopupMenuButton<ListTileTitleAlignment>(
                      onSelected: (ListTileTitleAlignment? value) {
                        setState(() {
                          // titleAlignment = value;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<ListTileTitleAlignment>>[
                        const PopupMenuItem<ListTileTitleAlignment>(
                          value: ListTileTitleAlignment.center,
                          child: Text('Modifier'),
                        ),
                        const PopupMenuItem<ListTileTitleAlignment>(
                          value: ListTileTitleAlignment.center,
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Ajouter un Personnage'),
        onPressed: () {
          _showMyDialog();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
      ),
    );
  }
}
