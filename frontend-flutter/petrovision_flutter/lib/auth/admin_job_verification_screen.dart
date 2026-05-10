// ========================================================================================================
// PetroVision Admin Job Verification Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the AdminJobVerificationScreen
// used for verifying administrator job numbers
// within the PetroVision authentication workflow.
//
// Features included:
// - Verifying administrator job numbers
// - Sending verification requests to the backend API
// - Handling authentication and validation errors
// - Managing loading and verification states
// - Displaying verification feedback messages
// - Supporting secure admin-access workflows
// - Providing responsive verification UI components
//
// It also integrates administrator-verification
// operations with the PetroVision authentication
// and dashboard-access system.
// ========================================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminJobVerificationScreen extends StatefulWidget {
  final String userId;

  const AdminJobVerificationScreen({super.key, required this.userId});

  @override
  State<AdminJobVerificationScreen> createState() =>
      _AdminJobVerificationScreenState();
}

class _AdminJobVerificationScreenState
    extends State<AdminJobVerificationScreen> {
  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  final TextEditingController jobController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    jobController.dispose();
    super.dispose();
  }

  Future<void> _verifyJobNumber() async {
    final jobNumber = jobController.text.trim();

    if (jobNumber.isEmpty) {
      setState(() => _errorMessage = 'Please enter your job number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/auth/verify-admin-job'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': widget.userId, 'job_number': jobNumber}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      } else {
        String message = 'Invalid job number';
        try {
          final data = json.decode(response.body);
          message = data['detail'] ?? message;
        } catch (_) {}

        setState(() {
          _errorMessage = message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ADMIN VERIFICATION',
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(Icons.badge_outlined, color: accentBlue, size: 40),
              ),
              const SizedBox(height: 30),
              Text(
                'Admin Job Verification',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your admin job number to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: jobController,
                style: TextStyle(
                  color: primaryNavy,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter job number',
                  prefixIcon: Icon(Icons.work_outline, color: accentBlue),
                  errorText: _errorMessage,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: _errorMessage != null
                          ? Colors.red.shade200
                          : Colors.grey.shade200,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: accentBlue, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              SizedBox(
                width: 240,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyJobNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryNavy,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
