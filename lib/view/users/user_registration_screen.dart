import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:erguo/controller/user_register_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserRegistrationScreen extends ConsumerStatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  ConsumerState<UserRegistrationScreen> createState() =>
      _UserRegistrationScreenState();
}

class _UserRegistrationScreenState
    extends ConsumerState<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? userType;
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Additional fields for worker details
  final experienceController = TextEditingController();
  final locationController = TextEditingController();

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Location permission denied")));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks[0];
      String address =
          '${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

      setState(() {
        locationController.text = address;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Location fetched")));
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to get location")));
    }
  }

  Future<void> registerUser() async {
    final provider = ref.read(registrationProvider.notifier);
    provider.setLoading(true);

    if (!_formKey.currentState!.validate()) {
      provider.setLoading(false);
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = userCredential.user!.uid;
      final role = userType ?? 'user';
      final imageUrl = ref.read(registrationProvider).imageUrl;

      final userData = {
        'uid': uid,
        'fullname': _fullnameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _genderController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (role == 'worker') {
        userData['experience'] = experienceController.text.trim();
        userData['location'] = locationController.text.trim();
        userData['photo'] = imageUrl ?? '';
      }

      await Future.wait([
        FirebaseFirestore.instance.collection('users').doc(uid).set(userData),
        FirebaseDatabase.instance.ref().child('users').child(uid).set(userData),
      ]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully")),
      );

      // Simulate 3 seconds loading
      await Future.delayed(Duration(seconds: 3));

      // Clear all fields
      _formKey.currentState!.reset();
      _fullnameController.clear();
      _emailController.clear();
      _genderController.clear();
      _phoneController.clear();
      _passwordController.clear();
      experienceController.clear();
      locationController.clear();

      setState(() {
        userType = null;
      });
      // Ensure loading is set to false
      provider.setLoading(false);
      provider.reset(); // reset state (including loading = false)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      provider.setLoading(false);
    }
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    experienceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);
    final provider = ref.read(registrationProvider.notifier);

    return Scaffold(
      backgroundColor: ColorConstants.successColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Register as User",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.secondaryColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: ColorConstants.secondaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        TextFormField(
                          controller: _fullnameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter full name' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter email' : null,
                        ),
                        SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _genderController.text.isEmpty
                              ? null
                              : _genderController.text,
                          items: ['male', 'female']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            _genderController.text = value!;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Select gender'
                              : null,
                        ),

                        SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter phone number' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value!.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          dropdownColor: ColorConstants.secondaryColor,
                          value: userType,
                          decoration: InputDecoration(
                            labelText: 'Select Role',
                            border: OutlineInputBorder(),
                            disabledBorder: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                          ),
                          items: ['user', 'worker']
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => userType = v!),
                        ),

                        // Additional fields for Worker
                        if (userType == 'worker') ...[
                          SizedBox(height: 12),
                          TextFormField(
                            controller: experienceController,
                            decoration: InputDecoration(
                              labelText: 'Experience',
                              border: OutlineInputBorder(),
                              disabledBorder: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your experience';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: locationController,
                            readOnly: true,
                            onTap: getCurrentLocation,
                            decoration: InputDecoration(
                              labelText: 'Tap to fetch Location',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please fetch your location';
                              }
                              return null;
                            },
                          ),

                          // Photo upload field (this can be more complex with file pickers)
                          SizedBox(height: 12),
                          Column(
                            children: [
                              InkWell(
                                onTap: provider.pickAndUploadImage,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: ColorConstants.primaryColor,
                                  backgroundImage: state.imageFile != null
                                      ? FileImage(state.imageFile!)
                                      : null,
                                  child: state.imageFile == null
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
                          ),
                        ],

                        SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: state.isLoading ? null : registerUser,
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.secondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: ColorConstants.accentColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
