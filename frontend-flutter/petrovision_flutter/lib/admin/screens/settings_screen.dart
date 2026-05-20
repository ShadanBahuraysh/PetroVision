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

// ========================================================================================================
// PetroVision Settings Screen
// ========================================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/interactive_widgets.dart';

class SettingsScreen extends StatefulWidget {
  final String? userId;
  const SettingsScreen({super.key, this.userId});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String baseUrl = "http://localhost:8000";

  bool isLoading = true;
  List<Map<String, dynamic>> admins = [];
  Map<String, dynamic>? currentAdmin;

  final _firstNameController = TextEditingController();
  final _lastNameController  = TextEditingController();
  final _emailController     = TextEditingController();
  final _phoneController     = TextEditingController();
  final _jobNumberController = TextEditingController();
  bool _jobNumberObscured = true;

  // Profile field errors
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;

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

  // ── Validators ──────────────────────────────────────────────────────────────

  String? _validateName(String value, String fieldLabel) {
    final t = value.trim();
    if (t.isEmpty) return '$fieldLabel is required.';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(t)) return '$fieldLabel must contain letters only.';
    return null;
  }

  String? _validateEmail(String value, {String? excludeUserId}) {
    final t = value.trim();
    if (t.isEmpty) return 'Email is required.';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(t)) return 'Enter a valid email address.';
    final duplicate = admins.any((a) =>
        (a['email'] ?? '').toString().toLowerCase() == t.toLowerCase() &&
        a['user_id'] != excludeUserId);
    if (duplicate) return 'This email is already used by another account.';
    return null;
  }

  String? _validatePhone(String value) {
    final t = value.trim();
    if (t.isEmpty) return 'Phone number is required.';
    if (!RegExp(r'^[0-9+\-\s()]{7,15}$').hasMatch(t)) return 'Enter a valid phone number.';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.trim().isEmpty) return 'Password is required.';
    if (value.trim().length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? _validateJobNumber(String value) {
    if (value.trim().isEmpty) return 'Job number is required.';
    return null;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _extractErrorMessage(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map && data["detail"] != null) {
        final detail = data["detail"].toString();
        if (detail.toLowerCase().contains("duplicate") || detail.toLowerCase().contains("already exists")) {
          return "This email is already used by another account.";
        }
        return detail;
      }
    } catch (_) {}
    return "Something went wrong. Please try again.";
  }

  void _showSnack(String message, {bool success = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  // ── Data ─────────────────────────────────────────────────────────────────────

  Future<void> _loadAdmins() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/auth/admins"));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        admins = data.map((e) => Map<String, dynamic>.from(e)).toList();

        String? resolvedId = widget.userId?.isNotEmpty == true ? widget.userId : null;
        if (resolvedId == null) {
          final prefs = await SharedPreferences.getInstance();
          resolvedId = prefs.getString('logged_in_user_id');
        }

        if (resolvedId != null && resolvedId.isNotEmpty) {
          currentAdmin = admins.firstWhere(
            (a) => a["user_id"] == resolvedId,
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
    final name  = (admin["name"] ?? "").toString().trim();
    final parts = name.split(" ");
    _firstNameController.text = parts.isNotEmpty ? parts.first : "";
    _lastNameController.text  = parts.length > 1 ? parts.sublist(1).join(" ") : "";
    _emailController.text     = admin["email"] ?? "";
    _phoneController.text     = admin["phone"] ?? "";
    _jobNumberController.text = admin["job_number"] ?? "";
  }

  Future<void> _updateCurrentAdmin() async {
    // Run all profile validators
    final fnErr    = _validateName(_firstNameController.text, 'First name');
    final lnErr    = _validateName(_lastNameController.text, 'Last name');
    final emErr    = _validateEmail(_emailController.text, excludeUserId: currentAdmin?["user_id"]);
    final phErr    = _validatePhone(_phoneController.text);

    setState(() {
      _firstNameError = fnErr;
      _lastNameError  = lnErr;
      _emailError     = emErr;
      _phoneError     = phErr;
    });

    if (fnErr != null || lnErr != null || emErr != null || phErr != null) return;
    if (currentAdmin == null || currentAdmin!["user_id"] == null) return;

    try {
      final res = await http.put(
        Uri.parse("$baseUrl/auth/admins/${currentAdmin!["user_id"]}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fname":      _firstNameController.text.trim(),
          "lname":      _lastNameController.text.trim(),
          "email":      _emailController.text.trim(),
          "phone":      _phoneController.text.trim(),
          "job_number": _jobNumberController.text.trim(),
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        _showSnack("Profile updated successfully.", success: true);
        await _loadAdmins();
      } else {
        _showSnack(_extractErrorMessage(res));
      }
    } catch (e) {
      _showSnack("Connection error. Please try again.");
    }
  }

  Future<void> _addAdmin({
    required String fname, required String lname, required String email,
    required String phone, required String password, required String jobNumber,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/auth/admins"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "fname": fname, "lname": lname, "email": email,
          "phone": phone, "password": password,
          "role": "admin", "job_number": jobNumber,
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context);
        _showSnack("Admin added successfully.", success: true);
        await _loadAdmins();
      } else {
        _showSnack(_extractErrorMessage(res));
      }
    } catch (e) {
      _showSnack("Connection error. Please try again.");
    }
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────────

  Future<void> _editAdmin(Map<String, dynamic> admin) async {
    final fnCtrl  = TextEditingController();
    final lnCtrl  = TextEditingController();
    final emCtrl  = TextEditingController(text: admin["email"] ?? "");
    final phCtrl  = TextEditingController(text: admin["phone"] ?? "");
    final jobCtrl = TextEditingController(text: admin["job_number"] ?? "");

    final name  = (admin["name"] ?? "").toString().trim();
    final parts = name.split(" ");
    fnCtrl.text = parts.isNotEmpty ? parts.first : "";
    lnCtrl.text = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    String? fnErr, lnErr, emErr, phErr;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Edit Admin"),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogFieldValidated("First Name", fnCtrl, errorText: fnErr,
              onChanged: (v) => set(() => fnErr = _validateName(v, 'First name'))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Last Name", lnCtrl, errorText: lnErr,
              onChanged: (v) => set(() => lnErr = _validateName(v, 'Last name'))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Email", emCtrl, errorText: emErr,
              onChanged: (v) => set(() => emErr = _validateEmail(v, excludeUserId: admin["user_id"]))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Phone", phCtrl, errorText: phErr,
              onChanged: (v) => set(() => phErr = _validatePhone(v))),
          const SizedBox(height: 12),
          _dialogField("Job Number", jobCtrl),
        ])),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF4195AF),
                textStyle: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF132935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () async {
              set(() {
                fnErr = _validateName(fnCtrl.text, 'First name');
                lnErr = _validateName(lnCtrl.text, 'Last name');
                emErr = _validateEmail(emCtrl.text, excludeUserId: admin["user_id"]);
                phErr = _validatePhone(phCtrl.text);
              });
              if (fnErr != null || lnErr != null || emErr != null || phErr != null) return;

              final res = await http.put(
                Uri.parse("$baseUrl/auth/admins/${admin["user_id"]}"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({
                  "fname": fnCtrl.text.trim(), "lname": lnCtrl.text.trim(),
                  "email": emCtrl.text.trim(), "phone": phCtrl.text.trim(),
                  "job_number": jobCtrl.text.trim(),
                }),
              );
              if (!mounted) return;
              if (res.statusCode == 200) {
                Navigator.pop(context);
                await _loadAdmins();
                _showSnack("Admin updated successfully.", success: true);
              } else {
                _showSnack(_extractErrorMessage(res));
              }
            },
            child: const Text("Save"),
          ),
        ],
      )),
    );
  }


  // ── Auto-generate next job number ─────────────────────────────────────────
  String _nextJobNumber() {
    // Collect all existing ADM-NNN numbers
    final existing = admins
        .map((a) => (a['job_number'] ?? '').toString().toUpperCase())
        .where((j) => RegExp(r'^ADM-\d+$').hasMatch(j))
        .map((j) => int.tryParse(j.split('-')[1]) ?? 0)
        .toList();
    final next = existing.isEmpty ? 1 : (existing.reduce((a, b) => a > b ? a : b) + 1);
    return 'ADM-' + next.toString().padLeft(3, '0');
  }

  void _showAddAdminDialog() {
    final fnCtrl  = TextEditingController();
    final lnCtrl  = TextEditingController();
    final emCtrl  = TextEditingController();
    final phCtrl  = TextEditingController();
    final pwCtrl  = TextEditingController();
    final jobCtrl = TextEditingController(text: _nextJobNumber());

    String? fnErr, lnErr, emErr, phErr, pwErr, jobErr;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
        backgroundColor: const Color(0xFFF8FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Add Admin"),
        content: SizedBox(width: 420, child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogFieldValidated("First Name", fnCtrl, errorText: fnErr,
              onChanged: (v) => set(() => fnErr = _validateName(v, 'First name'))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Last Name", lnCtrl, errorText: lnErr,
              onChanged: (v) => set(() => lnErr = _validateName(v, 'Last name'))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Email", emCtrl, errorText: emErr,
              onChanged: (v) => set(() => emErr = _validateEmail(v))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Phone", phCtrl, errorText: phErr,
              onChanged: (v) => set(() => phErr = _validatePhone(v))),
          const SizedBox(height: 12),
          _dialogFieldValidated("Password", pwCtrl, errorText: pwErr, obscure: true,
              onChanged: (v) => set(() => pwErr = _validatePassword(v))),
          const SizedBox(height: 12),
          _dialogFieldReadOnly("Job Number", jobCtrl),
        ])),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF4195AF),
                textStyle: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF132935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: () {
              set(() {
                fnErr  = _validateName(fnCtrl.text, 'First name');
                lnErr  = _validateName(lnCtrl.text, 'Last name');
                emErr  = _validateEmail(emCtrl.text);
                phErr  = _validatePhone(phCtrl.text);
                pwErr  = _validatePassword(pwCtrl.text);
              });
              if (fnErr != null || lnErr != null || emErr != null ||
                  phErr != null || pwErr != null) return;
              _addAdmin(
                fname: fnCtrl.text.trim(), lname: lnCtrl.text.trim(),
                email: emCtrl.text.trim(), phone: phCtrl.text.trim(),
                password: pwCtrl.text.trim(), jobNumber: jobCtrl.text.trim(),
              );
            },
            child: const Text("Add"),
          ),
        ],
      )),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

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
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // ── Profile Settings ──────────────────────────────────────
                  Expanded(flex: 3, child: SectionCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _sectionHeader(Icons.person_outline_rounded, 'Profile Settings', 'Update current admin information.'),
                      const SizedBox(height: 22),
                      Row(children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xFF132935),
                          child: Text(
                            (_firstNameController.text.isNotEmpty ? _firstNameController.text[0] : "A").toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text("${_firstNameController.text} ${_lastNameController.text}",
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827))),
                          const SizedBox(height: 4),
                          Text(_emailController.text,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ]),
                      ]),
                      const SizedBox(height: 24),
                      const Divider(color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: _fieldValidated('First Name', _firstNameController,
                            errorText: _firstNameError,
                            onChanged: (v) => setState(() => _firstNameError = _validateName(v, 'First name')))),
                        const SizedBox(width: 16),
                        Expanded(child: _fieldValidated('Last Name', _lastNameController,
                            errorText: _lastNameError,
                            onChanged: (v) => setState(() => _lastNameError = _validateName(v, 'Last name')))),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: _fieldValidated('Email Address', _emailController,
                            icon: Icons.email_outlined,
                            errorText: _emailError,
                            onChanged: (v) => setState(() => _emailError = _validateEmail(v, excludeUserId: currentAdmin?["user_id"])))),
                        const SizedBox(width: 16),
                        Expanded(child: _fieldValidated('Phone Number', _phoneController,
                            icon: Icons.phone_outlined,
                            errorText: _phoneError,
                            onChanged: (v) => setState(() => _phoneError = _validatePhone(v)))),
                      ]),
                      const SizedBox(height: 16),
                      _jobNumberField(),
                      const SizedBox(height: 24),
                      Align(alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: _updateCurrentAdmin,
                          style: darkDesktopButtonStyle(),
                          child: const Text('Save Changes'),
                        )),
                    ]),
                  )),
                  const SizedBox(width: 20),
                  // ── Admin Management ──────────────────────────────────────
                  Expanded(flex: 2, child: SectionCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12, runSpacing: 12,
                        children: [
                          _sectionHeader(Icons.admin_panel_settings_outlined, 'Admin Management', 'Add and edit administrator accounts.'),
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
                    ]),
                  )),
                ]),
                const SizedBox(height: 22),
                SectionCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionHeader(Icons.info_outline_rounded, 'System Information', 'Current platform and version details.'),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(child: _infoTile('Platform Version', 'PetroVision v2.4.1', Icons.rocket_launch_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _infoTile('Backend Status', 'Connected', Icons.cloud_done_outlined, valueColor: const Color(0xFF22C55E))),
                    const SizedBox(width: 16),
                    Expanded(child: _infoTile('ML Model', 'XGBoost v2 — Active', Icons.psychology_outlined)),
                  ]),
                ])),
              ],
            ),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────────

  Widget _fieldValidated(String label, TextEditingController ctrl,
      {IconData? icon, String? errorText, void Function(String)? onChanged}) {
    final hasErr = errorText != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF132935)),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF4195AF)) : null,
          filled: true,
          fillColor: hasErr ? const Color(0xFFFFF1F1) : const Color(0xFFF6F7F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: hasErr ? const BorderSide(color: Color(0xFFEF4444), width: 1.5) : BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasErr ? const Color(0xFFEF4444) : const Color(0xFF4195AF), width: 1.5)),
        ),
      ),
      if (hasErr) ...[
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
          const SizedBox(width: 4),
          Expanded(child: Text(errorText, style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)))),
        ]),
      ],
    ]);
  }

  Widget _dialogFieldValidated(String label, TextEditingController ctrl,
      {String? errorText, bool obscure = false, void Function(String)? onChanged}) {
    final hasErr = errorText != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: ctrl,
        obscureText: obscure,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
          filled: true,
          fillColor: hasErr ? const Color(0xFFFFF1F1) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasErr ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0), width: hasErr ? 1.5 : 1)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: hasErr ? const Color(0xFFEF4444) : const Color(0xFF132935), width: 1.5)),
        ),
      ),
      if (hasErr) ...[
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
          const SizedBox(width: 4),
          Expanded(child: Text(errorText, style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)))),
        ]),
      ],
    ]);
  }


  Widget _dialogFieldReadOnly(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      readOnly: true,
      style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF132935), letterSpacing: 1.2),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF4195AF)),
        filled: true,
        fillColor: const Color(0xFFEEF0F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF132935), width: 1.5)),
        helperText: 'Auto-generated — cannot be changed',
        helperStyle: const TextStyle(fontSize: 11, color: Color(0xFF8A959E)),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl, {bool obscure = false}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF132935), width: 1.5)),
      ),
    );
  }

  Widget _adminTile(Map<String, dynamic> admin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFF132935), child: Icon(Icons.person, color: Colors.white, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(admin["name"] ?? "Admin", style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          Text("${admin["email"] ?? ""} • Job Number Hidden", style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12)),
        ])),
        IconButton(onPressed: () => _editAdmin(admin), icon: const Icon(Icons.edit_outlined, color: Color(0xFF4195AF))),
      ]),
    );
  }

  Widget _sectionHeader(IconData icon, String title, String subtitle) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF132935).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF132935), size: 20)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8A959E))),
      ]),
    ]);
  }

  Widget _jobNumberField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Job Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
      const SizedBox(height: 8),
      TextField(
        controller: _jobNumberController,
        obscureText: _jobNumberObscured,
        readOnly: true,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF132935)),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF4195AF)),
          suffixIcon: IconButton(
            icon: Icon(_jobNumberObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: const Color(0xFF8A959E)),
            onPressed: () => setState(() => _jobNumberObscured = !_jobNumberObscured),
          ),
          filled: true, fillColor: const Color(0xFFEEF0F2),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    ]);
  }

  Widget _infoTile(String label, String value, IconData icon, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF4195AF)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A959E), fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: valueColor ?? const Color(0xFF132935))),
        ])),
      ]),
    );
  }
}