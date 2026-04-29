import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  final Color primaryNavy = const Color(0xFF1A2E35);
  final Color accentBlue = const Color(0xFF4195AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
    appBar: AppBar(
  title: const Text(
    "ABOUT US",
    style: TextStyle(
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
    icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A2E35), size: 20),
    onPressed: () => Navigator.pop(context),
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم الصورة الرئيسية والوصف
            _buildHeroSection(),
            const SizedBox(height: 30),
            
            // قسم الرؤية والرسالة (مربعات تفاعلية)
            Row(
              children: [
                Expanded(child: _buildInteractiveCard("Our Vision", "To transform the way customers experience fuel stations by combining convenience, rewards, and innovation.")),
                const SizedBox(width: 15),
                Expanded(child: _buildInteractiveCard("Our Mission", "To provide a seamless, fun, and rewarding experience for every customer while strengthening the bond between PetroMin and its community.")),
              ],
            ),
            
            const SizedBox(height: 30),
            const Text("FUN FACTS & ACHIEVEMENTS", 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
            const SizedBox(height: 15),
            
            // قائمة الإنجازات
            _buildAchievementItem(Icons.group, "Over 50,000 satisfied users in 2024"),
            _buildAchievementItem(Icons.stars, "Redeemed more than 1 million reward points"),
            _buildAchievementItem(Icons.location_on, "Operates in 20+ stations across the kingdom"),
            _buildAchievementItem(Icons.psychology, "Introduced AI-driven insights for personalized offers"),
            
            const SizedBox(height: 30),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  // الجزء العلوي: صورة مع نص تعريفي
  Widget _buildHeroSection() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=800&q=80', // رابط صورة تجريبي
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "PetroVision is your smart companion at PetroMin stations. Check out the latest offers, earn points every time you fuel up, and redeem rewards instantly at the station or with our partners. It’s designed to make every visit faster, more fun, and more rewarding.",
          style: TextStyle(color: Colors.grey.shade700, height: 1.6, fontSize: 15, fontWeight: FontWeight.w500),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // المربعات التفاعلية (تكبر وتظهر ظلال عند اللمس/الحوم)
  Widget _buildInteractiveCard(String title, String desc) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: isHovered ? (Matrix4.identity()..scale(1.05)) : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // هذا الجزء يحاكي الـ Gradient Border في الكود اللي أرسلتيه
              gradient: isHovered 
                  ? const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3B82F6), Color(0xFFA855F7)])
                  : null,
              boxShadow: [
                if (isHovered)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
              ],
            ),
            padding: const EdgeInsets.all(2), // حجم الفراغ للحد الملون (P-px)
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isHovered ? const Color(0xFF09090B) : Colors.white, // خلفية داكنة عند الحوم مثل Uiverse
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
                      // أيقونة السهم التي تتحرك لليمين عند الحوم
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        transform: isHovered 
                            ? (Matrix4.identity()..translate(5.0)) 
                            : Matrix4.identity(),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
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

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CONTACT US", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 15),
          _contactRow(Icons.email, "support@petrovision.com"),
          _contactRow(Icons.phone, "+966 12 345 6789"),
          _contactRow(Icons.location_on, "Jeddah, Saudi Arabia"),
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