// ========================================================================================================
// PetroVision Main Application Entry
// --------------------------------------------------------------------------------------------------------
// This file defines the main application entry point
// and global application configuration
// for the PetroVision platform.
//
// Features included:
// - Initializing the PetroVision application
// - Configuring localization and multilingual support
// - Managing application-wide language settings
// - Configuring global application themes and styling
// - Configuring routing and screen navigation
// - Applying responsive typography and Google Fonts
// - Configuring page transition behaviors
// - Managing provider-based state initialization
//
// It also integrates localization workflows,
// global UI configuration,
// navigation management,
// and application startup logic
// within the PetroVision platform.
// ========================================================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:r/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin/screens/dashboard_screen.dart';
import 'admin/screens/loyalty_programs_screen.dart';
import 'admin/screens/members_screen.dart';
import 'admin/screens/settings_screen.dart';
import 'auth/welcome_screen.dart';
import 'auth/login_screen.dart';
import 'customer/screens/home_page.dart';
import 'core/language_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageController(),
      child: const PetroVisionApp(),
    ),
  );
}

class PetroVisionApp extends StatelessWidget {
  const PetroVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langController = context.watch<LanguageController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetroVision',
      locale: langController.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const WelcomeScreen(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4195AF),
          primary: const Color(0xFF1A2E35),
          secondary: const Color(0xFF4195AF),
          surface: const Color(0xFFFBFBFB),
          background: const Color(0xFFFBFBFB),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFFFBFBFB),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
            color: Color(0xFF1A2E35),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
          contentTextStyle: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFFBFBFB),
        textTheme: langController.isArabic
            ? Theme.of(context).textTheme.apply(
                  bodyColor: Colors.black87,
                  displayColor: Colors.black,
                )
            : GoogleFonts.dmSansTextTheme(
                Theme.of(context).textTheme,
              ).apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black,
              ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: langController.isArabic
              ? const TextStyle(
                  color: Color(0xFF4195AF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
              : GoogleFonts.dmSans(
                  color: const Color(0xFF4195AF),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          iconTheme: const IconThemeData(color: Color(0xFF4195AF)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: langController.isArabic
                ? const TextStyle(fontWeight: FontWeight.bold)
                : GoogleFonts.dmSans(fontWeight: FontWeight.bold),
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
        '/customer-home': (context) => const HomePage(
           userId: '',
           name: 'Customer',
           email: '',
        ),
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