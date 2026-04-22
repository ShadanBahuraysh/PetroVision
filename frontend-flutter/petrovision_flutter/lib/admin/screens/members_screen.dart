import 'package:flutter/material.dart';

import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      selectedIndex: 2,
      title: 'Members',
      subtitle: 'Track member activity, tiers, and recent engagement.',
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalMembersCard(),
            Row(
              children: [
                const Expanded(
                  child: Text('Member Directory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                SizedBox(
                  width: 280,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search members',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _header(),
            _row('M001', 'Abeer Ahmed', 'Gold', '12,440 pts', 'Active'),
            _row('M002', 'Sara Khalid', 'Silver', '8,920 pts', 'Active'),
            _row('M003', 'Nora Hamed', 'Bronze', '3,110 pts', 'Inactive'),
            _row('M004', 'Layan Omar', 'Gold', '14,050 pts', 'Active'),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: const Row(
          children: [
            Expanded(child: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Tier', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Points', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
          ],
        ),
      );

  Widget _row(String a, String b, String c, String d, String e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(child: Text(a)),
            Expanded(flex: 2, child: Text(b)),
            Expanded(child: Text(c)),
            Expanded(child: Text(d)),
            Expanded(child: Text(e)),
          ],
        ),
      );


  Widget _buildTotalMembersCard() {
    const int totalMembers = 4;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Color(0xFF0F172A),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Members',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalMembers',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
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
