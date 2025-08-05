import 'dart:io';

import 'package:erguo/model/booking_state_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingController extends StateNotifier<BookingState> {
  BookingController() : super(BookingState());

  void setDescription(String value) => state = state.copyWith(description: value);
  void setAddress(String value) => state = state.copyWith(address: value);
  void setLocation(String value) => state = state.copyWith(location: value);
  void setScheduledTime(DateTime value) => state = state.copyWith(scheduledTime: value);
  void setImage(File file, String url) =>
      state = state.copyWith(imageFile: file, imageUrl: url);
  void clear() => state = BookingState();
}

final bookingProvider = StateNotifierProvider<BookingController, BookingState>((ref) {
  return BookingController();
});