import 'package:flutter/material.dart';
import '../database_helper.dart';

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
  String _houseName = '';
  String _location = '';
  int _price = 0;
  String _renterName = '';
  String _renterEmail = '';
  String _renterContactNumber = '';
  int? _selectedHouseId;

  String _searchQuery = '';
  String _availabilityFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
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
      _filteredHouses = _houses; // Initialize filtered houses
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

  Future<void> _addHouse() async {
    if (_houseFormKey.currentState!.validate()) {
      _houseFormKey.currentState!.save();
      await _dbHelper.insertHouse({
        'name': _houseName,
        'location': _location,
        'price': _price,
        'renter': '',
        'available': 1,
      });
      _loadHouses();
      _houseName = '';
      _location = '';
      _price = 0;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('House added successfully!')),
      );
    }
  }

  Future<void> _addRenter() async {
    if (_renterFormKey.currentState!.validate()) {
      _renterFormKey.currentState!.save();
      await _dbHelper.updateHouseAvailability(_selectedHouseId!, 0);
      await _dbHelper.updateRenter(
        _selectedHouseId!,
        _renterName,
        _renterEmail,
        _renterContactNumber,
      );
      _loadHouses();
      _renterName = '';
      _renterEmail = '';
      _renterContactNumber = '';
      _selectedHouseId = null;
      Navigator.of(context).pop();
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
          content: Form(
            key: _houseFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'House Name', border: OutlineInputBorder()),
                  onSaved: (value) {
                    _houseName = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter house name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
                  onSaved: (value) {
                    _location = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Rent per Month', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _price = int.parse(value!);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter price';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addHouse();
              },
              child: Text('Add House'),
            ),
          ],
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
          content: Form(
            key: _renterFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Select House', border: OutlineInputBorder()),
                  items: _filteredHouses
                      .where((house) => house['available'] == 1)
                      .map((house) {
                    return DropdownMenuItem<int>(
                      value: house['id'],
                      child: Text('${house['name']} - \$${house['price']}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedHouseId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a house';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Renter Name', border: OutlineInputBorder()),
                  onSaved: (value) {
                    _renterName = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter renter name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Renter Email', border: OutlineInputBorder()),
                  onSaved: (value) {
                    _renterEmail = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter renter email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Renter Contact Number', border: OutlineInputBorder()),
                  onSaved: (value) {
                    _renterContactNumber = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter renter contact number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addRenter();
              },
              child: Text('Assign Renter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Houses'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddHouseDialog,
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _showAddRenterDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Houses',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _availabilityFilter,
                  onChanged: (value) {
                    setState(() {
                      _availabilityFilter = value!;
                      _applyFilters();
                    });
                  },
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
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredHouses.length,
                itemBuilder: (context, index) {
                  final house = _filteredHouses[index];
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
