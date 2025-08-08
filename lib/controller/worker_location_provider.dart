import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final workerLocationProvider =
    StateNotifierProvider<WorkerLocationController, LatLng?>(
      (ref) => WorkerLocationController(),
    );

class WorkerLocationController extends StateNotifier<LatLng?> {
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  WorkerLocationController() : super(null) {
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get initial location
    final currentLocation = await _location.getLocation();
    state = LatLng(currentLocation.latitude!, currentLocation.longitude!);

    // Listen for updates
    _locationSubscription = _location.onLocationChanged.listen((
      LocationData newLocation,
    ) {
      state = LatLng(newLocation.latitude!, newLocation.longitude!);
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
