# com.hema.rumour_code_interview - Rumour — Anonymous Room-Code Chat App

Flutter + Firebase Cloud Firestore implementation based on the supplied Rumour reference screens from figma.

# Toolchain

- Flutter **3.38.5** (Dart 3.10.x).
- Dart SDK constraint: `>=3.10.0 <4.0.0`
- Firebase: Core, Anonymous Authentication, Cloud Firestore
- Local preferences: `shared_preferences`

# Features in this codebase

- Created a six-digit room newly or join an existing room.
- Firebase anonymous sign-in (no email/password).
- Realtime Firestore messages and server timestamps.
- Date separators, sender labels, and message time labels.
- Latest 30 messages streamed live, with an older-page query when scrolling to history.
- Firestore client persistence (enabled by default on Android/iOS), so previously fetched messages can be served from the local Firestore cache offline.

# Codebase structure i used

```text
lib/
  app.dart
  main.dart
  core/
    theme/app_theme.dart
    widgets/brand_mark.dart
  data/
    models/chat_message.dart
    models/room_identity.dart
    services/chat_service.dart
    services/identity_service.dart
    services/room_service.dart
  features/
    join/join_screen.dart
    identity/identity_screen.dart
    chat/chat_screen.dart
firestore.rules
```

# Firebase setup

1. Create a Firebase project at https://console.firebase.google.com/.
2. Add an Android app using your application ID (set it in `android/app/build.gradle` or `build.gradle.kts`).
3. Enable **Authentication → Sign-in method → Anonymous**.
4. Create a **Cloud Firestore** database.
5. Install FlutterFire CLI and configure the app:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

6. This starter uses native Firebase configuration (`Firebase.initializeApp()`). Ensure `google-services.json` is in `android/app/` and `GoogleService-Info.plist` is added to the iOS Runner target. If your FlutterFire setup generates `firebase_options.dart`, you may instead initialize with `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
7. Publish `firestore.rules` in the Firebase Console or with Firebase CLI.
8. Run:

   ```bash
   flutter pub get
   flutter run
   ```

# Firestore data structure

```text
rooms/{roomCode}
  code: string
  createdAt: timestamp
  memberCount: number
  lastMessage: string | null
  lastMessageAt: timestamp
```

# Offline behavior

Cloud Firestore persistence is enabled by default on Android and Apple platforms. Previously fetched documents are cached by the Firestore SDK and can be read offline. A message queued while offline is synchronized when connectivity returns. The UI intentionally treats the Firestore cache as the source of previously loaded history; it does not promise that messages never downloaded to the device will be available offline.

# Build APK

A Firebase project configuration is required before a real APK can connect to your backend. From the project root:

```bash
flutter build apk --release
```

The APK will be generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```


# Notes

- The supplied reference images are used as the figma your provided; 
