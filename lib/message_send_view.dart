import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/checkbox_form_field.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';

/// This widget displays a preview of the message to be sent to the device.
class MessagePreView extends StatefulWidget {
  final DeviceProperties displayedDevice;
  String _displayedMessage = "";

  MessagePreView(String displayedMessage,
      {super.key, required this.displayedDevice})
      : _displayedMessage = displayedMessage;

  @override
  State<MessagePreView> createState() => _MessagePreViewState();
}

class _MessagePreViewState extends State<MessagePreView> {
  final clockImage = 'assets/clockface_zoom.svg';

  /// This is exactly what will be displayed. Format eralier please.
  void updateMessage(String message) {
    setState(() {
      widget._displayedMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width =
        MediaQuery.of(context).size.width * 0.4; //40% of screen width

    double fullScreenWidth =
        MediaQuery.of(context).size.width; //100% of screen width

    return SizedBox(
        width: fullScreenWidth,
        child: Stack(
          children: [
            SvgPicture.asset(clockImage,
                width: fullScreenWidth,
                semanticsLabel: 'clockface'), // Background picture of clockface
            // Image aspect ratio: 0.5053, left relative to image: 0.2565, top relative to height: 0.2737
            Positioned(
              top: fullScreenWidth * 0.5053 * 0.2737, // height * top spacing
              left: fullScreenWidth * 0.2565, // width * left spacing
              child: Container(
                alignment: Alignment.topLeft,
                width: width,
                height: 0.65 * width, // Match 128*64 aspect ratio
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                        widget._displayedMessage.padRight(21).replaceAllMapped(
                            RegExp(r'.{21}'), (match) => "${match.group(0)}\n"),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 90,
                            fontFamily: 'RobotoMono',
                            color: Colors.white))), // Display
              ),
            )
          ],
        ));
  }
}

class MessageSendView extends StatefulWidget {
  final DeviceProperties device;
  const MessageSendView({super.key, required this.device});

  @override
  State<MessageSendView> createState() => _MessageSendViewState();
}

class _MessageSendViewState extends State<MessageSendView>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _messageDisplayKey = GlobalKey<_MessagePreViewState>();
  final letterLimitForMessage = 126;

  @override
  bool get wantKeepAlive => true;

  bool useAlarm = false;
  String messageToClock = ""; // What will be sent to server (unclean)

  //final String senderName = "App";

  /// Send a new message to firebase
  void _sendMessage() async {
    dbSendMessage(widget.device, messageToClock, useAlarm);
  }

  String _formatMessage(String messageToDisplay) {
    return "${Memory.instance.getUsername()!}> $messageToDisplay";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!isLoggedIn()) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const SettingsPage();
        }));
      });
    }

    print("Current clock ID ${widget.device.id}");

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
              MessagePreView(_formatMessage(""),
                  key: _messageDisplayKey, displayedDevice: widget.device),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nachricht an den Wecker',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (text) async {
                    print("Debug text event $text!");
                    if (Memory.instance.getUsername() == null) {
                      return;
                    }
                    // Show message on screen
                    _messageDisplayKey.currentState!
                        .updateMessage(_formatMessage(text));
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
