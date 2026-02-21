import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class ManageRequestTaskScreen extends StatefulWidget {
  const ManageRequestTaskScreen({super.key});

  @override
  State<ManageRequestTaskScreen> createState() =>
      _ManageRequestTaskScreenState();
}

class _ManageRequestTaskScreenState extends State<ManageRequestTaskScreen> {
  final Color primaryGreen = const Color(0xFF2E7D32);

  String? selectedWorkerId; // ✅ Use worker ID instead of Map

  List<Map<String, dynamic>> userRequests = [];
  List<Map<String, dynamic>> manageTasks = [];
  List<Map<String, dynamic>> allWorkers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      final requests = await ApiService.getAllRequests();
      final tasks = await ApiService.getAllTasks();
      final workers = await ApiService.getAllWorkers();

      setState(() {
        userRequests = List<Map<String, dynamic>>.from(requests);
        manageTasks = List<Map<String, dynamic>>.from(tasks);
        allWorkers = List<Map<String, dynamic>>.from(workers);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load requests/tasks/workers")),
      );
    }
  }

  Future<void> assignTask(String requestId) async {
    if (selectedWorkerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a worker first")),
      );
      return;
    }

    final success = await ApiService.assignTask(
      requestId,
      selectedWorkerId!, // ✅ Pass only worker UID
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task assigned successfully")),
      );
      fetchData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to assign task")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen.withOpacity(0.85), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Manage Requests & Tasks',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'View and manage user requests and worker tasks efficiently.',
                        style: TextStyle(
                            color: Colors.black87, fontSize: 16, height: 1.4),
                      ),
                      const SizedBox(height: 30),

                      // ================= User Requests =================
                      Text(
                        'User Requests',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 12),

                      Column(
                        children: userRequests.map((request) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.assignment,
                                        size: 30, color: primaryGreen),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            request['title'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Status: ${request['status'] ?? ''}',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // ✅ Dropdown to select worker by ID
                                DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Assign Worker",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: allWorkers.map((w) {
                                    return DropdownMenuItem<String>(
                                      value: w["_id"], // only ID
                                      child: Text("${w['name']}"),
                                    );
                                  }).toList(),
                                  value: selectedWorkerId,
                                  onChanged: (value) {
                                    setState(() => selectedWorkerId = value);
                                  },
                                ),
                                const SizedBox(height: 8),

                                if (request['status'] == 'Pending')
                                  ElevatedButton(
                                    onPressed: () =>
                                        assignTask(request['_id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryGreen,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: const Text("Assign"),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 30),

                      // ================= Manage Tasks =================
                      Text(
                        'Manage Tasks',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: manageTasks.map((task) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.work, size: 30, color: primaryGreen),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${task['title'] ?? ''} - ${task['worker_id'] ?? ''}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Status: ${task['status'] ?? ''}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}