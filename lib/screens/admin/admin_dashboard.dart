import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final Color primaryGreen = const Color(0xFF2E7D32);

  int totalRequests = 0;
  int pendingRequests = 0;
  int totalWorkers = 0; 
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final allRequests = await ApiService.getAllRequests(); 
      final allWorkers = await ApiService.getAllWorkers(); // 🔹 fetch all workers

      setState(() {
        totalRequests = allRequests.length;
        pendingRequests = allRequests.where((r) => r['status'] == 'Pending').length;
        totalWorkers = allWorkers.length; // 🔹 update total workers
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load dashboard data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); 
          },
        ),
        backgroundColor: primaryGreen,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen.withOpacity(0.85), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome Admin 👋',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage user requests and worker tasks efficiently.',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ===== Summary Cards =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryCard(
                              'Total Requests', totalRequests.toString(), primaryGreen, Icons.assignment),
                          _buildSummaryCard('Pending', pendingRequests.toString(),
                              Colors.orangeAccent, Icons.pending_actions),
                          _buildSummaryCard('Total Workers', totalWorkers.toString(),
                              Colors.blueAccent, Icons.engineering), // 🔹 new icon for workers
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ===== Dashboard Buttons =====
                      _buildDashboardButton(
                        context,
                        'Manage Requests / Tasks',
                        primaryGreen,
                        '/manage_request_task',
                        Icons.manage_accounts,
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardButton(
                        context,
                        'Track Tasks',
                        primaryGreen,
                        '/admin_track_tasks',
                        Icons.track_changes,
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardButton(
                        context,
                        'Manage Residents',
                        primaryGreen,
                        '/admin_manage_residents',
                        Icons.people_alt,
                      ),
                      const SizedBox(height: 20),
                      _buildDashboardButton(
                        context,
                        'Manage Workers', // 🔹 new button
                        primaryGreen,
                        '/admin_manage_workers', // 🔹 route to workers screen
                        Icons.engineering,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, Color color, String route, IconData icon) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon, size: 28, color: color),
        label: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
        ),
      ),
    );
  }
}
