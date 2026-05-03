import 'package:equatable/equatable.dart';

/// Optional classification for UI (e.g. attendance) without parsing user-facing strings.
enum FailureKind {
  generic,
  httpNotFound,
  httpClient,
  httpServer,
  networkTimeout,
  networkUnavailable,
  locationServiceDisabled,
  locationTimeout,
  locationUnavailable,
}

class Failure extends Equatable {
  final String message;
  final FailureKind kind;

  const Failure(this.message, {this.kind = FailureKind.generic});

  @override
  List<Object?> get props => [message, kind];
}
