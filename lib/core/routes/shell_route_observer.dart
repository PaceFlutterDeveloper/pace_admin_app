import 'package:flutter/material.dart';

/// Attached to the main [ShellRoute] so [RouteAware] pages (e.g. home) can refresh when a pushed route is popped.
final RouteObserver<ModalRoute<void>> shellRouteObserver =
    RouteObserver<ModalRoute<void>>();
