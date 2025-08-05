
import 'dart:io';

class BookingState {
  final String description;
  final String address;
  final String? imageUrl;
  final File? imageFile;
  final String? location;
  final DateTime? scheduledTime;

  BookingState({
    this.description = '',
    this.address = '',
    this.imageUrl,
    this.imageFile,
    this.location,
    this.scheduledTime,
  });

  BookingState copyWith({
    String? description,
    String? address,
    String? imageUrl,
    File? imageFile,
    String? location,
    DateTime? scheduledTime,
  }) {
    return BookingState(
      description: description ?? this.description,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      location: location ?? this.location,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}
