// ════════════════════════════════════════════════════════════════════
//  lib/config/map_config.dart
// ════════════════════════════════════════════════════════════════════

class MapConfig {
  MapConfig._();

  // ✅ Your real Google Maps API key
  static const String apiKey = 'AIzaSyCooTe0X_W2gErtGc2xgf6CV-GNZz2Fk2U';

  // SmartStock store location (Ahmedabad)
  static const double storeLat     = 23.0225;
  static const double storeLng     = 72.5714;
  static const String storeAddress = 'SmartStock Warehouse, Ahmedabad, Gujarat';

  // Map zoom levels
  static const double zoomCity    = 12.0;
  static const double zoomStreet  = 16.0;
  static const double zoomDefault = 14.0;
}



// // ════════════════════════════════════════════════════════════════════
// //  lib/config/map_config.dart
// //
// //  ⚠️  Replace YOUR_GOOGLE_MAPS_API_KEY with your real API key.
// //
// //  How to get API key:
// //  1. Go to https://console.cloud.google.com
// //  2. Enable: Maps SDK for Android, Maps SDK for iOS,
// //             Directions API, Geocoding API
// //  3. Create credentials → API Key → copy it here
// // ════════════════════════════════════════════════════════════════════
//
// class MapConfig {
//   MapConfig._();
//
//   // 🔑 PASTE YOUR KEY HERE
//   static const String apiKey = 'AIzaSyCooTe0X_W2gErtGc2xgf6CV-GNZz2Fk2U';
//
//   // SmartStock warehouse / store location (Ahmedabad)
//   static const double storeLat = 23.0225;
//   static const double storeLng = 72.5714;
//   static const String storeAddress = 'SmartStock Warehouse, Ahmedabad, Gujarat';
//
//   // Default map zoom levels
//   static const double zoomCity    = 12.0;
//   static const double zoomStreet  = 16.0;
//   static const double zoomDefault = 14.0;
// }
