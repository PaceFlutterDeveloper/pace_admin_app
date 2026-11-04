import 'dart:async';

import 'package:flutter/material.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(
    Stream<dynamic> stream, {
    List<Listenable> listenables = const [],
  }) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
    _listenables = listenables;
    for (final listenable in _listenables) {
      listenable.addListener(notifyListeners);
    }
  }

  late final StreamSubscription<dynamic> _subscription;
  late final List<Listenable> _listenables;

  @override
  void dispose() {
    _subscription.cancel();
    for (final listenable in _listenables) {
      listenable.removeListener(notifyListeners);
    }
    super.dispose();
  }
}
