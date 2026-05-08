import 'package:flutter/material.dart';
import '../../auth/welcome_screen.dart';
import 'interactive_widgets.dart';

class AdminShell extends StatelessWidget {
  final int selectedIndex;
  final String title;
  final String subtitle;
  final Widget child;
  final bool showExportButton;
  final VoidCallback? onExport;

  const AdminShell({
  super.key,
  required this.selectedIndex,
  required this.title,
  required this.subtitle,
  required this.child,

  this.showExportButton = true,
  this.onExport,
});

  static const List<_NavItem> _items = [
    _NavItem(label: 'Dashboard', icon: Icons.insert_chart_outlined_rounded, route: '/dashboard'),
    _NavItem(label: 'Loyalty Programs', icon: Icons.workspace_premium_outlined, route: '/loyalty'),
    _NavItem(label: 'Members', icon: Icons.groups_2_outlined, route: '/members'),
    _NavItem(label: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1100),
            child: SizedBox(
              width: MediaQuery.of(context).size.width < 1100
                  ? 1100
                  : MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
              child: Row(
          children: [
            /// SIDEBAR
            Container(
              width: 246,
              color: const Color(0xFF132935),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
    width: double.infinity,
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.only(top: 6, bottom: 2),
    child: Image.asset(
      'assets/images/AdminPageLogo.png',
      height: 75,
      fit: BoxFit.contain,
    ),
  ),
  Divider(
    color: Colors.grey.withOpacity(0.2),
    thickness: 1,
    height: 15,
  ),
  const SizedBox(height: 10),

                  ...List.generate(_items.length, (index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SidebarNavTile(
                        item: item,
                        isSelected: index == selectedIndex,
                        onTap: () {
                          if (ModalRoute.of(context)?.settings.name != item.route) {
                            Navigator.pushReplacementNamed(context, item.route);
                          }
                        },
                      ),
                    );
                  }),

                  const Spacer(),

                   _AccountSection(
                  ),
                ],
              ),
            ),

            /// MAIN CONTENT
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF6F7F9),
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF132935))),
                              const SizedBox(height: 6),
                              Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Color(0xFF8A959E))),
                            ],
                          ),
                        ),
                        if (showExportButton)
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: FilledButton.icon(
  onPressed: onExport,
  style: darkDesktopButtonStyle().copyWith(
    backgroundColor: const WidgetStatePropertyAll(Color(0xFF132935)),
    foregroundColor: const WidgetStatePropertyAll(Colors.white),
  ),
  icon: const Icon(Icons.download_rounded, size: 18),
  label: const Text('Export'), 
),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final contentWidth = constraints.maxWidth < 900
                            ? 900.0
                            : constraints.maxWidth;
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: contentWidth,
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        ),
      ),
    ),
    );
  }
}

class _AccountSection extends StatefulWidget {
  
    _AccountSection();

  @override
  State<_AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<_AccountSection> {
  OverlayEntry? _overlayEntry;
  bool _isHoveringMenu = false;
  bool _hoveringCard = false;

  void _showMenu() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox?;
    if (overlay == null || box == null) return;

    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + size.width - 150,
        top: position.dy - 54,
        child: MouseRegion(
          onEnter: (_) => _isHoveringMenu = true,
          onExit: (_) {
            _isHoveringMenu = false;
            _hideMenuDelayed();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 150,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF132935),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12),
                ],
              ),

              child: _LogoutTile(onTap: _logout),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideMenuDelayed() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!_isHoveringMenu) _hideMenu();
    });
  }

  void _hideMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _logout() {
    _hideMenu();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _hoveringCard = true;
        _showMenu();
        setState(() {});
      },
      onExit: (_) {
        _hoveringCard = false;
        _hideMenuDelayed();
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _hoveringCard
              ? Colors.white.withOpacity(0.15)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
child: Row(
  children: [
    CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.person_outline_rounded,
        color: Color(0xFF132935),
      ),
    ),

    SizedBox(width: 12),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Admin",
            style: TextStyle(color: Colors.white),
          ),

          SizedBox(height: 2),

          Text(
            "Hidden Email",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ],
),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _hovered ? Colors.white.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text("Logout", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarNavTile extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavTile> createState() => _SidebarNavTileState();
}

class _SidebarNavTileState extends State<_SidebarNavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final bgColor = isSelected
        ? Colors.white
        : _hovered
            ? Colors.white.withOpacity(0.10)
            : Colors.transparent;

    final fgColor = isSelected
        ? const Color(0xFF111827)
        : (_hovered ? Colors.white : Colors.white70);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            hoverColor: Colors.white.withOpacity(0.06),
            splashColor: Colors.white.withOpacity(0.08),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(widget.item.icon, size: 21, color: fgColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: fgColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandIcon extends StatelessWidget {
  const _BrandIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 20),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}