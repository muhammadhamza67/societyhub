import 'package:flutter/material.dart';
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

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  /// Load all messages for this resident/request
  Future<void> _loadMessages() async {
    try {
      final msgs = await _chatService.fetchChatMessages(
        residentId: widget.residentId,
        requestId: widget.requestId,
      );
      setState(() {
        messages = msgs;
      });

      // Connect WebSocket to receive real-time admin messages
      _chatService.connect((msg) {
        setState(() {
          messages.add({
            "sender": "admin",
            "message": msg,
            "timestamp": DateTime.now().toIso8601String()
          });
        });
      }, residentId: widget.residentId, requestId: widget.requestId);
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  /// Send a message
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await _chatService.sendMessage(
        residentId: widget.residentId,
        requestId: widget.requestId,
        sender: "resident",
        message: text,
        toId: "admin", // assuming admin ID is handled as "admin"
      );

      setState(() {
        messages.add({
          "sender": "resident",
          "message": text,
          "timestamp": DateTime.now().toIso8601String()
        });
        _controller.clear();
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat with Admin")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isResident = msg["sender"] == "resident";
                return Align(
                  alignment:
                      isResident ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isResident ? Colors.green[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(msg["message"]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: "Type your message..."),
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
