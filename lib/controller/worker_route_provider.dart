// lib/controller/worker_route_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class WorkerRouteState {
  final String distance;
  final String duration;
  final String userAddress;
  final String workerAddress;
  final Set<Polyline> polylines;

  WorkerRouteState({
    this.distance = "",
    this.duration = "",
    this.userAddress = "",
    this.workerAddress = "",
    this.polylines = const {},
  });

  WorkerRouteState copyWith({
    String? distance,
    String? duration,
    String? userAddress,
    String? workerAddress,
    Set<Polyline>? polylines,
  }) {
    return WorkerRouteState(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      userAddress: userAddress ?? this.userAddress,
      workerAddress: workerAddress ?? this.workerAddress,
      polylines: polylines ?? this.polylines,
    );
  }
}

class WorkerRouteNotifier extends StateNotifier<WorkerRouteState> {
  WorkerRouteNotifier() : super(WorkerRouteState());

  final String apiKey = "YOUR_GOOGLE_MAPS_API_KEY"; // Keep it secure

  Future<void> fetchRoute({
    required LatLng workerPosition,
    required LatLng userPosition,
  }) async {
    // Fetch Directions
    final directionsUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${workerPosition.latitude},${workerPosition.longitude}&destination=${userPosition.latitude},${userPosition.longitude}&key=$apiKey";

    final directionsResponse = await http.get(Uri.parse(directionsUrl));
    final directionsData = json.decode(directionsResponse.body);

    String distance = "";
    String duration = "";
    Set<Polyline> polylines = {};

    if (directionsData["status"] == "OK") {
      final route = directionsData["routes"][0];
      final leg = route["legs"][0];

      distance = leg["distance"]["text"];
      duration = leg["duration"]["text"];
      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          points: _decodePolyline(route["overview_polyline"]["points"]),
          color: Colors.blue,
          width: 5,
        ),
      };
    }

    // Reverse Geocoding for addresses
    final userGeoUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${userPosition.latitude},${userPosition.longitude}&key=$apiKey";
    final workerGeoUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${workerPosition.latitude},${workerPosition.longitude}&key=$apiKey";

    final userGeoRes = await http.get(Uri.parse(userGeoUrl));
    final workerGeoRes = await http.get(Uri.parse(workerGeoUrl));

    String userAddress = json.decode(
      userGeoRes.body,
    )["results"][0]["formatted_address"];
    String workerAddress = json.decode(
      workerGeoRes.body,
    )["results"][0]["formatted_address"];

    state = state.copyWith(
      distance: distance,
      duration: duration,
      userAddress: userAddress,
      workerAddress: workerAddress,
      polylines: polylines,
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}

final workerRouteProvider =
    StateNotifierProvider<WorkerRouteNotifier, WorkerRouteState>(
      (ref) => WorkerRouteNotifier(),
    );
