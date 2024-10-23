import 'package:flutter/material.dart';

class RenterFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int? houseId;
  final String houseName;
  final String houseLocation;
  final int housePrice;
  final Function(int?, String, String, String) onSubmit;

  const RenterFormWidget({
    required this.formKey,
    required this.houseId,
    required this.houseName,
    required this.houseLocation,
    required this.housePrice,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    // Define controllers for renter information here
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController contactController = TextEditingController();

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Renter Name'),
            validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          ),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
          ),
          TextFormField(
            controller: contactController,
            decoration: InputDecoration(labelText: 'Contact Number'),
            validator: (value) => value!.isEmpty ? 'Please enter a contact number' : null,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSubmit(houseId, nameController.text, emailController.text, contactController.text);
              }
            },
            child: Text('Assign Renter'),
          ),
        ],
      ),
    );
  }
}
