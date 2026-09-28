import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the OS sees a network interface; this does not prove
/// that Firebase is reachable. SOS SMS must never depend on this result.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._();

  factory ConnectivityService() => _instance;

  ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> isOnline() async {
    try {
      return _hasConnection(await _connectivity.checkConnectivity());
    } catch (_) {
      return false;
    }
  }

  Stream<bool> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map(_hasConnection);

  bool _hasConnection(List<ConnectivityResult> results) => results.any(
        (result) => result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );
}