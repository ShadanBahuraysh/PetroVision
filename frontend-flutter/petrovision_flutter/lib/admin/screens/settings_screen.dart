// ========================================================================================================
// PetroVision Settings Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the SettingsScreen and related
// UI components used for managing administrator
// settings and profile operations within the
// PetroVision admin dashboard.
//
// Features included:
// - Loading administrator account data
// - Updating admin profile information
// - Adding new administrator accounts
// - Editing administrator accounts
// - Displaying system information and platform status
// - Managing admin profile settings
// - Handling API requests and validation errors
// - Displaying success and error notifications
// - Providing interactive settings UI components
//
// It also integrates administrator-management
// workflows, backend API operations, and
// system configuration features within the
// PetroVision platform.
// ========================================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/interactive_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final String? userId;

  const SettingsScreen({
    super.key,
    this.userId,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String baseUrl = "http://10.0.2.2:8000";

  bool isLoading = true;
  List<Map<String, dynamic>> admins = [];
  Map<String, dynamic>? currentAdmin;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobNumberController = TextEditingController();
  bool _jobNumberObscured = true;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _jobNumberController.dispose();
    super.dispose();
  }
  
String _extractErrorMessage(http.Response res) {
  try {
    final data = jsonDecode(res.body);

    if (data is Map && data["detail"] != null) {
      final detail = data["detail"].toString();

      if (detail.toLowerCase().contains("duplicate") ||
          detail.toLowerCase().contains("already exists")) {
        return "This email is already used by another account";
      }

      return detail;
    }
  } catch (_) {}

  return "Something went wrong. Please try again.";
}

void _showSnack(String message, {bool success = false}) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );
}
  Future<void> _loadAdmins() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/auth/admins"));

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);

        admins = data.map((e) => Map<String, dynamic>.from(e)).toList();

        if (widget.userId != null) {
          currentAdmin = admins.firstWhere(
            (a) => a["user_id"] == widget.userId,
            orElse: () => admins.isNotEmpty ? admins.first : {},
          );
        } else {
          currentAdmin = admins.isNotEmpty ? admins.first : {};
        }

        _fillProfileFields();
      }
    } catch (e) {
      debugPrint("load admins error: $e");
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _fillProfileFields() {
    final admin = currentAdmin ?? {};

    final name = (admin["name"] ?? "").toString().trim();
    final parts = name.split(" ");

    _firstNameController.text = parts.isNotEmpty ? parts.first : "";
    _lastNameController.text = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    _emailController.text = admin["email"] ?? "";
    _phoneController.text = admin["phone"] ?? "";
    _jobNumberController.text = admin["job_number"] ?? "";
  }

  Future<void> _updateCurrentAdmin() async {
    if (currentAdmin == null || currentAdmin!["user_id"] == null) return;

    try {
      final res = await http.put(
        Uri.parse("$baseUrl/auth/admins/${currentAdmin!["user_id"]}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fname": _firstNameController.text.trim(),
          "lname": _lastNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "job_number": _jobNumberController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
        await _loadAdmins();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Update failed: ${res.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("update admin error: $e");
     _showSnack("Connection error. Please try again.");

    }
  }

  Future<void> _addAdmin({
  required String fname,
  required String lname,
  required String email,
  required String phone,
  required String password,
  required String jobNumber,
}) async {
  try {
    final res = await http.post(
      Uri.parse("$baseUrl/auth/admins"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fname": fname,
        "lname": lname,
        "email": email,
        "phone": phone,
        "password": password,
        "role": "admin",
        "job_number": jobNumber,
      }),
    );

    if (!mounted) return;

    if (res.statusCode == 200 || res.statusCode == 201) {
      Navigator.pop(context);
      _showSnack("Admin added successfully", success: true);
     await  _loadAdmins();
    } else {
      _showSnack("❌ ${_extractErrorMessage(res)}");
    }
  } catch (e) {
    _showSnack("❌ Connection error. Please try again.");
  }
}

  Future<void> _editAdmin(Map<String, dynamic> admin) async {
    final fnameController = TextEditingController();
    final lnameController = TextEditingController();
    final emailController = TextEditingController(text: admin["email"] ?? "");
    final phoneController = TextEditingController(text: admin["phone"] ?? "");
    final jobController = TextEditingController(text: admin["job_number"] ?? "");

    final name = (admin["name"] ?? "").toString().trim();
    final parts = name.split(" ");
    fnameController.text = parts.isNotEmpty ? parts.first : "";
    lnameController.text = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        ),
        title: const Text("Edit Admin"),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField("First Name", fnameController),
              const SizedBox(height: 12),
              _dialogField("Last Name", lnameController),
              const SizedBox(height: 12),
              _dialogField("Email", emailController),
              const SizedBox(height: 12),
              _dialogField("Phone", phoneController),
              const SizedBox(height: 12),
              _dialogField("Job Number", jobController),
            ],
          ),
        ),
        actions: [
          TextButton(
  style: TextButton.styleFrom(
    foregroundColor: const Color(0xFF4195AF),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),
  onPressed: () => Navigator.pop(context),
  child: const Text("Cancel"),
),
          FilledButton(
  style: FilledButton.styleFrom(
    backgroundColor: const Color(0xFF132935),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  onPressed: () async {
    final res = await http.put(
      Uri.parse("$baseUrl/auth/admins/${admin["user_id"]}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fname": fnameController.text.trim(),
        "lname": lnameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "job_number": jobController.text.trim(),
      }),
    );

    if (!mounted) return;

    if (res.statusCode == 200) {
      Navigator.pop(context);
      await _loadAdmins();
      _showSnack("Admin updated successfully", success: true);
    } else {
      _showSnack("❌ ${_extractErrorMessage(res)}");
    }
  },
  child: const Text("Save"),
),
        ],
      ),
    );
  }

  void _showAddAdminDialog() {
    final fnameController = TextEditingController();
    final lnameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final jobController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
        title: const Text("Add Admin"),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField("First Name", fnameController),
              const SizedBox(height: 12),
              _dialogField("Last Name", lnameController),
              const SizedBox(height: 12),
              _dialogField("Email", emailController),
              const SizedBox(height: 12),
              _dialogField("Phone", phoneController),
              const SizedBox(height: 12),
              _dialogField("Password", passwordController, obscure: true),
              const SizedBox(height: 12),
              _dialogField("Job Number", jobController),
            ],
          ),
        ),
        actions: [
          TextButton(
  style: TextButton.styleFrom(
    foregroundColor: const Color(0xFF4195AF),
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
    ),
  ),
  onPressed: () => Navigator.pop(context),
  child: const Text("Cancel"),
),
          FilledButton(
            style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF132935),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),),
            onPressed: () {
              _addAdmin(
                fname: fnameController.text.trim(),
                lname: lnameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                password: passwordController.text.trim(),
                jobNumber: jobController.text.trim(),
              );
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 3,
      title: 'Settings',
      subtitle: 'Manage admin profile and administrator accounts.',
      showExportButton: false,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              Icons.person_outline_rounded,
                              'Profile Settings',
                              'Update current admin information.',
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFF132935),
                                  child: Text(
                                    (_firstNameController.text.isNotEmpty
                                            ? _firstNameController.text[0]
                                            : "A")
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${_firstNameController.text} ${_lastNameController.text}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _emailController.text,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Divider(color: Color(0xFFE5E7EB)),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _field('First Name', _firstNameController)),
                                const SizedBox(width: 16),
                                Expanded(child: _field('Last Name', _lastNameController)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _field(
                                    'Email Address',
                                    _emailController,
                                    icon: Icons.email_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _field(
                                    'Phone Number',
                                    _phoneController,
                                    icon: Icons.phone_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _jobNumberField(),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                onPressed: _updateCurrentAdmin,
                                style: darkDesktopButtonStyle(),
                                child: const Text('Save Changes'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _sectionHeader(
                                  Icons.admin_panel_settings_outlined,
                                  'Admin Management',
                                  'Add and edit administrator accounts.',
                                ),
                                FilledButton.icon(
                                  onPressed: _showAddAdminDialog,
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text("Add Admin"),
                                  style: darkDesktopButtonStyle(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            ...admins.map((admin) => _adminTile(admin)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                        Icons.info_outline_rounded,
                        'System Information',
                        'Current platform and version details.',
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: _infoTile(
                              'Platform Version',
                              'PetroVision v2.4.1',
                              Icons.rocket_launch_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _infoTile(
                              'Backend Status',
                              'Connected',
                              Icons.cloud_done_outlined,
                              valueColor: const Color(0xFF22C55E),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _infoTile(
                              'ML Model',
                              'XGBoost v2 — Active',
                              Icons.psychology_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _adminTile(Map<String, dynamic> admin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF132935),
            child: Icon(Icons.person, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin["name"] ?? "Admin",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${admin["email"] ?? ""} • Job Number Hidden",
                  style: const TextStyle(
                    color: Color(0xFF8A959E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editAdmin(admin),
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF4195AF)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(
    color: Color(0xFF6B7280),
    fontWeight: FontWeight.w500,
  ),

  prefixIconColor: const Color(0xFF132935),

  filled: true,
  fillColor: Colors.white,

  contentPadding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  ),

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(
      color: Color(0xFFE2E8F0),
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(
      color: Color(0xFFE2E8F0),
    ),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(
      color: Color(0xFF132935),
      width: 1.5,
    ),
  ),
),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF132935).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF132935), size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A959E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _jobNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _jobNumberController,
          obscureText: _jobNumberObscured,
          readOnly: true,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF132935),
          ),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.badge_outlined,
              size: 18,
              color: Color(0xFF4195AF),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _jobNumberObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: const Color(0xFF8A959E),
              ),
              onPressed: () {
                setState(() => _jobNumberObscured = !_jobNumberObscured);
              },
            ),
            filled: true,
            fillColor: const Color(0xFFEEF0F2),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF132935),
          ),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 18, color: const Color(0xFF4195AF))
                : null,
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4195AF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4195AF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A959E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: valueColor ?? const Color(0xFF132935),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}