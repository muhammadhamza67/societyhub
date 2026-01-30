import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';
import 'admin_chat_screen.dart';

class AdminChatListScreen extends StatefulWidget {
  const AdminChatListScreen({super.key});

  @override
  State<AdminChatListScreen> createState() => _AdminChatListScreenState();
}

class _AdminChatListScreenState extends State<AdminChatListScreen> {
  List<Map<String, dynamic>> chats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    setState(() => isLoading = true);
    try {
      // Fetch all residents who have sent messages to admin
      final data = await ApiService.getAdminChats(); // Should return List<Map> with residentId & name
      setState(() {
        chats = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint("Failed to load admin chats: $e");
      setState(() {
        chats = [];
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Chats'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text('No chats yet'))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final residentId = chat['resident_id'];
                    final residentName = chat['name'] ?? 'Resident';

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(residentName),
                      subtitle: Text('ID: $residentId'),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminChatScreen(
                              residentId: residentId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
