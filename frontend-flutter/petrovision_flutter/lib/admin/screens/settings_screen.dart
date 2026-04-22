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
  bool emailNotifications = true;
  bool alertSounds = true;

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 3,
      title: 'Settings',
      subtitle: 'Update admin preferences and system defaults.',
      showExportButton: false,
      child: Column(
        children: [
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _field('First Name', 'Ruba')),
                    const SizedBox(width: 16),
                    Expanded(child: _field('Last Name', 'Alzahrani')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _field('Email', 'admin@petro.com')),
                    const SizedBox(width: 16),
                    Expanded(child: _field('Phone', '+966 5X XXX XXXX')),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () {},
                    style: darkDesktopButtonStyle(),
                    child: const Text('Save Changes'),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 22),

          /// 🔥 SWITCHES (FIXED)
          SectionCard(
            child: Row(
              children: [
                Expanded(
                  child: _switchTile(
                    'Email Notifications',
                    'Receive system and alert updates by email.',
                    emailNotifications,
                    (val) => setState(() => emailNotifications = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _switchTile(
                    'Alert Sounds',
                    'Enable sound for critical station alerts.',
                    alertSounds,
                    (val) => setState(() => alertSounds = val),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// 🔥 UPDATED SWITCH TILE
  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}