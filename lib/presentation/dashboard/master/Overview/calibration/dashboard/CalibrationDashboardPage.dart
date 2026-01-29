import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CalibrationDashboardPage extends StatefulWidget {
  final int tenantId;

  const CalibrationDashboardPage({
    super.key,
    required this.tenantId,
  });

  @override
  State<CalibrationDashboardPage> createState() =>
      _CalibrationDashboardPageState();
}

class _CalibrationDashboardPageState extends State<CalibrationDashboardPage> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  double totalQty = 0;
  Map<String, dynamic> sizeWiseQty = {};
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(selectedDate);

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final url =
        "http://192.168.29.215:8080/api/calibration-reports/tenant/${widget.tenantId}/date/$formattedDate";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          totalQty = (data['totalProductionQty'] ?? 0).toDouble();
          sizeWiseQty = data['sizeWiseProductionQty'] ?? {};
          reports = data['reports'] ?? [];
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    } catch (e) {
      isLoading = false;
    }
  }

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    fetchData();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calibration Dashboard"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // DATE CONTROLS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => changeDate(-1),
                      ),
                      TextButton(
                        onPressed: pickDate,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => changeDate(1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // SUMMARY CARD
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Total Production",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$totalQty",
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 30),
                          Wrap(
                            spacing: 12,
                            children: sizeWiseQty.entries.map((e) {
                              return Chip(
                                label: Text("${e.key} : ${e.value}"),
                                backgroundColor: Colors.blue.shade50,
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TABLE
                  if (reports.isEmpty)
                    const Text("No data available")
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            MaterialStateProperty.all(Colors.blue.shade50),
                        columns: const [
                          DataColumn(label: Text("Lot")),
                          DataColumn(label: Text("Origin")),
                          DataColumn(label: Text("Size")),
                          DataColumn(label: Text("Bags")),
                          DataColumn(label: Text("Qty")),
                          DataColumn(label: Text("Count/Kg")),
                          DataColumn(label: Text("Employee")),
                        ],
                        rows: reports.map((r) {
                          return DataRow(cells: [
                            DataCell(Text(r['lotMark'] ?? '-')),
                            DataCell(Text(r['origin'] ?? '-')),
                            DataCell(Text(r['sizeRange'] ?? '-')),
                            DataCell(Text("${r['noOfBags']}")),
                            DataCell(Text("${r['productionQty']}")),
                            DataCell(Text("${r['countPerKg']}")),
                            DataCell(Text(r['employeeName'] ?? '-')),
                          ]);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
