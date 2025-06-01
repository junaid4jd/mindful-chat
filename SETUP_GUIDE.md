# 🚀 MindfulChat - Setup and Deployment Guide

## 📋 **Local Development Setup**

### **Step 1: Clone the Repository**

```bash
git clone https://github.com/junaid4jd/mindful-chat.git
cd mindful-chat
```

### **Step 2: Install Dependencies**

```bash
flutter pub get
```

### **Step 3: Configure API Keys (IMPORTANT)**

#### **Option A: Environment Variables (Recommended)**

```bash
# Set environment variable for your session
export OPENAI_API_KEY="your-actual-openai-api-key-here"

# Run the app with environment variable
flutter run --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY
```

#### **Option B: Development Configuration**

1. Open `lib/config/app_config.dart`
2. Replace `YOUR_API_KEY_HERE` in `developmentApiKey` with your actual key
3. **NEVER commit this change to Git**

#### **Option C: Environment File (Alternative)**

1. Copy `.env.example` to `.env.local`
2. Add your actual API key to `.env.local`
3. Use a package like `flutter_dotenv` to load it

### **Step 4: Firebase Setup**

1. Create a Firebase project
2. Enable Authentication and Firestore
3. Add your `google-services.json` (Android)
4. Add your `GoogleService-Info.plist` (iOS)
5. Update Firestore rules (see `FIRESTORE_RULES_FIX.md`)

### **Step 5: Run the App**

```bash
flutter run
```

## 🔐 **Security Notes**

### **API Key Management**

- ✅ **OpenAI API key is NOT hardcoded** in the repository
- ✅ **Fallback to offline mode** if no key is provided
- ✅ **Environment variable support** for secure deployment
- ✅ **Development configuration** for local testing

### **What's Protected**

- OpenAI API keys
- Environment-specific configurations
- Local development files
- Build artifacts
- IDE-specific files

## 🚀 **Deployment Options**

### **Development Deployment**

```bash
# With environment variable
flutter build apk --dart-define=OPENAI_API_KEY=your-key-here
```

### **Production Deployment**

```bash
# Use CI/CD environment variables
flutter build apk --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY --release
```

### **Offline Mode**

- The app **automatically works in offline mode** if no API key is provided
- Full mental health support with built-in responses
- All features except advanced AI chat work normally

## 🛡️ **Security Best Practices**

### **For Contributors**

1. **Never commit API keys** to the repository
2. **Use environment variables** for sensitive data
3. **Test in offline mode** to ensure functionality
4. **Review changes** before committing

### **For Deployment**

1. **Use secure CI/CD pipelines** with environment variables
2. **Keep API keys in secure vaults**
3. **Monitor API usage** for security
4. **Rotate keys regularly**

## 📱 **App Features**

### **Core Functionality**

- ✅ **Role-based authentication** (User, Counselor, Admin)
- ✅ **Real-time chat** between users and counselors
- ✅ **Booking system** with payment processing
- ✅ **Daily exercises** with randomization
- ✅ **Admin dashboard** for management

### **AI Features**

- ✅ **Intelligent chatbot** (when API key provided)
- ✅ **Offline mental health responses** (always available)
- ✅ **Automatic fallback** system
- ✅ **Professional guidance** in both modes

## 🔧 **Troubleshooting**

### **API Key Issues**

- Check environment variable is set correctly
- Verify API key is valid and has credits
- Test offline mode functionality
- Check console logs for key validation

### **Firebase Issues**

- Ensure Firestore rules are properly configured
- Check Firebase project configuration
- Verify authentication is enabled
- Test with Firebase console

### **Build Issues**

- Run `flutter clean && flutter pub get`
- Check Flutter and Dart versions
- Verify all dependencies are compatible
- Test on different platforms

## 📞 **Support**

- Check the main README for full documentation
- Review the codebase for implementation details
- Test in offline mode for development
- Use the built-in fallback responses

---

**🔐 Your API keys are safe! The app works in offline mode by default and only uses AI features when
properly configured.**