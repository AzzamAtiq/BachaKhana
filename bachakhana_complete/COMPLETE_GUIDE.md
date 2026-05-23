# ╔══════════════════════════════════════════════════════════╗
# ║       BACHAKHANA — COMPLETE SETUP GUIDE                  ║
# ║       Sab kuch ek jagah — Step by Step                   ║
# ╚══════════════════════════════════════════════════════════╝

Yeh guide aapko zero se lekar Play Store launch tak le
jaayegi. Sab steps follow karein — koi cheez skip mat karein.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 1 — FLUTTER INSTALL (PC Setup)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 1 ─ Flutter SDK Download Karein
─────────────────────────────────────
  1. Yeh link kholen:
     https://docs.flutter.dev/get-started/install/windows/mobile

  2. "Download Flutter SDK" button dabayein
     File: flutter_windows_3.24.x-stable.zip (~500MB)

  3. C:\ drive mein "flutter" naam ka folder banayein:
     C:\flutter

  4. ZIP wahan extract karein.
     Final path: C:\flutter\bin\flutter.exe  ✅

STEP 2 ─ Flutter ko PATH mein Add Karein
─────────────────────────────────────────
  1. Windows Search mein likhen: "environment variables"
  2. "Edit the system environment variables" click karein
  3. "Environment Variables..." button click karein
  4. "System variables" mein "Path" dhundhen → double click
  5. "New" click karein aur yeh likhein:
       C:\flutter\bin
  6. OK → OK → OK press karein

STEP 3 ─ Terminal Open Karein aur Check Karein
───────────────────────────────────────────────
  1. PowerShell ya Command Prompt BAND karein
  2. Dobara kholein
  3. Yeh command chalayein:

       flutter --version

  Agar version dikhe (e.g. Flutter 3.24.0) to ✅ Install ho gaya!

STEP 4 ─ Android Studio Install Karein
────────────────────────────────────────
  1. Download: https://developer.android.com/studio
  2. Install karein (Next > Next > Finish)
  3. Pehli baar kholne par: "Standard" setup choose karein
  4. Android Virtual Device (emulator) automatically set ho jaayega

STEP 5 ─ Flutter Doctor Run Karein
────────────────────────────────────
  PowerShell mein:

    flutter doctor

  Yeh sab "✓" aana chahiye:
  ✓ Flutter
  ✓ Android toolchain
  ✓ Android Studio
  ✗ Chrome (optional - ignore kar sakte hain)

  Agar koi "✗" hai to:

    flutter doctor --android-licenses
    (Enter karein: y, y, y, y, y)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 2 ─ FIREBASE SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 6 ─ Firebase Project Banayein
────────────────────────────────────
  1. https://console.firebase.google.com par jayen
     (Google account se login karein)
  2. "Add project" click karein
  3. Project name: bachakhana-pk
  4. Google Analytics: Enable rakhen → Continue
  5. Analytics account: "Default" → "Create project"
  6. 1-2 minute wait karein → "Continue"

STEP 7 ─ Android App Register Karein
──────────────────────────────────────
  Firebase Console mein:
  1. Project overview page par Android icon click karein
  2. Android package name:  com.bachakhana.app
  3. App nickname:          BachaKhana
  4. SHA-1:                 (abhi khali chodh dein)
  5. "Register app" click karein
  6. "google-services.json" DOWNLOAD karein
  7. Is file ko copy karein yahan:
       C:\Users\UC\OneDrive\Desktop\bachakhana\android\app\

STEP 8 ─ Authentication Enable Karein
───────────────────────────────────────
  Firebase Console mein:
  1. Left menu → "Authentication"
  2. "Get started" click karein
  3. "Email/Password" pe click karein → Enable toggle ON karein
  4. "Save" click karein

STEP 9 ─ Firestore Database Banayein
──────────────────────────────────────
  Firebase Console mein:
  1. Left menu → "Firestore Database"
  2. "Create database" click karein
  3. "Start in test mode" select karein → Next
  4. Location: asia-south1 (Mumbai)  ← ZAROOR YEH CHOOSE KAREIN
  5. "Enable" click karein

STEP 10 ─ Firestore Security Rules Set Karein
───────────────────────────────────────────────
  Firestore Console → "Rules" tab → Sab kuch hata kar yeh paste karein:

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

  "Publish" click karein ✅

STEP 11 ─ FlutterFire CLI Install Karein
──────────────────────────────────────────
  PowerShell mein (Admin mode mein):

    dart pub global activate flutterfire_cli

  Phir:

    $env:Path += ";$env:APPDATA\Pub\Cache\bin"

STEP 12 ─ Firebase Configure Karein
─────────────────────────────────────
  Project folder mein jayen:

    cd C:\Users\UC\OneDrive\Desktop\bachakhana

  Phir:

    flutterfire configure --project=bachakhana-pk

  Pooche to:
  - Platform: Android (Space se select, Enter se confirm)
  - Yeh firebase_options.dart file khud banayega ✅

STEP 13 ─ android/build.gradle Update Karein
──────────────────────────────────────────────
  File kholen: android\build.gradle

  "dependencies {" ke andar yeh line add karein:
    classpath 'com.google.gms:google-services:4.4.0'

  File kholen: android\app\build.gradle
  BILKUL NEECHE yeh add karein:
    apply plugin: 'com.google.gms.google-services'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 3 ─ JAZZCASH PAYMENT SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 14 ─ JazzCash Merchant Account Banayein
──────────────────────────────────────────────
  1. https://sandbox.jazzcash.com.pk par jayen
  2. "Register as Merchant" click karein
  3. CNIC, bank account details bharen
  4. Approve hone mein 3-5 working days lagte hain
  5. Approve hone par yeh milega:
     - Merchant ID
     - Password
     - Integrity Salt (Secret Key)

STEP 15 ─ JazzCash Credentials Update Karein
──────────────────────────────────────────────
  File: lib/services/payment_service.dart

  In lines update karein:
    static const String _liveMerchantId = 'AAPKA_MERCHANT_ID';
    static const String _livePassword   = 'AAPKA_PASSWORD';
    static const String _liveSalt       = 'AAPKA_SALT';

  Aur jab ready ho jao to:
    static const bool isSandbox = false;  // true → false

STEP 16 ─ Return URL Setup (Optional - Production)
────────────────────────────────────────────────────
  payment_service.dart mein:
    'pp_ReturnURL': 'https://bachakhana.pk/payment/return'

  Yeh aapki website ka URL hona chahiye.
  Abhi testing ke liye sandbox use karein — koi URL chahiye nahi.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 4 ─ GOOGLE MAPS SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 17 ─ Google Maps API Key Lein
────────────────────────────────────
  1. https://console.cloud.google.com par jayen
  2. Upar left: Project select karein → "bachakhana-pk"
  3. Left menu → APIs & Services → Credentials
  4. "+ CREATE CREDENTIALS" → "API Key"
  5. API key copy kar lein (aik baar hi dikhti hai)
  6. "RESTRICT KEY" click karein:
     - Application restrictions: Android apps
     - Package name: com.bachakhana.app
     - "Save"

STEP 18 ─ Maps API Enable Karein
──────────────────────────────────
  Google Cloud Console mein:
  1. APIs & Services → Library
  2. "Maps SDK for Android" search karein → Enable
  3. "Geocoding API" search karein → Enable
  4. "Places API" search karein → Enable

STEP 19 ─ API Key App mein Add Karein
───────────────────────────────────────
  File: android\app\src\main\AndroidManifest.xml

  <application> tag ke andar yeh add karein:

    <meta-data
      android:name="com.google.android.geo.API_KEY"
      android:value="AAPKI_API_KEY_YAHAN"/>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 5 ─ PERMISSIONS & ANDROID CONFIG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 20 ─ AndroidManifest.xml Update Karein
─────────────────────────────────────────────
  File: android\app\src\main\AndroidManifest.xml

  <manifest> tag ke andar (application se UPAR) yeh add karein:

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

STEP 21 ─ Android Min SDK Version Set Karein
──────────────────────────────────────────────
  File: android\app\build.gradle

  android { defaultConfig { ... } } ke andar:
    minSdkVersion 21    ← Yeh 16 se 21 karein
    targetSdkVersion 34

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  APP FIRST RUN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 22 ─ Dependencies Install Karein
───────────────────────────────────────
  Project folder mein:

    flutter pub get

  Agar error aaye:
    flutter clean
    flutter pub get

STEP 23 ─ Emulator Start Karein
─────────────────────────────────
  Android Studio kholein:
  1. Right bottom mein "Device Manager" click karein
  2. "Create Device" → Pixel 7 → Next
  3. Android API 34 → Next → Finish
  4. Play button dabayein → Emulator start hoga

  Ya Physical Phone:
  1. Phone Settings → About Phone → Build Number par 7 baar click
  2. Developer Options → USB Debugging ON karein
  3. USB se PC se connect karein

STEP 24 ─ Restaurants Seed Karein (SIRF EK BAAR)
───────────────────────────────────────────────────
  File: lib/main.dart mein Firebase.initializeApp ke baad yeh add karein:

    import 'data/seed_data.dart';
    // ...
    await Firebase.initializeApp(...);
    await seedAllRestaurants();  // ← YEH LINE ADD KAREIN

  App run karein:
    flutter run

  Console mein "✅ 12 restaurants seeded!" dikhne ke baad:
  WAHI LINE COMMENT OUT KAREIN:
    // await seedAllRestaurants();

STEP 25 ─ App Run Karein
─────────────────────────
    flutter run

  Debug mode mein chalega. Sab features test karein:
  ✅ Login / Signup
  ✅ Restaurants list (Firestore se real-time)
  ✅ Search aur filter
  ✅ Slot selection
  ✅ JazzCash sandbox payment
  ✅ Map with restaurant pins
  ✅ Order history
  ✅ Notifications

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  PHASE 5 ─ PLAY STORE LAUNCH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

STEP 26 ─ App Icon Banayein
─────────────────────────────
  1. Canva.com par 1024x1024 icon design karein
  2. Save as PNG (transparent background)
  3. https://appicon.co par upload karein
  4. Android icons download karein
  5. android\app\src\main\res\ mein replace karein

STEP 27 ─ App ko Sign Karein (Release Build)
──────────────────────────────────────────────
  PowerShell mein keystore banayein:

    keytool -genkey -v -keystore bachakhana.keystore ^
      -alias bachakhana -keyalg RSA -keysize 2048 -validity 10000

  Poochhe to:
  - Password: koi bhi yaad rehne wala (YAAD RAKHEN!)
  - Name: BachaKhana
  - Organization: BachaKhana
  - Country: PK

  File bachakhana.keystore → android\ folder mein copy karein

STEP 28 ─ key.properties File Banayein
────────────────────────────────────────
  android\key.properties naam se nayi file banayein:

    storePassword=AAPKA_KEYSTORE_PASSWORD
    keyPassword=AAPKA_KEY_PASSWORD
    keyAlias=bachakhana
    storeFile=../bachakhana.keystore

STEP 29 ─ android/app/build.gradle Update Karein
──────────────────────────────────────────────────
  "android {" se PEHLE yeh add karein:

    def keystoreProperties = new Properties()
    def keystorePropertiesFile = rootProject.file('key.properties')
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
    }

  android { ... } ke andar buildTypes se PEHLE:

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ?
                file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

  buildTypes { release { ... } } mein:

    signingConfig signingConfigs.release

STEP 30 ─ Release APK / Bundle Banayein
─────────────────────────────────────────
  Play Store ke liye (.aab format):

    flutter build appbundle --release

  File milegi: build\app\outputs\bundle\release\app-release.aab

  Ya direct APK test ke liye:

    flutter build apk --release

  File milegi: build\app\outputs\flutter-apk\app-release.apk

STEP 31 ─ Google Play Console Setup
──────────────────────────────────────
  1. https://play.google.com/console par jayen
  2. Developer account banayein ($25 one-time fee)
  3. "Create app" click karein
  4. App name: BachaKhana
  5. Default language: Urdu ya English
  6. App ya Game: App
  7. Free ya Paid: Free

STEP 32 ─ Play Store pe Upload Karein
───────────────────────────────────────
  Play Console mein:
  1. "Production" → "Releases" → "Create new release"
  2. "Upload" → app-release.aab select karein
  3. Release notes likhein (Urdu/English mein)
  4. "Review release" → "Start rollout to Production"

  Review process: 3-7 din lagta hai
  Approve hone par app Play Store par live ho jaayegi! 🎉

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  COMMON ERRORS AUR SOLUTIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ERROR: 'flutter' is not recognized
  FIX: Step 2 dobara karein. PATH sahi set karein.
       PowerShell restart karein.

ERROR: Gradle build failed
  FIX:  flutter clean
        flutter pub get
        flutter run

ERROR: google-services.json not found
  FIX: google-services.json ko android\app\ mein rakhen
       (android\app\google-services.json)

ERROR: FirebaseApp not initialized
  FIX: main() mein await Firebase.initializeApp() check karein
       firebase_options.dart exist karta hai? Step 12 karein.

ERROR: PERMISSION_DENIED (Firestore)
  FIX: Step 10 mein Firestore Rules dobara set karein

ERROR: MissingPluginException (google_maps)
  FIX: flutter clean && flutter pub get && flutter run

ERROR: Emulator slow hai
  FIX: Android Studio → SDK Manager → "Intel HAXM" install karein
       Ya physical phone use karein

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  COMPLETE CHECKLIST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PHASE 1 — Flutter
  [ ] Step 1  — Flutter SDK download & extract
  [ ] Step 2  — PATH set
  [ ] Step 3  — flutter --version ✓
  [ ] Step 4  — Android Studio install
  [ ] Step 5  — flutter doctor ✓

PHASE 2 — Firebase
  [ ] Step 6  — Firebase project banaya
  [ ] Step 7  — Android app register + google-services.json
  [ ] Step 8  — Authentication enable
  [ ] Step 9  — Firestore database banaya
  [ ] Step 10 — Security rules set
  [ ] Step 11 — FlutterFire CLI install
  [ ] Step 12 — flutterfire configure
  [ ] Step 13 — build.gradle update

PHASE 3 — Payment
  [ ] Step 14 — JazzCash merchant account
  [ ] Step 15 — Credentials update
  [ ] Step 16 — Return URL (production ke liye)

PHASE 4 — Maps
  [ ] Step 17 — Google Maps API key
  [ ] Step 18 — APIs enable
  [ ] Step 19 — API key AndroidManifest mein add

PHASE 5 — Config
  [ ] Step 20 — Permissions add
  [ ] Step 21 — Min SDK 21 set

APP RUN
  [ ] Step 22 — flutter pub get
  [ ] Step 23 — Emulator / physical phone setup
  [ ] Step 24 — Seed data (SIRF EK BAAR)
  [ ] Step 25 — flutter run ✓

PLAY STORE
  [ ] Step 26 — App icon banayein
  [ ] Step 27 — Keystore banayein
  [ ] Step 28 — key.properties banayein
  [ ] Step 29 — build.gradle sign config
  [ ] Step 30 — flutter build appbundle
  [ ] Step 31 — Play Console account
  [ ] Step 32 — Upload aur publish

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Koi bhi step mein masla aaye — screenshot lein aur share karein!

Made with ❤️ in Pakistan 🇵🇰
BachaKhana — Khana Bachao, Paise Bachao 🌿
