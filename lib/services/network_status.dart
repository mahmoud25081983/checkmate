import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConnectivityProvider {
  static final ConnectivityProvider _instance = ConnectivityProvider._internal();
  static ConnectivityResult connectivityResult = ConnectivityResult.none;
  static final Connectivity connectivity = Connectivity();
  static late StreamSubscription<ConnectivityResult> connectivitySubscription;
  static final StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  static Stream<bool> get connectionStatusStream => connectionStatusController.stream;
  static bool isConnected = false;
  static bool hasInternet = false;

  factory ConnectivityProvider() {
    return _instance;
  }

  ConnectivityProvider._internal() {
    initConnectivity();
    connectivitySubscription = connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  static Future<void> initConnectivity() async {
    try {
      connectivityResult = await connectivity.checkConnectivity();
      await _updateConnectionStatus(connectivityResult);
    } on PlatformException catch (e) {
      debugPrint('Couldn\'t check connectivity status: $e');
    }
  }

  static Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    isConnected = result != ConnectivityResult.none;
    if (isConnected) {
      try {
        final internetResult = await InternetAddress.lookup('google.com');
        hasInternet = internetResult.isNotEmpty && internetResult[0].rawAddress.isNotEmpty;
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
  }

  static void dispose() {
    connectivitySubscription.cancel();
    connectionStatusController.close();
  }
}
