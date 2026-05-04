import 'package:flutter/material.dart';
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
          onPressed: () => Navigator.pop(context),
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
              widget.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: primaryNavy,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
             Text(
              widget.email,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 30),
            _SectionCard(
              title: l10n.personalInformation,
              child: Column(
                children: [
                  _InfoField(
                      label: l10n.fullNameLabel,
                      value: widget.name,
                      icon: Icons.person_outline_rounded),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.emailLabel,
                      value: widget.email,
                      icon: Icons.email_outlined),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.phoneLabel,
                      value: "+966 5X XXX XXXX",
                      icon: Icons.phone_outlined),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  _InfoField(
                      label: l10n.cityLabel,
                      value: "Riyadh",
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
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _buildTextField(l10n.phoneNumber, Icons.phone_outlined),
            const SizedBox(height: 12),
            _buildTextField(l10n.cityLabel, Icons.location_on_outlined),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2E35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
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
    );
  }

  void _showPasswordDialog(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                obscure: true),
            const SizedBox(height: 12),
            _buildTextField(l10n.newPassword, Icons.lock_rounded,
                obscure: true),
            const SizedBox(height: 12),
            _buildTextField(l10n.confirmPassword, Icons.lock_rounded,
                obscure: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2E35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
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
    );
  }

  Widget _buildTextField(String label, IconData icon,
      {bool obscure = false}) {
    return TextField(
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
