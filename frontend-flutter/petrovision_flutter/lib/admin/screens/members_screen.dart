import 'package:flutter/material.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<_Member> _members = const [
    _Member(id: 'M001', name: 'Abeer Ahmed',  tier: 'Gold',   points: 12440, status: 'Active'),
    _Member(id: 'M002', name: 'Sara Khalid',  tier: 'Silver', points: 8920,  status: 'Active'),
    _Member(id: 'M003', name: 'Nora Hamed',   tier: 'Bronze', points: 3110,  status: 'Inactive'),
    _Member(id: 'M004', name: 'Layan Omar',   tier: 'Gold',   points: 14050, status: 'Active'),
    _Member(id: 'M005', name: 'Reem Faisal',  tier: 'Silver', points: 6780,  status: 'Active'),
    _Member(id: 'M006', name: 'Dana Yousuf',  tier: 'Bronze', points: 1940,  status: 'Inactive'),
  ];

  List<_Member> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return _members;
    return _members.where((m) =>
      m.name.toLowerCase().contains(q) ||
      m.id.toLowerCase().contains(q) ||
      m.tier.toLowerCase().contains(q),
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = _members.where((m) => m.status == 'Active').length;
    final gold   = _members.where((m) => m.tier == 'Gold').length;
    final silver = _members.where((m) => m.tier == 'Silver').length;
    final bronze = _members.where((m) => m.tier == 'Bronze').length;

    return AdminShell(
      selectedIndex: 2,
      title: 'Members',
      subtitle: 'Track member activity, tiers, and recent engagement.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // KPI Row — responsive
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            final cards = [
              _KpiCard(title: 'Total Members',   value: '${_members.length}', icon: Icons.people_alt_outlined,          sub: 'Registered accounts',  color: const Color(0xFF4195AF)),
              _KpiCard(title: 'Active Members',  value: '$active',            icon: Icons.check_circle_outline_rounded,  sub: 'Currently active',     color: const Color(0xFF22C55E)),
              _KpiCard(title: 'Gold Members',    value: '$gold',              icon: Icons.workspace_premium_outlined,    sub: 'Highest tier',         color: const Color(0xFFF59E0B)),
              _KpiCard(title: 'Silver & Bronze', value: '${silver + bronze}', icon: Icons.star_half_rounded,             sub: 'Lower tier members',   color: const Color(0xFF8A959E)),
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

                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Member Directory',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                          SizedBox(height: 4),
                          Text('All registered loyalty members and their current tier status.',
                            style: TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 260,
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
                  ],
                ),

                const SizedBox(height: 20),

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
                    ],
                  ),
                ),

                ..._filtered.map((m) => _MemberRow(member: m)),

                if (_filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No members match your search.',
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
}

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
          Row(
            children: [
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8A959E)))),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF132935), letterSpacing: -0.3)),
          const SizedBox(height: 8),
          Text(sub, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
        ],
      ),
    ),
  );
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF8A959E)));
}

class _MemberRow extends StatefulWidget {
  final _Member member;
  const _MemberRow({required this.member});
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
            Expanded(child: Text(m.id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8A959E)))),
            Expanded(flex: 2, child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: const Color(0xFF132935),
                  child: Text(m.name[0], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                const SizedBox(width: 10),
                Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF111827))),
              ],
            )),
            Expanded(child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _tierColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.workspace_premium_rounded, size: 13, color: _tierColor),
                  const SizedBox(width: 4),
                  Text(m.tier, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _tierColor)),
                ]),
              ),
            )),
            Expanded(child: Text('${_fmt(m.points)} pts',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF132935)))),
            Expanded(child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: m.status == 'Active' ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.status == 'Active' ? const Color(0xFF22C55E) : const Color(0xFF8A959E))),
                  const SizedBox(width: 6),
                  Text(m.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: m.status == 'Active' ? const Color(0xFF16A34A) : const Color(0xFF6B7280))),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _Member {
  final String id, name, tier, status;
  final int points;
  const _Member({required this.id, required this.name, required this.tier, required this.points, required this.status});
}
