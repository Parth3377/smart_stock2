// ════════════════════════════════════════════════════════════════════
//  lib/models/location_model.dart
// ════════════════════════════════════════════════════════════════════

class LocationModel {
  final double lat;
  final double lng;
  final String address;

  const LocationModel({
    required this.lat,
    required this.lng,
    required this.address,
  });

  Map<String, dynamic> toMap() => {
    'lat': lat,
    'lng': lng,
    'address': address,
  };

  factory LocationModel.fromMap(Map<String, dynamic> map) => LocationModel(
    lat:     (map['lat']  as num? ?? 0).toDouble(),
    lng:     (map['lng']  as num? ?? 0).toDouble(),
    address:  map['address'] as String? ?? '',
  );

  @override
  String toString() => address.isNotEmpty ? address : '$lat, $lng';
}

class RouteInfoModel {
  final String distance;      // "4.2 km"
  final String duration;      // "12 mins"
  final double distanceMeters;
  final List<LatLngPoint> polylinePoints;

  const RouteInfoModel({
    required this.distance,
    required this.duration,
    required this.distanceMeters,
    required this.polylinePoints,
  });
}

class LatLngPoint {
  final double lat;
  final double lng;
  const LatLngPoint(this.lat, this.lng);
}
