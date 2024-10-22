import 'package:flutter/material.dart';

class HouseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredHouses;

  HouseListWidget({required this.filteredHouses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredHouses.length,
      itemBuilder: (context, index) {
        final house = filteredHouses[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              house['name'],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${house['location']} - \$${house['price']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Text(
              house['available'] == 1 ? 'Available' : 'Rented',
              style: TextStyle(
                color: house['available'] == 1 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
