import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class AnnouncementListScreen extends StatefulWidget {
  final String residentId; // 🔹 Add residentId

  const AnnouncementListScreen({super.key, required this.residentId});

  @override
  State<AnnouncementListScreen> createState() =>
      _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  late Future<List<dynamic>> futureAnnouncements;

  @override
  void initState() {
    super.initState();
    futureAnnouncements = ApiService.getAnnouncements();
  }

  Color getPriorityColor(String priority) {
    if (priority == "Emergency") return Colors.red;
    if (priority == "Important") return Colors.orange;
    return Colors.green;
  }

  // 🔹 Handle back navigation same as other resident screens
  Future<bool> _onWillPop() async {
    Navigator.pushNamedAndRemoveUntil(context, '/resident_dashboard',
        (route) => false,
        arguments: widget.residentId);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Announcements"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/resident_dashboard', (route) => false,
                  arguments: widget.residentId);
            },
          ),
        ),
        body: FutureBuilder(
          future: futureAnnouncements,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final announcements = snapshot.data as List;

            if (announcements.isEmpty) {
              return const Center(child: Text("No announcements yet"));
            }

            return ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final item = announcements[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      item["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(item["description"]),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: getPriorityColor(item["priority"]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item["priority"],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}