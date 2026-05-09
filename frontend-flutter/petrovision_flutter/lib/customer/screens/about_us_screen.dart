// ========================================================================================================
// PetroVision About Us Screen
// --------------------------------------------------------------------------------------------------------
// This file defines the AboutUsScreen used for
// presenting PetroVision company information
// and platform details within the application.
//
// Features included:
// - Displaying PetroVision company information
// - Supporting multilingual localization content
// - Displaying company vision and mission sections
// - Displaying interactive animated information cards
// - Supporting RTL and LTR layouts
// - Displaying achievement and platform highlights
// - Displaying contact information and support details
// - Providing responsive and interactive UI components
//
// It also integrates localization support,
// company-brand presentation,
// and interactive informational content
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:r/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: Text(
          l10n.aboutUsTitle,
          style: const TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            isRtl ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded,
            color: const Color(0xFF1A2E35),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(l10n.aboutUsHeroText),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(child: _buildInteractiveCard(l10n.ourVision, l10n.ourVisionDesc)),
                const SizedBox(width: 15),
                Expanded(child: _buildInteractiveCard(l10n.ourMission, l10n.ourMissionDesc)),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              l10n.funFacts,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
            ),
            const SizedBox(height: 15),
            _buildAchievementItem(Icons.group, l10n.achievement1),
            _buildAchievementItem(Icons.stars, l10n.achievement2),
            _buildAchievementItem(Icons.location_on, l10n.achievement3),
            _buildAchievementItem(Icons.psychology, l10n.achievement4),
            const SizedBox(height: 30),
            _buildContactSection(l10n.contactUs, l10n.contactLocation),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(String heroText) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=800&q=80',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.broken_image_outlined),
              ),
            );
          },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          heroText,
          style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 15, fontWeight: FontWeight.w500),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildInteractiveCard(String title, String desc) {
    bool isHovered = false;
    return StatefulBuilder(
      builder: (context, setState) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isHovered
                  ? const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6), Color(0xFFA855F7)])
                  : null,
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
              ],
            ),
            padding: const EdgeInsets.all(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHovered ? const Color(0xFF09090B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isHovered ? Colors.white : primaryNavy,
                          fontSize: 16,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        transform: isHovered
                            ? (Matrix4.identity()..translate(isRtl ? -5.0 : 5.0))
                            : Matrix4.identity(),
                        child: Icon(
                          isRtl ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isHovered ? Colors.tealAccent : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    desc,
                    style: TextStyle(
                      color: isHovered ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildContactSection(String title, String location) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 15),
          _contactRow(Icons.email, "support@petrovision.com"),
          _contactRow(Icons.phone, "+966 12 345 6789"),
          _contactRow(Icons.location_on, location),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 18),
          const SizedBox(width: 10),
          Text(info, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
