# Manual for Aegis - Secure Messaging App

## Description

Aegis is a cross-platform messaging application designed for Android and iOS with a strong focus on user security and privacy. It is developed using Flutter and Dart.

## Main Features

- **Cross-platform:** Available for Android and iOS with real-time message synchronization.
- **Security:**
  - End-to-end encryption (E2EE) for all communications.
  - Self-destructing messages and multimedia after a user-configured time.
  - Protection against social engineering attacks and advanced identity verification.
- **Secure Backend:** Implemented using Firebase for authentication, secure data storage, and push notifications.
- **Push Notifications:** Real-time notifications with Firebase Cloud Messaging (FCM).
- **Intuitive Interface:** Designed with Material Design for a consistent and user-friendly experience across platforms.

## Technologies Used

- **Frontend:**
  - Flutter (Dart)
- **Backend:**
  - Firebase (Authentication, Firestore, Cloud Storage)
- **Security:**
  - End-to-end encryption (E2EE)
  - TLS/SSL for protecting data in transit

## Installation and Setup

### APK

Download the latest APK from the Release section and install.

### Prerequisites (Not APK)

- Ensure you have Flutter and Dart installed on your development environment.
- Install Firebase CLI for deployment and configuration.

### Steps

1. **Clone the Repository:**

   ```ps
   git clone https://github.com/SuguruEV/athena_nike.git
   cd athena_nike
   ```

2. **Install Dependencies:**

    ```ps
    flutter pub get
    ```

3. **Setup Firebase:**

    - Create a Firebase project in the Firebase Console.
    - Add the Android and iOS apps to your Firebase project.
    - Download the `google-services.json` file for Android and `GoogleService-Info.plist` for iOS
    - Place these files in the appropriate directories.

4. **Run the App:**

    ```ps
    flutter run
    ```

## Usage Guide

### Main Screens

- **Landing Screen:** Initial screen when the app is launched.
- **Login Screen:** Allows users to log in to their accounts.
- **OTP Screen:** For OTP-based authentication.
- **User Information Screen:** Collects user information during registration.
- **Home Screen:** Main interface for accessing messages, friends, and groups.
- **Profile Screen:** Displays user profile information.
- **Friends Screen:** Manages friend lists and friend requests.
- **Chat Screen:** Interface for chatting with friends and groups.
- **Group Settings Screen:** Manages settings for groups.
- **Group Information Screen:** Displays information about groups.

### Firebase Configuration

The app uses Firebase for core functionalities liek authentication and messaging. Ensure Firebase is properly configured in your project by following the setup steps.

### Theme Support

Adaptive theming is implemented to support both light and dark modes.

### Background Message Handling

The app handles background messages using Firebase Messaging to ensure notifications are recieved when the app is not active.