import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class WorkerDashboardScreen extends StatefulWidget {
  final String workerId; // 🔹 Added workerId parameter

  const WorkerDashboardScreen({super.key, required this.workerId});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final Color workerColor = const Color(0xFFF9A825); // Amber / Worker theme

  bool isLoading = true;
  List<Map<String, dynamic>> tasks = [];

  int totalTasks = 0;
  int pendingTasks = 0;
  int inProgressTasks = 0;
  int completedTasks = 0;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      // 🔹 Use dynamic workerId
      final fetchedTasks = await ApiService.getWorkerTasks(widget.workerId);
      final mappedTasks = List<Map<String, dynamic>>.from(fetchedTasks);

      setState(() {
        tasks = mappedTasks;
        totalTasks = tasks.length;
        pendingTasks = tasks.where((t) => t['status'] == 'Pending').length;
        inProgressTasks =
            tasks.where((t) => t['status'] == 'In Progress').length;
        completedTasks =
            tasks.where((t) => t['status'] == 'Completed').length;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch tasks")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [workerColor.withOpacity(0.85), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== Header =====
                      const Text(
                        'Welcome Worker 👋',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Check your assigned tasks and progress',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ===== Summary Cards =====
                      Row(
                        children: [
                          _summaryCard(
                            title: 'Total Tasks',
                            value: totalTasks.toString(),
                            icon: Icons.assignment,
                            color: workerColor,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            title: 'Pending',
                            value: pendingTasks.toString(),
                            icon: Icons.pending_actions,
                            color: workerColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryCard(
                            title: 'In Progress',
                            value: inProgressTasks.toString(),
                            icon: Icons.work_outline,
                            color: workerColor,
                          ),
                          const SizedBox(width: 12),
                          _summaryCard(
                            title: 'Completed',
                            value: completedTasks.toString(),
                            icon: Icons.check_circle_outline,
                            color: workerColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ===== Action Button =====
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: workerColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            // 🔹 Pass workerId to task list screen
                            Navigator.pushNamed(
                              context,
                              '/worker_task_list',
                              arguments: widget.workerId,
                            );
                          },
                          child: const Text(
                            'View Assigned Tasks',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // ===== Reusable Summary Card =====
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
