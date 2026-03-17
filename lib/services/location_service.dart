// ════════════════════════════════════════════════════════════════════
//  lib/services/location_service.dart
//
//  Handles:
//  1. Get device current location (geolocator)
//  2. Reverse geocoding (lat/lng → address) via Google Geocoding API
//  3. Get route + distance + ETA via Google Directions API
//  4. Save delivery location to Firestore on order
//  5. Stream order delivery status from Firestore
// ════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/map_config.dart';
import '../models/location_model.dart';

class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  final _db = FirebaseFirestore.instance;

  // ════════════════════════════════════════════════════════════════════
  //  1. GET CURRENT DEVICE LOCATION
  // ════════════════════════════════════════════════════════════════════
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // Check / request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get readable address
      final address = await reverseGeocode(
          position.latitude, position.longitude);

      return LocationModel(
        lat:     position.latitude,
        lng:     position.longitude,
        address: address,
      );
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  2. REVERSE GEOCODING — lat/lng → readable address string
  // ════════════════════════════════════════════════════════════════════
  Future<String> reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?latlng=$lat,$lng'
            '&key=${MapConfig.apiKey}',
      );
      final response = await http.get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results[0]['formatted_address'] as String? ?? '$lat, $lng';
        }
      }
    } catch (_) {}
    return '$lat, $lng';
  }

  // ════════════════════════════════════════════════════════════════════
  //  3. FORWARD GEOCODING — address string → lat/lng
  // ════════════════════════════════════════════════════════════════════
  Future<LocationModel?> geocodeAddress(String address) async {
    try {
      final encoded = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
            '?address=$encoded'
            '&key=${MapConfig.apiKey}',
      );
      final response = await http.get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final loc = results[0]['geometry']['location'];
          return LocationModel(
            lat:     (loc['lat'] as num).toDouble(),
            lng:     (loc['lng'] as num).toDouble(),
            address: results[0]['formatted_address'] as String? ?? address,
          );
        }
      }
    } catch (_) {}
    return null;
  }

  // ════════════════════════════════════════════════════════════════════
  //  4. GET ROUTE — origin → destination
  //  Returns distance, duration, and polyline points for drawing route
  // ════════════════════════════════════════════════════════════════════
  Future<RouteInfoModel?> getRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=$originLat,$originLng'
            '&destination=$destLat,$destLng'
            '&mode=driving'
            '&key=${MapConfig.apiKey}',
      );

      final response = await http.get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;

      final route = routes[0];
      final leg   = route['legs'][0];

      final distance        = leg['distance']['text'] as String;
      final duration        = leg['duration']['text'] as String;
      final distanceMeters  = (leg['distance']['value'] as int).toDouble();

      // Decode polyline
      final encoded = route['overview_polyline']['points'] as String;
      final points  = _decodePolyline(encoded);

      return RouteInfoModel(
        distance:       distance,
        duration:       duration,
        distanceMeters: distanceMeters,
        polylinePoints: points,
      );
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  5. SAVE DELIVERY LOCATION TO FIRESTORE ORDER
  // ════════════════════════════════════════════════════════════════════
  Future<void> saveDeliveryLocation({
    required String orderId,
    required LocationModel location,
  }) async {
    try {
      await _db.collection('orders').doc(
        orderId.replaceAll('#', ''),
      ).update({
        'deliveryLocation': location.toMap(),
        'deliveryStatus':   'Pending',
        'updatedAt':        FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════════════
  //  6. STREAM ORDER DELIVERY INFO (real-time updates from Firestore)
  // ════════════════════════════════════════════════════════════════════
  Stream<Map<String, dynamic>?> streamOrderDelivery(String orderId) {
    return _db
        .collection('orders')
        .doc(orderId.replaceAll('#', ''))
        .snapshots()
        .map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return {
        'deliveryLocation': data['deliveryLocation'],
        'deliveryStatus':   data['deliveryStatus'] ?? 'Pending',
        'deliveryDistance': data['deliveryDistance'] ?? '',
        'estimatedArrival': data['estimatedArrival'] ?? '',
      };
    });
  }

  // ════════════════════════════════════════════════════════════════════
  //  7. UPDATE DELIVERY STATUS (Admin updates after dispatching)
  // ════════════════════════════════════════════════════════════════════
  Future<void> updateDeliveryStatus({
    required String orderId,
    required String status,        // Pending | Dispatched | Delivered
    String distance        = '',
    String estimatedArrival = '',
  }) async {
    try {
      await _db.collection('orders').doc(
        orderId.replaceAll('#', ''),
      ).update({
        'deliveryStatus':   status,
        'deliveryDistance': distance,
        'estimatedArrival': estimatedArrival,
        'updatedAt':        FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // ════════════════════════════════════════════════════════════════════
  //  POLYLINE DECODER (Google encoded polyline format)
  // ════════════════════════════════════════════════════════════════════
  List<LatLngPoint> _decodePolyline(String encoded) {
    final List<LatLngPoint> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dlng;

      points.add(LatLngPoint(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
