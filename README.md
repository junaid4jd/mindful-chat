# Mental Health Flutter App

A comprehensive Flutter application for mental health support featuring AI chatbot integration,
counselor booking system, and role-based authentication.

## 🎯 Features

### Core Functionality

- **Role-Based Authentication**: Support for Users, Counselors, and Admins
- **AI Chatbot Integration**: Mental health conversations powered by ChatGPT
- **Counselor Booking System**: Real-time booking with payment processing
- **Firebase Backend**: Complete authentication and data management
- **Real-time Updates**: Live status updates for bookings and appointments

### User Features

- Browse and search available counselors
- Book counseling sessions with date/time selection
- Multiple session types (Video Call, Audio Call, Chat)
- Payment processing with multiple payment methods
- Track booking history and status updates
- AI-powered mental health chatbot

### Counselor Features

- Dedicated counselor dashboard
- Manage booking requests (Accept/Reject)
- View client information and session details
- Profile management with specialization and experience
- Real-time booking notifications

### Admin Features

- Admin login access (no signup available)
- User and counselor management capabilities (future implementation)
- Platform administration and monitoring

## 🔐 Admin Access

### Default Admin Credentials

The app automatically creates a default admin account on first run:

- **Email**: `admin@mindfulchat.com`
- **Password**: `Admin123!`

### Admin Features

- **Platform Overview**: Real-time statistics and activity monitoring
- **User Management**: View and manage all registered users
- **Counselor Management**: Monitor counselors, toggle availability status
- **Booking Management**: View all bookings across the platform
- **System Administration**: Platform monitoring and control

### Admin Dashboard Sections

1. **Overview Tab**: Platform statistics, user counts, booking metrics
2. **Users Tab**: Manage regular users, view profiles, user actions
3. **Counselors Tab**: Manage counselors, toggle availability, view bookings
4. **Bookings Tab**: Monitor all platform bookings and their status

## 🏗️ Architecture

### Tech Stack

- **Frontend**: Flutter 3.7.0+
- **Backend**: Firebase (Auth, Firestore)
- **AI Integration**: ChatGPT SDK
- **State Management**: Provider Pattern
- **UI Framework**: Material Design

### Project Structure

```
lib/
├── constants/              # App constants and colors
├── model/                  # Data models
├── providers/              # State management
├── screens/                # UI screens
│   ├── splash/            # Splash screen
│   ├── role_selection/    # Role selection
│   ├── login/             # Authentication
│   ├── createAccount/     # User registration
│   ├── dashboard/         # Main user dashboard
│   ├── counselor_dashboard/ # Counselor interface
│   ├── booking/           # Booking system
│   └── payment/           # Payment processing
└── main.dart              # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Firebase project setup
- OpenAI API key (for ChatGPT integration)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mental_health_flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
    - Create a Firebase project
    - Enable Authentication and Firestore
    - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
    - Configure Firebase rules for Firestore

4. **Configure API Keys**
    - Add your OpenAI API key in `lib/screens/dashboard/pages/chatbot/chat_screen.dart`
    - Update the token field with your actual API key

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 App Flow

### Authentication Flow

1. **Splash Screen** → **Role Selection** → **Login/Signup** → **Dashboard**
2. Role-specific navigation based on user type (User/Counselor/Admin)

### User Journey

1. **Register/Login** as User
2. **Browse Counselors** in the Counselor tab
3. **Book Session** with preferred counselor
4. **Make Payment** through secure payment gateway
5. **Track Booking** status in My Bookings
6. **Chat with AI** for immediate mental health support

### Counselor Journey

1. **Register/Login** as Counselor
2. **Complete Profile** with specialization and experience
3. **Manage Bookings** in counselor dashboard
4. **Accept/Reject** booking requests
5. **View Client Details** and session information

## 🔧 Configuration

### Firebase Rules

```javascript
// Firestore Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /bookings/{bookingId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Database Schema

#### Users Collection

```json
{
  "uid": "user_id",
  "fullName": "John Doe",
  "email": "user@email.com",
  "role": "user|counselor|admin",
   "specialization": "Clinical Psychology",
   "experience": "5 years",
   "availability": "Available|Unavailable",
  "createdAt": "timestamp"
}
```

Note: `specialization`, `experience`, and `availability` fields are only used for counselor
accounts.

#### Bookings Collection

```json
{
  "userId": "user_id",
  "userName": "John Doe",
  "userEmail": "user@email.com",
  "counselorId": "counselor_id",
  "counselorName": "Dr. Smith",
  "sessionType": "Video Call|Audio Call|Chat",
  "appointmentDate": "25/12/2024",
  "appointmentTime": "10:00 AM",
  "message": "User's message to counselor",
  "amount": 50.00,
  "paymentMethod": "Credit Card|PayPal|Apple Pay",
  "status": "pending|accepted|rejected",
  "createdAt": "timestamp"
}
```

## 🔧 Troubleshooting Booking Issues

### If bookings don't appear:

1. **Check Firebase Rules**: Ensure your Firestore rules allow read/write access:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null;
       }
       
       match /bookings/{bookingId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

2. **Verify Data Structure**: Check that bookings are saved with correct fields:
   - `userId` - User's Firebase Auth UID
   - `counselorId` - Counselor's Firebase Auth UID
   - `status` - 'pending', 'accepted', or 'rejected'
   - All other required fields as per schema

3. **Check Console Logs**: Look for debug messages in the console:
   - "Counselor Dashboard - Connection state"
   - "User Bookings - Connection state"
   - "Building booking card for: [booking_id]"

4. **Test with Sample Data**: Create a test booking directly in Firebase Console to verify the UI
   works.

### Debugging Steps:

1. Open Flutter Console/Logs
2. Make a booking as a user
3. Check counselor dashboard - you should see debug messages
4. Check user bookings tab - you should see the booking
5. Use the Refresh buttons if data doesn't appear immediately

## 🎨 UI/UX Features

- **Modern Material Design**: Clean and intuitive interface
- **Role-based Navigation**: Customized UI for different user types
- **Real-time Updates**: Live booking status and notifications
- **Responsive Design**: Optimized for various screen sizes
- **Accessibility**: Proper contrast ratios and text sizing

## 🔐 Security Features

- **Firebase Authentication**: Secure user authentication
- **Role-based Access Control**: Restricted access based on user roles
- **Input Validation**: Comprehensive form validation
- **Secure Payment Processing**: PCI-compliant payment handling
- **Data Encryption**: All sensitive data encrypted in transit

## 🧪 Testing

The app includes basic widget tests. To run tests:

```bash
flutter test
```

## 📚 Dependencies

### Core Dependencies

- `firebase_auth: ^5.5.2` - Authentication
- `cloud_firestore: ^5.6.6` - Database
- `firebase_core: ^3.13.0` - Firebase setup
- `provider: ^6.1.4` - State management
- `chat_gpt_sdk: ^3.1.5` - AI integration
- `dash_chat_2: ^0.0.21` - Chat UI
- `http: ^1.3.0` - API calls
- `intl: ^0.19.0` - Internationalization

### Dev Dependencies

- `flutter_test` - Testing framework
- `flutter_lints: ^5.0.0` - Code linting
- `flutter_launcher_icons: ^0.14.3` - App icons

## 🚀 Deployment

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

## 🔮 Future Enhancements

- **Video/Audio Calling**: Real-time communication between users and counselors
- **Push Notifications**: Booking reminders and status updates
- **Advanced Analytics**: User engagement and app usage metrics
- **Multi-language Support**: Localization for global reach
- **AI Improvements**: Enhanced chatbot responses and context awareness
- **Admin Dashboard**: Complete admin panel for platform management

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

## 🏆 Acknowledgments

- Firebase for backend infrastructure
- OpenAI for ChatGPT integration
- Flutter community for excellent packages
- Mental health professionals for guidance on user experience

---

**Built with ❤️ for mental health support and accessibility**
