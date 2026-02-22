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
  bool isRatingLoading = true;

  List<Map<String, dynamic>> tasks = [];
  late String workerUid;

  int totalTasks = 0;
  int pendingTasks = 0;
  int inProgressTasks = 0;
  int completedTasks = 0;

  // Rating fields
  double averageRating = 0.0;
  int totalReviews = 0;
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    workerUid = FirebaseAuth.instance.currentUser!.uid;
    fetchTasks();
    fetchRatings();
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    try {
      final fetchedTasks = await ApiService.getTasksForWorker(workerUid);
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
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch tasks")),
      );
    }
  }

  // ================= FETCH RATINGS =================
  Future<void> fetchRatings() async {
    setState(() => isRatingLoading = true);
    final data = await ApiService.getWorkerRatings(workerUid);
    if (data != null) {
      setState(() {
        averageRating = (data['average_rating'] ?? 0.0).toDouble();
        totalReviews = data['total_reviews'] ?? 0;
        comments = List<Map<String, dynamic>>.from(data['reviews'] ?? []);
        isRatingLoading = false;
      });
    } else {
      setState(() => isRatingLoading = false);
    }
  }

  // 🔹 Navigate back to Role Selection
  Future<bool> _onWillPop() async {
    Navigator.pushNamedAndRemoveUntil(
        context, '/roleSelection', (route) => false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: workerColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/roleSelection', (route) => false);
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
                        const SizedBox(height: 20),

                        // ================= SUMMARY CARDS =================
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
                        const SizedBox(height: 20),

                        // ================= RATING CARD =================
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: isRatingLoading
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            averageRating.toStringAsFixed(1),
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Row(
                                            children: List.generate(
                                              5,
                                              (index) => Icon(
                                                index < averageRating.round()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "($totalReviews reviews)",
                                            style: TextStyle(
                                                color: Colors.grey.shade700),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      comments.isEmpty
                                          ? const Text("No feedback yet")
                                          : Column(
                                              children: comments
                                                  .map((c) => ListTile(
                                                        leading: Icon(Icons.person,
                                                            color: workerColor),
                                                        title: Text(c['comment'] ?? ''),
                                                        subtitle: Text(
                                                            'By: ${c['resident_name'] ?? 'Resident'}'),
                                                        trailing: Text(
                                                            '${c['rating']} ⭐'),
                                                      ))
                                                  .toList(),
                                            )
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
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