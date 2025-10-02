# Safe Mother App - Firebase Integration

## 🚀 Project Overview

The Safe Mother App is a comprehensive Flutter application designed to support mothers during pregnancy and childbirth. This project includes complete Firebase integration for authentication and data management.

## ✨ Features Implemented

### 🔐 Authentication System
- **Email/Password Authentication**: Complete sign-up and sign-in functionality
- **Google Sign-In**: Social authentication integration
- **Password Reset**: Forgot password functionality
- **Session Management**: Persistent user sessions
- **Role-based Access**: Support for patients, doctors, and family members

### 🔥 Firebase Integration
- **Firebase Authentication**: User management and authentication
- **Cloud Firestore**: Real-time database for user data
- **Security Rules**: Proper data access controls
- **Mock Service**: Demo mode when Firebase is not configured

### 📱 User Experience
- **Beautiful UI**: Material Design with custom theming
- **Loading States**: Proper loading indicators
- **Error Handling**: Comprehensive error messages
- **Responsive Design**: Works on different screen sizes
- **Demo Mode**: Test the app without Firebase setup

## 🛠️ Setup Instructions

### Option 1: Quick Demo (No Firebase Setup Required)

The app includes a mock Firebase service that allows you to test all features without setting up Firebase:

1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```
4. **Use demo credentials**:
   - Email: `demo@safemother.com`
   - Password: `demo123`

### Option 2: Full Firebase Setup

For production use, follow the [Firebase Setup Guide](FIREBASE_SETUP.md).

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase initialization
├── firebase_options.dart             # Firebase configuration (auto-generated)
├── signin.dart                        # Sign-in screen with Firebase auth
├── signup-roleSelection.dart          # Role selection screen
├── signup-roleMother.dart            # Registration form with Firebase
├── services/
│   ├── firebase_service.dart         # Firebase authentication service
│   ├── firebase_mock_service.dart    # Mock service for demo mode
│   ├── user_management_service.dart  # User management wrapper
│   ├── session_manager.dart          # Session persistence
│   └── logout_service.dart           # Logout functionality
└── pages/                            # Application screens
```

## 🔥 Firebase Services Implemented

### Authentication Service (`firebase_service.dart`)
- User registration with email/password
- User login with email/password
- Google Sign-In integration
- Password reset functionality
- User data management in Firestore
- Automatic fallback to mock service

### Mock Service (`firebase_mock_service.dart`)
- Complete Firebase simulation
- Local data storage
- Demo user accounts
- All authentication methods mocked

### User Management Service (`user_management_service.dart`)
- High-level user operations
- Session integration
- Error handling
- Consistent API across Firebase and mock modes

## 🧪 Testing the App

### Demo Mode Features:
1. **Sign In**: Use demo credentials or create new accounts
2. **Registration**: Complete sign-up process with validation
3. **Google Sign-In**: Simulated Google authentication
4. **Password Reset**: Mock password reset emails
5. **User Profiles**: Store and retrieve user data
6. **Session Persistence**: Users stay logged in between app launches

### Demo Credentials:
- **Email**: demo@safemother.com
- **Password**: demo123
- **Role**: Patient/Mother

## 🎨 UI/UX Features

### Sign-In Screen
- Beautiful gradient background
- Form validation
- Loading states
- Demo mode indicator
- Social sign-in options
- Forgot password functionality

### Registration Screen
- Multi-step registration
- Form validation
- Date picker for due date
- Real-time Firebase integration
- Error handling

### Demo Mode Indicator
- Clear indication when using mock services
- Demo credentials display
- Instructions for users

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Firebase account (for production)

### Quick Start
1. **Clone the repository**:
   ```bash
   git clone [repository-url]
   cd safeMother-mobApp-Flutter
   ```

2. **Install dependencies**:
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

4. **Test with demo credentials**:
   - Email: demo@safemother.com
   - Password: demo123

### Production Setup
1. Follow the [Firebase Setup Guide](FIREBASE_SETUP.md)
2. Replace `firebase_options.dart` with your Firebase configuration
3. Update security rules in Firebase Console
4. Test with real Firebase authentication

## 🧩 Dependencies

### Main Dependencies
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.3
  google_sign_in: ^6.2.1
  shared_preferences: ^2.2.2
  # ... other dependencies
```

## 🔧 Key Files Created

### Firebase Integration Files:
- `lib/services/firebase_service.dart` - Core Firebase authentication
- `lib/services/firebase_mock_service.dart` - Demo mode service
- `lib/services/user_management_service.dart` - User management wrapper
- `lib/services/logout_service.dart` - Logout functionality
- `lib/firebase_options.dart` - Firebase configuration
- `FIREBASE_SETUP.md` - Complete setup guide

## 🐛 Troubleshooting

### Common Issues:

1. **Firebase not initialized error**:
   - The app automatically falls back to demo mode
   - All features work with mock data

2. **Google Sign-In not working**:
   - Ensure SHA-1 fingerprint is added to Firebase
   - Check Firebase configuration

3. **Build errors**:
   - Run `flutter clean && flutter pub get`
   - Ensure all dependencies are compatible

### Demo Mode Limitations:
- Data is stored locally only
- No real email sending for password reset
- Google Sign-In is simulated

## 🎯 Key Achievements

✅ **Complete Firebase Integration**: Authentication, Firestore, Google Sign-In  
✅ **Demo Mode**: Full functionality without Firebase setup  
✅ **Beautiful UI**: Modern, responsive design  
✅ **Error Handling**: Comprehensive error management  
✅ **Session Management**: Persistent user sessions  
✅ **Security**: Proper validation and security rules  
✅ **Cross-Platform**: Works on all Flutter platforms  
✅ **Production Ready**: Complete setup guides and configuration  

The app is now ready for both development/testing (demo mode) and production (with Firebase) use!
