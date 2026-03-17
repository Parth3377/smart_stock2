// ════════════════════════════════════════════════════════════════════
//  lib/screens/maps/delivery_location_screen.dart
//
//  Shows Google Map with:
//  - Current device location
//  - Delivery address picker (tap on map or search)
//  - Route from store to delivery address
//  - Distance and ETA display
//  - Confirm address button
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/location_provider.dart';
import '../../models/location_model.dart';
import '../../config/map_config.dart';
import '../../services/location_service.dart';

class DeliveryLocationScreen extends StatefulWidget {
  /// If provided, shows tracking for this order
  final String? orderId;

  /// If true, user is selecting address (checkout flow)
  final bool isSelecting;

  const DeliveryLocationScreen({
    super.key,
    this.orderId,
    this.isSelecting = true,
  });

  @override
  State<DeliveryLocationScreen> createState() =>
      _DeliveryLocationScreenState();
}

class _DeliveryLocationScreenState
    extends State<DeliveryLocationScreen> {

  GoogleMapController? _mapController;
  final TextEditingController _searchCtrl = TextEditingController();

  // Map markers
  final Set<Marker>   _markers   = {};
  final Set<Polyline> _polylines = {};

  // Store location (where orders ship from)
  static const LatLng _storeLocation = LatLng(
      MapConfig.storeLat, MapConfig.storeLng);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMap();
    });
  }

  Future<void> _initMap() async {
    final provider = context.read<LocationProvider>();

    // Add store marker always
    _addStoreMarker();

    if (widget.isSelecting) {
      // Selection mode: get current GPS location
      await provider.fetchCurrentLocation();
      if (provider.hasLocation) {
        _updateDeliveryMarker(provider.selectedAddress!);
        await _moveCamera(LatLng(
          provider.selectedAddress!.lat,
          provider.selectedAddress!.lng,
        ));
      }
    } else if (widget.orderId != null) {
      // Tracking mode: load from Firestore
      _listenToOrderTracking();
    }
  }

  void _listenToOrderTracking() {
    LocationService.instance
        .streamOrderDelivery(widget.orderId!)
        .listen((data) {
      if (data == null || !mounted) return;
      final loc = data['deliveryLocation'];
      if (loc != null) {
        final location = LocationModel.fromMap(
            Map<String, dynamic>.from(loc));
        _updateDeliveryMarker(location);
        _drawRouteLine(location);
      }
    });
  }

  void _addStoreMarker() {
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('store'),
        position: _storeLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: 'SmartStock Store',
          snippet: 'Order ships from here',
        ),
      ));
    });
  }

  void _updateDeliveryMarker(LocationModel location) {
    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'delivery');
      _markers.add(Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(location.lat, location.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'Delivery Location',
          snippet: location.address,
        ),
      ));
    });
  }

  Future<void> _drawRouteLine(LocationModel destination) async {
    final provider = context.read<LocationProvider>();
    provider.selectedAddress = destination;
    await provider.calculateRoute();

    if (provider.routeInfo != null && mounted) {
      final points = provider.routeInfo!.polylinePoints
          .map((p) => LatLng(p.lat, p.lng))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: const Color(0xFF2E6CF6),
          width: 4,
        ));
      });
    }
  }

  Future<void> _moveCamera(LatLng position) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: MapConfig.zoomDefault),
      ),
    );
  }

  // User tapped on map — set delivery location there
  Future<void> _onMapTap(LatLng position) async {
    if (!widget.isSelecting) return;

    final provider = context.read<LocationProvider>();
    await provider.setAddressFromLatLng(
        position.latitude, position.longitude);

    if (provider.selectedAddress != null) {
      _updateDeliveryMarker(provider.selectedAddress!);
      await _drawRouteLine(provider.selectedAddress!);
    }
  }

  // Search address by text
  Future<void> _searchAddress() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;

    final provider = context.read<LocationProvider>();
    await provider.setAddressFromText(query);

    if (provider.selectedAddress != null) {
      _updateDeliveryMarker(provider.selectedAddress!);
      await _moveCamera(LatLng(
        provider.selectedAddress!.lat,
        provider.selectedAddress!.lng,
      ));
      await _drawRouteLine(provider.selectedAddress!);
    }
  }

  // Confirm delivery address and return to checkout
  void _confirmAddress() {
    final provider = context.read<LocationProvider>();
    if (provider.selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery location on the map.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pop(context, provider.selectedAddress);
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
        title: Text(
          widget.isSelecting ? 'Select Delivery Location' : 'Track Order',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [

              // ── GOOGLE MAP ────────────────────────────────────────
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(MapConfig.storeLat, MapConfig.storeLng),
                  zoom:   MapConfig.zoomDefault,
                ),
                onMapCreated: (ctrl) => _mapController = ctrl,
                onTap: _onMapTap,
                markers:   _markers,
                polylines: _polylines,
                myLocationEnabled:       true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled:     true,
                mapType: MapType.normal,
                style: _darkMapStyle,
              ),

              // ── SEARCH BAR (top) ──────────────────────────────────
              if (widget.isSelecting)
                Positioned(
                  top: 12, left: 16, right: 16,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161A22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.search, color: Color(0xFFA1A6B3), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: 'Search delivery address...',
                            hintStyle: TextStyle(color: Color(0xFFA1A6B3)),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          onSubmitted: (_) => _searchAddress(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Color(0xFF2E6CF6), size: 18),
                        onPressed: _searchAddress,
                      ),
                    ]),
                  ),
                ),

              // ── GPS BUTTON ────────────────────────────────────────
              if (widget.isSelecting)
                Positioned(
                  top: 72, right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'gps',
                    backgroundColor: const Color(0xFF161A22),
                    onPressed: () async {
                      await provider.fetchCurrentLocation();
                      if (provider.currentLocation != null) {
                        _updateDeliveryMarker(provider.currentLocation!);
                        await _moveCamera(LatLng(
                          provider.currentLocation!.lat,
                          provider.currentLocation!.lng,
                        ));
                        await _drawRouteLine(provider.currentLocation!);
                      }
                    },
                    child: provider.state == LocationState.loading
                        ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location,
                        color: Color(0xFF2E6CF6), size: 18),
                  ),
                ),

              // ── BOTTOM INFO CARD ──────────────────────────────────
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  decoration: const BoxDecoration(
                    color: Color(0xFF161A22),
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Route info (distance + ETA)
                      if (provider.hasRoute) ...[
                        Row(children: [
                          _infoChip(
                            Icons.route,
                            provider.routeInfo!.distance,
                            const Color(0xFF2E6CF6),
                          ),
                          const SizedBox(width: 12),
                          _infoChip(
                            Icons.access_time,
                            provider.routeInfo!.duration,
                            Colors.orange,
                          ),
                        ]),
                        const SizedBox(height: 12),
                      ],

                      // Selected address
                      if (provider.hasAddress) ...[
                        Row(children: [
                          const Icon(Icons.location_on,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              provider.selectedAddress!.address,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 14),
                      ] else ...[
                        const Text(
                          'Tap on the map to select delivery location',
                          style: TextStyle(
                              color: Color(0xFFA1A6B3), fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Confirm button (only in selection mode)
                      if (widget.isSelecting)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: provider.hasAddress
                                ? _confirmAddress
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E6CF6),
                              disabledBackgroundColor:
                              Colors.white12,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Confirm Delivery Location',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),

                      // Tracking status (only in tracking mode)
                      if (!widget.isSelecting)
                        StreamBuilder<Map<String, dynamic>?>(
                          stream: widget.orderId != null
                              ? LocationService.instance
                              .streamOrderDelivery(widget.orderId!)
                              : const Stream.empty(),
                          builder: (context, snap) {
                            final status =
                                snap.data?['deliveryStatus'] ?? 'Pending';
                            final distance =
                                snap.data?['deliveryDistance'] ?? '';
                            final eta =
                                snap.data?['estimatedArrival'] ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _statusRow(status),
                                if (distance.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Distance: $distance  •  ETA: $eta',
                                      style: const TextStyle(
                                          color: Color(0xFFA1A6B3),
                                          fontSize: 12),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _statusRow(String status) {
    final Color color;
    final IconData icon;
    switch (status) {
      case 'Dispatched':
        color = Colors.orange; icon = Icons.local_shipping; break;
      case 'Delivered':
        color = Colors.green;  icon = Icons.check_circle;   break;
      default:
        color = const Color(0xFF2E6CF6); icon = Icons.hourglass_top;
    }
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(
        'Status: $status',
        style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ]);
  }

  // Dark map style to match app theme
  static const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#212121"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2c2c2c"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]}
]
''';
}
