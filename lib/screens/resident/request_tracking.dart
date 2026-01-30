import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';
import 'resident_chat_screen.dart'; // 👈 Make sure this import exists

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
      final data =
          await ApiService.getRequestsForResident(widget.residentId);
      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch requests")),
      );
    }
  }

  /// STATUS COLOR MAPPING (Professional lifecycle)
  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Assigned':
        return Colors.blue;
      case 'In Progress':
        return Colors.purple;
      case 'Resolved':
        return Colors.green;
      case 'Closed':
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
                    final status = r['status'] ?? 'Pending';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
                          Text(
                            r['title'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// CATEGORY + PRIORITY
                          Text("Category: ${r['category'] ?? '-'}"),
                          Text("Priority: ${r['priority'] ?? '-'}"),

                          const SizedBox(height: 10),

                          /// STATUS BADGE
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  statusColor(status).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      // ================= CHAT BUTTON =================
      floatingActionButton: requests.isEmpty
          ? null
          : FloatingActionButton.extended(
              backgroundColor: primaryBlue,
              label: const Text("Chat with Admin"),
              icon: const Icon(Icons.chat),
              onPressed: () {
                if (requests.isNotEmpty) {
                  final firstRequestId = requests[0]['_id'];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResidentChatScreen(
                        requestId: firstRequestId,
                        residentId: widget.residentId,
                      ),
                    ),
                  );
                }
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
