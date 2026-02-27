import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:societyhub/screens/admin/admin_add_announcement_screen.dart';
import 'package:societyhub/screens/admin/admin_manage_workers_screen.dart';
import 'package:societyhub/screens/admin/AdminManageResidentsScreen.dart';
import 'package:societyhub/screens/admin/admin_dashboard.dart';
import 'package:societyhub/screens/admin/admin_track_tasks.dart';
import 'package:societyhub/screens/admin/managerequesttaskscreen.dart';

import 'package:societyhub/screens/resident/request_tracking.dart';
import 'package:societyhub/screens/resident/resident_dashboard.dart';
import 'package:societyhub/screens/resident/service_request_form.dart';

import 'package:societyhub/screens/roleselectionscreen.dart';
import 'package:societyhub/screens/signup_screen.dart';
import 'package:societyhub/screens/worker/worker_dashboard.dart';
import 'package:societyhub/screens/worker/worker_task_list.dart';
import 'package:societyhub/screens/worker/worker_profile_screen.dart';


import 'screens/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SocietyHubApp());
}

class SocietyHubApp extends StatelessWidget {
  const SocietyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocietyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
        ),
      ),
      initialRoute: '/login',

      // 🔹 Use onGenerateRoute to handle argument-based navigation
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          // ================= AUTH =================
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupScreen());
          case '/roleSelection':
            return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

          // ================= RESIDENT =================
          case '/resident_dashboard':
            if (args is String) {
              return MaterialPageRoute(
                  builder: (_) => WillPopScope(
                        onWillPop: () async {
                          Navigator.pushReplacementNamed(context, '/roleSelection');
                          return false;
                        },
                        child: ResidentDashboardScreen(residentId: args),
                      ));
            }
            return _missingIdPage('Resident ID missing!');
          case '/service_request_form':
            if (args is String) {
              return MaterialPageRoute(
                  builder: (_) => WillPopScope(
                        onWillPop: () async {
                          Navigator.pushReplacementNamed(context, '/roleSelection');
                          return false;
                        },
                        child: ServiceRequestForm(residentId: args),
                      ));
            }
            return _missingIdPage('Resident ID missing!');
          case '/request_tracking':
            if (args is String) {
              return MaterialPageRoute(
                  builder: (_) => WillPopScope(
                        onWillPop: () async {
                          Navigator.pushReplacementNamed(context, '/roleSelection');
                          return false;
                        },
                        child: RequestTracking(residentId: args),
                      ));
            }
            return _missingIdPage('Resident ID missing!');

          // ================= WORKER =================
          case '/worker_dashboard':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const WorkerDashboardScreen(),
                    ));
          case '/worker_task_list':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const WorkerTaskListScreen(),
                    ));
          case '/worker_profile':
            if (args is String) {
              return MaterialPageRoute(
                  builder: (_) => WillPopScope(
                        onWillPop: () async {
                          Navigator.pushReplacementNamed(context, '/roleSelection');
                          return false;
                        },
                        child: WorkerProfileScreen(workerId: args),
                      ));
            }
            return _missingIdPage('Worker ID missing!');

          // ================= ADMIN =================
          case '/admin_dashboard':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const AdminDashboardScreen(),
                    ));
          case '/admin_track_tasks':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const AdminTrackTasks(),
                    ));
          case '/manage_request_task':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const ManageRequestTaskScreen(),
                    ));
          case '/admin_manage_residents':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const AdminManageResidentsScreen(),
                    ));
          case '/admin_manage_workers':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/roleSelection');
                        return false;
                      },
                      child: const AdminManageWorkersScreen(),
                    ));

          // 🔹 NEW: Admin Announcements
          case '/admin_announcements':
            return MaterialPageRoute(
                builder: (_) => WillPopScope(
                      onWillPop: () async {
                        Navigator.pushReplacementNamed(context, '/admin_dashboard');
                        return false;
                      },
                      child: AdminAddAnnouncementScreen(adminId: "admin123"), // replace with dynamic adminId
                    ));

          default:
            return _missingIdPage('Route not found!');
        }
      },
    );
  }

  // 🔹 Helper page for missing IDs or invalid routes
  MaterialPageRoute _missingIdPage(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text(message, style: const TextStyle(fontSize: 18))),
      ),
    );
  }
}