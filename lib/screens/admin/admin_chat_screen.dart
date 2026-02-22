import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:societyhub/services/chat_service.dart';

class AdminChatScreen extends StatefulWidget {
  final String residentId;
  final String requestId;

  const AdminChatScreen({
    super.key,
    required this.residentId,
    required this.requestId,
  });

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  WebSocketChannel? channel;
  List<Map<String, dynamic>> messages = [];
  bool isConnected = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOldMessages();
    _connectSocket();
  }

  /// ==============================
  /// LOAD OLD CHAT
  /// ==============================
  Future<void> _loadOldMessages() async {
    try {
      final msgs = await _chatService.fetchAdminResidentChat(
        residentId: widget.residentId,
        requestId: widget.requestId,
      );

      setState(() {
        messages = msgs;
        isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Load messages error: $e");
    }
  }

  /// ==============================
  /// CONNECT SOCKET
  /// ==============================
  void _connectSocket() {
    try {
      channel = _chatService.connectSocket(
        residentId: widget.residentId,
        requestId: widget.requestId,

        onMessage: (msg) {
          setState(() => messages.add(msg));
          _scrollToBottom();
        },

        onError: (error) {
          debugPrint("❌ WebSocket error: $error");
          isConnected = false;
          _retryConnect();
        },

        onDone: () {
          debugPrint("⚠️ WebSocket closed");
          isConnected = false;
          _retryConnect();
        },
      );

      isConnected = true;
    } catch (e) {
      debugPrint("❌ Connection failed: $e");
      _retryConnect();
    }
  }

  void _retryConnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isConnected) _connectSocket();
    });
  }

  /// ==============================
  /// SEND MESSAGE
  /// ==============================
  void _sendMessage() {
    if (_controller.text.trim().isEmpty || !isConnected) return;

    final msg = {
      "resident_id": widget.residentId,
      "request_id": widget.requestId,
      "sender": "admin",
      "message": _controller.text.trim(),
      "timestamp": DateTime.now().toIso8601String(),
    };

    channel?.sink.add(jsonEncode(msg));
    setState(() => messages.add(msg));

    _controller.clear();
    _scrollToBottom();
  }

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

  /// ==============================
  /// CHAT BUBBLE
  /// ==============================
  Widget bubble(Map msg) {
    final isAdmin = msg["sender"] == "admin";

    DateTime? time;
    try {
      if (msg["timestamp"] != null) {
        time = DateTime.parse(msg["timestamp"]).toLocal();
      }
    } catch (_) {}

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isAdmin ? const Color(0xFFDCF8C6) : Colors.grey[300],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg["message"] ?? ""),
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

  /// ==============================
  /// UI
  /// ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Resident ${widget.residentId}"),
        backgroundColor: const Color(0xFF2E7D32), // your admin theme
      ),
      body: Column(
        children: [
          if (isLoading) const LinearProgressIndicator(),

          Expanded(
            child: messages.isEmpty && !isLoading
                ? const Center(child: Text("No messages yet"))
                : ListView.builder(
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