import 'package:checkmate/screens/home.dart';
import 'package:checkmate/screens/login.dart';
import 'package:checkmate/screens/signup.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';



import 'screens/splash.dart';
import 'package:provider/provider.dart';

import 'services/notification_services.dart';
import 'services/realm_service.dart';

const appId = "checkmate-llsapiw";


Future<void> main() async {
  //  final App atlasApp = App(AppConfiguration(appId));
  // final UserService userService = UserService(atlasApp);
   WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initializeNotification();
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<UserService>(create: (_) => UserService(appId)),
    ChangeNotifierProxyProvider<UserService, ItemService?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, UserService appServices,
            ItemService? realmServices) {
          return appServices.atlasApp!.currentUser != null
              ? ItemService(appServices.atlasApp!)
              : null;
        }),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        SignupScreen.routeName: (context) => SignupScreen(),
        LoginScreen.routeName: (context) => LoginScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
