import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class AdminManageWorkersScreen extends StatefulWidget {
  const AdminManageWorkersScreen({super.key});

  @override
  State<AdminManageWorkersScreen> createState() =>
      _AdminManageWorkersScreenState();
}

class _AdminManageWorkersScreenState extends State<AdminManageWorkersScreen> {
  bool isLoading = true;
  List<dynamic> workers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    setState(() => isLoading = true);
    final data = await ApiService.getAllWorkers();
    setState(() {
      workers = data;
      isLoading = false;
    });
  }

  Future<void> approveWorker(String workerId) async {
    final success = await ApiService.approveWorker(workerId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker approved")),
      );
      fetchWorkers();
    }
  }

  Future<void> rejectWorker(String workerId) async {
    final success = await ApiService.rejectWorker(workerId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Worker rejected")),
      );
      fetchWorkers();
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Workers"),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : workers.isEmpty
              ? const Center(child: Text("No workers found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workers.length,
                  itemBuilder: (context, index) {
                    final worker = workers[index];
                    final status = worker['status'] ?? 'Pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== NAME =====
                            Text(
                              worker['name'] ?? 'No Name',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // ===== PHONE =====
                            Text("📞 ${worker['phone'] ?? '-'}"),

                            // ===== ADDRESS =====
                            Text(
                              "📍 ${worker['gully'] ?? ''}, ${worker['house_no'] ?? ''}",
                            ),

                            const SizedBox(height: 6),

                            // ===== SKILLS =====
                            if (worker['skills'] != null)
                              Text(
                                "🛠 Skills: ${worker['skills'].join(', ')}",
                              ),

                            const SizedBox(height: 10),

                            // ===== STATUS =====
                            Row(
                              children: [
                                const Text(
                                  "Status: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  status,
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ===== ACTION BUTTONS =====
                            if (status == 'Pending')
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                      onPressed: () =>
                                          approveWorker(worker['_id']),
                                      child: const Text("Approve"),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          rejectWorker(worker['_id']),
                                      child: const Text("Reject"),
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
}
