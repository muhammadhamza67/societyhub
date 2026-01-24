import 'package:flutter/material.dart';
import 'package:societyhub/screens/resident/resident_dashboard.dart';
import 'package:societyhub/services/api_service.dart';

import 'resident_info_screen.dart';

class ResidentFlowHandler extends StatefulWidget {
  final String residentId;

  const ResidentFlowHandler({super.key, required this.residentId});

  @override
  State<ResidentFlowHandler> createState() => _ResidentFlowHandlerState();
}

class _ResidentFlowHandlerState extends State<ResidentFlowHandler> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final exists = await ApiService.checkResidentProfile(widget.residentId);

      if (exists) {
        // Profile exists → Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResidentDashboardScreen(residentId: widget.residentId),
          ),
        );
      } else {
        // Profile not exists → Info Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResidentInfoScreen(residentId: widget.residentId),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to check profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show spinner while checking profile
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
