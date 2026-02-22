import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  /// 🔴 CHANGE to your PC LAN IP
  /// Example: 192.168.0.10:8000
  static const String backendHost = "192.168.0.10:8000";

  Uri _httpUrl(String path) => Uri.parse("http://$backendHost$path");
  Uri _wsUrl(String path) => Uri.parse("ws://$backendHost$path");

  // ============================================================
  // CONNECT WEBSOCKET
  // ============================================================
  WebSocketChannel connectSocket({
    required String residentId,
    required String requestId,
    required void Function(Map<String, dynamic>) onMessage,
    void Function(Object error)? onError,
    void Function()? onDone,
  }) {
    final channel =
        WebSocketChannel.connect(_wsUrl("/ws/chat/$residentId/$requestId"));

    channel.stream.listen(
      (data) {
        try {
          final msg = jsonDecode(data);
          onMessage(msg);
        } catch (e) {
          print("❌ JSON decode error: $e");
        }
      },
      onError: (error) {
        print("❌ WebSocket error: $error");
        if (onError != null) onError(error);
      },
      onDone: () {
        print("⚠️ WebSocket closed");
        if (onDone != null) onDone();
      },
    );

    return channel;
  }

  // ============================================================
  // FETCH OLD CHAT
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchChatMessages({
    required String residentId,
    required String requestId,
  }) async {
    try {
      final res = await http.get(
        _httpUrl("/chat/$residentId/$requestId"),
      );

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("❌ fetchChatMessages error: $e");
    }
    return [];
  }

  // ============================================================
  // ADMIN RESIDENT LIST
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchAdminChats() async {
    try {
      final res = await http.get(_httpUrl("/admin/chats"));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data);
      }
    } catch (e) {
      print("❌ fetchAdminChats error: $e");
    }
    return [];
  }

  // ============================================================
  // ADMIN CHAT WITH RESIDENT
  // ============================================================
  Future<List<Map<String, dynamic>>> fetchAdminResidentChat({
    required String residentId,
    required String requestId,
  }) async {
    return fetchChatMessages(
      residentId: residentId,
      requestId: requestId,
    );
  }
}