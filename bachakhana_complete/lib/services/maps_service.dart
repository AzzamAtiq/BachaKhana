import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/models.dart';

class MapsService {
  /// Get user's current location
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  }

  /// Calculate distance between user and restaurant (km)
  static double calculateDistance(
    double userLat, double userLng,
    double restLat, double restLng,
  ) {
    final distMeters = Geolocator.distanceBetween(
      userLat, userLng, restLat, restLng);
    return (distMeters / 1000);
  }

  /// Convert address to coordinates
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (_) {}
    return null;
  }

  /// Build Google Maps markers for all restaurants
  static Set<Marker> buildMarkers({
    required List<RestaurantModel> restaurants,
    required Function(RestaurantModel) onTap,
  }) {
    return restaurants.map((r) => Marker(
      markerId: MarkerId(r.firestoreId),
      position: LatLng(r.latitude, r.longitude),
      infoWindow: InfoWindow(
        title: r.name,
        snippet: 'Rs ${r.bagPrice} · ${r.bagsLeft} bags',
        onTap: () => onTap(r),
      ),
    )).toSet();
  }

  /// Rawalpindi/Islamabad center coordinates
  static const LatLng rwpIsbCenter = LatLng(33.6844, 73.0479);

  /// Restaurant coordinates (RWP/ISB)
  static const Map<String, LatLng> restaurantCoords = {
    'Savour Foods':         LatLng(33.6938, 73.0651), // G-9 Markaz
    'Mei Kong':             LatLng(33.7294, 73.0931), // Jinnah Super
    'Texas Steak House':    LatLng(33.7215, 73.0578), // F-7 Markaz
    'Chaaye Khana':         LatLng(33.7340, 73.0517), // F-6
    'GK Restaurant':        LatLng(33.6007, 73.0679), // Saddar RWP
    'Monal Downtown':       LatLng(33.7037, 73.0486), // Blue Area
    'Anarkali Food St.':    LatLng(33.5986, 73.0659), // Raja Bazaar
    'Tahir Khan Broast':    LatLng(33.6021, 73.0714), // Saddar
    'Tuscany Courtyard':    LatLng(33.7180, 73.0621), // F-7/4
    'Ox & Grill':           LatLng(33.7074, 73.0489), // Centaurus
    'Basha Istanbul':       LatLng(33.5553, 73.0870), // Bahria Town
    'BBQ Tonight':          LatLng(33.5418, 73.1043), // Bahria Phase 7
  };
}
