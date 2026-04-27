import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/interactive_widgets.dart';

class LoyaltyProgramsScreen extends StatefulWidget {
  const LoyaltyProgramsScreen({super.key});

  @override
  State<LoyaltyProgramsScreen> createState() => _LoyaltyProgramsScreenState();
}

class _LoyaltyProgramsScreenState extends State<LoyaltyProgramsScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<_LoyaltyPartner> _partners = [
    _LoyaltyPartner(partnerName: 'Petromin Cafe',  rewardTitle: 'Free coffee reward',  pointsRequired: 650,  rewardValue: 'Free medium coffee', status: 'Active', customers: 1240),
    _LoyaltyPartner(partnerName: 'Quick Wash',     rewardTitle: 'Car wash voucher',     pointsRequired: 1200, rewardValue: 'Exterior wash',       status: 'Active', customers: 880),
    _LoyaltyPartner(partnerName: 'AutoCare Plus',  rewardTitle: 'Oil check discount',   pointsRequired: 900,  rewardValue: '15% off service',     status: 'Draft',  customers: 430),
  ];

  String _statusFilter = 'All';

  List<_LoyaltyPartner> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _partners.where((p) {
      final matchStatus = _statusFilter == 'All' || p.status == _statusFilter;
      final matchQuery  = q.isEmpty || p.partnerName.toLowerCase().contains(q) || p.rewardTitle.toLowerCase().contains(q) || p.rewardValue.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final totalCustomers  = _partners.fold<int>(0, (s, p) => s + p.customers);
    final activePrograms  = _partners.where((p) => p.status == 'Active').length;

    // Use same KpiItem/KpiCard as dashboard
    final kpis = [
      KpiItem(title: 'Station Partners',        value: '${_partners.length}',           change: '+1',    subtitle: 'Connected reward partners',  icon: Icons.handshake_outlined,          color: const Color(0xFF4195AF), chipColor: const Color(0xFF22C55E), isPositive: true),
      KpiItem(title: 'Customers Using Programs', value: _compactNum(totalCustomers),     change: '+12%',  subtitle: 'Across all active rewards',   icon: Icons.people_alt_outlined,         color: const Color(0xFF132935), chipColor: const Color(0xFF22C55E), isPositive: true),
      KpiItem(title: 'Active Programs',          value: '$activePrograms',               change: 'Live',  subtitle: 'Running loyalty campaigns',   icon: Icons.workspace_premium_outlined,  color: const Color(0xFF4195AF), chipColor: const Color(0xFF4195AF), isPositive: true),
      KpiItem(title: 'Rewards Redeemed',         value: '3.4K',                          change: '+8%',   subtitle: 'This quarter',                icon: Icons.redeem_rounded,              color: const Color(0xFF132935), chipColor: const Color(0xFF22C55E), isPositive: true),
    ];

    return AdminShell(
      selectedIndex: 1,
      title: 'Loyalty Programs',
      subtitle: 'Manage station partners, rewards, points, and redemption offers.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── KPI Row — responsive ────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;
            if (isNarrow) {
              return Column(children: [
                Row(children: List.generate(2, (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 0 ? 16 : 0),
                    child: _LoyaltyKpiCard(item: kpis[i]),
                  ),
                ))),
                const SizedBox(height: 16),
                Row(children: List.generate(2, (i) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == 0 ? 16 : 0),
                    child: _LoyaltyKpiCard(item: kpis[i + 2]),
                  ),
                ))),
              ]);
            }
            return Row(
              children: List.generate(kpis.length, (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == kpis.length - 1 ? 0 : 16),
                  child: _LoyaltyKpiCard(item: kpis[i]),
                ),
              )),
            );
          }),

          const SizedBox(height: 22),

          // ── Main content row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Table card
              Expanded(
                flex: 3,
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Partner & Reward Programs',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                                SizedBox(height: 4),
                                Text('Add station partners, define reward values, and manage current offers.',
                                  style: TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showDialog(),
                            style: darkDesktopButtonStyle().copyWith(
                              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add New Partner'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Search + filter
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search partner, reward, or offer',
                                hintStyle: const TextStyle(color: Color(0xFF8A959E), fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8A959E), size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF6F7F9),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          HoverSurface(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F9),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _statusFilter,
                                  dropdownColor: Colors.white,
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF132935)),
                                  style: const TextStyle(color: Color(0xFF132935), fontWeight: FontWeight.w600, fontSize: 14),
                                  items: const [
                                    DropdownMenuItem(value: 'All',    child: Text('All statuses')),
                                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                                    DropdownMenuItem(value: 'Draft',  child: Text('Draft')),
                                    DropdownMenuItem(value: 'Paused', child: Text('Paused')),
                                  ],
                                  onChanged: (v) { if (v != null) setState(() => _statusFilter = v); },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Table header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F7F9),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                        ),
                        child: const Row(
                          children: [
                            Expanded(flex: 2, child: _TH('Partner')),
                            Expanded(flex: 2, child: _TH('Reward')),
                            Expanded(child: _TH('Points')),
                            Expanded(flex: 2, child: _TH('Reward Value')),
                            Expanded(child: _TH('Status')),
                            Expanded(child: _TH('Members')),
                            Expanded(child: _TH('Actions')),
                          ],
                        ),
                      ),

                      // Rows
                      ..._filtered.map((p) => _PartnerRow(partner: p, onEdit: () => _showDialog(existing: p))),

                      if (_filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(child: Text('No programs match the current filter.', style: TextStyle(color: Color(0xFF8A959E)))),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Sidebar
              Expanded(
                child: Column(
                  children: [
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFF132935).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.insights_rounded, color: Color(0xFF132935), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text('Program Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _InsightTile(label: 'Top Partner',      value: 'Petromin Cafe',    sub: 'Most redeemed this month',       color: const Color(0xFF22C55E)),
                          _InsightTile(label: 'Best Reward Type', value: 'Fuel Discounts',   sub: 'Highest conversion among members', color: const Color(0xFF4195AF)),
                          _InsightTile(label: 'Low Engagement',   value: 'Oil Check Discount', sub: 'Consider lowering required points', color: const Color(0xFFEF4444)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFF4195AF).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                                child: const Icon(Icons.bolt_rounded, color: Color(0xFF4195AF), size: 18),
                              ),
                              const SizedBox(width: 12),
                              const Text('Admin Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ActionBtn(label: 'Create seasonal offer',           icon: Icons.celebration_outlined,      onTap: () => _showDialog(templateStatus: 'Draft')),
                          const SizedBox(height: 10),
                          _ActionBtn(label: 'Review expiring rewards',         icon: Icons.hourglass_bottom_rounded,  onTap: () {}),
                          const SizedBox(height: 10),
                          _ActionBtn(label: 'Adjust points for premium tiers', icon: Icons.tune_rounded,              onTap: () {}),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Dialog ────────────────────────────────────────────────────────────────

  Future<void> _showDialog({_LoyaltyPartner? existing, String templateStatus = 'Active'}) async {
    final isEdit           = existing != null;
    final nameCtrl         = TextEditingController(text: existing?.partnerName ?? '');
    final rewardCtrl       = TextEditingController(text: existing?.rewardTitle ?? '');
    final pointsCtrl       = TextEditingController(text: existing?.pointsRequired.toString() ?? '');
    final valueCtrl        = TextEditingController(text: existing?.rewardValue ?? '');
    String selectedStatus  = existing?.status ?? templateStatus;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isEdit ? 'Edit Partner Program' : 'Add New Partner',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF132935))),
                          const SizedBox(height: 4),
                          Text(isEdit ? 'Update reward details or status.' : 'Create a new partner reward program.',
                            style: const TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF8A959E)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _dlgField('Partner Name', nameCtrl)),
                  const SizedBox(width: 14),
                  Expanded(child: _dlgField('Reward Title', rewardCtrl)),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _dlgField('Points Required', pointsCtrl, isNumber: true)),
                  const SizedBox(width: 14),
                  Expanded(child: _dlgField('Reward Value', valueCtrl)),
                ]),
                const SizedBox(height: 14),
                const Text('Program Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6F7F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedStatus,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Color(0xFF132935), fontWeight: FontWeight.w600, fontSize: 14),
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Draft',  child: Text('Draft')),
                        DropdownMenuItem(value: 'Paused', child: Text('Paused')),
                      ],
                      onChanged: (v) { if (v != null) setModal(() => selectedStatus = v); },
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: outlinedDesktopButtonStyle(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty) return;
                        final updated = _LoyaltyPartner(
                          partnerName: nameCtrl.text.trim(),
                          rewardTitle: rewardCtrl.text.trim(),
                          pointsRequired: int.tryParse(pointsCtrl.text.trim()) ?? 0,
                          rewardValue: valueCtrl.text.trim().isEmpty ? 'Custom reward' : valueCtrl.text.trim(),
                          status: selectedStatus,
                          customers: existing?.customers ?? 0,
                        );
                        setState(() {
                          if (isEdit) { final i = _partners.indexOf(existing!); if (i != -1) _partners[i] = updated; }
                          else _partners.insert(0, updated);
                        });
                        Navigator.pop(ctx);
                      },
                      style: darkDesktopButtonStyle(),
                      child: Text(isEdit ? 'Update Partner' : 'Save Partner'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dlgField(String label, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : null,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF132935)),
          decoration: InputDecoration(
            filled: true, fillColor: const Color(0xFFF6F7F9),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF4195AF), width: 1.5)),
          ),
        ),
      ],
    );
  }

  String _compactNum(int v) {
    if (v >= 1000) { final c = v / 1000; return '${c.toStringAsFixed(c >= 10 ? 0 : 1)}K'; }
    return v.toString();
  }
}


// ── Loyalty KPI card (no dropdown filter) ───────────────────────────────────

class _LoyaltyKpiCard extends StatelessWidget {
  final KpiItem item;
  const _LoyaltyKpiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF132935).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8A959E))),
              ),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(item.value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF132935), letterSpacing: -0.3)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: item.chipColor, borderRadius: BorderRadius.circular(10)),
                child: Text(item.change,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.subtitle,
                  style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Table header cell ────────────────────────────────────────────────────────

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF8A959E)));
}

// ── Partner row ──────────────────────────────────────────────────────────────

class _PartnerRow extends StatefulWidget {
  final _LoyaltyPartner partner;
  final VoidCallback onEdit;
  const _PartnerRow({required this.partner, required this.onEdit});
  @override
  State<_PartnerRow> createState() => _PartnerRowState();
}

class _PartnerRowState extends State<_PartnerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.partner;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF6F7F9) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(p.partnerName,     style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF111827)))),
            Expanded(flex: 2, child: Text(p.rewardTitle,     style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
            Expanded(         child: Text('${p.pointsRequired} pts', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF132935)))),
            Expanded(flex: 2, child: Text(p.rewardValue,     style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
            Expanded(child: _StatusBadge(status: p.status)),
            Expanded(child: Text(_fmt(p.customers),          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151)))),
            Expanded(child: _EditBtn(onTap: widget.onEdit)),
          ],
        ),
      ),
    );
  }

  String _fmt(int v) { if (v >= 1000) { final c = v / 1000; return '${c.toStringAsFixed(c >= 10 ? 0 : 1)}K'; } return v.toString(); }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Active';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF132935) : const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(status,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF4B5563),
            fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EditBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _EditBtn({required this.onTap});
  @override
  State<_EditBtn> createState() => _EditBtnState();
}

class _EditBtnState extends State<_EditBtn> {
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _h ? const Color(0xFF132935) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _h ? const Color(0xFF132935) : const Color(0xFFE5E7EB)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_outlined, size: 14, color: _h ? Colors.white : const Color(0xFF374151)),
          const SizedBox(width: 5),
          Text('Edit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _h ? Colors.white : const Color(0xFF374151))),
        ]),
      ),
    ),
  );
}

// ── Insight tile ─────────────────────────────────────────────────────────────

class _InsightTile extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  const _InsightTile({required this.label, required this.value, required this.sub, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        Container(width: 4, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ── Action button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.onTap});
  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _h ? const Color(0xFF132935) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _h ? const Color(0xFF132935) : const Color(0xFFE5E7EB)),
        ),
        child: Row(children: [
          Icon(widget.icon, size: 16, color: _h ? Colors.white : const Color(0xFF4195AF)),
          const SizedBox(width: 10),
          Text(widget.label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: _h ? Colors.white : const Color(0xFF374151))),
        ]),
      ),
    ),
  );
}

// ── Data model ────────────────────────────────────────────────────────────────

class _LoyaltyPartner {
  final String partnerName, rewardTitle, rewardValue, status;
  final int pointsRequired, customers;
  const _LoyaltyPartner({required this.partnerName, required this.rewardTitle, required this.pointsRequired, required this.rewardValue, required this.status, required this.customers});
}
