import 'package:flutter/material.dart';

class RenterFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Map<String, dynamic>> filteredHouses;
  final Function(int?, String, String, String) onSubmit;

  RenterFormWidget({
    required this.formKey,
    required this.filteredHouses,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    String renterName = '';
    String renterEmail = '';
    String renterContactNumber = '';
    int? selectedHouseId;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            decoration: InputDecoration(labelText: 'Select House', border: OutlineInputBorder()),
            items: filteredHouses
                .where((house) => house['available'] == 1)
                .map((house) {
              return DropdownMenuItem<int>(
                value: house['id'],
                child: Text('${house['name']} - \$${house['price']}'),
              );
            }).toList(),
            onChanged: (value) => selectedHouseId = value,
            validator: (value) => value == null ? 'Please select a house' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'Renter Name', border: OutlineInputBorder()),
            onSaved: (value) => renterName = value!,
            validator: (value) => value!.isEmpty ? 'Please enter renter name' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'Renter Email', border: OutlineInputBorder()),
            onSaved: (value) => renterEmail = value!,
            validator: (value) => value!.isEmpty ? 'Please enter renter email' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'Renter Contact Number', border: OutlineInputBorder()),
            onSaved: (value) => renterContactNumber = value!,
            validator: (value) => value!.isEmpty ? 'Please enter renter contact number' : null,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                onSubmit(selectedHouseId, renterName, renterEmail, renterContactNumber);
              }
            },
            child: Text('Assign Renter'),
          ),
        ],
      ),
    );
  }
}
