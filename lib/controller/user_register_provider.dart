import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final registrationProvider =
    StateNotifierProvider<UserRegistrationController, UserRegistrationState>(
      (ref) => UserRegistrationController(),
    );

class UserRegistrationState {
  final bool isLoading;
  final File? imageFile;
  final String? imageUrl;

  UserRegistrationState({
    this.isLoading = false,
    this.imageFile,
    this.imageUrl,
  });

  UserRegistrationState copyWith({
    bool? isLoading,
    File? imageFile,
    String? imageUrl,
  }) {
    return UserRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      imageFile: imageFile ?? this.imageFile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class UserRegistrationController extends StateNotifier<UserRegistrationState> {
  UserRegistrationController() : super(UserRegistrationState());

  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final File image = File(pickedFile.path);
      state = state.copyWith(imageFile: image);

      final supabase = Supabase.instance.client;
      final bucket = supabase.storage.from('workers-image');
      final fileName = 'worker_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await bucket.upload(
        fileName,
        image,
        fileOptions: const FileOptions(upsert: true),
      );
      final url = bucket.getPublicUrl(fileName);

      state = state.copyWith(imageUrl: url);
    } catch (e) {
      print("Image upload error: $e");
    }
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void reset() {
    state = UserRegistrationState(
      isLoading: false,
      imageFile: null,
      imageUrl: null,
    );
  }
}
