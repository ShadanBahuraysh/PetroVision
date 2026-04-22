import 'package:flutter/material.dart';
import 'stations_page.dart';
import 'offers_page.dart'; 
import 'manage_profile_screen.dart';
import 'full_map_screen.dart';
import 'loyalty_dashboard_screen.dart';
import 'history_page.dart';
import 'earn_points_screen.dart';
import 'package:r/auth/welcome_screen.dart'; 
import 'about_us_screen.dart';
import 'terms_conditions_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final Color primaryNavy = const Color(0xFF1A2E35); 
  final Color accentBlue = const Color(0xFF4195AF);
  final Color scaffoldBg = const Color(0xFFFBFBFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scaffoldBg,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: primaryNavy),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "PETROVISION",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: primaryNavy),
            onPressed: () {},
          ),
        ],
      ),

      drawer: _buildCustomDrawer(),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeMainContent(),
          const StationsPage(),
          const LoyaltyDashboardScreen(),
          const OffersPage(),
        ],
      ),

      bottomNavigationBar: _buildBottomNav(),

      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: primaryNavy,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarnPointsScreen())),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.grid_view_rounded, "Home", 0),
              _navItem(Icons.map_outlined, "Stations", 1),
              const SizedBox(width: 40), 
              _navItem(Icons.stars_rounded, "Points", 2),
              _navItem(Icons.local_offer_outlined, "Offers", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? accentBlue : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? accentBlue : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryNavy),
            accountName: const Text("Raghad 👋", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: const Text("raghad@petrovision.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white, 
              child: Icon(Icons.person, color: Color(0xFF1A2E35), size: 35)
            ),
          ),
          _drawerItem(Icons.person_outline, "My Profile", () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageProfileScreen()));
          }),
          _drawerItem(Icons.receipt_long_outlined, "Transaction History", () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
          }),
          const Divider(),
_drawerItem(Icons.info_outline_rounded, "About Us", () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AboutUsScreen()),
  );
}),       
        _drawerItem(Icons.gavel_rounded, "Terms & Conditions", () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const TermsConditionsScreen()),
  );
}),
          _drawerItem(Icons.settings_outlined, "Settings", () {}),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent), 
            title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), 
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            }
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryNavy.withOpacity(0.7), size: 22),
      title: Text(
        title, 
        style: TextStyle(color: primaryNavy, fontWeight: FontWeight.w600, fontSize: 14)
      ),
      onTap: onTap,
    );
  }
}

class HomeMainContent extends StatelessWidget {
  const HomeMainContent({super.key});

  // دالة إظهار الباركود في منتصف الشاشة
  void _showBarcodePay(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4195AF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFF4195AF), size: 30),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Redeem Offer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A2E35)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Scan this code at the station",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 180, color: Color(0xFF1A2E35)),
                      const SizedBox(height: 10),
                      Text(
                        "PV-9928-110",
                        style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 140,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A2E35),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text("Close", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, Raghad", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
                  SizedBox(height: 4),
                  Text("Ready for a refill?", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              _buildPointsCard(),
            ],
          ),
          const SizedBox(height: 35),
          _buildMembershipCard(),
          const SizedBox(height: 40),
          const Text("Nearby Stations", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
          const SizedBox(height: 16),
          _buildMapCard(context),
          const SizedBox(height: 35),
          const Text("Special Offers", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
          const SizedBox(height: 12),
          _buildOfferItem(context, accentBlue), 
          const SizedBox(height: 120), 
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    const Color accentBlue = Color(0xFF4195AF);
    return Column(
      children: const [
        Text("750", style: TextStyle(color: accentBlue, fontWeight: FontWeight.w900, fontSize: 22
        )),
        Text("POINTS", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildMembershipCard() {
    const Color accentBlue = Color(0xFF4195AF);
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("BRONZE STATUS", style: TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          const Text("750 / 1,000", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
          const Text("Points to Silver Tier", style: TextStyle(color: Colors.black45, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: 0.75, backgroundColor: Colors.grey.shade200, color: accentBlue, minHeight: 8),
          ),
        ],
      ),
    );
  }

Widget _buildMapCard(BuildContext context) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: SizedBox(
      height: 170,
      width: double.infinity,
      child: Stack(
        children: [
          // معاينة الخريطة
const FullMapScreen(isPreview: true),
          
          // gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          
          // زر Explore
          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FullMapScreen())),
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text("Explore", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildOfferItem(BuildContext context, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 1.2), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.local_gas_station_rounded, color: accent),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Double Points Weekend", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                Text("On all fuel types", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showBarcodePay(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: accent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Text("Claim", style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}