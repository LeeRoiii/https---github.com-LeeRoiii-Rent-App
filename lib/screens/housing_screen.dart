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

  Future<void> _addRenter(int? houseId, String name, String email, String contactNumber) async {
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

  void _showAddRenterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assign Renter'),
          content: RenterFormWidget(
            formKey: _renterFormKey,
            filteredHouses: _filteredHouses,
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
      elevation: 6,
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
                      Text(house['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text(house['location'], style: TextStyle(color: Colors.grey[700])),
                      SizedBox(height: 8),
                      Text("\$${house['price']}/month", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? Colors.green : Colors.red,
                  size: 24,
                ),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isAvailable ? 'Available' : 'Rented',
                    style: TextStyle(
                      color: isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Perform action based on availability
              },
              child: Text(isAvailable ? 'Assign Renter' : 'View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            backgroundColor: Colors.deepPurple,
            elevation: 6,
            shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Property Management', style: TextStyle(color: Colors.white)),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _showAddHouseDialog,
                        icon: Icon(Icons.add),
                        label: Text('Add House'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _showAddRenterDialog,
                        icon: Icon(Icons.person_add),
                        label: Text('Add Renter'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
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
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: _isLoading
                ? SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredHouses.isEmpty
                    ? SliverFillRemaining(
                        child: Center(child: Text('No houses available')),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final house = _filteredHouses[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _buildHouseCard(house),
                            );
                          },
                          childCount: _filteredHouses.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
