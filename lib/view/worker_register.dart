import 'package:erguo/constants/color_constants.dart';
import 'package:flutter/material.dart';

class WorkerRegister extends StatelessWidget {
  const WorkerRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.secondaryColor,
      appBar: AppBar(
        
        title: Text('Register as Worker',style: TextStyle(color: ColorConstants.primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Enter your details',
              style: TextStyle(fontSize: 16, color: ColorConstants.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextFieldWidget(
            name: 'Full Name',
          ),
          TextFieldWidget(
            name: 'Phone Number',
          ),
          TextFieldWidget(
            name: 'Year of Experience',
          ),
          // adding image picker in a cirle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: ColorConstants.primaryColor,
              child: Icon(Icons.camera_alt, size: 50, color: ColorConstants.secondaryColor),
            ),
          ),
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
                  backgroundColor: WidgetStateProperty.all<Color>(ColorConstants.primaryColor),
                ),
                onPressed: () {
                  // Handle location verification logic
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: ColorConstants.secondaryColor),
                    SizedBox(width: 8),
                    Text('Verify Location', style: TextStyle(color: ColorConstants.secondaryColor, fontSize: 18),),
                  ],
                )
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
                  backgroundColor: WidgetStateProperty.all<Color>(ColorConstants.primaryColor),
                ),
                onPressed: () {
                  // Handle registration logic
                },
                child: Text('Register', style: TextStyle(color: ColorConstants.secondaryColor, fontSize: 18 ),)
              ),
            ),
          ),
        ],
      )
    );
  }
}

class TextFieldWidget extends StatelessWidget {
  String? name;
   TextFieldWidget({
    this.name,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        
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