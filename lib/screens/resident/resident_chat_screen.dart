import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:societyhub/services/chat_service.dart';

class ResidentChatScreen extends StatefulWidget {
  final String residentId;
  final String requestId;

  const ResidentChatScreen({
    super.key,
    required this.residentId,
    required this.requestId,
  });

  @override
  State<ResidentChatScreen> createState() => _ResidentChatScreenState();
}

class _ResidentChatScreenState extends State<ResidentChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  WebSocketChannel? channel;
  List<Map<String, dynamic>> messages = [];
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadOldMessages();
    _connectSocket();
  }

  /// Load old messages from backend
  Future<void> _loadOldMessages() async {
    try {
      final msgs = await _chatService.fetchChatMessages(
        residentId: widget.residentId,
        requestId: widget.requestId,
      );
      setState(() => messages = msgs);
      _scrollToBottom();
    } catch (e) {
      debugPrint("Failed to load old messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load old messages")),
      );
    }
  }

  /// Connect WebSocket with auto-reconnect
  void _connectSocket() {
    try {
      channel = _chatService.connectSocket(
        residentId: widget.residentId,
        requestId: widget.requestId,
        onMessage: (msg) {
          setState(() => messages.add(msg));
          _scrollToBottom();
        },
      );
      setState(() => isConnected = true);
    } catch (e) {
      debugPrint("WebSocket connection failed: $e");
      setState(() => isConnected = false);
      _retryConnection();
    }
  }

  /// Retry connecting after a delay
  void _retryConnection() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isConnected) _connectSocket();
    });
  }

  /// Send a message
  void _sendMessage() {
    if (_controller.text.trim().isEmpty || !isConnected || channel == null) return;

    final msg = {
      "resident_id": widget.residentId,
      "request_id": widget.requestId,
      "sender": "resident",
      "message": _controller.text.trim(),
      "timestamp": DateTime.now().toIso8601String(),
    };

    try {
      channel!.sink.add(jsonEncode(msg));
      setState(() => messages.add(msg));
      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint("Failed to send message: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send message")),
      );
    }
  }

  /// Scroll chat to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Chat bubble widget
  Widget bubble(Map msg) {
    final isResident = msg["sender"] == "resident";
    DateTime? time;

    try {
      time = msg["timestamp"] != null
          ? DateTime.parse(msg["timestamp"]).toLocal()
          : null;
    } catch (_) {
      time = null;
    }

    return Align(
      alignment: isResident ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isResident ? const Color(0xFFDCF8C6) : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isResident ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg["message"] ?? '',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (time != null)
              Text(
                "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel?.sink.close();
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Admin"),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) => bubble(messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
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