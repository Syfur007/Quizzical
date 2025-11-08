# Firestore Initial Setup Guide

## Quick Start: Setting Up Your Firestore Database

This guide will help you populate your Firestore database with initial data for testing the Quizzical app.

## Step 1: Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** in the left sidebar
4. Click **Create Database** if not already created
5. Choose **Start in test mode** for development (remember to update rules later)

## Step 2: Create Collections

You need to create these collections:
- `users`
- `categories`
- `questions`
- `results`

## Step 3: Add Initial Data

### 1. Create an Admin User

First, sign up through the app, then update the user document in Firestore:

1. Sign up with your email in the app
2. Go to Firestore Console → `users` collection
3. Find your user document (by email)
4. Edit the document and set `isAdmin: true`
5. Save

Or manually create a user document:

```json
{
  "name": "Admin User",
  "email": "admin@quizzical.com",
  "isAdmin": true,
  "createdAt": [Timestamp - current time]
}
```

Then create the auth user in Firebase Authentication with the same email.

### 2. Add Categories

Add these sample categories to the `categories` collection:

**Document 1:**
```json
{
  "name": "General Knowledge",
  "displayOrder": 1
}
```

**Document 2:**
```json
{
  "name": "Science",
  "displayOrder": 2
}
```

**Document 3:**
```json
{
  "name": "History",
  "displayOrder": 3
}
```

**Document 4:**
```json
{
  "name": "Geography",
  "displayOrder": 4
}
```

**Document 5:**
```json
{
  "name": "Sports",
  "displayOrder": 5
}
```

### 3. Add Sample Questions

Add these sample questions to the `questions` collection:

**Science Question 1 (Multiple Choice):**
```json
{
  "category": "Science",
  "type": "multiple",
  "difficulty": "easy",
  "question": "What is the chemical symbol for water?",
  "correct_answer": "H2O",
  "incorrect_answers": ["CO2", "O2", "H2SO4"]
}
```

**Science Question 2 (Multiple Choice):**
```json
{
  "category": "Science",
  "type": "multiple",
  "difficulty": "medium",
  "question": "What is the speed of light in a vacuum?",
  "correct_answer": "299,792,458 meters per second",
  "incorrect_answers": ["300,000,000 meters per second", "150,000,000 meters per second", "450,000,000 meters per second"]
}
```

**Science Question 3 (True/False):**
```json
{
  "category": "Science",
  "type": "boolean",
  "difficulty": "easy",
  "question": "The Earth is flat.",
  "correct_answer": "False",
  "incorrect_answers": ["True"]
}
```

**History Question 1 (Multiple Choice):**
```json
{
  "category": "History",
  "type": "multiple",
  "difficulty": "medium",
  "question": "In which year did World War II end?",
  "correct_answer": "1945",
  "incorrect_answers": ["1944", "1946", "1943"]
}
```

**Geography Question 1 (Multiple Choice):**
```json
{
  "category": "Geography",
  "type": "multiple",
  "difficulty": "easy",
  "question": "What is the capital of France?",
  "correct_answer": "Paris",
  "incorrect_answers": ["London", "Berlin", "Madrid"]
}
```

**General Knowledge Question 1 (Multiple Choice):**
```json
{
  "category": "General Knowledge",
  "type": "multiple",
  "difficulty": "easy",
  "question": "How many days are in a leap year?",
  "correct_answer": "366",
  "incorrect_answers": ["365", "364", "367"]
}
```

**Sports Question 1 (True/False):**
```json
{
  "category": "Sports",
  "type": "boolean",
  "difficulty": "easy",
  "question": "A soccer team has 11 players on the field.",
  "correct_answer": "True",
  "incorrect_answers": ["False"]
}
```

## Step 4: Set Up Security Rules

Go to **Firestore Database → Rules** and add these security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId || isAdmin();
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    // Questions collection
    match /questions/{questionId} {
      allow read: if request.auth != null;
      allow write: if isAdmin();
    }
    
    // Results collection
    match /results/{resultId} {
      allow read: if request.auth != null && 
                    (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null && 
                      request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAdmin();
    }
  }
}
```

Click **Publish** to save the rules.

## Step 5: Test the Setup

1. Run your Flutter app:
   ```bash
   flutter run
   ```

2. Sign up with a new account

3. Sign in with the admin account to test admin features

4. Try taking a quiz with the sample questions

5. View results

## Adding More Questions

### Using the App (Recommended)
Once you're logged in as an admin:
1. Go to Admin Dashboard
2. Click "Add Question"
3. Fill in the form
4. Submit

### Using Firebase Console (Manual)
1. Go to Firestore → `questions` collection
2. Click "Add Document"
3. Auto-generate ID or provide custom ID
4. Add fields according to the structure above

## Question Type Guidelines

### Multiple Choice Questions
- `type`: "multiple"
- `correct_answer`: One correct answer (string)
- `incorrect_answers`: Array of 3 wrong answers

### True/False Questions
- `type`: "boolean"
- `correct_answer`: "True" or "False" (string)
- `incorrect_answers`: Array with one item (the opposite of correct answer)

### Difficulty Levels
- "easy"
- "medium"
- "hard"

## Bulk Import Script (Optional)

If you want to import many questions at once, you can use this Node.js script:

```javascript
// import-questions.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const questions = [
  {
    category: "Science",
    type: "multiple",
    difficulty: "easy",
    question: "What planet is known as the Red Planet?",
    correct_answer: "Mars",
    incorrect_answers: ["Venus", "Jupiter", "Saturn"]
  },
  // Add more questions here...
];

async function importQuestions() {
  const batch = db.batch();
  
  questions.forEach(question => {
    const docRef = db.collection('questions').doc();
    batch.set(docRef, question);
  });
  
  await batch.commit();
  console.log('Questions imported successfully!');
}

importQuestions().catch(console.error);
```

Run with:
```bash
npm install firebase-admin
node import-questions.js
```

## Verification Checklist

- [ ] Firebase project created
- [ ] Firestore database initialized
- [ ] Collections created (users, categories, questions, results)
- [ ] At least one admin user created
- [ ] Sample categories added
- [ ] Sample questions added (at least 10 for testing)
- [ ] Security rules configured and published
- [ ] Firebase Authentication enabled (Email/Password)
- [ ] App can connect to Firebase
- [ ] Can sign up and sign in
- [ ] Can load categories
- [ ] Can take a quiz
- [ ] Can view results
- [ ] Admin features working

## Common Issues

### "Permission Denied" Errors
**Solution**: Check your security rules and ensure the user is authenticated.

### "Collection doesn't exist"
**Solution**: Create the collection by adding at least one document to it.

### "Cannot read property 'isAdmin' of null"
**Solution**: Make sure the user document exists in the `users` collection and has the `isAdmin` field.

### Questions not loading
**Solution**: 
- Check the category name matches exactly (case-sensitive)
- Ensure questions have the correct `type` field
- Verify at least 10 questions exist for the category

## Need More Questions?

You can:
1. Use the admin panel to add questions through the app
2. Import questions from quiz APIs (e.g., Open Trivia Database)
3. Create your own questions in Firestore Console
4. Use the bulk import script above

## Next Steps

After setting up initial data:
1. Test all app features
2. Add more questions for better quiz variety
3. Create more categories
4. Invite test users
5. Monitor Firestore usage in Firebase Console
6. Set up billing alerts (Firestore has generous free tier)

---

**Your Firestore database is now ready! 🎉**

You can start using the Quizzical app with a fully functional backend.

