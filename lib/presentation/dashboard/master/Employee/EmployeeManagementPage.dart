// File: EmployeeManagementPage.dart
import 'package:factory_app/presentation/dashboard/master/Employee/AddEmployee/AddEmployeeDialog.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/AssignRole/AssignRole.dart';
import 'package:factory_app/presentation/dashboard/master/Employee/deleteEmployee/deleteEmployee.dart';
import 'package:flutter/material.dart';
import 'ViewAttendance/AttendanceSummaryPage.dart';

class EmployeeManagementPage extends StatelessWidget {
  final int tenantId;

  const EmployeeManagementPage({
    super.key,
    required this.tenantId,
    required this.tenantName,
  });

  final actions = const [
    'Add Employee',
    'Assign Role',
    'View Attendance',
    'Deactivate Employee',
  ];
  
  final dynamic tenantName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: Text(actions[index]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                switch (actions[index]) {
                  case 'Add Employee':
                    _showAddEmployeeDialog(context);
                    break;

                  case 'Assign Role':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AssignRolePage(tenantId: tenantId, tenantName: tenantName,),
                      ),
                    );
                    break;

                  case 'View Attendance':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AttendanceSummaryPage(tenantId: tenantId),
                      ),
                    );
                    break;

                  case 'Deactivate Employee':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EmployeeRelevePage(tenantId: tenantId, tenantName: tenantName,),
                      ),
                    );
                    break;
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddEmployeeDialog(tenantId: tenantId),
    );
  }
}
