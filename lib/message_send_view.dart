import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:remote_alarm/backend.dart';
import 'package:remote_alarm/checkbox_form_field.dart';
import 'package:remote_alarm/memory.dart';
import 'package:remote_alarm/settings_page.dart';

/// This widget displays a preview of the message to be sent to the device.
class MessagePreView extends StatefulWidget {
  final DeviceProperties displayedDevice;

  const MessagePreView({super.key, required this.displayedDevice});

  @override
  State<MessagePreView> createState() => _MessagePreViewState();
}

class _MessagePreViewState extends State<MessagePreView> {
  String _displayedMessage = "";
  void updateMessage(String message) {
    _displayedMessage = message;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String username = Memory.instance.getUsername() ??
        ""; // If there is no username, give empty String.
    return widget.displayedDevice.deviceClass
        .toMessagePreview(context, _displayedMessage, username);
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

  @override
  bool get wantKeepAlive => true;

  bool useAlarm = false;
  String messageToClock = ""; // What will be sent to server (unclean)

  //final String senderName = "App";

  /// Send a new message to firebase
  void _sendMessage() async {
    dbSendMessage(widget.device, messageToClock, useAlarm);
  }

  String? _validate(String? value) {
    return dbValidateMessage(value, widget.device);
  }

  /*String _formatMessage(String messageToDisplay) {
    return "${Memory.instance.getUsername()!}> $messageToDisplay";
  }*/

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
              MessagePreView(
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
                    _messageDisplayKey.currentState!.updateMessage(text);
                  },
                  onSaved: (String? value) {
                    print("Message to Clock is: '$value'");
                    messageToClock = value!;
                  },
                  validator: _validate,
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
