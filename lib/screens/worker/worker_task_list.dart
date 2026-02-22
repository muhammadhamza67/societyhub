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
    workerUid = FirebaseAuth.instance.currentUser!.uid;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);

    try {
      final fetchedTasks = await ApiService.getTasksForWorker(workerUid);

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

  Future<void> _markTaskComplete(String taskId, int index) async {
    try {
      final success = await ApiService.markTaskComplete(
        taskId: taskId,
        status: 'Completed',
      );

      if (success) {
        setState(() {
          tasks[index]['status'] = 'Completed';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task marked as completed")),
        );
      } else {
        throw "API failed";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update task: $e")),
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
                    final status = task['status'] ?? 'Pending';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: status == 'Completed'
                          ? Colors.green.shade50
                          : Colors.white,
                      margin: const EdgeInsets.only(bottom: 14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITLE
                            Text(
                              task['title'] ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                decoration: status == 'Completed'
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // DESCRIPTION
                            Text(
                              task['description'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                decoration: status == 'Completed'
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // RESIDENT & STATUS ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Resident: ${task['residentName'] ?? '-'}",
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        _statusColor(status).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: _statusColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // COMPLETE BUTTON
                            if (status != 'Completed' && status != 'closed')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text("Mark as Complete"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: workerColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => _markTaskComplete(
                                      task['requestId'], index),
                                ),
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