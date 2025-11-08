# Quizzee - Flutter Quiz Application

A comprehensive quiz application built with Flutter, Firebase Authentication, and Cloud Firestore.

## Features

### User Features
- ✅ Email/Password Authentication
- ✅ Profile Management
- ✅ Quiz Categories Selection
- ✅ Multiple Choice & True/False Questions
- ✅ 15-second timer per question
- ✅ Real-time score tracking
- ✅ Detailed results with answer breakdown
- ✅ Quiz history tracking
- ✅ Purple-themed modern UI

### Admin Features
- ✅ Admin dashboard with dark theme
- ✅ Add new quiz questions
- ✅ Create user accounts
- ✅ View all quiz results across users
- ✅ Searchable and sortable results table

## Tech Stack

- **Framework:** Flutter 3.x
- **State Management:** Provider
- **Backend:** Firebase
  - Firebase Authentication
  - Cloud Firestore
- **UI:** Material Design 3 with custom purple theme

## Prerequisites

1. Flutter SDK (3.0 or higher)
2. Firebase Project
3. Android Studio / VS Code
4. Git

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd Quizzical
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will automatically create `firebase_options.dart` with your Firebase configuration.

#### Option B: Manual Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use an existing one
3. Add Android/iOS/Web apps
4. Download configuration files:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
5. Update `lib/firebase_options.dart` with your project credentials

### 4. Firebase Console Configuration

#### Enable Authentication
1. Go to Firebase Console → Authentication
2. Enable **Email/Password** sign-in method

#### Setup Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **test mode** (update rules later)
4. Choose your preferred location

#### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Questions collection
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Results collection
    match /results/{resultId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if false;
    }
  }
}
```

### 5. Initialize Sample Data

#### Create Categories
In Firestore Console, create documents in the `categories` collection:

```javascript
// Document 1
{
  "name": "General Knowledge",
  "displayOrder": 1
}

// Document 2
{
  "name": "Science & Nature",
  "displayOrder": 2
}

// Document 3
{
  "name": "History",
  "displayOrder": 3
}

// Document 4
{
  "name": "Sports",
  "displayOrder": 4
}

// Document 5
{
  "name": "Geography",
  "displayOrder": 5
}

// Document 6
{
  "name": "Entertainment",
  "displayOrder": 6
}
```

#### Create Sample Questions
In Firestore Console, create documents in the `questions` collection:

```javascript
// Example Multiple Choice Question
{
  "category": "General Knowledge",
  "type": "multiple",
  "question": "What is the capital of France?",
  "correct_answer": "Paris",
  "incorrect_answers": ["London", "Berlin", "Madrid"],
  "difficulty": "easy"
}

// Example True/False Question
{
  "category": "Science & Nature",
  "type": "boolean",
  "question": "The Earth is flat.",
  "correct_answer": "False",
  "incorrect_answers": ["True"],
  "difficulty": "easy"
}
```

#### Create Admin User
1. Run the app and sign up with an email
2. Go to Firestore Console → `users` collection
3. Find your user document and add:
   ```javascript
   {
     ...existing fields,
     "isAdmin": true
   }
   ```
4. Restart the app to see admin features

### 6. Run the Application

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── firebase_options.dart          # Firebase configuration
├── models/                        # Data models
│   ├── user_model.dart
│   ├── category_model.dart
│   ├── question_model.dart
│   └── result_model.dart
├── providers/                     # State management
│   └── auth_provider.dart
├── screens/                       # UI screens
│   ├── auth_screen.dart          # Login/Signup
│   ├── user_home_screen.dart     # User dashboard
│   ├── admin_home_screen.dart    # Admin dashboard
│   ├── new_quiz_screen.dart      # Quiz interface
│   ├── new_results_screen.dart   # Results display
│   ├── quiz_history_screen.dart  # Quiz history
│   ├── profile_screen.dart       # User profile
│   ├── admin_add_question_screen.dart
│   ├── admin_add_user_screen.dart
│   └── admin_results_screen.dart
└── services/                      # Business logic
    ├── auth_service.dart         # Authentication
    └── firestore_service.dart    # Database operations
```

## Usage

### For Users
1. **Sign Up/Login:** Create an account or login
2. **Select Quiz:** Choose category and question type
3. **Take Quiz:** Answer 10 questions with 15-second timer
4. **View Results:** See score and detailed breakdown
5. **Check History:** View all previous quiz attempts
6. **Edit Profile:** Update your name and account details

### For Admins
1. **Add Questions:** Create MCQ or True/False questions
2. **Add Users:** Create user accounts directly
3. **View Results:** See all quiz results across users
4. **Manage:** Full CRUD capabilities for quiz content

## Features to Implement (Optional)

- [ ] Question difficulty filtering
- [ ] Leaderboard system
- [ ] Quiz sharing
- [ ] Offline mode
- [ ] Dark mode toggle for users
- [ ] Question images/media support
- [ ] Translation (English ↔ Bangla)
- [ ] Email verification
- [ ] Password reset functionality
- [ ] Social authentication (Google, Facebook)
- [ ] Analytics dashboard
- [ ] Export results to PDF/CSV

## Troubleshooting

### Firebase Connection Issues
- Verify `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location
- Check Firebase project settings match your app package name
- Ensure internet connection is available

### Build Errors
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

### Authentication Errors
- Check Firebase Authentication is enabled
- Verify email/password sign-in method is activated
- Check security rules in Firestore

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is created for educational purposes.

## Contact

For questions or support, please contact the development team.

---

**Built with ❤️ using Flutter & Firebase**

