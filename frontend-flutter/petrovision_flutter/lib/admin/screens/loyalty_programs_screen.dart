
import 'package:flutter/material.dart';

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
    _LoyaltyPartner(
      partnerName: 'Petromin Cafe',
      rewardTitle: 'Free coffee reward',
      pointsRequired: 650,
      rewardValue: 'Free medium coffee',
      status: 'Active',
      customers: 1240,
    ),
    _LoyaltyPartner(
      partnerName: 'Quick Wash',
      rewardTitle: 'Car wash voucher',
      pointsRequired: 1200,
      rewardValue: 'Exterior wash',
      status: 'Active',
      customers: 880,
    ),
    _LoyaltyPartner(
      partnerName: 'AutoCare Plus',
      rewardTitle: 'Oil check discount',
      pointsRequired: 900,
      rewardValue: '15% off service',
      status: 'Draft',
      customers: 430,
    ),
  ];

  String _statusFilter = 'All';

  List<_LoyaltyPartner> get _filteredPartners {
    final query = _searchController.text.trim().toLowerCase();
    return _partners.where((partner) {
      final matchesStatus = _statusFilter == 'All' || partner.status == _statusFilter;
      final matchesQuery = query.isEmpty ||
          partner.partnerName.toLowerCase().contains(query) ||
          partner.rewardTitle.toLowerCase().contains(query) ||
          partner.rewardValue.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalCustomers = _partners.fold<int>(0, (sum, item) => sum + item.customers);
    final activePrograms = _partners.where((item) => item.status == 'Active').length;

    return AdminShell(
      selectedIndex: 1,
      title: 'Loyalty Programs',
      subtitle: 'Manage station partners, rewards, points, and redemption offers.',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Station Partners',
                  '${_partners.length}',
                  Icons.handshake_outlined,
                  'Connected reward partners',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _summaryCard(
                  'Customers Using Programs',
                  _compactNumber(totalCustomers),
                  Icons.people_alt_outlined,
                  'Across all active rewards',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _summaryCard(
                  'Active Programs',
                  '$activePrograms',
                  Icons.workspace_premium_outlined,
                  'Running loyalty campaigns',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _summaryCard(
                  'Rewards Redeemed',
                  '3.4K',
                  Icons.redeem_rounded,
                  'This quarter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Partner & Reward Programs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text(
                                  'Add station partners, define reward values, and manage current offers.',
                                  style: TextStyle(color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showPartnerDialog(),
                            style: darkDesktopButtonStyle().copyWith(
  padding: WidgetStatePropertyAll(
    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add New Partner'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: 'Search partner, reward, or offer',
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
                          const SizedBox(width: 14),
                          HoverSurface(
  child: Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(16),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _statusFilter,
        dropdownColor: const Color(0xFFEAF3F7),
        isExpanded: false,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF132935),
        ),

        style: const TextStyle(
          color: Color(0xFF132935),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),

        items: const [
          DropdownMenuItem(value: 'All', child: Text('All statuses')),
          DropdownMenuItem(value: 'Active', child: Text('Active')),
          DropdownMenuItem(value: 'Draft', child: Text('Draft')),
          DropdownMenuItem(value: 'Paused', child: Text('Paused')),
        ],

        onChanged: (value) {
          if (value == null) return;
          setState(() => _statusFilter = value);
        },
      ),
    ),
  ),
),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _tableHeader(),
                      ..._filteredPartners.map(_tableRow),
                      if (_filteredPartners.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                          ),
                          child: const Center(
                            child: Text('No loyalty programs match the current filter.', style: TextStyle(color: Color(0xFF6B7280))),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Program Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          SizedBox(height: 16),
                          _InsightTile(title: 'Top Partner', value: 'Petromin Cafe', subtitle: 'Most redeemed reward this month'),
                          _InsightTile(title: 'Best Reward Type', value: 'Fuel Discounts', subtitle: 'Highest conversion among members'),
                          _InsightTile(title: 'Low Engagement', value: 'Oil Check Discount', subtitle: 'Consider lowering required points'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          _ActionChip(label: 'Create seasonal offer', onTap: () => _showPartnerDialog(templateStatus: 'Draft')),
                          const SizedBox(height: 10),
                          _ActionChip(label: 'Review expiring rewards', onTap: () {}),
                          const SizedBox(height: 10),
                          _ActionChip(label: 'Adjust points for premium tiers', onTap: () {}),
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

  Widget _summaryCard(String title, String value, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
  BoxShadow(
    color: const Color(0xFF132935).withOpacity(0.05),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF3F4F6),
                child: Icon(icon, color: const Color(0xFF111827), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _tableHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: const Row(
          children: [
            Expanded(flex: 2, child: Text('Partner', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('Reward', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Points', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('Reward Value', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text('Members', style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Align(alignment: Alignment.centerRight, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700)))),
          ],
        ),
      );

  Widget _tableRow(_LoyaltyPartner item) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(item.partnerName, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(flex: 2, child: Text(item.rewardTitle)),
            Expanded(child: Text('${item.pointsRequired} pts')),
            Expanded(flex: 2, child: Text(item.rewardValue)),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.status == 'Active'
                        ? const Color(0xFF132935)
                        : item.status == 'Paused'
                            ? const Color(0xFF7FB3C8)
                            : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      color: item.status == 'Active' ? Colors.white : const Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Text(_compactNumber(item.customers))),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: _RowActionButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  onTap: () => _showPartnerDialog(existingPartner: item),
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _showPartnerDialog({_LoyaltyPartner? existingPartner, String templateStatus = 'Active'}) async {
    final isEditing = existingPartner != null;
    final nameController = TextEditingController(text: existingPartner?.partnerName ?? '');
    final rewardController = TextEditingController(text: existingPartner?.rewardTitle ?? '');
    final pointsController = TextEditingController(text: existingPartner?.pointsRequired.toString() ?? '');
    final valueController = TextEditingController(text: existingPartner?.rewardValue ?? '');
    String selectedStatus = existingPartner?.status ?? templateStatus;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Container(
                width: 620,
                padding: const EdgeInsets.all(24),
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
                              Text(
                                isEditing ? 'Edit Partner Program' : 'Add New Partner',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEditing
                                    ? 'Update points, reward details, or status for this partner program.'
                                    : 'Create a partner reward and add it to the current loyalty programs list.',
                                style: const TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        ),
                        _DialogIconButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _dialogField('Partner Name', nameController)),
                        const SizedBox(width: 14),
                        Expanded(child: _dialogField('Reward Title', rewardController)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _dialogField('Points Required', pointsController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 14),
                        Expanded(child: _dialogField('Reward Value', valueController)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Program Status', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                   HoverSurface(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
  child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
      value: selectedStatus,
      dropdownColor: const Color(0xFFEAF3F7),

      style: const TextStyle(
        color: Color(0xFF132935),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),

      items: const [
        DropdownMenuItem(value: 'Active', child: Text('Active')),
        DropdownMenuItem(value: 'Draft', child: Text('Draft')),
        DropdownMenuItem(value: 'Paused', child: Text('Paused')),
      ],

      onChanged: (value) {
        if (value == null) return;
        setModalState(() => selectedStatus = value);
      },
    ),
  ),
),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: outlinedDesktopButtonStyle(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty || rewardController.text.trim().isEmpty) {
                              return;
                            }
                            final updatedPartner = _LoyaltyPartner(
                              partnerName: nameController.text.trim(),
                              rewardTitle: rewardController.text.trim(),
                              pointsRequired: int.tryParse(pointsController.text.trim()) ?? 0,
                              rewardValue: valueController.text.trim().isEmpty ? 'Custom reward' : valueController.text.trim(),
                              status: selectedStatus,
                              customers: existingPartner?.customers ?? 0,
                            );
                            setState(() {
                              if (isEditing) {
                                final index = _partners.indexOf(existingPartner!);
                                if (index != -1) {
                                  _partners[index] = updatedPartner;
                                }
                              } else {
                                _partners.insert(0, updatedPartner);
                              }
                            });
                            Navigator.pop(context);
                          },
                          style: darkDesktopButtonStyle(),
                          child: Text(isEditing ? 'Update Partner' : 'Save Partner'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  String _compactNumber(int value) {
    if (value >= 1000) {
      final compact = value / 1000;
      return compact.toStringAsFixed(compact >= 10 ? 0 : 1) + 'K';
    }
    return value.toString();
  }
}

class _LoyaltyPartner {
  final String partnerName;
  final String rewardTitle;
  final int pointsRequired;
  final String rewardValue;
  final String status;
  final int customers;

  const _LoyaltyPartner({
    required this.partnerName,
    required this.rewardTitle,
    required this.pointsRequired,
    required this.rewardValue,
    required this.status,
    required this.customers,
  });
}

class _InsightTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _InsightTile({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.onTap});

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _RowActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _RowActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_RowActionButton> createState() => _RowActionButtonState();
}

class _RowActionButtonState extends State<_RowActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF132935) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovered ? const Color(0xFF132935) : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: _hovered ? Colors.white : const Color(0xFF111827)),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _hovered ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _DialogIconButton({required this.icon, required this.onTap});

  @override
  State<_DialogIconButton> createState() => _DialogIconButtonState();
}

class _DialogIconButtonState extends State<_DialogIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFFF3F4F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(widget.icon),
        ),
      ),
    );
  }
}
