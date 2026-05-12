// ========================================================================================================
// PetroVision Manage Profile Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the ManageProfileScreen
// used for displaying and managing customer
// profile information within the PetroVision platform.
//
// Features included:
// - Displaying customer profile information
// - Displaying personal and account information
// - Supporting profile-edit workflows
// - Supporting password-update workflows
// - Displaying profile-management dialogs
// - Supporting multilingual localization content
// - Providing reusable profile and action widgets
// - Providing responsive profile-management UI
//
// It also integrates customer profile workflows,
// account-management features,
// and profile-editing interfaces
// within the PetroVision platform.
// ========================================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r/l10n/app_localizations.dart';

class ManageProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;

  const ManageProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  State<ManageProfileScreen> createState() =>
      _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  late String _displayName;
  late String _displayEmail;
  String _displayPhone = "+966 5X XXX XXXX";
  String _displayCity = "Riyadh";

  @override
  void initState() {
    super.initState();
    _displayName = widget.name;
    _displayEmail = widget.email;
    _fetchUserProfile();
  }

  // ── Fetch current profile from backend ──────────────────────────────────
  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/auth/user/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _displayName = data['name'] ?? widget.name;
          _displayEmail = data['email'] ?? widget.email;
          _displayPhone = data['phone'] ?? _displayPhone;
          _displayCity = data['city'] ?? _displayCity;
        });
      }
    } catch (_) {
      // If fetch fails, keep widget values
    }
  }

  // ── Save updated profile to backend ─────────────────────────────────────
  Future<bool> _saveProfile({
    String? name,
    String? phone,
    String? city,
  }) async {
    try {
      // Build update payload — only send changed fields
      final Map<String, dynamic> payload = {};
      if (name != null && name.isNotEmpty) {
        final parts = name.trim().split(' ');
        payload['fname'] = parts.first;
        payload['lname'] = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
      if (phone != null && phone.isNotEmpty) payload['phone'] = phone;
      if (city != null && city.isNotEmpty) payload['city'] = city;

      if (payload.isEmpty) return true; // Nothing to update

      final response = await http.put(
        Uri.parse('http://localhost:8000/auth/update-user/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF1A2E35);
    const accentBlue = Color(0xFF4195AF);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          l10n.myProfile,
          style: const TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Color(0xFF1A2E35)),
          onPressed: () => Navigator.pop(context, _displayName),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentBlue.withOpacity(0.1),
                    border: Border.all(
                        color: accentBlue.withOpacity(0.3), width: 2),
                  ),
                  child: const Icon(Icons.person_rounded,
                      size: 55, color: accentBlue),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: accentBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 14, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _displayName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _displayEmail,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            _SectionCard(
              title: l10n.personalInformation,
              child: Column(
                children: [
                  _InfoField(
                      label: l10n.fullNameLabel,
                      value: _displayName,
                      icon: Icons.person_outline_rounded),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.emailLabel,
                      value: _displayEmail,
                      icon: Icons.email_outlined),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.phoneLabel,
                      value: _displayPhone,
                      icon: Icons.phone_outlined),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.cityLabel,
                      value: _displayCity,
                      icon: Icons.location_on_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l10n.accountSection,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    label: l10n.editProfile,
                    subtitle: l10n.updatePersonalInfo,
                    onTap: () => _showEditDialog(context, l10n),
                  ),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _ActionTile(
                    icon: Icons.lock_outline_rounded,
                    label: l10n.changePassword,
                    subtitle: l10n.updateSecurityCredentials,
                    onTap: () => _showPasswordDialog(context, l10n),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.red, size: 20),
                ),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.red),
                onTap: () => Navigator.pop(context, _displayName),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Edit Profile Dialog ──────────────────────────────────────────────────
  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    final nameCtrl = TextEditingController(text: _displayName);
    final phoneCtrl = TextEditingController(
        text: _displayPhone == "+966 5X XXX XXXX" ? '' : _displayPhone);
    final cityCtrl = TextEditingController(text: _displayCity);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editProfile,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E35),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(l10n.fullNameLabel,
                  Icons.person_outline_rounded, controller: nameCtrl),
              const SizedBox(height: 12),
              _buildTextField(l10n.phoneNumber, Icons.phone_outlined,
                  controller: phoneCtrl),
              const SizedBox(height: 12),
              _buildTextField(l10n.cityLabel, Icons.location_on_outlined,
                  controller: cityCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setSheetState(() => isSaving = true);

                          final success = await _saveProfile(
                            name: nameCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            city: cityCtrl.text.trim(),
                          );

                          setSheetState(() => isSaving = false);

                          if (!context.mounted) return;
                          Navigator.pop(context);

                          if (success) {
                            // ✅ Update UI with new values
                            setState(() {
                              if (nameCtrl.text.trim().isNotEmpty) {
                                _displayName = nameCtrl.text.trim();
                              }
                              if (phoneCtrl.text.trim().isNotEmpty) {
                                _displayPhone = phoneCtrl.text.trim();
                              }
                              if (cityCtrl.text.trim().isNotEmpty) {
                                _displayCity = cityCtrl.text.trim();
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully'),
                                backgroundColor: Color(0xFF1E8449),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to update profile. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2E35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.saveChanges,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Password Dialog ──────────────────────────────────────────────────────
  void _showPasswordDialog(BuildContext context, AppLocalizations l10n) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.changePassword,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2E35),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(l10n.currentPassword,
                  Icons.lock_outline_rounded,
                  obscure: true, controller: currentCtrl),
              const SizedBox(height: 12),
              _buildTextField(l10n.newPassword, Icons.lock_rounded,
                  obscure: true, controller: newCtrl),
              const SizedBox(height: 12),
              _buildTextField(l10n.confirmPassword, Icons.lock_rounded,
                  obscure: true, controller: confirmCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (newCtrl.text != confirmCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (newCtrl.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password must be at least 6 characters'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setSheetState(() => isSaving = true);
                          try {
                           final response = await http.post(
  Uri.parse('http://localhost:8000/auth/change-password/${widget.userId}'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'current_password': currentCtrl.text,
    'new_password': newCtrl.text,
  }),
);
                            setSheetState(() => isSaving = false);
                            if (!context.mounted) return;
                            Navigator.pop(context, _displayName);
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password updated successfully'),
                                  backgroundColor: Color(0xFF1E8449),
                                ),
                              );
                            } else {
  final error = jsonDecode(response.body);
  final msg = response.statusCode == 401
      ? 'Current password is incorrect'
      : error['detail'] ?? 'Failed to update password';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red),
  );
}
                          } catch (_) {
                            setSheetState(() => isSaving = false);
                            if (!context.mounted) return;
                            Navigator.pop(context, _displayName);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connection error. Please try again.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2E35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.updatePassword,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool obscure = false, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.next,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: const Color(0xFF4195AF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF6F7F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        labelStyle:
            const TextStyle(color: Colors.grey, fontSize: 14),
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
          ),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoField(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4195AF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2E35))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF4195AF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF4195AF), size: 20),
      ),
      title: Text(label,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1A2E35))),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Colors.grey),
    );
  }
}
