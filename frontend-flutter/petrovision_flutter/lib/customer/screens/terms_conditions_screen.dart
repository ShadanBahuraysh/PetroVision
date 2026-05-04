import 'package:flutter/material.dart';
import 'package:r/l10n/app_localizations.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          l10n.termsConditionsTitle,
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
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.termsWelcome,
              style: TextStyle(
                color: accentBlue,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.termsIntro,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 35),
            _buildSection(l10n.termsSec1Title, [l10n.termsSec1P1, l10n.termsSec1P2, l10n.termsSec1P3]),
            _buildSection(l10n.termsSec2Title, [l10n.termsSec2P1, l10n.termsSec2P2, l10n.termsSec2P3, l10n.termsSec2P4]),
            _buildSection(l10n.termsSec3Title, [l10n.termsSec3P1, l10n.termsSec3P2]),
            _buildSection(l10n.termsSec4Title, [l10n.termsSec4P1, l10n.termsSec4P2]),
            _buildSection(l10n.termsSec5Title, [l10n.termsSec5P1]),
            _buildSection(l10n.termsSec6Title, [l10n.termsSec6P1, l10n.termsSec6P2]),
            _buildSection(l10n.termsSec7Title, [l10n.termsSec7P1, l10n.termsSec7P2]),
            _buildSection(l10n.termsSec8Title, [l10n.termsSec8P1, l10n.termsSec8P2]),
            _buildSection(l10n.termsSec9Title, [l10n.termsSec9P1]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: primaryNavy,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map((point) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.circle, color: accentBlue, size: 6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    point,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
