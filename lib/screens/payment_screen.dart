import 'package:flutter/material.dart';
import '../database_helper.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _houses = [];

  @override
  void initState() {
    super.initState();
    _loadHouses();
  }

  Future<void> _loadHouses() async {
    final houses = await _dbHelper.getHouses();
    setState(() {
      _houses = houses;
    });
  }

  Future<void> _markAsPaid(int houseId) async {
    await _dbHelper.markRenterAsPaid(houseId);
    _loadHouses(); // Refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Renter marked as paid!')),
    );
  }

  Future<void> _markAsNotPaid(int houseId) async {
    await _dbHelper.markRenterAsNotPaid(houseId);
    _loadHouses(); // Refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Renter marked as not paid!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Payments'),
      ),
      body: ListView.builder(
        itemCount: _houses.length,
        itemBuilder: (context, index) {
          final house = _houses[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(house['renter'] ?? 'No Renter'),
              subtitle: Text(
                'Location: ${house['location']} - Rent: \$${house['price']}\n'
                'Payment Status: ${house['paid'] == 1 ? "Paid" : "Not Paid"}',
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: house['paid'] == 1 ? null : () => _markAsPaid(house['id']),
                    child: Text('Mark Paid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: house['paid'] == 1 ? Colors.green : Colors.blue,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: house['paid'] == 0 ? null : () => _markAsNotPaid(house['id']),
                    child: Text('Mark Not Paid'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: house['paid'] == 0 ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
