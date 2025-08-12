import 'package:erguo/view/worker/worker_payment_request_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controller/worker_location_provider.dart';
import '../../controller/worker_route_provider.dart';

class WorkerLiveTrackingScreen extends ConsumerStatefulWidget {
  final String userid;
  final double userLat;
  final double userLng;
  final int bookid;

  const WorkerLiveTrackingScreen({
    super.key,
    required this.userid,
    required this.userLat,
    required this.userLng,
    required this.bookid,
  });

  @override
  ConsumerState<WorkerLiveTrackingScreen> createState() =>
      _WorkerLiveTrackingScreenState();
}

class _WorkerLiveTrackingScreenState
    extends ConsumerState<WorkerLiveTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  void _fetchData() {
    final workerPos = ref.read(workerLocationProvider);
    if (workerPos != null) {
      ref
          .read(workerRouteProvider.notifier)
          .fetchRoute(
            workerPosition: workerPos,
            userPosition: LatLng(widget.userLat, widget.userLng),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workerPos = ref.watch(workerLocationProvider);
    final routeData = ref.watch(workerRouteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reach User')),
      body: workerPos == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: workerPos,
                    zoom: 14.0,
                  ),
                  rotateGesturesEnabled: true,
                  buildingsEnabled: true,
                  polylines: routeData.polylines,
                  myLocationEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("user"),
                      position: LatLng(widget.userLat, widget.userLng),
                      infoWindow: InfoWindow(
                        title: "User",
                        snippet: routeData.userAddress,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId("worker"),
                      position: workerPos,
                      infoWindow: InfoWindow(
                        title: "You",
                        snippet: routeData.workerAddress,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                  },
                ),
                // Positioned(
                //   top: 10,
                //   left: 10,
                //   right: 10,
                //   child: Card(
                //     color: Colors.white,
                //     child: Padding(
                //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //       child: Text(
                //         "Distance: ${routeData.distance} | Time: ${routeData.duration}",
                //         style: const TextStyle(fontSize: 16),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkerSendPaymentScreen(
                  userid: widget.userid,
                  bookid: widget.bookid,
                ),
              ),
            );
          },
          icon: const Icon(Icons.navigation),
          label: const Text("Reach"),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapSample extends StatefulWidget {
//   const MapSample({super.key});

//   @override
//   State<MapSample> createState() => _MapSampleState();
// }

// class _MapSampleState extends State<MapSample> {
//   final Completer<GoogleMapController> _controller =
//       Completer<GoogleMapController>();

//   final Set<Marker> _markers = {};

//   // Example positions
//   static const LatLng _userPosition = LatLng(
//     37.42796133580664,
//     -122.085749655962,
//   );
//   static const LatLng _workerPosition = LatLng(
//     37.43296265331129,
//     -122.08832357078792,
//   );

//   static const CameraPosition _initialCameraPosition = CameraPosition(
//     target: _userPosition,
//     zoom: 14.5,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _setInitialMarkers();
//   }

//   void _setInitialMarkers() {
//     _markers.clear();
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('user'),
//         position: _userPosition,
//         infoWindow: const InfoWindow(title: 'User Location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//       ),
//     );
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('worker'),
//         position: _workerPosition,
//         infoWindow: const InfoWindow(title: 'Worker Location'),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   Future<void> _moveToWorker() async {
//     final controller = await _controller.future;
//     await controller.animateCamera(
//       CameraUpdate.newLatLngZoom(_workerPosition, 16),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         mapType: MapType.normal,
//         initialCameraPosition: _initialCameraPosition,
//         markers: _markers,
//         onMapCreated: (controller) {
//           _controller.complete(controller);
//         },
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _moveToWorker,
//         label: const Text('Go to Worker'),
//         icon: const Icon(Icons.navigation),
//       ),
//     );
//   }
// }
