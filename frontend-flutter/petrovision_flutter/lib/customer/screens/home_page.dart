// ========================================================================================================
// PetroVision Home Page
// --------------------------------------------------------------------------------------------------------
// This file defines the HomePage and HomeMainContent
// used as the primary customer dashboard interface
// within the PetroVision platform.
//
// Features included:
// - Displaying customer dashboard and loyalty data
// - Managing navigation between application sections
// - Displaying nearby stations on interactive maps
// - Loading offers and loyalty membership information
// - Supporting QR-code earning and redemption workflows
// - Supporting multilingual localization and language switching
// - Displaying nearest fuel stations using geolocation services
// - Opening external navigation applications
// - Managing loading, API, and location states
// - Providing responsive dashboard and drawer UI components
//
// It also integrates loyalty APIs,
// map visualization workflows,
// geolocation services,
// station-navigation functionality,
// and customer dashboard operations
// within the PetroVision platform.
// ========================================================================================================
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:r/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
import '../../services/loyalty_api_service.dart';
import '../../core/language_controller.dart';
import 'confirm_redemption_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String userId;
  final String name;
  final String email;

  const HomePage({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const Color _primaryNavy = Color(0xFF1A2E35);
  static const Color _accentBlue = Color(0xFF4195AF);
  static const Color _scaffoldBg = Color(0xFFFBFBFB);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langController = context.watch<LanguageController>();

    return Scaffold(
      backgroundColor: _scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _scaffoldBg,
        centerTitle: true,
        leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: _primaryNavy),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
        automaticallyImplyLeading: false,
        title: Text(
  _currentIndex == 0
      ? "PETROVISION"
      : _currentIndex == 1
          ? "STATIONS"
          : _currentIndex == 2
              ? "LOYALTY PROGRAM"
              : "OFFERS",
          style: const TextStyle(
            color: _primaryNavy,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      drawer: _buildCustomDrawer(context, l10n, langController),
      body:  _currentIndex == 0
    ? HomeMainContent(
        key: UniqueKey(),
        userId: widget.userId,
        name: widget.name,
      )
    : _currentIndex == 1
        ? const StationsPage()
        : _currentIndex == 2
            ? LoyaltyDashboardScreen(
                key: UniqueKey(),
                userId: widget.userId,
              )
            : OffersPage(userId: widget.userId),

      bottomNavigationBar: _buildBottomNav(l10n),
      floatingActionButton: FloatingActionButton(
        elevation: 4,
        backgroundColor: _primaryNavy,
        onPressed: () => Navigator.push(
          context,
      MaterialPageRoute(
  builder: (_) => EarnPointsScreen(
    userId: widget.userId,
  ),
),        ),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 8, offset: const Offset(0, -1))],
      ),
      child: BottomAppBar(
        color: const Color.fromARGB(155, 245, 245, 245),
        surfaceTintColor: const Color.fromARGB(155, 245, 245, 245),
        shadowColor: Colors.transparent,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.grid_view_rounded, l10n.navHome, 0),
              _navItem(Icons.map_outlined, l10n.navStations, 1),
              const SizedBox(width: 40),
              _navItem(Icons.stars_rounded, l10n.navPoints, 2),
              _navItem(Icons.local_offer_outlined, l10n.navOffers, 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? _accentBlue : const Color(0xFFB0B8C1), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: isSelected ? _accentBlue : const Color(0xFFB0B8C1),
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
        ],
      ),
    );
  }

  Widget _buildCustomDrawer(BuildContext context, AppLocalizations l10n, LanguageController langController) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: _primaryNavy),
            accountName: Text("${widget.name} 👋", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(widget.email),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: _primaryNavy, size: 35),
            ),
          ),
          _drawerItem(Icons.person_outline, l10n.drawerMyProfile, () {
            Navigator.push(context, MaterialPageRoute(
  builder: (_) => ManageProfileScreen(
    userId: widget.userId,
    name: widget.name,
    email: widget.email,
  ),
),);
          }),
          _drawerItem(Icons.receipt_long_outlined, l10n.drawerTransactionHistory, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>  HistoryPage(  userId: widget.userId,
)));
          }),
          const Divider(height: 1),
          _buildLanguageToggle(context, l10n, langController),
          const Divider(height: 1),
          _drawerItem(Icons.info_outline_rounded, l10n.drawerAboutUs, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()));
          }),
          _drawerItem(Icons.gavel_rounded, l10n.drawerTermsConditions, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsConditionsScreen()));
          }),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(l10n.drawerLogout, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context, AppLocalizations l10n, LanguageController langController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.drawerLanguage, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
          const SizedBox(height: 10),
          Container(
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF0F4F6), borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                _langSegment(label: "EN", isSelected: !langController.isArabic,
                  onTap: () => context.read<LanguageController>().setLocale(const Locale('en'))),
                _langSegment(label: "AR", isSelected: langController.isArabic,
                  onTap: () => context.read<LanguageController>().setLocale(const Locale('ar'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langSegment({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? _primaryNavy : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: _primaryNavy.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 2))] : null,
          ),
          child: Center(
            child: Text(label, style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 0.5,
            )),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: _primaryNavy.withOpacity(0.7), size: 22),
      title: Text(title, style: const TextStyle(color: _primaryNavy, fontWeight: FontWeight.w600, fontSize: 14)),
      onTap: onTap,
    );
  }
}

// ── Home Main Content ─────────────────────────────────────────────────────────

class HomeMainContent extends StatefulWidget {
  final String userId;
  final String name;

  const HomeMainContent({
    super.key,
    required this.userId,
    required this.name,
  });

  @override
  State<HomeMainContent> createState() => _HomeMainContentState();
}

class _HomeMainContentState extends State<HomeMainContent> {
  int _points = 0;
  String _tier = "Bronze";
  int _nextTarget = 1000;
  String _nextTier = "Silver";
  bool _isLoading = true;
  bool _isMapLoading = true;
  List<Map<String, dynamic>> _mapStations = [];
  List<Map<String, dynamic>> _offers = [];
  bool _isOffersLoading = true;
  Position? _userPosition;
  Map<String, dynamic>? _nearestStation;
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadMapStations().then((_) => _getUserLocation());
    _loadOffers();
  }

Future<void> _getUserLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Please enable location services',
      ),
    ),
  );

  return;
}

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Location permission is required',
      ),
    ),
  );

  return;
}
    }

    if (permission == LocationPermission.deniedForever) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Location permission permanently denied',
      ),
    ),
  );

  return;
}

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );

    if (!mounted) return;

    setState(() {
      _userPosition = position;
      _nearestStation = _findNearestStation();
    });
  } catch (e) {
    debugPrint('Location error: $e');
  }
}

Map<String, dynamic>? _findNearestStation() {
  if (_userPosition == null || _mapStations.isEmpty) return null;

  final sortedStations = List<Map<String, dynamic>>.from(_mapStations);

  sortedStations.sort((a, b) {
    final distA = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      _toDouble(a['lat'], 0),
      _toDouble(a['lng'], 0),
    );

    final distB = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      _toDouble(b['lat'], 0),
      _toDouble(b['lng'], 0),
    );

    return distA.compareTo(distB);
  });

 

  return sortedStations.first;
}

Future<void> _openGoogleMaps(double lat, double lng) async {
  final Uri googleMapsUrl = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  if (!await launchUrl(
  googleMapsUrl,
  mode: LaunchMode.externalApplication,
)) {
  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Could not open Google Maps'),
    ),
  );
}
}
  Future<void> _loadOffers() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/offers'),
    );

    if (response.statusCode == 200) {
      List data = [];
      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = [];
      }

      if (!mounted) return;

      setState(() {
        _offers =
            data.map((e) => Map<String, dynamic>.from(e)).toList();
        _isOffersLoading = false;
      });
    } else {
      if (!mounted) return;

      setState(() {
        _isOffersLoading = false;
      });
    }
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isOffersLoading = false;
    });
  }
}

  Future<void> _loadData() async {
  int points = 0;
  Map<String, dynamic>? membership;

  try {
    points = await LoyaltyApiService.getPoints(widget.userId);
  } catch (_) {
    points = 0;
  }

  try {
    membership = await LoyaltyApiService.getMembership(widget.userId);
  } catch (_) {
    membership = null;
  }

  if (!mounted) return;

  setState(() {
    _points = points;
    _tier = membership?["tier"] ?? "Bronze";
    _nextTarget = _tier == "Gold" ? 2000 : 1000;
    _nextTier = _tier == "Bronze" ? "Silver" : "Gold";
    _isLoading = false;
  });
}


  Future<void> _loadMapStations() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8000/stations-db'));
      if (response.statusCode == 200) {
        List data = [];
        try {
          data = jsonDecode(response.body);
        } catch (_) {
          data = [];
        }
        if (!mounted) return;
        setState(() {
          _mapStations = data.map((item) => Map<String, dynamic>.from(item)).toList();
          _isMapLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isMapLoading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isMapLoading = false);
    }
  }

  double _toDouble(dynamic value, double fallback) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  List<Marker> _buildPreviewMarkers() {

  if (_mapStations.isEmpty) return [];

  List<Map<String, dynamic>> stationsToShow =
      List<Map<String, dynamic>>.from(_mapStations);

  if (_userPosition != null) {

    stationsToShow.sort((a, b) {

      final distA = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        _toDouble(a['lat'], 0),
        _toDouble(a['lng'], 0),
      );

      final distB = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        _toDouble(b['lat'], 0),
        _toDouble(b['lng'], 0),
      );

      return distA.compareTo(distB);
    });

    stationsToShow = stationsToShow.take(5).toList();
  }

  return stationsToShow.map((station) {

    final lat = _toDouble(station['lat'], 21.5433);
    final lng = _toDouble(station['lng'], 39.1728);

    return Marker(
      point: LatLng(lat, lng),
      width: 42,
      height: 42,

      child: GestureDetector(

        onTap: () => _showNearestStationDialog(station),

        child: const Icon(
          Icons.location_on,
          color: Color(0xFF4195AF),
          size: 40,
        ),
      ),
    );

  }).toList();
}

void _showNearestStationDialog(Map<String, dynamic> station) {
  final lat = _toDouble(station['lat'], 21.5433);
  final lng = _toDouble(station['lng'], 39.1728);
  final name = station['name']?.toString() ?? 'Station';
  final address = station['address']?.toString() ?? '';
  final l10n = AppLocalizations.of(context)!;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(name),
      content: Text(address.isEmpty ? l10n.openThisStation : address),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _openGoogleMaps(lat, lng);
          },
          child:  Text(l10n.openMaps),
        ),
      ],
    ),
  );
}

  /* void _showBarcodePay(BuildContext context, String redeemCode) {
    final l10n = AppLocalizations.of(context)!;
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
                  decoration: BoxDecoration(color: const Color(0xFF4195AF).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFF4195AF), size: 30),
                ),
                const SizedBox(height: 20),
                Text(l10n.redeemOffer, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1A2E35))),
                const SizedBox(height: 8),
                Text(l10n.scanCodeAtStation, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 180, color: Color(0xFF1A2E35)),
                      const SizedBox(height: 10),
                      Text(redeemCode, style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: 140, height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2E35), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: Text(l10n.close, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } */

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A2E35);
    const Color accentBlue = Color(0xFF4195AF);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.helloUser(widget.name), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: primaryNavy, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(l10n.readyForRefill, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              _buildPointsCard(l10n),
            ],
          ),
          const SizedBox(height: 35),
          _buildMembershipCard(l10n),
          const SizedBox(height: 40),
          Text(l10n.nearbyStations, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
          const SizedBox(height: 16),
          _buildMapCard(context, l10n),
          const SizedBox(height: 35),
          Text(l10n.specialOffers, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: primaryNavy)),
          const SizedBox(height: 12),
          _buildOfferItem(context, accentBlue, l10n),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildPointsCard(AppLocalizations l10n) {
    const Color accentBlue = Color(0xFF4195AF);
    return Column(
      children: [
        Text(_isLoading ? "..." : "$_points", style: const TextStyle(color: accentBlue, fontWeight: FontWeight.w900, fontSize: 22)),
        Text(l10n.points, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _buildMembershipCard(AppLocalizations l10n) {
    const Color accentBlue = Color(0xFF4195AF);
    final double progress = (_points / _nextTarget).clamp(0.0, 1.0);
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.tierStatus(_tier.toUpperCase()), style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
          const SizedBox(height: 6),
          Text("$_points / $_nextTarget", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(l10n.pointsToNextTier(_nextTier), style: const TextStyle(color: Colors.black45, fontSize: 14)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: accentBlue, minHeight: 8),
          ),
        ],
      ),
    );
  }
LatLng _getMapCenter() {
  final stations = List<Map<String, dynamic>>.from(_mapStations);

  if (stations.isEmpty) {
    return const LatLng(21.5433, 39.1728);
  }

  if (_userPosition != null) {
    stations.sort((a, b) {
      final distA = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        _toDouble(a['lat'], 0),
        _toDouble(a['lng'], 0),
      );

      final distB = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        _toDouble(b['lat'], 0),
        _toDouble(b['lng'], 0),
      );

      return distA.compareTo(distB);
    });
  }

  final nearestStations = stations.take(5).toList();

  final avgLat = nearestStations
          .map((s) => _toDouble(s['lat'], 21.5433))
          .reduce((a, b) => a + b) /
      nearestStations.length;

  final avgLng = nearestStations
          .map((s) => _toDouble(s['lng'], 39.1728))
          .reduce((a, b) => a + b) /
      nearestStations.length;

  return LatLng(avgLat, avgLng);
}

  Widget _buildMapCard(BuildContext context, AppLocalizations l10n) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: SizedBox(
      height: 210,
      width: double.infinity,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
  initialCenter: _userPosition == null
      ? const LatLng(21.5433, 39.1728)
      : LatLng(
          _userPosition!.latitude,
          _userPosition!.longitude,
        ),
  initialZoom: _userPosition == null ? 9.0 : 11.3,
  interactionOptions: const InteractionOptions(
    flags: InteractiveFlag.drag |
        InteractiveFlag.pinchZoom |
        InteractiveFlag.scrollWheelZoom,
  ),
),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.petrovision.app',
              ),
              MarkerLayer(markers: _buildPreviewMarkers()),
            ],
          ),

          if (_isMapLoading)
            Container(
              color: Colors.white.withOpacity(0.45),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4195AF),
                ),
              ),
            ),

          IgnorePointer(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.black.withOpacity(0.18),
          Colors.transparent,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  ),
),

          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _nearestStation == null
                    ? '${_mapStations.length} Stations'
                    : l10n.nearestStations,
                style: const TextStyle(
                  color: Color(0xFF1A2E35),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            right: 12,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FullMapScreen(),
                ),
              ),
              icon: const Icon(Icons.map_rounded, size: 16),
              label: Text(
                l10n.explore,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildOfferItem(
  BuildContext context,
  Color accent,
  AppLocalizations l10n,
) {
  if (_isOffersLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (_offers.isEmpty) {
    return const Text("No offers available");
  }

final offer = _offers.first;

final int redeemPoints =
    ((offer["redeem_points"] ?? 0) as num).toInt();

final bool canRedeem = _points >= redeemPoints;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.local_gas_station_rounded,
            color: accent,
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer["name"] ?? "Offer",
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),

              Text(
                offer["offer_type"] ?? "",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),



InkWell(
  onTap: !canRedeem
      ? null
      : () async {
          final redeemed = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ConfirmRedemptionScreen(
                rewardType: offer["name"] ?? "Offer",
                pointsCost: redeemPoints,
                currentPoints: _points,
                userId: widget.userId,
                offerId: offer["offer_id"],
              ),
            ),
          );

          if (redeemed == true) {
            _loadData();
          }
        },

          borderRadius: BorderRadius.circular(12),

          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Text(
              l10n.claim,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

}