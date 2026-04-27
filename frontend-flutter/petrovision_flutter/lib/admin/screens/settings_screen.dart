import 'package:flutter/material.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/interactive_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _alertSounds = true;
  bool _weeklyReports = false;

  final _firstNameController  = TextEditingController(text: 'Ruba');
  final _lastNameController   = TextEditingController(text: 'Alzahrani');
  final _emailController      = TextEditingController(text: 'admin@petro.com');
  final _phoneController      = TextEditingController(text: '+966 5X XXX XXXX');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 3,
      title: 'Settings',
      subtitle: 'Update admin preferences and system defaults.',
      showExportButton: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Profile + Notifications side by side ─────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Profile Card
              Expanded(
                flex: 3,
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.person_outline_rounded, 'Profile Settings', 'Update your personal details.'),
                      const SizedBox(height: 22),

                      // Avatar row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF132935),
                            child: const Text('R', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ruba Alzahrani',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827))),
                              const SizedBox(height: 4),
                              Text('System Administrator',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
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
                          Expanded(child: _field('Email Address', _emailController, icon: Icons.email_outlined)),
                          const SizedBox(width: 16),
                          Expanded(child: _field('Phone Number', _phoneController, icon: Icons.phone_outlined)),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () {},
                          style: darkDesktopButtonStyle(),
                          child: const Text('Save Changes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Notifications Card
              Expanded(
                flex: 2,
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(Icons.notifications_outlined, 'Notifications', 'Manage how you receive alerts.'),
                      const SizedBox(height: 22),
                      _switchTile(
                        title: 'Email Notifications',
                        subtitle: 'Receive system and alert updates by email.',
                        icon: Icons.email_outlined,
                        value: _emailNotifications,
                        onChanged: (v) => setState(() => _emailNotifications = v),
                      ),
                      const SizedBox(height: 14),
                      _switchTile(
                        title: 'Alert Sounds',
                        subtitle: 'Enable sound for critical station alerts.',
                        icon: Icons.volume_up_outlined,
                        value: _alertSounds,
                        onChanged: (v) => setState(() => _alertSounds = v),
                      ),
                      const SizedBox(height: 14),
                      _switchTile(
                        title: 'Weekly Reports',
                        subtitle: 'Get a weekly summary of station performance.',
                        icon: Icons.summarize_outlined,
                        value: _weeklyReports,
                        onChanged: (v) => setState(() => _weeklyReports = v),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── System Info Card ──────────────────────────────────────
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Icons.info_outline_rounded, 'System Information', 'Current platform and version details.'),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _infoTile('Platform Version', 'PetroVision v2.4.1', Icons.rocket_launch_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _infoTile('Backend Status', 'Connected', Icons.cloud_done_outlined, valueColor: const Color(0xFF22C55E))),
                    const SizedBox(width: 16),
                    Expanded(child: _infoTile('ML Model', 'XGBoost v2 — Active', Icons.psychology_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _infoTile('Last Sync', 'Today, 10:14 AM', Icons.sync_rounded)),
                  ],
                ),
              ],
            ),
          ),
        ],
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
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8A959E))),
          ],
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF132935)),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF4195AF)) : null,
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4195AF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: value ? const Color(0xFF132935).withOpacity(0.04) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? const Color(0xFF132935).withOpacity(0.15) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? const Color(0xFF132935) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: value ? Colors.white : const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF132935),
          ),
        ],
      ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF4195AF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8A959E), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13,
                  color: valueColor ?? const Color(0xFF132935))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
