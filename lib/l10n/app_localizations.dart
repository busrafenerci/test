import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Your Cycle Today'**
  String get hello;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @periodStartedToday.
  ///
  /// In en, this message translates to:
  /// **'My period started today'**
  String get periodStartedToday;

  /// No description provided for @periodEnded.
  ///
  /// In en, this message translates to:
  /// **'My period ended'**
  String get periodEnded;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Estimated next period'**
  String get nextPeriod;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @appStartError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while starting the app.'**
  String get appStartError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Within was developed to help you easily record your menstrual cycles and follow your personal cycle predictions.'**
  String get aboutDescription;

  /// No description provided for @developedInTurkey.
  ///
  /// In en, this message translates to:
  /// **'Developed in Türkiye.'**
  String get developedInTurkey;

  /// No description provided for @contactComingSoon.
  ///
  /// In en, this message translates to:
  /// **'The contact address will be added before the app is published.'**
  String get contactComingSoon;

  /// No description provided for @welcomeSlogan.
  ///
  /// In en, this message translates to:
  /// **'Know your cycle.\nDiscover your strength.'**
  String get welcomeSlogan;

  /// No description provided for @welcomeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continuing...'**
  String get welcomeContinue;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get welcomeStart;

  /// No description provided for @welcomeImageError.
  ///
  /// In en, this message translates to:
  /// **'W image could not be found'**
  String get welcomeImageError;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Let’s Get to Know You'**
  String get setupTitle;

  /// No description provided for @setupDescription.
  ///
  /// In en, this message translates to:
  /// **'Hi, I\'m W. I\'d like to get to know you a little better so I can support you.'**
  String get setupDescription;

  /// No description provided for @lastPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Last Period Start'**
  String get lastPeriodStart;

  /// No description provided for @periodDuration.
  ///
  /// In en, this message translates to:
  /// **'Period Duration'**
  String get periodDuration;

  /// No description provided for @averageCycleDuration.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle Length'**
  String get averageCycleDuration;

  /// No description provided for @dayUnit.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dayUnit;

  /// No description provided for @periodDurationHint.
  ///
  /// In en, this message translates to:
  /// **'Select how many days your period usually lasts.'**
  String get periodDurationHint;

  /// No description provided for @cycleDurationHint.
  ///
  /// In en, this message translates to:
  /// **'The average number of days between the start of two periods.'**
  String get cycleDurationHint;

  /// No description provided for @setupDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'The period, PMS, fertile window, and ovulation dates shown by Within are estimates. They are not medical advice and should not be used as a method of contraception.'**
  String get setupDisclaimer;

  /// No description provided for @disclaimerAccepted.
  ///
  /// In en, this message translates to:
  /// **'I have read and understood this information.'**
  String get disclaimerAccepted;

  /// No description provided for @setupStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get setupStart;

  /// No description provided for @setupSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get setupSaving;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your information. Please try again.'**
  String get saveFailed;

  /// No description provided for @month1.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get month1;

  /// No description provided for @month2.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get month2;

  /// No description provided for @month3.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get month3;

  /// No description provided for @month4.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get month4;

  /// No description provided for @month5.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get month5;

  /// No description provided for @month6.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get month6;

  /// No description provided for @month7.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get month7;

  /// No description provided for @month8.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get month8;

  /// No description provided for @month9.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get month9;

  /// No description provided for @month10.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get month10;

  /// No description provided for @month11.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get month11;

  /// No description provided for @month12.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get month12;

  /// No description provided for @averageCycle.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle'**
  String get averageCycle;

  /// No description provided for @daySingular.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get daySingular;

  /// No description provided for @dayPlural.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get dayPlural;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy matters to us'**
  String get privacyIntroTitle;

  /// No description provided for @privacyIntroText.
  ///
  /// In en, this message translates to:
  /// **'Within was developed to help you track your menstrual cycle. The period and cycle information you enter in the app is sensitive personal data.'**
  String get privacyIntroText;

  /// No description provided for @privacyCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'What information is stored?'**
  String get privacyCollectedTitle;

  /// No description provided for @privacyPeriodDates.
  ///
  /// In en, this message translates to:
  /// **'Period start and end dates'**
  String get privacyPeriodDates;

  /// No description provided for @privacyCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get privacyCycleLength;

  /// No description provided for @privacyPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Estimated period duration'**
  String get privacyPeriodLength;

  /// No description provided for @privacySetupStatus.
  ///
  /// In en, this message translates to:
  /// **'App setup completion status'**
  String get privacySetupStatus;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Where is your information stored?'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageText.
  ///
  /// In en, this message translates to:
  /// **'Your records are stored locally only on your device. Within does not require you to create an account and does not sync your information with an online account in the current version.'**
  String get privacyStorageText;

  /// No description provided for @privacyInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'Internet, location, and account'**
  String get privacyInternetTitle;

  /// No description provided for @privacyInternetText.
  ///
  /// In en, this message translates to:
  /// **'The current version does not require an internet connection for basic cycle tracking. It does not collect location information or create a user account.'**
  String get privacyInternetText;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Is your information shared?'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingText.
  ///
  /// In en, this message translates to:
  /// **'Within does not send your health or cycle information to any server, share it with third parties, or use it for advertising purposes.'**
  String get privacySharingText;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'How can you delete your information?'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteText.
  ///
  /// In en, this message translates to:
  /// **'You can permanently delete your period records and app settings stored on your device by selecting “Reset All Data” on the Settings screen. Uninstalling the app may also remove locally stored app data from your device.'**
  String get privacyDeleteText;

  /// No description provided for @privacyPredictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Predictions and health information'**
  String get privacyPredictionsTitle;

  /// No description provided for @privacyPredictionsText.
  ///
  /// In en, this message translates to:
  /// **'The period, PMS, fertile window, and ovulation dates shown by Within are approximate predictions. They are based on the records you enter, the settings you select, and general cycle calculation methods. Actual dates may vary from person to person and from cycle to cycle.'**
  String get privacyPredictionsText;

  /// No description provided for @privacyWarningText.
  ///
  /// In en, this message translates to:
  /// **'Predictions are not a method of contraception and should not be considered reliable on their own for pregnancy planning.'**
  String get privacyWarningText;

  /// No description provided for @privacyMedicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical disclaimer'**
  String get privacyMedicalTitle;

  /// No description provided for @privacyMedicalText.
  ///
  /// In en, this message translates to:
  /// **'Within is not a medical device and does not provide medical advice, diagnosis, or treatment. It is not a substitute for evaluation by a doctor. Fertile window and ovulation predictions should not be used on their own to prevent or achieve pregnancy.'**
  String get privacyMedicalText;

  /// No description provided for @privacyChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get privacyChangesTitle;

  /// No description provided for @privacyChangesText.
  ///
  /// In en, this message translates to:
  /// **'This privacy policy will be updated if new features, online services, analytics, or advertising tools are added to the app. You can access the latest version from the Settings screen.'**
  String get privacyChangesText;

  /// No description provided for @privacyFooterText.
  ///
  /// In en, this message translates to:
  /// **'In the current version, your information remains on your device and under your control.'**
  String get privacyFooterText;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your cycle settings, review privacy information, and control your data.'**
  String get settingsDescription;

  /// No description provided for @settingsCycleSection.
  ///
  /// In en, this message translates to:
  /// **'CYCLE'**
  String get settingsCycleSection;

  /// No description provided for @settingsAverageCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get settingsAverageCycleLength;

  /// No description provided for @settingsEstimatedPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Estimated period duration'**
  String get settingsEstimatedPeriodLength;

  /// No description provided for @settingsInformationSection.
  ///
  /// In en, this message translates to:
  /// **'INFORMATION'**
  String get settingsInformationSection;

  /// No description provided for @settingsPredictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'About Predictions'**
  String get settingsPredictionsTitle;

  /// No description provided for @settingsPredictionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how your cycle predictions are calculated'**
  String get settingsPredictionsSubtitle;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Within and app version'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get settingsPrivacySection;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how your information is stored'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'DATA'**
  String get settingsDataSection;

  /// No description provided for @settingsResetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get settingsResetAllData;

  /// No description provided for @settingsResetAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your period history and settings'**
  String get settingsResetAllDataSubtitle;

  /// No description provided for @settingsCyclePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Average cycle length'**
  String get settingsCyclePickerTitle;

  /// No description provided for @settingsCyclePickerDescription.
  ///
  /// In en, this message translates to:
  /// **'Within uses this value when predicting your next period.'**
  String get settingsCyclePickerDescription;

  /// No description provided for @settingsPeriodPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Estimated period duration'**
  String get settingsPeriodPickerTitle;

  /// No description provided for @settingsPeriodPickerDescription.
  ///
  /// In en, this message translates to:
  /// **'The default duration used for ongoing records and future period predictions.'**
  String get settingsPeriodPickerDescription;

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get settingsDeleteAll;

  /// No description provided for @settingsResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Within?'**
  String get settingsResetTitle;

  /// No description provided for @settingsResetDescription.
  ///
  /// In en, this message translates to:
  /// **'All your period records and cycle settings will be permanently deleted.\n\nThis action cannot be undone.'**
  String get settingsResetDescription;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading your settings.'**
  String get settingsLoadError;

  /// No description provided for @settingsCycleSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your cycle length could not be saved.'**
  String get settingsCycleSaveError;

  /// No description provided for @settingsPeriodSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your period duration could not be saved.'**
  String get settingsPeriodSaveError;

  /// No description provided for @settingsResetError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting your data. Please try again.'**
  String get settingsResetError;

  /// No description provided for @predictionHowCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'How are predictions calculated?'**
  String get predictionHowCreatedTitle;

  /// No description provided for @predictionHowCreatedText.
  ///
  /// In en, this message translates to:
  /// **'Within uses the period start and end dates you enter to estimate your cycle length and period duration. When there are not enough records, the default values selected in Settings and general cycle calculation methods are used.'**
  String get predictionHowCreatedText;

  /// No description provided for @predictionEstimatedInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Which information is estimated?'**
  String get predictionEstimatedInfoTitle;

  /// No description provided for @predictionNextPeriodItem.
  ///
  /// In en, this message translates to:
  /// **'Your next period date and estimated period days'**
  String get predictionNextPeriodItem;

  /// No description provided for @predictionPmsItem.
  ///
  /// In en, this message translates to:
  /// **'PMS phase'**
  String get predictionPmsItem;

  /// No description provided for @predictionFertileWindowItem.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get predictionFertileWindowItem;

  /// No description provided for @predictionOvulationItem.
  ///
  /// In en, this message translates to:
  /// **'Ovulation day'**
  String get predictionOvulationItem;

  /// No description provided for @predictionWhyDatesChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Why can dates change?'**
  String get predictionWhyDatesChangeTitle;

  /// No description provided for @predictionWhyDatesChangeText.
  ///
  /// In en, this message translates to:
  /// **'Every person\'s cycle is different. Stress, illness, medication, sleep patterns, travel, hormonal changes, and other factors may cause actual dates to differ from predictions.'**
  String get predictionWhyDatesChangeText;

  /// No description provided for @predictionWarningText.
  ///
  /// In en, this message translates to:
  /// **'Fertile window and ovulation predictions should not be used on their own to prevent or achieve pregnancy.'**
  String get predictionWarningText;

  /// No description provided for @predictionHealthDecisionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health decisions'**
  String get predictionHealthDecisionsTitle;

  /// No description provided for @predictionHealthDecisionsText.
  ///
  /// In en, this message translates to:
  /// **'Within does not provide a medical diagnosis or recommend treatment, and it is not a substitute for evaluation by a doctor. Consult a healthcare professional if you notice an unusual or concerning change in your cycle.'**
  String get predictionHealthDecisionsText;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Cycle'**
  String get homeSubtitle;

  /// No description provided for @homeTodayStatus.
  ///
  /// In en, this message translates to:
  /// **'Today\'s status'**
  String get homeTodayStatus;

  /// No description provided for @homePhaseMenstruationName.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get homePhaseMenstruationName;

  /// No description provided for @homePhaseRenewalName.
  ///
  /// In en, this message translates to:
  /// **'Renewal phase'**
  String get homePhaseRenewalName;

  /// No description provided for @homePhaseFertileName.
  ///
  /// In en, this message translates to:
  /// **'Fertile window'**
  String get homePhaseFertileName;

  /// No description provided for @homePhasePmsName.
  ///
  /// In en, this message translates to:
  /// **'PMS phase'**
  String get homePhasePmsName;

  /// No description provided for @homePhaseRestName.
  ///
  /// In en, this message translates to:
  /// **'Rest phase'**
  String get homePhaseRestName;

  /// No description provided for @homePhaseRestPmsName.
  ///
  /// In en, this message translates to:
  /// **'Rest / PMS phase'**
  String get homePhaseRestPmsName;

  /// No description provided for @homePhaseMenstruationTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re on your period'**
  String get homePhaseMenstruationTitle;

  /// No description provided for @homePhaseRenewalTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in your renewal phase'**
  String get homePhaseRenewalTitle;

  /// No description provided for @homePhaseFertileTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in your fertile window'**
  String get homePhaseFertileTitle;

  /// No description provided for @homePhasePmsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in your PMS phase'**
  String get homePhasePmsTitle;

  /// No description provided for @homePhaseRestTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in your rest phase'**
  String get homePhaseRestTitle;

  /// No description provided for @homePeriodDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Period day'**
  String get homePeriodDayLabel;

  /// No description provided for @homeCycleDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle day'**
  String get homeCycleDayLabel;

  /// No description provided for @homeCycleDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Cycle days'**
  String get homeCycleDaysLabel;

  /// No description provided for @homePhaseMenstruationDescription.
  ///
  /// In en, this message translates to:
  /// **'Your body is renewing itself. Be gentle with yourself today.'**
  String get homePhaseMenstruationDescription;

  /// No description provided for @homePhaseRenewalDescription.
  ///
  /// In en, this message translates to:
  /// **'Your energy may begin to rise again.'**
  String get homePhaseRenewalDescription;

  /// No description provided for @homePhaseFertileDescription.
  ///
  /// In en, this message translates to:
  /// **'You are in a phase when your energy and fertility may be higher.'**
  String get homePhaseFertileDescription;

  /// No description provided for @homePhasePmsDescription.
  ///
  /// In en, this message translates to:
  /// **'Make time to rest and care for yourself today.'**
  String get homePhasePmsDescription;

  /// No description provided for @homePhaseRestDescription.
  ///
  /// In en, this message translates to:
  /// **'You are in a calmer phase of your cycle.'**
  String get homePhaseRestDescription;

  /// No description provided for @homeTooltipMenstruationDescription.
  ///
  /// In en, this message translates to:
  /// **'Bleeding and the beginning of your body\'s renewal process.'**
  String get homeTooltipMenstruationDescription;

  /// No description provided for @homeTooltipRenewalDescription.
  ///
  /// In en, this message translates to:
  /// **'A dynamic phase when energy and estrogen may rise.'**
  String get homeTooltipRenewalDescription;

  /// No description provided for @homeTooltipFertileDescription.
  ///
  /// In en, this message translates to:
  /// **'The phase when fertility rises and ovulation approaches.'**
  String get homeTooltipFertileDescription;

  /// No description provided for @homeTooltipRestPmsDescription.
  ///
  /// In en, this message translates to:
  /// **'A pre-period phase for slowing down and resting.'**
  String get homeTooltipRestPmsDescription;

  /// No description provided for @homeNextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get homeNextPeriod;

  /// No description provided for @homeCycleInfo.
  ///
  /// In en, this message translates to:
  /// **'My cycle information'**
  String get homeCycleInfo;

  /// No description provided for @homeCycleLengthSuffix.
  ///
  /// In en, this message translates to:
  /// **'day cycle'**
  String get homeCycleLengthSuffix;

  /// No description provided for @homePeriodShortLabel.
  ///
  /// In en, this message translates to:
  /// **'Period:'**
  String get homePeriodShortLabel;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while loading your information.'**
  String get homeLoadError;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get homeRetry;

  /// No description provided for @homePeriodExpectedToday.
  ///
  /// In en, this message translates to:
  /// **'Expected to start today'**
  String get homePeriodExpectedToday;

  /// No description provided for @homeOneDayLeft.
  ///
  /// In en, this message translates to:
  /// **'1 day left'**
  String get homeOneDayLeft;

  /// No description provided for @homeDaysLeftSuffix.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get homeDaysLeftSuffix;

  /// No description provided for @homePhaseOtherDaysName.
  ///
  /// In en, this message translates to:
  /// **'Other days'**
  String get homePhaseOtherDaysName;

  /// No description provided for @homeTooltipOtherDaysDescription.
  ///
  /// In en, this message translates to:
  /// **'Ovulation and fertility predictions are not shown for short cycles.'**
  String get homeTooltipOtherDaysDescription;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your period and cycle predictions.'**
  String get calendarSubtitle;

  /// No description provided for @calendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Calendar information could not be loaded.'**
  String get calendarLoadError;

  /// No description provided for @calendarRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get calendarRetry;

  /// No description provided for @calendarMonthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get calendarMonthJanuary;

  /// No description provided for @calendarMonthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get calendarMonthFebruary;

  /// No description provided for @calendarMonthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get calendarMonthMarch;

  /// No description provided for @calendarMonthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get calendarMonthApril;

  /// No description provided for @calendarMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get calendarMonthMay;

  /// No description provided for @calendarMonthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get calendarMonthJune;

  /// No description provided for @calendarMonthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get calendarMonthJuly;

  /// No description provided for @calendarMonthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get calendarMonthAugust;

  /// No description provided for @calendarMonthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get calendarMonthSeptember;

  /// No description provided for @calendarMonthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get calendarMonthOctober;

  /// No description provided for @calendarMonthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get calendarMonthNovember;

  /// No description provided for @calendarMonthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get calendarMonthDecember;

  /// No description provided for @calendarWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get calendarWeekdayMonday;

  /// No description provided for @calendarWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get calendarWeekdayTuesday;

  /// No description provided for @calendarWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get calendarWeekdayWednesday;

  /// No description provided for @calendarWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get calendarWeekdayThursday;

  /// No description provided for @calendarWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get calendarWeekdayFriday;

  /// No description provided for @calendarWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get calendarWeekdaySaturday;

  /// No description provided for @calendarWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get calendarWeekdaySunday;

  /// No description provided for @calendarActualPeriodStatus.
  ///
  /// In en, this message translates to:
  /// **'Actual period · Day {dayNumber}'**
  String calendarActualPeriodStatus(int dayNumber);

  /// No description provided for @calendarStartCorrectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Period starting {date} · start can be moved back {daysEarlier} day(s)'**
  String calendarStartCorrectionStatus(String date, int daysEarlier);

  /// No description provided for @calendarEndCorrectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Period starting {date} · can end on day {dayNumber}'**
  String calendarEndCorrectionStatus(String date, int dayNumber);

  /// No description provided for @calendarPredictedPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Predicted period day'**
  String get calendarPredictedPeriodDay;

  /// No description provided for @calendarEstimatedOvulationStatus.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {dayNumber} · Estimated ovulation day'**
  String calendarEstimatedOvulationStatus(int dayNumber);

  /// No description provided for @calendarEstimatedPhaseStatus.
  ///
  /// In en, this message translates to:
  /// **'Cycle day {dayNumber} · {phaseName}'**
  String calendarEstimatedPhaseStatus(int dayNumber, String phaseName);

  /// No description provided for @calendarNoRecord.
  ///
  /// In en, this message translates to:
  /// **'No record'**
  String get calendarNoRecord;

  /// No description provided for @calendarFutureDateInfo.
  ///
  /// In en, this message translates to:
  /// **'Future dates are for viewing predictions only. Period records cannot be added to these dates.'**
  String get calendarFutureDateInfo;

  /// No description provided for @calendarRemovePeriodRecord.
  ///
  /// In en, this message translates to:
  /// **'Remove period record'**
  String get calendarRemovePeriodRecord;

  /// No description provided for @calendarLastPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'My last period day'**
  String get calendarLastPeriodDay;

  /// No description provided for @calendarPeriodStartCorrectionInfo.
  ///
  /// In en, this message translates to:
  /// **'You can move the start of the period record that began on {date} to this date. This will not create a new historical record.'**
  String calendarPeriodStartCorrectionInfo(String date);

  /// No description provided for @calendarPeriodEndExtensionInfo.
  ///
  /// In en, this message translates to:
  /// **'You can extend the period record that began on {date} to this date. The days in between will also be marked as actual period days.'**
  String calendarPeriodEndExtensionInfo(String date);

  /// No description provided for @calendarUnfinishedPeriodInfo.
  ///
  /// In en, this message translates to:
  /// **'The previous period record has no end date. If a new record is added, the previous record will automatically be treated as {days} days long.'**
  String calendarUnfinishedPeriodInfo(int days);

  /// No description provided for @calendarAddHistoricalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add Past Period Record'**
  String get calendarAddHistoricalPeriod;

  /// No description provided for @calendarStartNewPeriod.
  ///
  /// In en, this message translates to:
  /// **'Start New Period'**
  String get calendarStartNewPeriod;

  /// No description provided for @calendarPeriodStarted.
  ///
  /// In en, this message translates to:
  /// **'Period Started'**
  String get calendarPeriodStarted;

  /// No description provided for @calendarUpdateStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Update your period start?'**
  String get calendarUpdateStartTitle;

  /// No description provided for @calendarOldStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous start'**
  String get calendarOldStartLabel;

  /// No description provided for @calendarNewStartLabel.
  ///
  /// In en, this message translates to:
  /// **'New start'**
  String get calendarNewStartLabel;

  /// No description provided for @calendarUpdateStartDescription.
  ///
  /// In en, this message translates to:
  /// **'The start of the existing period record will be moved back by {daysEarlier} day(s). A new historical period record will not be created.'**
  String calendarUpdateStartDescription(int daysEarlier);

  /// No description provided for @calendarCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calendarCancel;

  /// No description provided for @calendarUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get calendarUpdate;

  /// No description provided for @calendarStartUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your period start was updated to {date}.'**
  String calendarStartUpdatedMessage(String date);

  /// No description provided for @calendarStartOverlapError.
  ///
  /// In en, this message translates to:
  /// **'The new start date overlaps another period record.'**
  String get calendarStartOverlapError;

  /// No description provided for @calendarPeriodTooLongAfterStartError.
  ///
  /// In en, this message translates to:
  /// **'This change could not be saved because it would make the period longer than {maxDays} days.'**
  String calendarPeriodTooLongAfterStartError(int maxDays);

  /// No description provided for @calendarStartUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The period start date could not be updated.'**
  String get calendarStartUpdateError;

  /// No description provided for @calendarFutureAddError.
  ///
  /// In en, this message translates to:
  /// **'A period record cannot be added to a future date.'**
  String get calendarFutureAddError;

  /// No description provided for @calendarAlreadyPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'This date is already a period day'**
  String get calendarAlreadyPeriodTitle;

  /// No description provided for @calendarAlreadyPeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'You selected day {dayNumber} of the period record that began on {date}. A new period start cannot be added within these days.'**
  String calendarAlreadyPeriodDescription(int dayNumber, String date);

  /// No description provided for @calendarOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get calendarOk;

  /// No description provided for @calendarUnfinishedRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'There is a period record without an end date'**
  String get calendarUnfinishedRecordTitle;

  /// No description provided for @calendarUnfinishedRecordBase.
  ///
  /// In en, this message translates to:
  /// **'The previous record that began on {date} will automatically be treated as {days} days long.'**
  String calendarUnfinishedRecordBase(String date, int days);

  /// No description provided for @calendarNewHistoricalRecordOutcome.
  ///
  /// In en, this message translates to:
  /// **'The new record on {date} will also be added as a {days}-day historical record.'**
  String calendarNewHistoricalRecordOutcome(String date, int days);

  /// No description provided for @calendarNewOngoingRecordOutcome.
  ///
  /// In en, this message translates to:
  /// **'The new record on {date} will be started as an ongoing period.'**
  String calendarNewOngoingRecordOutcome(String date);

  /// No description provided for @calendarConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get calendarConfirm;

  /// No description provided for @calendarAddHistoricalTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a past period record?'**
  String get calendarAddHistoricalTitle;

  /// No description provided for @calendarStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get calendarStartLabel;

  /// No description provided for @calendarEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get calendarEndLabel;

  /// No description provided for @calendarHistoricalDurationInfo.
  ///
  /// In en, this message translates to:
  /// **'The period duration for this historical record will automatically be set to {days} days. Your other period records will not change.'**
  String calendarHistoricalDurationInfo(int days);

  /// No description provided for @calendarAddRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get calendarAddRecord;

  /// No description provided for @calendarOverlapError.
  ///
  /// In en, this message translates to:
  /// **'This date range overlaps another period record.'**
  String get calendarOverlapError;

  /// No description provided for @calendarHistoricalAdded.
  ///
  /// In en, this message translates to:
  /// **'The past period record dated {date} was added as a {days}-day record.'**
  String calendarHistoricalAdded(String date, int days);

  /// No description provided for @calendarHistoricalAddError.
  ///
  /// In en, this message translates to:
  /// **'The past period record could not be added.'**
  String get calendarHistoricalAddError;

  /// No description provided for @calendarPreviousCompletedAndHistoricalAdded.
  ///
  /// In en, this message translates to:
  /// **'The previous record was completed as {days} days, and the new historical record was also added as {days} days.'**
  String calendarPreviousCompletedAndHistoricalAdded(int days);

  /// No description provided for @calendarPreviousCompletedAndNewStarted.
  ///
  /// In en, this message translates to:
  /// **'The previous record was completed as {days} days, and a new period was started.'**
  String calendarPreviousCompletedAndNewStarted(int days);

  /// No description provided for @calendarSelectedDateOverlapError.
  ///
  /// In en, this message translates to:
  /// **'The selected date overlaps the {days}-day range of an existing period record.'**
  String calendarSelectedDateOverlapError(int days);

  /// No description provided for @calendarNewStartSaveError.
  ///
  /// In en, this message translates to:
  /// **'The new period start could not be saved.'**
  String get calendarNewStartSaveError;

  /// No description provided for @calendarNewCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'🌙 New Cycle'**
  String get calendarNewCycleTitle;

  /// No description provided for @calendarConfirmStart.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm that your period started on {date}?'**
  String calendarConfirmStart(String date);

  /// No description provided for @calendarTemporaryRecordInfo.
  ///
  /// In en, this message translates to:
  /// **'W will create a temporary {days}-day record for now.'**
  String calendarTemporaryRecordInfo(int days);

  /// No description provided for @calendarPeriodStartSaved.
  ///
  /// In en, this message translates to:
  /// **'Your period start was saved.'**
  String get calendarPeriodStartSaved;

  /// No description provided for @calendarOngoingExistsError.
  ///
  /// In en, this message translates to:
  /// **'There is already an ongoing period record.'**
  String get calendarOngoingExistsError;

  /// No description provided for @calendarDateAlreadyHasRecordError.
  ///
  /// In en, this message translates to:
  /// **'A period record already exists for this date.'**
  String get calendarDateAlreadyHasRecordError;

  /// No description provided for @calendarPeriodStartSaveError.
  ///
  /// In en, this message translates to:
  /// **'Your period start could not be saved.'**
  String get calendarPeriodStartSaveError;

  /// No description provided for @calendarPeriodEndSaved.
  ///
  /// In en, this message translates to:
  /// **'Your period end date was saved as {date}.'**
  String calendarPeriodEndSaved(String date);

  /// No description provided for @calendarPeriodEndTooLongError.
  ///
  /// In en, this message translates to:
  /// **'A period cannot be saved as longer than {maxDays} days. You can use the Start New Period option instead.'**
  String calendarPeriodEndTooLongError(int maxDays);

  /// No description provided for @calendarPeriodEndSaveError.
  ///
  /// In en, this message translates to:
  /// **'The period end date could not be saved.'**
  String get calendarPeriodEndSaveError;

  /// No description provided for @calendarConfirmLastDayTitle.
  ///
  /// In en, this message translates to:
  /// **'Save your last period day?'**
  String get calendarConfirmLastDayTitle;

  /// No description provided for @calendarLastDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Last period day'**
  String get calendarLastDayLabel;

  /// No description provided for @calendarTotalDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get calendarTotalDurationLabel;

  /// No description provided for @calendarDayCount.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String calendarDayCount(int days);

  /// No description provided for @calendarSaveRealDurationInfo.
  ///
  /// In en, this message translates to:
  /// **'This duration will be saved as your actual period length and used for future predictions.'**
  String get calendarSaveRealDurationInfo;

  /// No description provided for @calendarLastDaySaved.
  ///
  /// In en, this message translates to:
  /// **'Your last period day was saved as {date}. Your period lasted {days} days.'**
  String calendarLastDaySaved(String date, int days);

  /// No description provided for @calendarPeriodLengthRangeError.
  ///
  /// In en, this message translates to:
  /// **'The period length must be between 1 and {maxDays} days.'**
  String calendarPeriodLengthRangeError(int maxDays);

  /// No description provided for @calendarPeriodEndUpdateError.
  ///
  /// In en, this message translates to:
  /// **'The period end date could not be updated.'**
  String get calendarPeriodEndUpdateError;

  /// No description provided for @calendarRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove period record?'**
  String get calendarRemoveTitle;

  /// No description provided for @calendarRemoveDescription.
  ///
  /// In en, this message translates to:
  /// **'The record that began on {date} will be removed.'**
  String calendarRemoveDescription(String date);

  /// No description provided for @calendarRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get calendarRemove;

  /// No description provided for @calendarRemoved.
  ///
  /// In en, this message translates to:
  /// **'The period record was removed.'**
  String get calendarRemoved;

  /// No description provided for @calendarRemoveError.
  ///
  /// In en, this message translates to:
  /// **'The period record could not be removed.'**
  String get calendarRemoveError;

  /// No description provided for @calendarLegendActualPeriod.
  ///
  /// In en, this message translates to:
  /// **'Actual period'**
  String get calendarLegendActualPeriod;

  /// No description provided for @calendarLegendPredictedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Predicted period'**
  String get calendarLegendPredictedPeriod;

  /// No description provided for @calendarLegendFertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Estimated fertile window'**
  String get calendarLegendFertileWindow;

  /// No description provided for @calendarLegendPmsPhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated PMS phase'**
  String get calendarLegendPmsPhase;

  /// No description provided for @calendarPredictionDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Cycle, PMS, fertile window, and ovulation information are approximate predictions and are not medical advice or a method of contraception.'**
  String get calendarPredictionDisclaimer;

  /// No description provided for @calendarEstimatedMenstruationPhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated period phase'**
  String get calendarEstimatedMenstruationPhase;

  /// No description provided for @calendarEstimatedRenewalPhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated renewal phase'**
  String get calendarEstimatedRenewalPhase;

  /// No description provided for @calendarEstimatedFertilePhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated fertile window'**
  String get calendarEstimatedFertilePhase;

  /// No description provided for @calendarEstimatedPmsPhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated PMS phase'**
  String get calendarEstimatedPmsPhase;

  /// No description provided for @calendarEstimatedRestPhase.
  ///
  /// In en, this message translates to:
  /// **'Estimated rest phase'**
  String get calendarEstimatedRestPhase;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you want to use in Within'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsLanguageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get settingsLanguageTurkish;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
