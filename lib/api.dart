import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class API {
  static const String baseUrl = 'http://192.168.93.52:8000/api';
  static const storage = FlutterSecureStorage();

  static Future<String?> getUserId() async {
    return storage.read(key: 'id');
  }

  static Future<dynamic> _apiCall(
    String path,
    String method, {
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      final token = await storage.read(key: 'jwt');
      final uri = Uri.parse('$baseUrl$path');

      http.Response response;
      if (method == 'GET') {
        response = await http.get(
          uri,
          headers: {
            ...headers ?? {},
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
        );
      } else if (method == 'POST') {
        response = await http.post(uri,
            headers: {
              ...headers ??
                  {
                    HttpHeaders.authorizationHeader: 'Bearer $token',
                  },
            },
            body: data);
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: {
            ...headers ??
                {
                  HttpHeaders.authorizationHeader: 'Bearer $token',
                }
          },
        );
      } else {
        return {'error': 'Unsupported HTTP method: $method'};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'API2 call failed: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'API1 call failed: $e'};
    }
  }

  static Future<List<dynamic>> getConversations(int characterId) async {
    final response = await _apiCall(
      '/conversations',
      'GET',
    );

    if (response is List<dynamic>) {
      final conversations = response
          .where((element) => element['character_id'] == characterId)
          .toList();

      // if conversations is an empty array, create a new conversation
      if (conversations.isEmpty) {
        final newConversation = await createConversations(characterId);
        conversations.add(newConversation);
      }

      return conversations;
    } else {
      return ['Get conversations failed: ${response['error'] ?? ''}'];
    }
  }

  static Future<List<dynamic>> getMessages(int conversationId) async {
    final response = await _apiCall(
      '/conversations/$conversationId/messages',
      'GET',
    );

    if (response is List<dynamic>) {
      return response;
    } else {
      return [
        {'content': 'Get messages failed: ${response['error'] ?? ''}'}
      ];
    }
  }

  static Future<List<dynamic>> sendMessage(
      int conversationId, String content) async {
    final bodySend = {
      'content': content,
    };

    // final bodySend = jsonEncode(<String, String>{
    //   'content': content,
    // });

    final response = await _apiCall(
      '/conversations/$conversationId/messages',
      'POST',
      data: bodySend,
    );

    if (response is List<dynamic>) {
      return response;
    } else {
      return [
        {'content': 'Send message failed: ${response['error'] ?? ''}'}
      ];
    }
  }

  static Future<List<dynamic>> getInfos() async {
    final userId = await getUserId();

    final response = await _apiCall(
      '/universes',
      'GET',
    );

    if (response is List<dynamic>) {
      print('userId: $userId');

      return response
          .where((element) => element['creator_id'] == int.parse(userId!))
          .toList();
    } else {
      return ['Get info failed: ${response['error'] ?? ''}'];
    }
  }

  static Future createConversations(int characterId) async {
    final userId = await getUserId();
    print(
        '//////////////////////////////////////////////////////////////////////////////// $userId');

    final bodySend = {
      'character_id': characterId.toString(),
      'user_id': userId.toString(),
    };

    // final bodySend = jsonEncode(<String, String>{
    //  'character_id': characterId.toString(),
    //         'user_id': userId.toString(),
    //       });

    final response = await _apiCall(
      '/conversations',
      'POST',
      data: bodySend,
    );

    print('respone /////////////////////////////// $response');

// si la réponse est une map
    if (response is Map<String, dynamic>) {
      print('resposne /////////////////////////////// $response');

      return response;
    } else {
      return ['Create conversation failed: ${response['error'] ?? ''}'];
    }
  }

  static Future deleteConversations(int idConversation) async {
    final response = await _apiCall(
      '/conversations/$idConversation',
      'DELETE',
    );

    if (response is List<dynamic>) {
      return response;
    } else {
      return ['Delete conversation failed: ${response['error'] ?? ''}'];
    }
  }

  static Future<dynamic> login(String username, String password) async {
    try {
      // final String bodySended = jsonEncode(<String, String>{
      //   'username': username,
      //   'password': password,
      // });

      final bodySended = {
        'username': username,
        'password': password,
      };

      final response = await _apiCall(
        '/login',
        'POST',
        data: bodySended,
        headers: {
          HttpHeaders.authorizationHeader: '',
        },
      );

      print('ouaip/////////////////////////////////');

      if (response is Map<String, dynamic>) {
        final token = response['token'];
        print(
            'test///////////////////////////////////////////////////// $response');
        await storage.write(key: 'jwt', value: token);
        await storage.write(key: 'id', value: response['id'].toString());
        await storage.readAll();
        print(await storage.readAll());
        return {'success': true, 'token': token};
      } else {
        return {
          'success': false,
          'error': 'Login failed: ${response['error'] ?? ''}'
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Login failed: $e'};
    }
  }

  static Future createUniverse(String name) async {
    final bodySend = {
      'name': name,
    };

    // final bodySend = jsonEncode(<String, String>{
    //   'name': name,
    // });

    final response = await _apiCall(
      '/universes',
      'POST',
      data: bodySend,
    );

    print('response: $response');
    if (response is List<dynamic>) {
      return response;
    } else {
      return ['Create universe failed: ${response['error'] ?? ''}'];
    }
  }

  static Future<List<dynamic>> getCharacters(int universeId) async {
    final response = await _apiCall(
      '/universes/$universeId/characters',
      'GET',
    );

    if (response is List<dynamic>) {
      return response;
    } else {
      return ['Get characters failed: ${response['error'] ?? ''}'];
    }
  }

  static Future createCharacter(int universeId, String name) async {
    final bodySend = {
      'name': name,
    };

    // final bodySend = jsonEncode(<String, String>{
    //   'name': name,
    // });

    final response = await _apiCall(
      '/universes/$universeId/characters',
      'POST',
      data: bodySend,
    );

    if (response is List<dynamic>) {
      return response;
    } else {
      return ['Create character failed: ${response['error'] ?? ''}'];
    }
  }
}
