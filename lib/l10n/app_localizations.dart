import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Mother'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Safe Mother'**
  String get welcomeMessage;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @privacySettings.
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// No description provided for @myDoctors.
  ///
  /// In en, this message translates to:
  /// **'My Doctors'**
  String get myDoctors;

  /// No description provided for @familyDoctorLink.
  ///
  /// In en, this message translates to:
  /// **'Family & Doctor Link'**
  String get familyDoctorLink;

  /// No description provided for @linkFamilyMembers.
  ///
  /// In en, this message translates to:
  /// **'Link Family Members'**
  String get linkFamilyMembers;

  /// No description provided for @linkDoctors.
  ///
  /// In en, this message translates to:
  /// **'Link Doctors'**
  String get linkDoctors;

  /// No description provided for @patientId.
  ///
  /// In en, this message translates to:
  /// **'Patient ID'**
  String get patientId;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @patientIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Patient ID copied to clipboard'**
  String get patientIdCopied;

  /// No description provided for @copyPatientId.
  ///
  /// In en, this message translates to:
  /// **'Copy Patient ID'**
  String get copyPatientId;

  /// No description provided for @sharePatientId.
  ///
  /// In en, this message translates to:
  /// **'Share your Patient ID with family members so they can register and link their accounts to receive updates about your pregnancy journey.'**
  String get sharePatientId;

  /// No description provided for @familyMembersInfo.
  ///
  /// In en, this message translates to:
  /// **'Family members can use this ID during registration to create linked accounts and receive pregnancy updates.'**
  String get familyMembersInfo;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @safeMotherPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Safe Mother Privacy'**
  String get safeMotherPrivacy;

  /// No description provided for @privacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your privacy and safety are our top priority. We ensure that your personal and medical information is securely protected and never shared without your consent. Safe Mother safeguards your details to provide you with confidential and trusted care.'**
  String get privacyDescription;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of your account?'**
  String get signOutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @signOutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully signed out'**
  String get signOutSuccess;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully!'**
  String get passwordChanged;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @noDoctorsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No Doctors Assigned'**
  String get noDoctorsAssigned;

  /// No description provided for @connectDoctors.
  ///
  /// In en, this message translates to:
  /// **'Connect with healthcare providers to get personalized care and guidance throughout your pregnancy journey.'**
  String get connectDoctors;

  /// No description provided for @findDoctor.
  ///
  /// In en, this message translates to:
  /// **'Find a Doctor'**
  String get findDoctor;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @selectDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get selectDoctor;

  /// No description provided for @currentlyLinked.
  ///
  /// In en, this message translates to:
  /// **'Currently Linked:'**
  String get currentlyLinked;

  /// No description provided for @selectNewDoctor.
  ///
  /// In en, this message translates to:
  /// **'Select a new doctor to change your current selection:'**
  String get selectNewDoctor;

  /// No description provided for @selectDoctorGuide.
  ///
  /// In en, this message translates to:
  /// **'Select a doctor to guide your pregnancy journey:'**
  String get selectDoctorGuide;

  /// No description provided for @noDoctorsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No doctors available'**
  String get noDoctorsAvailable;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @sendNewRequest.
  ///
  /// In en, this message translates to:
  /// **'Send New Request'**
  String get sendNewRequest;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent to {doctorName}. Waiting for approval.'**
  String requestSent(Object doctorName);

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send request to doctor'**
  String get requestFailed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePasswordTitle;

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

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter current password'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter new password'**
  String get enterNewPassword;

  /// No description provided for @passwordsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get passwordsNotMatch;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @feelingWell.
  ///
  /// In en, this message translates to:
  /// **'Hope you\'re feeling well today'**
  String get feelingWell;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @todaysReminders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Reminders'**
  String get todaysReminders;

  /// No description provided for @noRemindersToday.
  ///
  /// In en, this message translates to:
  /// **'No reminders for today'**
  String get noRemindersToday;

  /// No description provided for @upcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No description provided for @noUpcomingAppointments.
  ///
  /// In en, this message translates to:
  /// **'No Upcoming Appointments'**
  String get noUpcomingAppointments;

  /// No description provided for @recentMedicalRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Medical Records'**
  String get recentMedicalRecords;

  /// No description provided for @noRecentRecords.
  ///
  /// In en, this message translates to:
  /// **'No recent medical records'**
  String get noRecentRecords;

  /// No description provided for @bookAppointment.
  ///
  /// In en, this message translates to:
  /// **'Book\nAppointment'**
  String get bookAppointment;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminder;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @healthTips.
  ///
  /// In en, this message translates to:
  /// **'Health Tips'**
  String get healthTips;

  /// No description provided for @appointmentBookingComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Appointment booking feature coming soon!'**
  String get appointmentBookingComingSoon;

  /// No description provided for @addReminderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Add reminder feature coming soon!'**
  String get addReminderComingSoon;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @hospital.
  ///
  /// In en, this message translates to:
  /// **'Hospital'**
  String get hospital;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @stayHydrated.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated - drink plenty of water'**
  String get stayHydrated;

  /// No description provided for @eatNutritious.
  ///
  /// In en, this message translates to:
  /// **'Eat nutritious meals regularly'**
  String get eatNutritious;

  /// No description provided for @getAdequateRest.
  ///
  /// In en, this message translates to:
  /// **'Get adequate rest (7-9 hours)'**
  String get getAdequateRest;

  /// No description provided for @lightExercise.
  ///
  /// In en, this message translates to:
  /// **'Light exercise as approved by doctor'**
  String get lightExercise;

  /// No description provided for @learnAndTips.
  ///
  /// In en, this message translates to:
  /// **'Learn & Tips'**
  String get learnAndTips;

  /// No description provided for @todaysFeaturedTip.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Featured Tip'**
  String get todaysFeaturedTip;

  /// No description provided for @readFullArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Full Article'**
  String get readFullArticle;

  /// No description provided for @noTipsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tips available in this category'**
  String get noTipsAvailable;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get readMore;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get keyPoints;

  /// No description provided for @detailedInformation.
  ///
  /// In en, this message translates to:
  /// **'Detailed Information'**
  String get detailedInformation;

  /// No description provided for @todayMealPreference.
  ///
  /// In en, this message translates to:
  /// **'Today Meal Preference'**
  String get todayMealPreference;

  /// No description provided for @doctorRecommended.
  ///
  /// In en, this message translates to:
  /// **'Doctor Recommended'**
  String get doctorRecommended;

  /// No description provided for @noMealPrescribed.
  ///
  /// In en, this message translates to:
  /// **'No Meal Prescribed'**
  String get noMealPrescribed;

  /// No description provided for @noMealPrescribedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your doctor hasn\'t prescribed any specific meals yet.'**
  String get noMealPrescribedDesc;

  /// No description provided for @todayExercisePreference.
  ///
  /// In en, this message translates to:
  /// **'Today Exercise Preference'**
  String get todayExercisePreference;

  /// No description provided for @noExercisePrescribed.
  ///
  /// In en, this message translates to:
  /// **'No Exercise Prescribed'**
  String get noExercisePrescribed;

  /// No description provided for @noExercisePrescribedDesc.
  ///
  /// In en, this message translates to:
  /// **'Your doctor hasn\'t prescribed any exercises yet.'**
  String get noExercisePrescribedDesc;

  /// No description provided for @logSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// No description provided for @healthLog.
  ///
  /// In en, this message translates to:
  /// **'Health Log'**
  String get healthLog;

  /// No description provided for @recentHealthLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent Health Logs'**
  String get recentHealthLogs;

  /// No description provided for @noHealthLogsYet.
  ///
  /// In en, this message translates to:
  /// **'No Health Logs Yet'**
  String get noHealthLogsYet;

  /// No description provided for @startLoggingHealthData.
  ///
  /// In en, this message translates to:
  /// **'Start logging your health data to see your history here'**
  String get startLoggingHealthData;

  /// No description provided for @contactYourDoctors.
  ///
  /// In en, this message translates to:
  /// **'Contact Your Doctors'**
  String get contactYourDoctors;

  /// No description provided for @noDoctorsLinked.
  ///
  /// In en, this message translates to:
  /// **'No Doctors Linked'**
  String get noDoctorsLinked;

  /// No description provided for @linkDoctorFirst.
  ///
  /// In en, this message translates to:
  /// **'Please link with a doctor first to enable emergency contact.'**
  String get linkDoctorFirst;

  /// No description provided for @callDoctor.
  ///
  /// In en, this message translates to:
  /// **'Call Doctor'**
  String get callDoctor;

  /// No description provided for @pleaseCallNumber.
  ///
  /// In en, this message translates to:
  /// **'Please call this number:'**
  String get pleaseCallNumber;

  /// No description provided for @todaysHealthCheck.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Health Check'**
  String get todaysHealthCheck;

  /// No description provided for @bloodPressureExample.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure (e.g., 120/80)'**
  String get bloodPressureExample;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @babyKicksCounter.
  ///
  /// In en, this message translates to:
  /// **'Baby Kicks Counter'**
  String get babyKicksCounter;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @symptomsIfAny.
  ///
  /// In en, this message translates to:
  /// **'Symptoms (if any)'**
  String get symptomsIfAny;

  /// No description provided for @sleepHoursExample.
  ///
  /// In en, this message translates to:
  /// **'Sleep Hours (e.g., 8)'**
  String get sleepHoursExample;

  /// No description provided for @waterIntakeGlasses.
  ///
  /// In en, this message translates to:
  /// **'Water Intake (glasses/day)'**
  String get waterIntakeGlasses;

  /// No description provided for @exerciseMinutesDaily.
  ///
  /// In en, this message translates to:
  /// **'Exercise Minutes (daily)'**
  String get exerciseMinutesDaily;

  /// No description provided for @energyLevel.
  ///
  /// In en, this message translates to:
  /// **'Energy Level'**
  String get energyLevel;

  /// No description provided for @appetiteLevel.
  ///
  /// In en, this message translates to:
  /// **'Appetite'**
  String get appetiteLevel;

  /// No description provided for @painLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain Level'**
  String get painLevel;

  /// No description provided for @healthIndicators.
  ///
  /// In en, this message translates to:
  /// **'Health Indicators'**
  String get healthIndicators;

  /// No description provided for @hadContractions.
  ///
  /// In en, this message translates to:
  /// **'Had Contractions'**
  String get hadContractions;

  /// No description provided for @hadHeadaches.
  ///
  /// In en, this message translates to:
  /// **'Had Headaches'**
  String get hadHeadaches;

  /// No description provided for @hadSwelling.
  ///
  /// In en, this message translates to:
  /// **'Had Swelling'**
  String get hadSwelling;

  /// No description provided for @tookVitamins.
  ///
  /// In en, this message translates to:
  /// **'Took Vitamins'**
  String get tookVitamins;

  /// No description provided for @nauseaDetailsIfAny.
  ///
  /// In en, this message translates to:
  /// **'Nausea Details (if any)'**
  String get nauseaDetailsIfAny;

  /// No description provided for @currentMedications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get currentMedications;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @saveHealthLog.
  ///
  /// In en, this message translates to:
  /// **'Save Health Log'**
  String get saveHealthLog;

  /// No description provided for @pregnancyAssistant.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Assistant'**
  String get pregnancyAssistant;

  /// No description provided for @aiPoweredSupport.
  ///
  /// In en, this message translates to:
  /// **'AI-powered support'**
  String get aiPoweredSupport;

  /// No description provided for @askPregnancyQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a pregnancy-related question...'**
  String get askPregnancyQuestion;

  /// No description provided for @commonPregnancyQuestions.
  ///
  /// In en, this message translates to:
  /// **'Common Pregnancy Questions'**
  String get commonPregnancyQuestions;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @pregnancyAssistantSender.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Assistant'**
  String get pregnancyAssistantSender;

  /// No description provided for @avoidFoodsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What foods should I avoid during pregnancy?'**
  String get avoidFoodsQuestion;

  /// No description provided for @safeExercisesQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are safe exercises for the third trimester?'**
  String get safeExercisesQuestion;

  /// No description provided for @relieveMorningSicknessQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can I relieve morning sickness?'**
  String get relieveMorningSicknessQuestion;

  /// No description provided for @pretermLaborSignsQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are the signs of preterm labor?'**
  String get pretermLaborSignsQuestion;

  /// No description provided for @weightGainQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much weight should I gain during pregnancy?'**
  String get weightGainQuestion;

  /// No description provided for @healthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Health Assessment'**
  String get healthAssessment;

  /// No description provided for @assessmentResults.
  ///
  /// In en, this message translates to:
  /// **'Assessment Results:'**
  String get assessmentResults;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations:'**
  String get recommendations;

  /// No description provided for @highRiskDetected.
  ///
  /// In en, this message translates to:
  /// **'High risk detected! Please contact your healthcare provider immediately.'**
  String get highRiskDetected;

  /// No description provided for @contactDoctor.
  ///
  /// In en, this message translates to:
  /// **'Contact Doctor'**
  String get contactDoctor;

  /// No description provided for @healthInfoSaved.
  ///
  /// In en, this message translates to:
  /// **'Health information saved and analyzed successfully!'**
  String get healthInfoSaved;

  /// No description provided for @errorSavingHealthInfo.
  ///
  /// In en, this message translates to:
  /// **'Error saving health information: {error}'**
  String errorSavingHealthInfo(Object error);

  /// No description provided for @phoneNumberNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Phone number not available'**
  String get phoneNumberNotAvailable;

  /// No description provided for @unableToMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Unable to make call: {error}'**
  String unableToMakeCall(Object error);

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @bpLabel.
  ///
  /// In en, this message translates to:
  /// **'BP'**
  String get bpLabel;

  /// No description provided for @kicksLabel.
  ///
  /// In en, this message translates to:
  /// **'Kicks'**
  String get kicksLabel;

  /// No description provided for @sleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepLabel;

  /// No description provided for @symptomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Symptoms: {symptoms}'**
  String symptomsLabel(Object symptoms);

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String notesLabel(Object notes);

  /// No description provided for @enterBloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Please enter your blood pressure'**
  String get enterBloodPressure;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter your weight'**
  String get enterWeight;

  /// No description provided for @enterSleepHours.
  ///
  /// In en, this message translates to:
  /// **'Please enter sleep hours'**
  String get enterSleepHours;

  /// No description provided for @enterWaterIntake.
  ///
  /// In en, this message translates to:
  /// **'Please enter water intake'**
  String get enterWaterIntake;

  /// No description provided for @enterExerciseMinutes.
  ///
  /// In en, this message translates to:
  /// **'Please enter exercise minutes'**
  String get enterExerciseMinutes;

  /// No description provided for @errorLoadingDoctors.
  ///
  /// In en, this message translates to:
  /// **'Error loading doctors: {error}'**
  String errorLoadingDoctors(Object error);

  /// No description provided for @startYourPregnancyJourney.
  ///
  /// In en, this message translates to:
  /// **'Start Your Pregnancy Journey'**
  String get startYourPregnancyJourney;

  /// No description provided for @completePregnancyDetails.
  ///
  /// In en, this message translates to:
  /// **'Complete your pregnancy details in your profile to start tracking your journey.'**
  String get completePregnancyDetails;

  /// No description provided for @setupPregnancyTracking.
  ///
  /// In en, this message translates to:
  /// **'Setup Pregnancy Tracking'**
  String get setupPregnancyTracking;

  /// No description provided for @yourPregnancyJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Pregnancy Journey'**
  String get yourPregnancyJourney;

  /// No description provided for @trimesterLabel.
  ///
  /// In en, this message translates to:
  /// **'{trimester} Trimester'**
  String trimesterLabel(Object trimester);

  /// No description provided for @weeksLabel.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeksLabel;

  /// No description provided for @expectedDueDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Due Date'**
  String get expectedDueDate;

  /// No description provided for @thisWeeksDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Development'**
  String get thisWeeksDevelopment;

  /// No description provided for @viewFullJourney.
  ///
  /// In en, this message translates to:
  /// **'View Full Journey'**
  String get viewFullJourney;

  /// No description provided for @pregnancyMilestones.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Milestones'**
  String get pregnancyMilestones;

  /// No description provided for @heartBegins.
  ///
  /// In en, this message translates to:
  /// **'Heart Begins'**
  String get heartBegins;

  /// No description provided for @allOrgans.
  ///
  /// In en, this message translates to:
  /// **'All Organs'**
  String get allOrgans;

  /// No description provided for @endFirstTrimester.
  ///
  /// In en, this message translates to:
  /// **'End 1st Trimester'**
  String get endFirstTrimester;

  /// No description provided for @halfwayPoint.
  ///
  /// In en, this message translates to:
  /// **'Halfway Point'**
  String get halfwayPoint;

  /// No description provided for @viability.
  ///
  /// In en, this message translates to:
  /// **'Viability'**
  String get viability;

  /// No description provided for @eyesOpen.
  ///
  /// In en, this message translates to:
  /// **'Eyes Open'**
  String get eyesOpen;

  /// No description provided for @rapidGrowth.
  ///
  /// In en, this message translates to:
  /// **'Rapid Growth'**
  String get rapidGrowth;

  /// No description provided for @fullTermSoon.
  ///
  /// In en, this message translates to:
  /// **'Full Term Soon'**
  String get fullTermSoon;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @babyGrowing.
  ///
  /// In en, this message translates to:
  /// **'{babyName} is growing!'**
  String babyGrowing(Object babyName);

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {totalDays}'**
  String dayLabel(Object totalDays);

  /// No description provided for @weeksDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks, {days} days'**
  String weeksDaysLabel(Object days, Object weeks);

  /// No description provided for @timeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{weeksRemaining} weeks, {daysRemaining} days to go'**
  String timeRemaining(Object daysRemaining, Object weeksRemaining);

  /// No description provided for @progressComplete.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% complete ({totalDays}/280 days)'**
  String progressComplete(Object percentage, Object totalDays);

  /// No description provided for @babyDevWeek4.
  ///
  /// In en, this message translates to:
  /// **'Your baby is just beginning to develop. The fertilized egg is implanting in your uterus.'**
  String get babyDevWeek4;

  /// No description provided for @babyDevWeek8.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s heart is starting to beat and major organs are beginning to form.'**
  String get babyDevWeek8;

  /// No description provided for @babyDevWeek12.
  ///
  /// In en, this message translates to:
  /// **'Your baby is now about the size of a lime and all major organs are formed.'**
  String get babyDevWeek12;

  /// No description provided for @babyDevWeek16.
  ///
  /// In en, this message translates to:
  /// **'Your baby can now make facial expressions and may even be sucking their thumb.'**
  String get babyDevWeek16;

  /// No description provided for @babyDevWeek20.
  ///
  /// In en, this message translates to:
  /// **'Your baby is about the size of a banana and you might start feeling movement soon.'**
  String get babyDevWeek20;

  /// No description provided for @babyDevWeek24.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s hearing is developing and they can hear your voice and heartbeat.'**
  String get babyDevWeek24;

  /// No description provided for @babyDevWeek28.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s eyes can now open and close, and they may have hiccups.'**
  String get babyDevWeek28;

  /// No description provided for @babyDevWeek32.
  ///
  /// In en, this message translates to:
  /// **'Your baby is gaining weight rapidly and their bones are hardening.'**
  String get babyDevWeek32;

  /// No description provided for @babyDevWeek36.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s lungs are maturing and they\'re getting ready for life outside the womb.'**
  String get babyDevWeek36;

  /// No description provided for @babyDevWeek40.
  ///
  /// In en, this message translates to:
  /// **'Your baby is full-term and ready to meet you! They could arrive any day now.'**
  String get babyDevWeek40;

  /// No description provided for @consultation.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultation;

  /// No description provided for @loadingConsultationData.
  ///
  /// In en, this message translates to:
  /// **'Loading consultation data...'**
  String get loadingConsultationData;

  /// No description provided for @yourDoctors.
  ///
  /// In en, this message translates to:
  /// **'Your Doctors'**
  String get yourDoctors;

  /// No description provided for @quickChat.
  ///
  /// In en, this message translates to:
  /// **'Quick\nChat'**
  String get quickChat;

  /// No description provided for @noDoctorsLinkedDesc.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t linked with any doctors yet. Visit your profile to send connection requests to healthcare professionals.'**
  String get noDoctorsLinkedDesc;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @scheduleAppointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule an appointment with your doctor'**
  String get scheduleAppointment;

  /// No description provided for @chooseYourDoctor.
  ///
  /// In en, this message translates to:
  /// **'Choose your doctor'**
  String get chooseYourDoctor;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @chooseAppointmentDate.
  ///
  /// In en, this message translates to:
  /// **'Choose appointment date'**
  String get chooseAppointmentDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @reasonForVisit.
  ///
  /// In en, this message translates to:
  /// **'Reason for Visit'**
  String get reasonForVisit;

  /// No description provided for @appointmentExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Regular checkup, Consultation'**
  String get appointmentExample;

  /// No description provided for @additionalNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes (Optional)'**
  String get additionalNotesOptional;

  /// No description provided for @specificConcerns.
  ///
  /// In en, this message translates to:
  /// **'Any specific concerns or information'**
  String get specificConcerns;

  /// No description provided for @bookAppointmentButton.
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointmentButton;

  /// No description provided for @appointmentBookedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Appointment booked successfully!'**
  String get appointmentBookedSuccess;

  /// No description provided for @quickChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Chat'**
  String get quickChatTitle;

  /// No description provided for @chooseDoctorChat.
  ///
  /// In en, this message translates to:
  /// **'Choose a doctor to start chatting:'**
  String get chooseDoctorChat;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @linkDoctorFirstChat.
  ///
  /// In en, this message translates to:
  /// **'Please link with a doctor first to start chatting'**
  String get linkDoctorFirstChat;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with\nDr. {doctorName}'**
  String startConversation(Object doctorName);

  /// No description provided for @messagesSecure.
  ///
  /// In en, this message translates to:
  /// **'Your messages are secure and private'**
  String get messagesSecure;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @failedSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message. Please try again.'**
  String get failedSendMessage;

  /// No description provided for @goToProfileSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → Settings → Link with Doctors'**
  String get goToProfileSettings;

  /// No description provided for @safeMotherTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Mother'**
  String get safeMotherTitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @mealDescription.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get mealDescription;

  /// No description provided for @nutritionalBenefits.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Benefits:'**
  String get nutritionalBenefits;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients:'**
  String get ingredients;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation:'**
  String get preparation;

  /// No description provided for @safeForPregnancy.
  ///
  /// In en, this message translates to:
  /// **'Safe for Pregnancy'**
  String get safeForPregnancy;

  /// No description provided for @difficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty}'**
  String difficultyLabel(Object difficulty);

  /// No description provided for @exerciseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description:'**
  String get exerciseDescription;

  /// No description provided for @exerciseBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits:'**
  String get exerciseBenefits;

  /// No description provided for @safeFor.
  ///
  /// In en, this message translates to:
  /// **'Safe for:'**
  String get safeFor;

  /// No description provided for @consultDoctorBefore.
  ///
  /// In en, this message translates to:
  /// **'Consult with your doctor before performing'**
  String get consultDoctorBefore;

  /// No description provided for @safeMotherLearn.
  ///
  /// In en, this message translates to:
  /// **'Safe Mother - Learn'**
  String get safeMotherLearn;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @pregnancy.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy'**
  String get pregnancy;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @baby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get baby;

  /// No description provided for @parenting.
  ///
  /// In en, this message translates to:
  /// **'Parenting'**
  String get parenting;

  /// No description provided for @failedLoadArticles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load articles. Please try again later.'**
  String get failedLoadArticles;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'No title'**
  String get noTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @publishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published: {date}'**
  String publishedLabel(Object date);

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String sourceLabel(Object source);

  /// No description provided for @articleUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Article URL is not available'**
  String get articleUrlNotAvailable;

  /// No description provided for @couldNotOpenArticle.
  ///
  /// In en, this message translates to:
  /// **'Could not open article. Error: {error}'**
  String couldNotOpenArticle(Object error);

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @searchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search articles'**
  String get searchArticles;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No Articles Found'**
  String get noArticlesFound;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @log.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get log;

  /// No description provided for @consultationNav.
  ///
  /// In en, this message translates to:
  /// **'Consultation'**
  String get consultationNav;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @pregnancyInformation.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Information'**
  String get pregnancyInformation;

  /// No description provided for @expectedDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Expected Delivery Date'**
  String get expectedDeliveryDate;

  /// No description provided for @pregnancyConfirmedDate.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Confirmed Date'**
  String get pregnancyConfirmedDate;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @firstChild.
  ///
  /// In en, this message translates to:
  /// **'First Child'**
  String get firstChild;

  /// No description provided for @previousPregnancyLoss.
  ///
  /// In en, this message translates to:
  /// **'Previous Pregnancy Loss'**
  String get previousPregnancyLoss;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @allergiesCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Allergies (comma separated)'**
  String get allergiesCommaSeparated;

  /// No description provided for @emergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Name'**
  String get emergencyContactName;

  /// No description provided for @emergencyContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Phone'**
  String get emergencyContactPhone;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @enterValidAge.
  ///
  /// In en, this message translates to:
  /// **'Enter valid age'**
  String get enterValidAge;

  /// No description provided for @pleaseEnterValidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get pleaseEnterValidPhoneNumber;

  /// No description provided for @allergiesExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Penicillin, Peanuts, Shellfish'**
  String get allergiesExample;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pregnancyJourney.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy Journey'**
  String get pregnancyJourney;

  /// No description provided for @setupYourPregnancyJourney.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Pregnancy Journey'**
  String get setupYourPregnancyJourney;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'Total Days'**
  String get totalDays;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'WEEKS'**
  String get weeks;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @dueDateOverdue.
  ///
  /// In en, this message translates to:
  /// **'Due Date (Overdue)'**
  String get dueDateOverdue;

  /// No description provided for @babyCanArriveAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Baby can arrive any time now!'**
  String get babyCanArriveAnyTime;

  /// No description provided for @trimesterProgress.
  ///
  /// In en, this message translates to:
  /// **'Trimester Progress'**
  String get trimesterProgress;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week {current} of {total}'**
  String weekOf(Object current, Object total);

  /// No description provided for @heartBeginsBeating.
  ///
  /// In en, this message translates to:
  /// **'Heart Begins Beating'**
  String get heartBeginsBeating;

  /// No description provided for @heartBeginsBeatingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your baby\'s heart starts to beat'**
  String get heartBeginsBeatingDesc;

  /// No description provided for @allMajorOrgans.
  ///
  /// In en, this message translates to:
  /// **'All Major Organs'**
  String get allMajorOrgans;

  /// No description provided for @allMajorOrgansDesc.
  ///
  /// In en, this message translates to:
  /// **'All major organs are now formed'**
  String get allMajorOrgansDesc;

  /// No description provided for @endOfFirstTrimester.
  ///
  /// In en, this message translates to:
  /// **'End of First Trimester'**
  String get endOfFirstTrimester;

  /// No description provided for @endOfFirstTrimesterDesc.
  ///
  /// In en, this message translates to:
  /// **'Risk of miscarriage decreases significantly'**
  String get endOfFirstTrimesterDesc;

  /// No description provided for @genderDetermination.
  ///
  /// In en, this message translates to:
  /// **'Gender Determination'**
  String get genderDetermination;

  /// No description provided for @genderDeterminationDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s gender can be determined'**
  String get genderDeterminationDesc;

  /// No description provided for @halfwayPointDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'re halfway through your pregnancy!'**
  String get halfwayPointDesc;

  /// No description provided for @viabilityMilestone.
  ///
  /// In en, this message translates to:
  /// **'Viability Milestone'**
  String get viabilityMilestone;

  /// No description provided for @viabilityMilestoneDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby has a good chance of survival if born'**
  String get viabilityMilestoneDesc;

  /// No description provided for @eyesCanOpen.
  ///
  /// In en, this message translates to:
  /// **'Eyes Can Open'**
  String get eyesCanOpen;

  /// No description provided for @eyesCanOpenDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s eyes can open and close'**
  String get eyesCanOpenDesc;

  /// No description provided for @rapidWeightGain.
  ///
  /// In en, this message translates to:
  /// **'Rapid Weight Gain'**
  String get rapidWeightGain;

  /// No description provided for @rapidWeightGainDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby is gaining weight rapidly'**
  String get rapidWeightGainDesc;

  /// No description provided for @consideredFullTerm.
  ///
  /// In en, this message translates to:
  /// **'Considered Full-Term'**
  String get consideredFullTerm;

  /// No description provided for @consideredFullTermDesc.
  ///
  /// In en, this message translates to:
  /// **'Baby is now considered full-term'**
  String get consideredFullTermDesc;

  /// No description provided for @dueDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Your estimated due date arrives!'**
  String get dueDateDesc;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get completed;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @development.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get development;

  /// No description provided for @thisWeeksTips.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Tips'**
  String get thisWeeksTips;

  /// No description provided for @familyWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Supporting your loved one through this beautiful journey'**
  String get familyWelcomeMessage;

  /// No description provided for @caregiver.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiver;

  /// No description provided for @healthOverview.
  ///
  /// In en, this message translates to:
  /// **'Health Overview'**
  String get healthOverview;

  /// No description provided for @viewAllHealthData.
  ///
  /// In en, this message translates to:
  /// **'View All Health Data'**
  String get viewAllHealthData;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @lastHealthUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Health Update'**
  String get lastHealthUpdate;

  /// No description provided for @linkedPatient.
  ///
  /// In en, this message translates to:
  /// **'Linked Patient'**
  String get linkedPatient;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Patient Name'**
  String get patientName;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacySecurity;

  /// No description provided for @familyMember.
  ///
  /// In en, this message translates to:
  /// **'Family Member'**
  String get familyMember;

  /// No description provided for @linkedTo.
  ///
  /// In en, this message translates to:
  /// **'Linked to'**
  String get linkedTo;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @enterYour.
  ///
  /// In en, this message translates to:
  /// **'Enter your'**
  String get enterYour;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long!'**
  String get passwordMinLength;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdated;

  /// No description provided for @failedUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to update password'**
  String get failedUpdatePassword;

  /// No description provided for @privacyDescriptionFamily.
  ///
  /// In en, this message translates to:
  /// **'Your privacy and the security of {patientName}\'s medical information are our top priority. All data is encrypted and stored securely. Family members can only access information that is explicitly shared with them.'**
  String privacyDescriptionFamily(Object patientName);

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'updated successfully!'**
  String get updatedSuccessfully;

  /// No description provided for @failedUpdateField.
  ///
  /// In en, this message translates to:
  /// **'Failed to update {field}: {error}'**
  String failedUpdateField(Object error, Object field);

  /// No description provided for @errorSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {error}'**
  String errorSigningOut(Object error);

  /// No description provided for @signedOutSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessfully;

  /// No description provided for @patientHealthLogs.
  ///
  /// In en, this message translates to:
  /// **'{patientName}\'s Health Logs'**
  String patientHealthLogs(Object patientName);

  /// No description provided for @viewingRecentHealthUpdates.
  ///
  /// In en, this message translates to:
  /// **'Viewing recent health updates and vital signs'**
  String get viewingRecentHealthUpdates;

  /// No description provided for @healthLogsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Health logs will appear here when {patientName} starts tracking'**
  String healthLogsWillAppear(Object patientName);

  /// No description provided for @recentLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent Logs'**
  String get recentLogs;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @babyKicks.
  ///
  /// In en, this message translates to:
  /// **'Baby Kicks'**
  String get babyKicks;

  /// No description provided for @sleepHours.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepHours;

  /// No description provided for @waterIntake.
  ///
  /// In en, this message translates to:
  /// **'Water Intake'**
  String get waterIntake;

  /// No description provided for @exerciseMinutes.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseMinutes;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @nauseaDetails.
  ///
  /// In en, this message translates to:
  /// **'Nausea Details'**
  String get nauseaDetails;

  /// No description provided for @contractions.
  ///
  /// In en, this message translates to:
  /// **'Contractions'**
  String get contractions;

  /// No description provided for @headaches.
  ///
  /// In en, this message translates to:
  /// **'Headaches'**
  String get headaches;

  /// No description provided for @swelling.
  ///
  /// In en, this message translates to:
  /// **'Swelling'**
  String get swelling;

  /// No description provided for @vitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get vitamins;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @moderateRisk.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get moderateRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @anxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get anxious;

  /// No description provided for @viewLog.
  ///
  /// In en, this message translates to:
  /// **'View Log'**
  String get viewLog;

  /// No description provided for @safeMother.
  ///
  /// In en, this message translates to:
  /// **'Safe Mother'**
  String get safeMother;

  /// No description provided for @patientAppointments.
  ///
  /// In en, this message translates to:
  /// **'{patientName}\'s Appointments'**
  String patientAppointments(Object patientName);

  /// No description provided for @trackManageAppointments.
  ///
  /// In en, this message translates to:
  /// **'Track and manage healthcare appointments'**
  String get trackManageAppointments;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get upcoming;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'TOMORROW'**
  String get tomorrow;

  /// No description provided for @completedAppointments.
  ///
  /// In en, this message translates to:
  /// **'Completed Appointments'**
  String get completedAppointments;

  /// No description provided for @noAppointments.
  ///
  /// In en, this message translates to:
  /// **'No Appointments'**
  String get noAppointments;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found for {patientName}.'**
  String noAppointmentsFound(Object patientName);

  /// No description provided for @noAppointmentsDialog.
  ///
  /// In en, this message translates to:
  /// **'No Appointments'**
  String get noAppointmentsDialog;

  /// No description provided for @noAppointmentsDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'No appointment schedules found for {patientName}. Appointments will appear here when scheduled.'**
  String noAppointmentsDialogMessage(Object patientName);

  /// No description provided for @firestoreError.
  ///
  /// In en, this message translates to:
  /// **'Firestore Error'**
  String get firestoreError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// No description provided for @unableToLoadAppointments.
  ///
  /// In en, this message translates to:
  /// **'Unable to load appointments. Please check your connection and try again.'**
  String get unableToLoadAppointments;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while loading appointments.'**
  String get unexpectedError;

  /// No description provided for @failedToLoadAppointments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load appointments: {error}'**
  String failedToLoadAppointments(Object error);

  /// No description provided for @videoCallAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video call available'**
  String get videoCallAvailable;

  /// No description provided for @joinCall.
  ///
  /// In en, this message translates to:
  /// **'Join Call'**
  String get joinCall;

  /// No description provided for @joiningVideoCall.
  ///
  /// In en, this message translates to:
  /// **'Joining video call...'**
  String get joiningVideoCall;

  /// No description provided for @appointmentsLoadingBasicSorting.
  ///
  /// In en, this message translates to:
  /// **'Appointments loading with basic sorting (index building...)'**
  String get appointmentsLoadingBasicSorting;

  /// No description provided for @appointmentsLoadingBasicSortingFull.
  ///
  /// In en, this message translates to:
  /// **'Appointments loading with basic sorting. Full sorting will be available soon.'**
  String get appointmentsLoadingBasicSortingFull;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @pregnancyAndParentingGuide.
  ///
  /// In en, this message translates to:
  /// **'Pregnancy & Parenting Guide'**
  String get pregnancyAndParentingGuide;

  /// No description provided for @latestArticlesAndResources.
  ///
  /// In en, this message translates to:
  /// **'Latest articles and resources for {patientName}\'s pregnancy journey'**
  String latestArticlesAndResources(Object patientName);

  /// No description provided for @searchPregnancyArticles.
  ///
  /// In en, this message translates to:
  /// **'Search pregnancy articles...'**
  String get searchPregnancyArticles;

  /// No description provided for @loadingArticles.
  ///
  /// In en, this message translates to:
  /// **'Loading articles...'**
  String get loadingArticles;

  /// No description provided for @unableToLoadArticles.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Articles'**
  String get unableToLoadArticles;

  /// No description provided for @failedToLoadArticles.
  ///
  /// In en, this message translates to:
  /// **'Failed to load articles. Please try again later.'**
  String get failedToLoadArticles;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or category filter'**
  String get tryAdjustingSearch;

  /// No description provided for @readArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Article'**
  String get readArticle;

  /// No description provided for @cannotOpenArticle.
  ///
  /// In en, this message translates to:
  /// **'Cannot open article: {url}'**
  String cannotOpenArticle(Object url);
}
// Add these to your AppLocalizations class
String get selectLanguage => 'Select Language';
String get save => 'Save';

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'si': return AppLocalizationsSi();
    case 'ta': return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
