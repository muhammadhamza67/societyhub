import 'package:flutter/material.dart';
import 'package:societyhub/screens/admin/AdminResidentListScreen.dart';
import 'package:societyhub/screens/admin/admin_chat_screen.dart';

import 'package:societyhub/services/api_service.dart';

class AdminManageResidentsScreen extends StatefulWidget {
  const AdminManageResidentsScreen({super.key});

  @override
  State<AdminManageResidentsScreen> createState() =>
      _AdminManageResidentsScreenState();
}

class _AdminManageResidentsScreenState
    extends State<AdminManageResidentsScreen> {
  final Color primaryGreen = const Color(0xFF2E7D32); // Admin theme
  bool isLoading = true;
  List<Map<String, dynamic>> residents = [];

  @override
  void initState() {
    super.initState();
    fetchResidents();
  }

  Future<void> fetchResidents() async {
    try {
      final res = await ApiService.getAllResidents(); // backend GET /admin/residents
      setState(() {
        residents = List<Map<String, dynamic>>.from(res);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch residents: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Residents"),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen.withOpacity(0.8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // ===== Chat System Button =====
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text("Open Chat System"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Open the admin chat list screen (resident list)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminResidentListScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  // ===== Resident List =====
                  Expanded(
                    child: residents.isEmpty
                        ? const Center(child: Text("No residents found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: residents.length,
                            itemBuilder: (context, index) {
                              final resident = residents[index];
                              return GestureDetector(
                                onTap: () {
                                  // Open chat with this resident directly
                                  if (resident['resident_id'] != null &&
                                      resident['request_id'] != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AdminChatScreen(
                                          residentId: resident['resident_id'],
                                          requestId: resident['request_id'],
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 15),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resident['name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'House No: ${resident['house_no'] ?? '-'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Gully: ${resident['gully'] ?? '-'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Phone: ${resident['phone'] ?? '-'}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Text(
                                            "Verified: ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            resident['verified'] == true
                                                ? "Yes"
                                                : "No",
                                            style: TextStyle(
                                                color: resident['verified'] == true
                                                    ? Colors.green
                                                    : Colors.red),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}