# remote-alarm-app
Beautiful code for app to communicate with clock.

**Wichtig**: Damit die App richtig funktioniert und Nachrichten versendet werden können, muss eine Grundstruktur in der __Firebase Realtime Database__ angelegt werden.
Diese sieht wie folgt aus:

```
{
  "clocks": {
    "<clock_id>": {
      "clock_fb": {
        "latest_clock_status": "",
        "latest_clock_status_count": 0,
        "latest_clock_status_utc": 0
      },
      "clock_user": "niemand"
    }
  }
}
```

In der aktuellen Version der Uhrprogrammierung ist clock_id = `clock_1` und muss entsprechend so gewählt werden. Man kann die ID auch in der Programmierung der Clock anpassen. Dies entspricht dem define `CLOCK_ID` aus [config.h](https://github.com/remote-alarm-clock/remote-alarm-clock-pio/blob/main/include/config.h).

Auf lange Sicht wird die Uhrprogrammierung so verändert, dass die ID selbst angepasst wird und die Datenbankstruktur sich auch von selbst zur Initialisierung erstellt. Dies ist jedoch aktuell (2023-11-22) nicht der Fall. Somit ist das ein kleiner Fix, der die Software nutzbar macht :)


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
