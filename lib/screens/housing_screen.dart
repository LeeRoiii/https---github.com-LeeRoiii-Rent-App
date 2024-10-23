import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'house_form_widget.dart';
import 'renter_form_widget.dart';
import 'search_and_filter_widget.dart';

class HousingScreen extends StatefulWidget {
  @override
  _HousingScreenState createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _houses = [];
  List<Map<String, dynamic>> _filteredHouses = [];
  final _houseFormKey = GlobalKey<FormState>();
  final _renterFormKey = GlobalKey<FormState>();
  String _searchQuery = '';
  String _availabilityFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    setState(() => _isLoading = true);
    final houses = await _dbHelper.getHouses();
    setState(() {
      _houses = houses.map((house) {
        return {
          'id': house['id'],
          'name': house['name'],
          'location': house['location'],
          'price': house['price'] as int,
          'renter': house['renter'] ?? '',
          'available': house['available'] as int,
        };
      }).toList();
      _filteredHouses = _houses;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredHouses = _houses.where((house) {
        final matchesSearch = house['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());

        final matchesAvailability = (_availabilityFilter == 'All') ||
            (_availabilityFilter == 'Available' && house['available'] == 1) ||
            (_availabilityFilter == 'Rented' && house['available'] == 0);

        return matchesSearch && matchesAvailability;
      }).toList();
    });
  }

  Future<void> _addHouse(String name, String location, int price) async {
    await _dbHelper.insertHouse({
      'name': name,
      'location': location,
      'price': price,
      'renter': '',
      'available': 1,
    });
    _loadHouses();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('House added successfully!')),
    );
  }

  Future<void> _addRenter(
      int? houseId, String name, String email, String contactNumber) async {
    if (houseId != null) {
      await _dbHelper.updateHouseAvailability(houseId, 0);
      await _dbHelper.updateRenter(houseId, name, email, contactNumber);
      _loadHouses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Renter assigned successfully!')),
      );
    }
  }

  void _showAddHouseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add House'),
          content: HouseFormWidget(
            formKey: _houseFormKey,
            onSubmit: (name, location, price) {
              _addHouse(name, location, price);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _showAddRenterDialog(Map<String, dynamic> house) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Renter for ${house['name']}'),
          content: RenterFormWidget(
            formKey: _renterFormKey,
            houseId: house['id'], // Pass the house ID to the widget
            houseName: house['name'], // Pass the house name
            houseLocation: house['location'], // Pass the house location
            housePrice: house['price'], // Pass the house price
            onSubmit: (houseId, name, email, contactNumber) {
              _addRenter(houseId, name, email, contactNumber);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  Widget _buildHouseCard(Map<String, dynamic> house) {
    bool isAvailable = house['available'] == 1;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // House name
                      Text(
                        house['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      // Location row
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                          SizedBox(width: 4),
                          Text(
                            house['location'],
                            style: TextStyle(color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Price row
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.grey[600], size: 16),
                          SizedBox(width: 4),
                          Text(
                            "\$${house['price']}/month",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Availability label
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Rented',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Assign Renter / View Details button
            ElevatedButton(
              onPressed: () {
                if (isAvailable) {
                  _showAddRenterDialog(house); // Pass the entire house object
                } else {
                  // Handle view details if not available
                }
              },
              child: Text(isAvailable ? 'Assign Renter' : 'View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Set button color to blue
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Housing List', style: TextStyle(color: Colors.white)),
            IconButton(
              onPressed: _showAddHouseDialog,
              icon: Icon(Icons.add),
              color: Colors.white,
            ),
          ],
        ),
        backgroundColor: Colors.blue, // Set AppBar color to blue
        elevation: 6,
        shadowColor: Colors.blueAccent.withOpacity(0.4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchAndFilterWidget(
              searchQuery: _searchQuery,
              availabilityFilter: _availabilityFilter,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilters();
                });
              },
              onFilterChanged: (value) {
                setState(() {
                  _availabilityFilter = value!;
                  _applyFilters();
                });
              },
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 5,
                      ),
                    )
                  : _filteredHouses.isEmpty
                      ? Center(child: Text('No houses available'))
                      : ListView.builder(
                          itemCount: _filteredHouses.length,
                          itemBuilder: (context, index) {
                            final house = _filteredHouses[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildHouseCard(house),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
