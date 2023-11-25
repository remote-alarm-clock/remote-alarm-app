import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:remote_alarm/main.dart';

final credentialFormKey = GlobalKey<FormState>();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

Future<void> loginDialogBuilder(BuildContext context) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bei Datenbank anmelden'),
        content: const LoginField(),
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
            child: const Text('Anmelden'),
            onPressed: () async {
              final ScaffoldMessengerState scaffold = scaffoldKey.currentState!;
              // Validate the username form
              if (credentialFormKey.currentState!.validate()) {
                // Form is valid, so run the save function. Will also display snackbar with saving notification
                try {
                  String username = emailController.text;
                  final credential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: username, password: passwordController.text);
                  Navigator.of(context).pop();
                  scaffold.showSnackBar(SnackBar(
                      content: Text('Erfolgreich als $username angemeldet!')));
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    scaffold.showSnackBar(const SnackBar(
                        content:
                            Text('Es gibt keinen Benutzer mit dieser Email!')));
                  } else if (e.code == 'wrong-password') {
                    scaffold.showSnackBar(const SnackBar(
                        content:
                            Text('Das Passwort für den Benutzer ist falsch!')));
                  }
                }
              }
            },
          ),
        ],
      );
    },
  );
}

/**
 * LOGIN
 */
class LoginField extends StatefulWidget {
  const LoginField({super.key});

  @override
  State<LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<LoginField> {
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: credentialFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Flexible(
              child:
                  Text('Bitte melde dich bei deiner Firebase Datenbank an.')),
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-Mail',
                    ),

                    controller: emailController,
                    // Requiered to update TextFormField on stateChange
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Bitte eine E-Mail angeben!";
                      }

                      if (!RegExp(
                              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
                          .hasMatch(value)) {
                        return "E-Mail ist ungültig!";
                      }

                      return null;
                    },
                  ))),
          Flexible(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 0.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Passwort',
                    ),

                    controller: passwordController,
                    // Requiered to update TextFormField on stateChange
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Passwort ist leer!";
                      }

                      return null;
                    },
                  )))
        ],
      ),
    );
  }
}
/**
 * END HANDLE USERNAME INPUT
 */
