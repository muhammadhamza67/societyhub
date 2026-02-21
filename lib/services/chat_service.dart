import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  final String baseUrl = "http://127.0.0.1:8000"; // Update if needed
  WebSocketChannel? _channel;

  /// Connect to WebSocket for real-time messages
  void connect(void Function(String message) onMessage,
      {required String residentId, required String requestId}) {
    final wsUrl =
        "ws://127.0.0.1:8000/ws/chat?resident_id=$residentId&request_id=$requestId";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel?.stream.listen((event) {
      final data = json.decode(event);
      if (data['message'] != null) {
        onMessage(data['message']);
      }
    }, onDone: () {
      print("WebSocket closed");
    }, onError: (error) {
      print("WebSocket error: $error");
    });
  }

  /// Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  /// Send a message via REST API
  Future<void> sendMessage({
    required String residentId,
    required String requestId,
    required String sender, // 'admin' or 'resident'
    required String message,
    required String toId, // recipient id
  }) async {
    final url = Uri.parse("$baseUrl/chat/send");
    final body = {
      "resident_id": residentId,
      "request_id": requestId,
      "sender": sender,
      "message": message,
      "to_id": toId,
    };

    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body));

    if (response.statusCode != 200) {
      throw Exception("Failed to send message: ${response.body}");
    }
  }

  /// Fetch all chats for admin
  Future<List<Map<String, dynamic>>> fetchAdminChats() async {
    final url = Uri.parse("$baseUrl/admin/chats");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch admin chats: ${response.body}");
    }
  }

  /// Fetch chat messages for a specific resident and request
  Future<List<Map<String, dynamic>>> fetchChatMessages({
    required String residentId,
    required String requestId,
  }) async {
    final url = Uri.parse("$baseUrl/chat/$residentId/$requestId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to fetch chat messages: ${response.body}");
    }
  }
}
