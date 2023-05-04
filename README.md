# remote-alarm-app
Beautiful code for app to communicate with clock.

## Setting up the Code
You need: 
- The Flutter/Dart SDK and Android SDK to self compile for Android (which is the main os, we developed for). iOS is prob also supported, but NOT TESTED.
- Android Studio is recommended see [here](https://docs.flutter.dev/development/tools/android-studio) for how to integrate Flutter with Android Studio.
- Firebase CLI / FlutterFire CLI (see below)
### Firebase 
Before you setup the app secrets, you need to create a Firebase. 
This app uses Firebase. You need FlutterFire to create a firebase_options.dart file with your API secrets in order for the App to communicate to the API
### Installing FlutterFire CLI and creating config.
Follow this [link](https://firebase.flutter.dev/docs/cli/) to install the Firebase CLI and FlutterFire CLI integration. I recommend using Node.js if you are using windows since executable is less comprehensive. Authenticate using your Google Account that is linked to Firebase.
Once authenticated activate flutterfire by typing `dart pub global activate flutterfire_cli` and execute the configuration dialoge with `flutterfire configure`.
Select your Firebase project, `android` as the platform (or `ios` if you so desire).
This will create your secrets.
