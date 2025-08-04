// lib/data/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternet() async {
    final results = await _connectivity.checkConnectivity();
    // Check if the list of results contains mobile or wifi
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }
}
