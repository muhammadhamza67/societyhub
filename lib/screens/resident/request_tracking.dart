import 'package:flutter/material.dart';
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
      final data =
          await ApiService.getRequestsForResident(widget.residentId);
      setState(() {
        requests = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to fetch requests")),
      );
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Assigned':
        return Colors.blue;
      case 'In Progress':
        return Colors.purple;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
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
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 14),
                      child: ListTile(
                        leading: Icon(Icons.assignment, color: primaryBlue),
                        title: Text(r['title'] ?? ''),
                        subtitle: Text(r['category'] ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor(r['status']),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            r['status'] ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
