import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityChecker {
  static final ConnectivityChecker _instance = ConnectivityChecker._internal();
  factory ConnectivityChecker() => _instance;
  ConnectivityChecker._internal();

  final Connectivity _connectivity = Connectivity();

  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Wait until an internet connection becomes available or the timeout elapses.
  ///
  /// Returns true if internet became available within the [timeout], otherwise
  /// returns false. This uses the connectivity stream and will cancel the
  /// subscription when done.
  Future<bool> waitForInternetConnection({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      final initial = await _connectivity.checkConnectivity();
      if (initial != ConnectivityResult.none) return true;
    } catch (e) {
      print('Error checking initial connectivity: $e');
      // fallthrough to subscription-based waiting
    }

    final completer = Completer<bool>();
    late StreamSubscription<dynamic> sub;
    late Timer timer;

    sub = _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (!completer.isCompleted) completer.complete(true);
      }
    }, onError: (err) {
      print('Connectivity stream error: $err');
    });

    timer = Timer(timeout, () {
      if (!completer.isCompleted) completer.complete(false);
    });

    final result = await completer.future;
    await sub.cancel();
    timer.cancel();
    return result;
  }
}
