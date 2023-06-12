import 'dart:convert';
import 'dart:io';
// import 'package:badges/badges.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _universController = TextEditingController();
  List<dynamic> _apiResponse = [];

  @override
  void initState() {
    super.initState();
    loadInfos();
  }

  Future<void> loadInfos() async {
    final infos = await API.getInfos();

    setState(() {
      _apiResponse = infos;
      // ajouter le nombre de personnages dans l'univers

      print(_apiResponse);
    });
    for (var n in _apiResponse) {
      getCharactersLength(n['id']);
      // _apiResponse[n].add(n['characters'].length);
    }

    print(_apiResponse);
  }

  Future<void> loadUniverses() async {
    await API.createUniverse(_universController.text);
    loadInfos();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create universe'),
          content: TextField(
            controller: _universController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'univers',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                loadUniverses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> getCharactersLength(int universeId) async {
    final characters = await API.getCharacters(universeId);

    setState(() {
      _apiResponse[universeId - 1]['characters'] = characters.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        // automaticallyImplyLeading: false,
        // leading: null,
        // bouton de déconnexion
        actions: null,
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            Builder(
              builder: (BuildContext context) {
                return const UserAccountsDrawerHeader(
                  accountName: Text(
                    'Robin Poiron',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    'test@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  currentAccountPicture: FlutterLogo(),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text('Page 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.train,
              ),
              title: const Text('Page 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const AboutListTile(
              // <-- SEE HERE
              icon: Icon(
                Icons.info,
              ),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'My Cool App',
              applicationVersion: '1.0.25',
              applicationLegalese: '© 2019 Company',
              aboutBoxChildren: [
                ///Content goes here...
              ],
              child: Text('About app'),
            ),
            const Divider(
              thickness: 1,
              // color: Color.fromARGB(255, 130, 130, 132),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Déconnexion'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.grey[200],
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
                      '/universes',
                      arguments: {
                        'id': n['id'],
                      }, // Passer l'ID de la conversation comme argument
                    );
                  },
                  child: Badge(
                    label: Text(n['characters']?.toString() ?? '0'),
                    child: ListTile(
                      leading: const FlutterLogo(),
                      title: Row(
                        children: [
                          Text(n['name']),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Ajouter un Univers'),
        onPressed: () {
          _showMyDialog();
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
      ),
    );
  }
}
