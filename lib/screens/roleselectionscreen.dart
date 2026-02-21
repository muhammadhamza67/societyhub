import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // 1️⃣ Try getting UID from arguments
    String? userId =
        ModalRoute.of(context)?.settings.arguments as String?;

    // 2️⃣ If arguments missing → get from Firebase directly
    userId ??= FirebaseAuth.instance.currentUser?.uid;

    // 3️⃣ If still null → show error
    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not found. Please login again.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // ================= UI =================
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Welcome to SocietyHub',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            RoleButton(
              icon: Icons.person,
              label: 'Resident',
              color: Colors.blue,
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/resident_dashboard',
                  arguments: userId,   // ✅ residentId
                );
              },
            ),

            const SizedBox(height: 20),

            RoleButton(
              icon: Icons.engineering,
              label: 'Worker',
              color: Colors.orange,
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/worker_dashboard',
                  arguments: userId,   // ✅ workerId
                );
              },
            ),

            const SizedBox(height: 20),

            RoleButton(
              icon: Icons.admin_panel_settings,
              label: 'Admin',
              color: Colors.green,
              onTap: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/admin_dashboard',
                  arguments: userId,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
