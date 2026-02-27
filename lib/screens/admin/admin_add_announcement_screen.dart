import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';


class AdminAddAnnouncementScreen extends StatefulWidget {
  final String adminId;
  const AdminAddAnnouncementScreen({super.key, required this.adminId});

  @override
  State<AdminAddAnnouncementScreen> createState() =>
      _AdminAddAnnouncementScreenState();
}

class _AdminAddAnnouncementScreenState
    extends State<AdminAddAnnouncementScreen> {

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  String priority = "Normal";
  bool isLoading = false;

  void postAnnouncement() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    bool success = await ApiService.addAnnouncement(
      titleController.text.trim(),
      descriptionController.text.trim(),
      priority,
      widget.adminId,
    );

    setState(() => isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to post announcement")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Announcement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              value: priority,
              items: ["Normal", "Important", "Emergency"]
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => priority = value.toString());
              },
              decoration: const InputDecoration(labelText: "Priority"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : postAnnouncement,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post Announcement"),
            )
          ],
        ),
      ),
    );
  }
}