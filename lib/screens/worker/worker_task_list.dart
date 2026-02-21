import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:societyhub/services/api_service.dart';

class WorkerTaskListScreen extends StatefulWidget {
  const WorkerTaskListScreen({super.key});

  @override
  State<WorkerTaskListScreen> createState() => _WorkerTaskListScreenState();
}

class _WorkerTaskListScreenState extends State<WorkerTaskListScreen> {
  final Color workerColor = const Color(0xFFF9A825);
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  late String workerUid;

  @override
  void initState() {
    super.initState();

    // ✅ Get Firebase UID automatically
    workerUid = FirebaseAuth.instance.currentUser!.uid;
    print("Worker UID = $workerUid");

    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);

    try {
      // ✅ Fetch only tasks assigned to this worker
      final fetchedTasks =
          await ApiService.getTasksForWorker(workerUid);

      final mappedTasks =
          List<Map<String, dynamic>>.from(fetchedTasks.map((t) {
        return {
          "title": t['title'] ?? '',
          "description": t['description'] ?? '',
          "status": t['status'] ?? 'Pending',
          "requestId": t['_id'] ?? '',
          "residentId": t['resident_id'] ?? '',
          "residentName": t['resident_name'] ?? '',
        };
      }));

      setState(() {
        tasks = mappedTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch tasks: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assigned Tasks"),
        backgroundColor: workerColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? const Center(child: Text("No tasks assigned"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task['description'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Resident: ${task['residentName'] ?? '-'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  task['status'] ?? '-',
                                  style: TextStyle(
                                    color: _statusColor(
                                        task['status'] ?? ''),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  static Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.purple;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
