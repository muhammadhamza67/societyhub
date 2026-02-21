import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:societyhub/services/api_service.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  final Color workerColor = const Color(0xFFF9A825);

  bool isLoading = true;
  List<Map<String, dynamic>> tasks = [];

  late String workerUid;

  int totalTasks = 0;
  int pendingTasks = 0;
  int inProgressTasks = 0;
  int completedTasks = 0;

  @override
  void initState() {
    super.initState();
    workerUid = FirebaseAuth.instance.currentUser!.uid;
    print("Worker UID = $workerUid");
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    try {
      print("Fetching tasks for workerUid: $workerUid");
      final fetchedTasks = await ApiService.getTasksForWorker(workerUid);
      print("Fetched tasks: $fetchedTasks");

      final mappedTasks = List<Map<String, dynamic>>.from(fetchedTasks.map((t) {
        return {
          "title": t['title'] ?? '',
          "status": t['status'] ?? 'Pending',
          "requestId": t['_id'],
          "residentId": t['resident_id'] ?? '',
        };
      }));

      setState(() {
        tasks = mappedTasks;
        totalTasks = tasks.length;
        pendingTasks =
            tasks.where((t) => t['status'].toLowerCase() == 'pending').length;
        inProgressTasks = tasks
            .where((t) => t['status'].toLowerCase() == 'in progress')
            .length;
        completedTasks = tasks
            .where((t) =>
                t['status'].toLowerCase() == 'completed' ||
                t['status'].toLowerCase() == 'resolved')
            .length;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch tasks")),
      );
    }
  }

  // 🔹 Navigate back to Role Selection
  Future<bool> _onWillPop() async {
    Navigator.pushNamedAndRemoveUntil(
        context, '/roleSelection', (route) => false); // <-- fixed route
    return false; // prevent default pop
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // intercept Android back button
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: workerColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/roleSelection', (route) => false); // <-- fixed route
            },
          ),
          title: const Text('Worker Dashboard'),
        ),
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
                        const Text(
                          'Welcome Worker 👋',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Check your assigned tasks and progress',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            _summaryCard(
                                'Total Tasks', totalTasks.toString(), Icons.assignment),
                            const SizedBox(width: 12),
                            _summaryCard(
                                'Pending', pendingTasks.toString(), Icons.pending_actions),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _summaryCard('In Progress', inProgressTasks.toString(),
                                Icons.work_outline),
                            const SizedBox(width: 12),
                            _summaryCard(
                                'Completed', completedTasks.toString(), Icons.check_circle),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            side: BorderSide(color: workerColor, width: 2),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/worker_task_list');
                          },
                          child: const Text('View Assigned Tasks'),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: tasks.isEmpty
                              ? const Center(
                                  child: Text("No tasks assigned yet"),
                                )
                              : ListView.builder(
                                  itemCount: tasks.length,
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    return ListTile(
                                      title: Text(task['title']),
                                      subtitle: Text(task['status']),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: workerColor),
            const SizedBox(height: 10),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}
