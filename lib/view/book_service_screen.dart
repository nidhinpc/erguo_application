import 'package:erguo/constants/color_constants.dart';
import 'package:flutter/material.dart';

class BookServiceScreen extends StatelessWidget {
  const BookServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String serviceName = ModalRoute.of(context)?.settings.arguments as String? ?? 'Service';

    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Request For $serviceName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
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
              decoration: const InputDecoration(labelText: 'Describe your issue',
                border: OutlineInputBorder(),
                disabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),                
                ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address',border: OutlineInputBorder(),
                disabledBorder: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(),),
            ),
            const SizedBox(height: 12),
            // add image picker in a container
            Container(
              
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstants.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.primaryColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, size: 30, color: ColorConstants.primaryColor),
                  const SizedBox(width: 10),
                  Text('Select a photo', style: TextStyle(color: ColorConstants.primaryColor, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // add location selector in a container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstants.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.primaryColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 30, color: ColorConstants.primaryColor),
                  const SizedBox(width: 10),
                  Text('Select your location', style: TextStyle(color: ColorConstants.primaryColor, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // add  schedule timer in a container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorConstants.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.primaryColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule, size: 30, color: ColorConstants.primaryColor),
                  const SizedBox(width: 10),
                  Text('Select a time', style: TextStyle(color: ColorConstants.primaryColor, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(ColorConstants.primaryColor),
                ),
                icon: const Icon(Icons.arrow_forward, size: 20, color: ColorConstants.secondaryColor),
                label: const Text('Submit Booking',
                    style: TextStyle(color: ColorConstants.secondaryColor, fontSize: 18)),
                onPressed: () {
                  // You can send this data to Firebase or backend here
                  String name = nameController.text.trim();
                  String address = addressController.text.trim();
                  String phone = phoneController.text.trim();

                  if (name.isEmpty || address.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$serviceName service booked successfully!')),
                    );
                    Navigator.pop(context);
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
