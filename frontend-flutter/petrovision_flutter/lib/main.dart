import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/loyalty_programs_screen.dart';
import 'admin/screens/members_screen.dart';
import 'admin/screens/settings_screen.dart';
import 'auth/welcome_screen.dart';
import 'auth/login_screen.dart';
import 'customer/screens/home_page.dart';

void main() {
  runApp(const PetroVisionApp());
}

class PetroVisionApp extends StatelessWidget {
  const PetroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetroVision',
      //initialRoute: '/dashboard_screen',
  //initialRoute: '/welcome_screen',
home: const DashboardScreen(),
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFBFBFB),

        textTheme: GoogleFonts.dmSansTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.dmSans(
            color: const Color(0xFF4195AF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Color(0xFF4195AF)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
          ),
        ),

        hoverColor: const Color(0xFF4195AF).withOpacity(0.1),
        splashColor: const Color(0xFF4195AF).withOpacity(0.2),
        highlightColor: Colors.transparent,
        canvasColor: const Color(0xFFEAF3F7),

        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.macOS: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),

      routes: {
  '/welcome': (context) => const WelcomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/loyalty': (context) => const LoyaltyProgramsScreen(),
  '/members': (context) => const MembersScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/customer-home': (context) => const HomePage(),
  '/dashboard': (context) => const DashboardScreen(),
},
    );
  }
}

class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
