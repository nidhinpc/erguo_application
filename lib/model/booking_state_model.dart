import 'dart:io';

class BookingState {
  final String description;
  final String address;
  final String? location;
  final DateTime? scheduledTime;
  final File? imageFile;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  BookingState({
    this.description = '',
    this.address = '',
    this.location,
    this.scheduledTime,
    this.imageFile,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  BookingState copyWith({
    String? description,
    String? address,
    String? location,
    DateTime? scheduledTime,
    File? imageFile,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) {
    return BookingState(
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
