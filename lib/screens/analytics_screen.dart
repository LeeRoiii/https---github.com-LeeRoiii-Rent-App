import 'package:flutter/material.dart';
import '../database_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int totalRenters = 0;
  int totalAvailableHouses = 0;
  int totalMonthlyIncome = 0;
  int totalPaidForMonth = 0;
  int totalNotPaidForMonth = 0;
  int totalRentersPaid = 0; // Total renters who have paid
  int totalRentersNotPaid = 0; // Total renters who have not paid

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  Future<void> _calculateAnalytics() async {
    final houses = await _dbHelper.getHouses();
    setState(() {
      totalRenters = houses.where((house) => house['available'] == 0).length;
      totalAvailableHouses = houses.where((house) => house['available'] == 1).length;
      totalMonthlyIncome = houses
          .where((house) => house['available'] == 0)
          .fold(0, (sum, house) => sum + (house['price'] as int));

      totalPaidForMonth = houses
          .where((house) => house['available'] == 0 && house['paid'] == 1)
          .fold(0, (sum, house) => sum + (house['price'] as int));

      totalNotPaidForMonth = houses
          .where((house) => house['available'] == 0 && house['paid'] == 0)
          .fold(0, (sum, house) => sum + (house['price'] as int));
      
      totalRentersPaid = houses.where((house) => house['available'] == 0 && house['paid'] == 1).length; // Count renters who have paid
      totalRentersNotPaid = houses.where((house) => house['available'] == 0 && house['paid'] == 0).length; // Count renters who have not paid
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // White background for a clean look
      padding: const EdgeInsets.all(20.0), // More padding for better spacing
      child: SingleChildScrollView( // Make the content scrollable
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Analytics Overview',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // A primary color for the title
              ),
            ),
            SizedBox(height: 20), // Space between title and cards
            _buildCard(
              title: 'Total Renters',
              value: totalRenters.toString(),
              icon: Icons.person,
              color: Colors.blue,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Renters Paid',
              value: totalRentersPaid.toString(),
              icon: Icons.check_circle,
              color: Colors.greenAccent,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Renters Not Paid',
              value: totalRentersNotPaid.toString(),
              icon: Icons.cancel,
              color: Colors.redAccent,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Available Houses',
              value: totalAvailableHouses.toString(),
              icon: Icons.home,
              color: Colors.green,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Monthly Income',
              value: '\$${totalMonthlyIncome}',
              icon: Icons.monetization_on,
              color: Colors.orange,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Paid for the Month',
              value: '\$${totalPaidForMonth}',
              icon: Icons.check_circle,
              color: Colors.greenAccent,
            ),
            SizedBox(height: 20), // Space between cards
            _buildCard(
              title: 'Total Not Paid for the Month',
              value: '\$${totalNotPaidForMonth}',
              icon: Icons.cancel,
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 8, // Increased elevation for a more prominent effect
      shadowColor: Colors.black.withOpacity(0.2), // Softer shadow color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Inner padding
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2), // Light background for the avatar
              child: Icon(icon, size: 30, color: color), // Icon in the avatar
            ),
            SizedBox(width: 15), // Space between icon and text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700], // Subtle text color
                    ),
                  ),
                  SizedBox(height: 5), // Space between title and value
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color, // Color based on the card type
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
