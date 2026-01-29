// File: master_dashboard.dart
import 'package:factory_app/presentation/dashboard/master/Departments/DepartmentStatusPage.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/EmployeeManagementPage.dart';
import 'package:factory_app/presentation/dashboard/master/More/MasterMorePage.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/MasterOverviewPage.dart';
import 'package:factory_app/presentation/dashboard/ReportsPage.dart';
import 'package:flutter/material.dart';


// Import all dashboards


class MasterDashboardApp extends StatelessWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;
   const MasterDashboardApp({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MasterDashboardPage(
        tenantName: tenantName,
        tenantId: tenantId,
        employeeId: employeeId,
      ),
    );
  }
}

class MasterDashboardPage extends StatefulWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const MasterDashboardPage({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  State<MasterDashboardPage> createState() => _MasterDashboardPageState();
}

class _MasterDashboardPageState extends State<MasterDashboardPage> {
  int _selectedIndex = 0;

late final List<Widget> _pages = [
  MasterOverviewPage(tenantId:widget.tenantId),
  DepartmentStatusPage(
    tenantName: widget.tenantName,
    tenantId: widget.tenantId,
    employeeId: widget.employeeId,
  ),
  EmployeeManagementPage(
    tenantId: widget.tenantId,
    tenantName: widget.tenantName, // ✅ FIX
  ),
  ReportsPage(),
  MasterMorePage(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tenantName} - Master Dashboard'),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.factory), label: 'Departments'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

