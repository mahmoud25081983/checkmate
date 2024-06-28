import 'package:checkmate/services/user_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:checkmate/screens/home.dart';
import 'package:checkmate/services/realm_service.dart';
import '../services/connectivity_provider.dart';

import 'splash.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static const String routeName = 'loginscreen';
  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              style:
                  ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              onPressed: () async {
                try {
                  final navigator = Navigator.of(context);
                  navigator.pushReplacement(
                      MaterialPageRoute(builder: (BuildContext context) {
                    return SplashScreen();
                  }));
                } on RealmException catch (error) {
                  if (kDebugMode) {
                    print(
                        "Error while loading signup screen. ${error.message}");
                  }
                }
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 100,
                  color: Colors.blueAccent,
                ),
                const SizedBox(
                  height: 30,
                ),
                const Text("Login",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(
                  height: 30,
                ),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        hintText: "Email", border: OutlineInputBorder())),
                const SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                      hintText: "Password", border: OutlineInputBorder()),
                  obscureText: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20)),
                    onPressed: () async {
                      try {
                        final navigator = Navigator.of(context);

                        User user = await userService.logInUserEmailPassword(
                            emailController.text, passwordController.text);

                        navigator.pushReplacement(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return HomeScreen();
                        }));
                      } on RealmException catch (error) {
                        if (kDebugMode) {
                          print("Error during login ${error.message}");
                        }
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)));
                        }
                      }
                    },
                    child: const Text("Login", style: TextStyle(fontSize: 20)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
