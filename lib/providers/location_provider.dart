// ════════════════════════════════════════════════════════════════════
//  lib/providers/location_provider.dart
//
//  Manages:
//  - Current device location
//  - Selected delivery address
//  - Route calculation
//  - Delivery tracking state
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

enum LocationState { idle, loading, loaded, error }

class LocationProvider extends ChangeNotifier {

  LocationState state         = LocationState.idle;
  LocationModel? currentLocation;   // device GPS location
  LocationModel? selectedAddress;   // chosen delivery address
  RouteInfoModel? routeInfo;        // route from store to delivery
  String? errorMessage;

  bool get hasLocation     => currentLocation != null;
  bool get hasAddress      => selectedAddress != null;
  bool get hasRoute        => routeInfo != null;

  // ════════════════════════════════════════════════════════════════════
  //  GET CURRENT GPS LOCATION
  // ════════════════════════════════════════════════════════════════════
  Future<void> fetchCurrentLocation() async {
    state = LocationState.loading;
    errorMessage = null;
    notifyListeners();

    final loc = await LocationService.instance.getCurrentLocation();

    if (loc != null) {
      currentLocation = loc;
      selectedAddress ??= loc; // auto-set as delivery address if not set
      state = LocationState.loaded;
    } else {
      errorMessage = 'Unable to get your location. Please enable GPS.';
      state = LocationState.error;
    }
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════
  //  SET DELIVERY ADDRESS MANUALLY (from text input)
  // ════════════════════════════════════════════════════════════════════
  Future<void> setAddressFromText(String addressText) async {
    state = LocationState.loading;
    notifyListeners();

    final loc = await LocationService.instance.geocodeAddress(addressText);
    if (loc != null) {
      selectedAddress = loc;
      state = LocationState.loaded;
    } else {
      errorMessage = 'Address not found. Please try a different address.';
      state = LocationState.error;
    }
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════
  //  SET DELIVERY ADDRESS FROM MAP TAP
  // ════════════════════════════════════════════════════════════════════
  Future<void> setAddressFromLatLng(double lat, double lng) async {
    state = LocationState.loading;
    notifyListeners();

    final address = await LocationService.instance.reverseGeocode(lat, lng);
    selectedAddress = LocationModel(lat: lat, lng: lng, address: address);
    state = LocationState.loaded;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════
  //  CALCULATE ROUTE from store to delivery address
  // ════════════════════════════════════════════════════════════════════
  Future<void> calculateRoute() async {
    if (selectedAddress == null) return;

    state = LocationState.loading;
    notifyListeners();

    final route = await LocationService.instance.getRoute(
      originLat:  23.0225,   // SmartStock store lat (Ahmedabad)
      originLng:  72.5714,   // SmartStock store lng
      destLat:    selectedAddress!.lat,
      destLng:    selectedAddress!.lng,
    );

    routeInfo = route;
    state = LocationState.loaded;
    notifyListeners();
  }

  // ════════════════════════════════════════════════════════════════════
  //  CLEAR — reset for new order
  // ════════════════════════════════════════════════════════════════════
  void clear() {
    selectedAddress = null;
    routeInfo       = null;
    errorMessage    = null;
    state           = LocationState.idle;
    notifyListeners();
  }
}
