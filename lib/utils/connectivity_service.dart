import 'dart:async';

import 'package:nb_utils/nb_utils.dart';

import '../main.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void init() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
      bool connected = result != ConnectivityResult.none && await isNetworkAvailable();
      bool wasConnected = appStore.isInternetAvailable;

      appStore.setInternetAvailable(connected);

      if (connected && !wasConnected) {
        LiveStream().emit('internet_reconnected');
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
