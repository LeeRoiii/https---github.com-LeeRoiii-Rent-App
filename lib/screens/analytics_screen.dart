import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package to pubspec.yaml

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int totalRenters = 0, totalAvailableHouses = 0, totalMonthlyIncome = 0;
  int totalPaidForMonth = 0, totalNotPaidForMonth = 0;
  int totalRentersPaid = 0, totalRentersNotPaid = 0;
  String selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  Future<void> _calculateAnalytics() async {
    final houses = await _dbHelper.getHouses();
    setState(() {
      totalRenters = houses.where((h) => h['available'] == 0).length;
      totalAvailableHouses = houses.where((h) => h['available'] == 1).length;
      totalMonthlyIncome = houses.where((h) => h['available'] == 0).fold(0, (sum, h) => sum + (h['price'] as int));
      totalPaidForMonth = houses.where((h) => h['available'] == 0 && h['paid'] == 1).fold(0, (sum, h) => sum + (h['price'] as int));
      totalNotPaidForMonth = houses.where((h) => h['available'] == 0 && h['paid'] == 0).fold(0, (sum, h) => sum + (h['price'] as int));
      totalRentersPaid = houses.where((h) => h['available'] == 0 && h['paid'] == 1).length;
      totalRentersNotPaid = houses.where((h) => h['available'] == 0 && h['paid'] == 0).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _calculateAnalytics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildMetricsGrid(),
              SizedBox(height: 20),
              _buildCharts(),
              SizedBox(height: 20),
              _buildFinancialSummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Analytics Overview', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        _buildPeriodDropdown(),
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[300]!)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          items: ['This Month', 'Last Month', 'Last 3 Months', 'This Year'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: (newValue) {
            setState(() {
              selectedPeriod = newValue!;
              _calculateAnalytics();
            });
          },
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      MetricItem('Total Renters', totalRenters.toString(), Icons.person, Colors.blue),
      MetricItem('Paid Renters', totalRentersPaid.toString(), Icons.check_circle, Colors.green),
      MetricItem('Unpaid Renters', totalRentersNotPaid.toString(), Icons.cancel, Colors.red),
      MetricItem('Available Units', totalAvailableHouses.toString(), Icons.home, Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: metrics.map((metric) => _buildMetricCard(metric)).toList(),
    );
  }

  Widget _buildMetricCard(MetricItem metric) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(backgroundColor: metric.color.withOpacity(0.1), child: Icon(metric.icon, color: metric.color)),
            SizedBox(height: 12),
            Text(metric.title, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(metric.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: metric.color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        SizedBox(height: 16),
        Container(
          height: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(color: Colors.green, value: totalPaidForMonth.toDouble(), title: 'Paid', radius: 50, titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                PieChartSectionData(color: Colors.red, value: totalNotPaidForMonth.toDouble(), title: 'Unpaid', radius: 50, titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildFinancialItem('Total Monthly Income', '\$${totalMonthlyIncome.toString()}', Icons.monetization_on, Colors.blue),
                Divider(height: 32),
                _buildFinancialItem('Total Paid', '\$${totalPaidForMonth.toString()}', Icons.check_circle, Colors.green),
                Divider(height: 32),
                _buildFinancialItem('Total Unpaid', '\$${totalNotPaidForMonth.toString()}', Icons.cancel, Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialItem(String title, String value, IconData icon, Color color) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class MetricItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  MetricItem(this.title, this.value, this.icon, this.color);
}
