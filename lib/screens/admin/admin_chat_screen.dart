import 'package:flutter/material.dart';
import 'package:societyhub/services/chat_service.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> chatList = [];
  List<Map<String, dynamic>> messages = [];

  String? selectedResidentId;
  String? selectedRequestId;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  /// Load admin chats
  Future<void> _loadChats() async {
    try {
      final chats = await _chatService.fetchAdminChats();
      setState(() {
        chatList = chats;
      });
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  /// Load messages for selected chat
  Future<void> _loadMessages(String residentId, String requestId) async {
    try {
      final msgs = await _chatService.fetchChatMessages(
        residentId: residentId,
        requestId: requestId,
      );
      setState(() {
        messages = msgs;
        selectedResidentId = residentId;
        selectedRequestId = requestId;
      });

      // Connect WebSocket for real-time messages
      _chatService.connect((msg) {
        setState(() {
          messages.add({
            "sender": "resident",
            "message": msg,
            "timestamp": DateTime.now().toIso8601String()
          });
        });
      }, residentId: residentId, requestId: requestId);
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  /// Send message
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || selectedResidentId == null || selectedRequestId == null) {
      return;
    }

    try {
      await _chatService.sendMessage(
        residentId: selectedResidentId!,
        requestId: selectedRequestId!,
        sender: "admin",
        message: text,
        toId: selectedResidentId!,
      );

      setState(() {
        messages.add({
          "sender": "admin",
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
      appBar: AppBar(title: const Text("Admin Chat")),
      body: Row(
        children: [
          // Chat List
          SizedBox(
            width: 250,
            child: ListView.builder(
              itemCount: chatList.length,
              itemBuilder: (_, index) {
                final chat = chatList[index];
                return ListTile(
                  title: Text(chat["resident_id"]),
                  subtitle: Text(chat["last_message"] ?? ""),
                  onTap: () {
                    _loadMessages(chat["resident_id"], chat["request_id"]);
                  },
                  selected: chat["resident_id"] == selectedResidentId,
                );
              },
            ),
          ),

          // Chat Window
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isAdmin = msg["sender"] == "admin";
                      return Align(
                        alignment:
                            isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isAdmin ? Colors.blue[200] : Colors.grey[300],
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
                              const InputDecoration(hintText: "Type message..."),
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
          ),
        ],
      ),
    );
  }
}
