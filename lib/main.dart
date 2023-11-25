import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/device_tabs_view.dart';
import 'package:remote_alarm/memory.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:background_fetch/background_fetch.dart';

const appTitle = "Wecker";
final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

const int maximumAllowedDeviceCount = 5;

/**
 * TODO
 * - Add Background Task to load messages periodically even if app is terminated
 * - Add cache for current message from alarmclk and display it In-App
 * - Add multi clock support
 * - Add settings panel for a given clock
 */

/**
 * BACKGROUND TASK
 */

/*// [Android-only] This "Headless Task" is run when the Android app
// is terminated with enableHeadless: true
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}*/

/**
 * END BACKGROUND TASK
 */

/**
 * NOTIFICATION MANAGER
 */

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('analog_alarm_clock');
  /*final IOSInitializationSettings initializationSettingsIOS =
  IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNoconstation);*/
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    //iOS: initializationSettingsIOS
  );
  // AS 22-12-6: Not necessary for now, so just commented out. See new plugin doc for updated source
  await flutterLocalNotificationsPlugin.initialize(
      initializationSettings); //, onSelectNotification: selectNotification);
}
/*
AS 22-12-6: See comment above
void selectNotification(String? payload) async {
  if (payload != null) {
    print('notification payload: $payload');
  }
}*/

Future<void> showNotification(String title, String content) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'arlm_clk_back_channel', 'Alarm Clock back channel',
          channelDescription: 'Important stuff sent here.',
          importance: Importance.max,
          ticker: 'ticker');
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin
      .show(0, title, content, platformChannelSpecifics, payload: 'item x');
}

/**
 * END NOTIFICATION MANAGER
 */

/**
 * LOADING SCREEN AND APP
 */

/// Method where all initializations happen and all pre build checks are supposed to be done! (Like async DB checks and builders!)
Future<void> initializeApp() async {
  // Initialize everything
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load memory here
  await Memory.instance.reload();

  for (final device in Memory.instance.getDevices()) {
    await dbRegisterListener(device);
  }

  // Do database checks here
}

class SomethingWentWrong extends StatelessWidget {
  const SomethingWentWrong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appTitle,
        home: Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
            ),
            body: const Center(child: Text("something went wrong"))));
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: appTitle,
        home: Scaffold(
            appBar: AppBar(
              title: const Text(appTitle),
            ),
            body: const Center(child: Text("loading..."))));
  }
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("Something went wrong");
          return const SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          final auth = FirebaseAuth.instanceFor(
              app: Firebase.app(), persistence: Persistence.LOCAL);
          return MaterialApp(
            title: appTitle,
            scaffoldMessengerKey: scaffoldKey,
            home: DeviceTabsView(),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const Loading();
      },
    );
  }
}

/**
 * END LOADING SCREEN AND APP
 */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await initializeNotifications();
  runApp(const App());

  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}
