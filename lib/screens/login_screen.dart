import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:societyhub/screens/resident/resident_flow_handler.dart';
import 'package:societyhub/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ================= LOGIN LOGIC (FIXED) =================
  Future<void> login(BuildContext context, String role) async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final userId = userCredential.user!.uid;

      // ---------------- RESIDENT ----------------
      if (role == 'resident') {
        final exists = await ApiService.checkResidentProfile(userId);

        if (exists) {
          Navigator.pushReplacementNamed(
            context,
            '/resident_dashboard',
            arguments: userId,
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResidentFlowHandler(residentId: userId),
            ),
          );
        }
      }

      // ---------------- ADMIN ----------------
      else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      }

      // ---------------- WORKER ----------------
      else if (role == 'worker') {
        final exists = await ApiService.checkWorkerProfile(userId);

        // New worker → profile form
        if (!exists) {
          Navigator.pushReplacementNamed(
            context,
            '/worker_profile',
            arguments: userId,
          );
          return;
        }

        final profile = await ApiService.getWorkerProfileById(userId);
        final status = profile?['status'] ?? 'Pending';

        if (status == 'Approved') {
          Navigator.pushReplacementNamed(
            context,
            '/worker_dashboard',
            arguments: userId,
          );
        } else if (status == 'Pending') {
          _showInfoDialog(
            'Pending Approval',
            'Your profile is submitted and waiting for admin approval.',
          );
        } else if (status == 'Rejected') {
          _showRejectedDialog(userId);
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      } else {
        message = e.message ?? 'Login failed';
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= DIALOGS =================
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRejectedDialog(String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Profile Rejected'),
        content: const Text(
            'Your profile was rejected. Please update and resubmit.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                '/worker_profile',
                arguments: userId,
              );
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  // ================= UI (UNCHANGED) =================
  @override
  Widget build(BuildContext context) {
    final role =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'resident';

    Color roleColor;
    String roleLabel;

    switch (role) {
      case 'worker':
        roleColor = Colors.orange;
        roleLabel = 'Worker';
        break;
      case 'admin':
        roleColor = Colors.green;
        roleLabel = 'Admin';
        break;
      default:
        roleColor = const Color(0xFF1565C0);
        roleLabel = 'Resident';
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [roleColor.withOpacity(0.8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Welcome Back, $roleLabel',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: roleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to continue managing your tasks',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Email',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Password',
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : () => login(context, role),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black87,
                            side: BorderSide(color: roleColor, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
