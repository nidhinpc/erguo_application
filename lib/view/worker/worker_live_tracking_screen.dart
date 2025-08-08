import 'package:erguo/view/worker/worker_payment_request_screen.dart';
import 'package:erguo/view/worker/working_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/worker_location_provider.dart';

class WorkerLiveTrackingScreen extends ConsumerStatefulWidget {
  final String userid;
  final double userLat;
  final double userLng;

  const WorkerLiveTrackingScreen({
    super.key,
    required this.userid,
    required this.userLat,
    required this.userLng,
  });

  @override
  ConsumerState<WorkerLiveTrackingScreen> createState() =>
      _WorkerLiveTrackingScreenState();
}

class _WorkerLiveTrackingScreenState
    extends ConsumerState<WorkerLiveTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final workerPosition = ref.watch(workerLocationProvider);

    if (workerPosition != null && _mapController != null) {
      // Adjust camera to fit both markers
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          (workerPosition.latitude < widget.userLat)
              ? workerPosition.latitude
              : widget.userLat,
          (workerPosition.longitude < widget.userLng)
              ? workerPosition.longitude
              : widget.userLng,
        ),
        northeast: LatLng(
          (workerPosition.latitude > widget.userLat)
              ? workerPosition.latitude
              : widget.userLat,
          (workerPosition.longitude > widget.userLng)
              ? workerPosition.longitude
              : widget.userLng,
        ),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reach User')),
      body: workerPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: workerPosition,
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
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                ),
                Marker(
                  markerId: const MarkerId("worker"),
                  position: workerPosition,
                  infoWindow: const InfoWindow(title: "Your Location"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Marked as reached")));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WorkerSendPaymentScreen(userid: widget.userid),
            ),
          );
        },
        icon: const Icon(Icons.navigation),
        label: const Text("Reach"),
      ),
    );
  }
}
