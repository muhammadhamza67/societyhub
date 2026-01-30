import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String workerId; // 🔹 Use workerId

  const WorkerProfileScreen({super.key, required this.workerId});

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController gullyController = TextEditingController();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWorkerProfile();
  }

  Future<void> fetchWorkerProfile() async {
    setState(() {
      isLoading = true;
    });

    final profile = await ApiService.getWorkerProfileById(widget.workerId);
    if (profile != null) {
      nameController.text = profile['name'] ?? '';
      phoneController.text = profile['phone'] ?? '';
      gullyController.text = profile['address']?['gully'] ?? '';
      houseController.text = profile['address']?['house_no'] ?? '';
      skillsController.text =
          (profile['skills'] as List<dynamic>?)?.join(', ') ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final skillsList =
        skillsController.text.split(',').map((e) => e.trim()).toList();

    final success = await ApiService.saveWorkerProfile(
      workerId: widget.workerId, // 🔹 API still uses userId internally
      name: nameController.text,
      phone: phoneController.text,
      gully: gullyController.text,
      houseNo: houseController.text,
      skills: skillsList,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Profile submitted successfully! Pending approval.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit profile. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Profile'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Complete your profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// NAME
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// PHONE
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    /// ADDRESS
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: gullyController,
                            decoration: const InputDecoration(
                              labelText: 'Street / Gully',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter street/gully';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: houseController,
                            decoration: const InputDecoration(
                              labelText: 'House No',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter house number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// SKILLS / JOB APPLIED
                    TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills / Job Applied',
                        hintText: 'Separate multiple skills with comma',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your skills';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Submit Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
