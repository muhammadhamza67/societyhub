import 'package:flutter/material.dart';
import 'package:societyhub/screens/admin/admin_chat_screen.dart';
import 'package:societyhub/services/chat_service.dart';


class AdminResidentListScreen extends StatefulWidget {
  const AdminResidentListScreen({super.key});

  @override
  State<AdminResidentListScreen> createState() =>
      _AdminResidentListScreenState();
}

class _AdminResidentListScreenState extends State<AdminResidentListScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> residents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResidents();
  }

  /// Fetch residents list from backend
  Future<void> _loadResidents() async {
    setState(() => isLoading = true);

    try {
      final data = await _chatService.fetchAdminChats();

      debugPrint("Admin Chats Data → $data"); // 🔍 debug

      setState(() => residents = data);
    } catch (e) {
      debugPrint("Failed to fetch residents: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load resident chats")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Open chat screen safely
  void _openChat(Map res) {
    final residentId = res['resident_id']?.toString();
    final requestId = res['request_id']?.toString();

    if (residentId == null || requestId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid chat data")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminChatScreen(
          residentId: residentId,
          requestId: requestId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Resident Chats"),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadResidents,
              child: residents.isEmpty
                  ? const Center(child: Text("No chats found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: residents.length,
                      itemBuilder: (context, index) {
                        final res = residents[index];

                        final residentName =
                            res['name']?.toString() ?? "Resident";
                        final lastMessage =
                            res['last_message']?.toString() ?? "";
                        final timestamp = res['timestamp'] != null
                            ? res['timestamp'].toString().substring(11, 16)
                            : "";

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[400],
                              child: Text(
                                residentName.length >= 2
                                    ? residentName.substring(0, 2).toUpperCase()
                                    : residentName.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(residentName),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              timestamp,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            onTap: () => _openChat(res),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}