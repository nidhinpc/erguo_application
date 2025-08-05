import 'package:erguo/view/worker/working_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class WorkerLiveTrackingScreen extends StatefulWidget {
  final double userLat;
  final double userLng;

  const WorkerLiveTrackingScreen({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<WorkerLiveTrackingScreen> createState() => _WorkerLiveTrackingScreenState();
}

class _WorkerLiveTrackingScreenState extends State<WorkerLiveTrackingScreen> {
  GoogleMapController? _mapController;
  final Location location = Location();
  LatLng? workerPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocationTracking();
  }

  void _initializeLocationTracking() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled && !await location.requestService()) return;

    final permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) return;

    final currentLocation = await location.getLocation();
    setState(() {
      workerPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    });

    location.onLocationChanged.listen((LocationData currentLocation) {
      final updatedPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      setState(() {
        workerPosition = updatedPosition;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(updatedPosition),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reach User')),
      body: workerPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: workerPosition!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: {
                Marker(
                  markerId: const MarkerId("user"),
                  position: LatLng(widget.userLat, widget.userLng),
                  infoWindow: const InfoWindow(title: "User Location"),
                ),
                Marker(
                  markerId: const MarkerId("worker"),
                  position: workerPosition!,
                  infoWindow: const InfoWindow(title: "Your Location"),
                )
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // You can mark "Reached" in Firestore here
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Marked as reached")),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkingScreen()),
          );
        },
        icon: const Icon(Icons.navigation),
        label: const Text("Reach"),
      ),
    );
  }
}
