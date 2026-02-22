import 'package:web_socket_channel/web_socket_channel.dart';

class ChatSocket {
  static WebSocketChannel connect(String residentId) {
    return WebSocketChannel.connect(
      Uri.parse("ws://localhost:8000/ws/chat/$residentId"),
    );
  }
}