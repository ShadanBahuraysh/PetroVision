import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navStations.
  ///
  /// In en, this message translates to:
  /// **'STATIONS'**
  String get navStations;

  /// No description provided for @navPoints.
  ///
  /// In en, this message translates to:
  /// **'LOYALTY PROGRAM'**
  String get navPoints;

  /// No description provided for @navOffers.
  ///
  /// In en, this message translates to:
  /// **'OFFERS'**
  String get navOffers;

  /// No description provided for @stationsTitle.
  ///
  /// In en, this message translates to:
  /// **'STATIONS'**
  String get stationsTitle;

  /// No description provided for @noStationsFound.
  ///
  /// In en, this message translates to:
  /// **'No stations found'**
  String get noStationsFound;

  /// No description provided for @specialOffersAtStation.
  ///
  /// In en, this message translates to:
  /// **'Special offers at this station:'**
  String get specialOffersAtStation;

  /// No description provided for @workingHours.
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @drawerMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get drawerMyProfile;

  /// No description provided for @drawerTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get drawerTransactionHistory;

  /// No description provided for @drawerAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get drawerAboutUs;

  /// No description provided for @drawerTermsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get drawerTermsConditions;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @drawerLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get drawerLanguage;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @readyForRefill.
  ///
  /// In en, this message translates to:
  /// **'Ready for a refill?'**
  String get readyForRefill;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get points;

  /// No description provided for @tierStatus.
  ///
  /// In en, this message translates to:
  /// **'{tier} STATUS'**
  String tierStatus(String tier);

  /// No description provided for @pointsToNextTier.
  ///
  /// In en, this message translates to:
  /// **'Points to {tier} Tier'**
  String pointsToNextTier(String tier);

  /// No description provided for @nearbyStations.
  ///
  /// In en, this message translates to:
  /// **'Nearby Stations'**
  String get nearbyStations;

  /// No description provided for @specialOffers.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @doublePointsWeekend.
  ///
  /// In en, this message translates to:
  /// **'Double Points Weekend'**
  String get doublePointsWeekend;

  /// No description provided for @onAllFuelTypes.
  ///
  /// In en, this message translates to:
  /// **'On all fuel types'**
  String get onAllFuelTypes;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get claim;

  /// No description provided for @redeemOffer.
  ///
  /// In en, this message translates to:
  /// **'Redeem Offer'**
  String get redeemOffer;

  /// No description provided for @scanCodeAtStation.
  ///
  /// In en, this message translates to:
  /// **'Scan this code at the station'**
  String get scanCodeAtStation;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @transactionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION HISTORY'**
  String get transactionHistoryTitle;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @offersTitle.
  ///
  /// In en, this message translates to:
  /// **'OFFERS'**
  String get offersTitle;

  /// No description provided for @noOffersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No offers available'**
  String get noOffersAvailable;

  /// No description provided for @earnRedeemPoints.
  ///
  /// In en, this message translates to:
  /// **'Earn {earn} pts • Redeem {redeem} pts'**
  String earnRedeemPoints(int earn, int redeem);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @cityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updatePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updatePersonalInfo;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateSecurityCredentials.
  ///
  /// In en, this message translates to:
  /// **'Update your security credentials'**
  String get updateSecurityCredentials;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @loyaltyProgramTitle.
  ///
  /// In en, this message translates to:
  /// **'LOYALTY PROGRAM'**
  String get loyaltyProgramTitle;

  /// No description provided for @yourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your Points'**
  String get yourPoints;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @earn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earn;

  /// No description provided for @redeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// No description provided for @aboutUsTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT US'**
  String get aboutUsTitle;

  /// No description provided for @ourVision.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// No description provided for @ourMission.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// No description provided for @funFacts.
  ///
  /// In en, this message translates to:
  /// **'FUN FACTS & ACHIEVEMENTS'**
  String get funFacts;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'CONTACT US'**
  String get contactUs;

  /// No description provided for @termsConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'TERMS & CONDITIONS'**
  String get termsConditionsTitle;

  /// No description provided for @aboutUsHeroText.
  ///
  /// In en, this message translates to:
  /// **'PetroVision is your smart companion at PetroMin stations. Check out the latest offers, earn points every time you fuel up, and redeem rewards instantly at the station or with our partners. It\'s designed to make every visit faster, more fun, and more rewarding.'**
  String get aboutUsHeroText;

  /// No description provided for @ourVisionDesc.
  ///
  /// In en, this message translates to:
  /// **'To transform the way customers experience fuel stations by combining convenience, rewards, and innovation.'**
  String get ourVisionDesc;

  /// No description provided for @ourMissionDesc.
  ///
  /// In en, this message translates to:
  /// **'To provide a seamless, fun, and rewarding experience for every customer while strengthening the bond between PetroMin and its community.'**
  String get ourMissionDesc;

  /// No description provided for @achievement1.
  ///
  /// In en, this message translates to:
  /// **'Over 50,000 satisfied users in 2024'**
  String get achievement1;

  /// No description provided for @achievement2.
  ///
  /// In en, this message translates to:
  /// **'Redeemed more than 1 million reward points'**
  String get achievement2;

  /// No description provided for @achievement3.
  ///
  /// In en, this message translates to:
  /// **'Operates in 20+ stations across the kingdom'**
  String get achievement3;

  /// No description provided for @achievement4.
  ///
  /// In en, this message translates to:
  /// **'Introduced AI-driven insights for personalized offers'**
  String get achievement4;

  /// No description provided for @contactLocation.
  ///
  /// In en, this message translates to:
  /// **'Jeddah, Saudi Arabia'**
  String get contactLocation;

  /// No description provided for @termsWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PetroVision'**
  String get termsWelcome;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: April 2026\nBy using our app, you agree to these Terms and Conditions. Please read them carefully.'**
  String get termsIntro;

  /// No description provided for @termsSec1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Use of the App'**
  String get termsSec1Title;

  /// No description provided for @termsSec1P1.
  ///
  /// In en, this message translates to:
  /// **'PetroVision is intended for personal, non-commercial use.'**
  String get termsSec1P1;

  /// No description provided for @termsSec1P2.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 18 years old to use the app.'**
  String get termsSec1P2;

  /// No description provided for @termsSec1P3.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your account and password.'**
  String get termsSec1P3;

  /// No description provided for @termsSec2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Loyalty Points and Rewards'**
  String get termsSec2Title;

  /// No description provided for @termsSec2P1.
  ///
  /// In en, this message translates to:
  /// **'Points are earned based on transactions at PetroMin stations and participating partners.'**
  String get termsSec2P1;

  /// No description provided for @termsSec2P2.
  ///
  /// In en, this message translates to:
  /// **'Points have no cash value and cannot be exchanged for money.'**
  String get termsSec2P2;

  /// No description provided for @termsSec2P3.
  ///
  /// In en, this message translates to:
  /// **'Rewards must be redeemed through the app and are subject to availability.'**
  String get termsSec2P3;

  /// No description provided for @termsSec2P4.
  ///
  /// In en, this message translates to:
  /// **'PetroVision reserves the right to modify or cancel rewards at any time.'**
  String get termsSec2P4;

  /// No description provided for @termsSec3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Offers and Promotions'**
  String get termsSec3Title;

  /// No description provided for @termsSec3P1.
  ///
  /// In en, this message translates to:
  /// **'All offers and promotions are subject to terms set by PetroMin stations or their partners.'**
  String get termsSec3P1;

  /// No description provided for @termsSec3P2.
  ///
  /// In en, this message translates to:
  /// **'PetroVision is not responsible for errors, inaccuracies, or expiration of offers.'**
  String get termsSec3P2;

  /// No description provided for @termsSec4Title.
  ///
  /// In en, this message translates to:
  /// **'4. User Content'**
  String get termsSec4Title;

  /// No description provided for @termsSec4P1.
  ///
  /// In en, this message translates to:
  /// **'Any content you submit (reviews, feedback, or suggestions) may be used by PetroVision to improve services.'**
  String get termsSec4P1;

  /// No description provided for @termsSec4P2.
  ///
  /// In en, this message translates to:
  /// **'You grant PetroVision a non-exclusive, royalty-free license to use your content.'**
  String get termsSec4P2;

  /// No description provided for @termsSec5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Privacy'**
  String get termsSec5Title;

  /// No description provided for @termsSec5P1.
  ///
  /// In en, this message translates to:
  /// **'Your use of the app is also governed by our Privacy Policy, which explains how we collect, use, and protect your information.'**
  String get termsSec5P1;

  /// No description provided for @termsSec6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Limitation of Liability'**
  String get termsSec6Title;

  /// No description provided for @termsSec6P1.
  ///
  /// In en, this message translates to:
  /// **'PetroVision is provided \"as is\" without warranties of any kind.'**
  String get termsSec6P1;

  /// No description provided for @termsSec6P2.
  ///
  /// In en, this message translates to:
  /// **'We are not liable for any damages resulting from your use of the app or inability to access it.'**
  String get termsSec6P2;

  /// No description provided for @termsSec7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Termination'**
  String get termsSec7Title;

  /// No description provided for @termsSec7P1.
  ///
  /// In en, this message translates to:
  /// **'We may suspend or terminate your access if you violate these Terms and Conditions.'**
  String get termsSec7P1;

  /// No description provided for @termsSec7P2.
  ///
  /// In en, this message translates to:
  /// **'Upon termination, your account and points may be deactivated.'**
  String get termsSec7P2;

  /// No description provided for @termsSec8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Changes to Terms'**
  String get termsSec8Title;

  /// No description provided for @termsSec8P1.
  ///
  /// In en, this message translates to:
  /// **'PetroVision may update these Terms and Conditions at any time.'**
  String get termsSec8P1;

  /// No description provided for @termsSec8P2.
  ///
  /// In en, this message translates to:
  /// **'Continued use of the app after changes constitutes acceptance of the updated terms.'**
  String get termsSec8P2;

  /// No description provided for @termsSec9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Governing Law'**
  String get termsSec9Title;

  /// No description provided for @termsSec9P1.
  ///
  /// In en, this message translates to:
  /// **'These Terms are governed by the laws of the country where PetroMin operates.'**
  String get termsSec9P1;

  /// No description provided for @nearestStations.
  ///
  /// In en, this message translates to:
  /// **'Nearest Stations'**
  String get nearestStations;

  /// No description provided for @openMaps.
  ///
  /// In en, this message translates to:
  /// **'Open Maps'**
  String get openMaps;

  /// No description provided for @openThisStation.
  ///
  /// In en, this message translates to:
  /// **'Open this station in Google Maps?'**
  String get openThisStation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
