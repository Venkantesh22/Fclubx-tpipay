import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> _isConnected = ValueNotifier<bool>(true);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  ValueNotifier<bool> get isConnected => _isConnected;

  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectionStatus(results);
      },
    );
    
    // Check initial connectivity
    checkInitialConnectivity();
  }

  Future<void> checkInitialConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      _isConnected.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool isConnected = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi || 
      result == ConnectivityResult.ethernet
    );
    
    _isConnected.value = isConnected;
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _isConnected.dispose();
  }
}
