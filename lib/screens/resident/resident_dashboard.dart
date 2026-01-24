import 'package:flutter/material.dart';
import 'service_request_form.dart';
import 'request_tracking.dart';
import 'resident_info_screen.dart'; // ✅ Corrected import
import 'package:societyhub/services/api_service.dart';

class ResidentDashboardScreen extends StatefulWidget {
  final String residentId;
  const ResidentDashboardScreen({super.key, required this.residentId});

  @override
  State<ResidentDashboardScreen> createState() => _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  final Color primaryBlue = const Color(0xFF1565C0);

  int totalRequests = 0;
  int pendingRequests = 0;
  int completedRequests = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.residentId.isNotEmpty) {
      fetchResidentRequests();
    } else {
      isLoading = false;
    }
  }

  Future<void> fetchResidentRequests() async {
    try {
      final res = await ApiService.getRequestsForResident(widget.residentId);
      setState(() {
        totalRequests = res.length;
        pendingRequests = res.where((r) => r['status'] == 'Pending').length;
        completedRequests = res.where((r) => r['status'] == 'Completed').length;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load requests")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resident Dashboard'),
        backgroundColor: primaryBlue,
        actions: [
          // Settings Icon → Popup Menu
          PopupMenuButton<int>(
            icon: const Icon(Icons.settings),
            onSelected: (item) {
              if (item == 0) {
                // Edit Profile → opens resident_info_screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ResidentInfoScreen(residentId: widget.residentId),
                  ),
                );
              } else if (item == 1) {
                // Logout
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue.withOpacity(0.8), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Welcome 👋',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage your service requests',
                        style: TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 25),

                      // SUMMARY CARDS
                      Row(
                        children: [
                          _buildStatCard(
                              'Total', totalRequests, Icons.assignment),
                          const SizedBox(width: 10),
                          _buildStatCard(
                              'Pending', pendingRequests, Icons.pending),
                          const SizedBox(width: 10),
                          _buildStatCard(
                              'Completed', completedRequests, Icons.check_circle),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // SUBMIT REQUEST BUTTON
                      _buildActionButton(
                        text: 'Submit Service Request',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceRequestForm(
                                  residentId: widget.residentId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),

                      // TRACK REQUEST BUTTON
                      _buildActionButton(
                        text: 'Track My Requests',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RequestTracking(
                                  residentId: widget.residentId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // ==========================
  // SUMMARY STAT CARD
  // ==========================
  Widget _buildStatCard(String title, int count, IconData icon) {
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: 32),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  // ==========================
  // ACTION BUTTON
  // ==========================
  Widget _buildActionButton(
      {required String text, required VoidCallback onTap}) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: BorderSide(color: primaryBlue, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
