import 'package:checkmate/screens/home.dart';
import 'package:checkmate/screens/login.dart';
import 'package:checkmate/screens/signup.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:flutter/material.dart';

import 'screens/splash.dart';
import 'package:provider/provider.dart';

import 'services/connectivity_provider.dart';
import 'services/notification_services.dart';
import 'services/realm_service.dart';

const appId = "checkmate-llsapiw";

Future<void> main() async {
  //  final App atlasApp = App(AppConfiguration(appId));
  // final UserService userService = UserService(atlasApp);
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initializeNotification();
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ConnectivityProvider>(
        create: (_) => ConnectivityProvider()),
    ChangeNotifierProvider<UserService>(create: (_) => UserService(appId)),
    ChangeNotifierProxyProvider<UserService, ItemService?>(
        // RealmServices can only be initialized only if the user is logged in.
        create: (context) => null,
        update: (BuildContext context, UserService appServices,
            ItemService? realmServices) {
          return appServices.atlasApp.currentUser != null
              ? ItemService(appServices.atlasApp)
              : null;
        }),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
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


/* exports = async function(changeEvent) {
  // Log the entire change event for debugging purposes
  console.log("Change event:", JSON.stringify(changeEvent));
  
  try {
    // Ensure documentKey and _id are present
    if (!changeEvent.documentKey || !changeEvent.documentKey._id) {
      throw new Error("Missing documentKey or _id in changeEvent");
    }

    // Access the _id of the changed document
    const docId = changeEvent.documentKey._id;

    // Get the MongoDB service you want to use (see "Linked Data Sources" tab)
    const serviceName = "mongodb-atlas";
    const databaseName = "checkmate";
    const collection = context.services.get(serviceName).db(databaseName).collection(changeEvent.ns.coll);

    // Get the "FullDocument" present in the Insert/Replace/Update ChangeEvents
    // Perform operations based on the change event type
    if (changeEvent.operationType === "delete") {
      await collection.deleteOne({"_id": docId});
      console.log(`Deleted document with _id: ${docId}`);
    } else if (changeEvent.operationType === "insert") {
      await collection.insertOne(changeEvent.fullDocument);
      console.log(`Inserted document: ${JSON.stringify(changeEvent.fullDocument)}`);
    } else if (changeEvent.operationType === "update" || changeEvent.operationType === "replace") {
      await collection.replaceOne({"_id": docId}, changeEvent.fullDocument);
      console.log(`Replaced document with _id: ${docId}`);
    } else {
      console.log(`Unhandled operation type: ${changeEvent.operationType}`);
    }
  } catch (err) {
    console.log("Error performing MongoDB write:", err.message);
  }
}; */