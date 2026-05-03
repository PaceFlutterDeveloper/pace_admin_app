import 'package:equatable/equatable.dart';

class GeofenceConfig extends Equatable {
  final String schoolName;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusMeters;

  const GeofenceConfig({
    required this.schoolName,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusMeters,
  });

  @override
  List<Object?> get props => [
        schoolName,
        centerLatitude,
        centerLongitude,
        radiusMeters,
      ];
}
