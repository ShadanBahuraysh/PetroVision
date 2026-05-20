// ========================================================================================================
// PetroVision Loyalty Programs Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the LoyaltyProgramsScreen
// and related UI components used for managing
// loyalty offers and QR-code operations within
// the PetroVision admin dashboard.
//
// Features included:
// - Loading loyalty offers from the backend
// - Creating and editing loyalty offers
// - Displaying loyalty KPI statistics
// - Searching and filtering loyalty offers
// - Displaying offer status and reward details
// - Generating and displaying QR codes
// - Supporting earn and redeem QR workflows
// - Managing loyalty offer dialogs and forms
// - Handling API request and loading states
// - Providing interactive dashboard UI components
//
// It also integrates loyalty-program APIs,
// QR-code workflows, and offer-management
// functionality within the PetroVision platform.
// ========================================================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import '../models/dashboard_models.dart';
import '../widgets/admin_shell.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/interactive_widgets.dart';

const String _baseUrl = 'http://localhost:8000';

class LoyaltyProgramsScreen extends StatefulWidget {
  const LoyaltyProgramsScreen({super.key});
  @override
  State<LoyaltyProgramsScreen> createState() => _LoyaltyProgramsScreenState();
}

class _LoyaltyProgramsScreenState extends State<LoyaltyProgramsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<_Offer> _offers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await http.get(Uri.parse('$_baseUrl/offers/'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _offers = data.map((o) => _Offer.fromJson(o)).toList();
          _loading = false;
        });
      } else {
        setState(() { _error = 'Failed to load offers (${res.statusCode})'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Could not reach server'; _loading = false; });
    }
  }

  String _statusFilter = 'All';

  List<_Offer> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _offers.where((o) {
      final matchStatus = _statusFilter == 'All' || o.status == _statusFilter;
      final matchQuery  = q.isEmpty || o.name.toLowerCase().contains(q) ||
          o.category.toLowerCase().contains(q) || o.earnQr.toLowerCase().contains(q);
      return matchStatus && matchQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _offers.where((o) => o.status == 'Active').length;
    final kpis = [
      KpiItem(title: 'Total Offers',     value: '${_offers.length}', change: '+1',   subtitle: 'In the system',             icon: Icons.local_offer_outlined,       color: const Color(0xFF4195AF), chipColor: const Color(0xFF22C55E), isPositive: true),
      KpiItem(title: 'Active Offers',    value: '$activeCount',      change: 'Live', subtitle: 'Running loyalty campaigns', icon: Icons.workspace_premium_outlined, color: const Color(0xFF132935), chipColor: const Color(0xFF4195AF), isPositive: true),
      KpiItem(title: 'Rewards Redeemed', value: '3.4K',              change: '+8%',  subtitle: 'This quarter',              icon: Icons.redeem_rounded,             color: const Color(0xFF4195AF), chipColor: const Color(0xFF22C55E), isPositive: true),
      KpiItem(title: 'QR Codes Active',  value: '${activeCount * 2}',change: 'Auto', subtitle: 'Earn + redeem per offer',   icon: Icons.qr_code_2_rounded,          color: const Color(0xFF132935), chipColor: const Color(0xFF4195AF), isPositive: true),
    ];

    return AdminShell(
      selectedIndex: 1,
      title: 'Loyalty Programs',
      subtitle: 'Manage offers, points, and QR codes for earn and redeem.',
      showExportButton: false,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF132935)))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFF8A959E)),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Color(0xFF8A959E))),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _loadOffers, style: darkDesktopButtonStyle(), child: const Text('Retry')),
                ]))
              : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI row
          Row(
            children: List.generate(kpis.length, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < kpis.length - 1 ? 16 : 0),
                child: _KpiCard(item: kpis[i]),
              ),
            )),
          ),
          const SizedBox(height: 22),

          // Table + sidebar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Expanded(flex: 3, child: _tableCard()),
                const SizedBox(width: 20),
                IntrinsicWidth(child: _sidebar()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableCard() {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Offers & QR Codes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              SizedBox(height: 4),
              Text('Each offer has an auto-generated earn QR (for receipts) and redeem QR (for station).',
                  style: TextStyle(color: Color(0xFF8A959E), fontSize: 13)),
            ])),
            FilledButton.icon(
              onPressed: () => _showDialog(),
              style: darkDesktopButtonStyle().copyWith(
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 16))),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Offer'),
            ),
          ]),
          const SizedBox(height: 16),

          // Search + filter
          Row(children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search offer, category, or QR code',
                  hintStyle: const TextStyle(color: Color(0xFF8A959E), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8A959E), size: 20),
                  filled: true, fillColor: const Color(0xFFF6F7F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 48, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter, dropdownColor: Colors.white,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF132935)),
                  style: const TextStyle(color: Color(0xFF132935), fontWeight: FontWeight.w600, fontSize: 14),
                  items: ['All','Active','Draft','Paused','Inactive']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s == 'All' ? 'All statuses' : s))).toList(),
                  onChanged: (v) { if (v != null) setState(() => _statusFilter = v); },
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF6F7F9),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: const Row(children: [
              _TH('Offer',      flex: 3),
              _TH('Category',   flex: 2),
              _TH('Earn pts',   flex: 2),
              _TH('Redeem pts', flex: 2),
              _TH('Min tier',   flex: 2),
              _TH('Status',     flex: 2),
              _TH('QR codes',   flex: 3),
              _TH('View',       flex: 1),
              _TH('Edit',       flex: 1),
            ]),
          ),

          // Data rows
          ..._filtered.map((o) => _OfferRow(offer: o, onEdit: () => _showDialog(existing: o))),
          if (_filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No offers match.', style: TextStyle(color: Color(0xFF8A959E)))),
            ),
        ],
      ),
    );
  }

  Widget _sidebar() {
    return SectionCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF132935).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.info_outline_rounded, color: Color(0xFF132935), size: 18)),
          const SizedBox(width: 12),
          const Expanded(child: Text('How QR codes work',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)))),
        ]),
        const SizedBox(height: 14),
        _qrTile('Earn QR',        'On the receipt',    'Customer scans to add points', const Color(0xFF4195AF)),
        const SizedBox(height: 8),
        _qrTile('Redeem QR',      'At the station',    'Customer scans to use points', const Color(0xFF22C55E)),
        const SizedBox(height: 8),
        _qrTile('Auto-generated', 'On offer creation', 'No manual input needed',       const Color(0xFF8A959E)),
      ]),
    );
  }

  Widget _qrTile(String label, String title, String sub, Color color) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 3, height: 44, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 11, fontWeight: FontWeight.w600)),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        Text(sub,   style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12)),
      ])),
    ]);
  }

  Future<void> _showDialog({_Offer? existing}) async {
    final isEdit     = existing != null;
    final nameCtrl   = TextEditingController(text: existing?.name ?? '');
    String category  = existing?.category ?? 'Fuel';
    final earnCtrl   = TextEditingController(text: existing != null ? existing.earnPts.toString() : '');
    final redeemCtrl = TextEditingController(text: existing != null ? existing.redeemPts.toString() : '');
    String minTier   = existing?.minTier ?? 'Bronze';
    String status    = existing?.status ?? 'Active';

    // Per-field error strings
    String? nameError;
    String? earnError;
    String? redeemError;

    // ── Validators (closures — required for Flutter Web / JS) ──────────────────
    final validateName = (String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return 'Offer name is required.';
      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(trimmed)) return 'Name must contain letters only — no numbers or special characters.';
      final isDuplicate = _offers.any((o) =>
          o.name.trim().toLowerCase() == trimmed.toLowerCase() &&
          o.offerId != existing?.offerId);
      if (isDuplicate) return 'An offer with this name already exists.';
      return null;
    };

    final validatePoints = (String value, String fieldLabel) {
      if (value.trim().isEmpty) return '$fieldLabel is required.';
      final parsed = int.tryParse(value.trim());
      if (parsed == null) return '$fieldLabel must be a whole number.';
      if (parsed < 0) return '$fieldLabel cannot be negative.';
      return null;
    };

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(width: 520, padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Header ───────────────────────────────────────────────────────
            Row(children: [
              Expanded(child: Text(isEdit ? 'Edit Offer' : 'Add Offer',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF132935)))),
              IconButton(onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF8A959E))),
            ]),
            const SizedBox(height: 20),

            // ── Row 1: Name + Category ────────────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _dlgFieldValidated(
                label: 'Offer Name',
                ctrl: nameCtrl,
                errorText: nameError,
                onChanged: (v) => set(() => nameError = validateName(v)),
              )),
              const SizedBox(width: 12),
              Expanded(child: _dlgDropdown(
                label: 'Category',
                value: category,
                items: ['Fuel','Coffee','Food','Services','Bonus','Other'],
                onChanged: (v) { if (v != null) set(() => category = v); },
              )),
            ]),
            const SizedBox(height: 12),

            // ── Row 2: Earn pts + Redeem pts ──────────────────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _dlgFieldValidated(
                label: 'Earn Points',
                ctrl: earnCtrl,
                isNumber: true,
                errorText: earnError,
                hint: '0 or more',
                onChanged: (v) => set(() => earnError = validatePoints(v, 'Earn Points')),
              )),
              const SizedBox(width: 12),
              Expanded(child: _dlgFieldValidated(
                label: 'Redeem Points',
                ctrl: redeemCtrl,
                isNumber: true,
                errorText: redeemError,
                hint: '0 or more',
                onChanged: (v) => set(() => redeemError = validatePoints(v, 'Redeem Points')),
              )),
            ]),
            const SizedBox(height: 12),

            // ── Row 3: Min Tier dropdown + Status dropdown ────────────────────
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _dlgDropdown(
                label: 'Min Tier',
                value: minTier,
                items: ['Bronze', 'Silver', 'Gold'],
                onChanged: (v) { if (v != null) set(() => minTier = v); },
              )),
              const SizedBox(width: 12),
              Expanded(child: _dlgDropdown(
                label: 'Status',
                value: status,
                items: ['Active','Draft','Paused','Inactive'],
                onChanged: (v) { if (v != null) set(() => status = v); },
              )),
            ]),
            const SizedBox(height: 24),

            // ── Actions ───────────────────────────────────────────────────────
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: outlinedDesktopButtonStyle(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: darkDesktopButtonStyle(),
                onPressed: () async {
                  // Run all validators on submit
                  set(() {
                    nameError   = validateName(nameCtrl.text);
                    earnError   = validatePoints(earnCtrl.text, 'Earn Points');
                    redeemError = validatePoints(redeemCtrl.text, 'Redeem Points');
                  });
                  if (nameError != null || earnError != null || redeemError != null) return;

                  Navigator.pop(ctx);

                  final body = jsonEncode({
                    'name':          nameCtrl.text.trim(),
                    'category':      category,
                    'earn_points':   int.parse(earnCtrl.text.trim()),
                    'redeem_points': int.parse(redeemCtrl.text.trim()),
                    'min_tier':      minTier,
                    'offer_type':    category,
                    'status':        status,
                  });

                  final res = existing != null && existing.offerId != null
                      ? await http.put(
                          Uri.parse('$_baseUrl/offers/${existing.offerId}'),
                          headers: {'Content-Type': 'application/json'},
                          body: body,
                        )
                      : await http.post(
                          Uri.parse('$_baseUrl/offers/'),
                          headers: {'Content-Type': 'application/json'},
                          body: body,
                        );

                  if (!mounted) return;

                  if (res.statusCode == 200 || res.statusCode == 201) {
                    _loadOffers();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Offer updated successfully.' : 'Offer created successfully.')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save offer. (${res.statusCode})')),
                    );
                  }
                },
                child: Text(isEdit ? 'Update' : 'Save'),
              ),
            ]),
          ]),
        ),
      )),
    );
  }

  Widget _dlgFieldValidated(
      {required String label,
      required TextEditingController ctrl,
      bool isNumber = false,
      String? errorText,
      String? hint,
      void Function(String)? onChanged}) {
    final hasError = errorText != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const Text(' *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFEF4444))),
      ]),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : null,
        onChanged: onChanged,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF132935)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 13),
          filled: true,
          fillColor: hasError ? const Color(0xFFFFF1F1) : const Color(0xFFF6F7F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: hasError
                  ? const BorderSide(color: Color(0xFFEF4444), width: 1.5)
                  : BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: hasError ? const Color(0xFFEF4444) : const Color(0xFF4195AF),
                  width: 1.5)),
          errorText: null, // we render it manually below
        ),
      ),
      if (hasError) ...[
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFEF4444)),
          const SizedBox(width: 4),
          Expanded(child: Text(errorText, style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)))),
        ]),
      ],
    ]);
  }

  Widget _dlgDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151))),
        const Text(' *', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFFEF4444))),
      ]),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Color(0xFF132935), fontWeight: FontWeight.w600, fontSize: 14),
            items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ]);
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final KpiItem item;
  const _KpiCard({required this.item});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFE5E7EB)),
      boxShadow: [BoxShadow(color: const Color(0xFF132935).withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8A959E)))),
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(12)),
          child: Icon(item.icon, color: item.color, size: 20)),
      ]),
      const SizedBox(height: 16),
      Text(item.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF132935))),
      const SizedBox(height: 10),
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: item.chipColor, borderRadius: BorderRadius.circular(8)),
          child: Text(item.change, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11))),
        const SizedBox(width: 8),
        Expanded(child: Text(item.subtitle, style: const TextStyle(color: Color(0xFF8A959E), fontSize: 12))),
      ]),
    ]),
  );
}

class _TH extends StatelessWidget {
  final String text; final int flex;
  const _TH(this.text, {required this.flex});
  @override
  Widget build(BuildContext context) => Expanded(flex: flex,
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF8A959E))));
}

class _OfferRow extends StatefulWidget {
  final _Offer offer; final VoidCallback onEdit;
  const _OfferRow({required this.offer, required this.onEdit});
  @override State<_OfferRow> createState() => _OfferRowState();
}
class _OfferRowState extends State<_OfferRow> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF6F7F9) : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
        child: Row(children: [
          Expanded(flex: 3, child: Text(o.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF111827)))),
          Expanded(flex: 2, child: Text(o.category, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
          Expanded(flex: 2, child: Text('${o.earnPts} pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF4195AF)))),
          Expanded(flex: 2, child: Text('${o.redeemPts} pts', style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
          Expanded(flex: 2, child: Text(o.minTier, style: const TextStyle(fontSize: 12, color: Color(0xFF374151)))),
          Expanded(flex: 2, child: _StatusBadge(status: o.status)),
          Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            _QrChip(code: o.earnQr,   color: const Color(0xFF4195AF)),
            const SizedBox(height: 3),
            _QrChip(code: o.redeemQr, color: const Color(0xFF132935)),
          ])),
          Expanded(flex: 1, child: Center(child: _ViewQrBtn(offer: o))),
          Expanded(flex: 1, child: Center(child: _EditBtn(onTap: widget.onEdit))),
        ]),
      ),
    );
  }
}

class _QrChip extends StatelessWidget {
  final String code; final Color color;
  const _QrChip({required this.code, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.qr_code_rounded, size: 10, color: color), const SizedBox(width: 3),
      Text(code, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) {
    Color bg; Color fg;
    switch (status) {
      case 'Active': bg = const Color(0xFF132935); fg = Colors.white; break;
      case 'Draft':  bg = const Color(0xFFF6F7F9); fg = const Color(0xFF4B5563); break;
      case 'Paused': bg = const Color(0xFFFEF3C7); fg = const Color(0xFFB45309); break;
      default:       bg = const Color(0xFFE5E7EB); fg = const Color(0xFF6B7280);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(status, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w700))),
    );
  }
}

class _ViewQrBtn extends StatefulWidget {
  final _Offer offer;
  const _ViewQrBtn({required this.offer});
  @override State<_ViewQrBtn> createState() => _ViewQrBtnState();
}
class _ViewQrBtnState extends State<_ViewQrBtn> {
  bool _h = false;
  void _open() {
    showDialog(
      context: context,
      builder: (_) => _QrPopup(offer: widget.offer),
    );
  }
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(onTap: _open,
      child: AnimatedContainer(duration: const Duration(milliseconds: 120),
        width: 30, height: 28,
        decoration: BoxDecoration(
          color: _h ? const Color(0xFF4195AF) : const Color(0xFF4195AF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _h ? const Color(0xFF4195AF) : const Color(0xFF4195AF).withOpacity(0.25))),
        child: Center(child: Icon(Icons.qr_code_rounded, size: 14, color: _h ? Colors.white : const Color(0xFF4195AF))),
      ),
    ),
  );
}

class _QrPopup extends StatelessWidget {
  final _Offer offer;
  const _QrPopup({required this.offer});

  Widget _qrBlock(String label, String code, Color color, IconData icon) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          // Real scannable QR code
          QrImageView(
            data: code,
            version: QrVersions.auto,
            size: 120,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: color,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: color,
            ),
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.qr_code_rounded, size: 12, color: Colors.white),
              const SizedBox(width: 5),
              Text(code, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFF132935).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF132935), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(offer.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
              const Text('QR Codes', style: TextStyle(fontSize: 12, color: Color(0xFF8A959E))),
            ])),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Color(0xFF8A959E)),
            ),
          ]),
          const SizedBox(height: 6),
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 20),
          // Two QR codes side by side
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _qrBlock('Earn QR — On the receipt',   offer.earnQr,   const Color(0xFF4195AF), Icons.receipt_outlined),
            Container(width: 1, height: 180, color: const Color(0xFFE5E7EB)),
            _qrBlock('Redeem QR — At the station', offer.redeemQr, const Color(0xFF132935), Icons.storefront_outlined),
          ]),
          const SizedBox(height: 24),
          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF6F7F9), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF8A959E)),
              const SizedBox(width: 8),
              const Expanded(child: Text(
                'Earn QR is printed on receipts. Redeem QR is placed at the station.',
                style: TextStyle(fontSize: 12, color: Color(0xFF8A959E)),
              )),
            ]),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF132935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _EditBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _EditBtn({required this.onTap});
  @override State<_EditBtn> createState() => _EditBtnState();
}
class _EditBtnState extends State<_EditBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit:  (_) => setState(() => _h = false),
    child: GestureDetector(onTap: widget.onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 120),
        width: 30, height: 28,
        decoration: BoxDecoration(
          color: _h ? const Color(0xFF132935) : const Color(0xFFF6F7F9),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _h ? const Color(0xFF132935) : const Color(0xFFE5E7EB))),
        child: Center(child: Icon(Icons.edit_outlined, size: 14, color: _h ? Colors.white : const Color(0xFF374151))),
      ),
    ),
  );
}

// ── Models ────────────────────────────────────────────────────────────────────
class _Offer {
  final String? offerId;
  final String name, category, minTier, status, earnQr, redeemQr;
  final int earnPts, redeemPts;
  const _Offer({
    this.offerId,
    required this.name, required this.category, required this.earnPts,
    required this.redeemPts, required this.minTier, required this.status,
    required this.earnQr, required this.redeemQr,
  });

  factory _Offer.fromJson(Map<String, dynamic> j) => _Offer(
    offerId:   j['offer_id']      as String?,
    name:      j['name']          as String? ?? j['offer_type'] as String? ?? '',
    category:  j['category']      as String? ?? '',
    earnPts:   (j['earn_points']  as num?)?.toInt() ?? 0,
    redeemPts: (j['redeem_points']as num?)?.toInt() ?? 0,
    minTier:   j['min_tier']      as String? ?? 'Bronze',
    status:    j['status']        as String? ?? 'Active',
    earnQr:    j['earn_qr_code']       as String? ?? '',
    redeemQr:  j['redeem_qr_code']     as String? ?? '',
  );
}