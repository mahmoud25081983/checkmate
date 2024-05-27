import 'package:checkmate/services/user_service.dart';
import 'package:checkmate/splash.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as D;
import 'package:realm/realm.dart';
import 'package:workmanager/workmanager.dart';
import 'services/network_status.dart';

const appId = "checkmate-llsapiw";

/* void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Your background task code goes here
    print("Background task is running...");
    return Future.value(true);
  });
} */

void main() async {

    final db = await D.Db.create('mongodb+srv://admin:0000@test.bgwibk3.mongodb.net/?retryWrites=true&w=majority&appName=test');
  await db.open();
  WidgetsFlutterBinding.ensureInitialized();

/*     Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    "1",
    "simpleTask",
    frequency: Duration(minutes: 15), // Adjust the frequency as needed
  ); */
  await ConnectivityProvider.initConnectivity();
  final App atlasApp = App(AppConfiguration(appId));
  final UserService userService = UserService(atlasApp, db);
  runApp(MyApp(userService: userService));
}

class MyApp extends StatefulWidget {
  final UserService userService;

  const MyApp({super.key, required this.userService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ConnectivityProvider connectivityProvider;

  @override
  void initState() {
    super.initState();
    connectivityProvider = ConnectivityProvider();

    ConnectivityProvider.connectionStatusStream.listen((hasInternet) {
      if (hasInternet) {
        print("Connected to the internet");
      } else {
        print("No internet connection");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shopping List',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: SplashScreen(userService: widget.userService),
    );
  }

  @override
  void dispose() {
    ConnectivityProvider.dispose();
    super.dispose();
  }
}
