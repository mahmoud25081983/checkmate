import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

  final StreamController<bool> connectionStatusController =
      StreamController<bool>();

  Stream<bool> get connectionStatusStream => connectionStatusController.stream;
  bool isConnected = false;
  bool hasInternet = false;

  ConnectivityProvider() {
    initConnectivity();
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void initConnectivity() async {
    try {
      connectivityResult = await connectivity.checkConnectivity();
      _updateConnectionStatus(connectivityResult);
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    isConnected = result != ConnectivityResult.none;
    notifyListeners();
    if (isConnected) {
      try {
        List<InternetAddress> internetResult =
            await InternetAddress.lookup('google.com');
        hasInternet = internetResult.isNotEmpty &&
            internetResult[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        hasInternet = false;
      }
    } else {
      hasInternet = false;
    }

    if (!connectionStatusController.isClosed) {
      connectionStatusController.add(hasInternet);
      debugPrint('Connection Status: $result, Has Internet: $hasInternet');
    }

    notifyListeners();
  }

  void disposing() {
    connectivitySubscription.cancel();
    connectionStatusController.close();
    notifyListeners();
  }
}