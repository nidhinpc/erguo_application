import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erguo/constants/color_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? userType; // Default is 'user'
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // Additional fields for worker details
  final experienceController = TextEditingController();
  final locationController = TextEditingController();
  String? selectedPhoto;

  bool _isLoading = false;

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) return ;

    setState(() => _isLoading = true);

    try {
      // Create Firebase user
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store extra details in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'fullname': _fullnameController.text.trim(),
        'email': _emailController.text.trim(),
        'gender': _genderController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': 'user', // default role
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User registered successfully")),
      );

      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                          decoration: const InputDecoration(labelText: 'Full Name',  border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter full name' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email',
                            border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter email' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _genderController,
                          decoration: const InputDecoration(labelText: 'Gender',
                            border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                          validator: (value) =>
                              value!.isEmpty ? 'Enter gender' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone',
                            border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                          keyboardType: TextInputType.phone,
                          validator: (value) =>
                              value!.isEmpty ? 'Enter phone number' : null,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password',
                            border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                          obscureText: true,
                          validator: (value) =>
                              value!.length < 6 ? 'Minimum 6 characters' : null,
                        ),
                        const SizedBox(height: 12),

                           DropdownButtonFormField<String>(

                            dropdownColor: ColorConstants.secondaryColor,
                value: userType,
                decoration: InputDecoration(labelText: 'Select Role', border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),
                                    ),
                onChanged: (String? newValue) {
                  setState(() {
                    userType = newValue;
                  });
                },
                items: ['user', 'worker']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value == 'user' ? 'User' : 'Worker'),
                      ),
                    )
                    .toList(),
              ),

                    // Additional fields for Worker
              if (userType == 'worker') ...[
                SizedBox(height: 12),
                TextFormField(
                  controller: experienceController,
                  decoration: InputDecoration(labelText: 'Experience', border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
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
                  decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),

                // Photo upload field (this can be more complex with file pickers)
                SizedBox(height: 12),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Upload Photo URL',border: OutlineInputBorder(),
                                    disabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                    enabledBorder: OutlineInputBorder(),),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a photo URL';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    selectedPhoto = value;
                  },
                ),
              ],

              SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _isLoading ? null : registerUser,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text("Register",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstants.secondaryColor,
                                  )),
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








// class RegistrationScreen extends StatefulWidget {
//   @override
//   _RegistrationScreenState createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   // Define the dropdown value
//   String? userType; // Default is 'user'
//   final _formKey = GlobalKey<FormState>();

//   // Text controllers for basic user details
//   final nameController = TextEditingController();
//   final phoneController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();

//   // Additional fields for worker details
//   final experienceController = TextEditingController();
//   final locationController = TextEditingController();
//   String? selectedPhoto;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Registration Form')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               // Basic info fields
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your name';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: phoneController,
//                 decoration: InputDecoration(labelText: 'Phone Number'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your phone number';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter your password';
//                   }
//                   return null;
//                 },
//               ),

//               // Dropdown for User or Worker
//               DropdownButtonFormField<String>(
//                 value: userType,
//                 decoration: InputDecoration(labelText: 'Select Role'),
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     userType = newValue;
//                   });
//                 },
//                 items: ['user', 'worker']
//                     .map<DropdownMenuItem<String>>(
//                       (String value) => DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value == 'user' ? 'User' : 'Worker'),
//                       ),
//                     )
//                     .toList(),
//               ),

//               // Additional fields for Worker
//               if (userType == 'worker') ...[
//                 TextFormField(
//                   controller: experienceController,
//                   decoration: InputDecoration(labelText: 'Experience'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your experience';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: locationController,
//                   decoration: InputDecoration(labelText: 'Location'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your location';
//                     }
//                     return null;
//                   },
//                 ),

//                 // Photo upload field (this can be more complex with file pickers)
//                 TextFormField(
//                   decoration: InputDecoration(labelText: 'Upload Photo URL'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please provide a photo URL';
//                     }
//                     return null;
//                   },
//                   onChanged: (value) {
//                     selectedPhoto = value;
//                   },
//                 ),
//               ],

//               // Submit Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: ElevatedButton(
//                   onPressed: () {
//                     if (_formKey.currentState?.validate() ?? false) {
//                       // Process data
//                       // For example, you can send it to an API or save it locally
//                       print("Name: ${nameController.text}");
//                       print("Phone: ${phoneController.text}");
//                       print("Email: ${emailController.text}");
//                       print("Role: $userType");

//                       if (userType == 'worker') {
//                         print("Experience: ${experienceController.text}");
//                         print("Location: ${locationController.text}");
//                         print("Photo: $selectedPhoto");
//                       }
//                     }
//                   },
//                   child: Text('Register'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }