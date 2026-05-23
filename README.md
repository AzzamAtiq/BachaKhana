BACHAKHANA — COMPLETE SETUP GUIDE
Everything in One Place — Step by Step

This guide will take you from scratch all the way to launching your app on the Google Play Store. Follow every step carefully and do not skip anything.

PHASE 1 — FLUTTER INSTALLATION (PC Setup)
STEP 1 — Download the Flutter SDK
Open the official Flutter installation page:
Flutter Installation Guide
Click “Download Flutter SDK”

Download file:

flutter_windows_3.24.x-stable.zip

Create a folder inside your C: drive:

C:\flutter
Extract the ZIP file there.

Final path should be:

C:\flutter\bin\flutter.exe

✅ Flutter SDK installed successfully.

STEP 2 — Add Flutter to Windows PATH
Open Windows Search

Type:

environment variables

Open:

Edit the system environment variables

Click:

Environment Variables...

Under System Variables, find:

Path
Double-click it → Click New

Add:

C:\flutter\bin

Click:

OK → OK → OK
STEP 3 — Verify Flutter Installation
Close all PowerShell or CMD windows.
Open a new terminal.
Run:
flutter --version

If Flutter version appears, installation is successful. ✅

Example:

Flutter 3.24.0
STEP 4 — Install Android Studio
Download Android Studio:
Android Studio

Install normally:

Next → Next → Finish
On first launch:
Choose Standard Setup
Android Emulator will install automatically.
STEP 5 — Run Flutter Doctor

Run:

flutter doctor

You should see:

✓ Flutter
✓ Android toolchain
✓ Android Studio
✗ Chrome (Optional)

If Android licenses are missing:

flutter doctor --android-licenses

Press:

y

for every prompt.

PHASE 2 — FIREBASE SETUP
STEP 6 — Create Firebase Project
Open Firebase Console:
Firebase Console

Click:

Add project

Project Name:

bachakhana-pk
Keep Google Analytics enabled.

Click:

Continue → Create Project
Wait 1–2 minutes.

✅ Firebase project created.

STEP 7 — Register Android App

Inside Firebase:

Click Android icon.

Package name:

com.bachakhana.app

App nickname:

BachaKhana
Leave SHA-1 empty for now.

Click:

Register App

Download:

google-services.json

Move it to:

C:\Users\UC\OneDrive\Desktop\bachakhana\android\app\
STEP 8 — Enable Firebase Authentication

Go to:

Authentication

Click:

Get Started

Open:

Email/Password
Enable it.
Save.
STEP 9 — Create Firestore Database

Open:

Firestore Database

Click:

Create Database

Choose:

Start in test mode

Region:

asia-south1 (Mumbai)

Click:

Enable
STEP 10 — Configure Firestore Rules

Open:

Firestore → Rules

Replace everything with:

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    match /restaurants/{id} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        (resource.data.ownerId == request.auth.uid ||
         request.auth.token.admin == true);
      allow delete: if request.auth.token.admin == true;
    }

    match /orders/{id} {
      allow read: if request.auth != null &&
        resource.data.userId == request.auth.uid;
      allow create: if request.auth != null &&
        request.resource.data.userId == request.auth.uid;
      allow update: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }

    match /users/{userId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == userId;
    }
  }
}

Click:

Publish

✅ Rules applied successfully.

STEP 11 — Install FlutterFire CLI

Run PowerShell as Administrator:

dart pub global activate flutterfire_cli

Then run:

$env:Path += ";$env:APPDATA\Pub\Cache\bin"
STEP 12 — Configure Firebase with Flutter

Navigate to project folder:

cd C:\Users\UC\OneDrive\Desktop\bachakhana

Run:

flutterfire configure --project=bachakhana-pk

Select:

Android

This automatically creates:

firebase_options.dart

✅ Firebase connected successfully.

STEP 13 — Update Gradle Files

Open:

android/build.gradle

Inside dependencies:

classpath 'com.google.gms:google-services:4.4.0'

Then open:

android/app/build.gradle

Add at bottom:

apply plugin: 'com.google.gms.google-services'
PHASE 3 — JAZZCASH PAYMENT SETUP
STEP 14 — Create JazzCash Merchant Account
Open:
JazzCash Sandbox

Click:

Register as Merchant
Submit:
CNIC
Bank details

Approval time:

3–5 working days

You will receive:

Merchant ID
Password
Integrity Salt
STEP 15 — Configure JazzCash Credentials

Open:

lib/services/payment_service.dart

Update:

static const String _liveMerchantId = 'YOUR_MERCHANT_ID';
static const String _livePassword   = 'YOUR_PASSWORD';
static const String _liveSalt       = 'YOUR_SALT';

When moving to production:

static const bool isSandbox = false;
STEP 16 — Configure Return URL (Optional)

Inside:

'pp_ReturnURL': 'https://bachakhana.pk/payment/return'

Use your real website URL for production.

PHASE 4 — GOOGLE MAPS SETUP
STEP 17 — Create Google Maps API Key
Open Google Cloud Console:
Google Cloud Console

Select project:

bachakhana-pk

Go to:

APIs & Services → Credentials

Click:

Create Credentials → API Key
Restrict the key:
Android Apps

Package:

com.bachakhana.app
STEP 18 — Enable Required APIs

Enable:

Maps SDK for Android
Geocoding API
Places API
STEP 19 — Add API Key to AndroidManifest

Open:

android/app/src/main/AndroidManifest.xml

Inside <application>:

<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_API_KEY_HERE"/>
PHASE 5 — ANDROID CONFIGURATION
STEP 20 — Add Permissions

Inside AndroidManifest.xml, above <application>:

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
STEP 21 — Update SDK Versions

Open:

android/app/build.gradle

Set:

minSdkVersion 21
targetSdkVersion 34
FIRST APP RUN
STEP 22 — Install Dependencies

Run:

flutter pub get

If errors occur:

flutter clean
flutter pub get
STEP 23 — Start Emulator or Connect Device
Emulator
Open Android Studio
Open Device Manager
Create Device → Pixel 7
Choose API 34
Start Emulator
Physical Device
Enable Developer Options
Turn ON USB Debugging
Connect via USB
STEP 24 — Seed Restaurant Data (Run Only Once)

Inside lib/main.dart:

import 'data/seed_data.dart';

await Firebase.initializeApp(...);
await seedAllRestaurants();

Run:

flutter run

After seeing:

✅ 12 restaurants seeded!

Comment the line:

// await seedAllRestaurants();
STEP 25 — Run the App
flutter run

Test all features:

✅ Login / Signup
✅ Restaurant Listings
✅ Search & Filters
✅ Slot Booking
✅ JazzCash Payments
✅ Maps
✅ Order History
✅ Notifications

PHASE 6 — PLAY STORE LAUNCH
STEP 26 — Create App Icon
Create 1024×1024 icon using:
Canva
Export PNG.
Generate Android icons using:
App Icon Generator
Replace icons inside:
android/app/src/main/res/
STEP 27 — Generate Signing Keystore

Run:

keytool -genkey -v -keystore bachakhana.keystore ^
  -alias bachakhana -keyalg RSA -keysize 2048 -validity 10000

Move:

bachakhana.keystore

into:

android/
STEP 28 — Create key.properties

Create:

android/key.properties

Add:

storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=bachakhana
storeFile=../bachakhana.keystore
STEP 29 — Configure Release Signing

Inside android/app/build.gradle:

Add before android {:

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

Add inside android {}:

signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile']
            ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

Inside:

buildTypes {
    release {

Add:

signingConfig signingConfigs.release
STEP 30 — Build Release Files
Play Store Bundle (.aab)
flutter build appbundle --release

Output:

build/app/outputs/bundle/release/app-release.aab
APK
flutter build apk --release

Output:

build/app/outputs/flutter-apk/app-release.apk
STEP 31 — Setup Google Play Console

Open:
Google Play Console

Pay:

$25 one-time fee

Click:

Create App

App Name:

BachaKhana
Choose:
App
Free
STEP 32 — Publish App

Inside Play Console:

Production → Releases
Create New Release

Upload:

app-release.aab
Add release notes.

Click:

Review Release
Start rollout.

Approval time:

3–7 days

🎉 Your app will go live on the Google Play Store!

COMMON ERRORS & FIXES
ERROR: flutter is not recognized

Fix:

Recheck PATH variable
Restart terminal
ERROR: Gradle build failed
flutter clean
flutter pub get
flutter run
ERROR: google-services.json not found

Ensure file path:

android/app/google-services.json
ERROR: FirebaseApp not initialized

Check:

await Firebase.initializeApp()
ERROR: PERMISSION_DENIED (Firestore)

Reapply Firestore Rules from Step 10.

ERROR: MissingPluginException (google_maps)
flutter clean
flutter pub get
flutter run
ERROR: Emulator is very slow

Use:

Intel HAXM
Or physical device
FINAL CHECKLIST
Flutter Setup
 Flutter SDK installed
 PATH configured
 flutter doctor passed
 Android Studio installed
Firebase
 Firebase project created
 Authentication enabled
 Firestore configured
 FlutterFire connected
Payments
 JazzCash merchant account approved
 Credentials configured
Maps
 Maps API enabled
 API key added
Android Config
 Permissions added
 minSdkVersion set to 21
App Testing
 flutter pub get completed
 Emulator/device connected
 Restaurants seeded
 App tested successfully
Play Store
 App icon created
 Keystore generated
 Release bundle generated
 Play Console setup completed
 App uploaded for review

Made with ❤️ in Pakistan 🇵🇰
BachaKhana — Save Food, Save Money 🌿
