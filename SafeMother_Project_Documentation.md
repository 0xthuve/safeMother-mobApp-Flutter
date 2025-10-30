# Safe Mother - Pregnancy Health Companion

📱 **Project Overview**  
A comprehensive Flutter application designed to support expecting mothers throughout their pregnancy journey with health tracking, AI assistance, doctor consultations, and educational resources.

---

## 🚀 Features

### ✨ Core Functionality
- 🏥 **Health Logging** - Track symptoms, baby kicks, blood pressure, weight, and more  
- 🤖 **AI Risk Assessment** - Intelligent analysis of health data with risk alerts  
- 👩‍⚕️ **Doctor Consultation** - Book appointments and chat with healthcare providers  
- 📚 **Educational Content** - Pregnancy guides, week-by-week development, and tips  
- 💬 **AI Chat Assistant** - 24/7 pregnancy-related questions and support  

### 🛡️ Safety & Monitoring
- Real-time health risk assessment  
- Emergency contact features  
- Doctor alert system for high-risk cases  
- Secure data storage and messaging  

---

## 📋 Prerequisites
- Flutter 3.19+  
- Dart 3.3+  
- Firebase Project  
- Groq API Key (for AI features)  

---

## ⚙️ Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/safe-mother.git
cd safe-mother
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Firebase for your project
flutterfire configure
```

### 4. Environment Configuration
Create `lib/config/env.dart`:

```dart
class Env {
  static const String groqApiKey = "your_groq_api_key_here";
  static const String firebaseProjectId = "your_firebase_project_id";
}
```

### 5. Run the Application
```bash
flutter run
```

---

## 🏗️ Project Structure
```
lib/
├── main.dart                 # Application entry point
├── config/                   # Configuration files
├── l10n/                     # Localization files
├── models/                   # Data models
├── services/                 # Backend services
├── screens/                  # Main application screens
│   ├── home/                 # Dashboard
│   ├── health_log/           # Health tracking
│   ├── consultation/         # Doctor appointments
│   ├── education/            # Learning resources
│   └── chat/                 # AI assistant
│   └── profile/              # User profile management
├── widgets/                  # Reusable UI components
└── utils/                    # Helper utilities
```

---

## 🔧 Configuration

### Firebase Setup
1. Create a new Firebase project  
2. Enable Authentication (Email/Password)  
3. Enable Realtime Database  
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)  

### API Keys Required
- **Groq API:** For AI chat functionality  
- **Firebase:** For authentication and database  

---

## 📱 Screens Overview

### 1. Dashboard (`HomeScreen`)
- Pregnancy timeline and progress  
- Quick health metrics overview  
- Upcoming appointments  
- Emergency contacts  

### 2. Health Log (`PatientDashboardLog`)
- Comprehensive health tracking  
- Symptom monitoring  
- Baby kicks counter  
- AI risk assessment  

### 3. Consultation (`ConsultationScreen`)
- Doctor directory  
- Appointment booking  
- Real-time chat with doctors  
- Medical history  

### 4. Education (`EducationScreen`)
- Week-by-week pregnancy guide  
- Articles and resources  
- Video content  
- Tips and advice  

### 5. AI Chat (`ChatScreen`)
- 24/7 pregnancy assistant  
- Common question suggestions  
- Emergency guidance  
- Personalized advice  

---

## 🗃️ Data Models
**Core Models**
- `User` - Patient profile and preferences  
- `SymptomLog` - Health tracking entries  
- `Appointment` - Doctor appointments  
- `Doctor` - Healthcare provider information  
- `RiskAssessment` - AI analysis results  

---

## 🔌 Services

### Backend Services
- `BackendService` - Firebase database operations  
- `AuthService` - User authentication  
- `AppointmentService` - Appointment management  
- `AIRiskAssessmentService` - Health risk analysis  
- `ChatService` - AI and doctor messaging  

### External APIs
- **Groq API** - AI chat completions  
- **Firebase Auth** - User authentication  
- **Firebase Realtime Database** - Data storage  

---

## 🎨 UI/UX Features

### Design System
- **Color Palette:** Purple theme (#7B1FA2, #E91E63)  
- **Typography:** Lexend font family  
- **Icons:** Material Design Icons  
- **Layout:** Responsive design for mobile  

### Key Components
- Custom bottom navigation  
- Gradient backgrounds  
- Animated transitions  
- Loading states and error handling  

---

## 🔒 Security & Privacy

### Data Protection
- Secure Firebase authentication  
- Encrypted data transmission  
- Privacy-focused data collection  
- HIPAA-compliant health data handling  

### User Privacy
- Anonymous analytics  
- Opt-in data sharing  
- Clear privacy policy  
- Data deletion options  

---

## 🧪 Testing

### Test Coverage
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Generate test coverage
flutter test --coverage
```

### Testing Strategy
- Unit tests for services and models  
- Widget tests for UI components  
- Integration tests for user flows  
- Performance testing  

---

## 📦 Build & Deployment

### Android Build
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS Build
```bash
flutter build ios --release
flutter build ipa --release
```

### Web Build
```bash
flutter build web --release
```

### 🚀 Deployment Checklist
- Update version in `pubspec.yaml`  
- Run all tests  
- Update changelog  
- Generate build artifacts  
- Deploy to app stores  
- Update documentation  

---

## 📄 License
```
MIT License

Copyright (c) 2024 Safe Mother

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🤝 Contributing
1. Fork the repository  
2. Create a feature branch (`git checkout -b feature/amazing-feature`)  
3. Commit your changes (`git commit -m 'Add some amazing feature'`)  
4. Push to the branch (`git push origin feature/amazing-feature`)  
5. Open a Pull Request  

**Code Standards**
- Follow Dart style guide  
- Write meaningful commit messages  
- Add tests for new features  
- Update documentation  

---

## 🆘 Support

### Documentation
- User Guide  
- Developer Guide  
- API Documentation  

### Community
- Discord Channel  
- GitHub Issues  
- Email Support  

---

## 🔄 Version History
**Beta v1.0.0**
- Initial beta release  
- Core health tracking features  
- AI chat integration  
- Doctor consultation system  
- Multi-language support  

---

## 📞 Contact
**Project Maintainer:** Safe Mother Team  
**Email:** contact@safemother.app  
**Website:** [https://safemother.app](https://safemother.app)  
**GitHub:** [https://github.com/your-username/safe-mother](https://github.com/your-username/safe-mother)  

---

## 🙏 Acknowledgments
- Flutter team for the amazing framework  
- Firebase for backend services  
- Groq for AI capabilities  
- Medical professionals for guidance  
- Beta testers for valuable feedback  

⭐ If you find this project helpful, please give it a star on GitHub!
