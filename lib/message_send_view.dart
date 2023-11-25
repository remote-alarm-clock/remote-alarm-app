import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/checkbox_form_field.dart';
import 'package:remote_alarm/main.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageSendView extends StatefulWidget {
  final DeviceProperties device;
  MessageSendView({super.key, required this.device});

  @override
  State<MessageSendView> createState() => _MessageSendViewState();
}

class _MessageSendViewState extends State<MessageSendView> {
  final _formKey = GlobalKey<FormState>();
  final letterLimitForMessage = 126;
  final clockImage = 'assets/clockface_zoom.svg';

  bool useAlarm = false;
  String messageToClock = ""; // What will be sent to server (unclean)
  String previewMessage =
      " "; // What is displayed (also preprocessed with newlines)

  //final String senderName = "App";

  /// Send a new message to firebase
  void _sendMessage() async {
    dbSendMessage(widget.device, messageToClock, useAlarm);
  }

  @override
  void initState() {
    super.initState();
    registerListener();
  }

  void registerListener() async {
    // TODO: Move DB functions to backend
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("clock_id") == null) {
      return;
    }

    final clockId = prefs.getString("clock_id")!;
    /**
     * REGISTER NOTIFICATION HANDLER FOR DATABASE CHANGE MESSAGE
     */
    DatabaseReference starCountRef = FirebaseDatabase.instance
        .ref('clocks/$clockId/clock_fb/latest_clock_status_count');
    starCountRef.onValue.listen((DatabaseEvent event) async {
      showMessageFromClock(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn()) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const SettingsPage();
        }));
      });
    }
    registerListener();

    print("Current clock ID ${widget.device.id}");

    double width =
        MediaQuery.of(context).size.width * 0.4; //40% of screen width

    double fullScreenWidth =
        MediaQuery.of(context).size.width; //100% of screen width
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
              const SizedBox(height: 8),
              Container(
                  width: fullScreenWidth,
                  child: Stack(
                    children: [
                      SvgPicture.asset(clockImage,
                          width: fullScreenWidth,
                          semanticsLabel:
                              'clockface'), // Background picture of clockface
                      // Image aspect ratio: 0.5053, left relative to image: 0.2565, top relative to height: 0.2737
                      Positioned(
                        top: fullScreenWidth *
                            0.5053 *
                            0.2737, // height * top spacing
                        left: fullScreenWidth * 0.2565, // width * left spacing
                        child: Container(
                          alignment: Alignment.topLeft,
                          width: width,
                          height: 0.65 * width, // Match 128*64 aspect ratio
                          child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(previewMessage,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      fontSize: 90,
                                      fontFamily: 'RobotoMono',
                                      color: Colors.white))), // Display
                        ),
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nachricht an den Wecker',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (text) async {
                    print("Debug text event $text!");
                    final prefs = await SharedPreferences.getInstance();
                    if (prefs.getString("username") == null) {
                      return;
                    }
                    final username = prefs.getString("username")!;
                    previewMessage = "$username> $text"
                        .padRight(21)
                        .replaceAllMapped(
                            RegExp(r'.{21}'), (match) => "${match.group(0)}\n");
                    print("Now message: $previewMessage");
                    setState(() => {});
                  },
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
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Nachricht wird versendet..."),
                          duration: Duration(seconds: 1),
                        ));
                        _sendMessage();
                      }
                    },
                    child: const Text('Absenden'),
                  )
                ],
              ),
            ]));
  }
}
