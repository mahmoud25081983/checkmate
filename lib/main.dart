import 'package:checkmate/services/user_service.dart';
import 'package:flutter/material.dart';

import 'screens/splash.dart';
import 'package:provider/provider.dart';

import 'services/realm_service.dart';


const appId = "checkmate-llsapiw";

void main() {
   //  final App atlasApp = App(AppConfiguration(appId));
 // final UserService userService = UserService(atlasApp);
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<UserService>(create: (_) => UserService(appId)),
    ChangeNotifierProxyProvider<UserService, ItemService?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, UserService appServices, ItemService? realmServices) {
          return appServices.atlasApp.currentUser != null ? ItemService(appServices.atlasApp) : null;
        }),
  ], child:  const MyApp()));
}


class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const SplashScreen(),
    );
  }
}
