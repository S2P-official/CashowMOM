// File: attendance/AttendanceSummaryPage.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'EmployeeAttendanceCalendarPage.dart';

class Employee {
  final int id;
  final String name;
  final int presentDays;

  Employee({
    required this.id,
    required this.name,
    required this.presentDays,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      presentDays: json['presentDays'] ?? 0,
    );
  }
}

class AttendanceSummaryPage extends StatefulWidget {
  final int tenantId;

  const AttendanceSummaryPage({super.key, required this.tenantId});

  @override
  State<AttendanceSummaryPage> createState() => _AttendanceSummaryPageState();
}

class _AttendanceSummaryPageState extends State<AttendanceSummaryPage> {
  static const String baseUrl = 'http://192.168.29.215:8080';

  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = fetchEmployees();
  }

  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/employees/tenant/${widget.tenantId}'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load employees');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Employee.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Summary')),
      body: FutureBuilder<List<Employee>>(
        future: _employeesFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final employees = snapshot.data!;
          if (employees.isEmpty) {
            return const Center(child: Text('No employees found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: employees.length,
            itemBuilder: (_, index) {
              final emp = employees[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(emp.name),
                  subtitle: Text('Days Present: ${emp.presentDays}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeAttendanceCalendarPage(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
