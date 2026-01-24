import 'package:flutter/material.dart';
import 'package:societyhub/services/api_service.dart';

class ResidentInfoScreen extends StatefulWidget {
  final String residentId;
  const ResidentInfoScreen({super.key, required this.residentId});

  @override
  State<ResidentInfoScreen> createState() => _ResidentInfoScreenState();
}

class _ResidentInfoScreenState extends State<ResidentInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetching = true; // For fetching existing profile

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _gullyController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();

  final Color primaryBlue = const Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();
    loadResidentProfile();
  }

  Future<void> loadResidentProfile() async {
    setState(() => _isFetching = true);
    try {
      final profile = await ApiService.getResidentProfileById(widget.residentId);

      if (profile != null) {
        _nameController.text = profile['name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _gullyController.text = profile['gully'] ?? '';
        _houseController.text = profile['house_no'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: $e")),
      );
    } finally {
      setState(() => _isFetching = false);
    }
  }

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      bool success = await ApiService.saveResidentProfile(
        residentId: widget.residentId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        gully: _gullyController.text.trim(),
        houseNo: _houseController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Saved Successfully")),
        );

        Navigator.pushReplacementNamed(
          context,
          '/resident_dashboard',
          arguments: widget.residentId,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save profile")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _gullyController.dispose();
    _houseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isFetching
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryBlue.withOpacity(0.85), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Text(
                          "Complete Your Profile",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please provide your details to continue",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 30),

                        /// CARD
                        Container(
                          padding: const EdgeInsets.all(20),
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
                              TextFormField(
                                controller: _nameController,
                                decoration: _inputDecoration("Full Name"),
                                validator: (v) =>
                                    v == null || v.isEmpty ? "Enter your name" : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _phoneController,
                                decoration: _inputDecoration("Phone Number"),
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Enter phone number"
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _gullyController,
                                decoration: _inputDecoration("Gully / Street"),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Enter gully/street"
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _houseController,
                                decoration: _inputDecoration("House No"),
                                validator: (v) => v == null || v.isEmpty
                                    ? "Enter house number"
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        /// BUTTON
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : submitProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              side: BorderSide(color: primaryBlue, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: primaryBlue)
                                : const Text(
                                    "Save Profile",
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
