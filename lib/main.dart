import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:societyhub/screens/admin/admin_manage_workers_screen.dart';
import 'firebase_options.dart';

import 'package:societyhub/screens/admin/AdminManageResidentsScreen.dart';

 // ✅ NEW
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(SocietyHubApp());
}

class SocietyHubApp extends StatelessWidget {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const RoleSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),

        // ================= RESIDENT =================
        '/resident_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text('Resident ID missing!')),
            );
          }
          return ResidentDashboardScreen(residentId: args);
        },
        '/service_request_form': (context) =>
            ServiceRequestForm(residentId: ''),
        '/request_tracking': (context) =>
            const RequestTracking(residentId: ''),

        // ================= WORKER =================
        '/worker_dashboard': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text('Worker ID missing!')),
            );
          }
          return WorkerDashboardScreen(workerId: args);
        },
        '/worker_task_list': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text('Worker ID missing!')),
            );
          }
          return WorkerTaskListScreen(workerId: args);
        },
        '/worker_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text('Worker ID missing!')),
            );
          }
          return WorkerProfileScreen(workerId: args);
        },

        // ================= ADMIN =================
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/admin_track_tasks': (context) => const AdminTrackTasks(),
        '/manage_request_task': (context) =>
            const ManageRequestTaskScreen(),
        '/admin_manage_residents': (context) =>
            const AdminManageResidentsScreen(),

        // ✅ NEW: ADMIN MANAGE WORKERS
        '/admin_manage_workers': (context) =>
            const AdminManageWorkersScreen(),
      },
    );
  }
}
