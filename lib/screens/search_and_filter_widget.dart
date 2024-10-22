import 'package:flutter/material.dart';

class SearchAndFilterWidget extends StatelessWidget {
  final String searchQuery;
  final String availabilityFilter;
  final ValueChanged<String> onSearchChanged; // Update this line
  final ValueChanged<String?> onFilterChanged; // Update this line

  SearchAndFilterWidget({
    required this.searchQuery,
    required this.availabilityFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search Houses',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        SizedBox(width: 10),
        DropdownButton<String>(
          value: availabilityFilter,
          onChanged: onFilterChanged, // This should work now
          items: [
            DropdownMenuItem(value: 'All', child: Text('All')),
            DropdownMenuItem(value: 'Available', child: Text('Available')),
            DropdownMenuItem(value: 'Rented', child: Text('Rented')),
          ],
        ),
      ],
    );
  }
}
