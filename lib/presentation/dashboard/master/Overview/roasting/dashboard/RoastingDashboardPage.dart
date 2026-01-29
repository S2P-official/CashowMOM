import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RoastingDashboardPage extends StatefulWidget {
  final int tenantId;

  const RoastingDashboardPage({super.key, required this.tenantId});

  @override
  State<RoastingDashboardPage> createState() => _RoastingDashboardPageState();
}

class _RoastingDashboardPageState extends State<RoastingDashboardPage> {
  DateTime selectedDate = DateTime.now();
  bool isLoading = true;

  double totalRoastedSum = 0;
  Map<String, dynamic> cuttingLineWiseTotal = {};
  List<dynamic> reports = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    final url =
        "http://192.168.29.215:8080/api/roasting-reports/tenant/${widget.tenantId}/date/$formattedDate";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          totalRoastedSum = (data['totalRoastedSum'] ?? 0).toDouble();
          cuttingLineWiseTotal = Map<String, dynamic>.from(
            data['cuttingLineWiseTotalRoasted'] ?? {},
          );
          reports = data['reports'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
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
        title: const Text("Roasting Dashboard"),
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
                            fontWeight: FontWeight.bold,
                          ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            "Total Roasted Qty",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$totalRoastedSum",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 30),
                          Wrap(
                            spacing: 12,
                            children: cuttingLineWiseTotal.entries.map((e) {
                              return Chip(
                                label: Text("${e.key} : ${e.value}"),
                                backgroundColor: Colors.blue.shade50,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // TABLE
                  // TABLE
                  // TABLE
                  if (reports.isEmpty)
                    const Text("No data available")
                  else
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.6, // adjust as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          columns: const [
                            DataColumn(label: Text("Lot")),
                            DataColumn(label: Text("Origin")),
                            DataColumn(label: Text("Size")),
                            DataColumn(label: Text("Bags")),
                            DataColumn(label: Text("Qty")),
                            DataColumn(label: Text("Count/Kg")),
                            DataColumn(label: Text("Roaster")),
                            DataColumn(label: Text("Employee")),
                            DataColumn(label: Text("Cooking Time")),
                            DataColumn(label: Text("Temp (VN)")),
                            DataColumn(label: Text("Roasting Duration")),
                            DataColumn(label: Text("Soaking Moisture")),
                            DataColumn(label: Text("Moisture After Roasting")),
                            DataColumn(label: Text("Total Roasted")),
                            DataColumn(label: Text("Cutting Line")),
                          ],
                          rows: reports.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r['lotMark'] ?? '-')),
                                DataCell(Text(r['origin'] ?? '-')),
                                DataCell(Text(r['sizeRange'] ?? '-')),
                                DataCell(Text("${r['noOfBags']}")),
                                DataCell(Text("${r['productionQty']}")),
                                DataCell(Text("${r['countPerKg']}")),
                                DataCell(Text(r['roasterName'] ?? '-')),
                                DataCell(Text(r['employeeName'] ?? '-')),
                                DataCell(Text(r['cookingTime'] ?? '-')),
                                DataCell(Text(r['tempForVnMachine'] ?? '-')),
                                DataCell(Text(r['roastingDuration'] ?? '-')),
                                DataCell(Text(r['soackingMoisture'] ?? '-')),
                                DataCell(
                                  Text(r['moistureAfterRoasting'] ?? '-'),
                                ),
                                DataCell(Text(r['totalRoasted'] ?? '-')),
                                DataCell(Text(r['cuttingLine'] ?? '-')),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
