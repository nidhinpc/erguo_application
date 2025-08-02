import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? selectedImage;
  String? userLocation;
  DateTime? selectedDateTime;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String?> uploadToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final fileName = 'booking_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = 'booking/$fileName';

    final response =
        await supabase.storage.from('booking-image').upload(filePath, file);

    if (response.isNotEmpty) {
      return supabase.storage.from('booking-image').getPublicUrl(filePath);
    }
    return null;
  }

  Future<void> getCurrentLocation() async {
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

      setState(() {
        userLocation = "${place.locality}, ${place.administrativeArea}";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location selected: $userLocation")),
      );
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> pickDateTime(BuildContext context) async {
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
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String serviceName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Service';

    return Scaffold(
      appBar: AppBar(
        title: Text('Request For $serviceName',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fill in the details to book $serviceName service',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            TextField(
              maxLines: 5,
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Describe your issue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () async => await pickImage(),
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
                      selectedImage != null ? 'Image selected' : 'Select a photo',
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            if (selectedImage != null) ...[
              const SizedBox(height: 10),
              Center(
                child: Image.file(selectedImage!, height: 150),
              )
            ],

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => getCurrentLocation(),
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
                      userLocation ?? 'Select your location',
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => pickDateTime(context),
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
                      selectedDateTime != null
                          ? '${selectedDateTime!.toLocal()}'.split('.')[0]
                          : 'Select a time',
                      style: const TextStyle(
                          color: ColorConstants.primaryColor, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all<Color>(ColorConstants.primaryColor),
                ),
                icon: const Icon(Icons.arrow_forward,
                    size: 20, color: ColorConstants.secondaryColor),
                label: const Text('Submit Booking',
                    style: TextStyle(
                        color: ColorConstants.secondaryColor, fontSize: 18)),
                onPressed: () async {
                  String description = nameController.text.trim();
                  String address = addressController.text.trim();
                  String location = userLocation ?? "Not selected";
                  String scheduleTime =
                      selectedDateTime?.toIso8601String() ?? "";

                  if (description.isEmpty ||
                      address.isEmpty ||
                      selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Please fill all fields and pick an image')),
                    );
                    return;
                  }

                  try {
                    final imageUrl = await uploadToSupabase(selectedImage!);
                    if (imageUrl == null) throw Exception("Image upload failed");

                    await FirebaseFirestore.instance.collection('booking').add({
                      "description": description,
                      "address": address,
                      "photo": imageUrl,
                      "location": location,
                      "servicename": serviceName,
                      "sheduledtime": scheduleTime,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking submitted successfully!')),
                    );
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
