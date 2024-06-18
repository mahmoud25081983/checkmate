import 'package:checkmate/screens/login.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import 'signup.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = 'splashscreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_rounded,
                size: 100,
                color: Colors.greenAccent,
              ),
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20)),
                  onPressed: () async {
                    try {
                      final navigator = Navigator.of(context);
                      navigator.pushReplacement(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return LoginScreen(
                        );
                      }));
                    } on RealmException catch (error) {
                      if (kDebugMode) {
                        print(
                            "Error while loading login screen. ${error.message}");
                      }
                    }
                  },
                  child: const Text("Login", style: TextStyle(fontSize: 20))),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20)),
                  onPressed: () async {
                    try {
                      final navigator = Navigator.of(context);
                      navigator.pushReplacement(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SignupScreen();
                      }));
                    } on RealmException catch (error) {
                      if (kDebugMode) {
                        print(
                            "Error while loading signup screen. ${error.message}");
                      }
                    }
                  },
                  child: const Text("Signup", style: TextStyle(fontSize: 20)))
            ],
          ),
        ),
      ),
    );
  }
}
