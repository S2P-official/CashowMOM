import 'package:factory_app/presentation/dashboard/borma_dashboard.dart';
import 'package:factory_app/presentation/dashboard/calibration_dashboard.dart';
import 'package:factory_app/presentation/dashboard/grading_dashboard.dart';
import 'package:factory_app/presentation/dashboard/peeling_dashboard.dart';
import 'package:factory_app/presentation/dashboard/roasting_dashboard.dart';
import 'package:factory_app/presentation/dashboard/shelling_dashboard.dart';
import 'package:flutter/material.dart';

class DepartmentStatusPage extends StatelessWidget {
  final String tenantName;
  final int tenantId;
  final int employeeId;

  const DepartmentStatusPage({
    super.key,
    required this.tenantName,
    required this.tenantId,
    required this.employeeId,
  });

  @override
  Widget build(BuildContext context) {
    final departments = [
      ('Calibration', () => CalibrationDashboardApp(tenantName: tenantName, tenantId: tenantId, employeeId: employeeId)),
       ('Roasting', () => RoastingDashboardApp(tenantName: tenantName, tenantId: tenantId, employeeId: employeeId)),
       ('Shelling', () => ShellingDashboardApp(tenantName: tenantName, tenantId: tenantId, employeeId: employeeId)),
      ('Borma', () => BormaDashboardApp(tenantName: tenantName, tenantId: tenantId, employeeId: employeeId)),
      ('Peeling', () => PeelingDashboardApp(tenantName: tenantName, tenantId: tenantId, employeeId: employeeId)),
      ('Grading', () => GradingDashboardApp(tenantName: tenantName)),
      
     
      
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.factory),
            title: Text(departments[index].$1),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => departments[index].$2()),
              );
            },
          ),
        );
      },
    );
  }
}
