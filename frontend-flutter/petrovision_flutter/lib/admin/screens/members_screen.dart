// ========================================================================================================
// PetroVision Members Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the MembersScreen and related
// UI components used for managing loyalty members
// within the PetroVision admin dashboard.
//
// Features included:
// - Loading member data from the backend
// - Displaying loyalty-member statistics
// - Searching and filtering members
// - Displaying member tiers and points
// - Displaying member activity status
// - Supporting member deletion operations
// - Handling API request and loading states
// - Providing interactive dashboard UI components
//
// It also integrates loyalty-member management
// and member analytics within the PetroVision
// administrative dashboard platform.
// ========================================================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';

const String _membersBaseUrl = 'http://localhost:8000';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});
  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_Member> _members = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('$_membersBaseUrl/auth/users'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _members = data.map((m) => _Member.fromJson(m)).toList();
          _loading = false;
        });
      } else {
        setState(() { _error = 'Failed to load members (${res.statusCode})'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Could not reach server'; _loading = false; });
    }
  }

  String _tierFilter   = 'All';
  String _statusFilter = 'All';

  List<_Member> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _members.where((m) {
      final matchTier   = _tierFilter   == 'All' || m.tier   == _tierFilter;
      final matchStatus = _statusFilter == 'All' || m.status == _statusFilter;
      final matchQuery  = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.id.toLowerCase().contains(q) ||
          m.tier.toLowerCase().contains(q);
      return matchTier && matchStatus && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _members.where((m) => m.status == 'active').length;
    final gold   = _members.where((m) => m.tier == 'Gold').length;
    final silver = _members.where((m) => m.tier == 'Silver').length;
    final bronze = _members.where((m) => m.tier == 'Bronze').length;

    return AdminShell(
      selectedIndex: 2,
      title: 'Members',
      subtitle: 'Track member activity, tiers, and recent engagement.',
      showExportButton: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF132935)))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFF8A959E)),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFF8A959E))),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadMembers,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF132935), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Retry'),
                  ),
                ]))
              : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Row
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            final cards = [
              _KpiCard(title: 'Total Members',   value: '${_members.length}', icon: Icons.people_alt_outlined,         sub: 'Registered accounts',  color: const Color(0xFF4195AF)),
              _KpiCard(title: 'Active Members',  value: '$active',            icon: Icons.check_circle_outline_rounded, sub: 'Currently active',     color: const Color(0xFF22C55E)),
              _KpiCard(title: 'Gold Members',    value: '$gold',              icon: Icons.workspace_premium_outlined,   sub: 'Highest tier',         color: const Color(0xFFF59E0B)),
              _KpiCard(title: 'Silver & Bronze', value: '${silver + bronze}', icon: Icons.star_half_rounded,            sub: 'Lower tier members',   color: const Color(0xFF8A959E)),
            ];
            if (isNarrow) {
              return Column(children: [
                Row(children: [cards[0], const SizedBox(width: 16), cards[1]]),
                const SizedBox(height: 16),
                Row(children: [cards[2], const SizedBox(width: 16), cards[3]]),
              ]);
            }
            return Row(children: [
              cards[0], const SizedBox(width: 16),
              cards[1], const SizedBox(width: 16),
              cards[2], const SizedBox(width: 16),
              cards[3],
            ]);
          }),
          const SizedBox(height: 22),

          // Table Card
          SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Member Directory',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    SizedBox(height: 4),
                    Text('All registered loyalty members and their current tier status.',
                        style: TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 18),

                // Search + Filters row
                Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search members...',
                          hintStyle: const TextStyle(color: Color(0xFF8A959E), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8A959E), size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF6F7F9),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tier filter
                    _FilterDropdown(
                      value: _tierFilter,
                      hint: 'All tiers',
                      items: const ['All', 'Gold', 'Silver', 'Bronze'],
                      onChanged: (v) { if (v != null) setState(() => _tierFilter = v); },
                    ),
                    const SizedBox(width: 10),

                    // Status filter
                    _FilterDropdown(
                      value: _statusFilter,
                      hint: 'All statuses',
                      items: const ['All', 'active', 'inactive'],
                      labelMap: const {'All': 'All statuses', 'active': 'Active', 'inactive': 'Inactive'},
                      onChanged: (v) { if (v != null) setState(() => _statusFilter = v); },
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: _TH('Member ID')),
                      Expanded(flex: 2, child: _TH('Name')),
                      Expanded(child: _TH('Tier')),
                      Expanded(child: _TH('Points')),
                      Expanded(child: _TH('Status')),
                      SizedBox(width: 48, child: _TH('')),
                    ],
                  ),
                ),

                // Rows
                ..._filtered.map((m) => _MemberRow(
                  member: m,
                  onDelete: () => _confirmDelete(m),
                )),
                if (_filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No members match your filters.',
                          style: TextStyle(color: Color(0xFF8A959E))),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _confirmDelete(_Member member) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Delete Member',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827)))),
              IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8A959E))),
            ]),
            const SizedBox(height: 16),
            RichText(text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5),
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(text: member.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                TextSpan(text: ' (${member.id})? This action cannot be undone.'),
              ],
            )),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final res = await http.delete(Uri.parse('$_membersBaseUrl/auth/users/${member.id}'));
                  if (!mounted) return;
                  if (res.statusCode == 200) {
                      await _loadMembers();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Member deleted successfully.')),
                      );
                } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to delete member.')),
                      );
                    }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

// ── Filter dropdown ────────────────────────────────────────────────────────────
class _FilterDropdown extends StatelessWidget {
  final String value;
  final String hint;
  final List<String> items;
  final Map<String, String>? labelMap;
  final ValueChanged<String?> onChanged;
  const _FilterDropdown({
    required this.value, required this.hint, required this.items,
    this.labelMap, required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF132935), size: 18),
        style: const TextStyle(color: Color(0xFF132935), fontWeight: FontWeight.w600, fontSize: 13),
        items: items.map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(labelMap?[item] ?? item),
        )).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}

// ── KPI card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String title, value, sub;
  final IconData icon;
  final Color color;
  const _KpiCard({required this.title, required this.value, required this.icon, required this.sub, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: const Color(0xFF132935).withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8A959E)))),
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
          ]),
          const SizedBox(height: 18),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF132935), letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
        ],
      ),
    ),
  );
}

// ── Table header cell ─────────────────────────────────────────────────────────
class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF8A959E)));
}

// ── Member row ────────────────────────────────────────────────────────────────
class _MemberRow extends StatefulWidget {
  final _Member member;
  final VoidCallback onDelete;
  const _MemberRow({required this.member, required this.onDelete});
  @override
  State<_MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<_MemberRow> {
  bool _hovered = false;

  Color get _tierColor {
    switch (widget.member.tier) {
      case 'Gold':   return const Color(0xFFF59E0B);
      case 'Silver': return const Color(0xFF8A959E);
      default:       return const Color(0xFFCD7C2F);
    }
  }

  String _fmt(int pts) {
    if (pts >= 1000) { final v = pts / 1000; return '${v.toStringAsFixed(v >= 10 ? 0 : 1)}K'; }
    return pts.toString();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final isActive = m.status == 'active';
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF6F7F9) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            // Member ID
            Expanded(child: Text(m.id,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8A959E)))),
            // Name with avatar
            Expanded(flex: 2, child: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF132935),
                child: Text(m.name[0],
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Flexible(child: Text(m.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827)))),
            ])),
            // Tier badge
            Expanded(child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: _tierColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.workspace_premium_rounded, size: 13, color: _tierColor),
                  const SizedBox(width: 4),
                  Text(m.tier, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _tierColor)),
                ]),
              ),
            )),
            // Points
            Expanded(child: Text('${_fmt(m.points)} pts',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF132935)))),
            // Status badge
            Expanded(child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF22C55E).withOpacity(0.1)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF22C55E) : const Color(0xFF8A959E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isActive ? const Color(0xFF16A34A) : const Color(0xFF6B7280),
                    ),
                  ),
                ]),
              ),
            )),
            // Delete button
            SizedBox(
              width: 48,
              child: _DeleteBtn(onTap: widget.onDelete),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delete button ─────────────────────────────────────────────────────────────
class _DeleteBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _DeleteBtn({required this.onTap});
  @override State<_DeleteBtn> createState() => _DeleteBtnState();
}
class _DeleteBtnState extends State<_DeleteBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 30, height: 28,
        decoration: BoxDecoration(
          color: _h ? const Color(0xFFEF4444) : const Color(0xFFFFE4E6),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _h ? const Color(0xFFEF4444) : const Color(0xFFFECACA)),
        ),
        child: Center(child: Icon(Icons.delete_outline_rounded, size: 14,
            color: _h ? Colors.white : const Color(0xFFEF4444))),
      ),
    ),
  );
}

// ── Data model ────────────────────────────────────────────────────────────────
class _Member {
  final String id, name, tier, status;
  final int points;
  const _Member({required this.id, required this.name, required this.tier, required this.points, required this.status});

  factory _Member.fromJson(Map<String, dynamic> j) => _Member(
    id:     j['user_id'] as String? ?? '',
    name:   j['name']    as String? ?? '',
    tier:   j['tier']    as String? ?? 'Bronze',
    points: (j['points'] as num?)?.toInt() ?? 0,
    status: j['status']  as String? ?? 'active',
  );
}