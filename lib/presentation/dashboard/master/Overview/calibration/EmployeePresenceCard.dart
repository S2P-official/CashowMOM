import 'package:flutter/material.dart';

/* ===========================
   Employee Model (example)
   =========================== */
class Employee {
  final String name;

  Employee({required this.name});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      name: json['name'] ?? '',
    );
  }
}

/* ===========================
   Employee Presence Card
   =========================== */
class EmployeePresenceCard extends StatelessWidget {
  final Future<List<Employee>> presentEmployeesFuture;
  final bool isTablet;

  const EmployeePresenceCard({
    super.key,
    required this.presentEmployeesFuture,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Employee>>(
      future: presentEmployeesFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildCard(context, 0);
        }

        final employees = snapshot.data!;

        return _buildCard(context, employees.length, employees);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    int count, [
    List<Employee>? employees,
  ]) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: employees == null
          ? null
          : () {
              _showEmployeeBottomSheet(context, employees);
            },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_alt,
                size: isTablet ? 48 : 40,
                color: Colors.green.shade700,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Employees Present Today',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ===========================
     Bottom Sheet Popup
     =========================== */
  void _showEmployeeBottomSheet(
    BuildContext context,
    List<Employee> employees,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Text(
                'Employees Present Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                itemCount: employees.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, index) {
                  final emp = employees[index];
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(emp.name),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
