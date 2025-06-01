# Mental Health Flutter App - Debugging Guide

## 🔍 Issue: Counselors and Bookings Not Appearing in Firebase

### Current Status

The app code is **correctly implemented** for saving counselor accounts and bookings to Firebase.
The issue is likely one of the following:

## 🚨 Most Likely Issues

### 1. **Firebase Security Rules** (Primary Suspect)

Your current Firestore rules are too restrictive:

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

**Problem**: This only allows users to read their own profile, but the app needs to read ALL
counselor profiles.

### 2. **Missing Data in Firebase Console**

- Counselors may not be created yet
- Bookings may not be saved due to authentication issues

### 3. **Authentication Issues**

- Users may not be properly authenticated
- Auth state may not persist between sessions

## 🔧 **IMMEDIATE FIXES**

### Step 1: Update Firestore Security Rules

Go to Firebase Console → Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - allow reading counselor profiles
    match /users/{userId} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || resource.data.role == 'counselor');
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bookings collection - allow access for participants
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.counselorId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
  }
}
```

### Step 2: Test with Debug Information

The app now includes enhanced debugging. Check the console logs for:

- Authentication status
- Firebase connection status
- Data query results
- Error messages

### Step 3: Create Test Data

Use the admin dashboard's "+" button to create test counselors and bookings.

## 🧪 **DEBUGGING STEPS**

### 1. Check Console Logs

Run the app and check for these debug messages:

- `DEBUG - Current user: [user_id]`
- `DEBUG - Firestore connection successful`
- `DEBUG - Counselor query returned X documents`
- `Counselors Query - Total docs: X`

### 2. Verify Authentication

```dart
final currentUser = FirebaseAuth.instance.currentUser;
print('User authenticated: ${currentUser != null}');
print('User ID: ${currentUser?.uid}');
```

### 3. Manual Data Check

1. Go to Firebase Console
2. Check Firestore Database
3. Look for:
    - `users` collection with role='counselor'
    - `bookings` collection with actual data

### 4. Test Account Creation

1. Create a new counselor account
2. Check if it appears in Firebase Console
3. Check if it appears in the counselor list

## 📋 **EXPECTED BEHAVIOR**

### Counselor Creation Flow:

1. User selects "Counselor" role
2. Fills specialization and experience
3. Account created in Firebase with role='counselor'
4. Should appear in counselor list for users

### Booking Creation Flow:

1. User selects counselor and books session
2. Proceeds to payment
3. Booking saved to Firebase with status='pending'
4. Should appear in counselor's booking requests
5. Should appear in user's booking history

## 🔍 **TROUBLESHOOTING CHECKLIST**

- [ ] Firebase security rules updated
- [ ] Console shows authentication success
- [ ] Console shows Firestore connection success
- [ ] Counselor accounts visible in Firebase Console
- [ ] Bookings visible in Firebase Console
- [ ] Debug logs show proper data retrieval
- [ ] Test data creation works

## 🚀 **NEXT STEPS**

1. **Update Firebase Rules** (Critical)
2. **Run the app and check console logs**
3. **Create test data using admin panel**
4. **Verify data appears in Firebase Console**
5. **Test counselor creation and booking flow**

The core functionality is correct - it's most likely a **permissions issue** with Firebase security
rules.

---

**Built with ❤️ for mental health support and accessibility**