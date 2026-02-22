import 'package:flutter/material.dart';
import 'package:societyhub/screens/resident/RateWorkerScreen.dart';
import 'package:societyhub/screens/resident/resident_chat_screen.dart';
import 'package:societyhub/services/api_service.dart';

class RequestTracking extends StatefulWidget {
  final String residentId;

  const RequestTracking({super.key, required this.residentId});

  @override
  State<RequestTracking> createState() => _RequestTrackingState();
}

class _RequestTrackingState extends State<RequestTracking> {
  final Color primaryBlue = const Color(0xFF1565C0);
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final data = await ApiService.getRequestsForResident(widget.residentId);
      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch requests")),
      );
    }
  }

  // STATUS COLOR
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in progress':
        return Colors.purple;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Requests'),
        backgroundColor: primaryBlue,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No requests found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    final status = (r['status'] ?? 'Pending').toString();
                    final requestId = r['_id'] ?? '';
                    final workerId = r['worker_id'] ?? 'demo_worker';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shadowColor: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TITLE
                            Text(
                              r['title'] ?? 'Untitled Request',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // CATEGORY & PRIORITY
                            Row(
                              children: [
                                Icon(Icons.category,
                                    size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 4),
                                Text(
                                  r['category'] ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.priority_high,
                                    size: 18, color: Colors.grey[700]),
                                const SizedBox(width: 4),
                                Text(
                                  r['priority'] ?? '-',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // STATUS BADGE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 12,
                                    color: statusColor(status),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor(status),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // RATE WORKER BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.star),
                                label: const Text(
                                  "Rate Worker",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RateWorkerScreen(
                                        workerId: workerId,
                                        residentId: widget.residentId,
                                        requestId: requestId,
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
                  },
                ),

      // CHAT BUTTON
      floatingActionButton: requests.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: primaryBlue,
              label: const Text(
                "Chat with Admin",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResidentChatScreen(
                      residentId: widget.residentId,
                      requestId: requests.first['_id'] ?? '',
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}