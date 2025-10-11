// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Safe Mother';

  @override
  String get welcomeMessage => 'Welcome to Safe Mother';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get myProfile => 'My Profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get myDoctors => 'My Doctors';

  @override
  String get familyDoctorLink => 'Family & Doctor Link';

  @override
  String get linkFamilyMembers => 'Link Family Members';

  @override
  String get linkDoctors => 'Link Doctors';

  @override
  String get patientId => 'Patient ID';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get age => 'Age';

  @override
  String get contact => 'Contact';

  @override
  String get role => 'Role';

  @override
  String get mother => 'Mother';

  @override
  String get notSet => 'Not set';

  @override
  String get notAvailable => 'Not available';

  @override
  String get patientIdCopied => 'Patient ID copied to clipboard';

  @override
  String get copyPatientId => 'Copy Patient ID';

  @override
  String get sharePatientId => 'Share your Patient ID with family members so they can register and link their accounts to receive updates about your pregnancy journey.';

  @override
  String get familyMembersInfo => 'Family members can use this ID during registration to create linked accounts and receive pregnancy updates.';

  @override
  String get close => 'Close';

  @override
  String get safeMotherPrivacy => 'Safe Mother Privacy';

  @override
  String get privacyDescription => 'Your privacy and safety are our top priority. We ensure that your personal and medical information is securely protected and never shared without your consent. Safe Mother safeguards your details to provide you with confidential and trusted care.';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOutSuccess => 'Successfully signed out';

  @override
  String get signOutFailed => 'Sign out failed';

  @override
  String get passwordChanged => 'Password changed successfully!';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get noDoctorsAssigned => 'No Doctors Assigned';

  @override
  String get connectDoctors => 'Connect with healthcare providers to get personalized care and guidance throughout your pregnancy journey.';

  @override
  String get findDoctor => 'Find a Doctor';

  @override
  String get active => 'ACTIVE';

  @override
  String get selectDoctor => 'Select Doctor';

  @override
  String get currentlyLinked => 'Currently Linked:';

  @override
  String get selectNewDoctor => 'Select a new doctor to change your current selection:';

  @override
  String get selectDoctorGuide => 'Select a doctor to guide your pregnancy journey:';

  @override
  String get noDoctorsAvailable => 'No doctors available';

  @override
  String get retry => 'Retry';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get sendNewRequest => 'Send New Request';

  @override
  String requestSent(Object doctorName) {
    return 'Request sent to $doctorName. Waiting for approval.';
  }

  @override
  String get requestFailed => 'Failed to send request to doctor';

  @override
  String get error => 'Error';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get enterCurrentPassword => 'Please enter current password';

  @override
  String get enterNewPassword => 'Please enter new password';

  @override
  String get passwordsNotMatch => 'New passwords do not match';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get tamil => 'Tamil';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get feelingWell => 'Hope you\'re feeling well today';

  @override
  String get appointments => 'Appointments';

  @override
  String get reminders => 'Reminders';

  @override
  String get records => 'Records';

  @override
  String get todaysReminders => 'Today\'s Reminders';

  @override
  String get noRemindersToday => 'No reminders for today';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String get noUpcomingAppointments => 'No Upcoming Appointments';

  @override
  String get recentMedicalRecords => 'Recent Medical Records';

  @override
  String get noRecentRecords => 'No recent medical records';

  @override
  String get bookAppointment => 'Book\nAppointment';

  @override
  String get addReminder => 'Add Reminder';

  @override
  String get emergencyContact => 'Emergency Contact';

  @override
  String get healthTips => 'Health Tips';

  @override
  String get appointmentBookingComingSoon => 'Appointment booking feature coming soon!';

  @override
  String get addReminderComingSoon => 'Add reminder feature coming soon!';

  @override
  String get emergency => 'Emergency';

  @override
  String get hospital => 'Hospital';

  @override
  String get doctor => 'Doctor';

  @override
  String get stayHydrated => 'Stay hydrated - drink plenty of water';

  @override
  String get eatNutritious => 'Eat nutritious meals regularly';

  @override
  String get getAdequateRest => 'Get adequate rest (7-9 hours)';

  @override
  String get lightExercise => 'Light exercise as approved by doctor';

  @override
  String get learnAndTips => 'Learn & Tips';

  @override
  String get todaysFeaturedTip => 'Today\'s Featured Tip';

  @override
  String get readFullArticle => 'Read Full Article';

  @override
  String get noTipsAvailable => 'No tips available in this category';

  @override
  String get readMore => 'Read more';

  @override
  String get keyPoints => 'Key Points';

  @override
  String get detailedInformation => 'Detailed Information';

  @override
  String get todayMealPreference => 'Today Meal Preference';

  @override
  String get doctorRecommended => 'Doctor Recommended';

  @override
  String get noMealPrescribed => 'No Meal Prescribed';

  @override
  String get noMealPrescribedDesc => 'Your doctor hasn\'t prescribed any specific meals yet.';

  @override
  String get todayExercisePreference => 'Today Exercise Preference';

  @override
  String get noExercisePrescribed => 'No Exercise Prescribed';

  @override
  String get noExercisePrescribedDesc => 'Your doctor hasn\'t prescribed any exercises yet.';

  @override
  String get logSymptoms => 'Log Symptoms';

  @override
  String get healthLog => 'Health Log';

  @override
  String get recentHealthLogs => 'Recent Health Logs';

  @override
  String get noHealthLogsYet => 'No Health Logs Yet';

  @override
  String get startLoggingHealthData => 'Start logging your health data to see your history here';

  @override
  String get contactYourDoctors => 'Contact Your Doctors';

  @override
  String get noDoctorsLinked => 'No Doctors Linked';

  @override
  String get linkDoctorFirst => 'Please link with a doctor first to enable emergency contact.';

  @override
  String get callDoctor => 'Call Doctor';

  @override
  String get pleaseCallNumber => 'Please call this number:';

  @override
  String get todaysHealthCheck => 'Today\'s Health Check';

  @override
  String get bloodPressureExample => 'Blood Pressure (e.g., 120/80)';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get babyKicksCounter => 'Baby Kicks Counter';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get symptomsIfAny => 'Symptoms (if any)';

  @override
  String get sleepHoursExample => 'Sleep Hours (e.g., 8)';

  @override
  String get waterIntakeGlasses => 'Water Intake (glasses/day)';

  @override
  String get exerciseMinutesDaily => 'Exercise Minutes (daily)';

  @override
  String get energyLevel => 'Energy Level';

  @override
  String get appetiteLevel => 'Appetite Level';

  @override
  String get painLevel => 'Pain Level';

  @override
  String get healthIndicators => 'Health Indicators';

  @override
  String get hadContractions => 'Had Contractions';

  @override
  String get hadHeadaches => 'Had Headaches';

  @override
  String get hadSwelling => 'Had Swelling';

  @override
  String get tookVitamins => 'Took Vitamins';

  @override
  String get nauseaDetailsIfAny => 'Nausea Details (if any)';

  @override
  String get currentMedications => 'Current Medications';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get saveHealthLog => 'Save Health Log';

  @override
  String get pregnancyAssistant => 'Pregnancy Assistant';

  @override
  String get aiPoweredSupport => 'AI-powered support';

  @override
  String get askPregnancyQuestion => 'Ask a pregnancy-related question...';

  @override
  String get commonPregnancyQuestions => 'Common Pregnancy Questions';

  @override
  String get thinking => 'Thinking...';

  @override
  String get pregnancyAssistantSender => 'Pregnancy Assistant';

  @override
  String get avoidFoodsQuestion => 'What foods should I avoid during pregnancy?';

  @override
  String get safeExercisesQuestion => 'What are safe exercises for the third trimester?';

  @override
  String get relieveMorningSicknessQuestion => 'How can I relieve morning sickness?';

  @override
  String get pretermLaborSignsQuestion => 'What are the signs of preterm labor?';

  @override
  String get weightGainQuestion => 'How much weight should I gain during pregnancy?';

  @override
  String get healthAssessment => 'Health Assessment';

  @override
  String get assessmentResults => 'Assessment Results:';

  @override
  String get recommendations => 'Recommendations:';

  @override
  String get highRiskDetected => 'High risk detected! Please contact your healthcare provider immediately.';

  @override
  String get contactDoctor => 'Contact Doctor';

  @override
  String get healthInfoSaved => 'Health information saved and analyzed successfully!';

  @override
  String errorSavingHealthInfo(Object error) {
    return 'Error saving health information: $error';
  }

  @override
  String get phoneNumberNotAvailable => 'Phone number not available';

  @override
  String unableToMakeCall(Object error) {
    return 'Unable to make call: $error';
  }

  @override
  String get weightLabel => 'Weight';

  @override
  String get bpLabel => 'BP';

  @override
  String get kicksLabel => 'Kicks';

  @override
  String get sleepLabel => 'Sleep';

  @override
  String symptomsLabel(Object symptoms) {
    return 'Symptoms: $symptoms';
  }

  @override
  String notesLabel(Object notes) {
    return 'Notes: $notes';
  }

  @override
  String get enterBloodPressure => 'Please enter your blood pressure';

  @override
  String get enterWeight => 'Please enter your weight';

  @override
  String get enterSleepHours => 'Please enter sleep hours';

  @override
  String get enterWaterIntake => 'Please enter water intake';

  @override
  String get enterExerciseMinutes => 'Please enter exercise minutes';

  @override
  String errorLoadingDoctors(Object error) {
    return 'Error loading doctors: $error';
  }

  @override
  String get startYourPregnancyJourney => 'Start Your Pregnancy Journey';

  @override
  String get completePregnancyDetails => 'Complete your pregnancy details in your profile to start tracking your journey.';

  @override
  String get setupPregnancyTracking => 'Setup Pregnancy Tracking';

  @override
  String get yourPregnancyJourney => 'Your Pregnancy Journey';

  @override
  String trimesterLabel(Object trimester) {
    return '$trimester Trimester';
  }

  @override
  String get weeksLabel => 'weeks';

  @override
  String get expectedDueDate => 'Expected Due Date';

  @override
  String get thisWeeksDevelopment => 'This Week\'s Development';

  @override
  String get viewFullJourney => 'View Full Journey';

  @override
  String get pregnancyMilestones => 'Pregnancy Milestones';

  @override
  String get heartBegins => 'Heart Begins';

  @override
  String get allOrgans => 'All Organs';

  @override
  String get endFirstTrimester => 'End 1st Trimester';

  @override
  String get halfwayPoint => 'Halfway Point';

  @override
  String get viability => 'Viability';

  @override
  String get eyesOpen => 'Eyes Open';

  @override
  String get rapidGrowth => 'Rapid Growth';

  @override
  String get fullTermSoon => 'Full Term Soon';

  @override
  String get dueDate => 'Due Date';

  @override
  String babyGrowing(Object babyName) {
    return '$babyName is growing!';
  }

  @override
  String dayLabel(Object totalDays) {
    return 'Day $totalDays';
  }

  @override
  String weeksDaysLabel(Object days, Object weeks) {
    return '$weeks weeks, $days days';
  }

  @override
  String timeRemaining(Object daysRemaining, Object weeksRemaining) {
    return '$weeksRemaining weeks, $daysRemaining days to go';
  }

  @override
  String progressComplete(Object percentage, Object totalDays) {
    return '$percentage% complete ($totalDays/280 days)';
  }

  @override
  String get babyDevWeek4 => 'Your baby is just beginning to develop. The fertilized egg is implanting in your uterus.';

  @override
  String get babyDevWeek8 => 'Your baby\'s heart is starting to beat and major organs are beginning to form.';

  @override
  String get babyDevWeek12 => 'Your baby is now about the size of a lime and all major organs are formed.';

  @override
  String get babyDevWeek16 => 'Your baby can now make facial expressions and may even be sucking their thumb.';

  @override
  String get babyDevWeek20 => 'Your baby is about the size of a banana and you might start feeling movement soon.';

  @override
  String get babyDevWeek24 => 'Your baby\'s hearing is developing and they can hear your voice and heartbeat.';

  @override
  String get babyDevWeek28 => 'Your baby\'s eyes can now open and close, and they may have hiccups.';

  @override
  String get babyDevWeek32 => 'Your baby is gaining weight rapidly and their bones are hardening.';

  @override
  String get babyDevWeek36 => 'Your baby\'s lungs are maturing and they\'re getting ready for life outside the womb.';

  @override
  String get babyDevWeek40 => 'Your baby is full-term and ready to meet you! They could arrive any day now.';

  @override
  String get consultation => 'Consultation';

  @override
  String get loadingConsultationData => 'Loading consultation data...';

  @override
  String get yourDoctors => 'Your Doctors';

  @override
  String get quickChat => 'Quick\nChat';

  @override
  String get noDoctorsLinkedDesc => 'You haven\'t linked with any doctors yet. Visit your profile to send connection requests to healthcare professionals.';

  @override
  String get refresh => 'Refresh';

  @override
  String get scheduleAppointment => 'Schedule an appointment with your doctor';

  @override
  String get chooseYourDoctor => 'Choose your doctor';

  @override
  String get selectDate => 'Select Date';

  @override
  String get chooseAppointmentDate => 'Choose appointment date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get reasonForVisit => 'Reason for Visit';

  @override
  String get appointmentExample => 'e.g., Regular checkup, Consultation';

  @override
  String get additionalNotesOptional => 'Additional Notes (Optional)';

  @override
  String get specificConcerns => 'Any specific concerns or information';

  @override
  String get bookAppointmentButton => 'Book Appointment';

  @override
  String get appointmentBookedSuccess => 'Appointment booked successfully!';

  @override
  String get quickChatTitle => 'Quick Chat';

  @override
  String get chooseDoctorChat => 'Choose a doctor to start chatting:';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get linkDoctorFirstChat => 'Please link with a doctor first to start chatting';

  @override
  String startConversation(Object doctorName) {
    return 'Start a conversation with\nDr. $doctorName';
  }

  @override
  String get messagesSecure => 'Your messages are secure and private';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get now => 'Now';

  @override
  String minutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String get failedSendMessage => 'Failed to send message. Please try again.';

  @override
  String get goToProfileSettings => 'Go to Profile → Settings → Link with Doctors';

  @override
  String get safeMotherTitle => 'Safe Mother';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get mealDescription => 'Description:';

  @override
  String get nutritionalBenefits => 'Nutritional Benefits:';

  @override
  String get ingredients => 'Ingredients:';

  @override
  String get preparation => 'Preparation:';

  @override
  String get safeForPregnancy => 'Safe for Pregnancy';

  @override
  String difficultyLabel(Object difficulty) {
    return 'Difficulty: $difficulty';
  }

  @override
  String get exerciseDescription => 'Description:';

  @override
  String get exerciseBenefits => 'Benefits:';

  @override
  String get safeFor => 'Safe for:';

  @override
  String get consultDoctorBefore => 'Consult with your doctor before performing';

  @override
  String get safeMotherLearn => 'Safe Mother - Learn';

  @override
  String get all => 'All';

  @override
  String get pregnancy => 'Pregnancy';

  @override
  String get health => 'Health';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get baby => 'Baby';

  @override
  String get parenting => 'Parenting';

  @override
  String get failedLoadArticles => 'Failed to load articles. Please try again later.';

  @override
  String get noTitle => 'No title';

  @override
  String get noDescription => 'No description';

  @override
  String publishedLabel(Object date) {
    return 'Published: $date';
  }

  @override
  String sourceLabel(Object source) {
    return 'Source: $source';
  }

  @override
  String get articleUrlNotAvailable => 'Article URL is not available';

  @override
  String couldNotOpenArticle(Object error) {
    return 'Could not open article. Error: $error';
  }

  @override
  String get learn => 'Learn';

  @override
  String get searchArticles => 'Search articles';

  @override
  String get noArticlesFound => 'No articles found in this category';

  @override
  String get home => 'Home';

  @override
  String get log => 'Log';

  @override
  String get consultationNav => 'Consultation';

  @override
  String get chat => 'Chat';

  @override
  String get pregnancyInformation => 'Pregnancy Information';

  @override
  String get expectedDeliveryDate => 'Expected Delivery Date';

  @override
  String get pregnancyConfirmedDate => 'Pregnancy Confirmed Date';

  @override
  String get weight => 'Weight';

  @override
  String get firstChild => 'First Child';

  @override
  String get previousPregnancyLoss => 'Previous Pregnancy Loss';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get notProvided => 'Not provided';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully!';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get medicalInformation => 'Medical Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get allergiesCommaSeparated => 'Allergies (comma separated)';

  @override
  String get emergencyContactName => 'Emergency Contact Name';

  @override
  String get emergencyContactPhone => 'Emergency Contact Phone';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get enterValidAge => 'Enter valid age';

  @override
  String get pleaseEnterValidPhoneNumber => 'Please enter a valid phone number';

  @override
  String get allergiesExample => 'e.g., Penicillin, Peanuts, Shellfish';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pregnancyJourney => 'Pregnancy Journey';

  @override
  String get setupYourPregnancyJourney => 'Setup Your Pregnancy Journey';

  @override
  String get progress => 'Progress';

  @override
  String get totalDays => 'Total Days';

  @override
  String get remaining => 'Remaining';

  @override
  String get weeks => 'WEEKS';

  @override
  String get days => 'days';

  @override
  String get dueDateOverdue => 'Due Date (Overdue)';

  @override
  String get babyCanArriveAnyTime => 'Baby can arrive any time now!';

  @override
  String get trimesterProgress => 'Trimester Progress';

  @override
  String weekOf(Object current, Object total) {
    return 'Week $current of $total';
  }

  @override
  String get heartBeginsBeating => 'Heart Begins Beating';

  @override
  String get heartBeginsBeatingDesc => 'Your baby\'s heart starts to beat';

  @override
  String get allMajorOrgans => 'All Major Organs';

  @override
  String get allMajorOrgansDesc => 'All major organs are now formed';

  @override
  String get endOfFirstTrimester => 'End of First Trimester';

  @override
  String get endOfFirstTrimesterDesc => 'Risk of miscarriage decreases significantly';

  @override
  String get genderDetermination => 'Gender Determination';

  @override
  String get genderDeterminationDesc => 'Baby\'s gender can be determined';

  @override
  String get halfwayPointDesc => 'You\'re halfway through your pregnancy!';

  @override
  String get viabilityMilestone => 'Viability Milestone';

  @override
  String get viabilityMilestoneDesc => 'Baby has a good chance of survival if born';

  @override
  String get eyesCanOpen => 'Eyes Can Open';

  @override
  String get eyesCanOpenDesc => 'Baby\'s eyes can open and close';

  @override
  String get rapidWeightGain => 'Rapid Weight Gain';

  @override
  String get rapidWeightGainDesc => 'Baby is gaining weight rapidly';

  @override
  String get consideredFullTerm => 'Considered Full-Term';

  @override
  String get consideredFullTermDesc => 'Baby is now considered full-term';

  @override
  String get dueDateDesc => 'Your estimated due date arrives!';

  @override
  String get completed => 'Completed';

  @override
  String get current => 'Current';

  @override
  String get development => 'Development';

  @override
  String get thisWeeksTips => 'This Week\'s Tips';
}
