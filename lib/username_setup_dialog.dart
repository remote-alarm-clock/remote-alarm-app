import 'package:flutter/material.dart';
import 'package:remote_alarm/memory.dart';

/// This file contains the username set dialog definitions and the corresponsing builder function.

final usernameFormKey = GlobalKey<FormState>();

Future<void> usernameDialogBuilder(BuildContext context) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Setze deinen Benutzernamen'),
        content: const UsernameInputField(),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Speichern'),
            onPressed: () async {
              Navigator.of(context).pop();
              // Validate the username form
              if (usernameFormKey.currentState!.validate()) {
                // Form is valid, so run the save function. Will also display snackbar with saving notification
                usernameFormKey.currentState!.save();
              }
            },
          ),
        ],
      );
    },
  );
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
  String _username = "";
  final usernameLimit = 8;

  void readData() async {
    // Load the username async.
    String? name = Memory.instance.getUsername();
    name ??= "";
    setState(() {
      _username = name!;
      print("Username loaded to $_username");
    });
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
        key: usernameFormKey,
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
                      onSaved: (String? value) async {
                        print("New username is: '$value'");
                        _username = value!;
                        // Save new username to prefs
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Benutzername wird auf '$_username' gesetzt!")));
                        await Memory.instance.setUsername(_username);
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
          ],
        ));
  }
}
/**
 * END HANDLE USERNAME INPUT
 */
