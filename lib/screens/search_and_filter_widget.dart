import 'package:flutter/material.dart';

class SearchAndFilterWidget extends StatelessWidget {
  final String searchQuery;
  final String availabilityFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  SearchAndFilterWidget({
    required this.searchQuery,
    required this.availabilityFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0), // Add padding for spacing
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Houses',
                labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                prefixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 0, 0, 0)),
                filled: true,
                fillColor: Colors.blue[50], // Light blue background for input
              ),
              onChanged: onSearchChanged,
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50], // Background color for dropdown
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 1),
            ),
            child: DropdownButton<String>(
              value: availabilityFilter,
              onChanged: onFilterChanged,
              underline: SizedBox(), // Remove underline
              icon: Icon(Icons.arrow_drop_down, color: const Color.fromARGB(255, 0, 0, 0)), // Blue icon
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 16),
              dropdownColor: Colors.white, // White dropdown background
              items: [
                DropdownMenuItem(
                  value: 'All',
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: 'Available',
                  child: Text('Available'),
                ),
                DropdownMenuItem(
                  value: 'Rented',
                  child: Text('Rented'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
