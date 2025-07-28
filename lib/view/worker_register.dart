import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class WorkerRegister extends StatefulWidget {
  const WorkerRegister({super.key});

  @override
  State<WorkerRegister> createState() => _WorkerRegisterState();
}

class _WorkerRegisterState extends State<WorkerRegister> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final experienceController = TextEditingController();
  String? location = "Unknown";
  // // File? selectedImage;
  // final picker = ImagePicker();
  // Future<void> pickImage() async {
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //   if (image != null) {
  //     setState(() {
  //       selectedImage = File(image.path);
  //     });
  //   }
  // }

  Future<void> registerWorker() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        experienceController.text.isEmpty ||
        // selectedImage == null ||
        location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and pick an image")),
      );
      return;
    }

    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child(
        'worker_images/$fileName.jpg',
      );
      // await ref.putFile(selectedImage!);
      // String imageUrl = await ref.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('workers').add({
        'name': nameController.text.trim(),
        'phonenumber': phoneController.text.trim(),
        'experience': experienceController.text.trim(),
        'image': "null",
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Worker registered successfully")));

      // Clear fields
      nameController.clear();
      phoneController.clear();
      experienceController.clear();
      setState(() {
        // selectedImage = null;
        location = "Unknown";
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error during registration")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.secondaryColor,
      appBar: AppBar(
        title: Text(
          'Register as Worker',
          style: TextStyle(
            color: ColorConstants.primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Enter your details',
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextFieldWidget(name: 'Full Name', controller: nameController),
          TextFieldWidget(name: 'Phone Number', controller: phoneController),
          TextFieldWidget(
            name: 'Year of Experience',
            controller: experienceController,
          ),
          // adding image picker in a cirle
          // Padding(
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 16.0,
          //     vertical: 8.0,
          //   ),
          //   child: InkWell(
          //     onTap: pickImage,
          //     child: CircleAvatar(
          //       radius: 50,
          //       backgroundColor: ColorConstants.primaryColor,
          //       backgroundImage: selectedImage != null
          //           ? FileImage(selectedImage!)
          //           : null,
          //       child: selectedImage == null
          //           ? Icon(
          //               Icons.camera_alt,
          //               size: 50,
          //               color: ColorConstants.secondaryColor,
          //             )
          //           : null,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Tap to select a photo"),
          ),
          // adding Location verification button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              width: 300,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    ColorConstants.primaryColor,
                  ),
                ),
                onPressed: () {
                  // Handle location verification logic
                  setState(() {
                    location = "kochi, kerala";
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: ColorConstants.secondaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Verify Location',
                      style: TextStyle(
                        color: ColorConstants.secondaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    ColorConstants.primaryColor,
                  ),
                ),
                onPressed: () {
                  // Handle registration logic
                  registerWorker();
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: ColorConstants.secondaryColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String? name;
  final TextEditingController? controller;
  const TextFieldWidget({this.name, super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: name,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          enabled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
        ),
      ),
    );
  }
}
