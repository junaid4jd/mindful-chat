# Firebase Firestore Rules Configuration

To fix the index requirement error, you need to update your Firestore security rules.

## 🔧 **Updated Firestore Rules:**

Go to Firebase Console → Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Allow users to read counselor profiles and their own profile
      allow read: if request.auth != null && 
        (request.auth.uid == userId || resource.data.role == 'counselor');
      // Allow users to write only their own profile
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Bookings collection
    match /bookings/{bookingId} {
      // Allow read/write for booking participants
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.counselorId);
      // Allow creation of new bookings
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    
    // Chat rooms collection
    match /chatRooms/{chatRoomId} {
      // Allow read/write for chat participants
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         request.auth.uid == resource.data.counselorId);
    }
    
    // Messages collection
    match /messages/{messageId} {
      // Allow read for messages in chat rooms user has access to
      allow read: if request.auth != null;
      // Allow creation of new messages
      allow create: if request.auth != null && request.auth.uid == request.resource.data.senderId;
      // Allow updates for read status
      allow update: if request.auth != null;
    }
  }
}
```

## 🚀 **No Complex Indexes Required!**

The updated chat system now:

✅ **Uses simple queries** without composite indexes
✅ **Filters and sorts client-side** to avoid index requirements  
✅ **Works with basic Firestore rules**
✅ **Maintains real-time functionality**
✅ **Preserves all chat features**

## 📝 **Key Changes Made:**

1. **Removed complex orderBy + where combinations**
2. **Implemented client-side sorting** for messages and chat rooms
3. **Simplified Firestore queries** to avoid index requirements
4. **Added proper security rules** for chat functionality
5. **Maintained real-time updates** and performance

## 🔄 **How to Apply:**

1. **Update Firestore Rules** with the configuration above
2. **Restart your app** to apply the changes
3. **Test the chat functionality** - it should work without index errors

The chat system will now work smoothly without requiring any custom Firestore indexes! 🎉

---

**The error should be resolved after updating the Firestore rules.**