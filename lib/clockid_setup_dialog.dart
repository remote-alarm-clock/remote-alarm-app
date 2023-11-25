import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final clockidFormKey = GlobalKey<FormState>();

Future<void> clockidDialogBuilder(BuildContext context) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Uhr auswählen'),
        content: const ClockIDInputField(),
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
              // Validate the clock form
              if (clockidFormKey.currentState!.validate()) {
                // Form is valid, so run the save function. Will also display snackbar with saving notification
                clockidFormKey.currentState!.save();
              }
            },
          ),
        ],
      );
    },
  );
}

/**
 * HANDLE CLOCKID INPUT
 */
class ClockIDInputField extends StatefulWidget {
  const ClockIDInputField({super.key});

  @override
  State<ClockIDInputField> createState() => _ClockIDInputFieldState();
}

class _ClockIDInputFieldState extends State<ClockIDInputField> {
  String _clockid = "";

  void readData() async {
    // Load the username async.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString("clock_id") == null) {
      setState(() => _clockid = "");
      print("prefs are empty");
    } else {
      setState(() {
        _clockid = prefs.getString("clock_id")!;
        print("prefs name loaded to $_clockid");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    readData();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: clockidFormKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Uhr-ID',
                      ),
                      initialValue: _clockid,
                      // Requiered to update TextFormField on stateChange
                      key: Key(_clockid),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onSaved: (String? value) async {
                        print("New clock_id is: '$value'");
                        _clockid = value!;
                        // Save new username to prefs
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Uhr-ID wird auf '$_clockid' gesetzt!")));
                        final prefs = await SharedPreferences.getInstance();
                        prefs.setString("clock_id", _clockid);
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "Bitte wähle eine Uhr-ID!";
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
