import 'dart:convert';

import 'package:flutter/material.dart';
import 'api.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({Key? key}) : super(key: key);

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _apiResponse = [];
  List<dynamic> _apiMessages = [];
  String characterName = '';
  int characterId = 0;
  int idConversation = 0;
  bool _isConversationEmpty = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      characterId = args['id'];
      characterName = args['name'];
      print('characterId: $characterId');
      print('characterName: $characterName');
      loadConversations(characterId);
    });
  }

  Future<void> loadConversations(int characterId) async {
    final conversations = await API.getConversations(characterId);
    setState(() {
      _apiResponse = conversations;
    });

    print('conversations: $conversations');

    if (conversations.isNotEmpty) {
      idConversation = conversations[0]['id'];
      print('idConversation: $idConversation');
      loadMessages();
    }
  }

  void refreshConversation(int idConversation) async {
    final response = await API.deleteConversations(idConversation);
    setState(() {
      _apiResponse = response;
    });

    print('deleted?: $response');

    loadConversations(characterId);
  }

  Future<void> loadMessages() async {
    final messages = await API.getMessages(idConversation);
    setState(() {
      _apiMessages = messages;
      _isConversationEmpty = messages.isEmpty;
      _isLoading = false;
    });

    print(messages);
  }

  void _sendMessage() {
    String message = _messageController.text;

    setState(() {
      _isLoading = true;
      _apiMessages.add({
        'id': _apiMessages.length + 1,
        'content': message,
        'is_sent_by_human': true,
        'created_at': DateTime.now().toString(),
      });
    });

    API.sendMessage(idConversation, message).then((value) {
      loadMessages();
      setState(() {
        _isLoading = false;
      });
    });

    _messageController.clear();
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(characterName),
        // actions: refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              refreshConversation(idConversation);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isConversationEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Envoyer votre premier message \n à $characterName ici',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                    textWidthBasis: TextWidthBasis.values[1],
                  ),
                  const Icon(Icons.arrow_downward),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _apiMessages.length,
                shrinkWrap: true,
                reverse: true,
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var messages = _apiMessages.reversed.toList()[index];
                  bool isSentByHuman = messages['is_sent_by_human'] ?? false;
                  String content = messages['content'] ?? '';
                  return Container(
                    padding: const EdgeInsets.only(
                        left: 14, right: 14, top: 10, bottom: 10),
                    child: Align(
                      alignment: (!isSentByHuman
                          ? Alignment.topLeft
                          : Alignment.topRight),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: (!isSentByHuman
                              ? Colors.grey.shade200
                              : Colors.blue[200]),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          content,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // loader
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
