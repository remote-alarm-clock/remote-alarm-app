import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'checkbox_form_field.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:background_fetch/background_fetch.dart';

// TODO: Make this settable through settings
const appTitle = "Wecker";
String clock_id = "clock_1";

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
/*
// [Android-only] This "Headless Task" is run when the Android app
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
}
*/

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

Future<void> _showNotification(String title, String content) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
          'arlm_clk_back_channel', 'Alarm Clock back channel',
          channelDescription: 'Important stuff sent here.',
          importance: Importance.max,
          priority: Priority.high,
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
 * SHOW MESSAGE FROM CLOCK
 */
Future<void> showMessageFromClock(DatabaseEvent event) async {
  final prefs = await SharedPreferences.getInstance();
  final data = event.snapshot.value;
  final latestClockStatusCount = prefs.get('latest_clock_status_count') ?? -1;

  // There already exists a message with that content, which has been displayed.
  if (latestClockStatusCount != -1 &&
      int.parse(data.toString()) == latestClockStatusCount) return;

  // Save newest Code of Message
  prefs.setInt('latest_clock_status_count', int.parse(data.toString()));

  // Load Message Body
  final msg = await FirebaseDatabase.instance
      .ref("clocks/$clock_id/clock_fb/latest_clock_status")
      .get();
  final user =
      await FirebaseDatabase.instance.ref("clocks/$clock_id/clock_user").get();
  final utc = await FirebaseDatabase.instance
      .ref("clocks/$clock_id/clock_fb/latest_clock_status_utc")
      .get();

  final userString = user.value.toString();
  final msgString = msg.value.toString();
  String timeString = ""; // Will be empty if no date is found.
  if (utc.exists) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch((utc.value as int)*1000);
    print(timestamp);
    final DateFormat formatterDate = DateFormat("dd.MM.yyyy");
    final DateFormat formatterTime = DateFormat("HH:mm");
    final date = formatterDate.format(timestamp);
    final time = formatterTime.format(timestamp);
    timeString = "$date um $time Uhr";
  }

  _showNotification("Nachricht von $userString", "$timeString\n$msgString");
}

/**
 * HANDLE USERNAME INPUT
 */
class UsernameInputField extends StatefulWidget {
  const UsernameInputField({super.key});

  @override
  State<UsernameInputField> createState() => _UsernameInputFieldState();
}

class _UsernameInputFieldState extends State<UsernameInputField> {
  final _formKey = GlobalKey<FormState>();
  String _username = "";
  int usernameLimit = 8;

  void readData() async {
    // Load the username async.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("username") == null) {
      setState(() => _username = "");
      print("prefs are empty");
    } else {
      setState(() {
        _username = prefs.getString("username")!;
        print("prefs name loaded to $_username");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    readData();
    print("initializing namefield");
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Benutzername',
                      ),
                      initialValue: _username,
                      // Requiered to update TextFormField on stateChange
                      key: Key(_username),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String? value) {
                        print("New username is: '$value'");
                        _username = value!;
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Bitte wähle einen Benutzernamen!";
                        }
                        if (value.length > usernameLimit) {
                          return "Benutzername max. $usernameLimit Zeichen!";
                        }
                        return null;
                      },
                    ))),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                child: ElevatedButton(
                  onPressed: () async {
                    // Validate the Form
                    if (_formKey.currentState!.validate()) {
                      // Form is valid so display a snackbar, that the message will be sent out!
                      _formKey.currentState!.save();
                      // Save new username to prefs
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("username", _username);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text("Benutzername auf '$_username' gesetzt!")));
                    }
                    // Validate and save username
                  },
                  child: const Text('Namen setzen'),
                ))
          ],
        ));
  }
}
/**
 * END HANDLE USERNAME INPUT
 */

/**
 * MESSAGE INPUT
 */
class MessageForm extends StatefulWidget {
  const MessageForm({super.key});

  @override
  State<MessageForm> createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final _formKey = GlobalKey<FormState>();
  final letterLimitForMessage = 32;

  bool useAlarm = false;
  String messageToClock = "";

  //final String senderName = "App";

  /// Send a new message to firebase
  void sendMessage() async {
    // Check if username has been set
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("username") == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Es wurde kein Benutzername gesetzt. Bitte wähle als erstes einen Namen.")));
      return;
    }

    final username = prefs.getString("username")!;

    final referenceLastMessageId = FirebaseDatabase.instance
        .ref("clocks/$clock_id/messages/latest_message_id");
    // Get newest Message ID
    final latestMessageId = await referenceLastMessageId.get();

    // Push new Message to Stack
    if (latestMessageId.exists) {
      // Check if return was not null
      int newMessageId = (int.parse(latestMessageId.value.toString())) + 1;
      final refUp = FirebaseDatabase.instance.ref("clocks/$clock_id/messages");
      await refUp.update({
        "$newMessageId/sender_name": username,
        "$newMessageId/text": messageToClock,
        "$newMessageId/bell": (useAlarm ? 1 : 0),
        "$newMessageId/timestamp": (DateTime.now().millisecondsSinceEpoch/1000.0).round(),
        "latest_message_id": newMessageId
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Nachricht ist raus!")));
    } else {
      // ID does not exist
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Es ist ein Fehler beim Versenden aufgetreten. Die letzte Nachricht-ID existiert nicht!")));
    }

    //_showNotification("test", "test2");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /**
     * REGISTER NOTIFICATION HANDLER FOR DATABASE CHANGE MESSAGE
     */
    DatabaseReference starCountRef = FirebaseDatabase.instance
        .ref('clocks/$clock_id/clock_fb/latest_clock_status_count');
    starCountRef.onValue.listen((DatabaseEvent event) async {
      showMessageFromClock(event);
    });
    // This method is rerun every time setState is called,
    // for instance, as done by the _increment method above.
    // The Flutter framework has been optimized to make
    // rerunning build methods fast, so that you can just
    // rebuild anything that needs updating rather than
    // having to individually changes instances of widgets.
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const UsernameInputField(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nachricht an Wecker',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onSaved: (String? value) {
                    print("Message to Clock is: '$value'");
                    messageToClock = value!;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte gebe eine Nachricht ein!";
                    }
                    if (value.length > letterLimitForMessage) {
                      return "Nachricht max. $letterLimitForMessage Zeichen!";
                    }
                    return null;
                  },
                ),
              ),
              CheckboxFormField(
                title: const Text("Soll der Wecker klingeln?"),
                onSaved: (bool? checkboxValue) {
                  print("Checkbox has value $checkboxValue");
                  useAlarm = checkboxValue!;
                },
                validator: (bool? something) {
                  /*No validation needed*/
                },
                initialValue: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Validate the Form
                      if (_formKey.currentState!.validate()) {
                        // Form is valid so display a snackbar, that the message will be sent out!
                        _formKey.currentState!.save();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Nachricht wird versendet...")));
                        sendMessage();
                      }
                    },
                    child: const Text('Absenden'),
                  )
                ],
              ),
            ]));
  }
}
/**
 * END MESSAGE INPUT
 */

/**
 * LOADING SCREEN AND APP
 */
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
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print("Something went wrong");
          return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
              title: appTitle,
              home: Scaffold(
                  appBar: AppBar(
                    title: const Text(appTitle),
                  ),
                  body: MessageForm()));
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Loading();
      },
    );
  }
}

/**
 * END LOADING SCREEN AND APP
 */
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotifications();
  runApp(const App());

  // BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}
