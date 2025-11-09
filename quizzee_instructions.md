# CSE-8 MAD Lab Final Project Instructions (Revised)

## 1) Overview & Requirements

### App Name: **Quizzee**

### Technical Requirements:
- Create a clean, responsive, and accessible Flutter app
- **Theme:** Purple color scheme throughout the app
- **Authentication:** Firebase Authentication (Email/Password)
- **Database:** Cloud Firestore for storing:
  - Questions and categories
  - User profiles
  - Quiz results and history
- **State Management:** Use Provider/Riverpod/Bloc/Cubit/GetX
- **Design:** Use illustrations where appropriate to enhance UX
- **Responsive:** Layout must adapt to different screen sizes

---

## 2) User Flow & Screens

### 2.1 Screen 1 — Login/Signup (Authentication)

**Purpose:** User authentication entry point

**UI:**
- App branding: "Quizzee" logo/title
- Two tabs or toggle: "Login" and "Sign Up"
- **Login fields:**
  - Email input
  - Password input
  - "Login" button
  - "Forgot Password?" link (optional)
- **Sign Up fields:**
  - Name/Username
  - Email
  - Password
  - Confirm Password
  - "Sign Up" button
- Illustration: Welcome/authentication themed

**Firebase Integration:**
- Use `FirebaseAuth.instance.signInWithEmailAndPassword()` for login
- Use `FirebaseAuth.instance.createUserWithEmailAndPassword()` for signup
- Store user profile in Firestore under `users/{userId}` collection

**Navigation:**
- After successful authentication → Home Screen

**Acceptance Criteria:**
- Email validation (proper format)
- Password strength indicators for signup
- Error handling for invalid credentials
- Loading states during authentication
- Session persistence (user stays logged in)

---

### 2.2 Screen 2 — Home/Quiz Configuration

**Purpose:** Main hub for quiz selection and navigation

**UI Layout:**

**Header:**
- **Upper Left:** Profile icon (circular avatar)
  - Tap to navigate to Profile Edit screen
- **Upper Right:** "Previous Scores" button/icon
  - Tap to view Quiz History

**Main Content:**
- **Question Category Selection:**
  - Grid or list of 6 category cards
  - Categories (you can choose any 6, examples):
    1. General Knowledge
    2. Science & Nature
    3. History
    4. Sports
    5. Geography
    6. Entertainment
  - Each card with distinct purple shade variation and/or illustration
  - Single selection (radio behavior)

- **Question Type Selection:**
  - 2 options: "MCQ (Multiple Choice)" and "True/False"
  - Segmented control or radio buttons

- **"Let's Start" Button:**
  - Primary CTA at bottom
  - Enabled only when category and type are selected

**Firebase Integration:**
- Categories stored in Firestore: `categories/{categoryId}`
- Fetch on screen load and cache during session

**Navigation:**
- Profile icon → Profile Edit Screen
- Previous Scores → Quiz History Screen
- Let's Start → Quiz Question Screen

**Acceptance Criteria:**
- Category and type selection required before starting
- Visual feedback for selected options
- Categories load from Firestore with loading states
- Smooth navigation with selected config passed to next screen

---

### 2.3 Screen 3 — Quiz Questions

**Purpose:** Display and answer quiz questions one at a time

**UI:**
- **Progress Indicator:** Show question number (e.g., "Question 3/10")
- **Sliding Timer:** 15 seconds countdown per question (visual progress bar/circle)
- **Question Display:** 
  - Category label
  - Question text (large, readable)
- **Answer Options:**
  - **For MCQ:** 4 answer buttons (shuffled)
  - **For True/False:** 2 buttons (True/False)
- **Navigation:** 
  - Timer expires OR answer selected → auto-advance to next
  - Visual feedback on selection (correct = green, incorrect = red)
  - Brief delay (1-2s) to show correct answer before advancing

**Firebase Integration:**
- Questions fetched from Firestore:
  ```
  questions/{questionId}
  {
    category: "Science",
    type: "multiple", // or "boolean"
    question: "Question text?",
    correct_answer: "Answer",
    incorrect_answers: ["Wrong1", "Wrong2", "Wrong3"]
  }
  ```
- Query 10 random questions matching selected category and type

**Quiz Logic:**
- Timer starts on question display
- Timeout = mark as incorrect, auto-advance
- Track: answers selected, time taken, score
- Shuffle answers for MCQ type
- Disable answer buttons after selection

**Acceptance Criteria:**
- Exactly 10 questions per quiz
- Timer visible and counts down smoothly
- No timer overlap when navigating
- Answer selection provides immediate visual feedback
- Score calculation accurate
- Loading state while fetching questions

---

### 2.4 Screen 4 — Results

**Purpose:** Display quiz performance with detailed breakdown

**UI:**
- **Score Display:** 
  - Large, prominent: "Your Score: 7/10"
  - Percentage accuracy
  - Illustration based on performance (celebration/encouragement)
  
- **Detailed Results:**
  - Scrollable list/cards showing:
    - Each question
    - User's answer
    - Correct answer
    - Marking (✓ or ✗)

- **Action Buttons:**
  - **"Start Again"** → Restart quiz with same configuration
  - **"Home"** → Navigate back to Home Screen

**Firebase Integration:**
- Save result to Firestore:
  ```
  results/{resultId}
  {
    userId: "user123",
    category: "Science",
    type: "multiple",
    score: 7,
    totalQuestions: 10,
    accuracy: 70.0,
    timestamp: Timestamp,
    answers: [/* detailed answer array */]
  }
  ```

**Navigation:**
- Start Again → Reset state, navigate to Quiz Questions (same config)
- Home → Navigate to Home Screen (clears quiz state)

**Acceptance Criteria:**
- Accurate score and statistics displayed
- Complete answer breakdown visible
- Results saved to Firestore before display
- Both navigation options function correctly
- Result appears in user's history

---

### 2.5 Screen 5 — Quiz History (Previous Scores)

**Purpose:** Display all past quiz attempts

**UI:**
- List/cards of previous quiz results
- Each item shows:
  - Date/time
  - Category
  - Score (e.g., "8/10 - 80%")
  - Type (MCQ/True-False)
- Tap to view detailed results
- Sort by most recent first

**Firebase Integration:**
- Query Firestore:
  ```
  results
    .where('userId', isEqualTo: currentUserId)
    .orderBy('timestamp', descending: true)
  ```

**Acceptance Criteria:**
- All user results displayed
- Sorted chronologically (newest first)
- Tapping opens detailed view
- Empty state for no history

---

### 2.6 Screen 6 — Profile Edit

**Purpose:** Update user information

**UI:**
- Profile picture (optional upload/placeholder)
- Editable fields:
  - Name/Username
  - Email (display only or change with re-auth)
- "Save Changes" button
- "Logout" button

**Firebase Integration:**
- Update user document in Firestore: `users/{userId}`
- Update Firebase Auth profile if name changed

**Acceptance Criteria:**
- Changes save to Firestore
- Validation for required fields
- Logout functionality working

---

## 3) Admin Interface

### Admin Access:
- Admin identified by special field in user document: `isAdmin: true`
- Check on login, route to Admin Home instead of User Home

### Theme: **Dark Mode** (distinct from user purple theme)

---

### 3.1 Admin Screen 1 — Admin Home

**Purpose:** Central hub for admin operations

**UI:**
- **Header:** 
  - "Admin Dashboard" title
  - **Upper Right:** "Logout" button

- **Main Content - 3 Action Buttons:**
  1. **"Add Question"** → Navigate to Add Question screen
  2. **"Add New User"** → Navigate to Add User screen
  3. **"See Results"** → Navigate to All Results screen

**Acceptance Criteria:**
- Dark theme applied
- All buttons navigate correctly
- Logout returns to Login screen

---

### 3.2 Admin Screen 2 — Add Question

**Purpose:** Create and store new quiz questions

**UI:**
- **Form Fields:**
  - **Category:** Dropdown (6 categories)
  - **Type:** Dropdown (MCQ / True-False)
  - **Question Text:** Multi-line text input
  - **Correct Answer:** Text input
  - **Incorrect Answers:** 
    - For MCQ: 3 text inputs
    - For True-False: Auto-populated (opposite of correct)
  - **Difficulty** (optional): Easy/Medium/Hard
  
- **"Save Question" Button**
- Success/error feedback

**Firebase Integration:**
- Add to Firestore: `questions/{autoId}`

**Acceptance Criteria:**
- All required fields validated
- Question saved to Firestore successfully
- Form clears after successful save
- Error handling for failures

---

### 3.3 Admin Screen 3 — Add New User

**Purpose:** Create user accounts (special case/admin-created)

**UI:**
- **Form Fields:**
  - Name
  - Email
  - Initial Password
  - Admin checkbox (optional - to create admin users)
  
- **"Create User" Button**

**Firebase Integration:**
- Use Firebase Admin SDK or Cloud Function to create user
- Alternative: Create with temp password, send reset link
- Add user document to Firestore: `users/{userId}`

**Acceptance Criteria:**
- User created in Firebase Auth
- User document created in Firestore
- Validation for email format
- Feedback on success/failure

---

### 3.4 Admin Screen 4 — See Results (All Users)

**Purpose:** View quiz performance across all users

**UI:**
- **Tabular Display** (DataTable or similar)
- **Columns:**
  - User Name
  - Category
  - Type
  - Score
  - Accuracy (%)
  - Date/Time
  
- **Features:**
  - Sortable columns
  - Search/filter by user or category
  - Pagination if many results

**Firebase Integration:**
- Query all results: `results.orderBy('timestamp', descending: true)`
- Join with user data for names

**Acceptance Criteria:**
- All results displayed in table format
- Data loads with pagination/lazy loading
- Sorting and filtering functional
- Performance optimized for large datasets

---

## 4) Firebase Structure

### Collections:

```
users/{userId}
  - name: string
  - email: string
  - isAdmin: boolean
  - createdAt: timestamp
  - profilePicUrl: string (optional)

categories/{categoryId}
  - name: string
  - displayOrder: number

questions/{questionId}
  - category: string
  - type: string ("multiple" | "boolean")
  - question: string
  - correct_answer: string
  - incorrect_answers: array
  - difficulty: string (optional)

results/{resultId}
  - userId: string
  - category: string
  - type: string
  - score: number
  - totalQuestions: number
  - accuracy: number
  - timestamp: timestamp
  - answers: array [
      {
        question: string,
        userAnswer: string,
        correctAnswer: string,
        isCorrect: boolean
      }
    ]
```

---

## 5) Optional Features

### 5.1 Translation (Bangla ↔ English)
- Toggle button on question screen
- Use translation API or pre-translated questions in Firestore
- Store questions with both language versions:
  ```
  question_en: "English text"
  question_bn: "বাংলা টেক্সট"
  ```

---

## 6) Technical Implementation Notes

### State Management:
- Auth state (current user, admin status)
- Quiz state (current question, score, timer)
- Config state (selected category, type)
- UI state (loading, errors)

### Error Handling:
- Network failures
- Firebase errors
- Invalid data
- Empty states

### Performance:
- Cache categories and user data
- Lazy load quiz history
- Optimize Firestore queries with indexes
- Implement pagination for large datasets

### Security:
- Firestore security rules to protect user data
- Admin-only write access to questions
- Users can only read/write their own results

### Testing Considerations:
- Auth flow (login/signup/logout)
- Quiz logic (scoring, timer, navigation)
- Firebase CRUD operations
- Admin privileges

---

## 7) Deliverables

1. Complete Flutter application with all screens
2. Firebase project with proper security rules
3. Sample data (categories, questions, users)
4. README with setup instructions
5. Demo video/screenshots (optional)

---

## 8) Evaluation Criteria

- **Functionality:** All features working as specified
- **Firebase Integration:** Proper use of Auth and Firestore
- **State Management:** Clean, maintainable state handling
- **UI/UX:** Responsive, accessible, purple theme for users, dark for admin
- **Code Quality:** Well-structured, commented, following best practices
- **Error Handling:** Graceful handling of edge cases
- **Admin Features:** Full CRUD capabilities with proper access control

---

**Good luck building Quizzee! 🎯**