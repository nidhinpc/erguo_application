import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/color_constants.dart';

class WorkerRegister extends StatefulWidget {
  const WorkerRegister({super.key});

  @override
  State<WorkerRegister> createState() => _WorkerRegisterState();
}

class _WorkerRegisterState extends State<WorkerRegister> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final experienceController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();


  File? selectedImage;
  String? uploadedImageUrl;
  String? location = "Unknown";
  final picker = ImagePicker();
  bool obscurePassword = true;

  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      setState(() {
        selectedImage = File(pickedFile.path);
      });

      final supabase = Supabase.instance.client;
      final bucket = supabase.storage.from('workers-image');
      final fileName = 'worker_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await bucket.upload(
        fileName,
        selectedImage!,
        fileOptions: const FileOptions(upsert: true),
      );

      uploadedImageUrl = bucket.getPublicUrl(fileName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      print("Image upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image")),
      );
    }
  }

  Future<void> registerWorker() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        experienceController.text.isEmpty ||
        passwordController.text.isEmpty ||
        uploadedImageUrl == null ||
        location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and upload an image")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('workers').add({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phonenumber': phoneController.text.trim(),
        'experience': experienceController.text.trim(),
        'password': passwordController.text.trim(),
        'image': uploadedImageUrl,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Worker registered successfully")),
      );

      // Clear fields
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      experienceController.clear();
      passwordController.clear();
      setState(() {
        selectedImage = null;
        uploadedImageUrl = null;
        location = "Unknown";
        obscurePassword = true;
      });
    } catch (e) {
      print("Firestore error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during registration")),
      );
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: ColorConstants.primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            TextFieldWidget(name: 'Full Name', controller: nameController),
            TextFieldWidget(name: 'Email', controller: emailController),
            TextFieldWidget(name: 'Phone Number', controller: phoneController),
            TextFieldWidget(
              name: 'Years of Experience',
              controller: experienceController,
            ),
            _buildPasswordField(),
            const SizedBox(height: 16),
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildLocationButton(),
            const SizedBox(height: 16),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Enter your details',
        style: TextStyle(
          fontSize: 16,
          color: ColorConstants.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: passwordController,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        InkWell(
          onTap: pickAndUploadImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: ColorConstants.primaryColor,
            backgroundImage: selectedImage != null
                ? FileImage(selectedImage!)
                : null,
            child: selectedImage == null
                ? Icon(
                    Icons.camera_alt,
                    size: 50,
                    color: ColorConstants.secondaryColor,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text("Tap to select a photo"),
      ],
    );
  }

  Widget _buildLocationButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            location = "Kochi, Kerala"; // Replace with actual location later
          });
        },
        icon: Icon(Icons.location_on, color: ColorConstants.secondaryColor),
        label: Text(
          'Verify Location',
          style: TextStyle(
            color: ColorConstants.secondaryColor,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: registerWorker,
        child: Text(
          'Register',
          style: TextStyle(
            color: ColorConstants.secondaryColor,
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
        ),
      ),
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  final String name;
  final TextEditingController controller;

  const TextFieldWidget({
    super.key,
    required this.name,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType:
            name.toLowerCase().contains("phone") ? TextInputType.phone : null,
        decoration: InputDecoration(
          labelText: name,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
