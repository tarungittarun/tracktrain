import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Watches the network state so the app can present Offline vs Online mode
/// honestly and route live-mode requests only when a path to the internet
/// exists.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService() {
    _subscription =
        Connectivity().onConnectivityChanged.listen(_update);
    unawaited(_refresh());
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  Future<void> _refresh() async {
    try {
      _update(await Connectivity().checkConnectivity());
    } catch (_) {
      // Connectivity plugins can throw on some OEM builds; assume offline —
      // the whole app is designed to run without internet anyway.
      _update(const [ConnectivityResult.none]);
    }
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online != _isOnline) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
