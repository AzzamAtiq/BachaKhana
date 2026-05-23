import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../services/maps_service.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapCtrl;
  Position? _userPosition;
  RestaurantModel? _selectedRest;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final pos = await MapsService.getCurrentLocation();
    setState(() { _userPosition = pos; _loadingLocation = false; });
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = context.watch<AppState>().filteredRestaurants;

    final markers = <Marker>{};
    for (final r in restaurants) {
      // Use known coordinates or fallback to center
      final coords = MapsService.restaurantCoords[r.name]
        ?? LatLng(r.latitude, r.longitude);
      markers.add(Marker(
        markerId: MarkerId(r.firestoreId.isEmpty ? r.name : r.firestoreId),
        position: coords,
        infoWindow: InfoWindow(
          title: r.name,
          snippet: 'Rs ${r.bagPrice} · ${r.bagsLeft} bags baki',
        ),
        onTap: () => setState(() => _selectedRest = r),
      ));
    }

    if (_userPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userPosition!.latitude, _userPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Aap yahan hain'),
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Map 🗺️'), automaticallyImplyLeading: false),
      body: Stack(children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _userPosition != null
              ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
              : MapsService.rwpIsbCenter,
            zoom: 13,
          ),
          markers: markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (c) => _mapCtrl = c,
          onTap: (_) => setState(() => _selectedRest = null),
        ),

        // Loading overlay
        if (_loadingLocation)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator(
              color: AppColors.green))),

        // My location button
        Positioned(right: 16, bottom: _selectedRest != null ? 200 : 24,
          child: FloatingActionButton.small(
            backgroundColor: Colors.white,
            child: const Icon(Icons.my_location, color: AppColors.green),
            onPressed: () {
              if (_userPosition != null) {
                _mapCtrl?.animateCamera(CameraUpdate.newLatLng(
                  LatLng(_userPosition!.latitude, _userPosition!.longitude)));
              } else { _getLocation(); }
            },
          )),

        // Restaurant count chip
        Positioned(top: 16, left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1),
                blurRadius: 8, offset: const Offset(0,2))]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.restaurant, size: 14, color: AppColors.greenMid),
              const SizedBox(width: 6),
              Text('${restaurants.length} restaurants',
                style: GoogleFonts.sora(fontSize: 12,
                  fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ]),
          )),

        // Selected restaurant card
        if (_selectedRest != null)
          Positioned(bottom: 0, left: 0, right: 0,
            child: _buildRestCard(_selectedRest!)),
      ]),
    );
  }

  Widget _buildRestCard(RestaurantModel r) => Container(
    margin: const EdgeInsets.all(16),
    decoration: shadowDecoration(radius: 20),
    padding: const EdgeInsets.all(16),
    child: Row(children: [
      Container(width: 60, height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: r.gradientColors),
          borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(r.emoji,
          style: const TextStyle(fontSize: 28)))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: GoogleFonts.sora(fontSize: 14,
            fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          Text(r.location, style: GoogleFonts.sora(fontSize: 11,
            color: AppColors.gray), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Text('Rs ${r.bagPrice}', style: GoogleFonts.sora(fontSize: 16,
              fontWeight: FontWeight.w800, color: AppColors.greenMid)),
            const SizedBox(width: 8),
            Text('${r.bagsLeft} bags baki', style: GoogleFonts.sora(
              fontSize: 10, color: AppColors.gray)),
          ]),
        ])),
      ElevatedButton(
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(restaurant: r))),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Dekho'),
      ),
    ]),
  );
}
