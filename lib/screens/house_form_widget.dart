import 'package:flutter/material.dart';

class HouseFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function(String, String, int) onSubmit;

  HouseFormWidget({required this.formKey, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    String houseName = '';
    String location = '';
    int price = 0;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: 'House Name', border: OutlineInputBorder()),
            onSaved: (value) => houseName = value!,
            validator: (value) => value!.isEmpty ? 'Please enter house name' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
            onSaved: (value) => location = value!,
            validator: (value) => value!.isEmpty ? 'Please enter location' : null,
          ),
          SizedBox(height: 10),
          TextFormField(
            decoration: InputDecoration(labelText: 'Rent per Month', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onSaved: (value) => price = int.parse(value!),
            validator: (value) => value!.isEmpty ? 'Please enter price' : null,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                onSubmit(houseName, location, price);
              }
            },
            child: Text('Add House'),
          ),
        ],
      ),
    );
  }
}
