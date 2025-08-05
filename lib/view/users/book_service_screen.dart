import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:erguo/controller/booking_service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookServiceScreen extends ConsumerWidget {
  const BookServiceScreen({super.key});

  Future<void> pickAndUploadImage(WidgetRef ref, BuildContext context) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final File file = File(pickedFile.path);
      final supabase = Supabase.instance.client;
      final bucket = supabase.storage.from('booking-img');
      final fileName = 'booking_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await bucket.upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final imageUrl = bucket.getPublicUrl(fileName);
      ref.read(bookingProvider.notifier).setImage(file, imageUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      print("Image upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  Future<void> getCurrentLocation(WidgetRef ref, BuildContext context) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return;
        }
      }

      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      ref.read(bookingProvider.notifier).setLocation(
            "${place.locality}, ${place.administrativeArea}",
          );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location selected: ${place.locality}")),
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> pickDateTime(BuildContext context, WidgetRef ref) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        ref.read(bookingProvider.notifier).setScheduledTime(fullDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingProvider);
    final String serviceName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Service';

    return Scaffold(
      backgroundColor: ColorConstants.secondaryColor,
      appBar: AppBar(
        title: Text('Request For $serviceName',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describe your issue',
                border: OutlineInputBorder(),
              ),
              onChanged: ref.read(bookingProvider.notifier).setDescription,
            ),
            const SizedBox(height: 12),
            TextField(

              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(

                ),

              ),
              onChanged: ref.read(bookingProvider.notifier).setAddress,
            ),
            const SizedBox(height: 12),
             GestureDetector(
              onTap: () async => await pickAndUploadImage(ref, context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConstants.primaryColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt,
                        size: 30, color: ColorConstants.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                     state.imageFile != null ? 'Image selected' : 'Select a photo',
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (state.imageFile != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Image.file(state.imageFile!, height: 150),
              )
            ],
            // ElevatedButton(
            //   onPressed: () => pickAndUploadImage(ref, context),
            //   child: const Text('Pick Image'),
            // ),
            // if (state.imageFile != null)
            //   Image.file(state.imageFile!, height: 100),
            const SizedBox(height: 12),
              GestureDetector(
              onTap: () => getCurrentLocation(ref, context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConstants.primaryColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on,
                        size: 30, color: ColorConstants.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      state.location ?? "Select a location",
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () => getCurrentLocation(ref, context),
            //   child: const Text('Get Location'),
            // ),
            // if (state.location != null) Text("Location: ${state.location}"),
            const SizedBox(height: 12),
              GestureDetector(
              onTap: () =>  pickDateTime(context, ref),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorConstants.primaryColor, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule,
                        size: 30, color: ColorConstants.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      state.scheduledTime != null
                          ? "${state.scheduledTime!.toLocal()}"
                          : "Select a time",
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                   ),
                   
                  ],
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: () => pickDateTime(context, ref),
            //   child: const Text('Pick Schedule'),
            // ),
            // if (state.scheduledTime != null)
            //   Text("Time: ${state.scheduledTime!.toLocal()}"),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                 style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(ColorConstants.primaryColor),
                ),
                onPressed: () async {
                  if (state.description.isEmpty ||
                      state.address.isEmpty ||
                      state.imageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all fields and upload image')),
                    );
                    return;
                  }
              
                  final user = FirebaseAuth.instance.currentUser;
                  await FirebaseFirestore.instance.collection('booking').add({
                    "description": state.description,
                    "address": state.address,
                    "photo": state.imageUrl,
                    "location": state.location ?? "Not selected",
                    "servicename": serviceName,
                    "sheduledtime": state.scheduledTime?.toIso8601String() ?? '',
                    "userId": user?.uid,
                  });
              
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking submitted successfully!')),
                  );
                  ref.read(bookingProvider.notifier).clear();
                  Navigator.pop(context);
                },
                child: const Text('Submit Booking',
                    style: TextStyle(
                      color: ColorConstants.secondaryColor,
                      fontSize: 18,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
