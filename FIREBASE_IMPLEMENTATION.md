# Firebase Services Implementation Guide

## Overview
This document describes the Firebase services implementation in the Quizzical application, including authentication, Firestore database operations, and state management.

## Architecture

### Services Layer

#### 1. AuthService (`lib/services/auth_service.dart`)
Handles all Firebase Authentication operations:
- **Sign Up**: Creates new user accounts with email/password
- **Sign In**: Authenticates existing users
- **Sign Out**: Logs out the current user
- **Get User Data**: Fetches user profile from Firestore
- **Update Profile**: Updates user information
- **Password Reset**: Sends password reset emails
- **Admin Check**: Verifies if a user has admin privileges

#### 2. FirestoreService (`lib/services/firestore_service.dart`)
Manages all Firestore database operations:
- **Categories**: CRUD operations for quiz categories
- **Questions**: Fetch and add quiz questions with filtering
- **Results**: Save and retrieve quiz results
- **User Queries**: Get user information by ID

### Providers (State Management)

#### 1. AuthProvider (`lib/providers/auth_provider.dart`)
Manages authentication state:
- Listens to Firebase auth state changes
- Maintains current user and user model
- Provides authentication methods
- Handles loading and error states
- **New Feature**: `isInitializing` flag to properly handle app startup loading

Key Properties:
- `isAuthenticated`: Check if user is logged in
- `isAdmin`: Check if user has admin privileges
- `isInitializing`: Check if initial auth state is loading
- `user`: Current Firebase User
- `userModel`: Current UserModel with additional data

#### 2. QuizProvider (`lib/providers/quiz_provider.dart`)
Manages quiz functionality:
- Load categories
- Load quiz questions by category and type
- Track current question and user answers
- Calculate scores and submit results
- View user quiz history

Key Methods:
- `loadQuizQuestions()`: Fetches questions for a specific quiz
- `answerQuestion()`: Records user's answer
- `nextQuestion()` / `previousQuestion()`: Navigate through questions
- `submitQuiz()`: Calculates score and saves result to Firestore

#### 3. AdminProvider (`lib/providers/admin_provider.dart`)
Manages admin functionality:
- View all questions
- Add new questions
- View all quiz results
- Manage categories
- Create new users

## Data Models

### 1. UserModel (`lib/models/user_model.dart`)
```dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;
  final DateTime createdAt;
  final String? profilePicUrl;
}
```

### 2. CategoryModel (`lib/models/category_model.dart`)
```dart
class CategoryModel {
  final String id;
  final String name;
  final int displayOrder;
}
```

### 3. QuestionModel (`lib/models/question_model.dart`)
```dart
class QuestionModel {
  final String id;
  final String category;
  final String type;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String? difficulty;
}
```

### 4. ResultModel (`lib/models/result_model.dart`)
```dart
class ResultModel {
  final String id;
  final String userId;
  final String category;
  final String type;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final DateTime timestamp;
  final List<AnswerDetail> answers;
}
```

## App Initialization Flow

### Loading Screen Fix
The app now properly handles the initial loading state:

1. **Firebase Initialization**: Firebase is initialized in `main()`
2. **Auth State Check**: AuthProvider listens to auth state changes
3. **Loading Screen**: Shows a branded loading screen while checking auth state
4. **Route Decision**: Routes to appropriate screen based on authentication and admin status

```dart
// AuthWrapper in main.dart
if (authProvider.isInitializing) {
  // Show loading screen
}
if (!authProvider.isAuthenticated) {
  // Show auth screen
}
if (authProvider.isAdmin) {
  // Show admin home
} else {
  // Show user home
}
```

## Firestore Database Structure

```
users/
  {userId}/
    - name: string
    - email: string
    - isAdmin: boolean
    - createdAt: timestamp
    - profilePicUrl: string (optional)

categories/
  {categoryId}/
    - name: string
    - displayOrder: number

questions/
  {questionId}/
    - category: string
    - type: string (multiple, boolean)
    - question: string
    - correct_answer: string
    - incorrect_answers: array
    - difficulty: string (optional)

results/
  {resultId}/
    - userId: string
    - category: string
    - type: string
    - score: number
    - totalQuestions: number
    - accuracy: number
    - timestamp: timestamp
    - answers: array of AnswerDetail
```

## Usage Examples

### Sign In
```dart
final authProvider = context.read<AuthProvider>();
final success = await authProvider.signIn(
  email: email,
  password: password,
);
```

### Load Quiz Questions
```dart
final quizProvider = context.read<QuizProvider>();
await quizProvider.loadQuizQuestions(
  category: 'Science',
  type: 'multiple',
  limit: 10,
);
```

### Submit Quiz
```dart
final result = await quizProvider.submitQuiz(
  userId: user.uid,
  userName: user.name,
  category: 'Science',
  type: 'multiple',
);
```

### Add Question (Admin)
```dart
final adminProvider = context.read<AdminProvider>();
final question = QuestionModel(
  id: '',
  category: 'Science',
  type: 'multiple',
  question: 'What is the speed of light?',
  correctAnswer: '299,792,458 m/s',
  incorrectAnswers: ['300,000,000 m/s', '150,000,000 m/s', '450,000,000 m/s'],
);
await adminProvider.addQuestion(question);
```

## Error Handling

All providers include error handling:
- `errorMessage`: Contains the last error message
- `clearError()`: Clears the error message
- `isLoading`: Indicates if an operation is in progress

Example:
```dart
final quizProvider = context.watch<QuizProvider>();
if (quizProvider.errorMessage != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(quizProvider.errorMessage!)),
  );
  quizProvider.clearError();
}
```

## Security Considerations

1. **Firestore Rules**: Ensure proper security rules are set in Firebase Console
2. **Admin Privileges**: Admin status is stored in Firestore, not in client-side code
3. **User Data**: User data is only accessible to the authenticated user and admins
4. **Password Reset**: Uses Firebase's built-in secure password reset

## Testing

### Required Firebase Setup
1. Create a Firebase project
2. Add Android/iOS/Web apps to your Firebase project
3. Download and configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Set up Firestore database
5. Configure Firebase Authentication (Email/Password)
6. Set up Firestore security rules

### Testing Users
Create test users with different roles:
- Regular user: `isAdmin: false`
- Admin user: `isAdmin: true`

## Troubleshooting

### App Stuck on Loading Screen
- Check Firebase initialization in `main.dart`
- Verify `isInitializing` flag is properly set to false after auth check
- Check Firebase connection and credentials

### Authentication Errors
- Verify Firebase Auth is enabled in Firebase Console
- Check email/password provider is enabled
- Verify network connectivity

### Firestore Errors
- Check Firestore security rules
- Verify collections exist in Firestore
- Check network connectivity
- Review error messages in `errorMessage` property

## Future Enhancements

1. **Offline Support**: Implement Firestore offline persistence
2. **Real-time Updates**: Use Firestore streams for live data updates
3. **Image Upload**: Add profile picture upload with Firebase Storage
4. **Analytics**: Integrate Firebase Analytics
5. **Push Notifications**: Add Firebase Cloud Messaging
6. **Performance Monitoring**: Integrate Firebase Performance Monitoring

