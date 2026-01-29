import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../../state/auth_provider.dart';

class CheckInScreenPage extends StatefulWidget {
  const CheckInScreenPage({super.key});

  @override
  State<CheckInScreenPage> createState() => _CheckInScreenPageState();
}

class _CheckInScreenPageState extends State<CheckInScreenPage> {
  bool _checkedIn = false;
  bool _checkedOut = false;
  bool _loading = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    await _getCurrentLocation();
    await _fetchAttendanceStatus();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _fetchAttendanceStatus() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tenantId = auth.userData?["tenant_id"];
    final employeeId = auth.userData?["employee_id"];

    try {
      final response = await http.get(Uri.parse(
          'http://192.168.29.215:8080/api/attendance/status?tenantId=$tenantId&employeeId=$employeeId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _checkedIn = data['checkedIn'] ?? false;
          _checkedOut = data['checkedOut'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleCheckInOut() async {
    if (_checkedOut) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final tenantId = auth.userData?["tenant_id"];
    final employeeId = auth.userData?["employee_id"];

    final url = _checkedIn
        ? 'http://192.168.29.215:8080/api/attendance/checkout'
        : 'http://192.168.29.215:8080/api/attendance/checkin';

    if (_currentPosition == null) await _getCurrentLocation();

    final body = json.encode({
      'tenantId': tenantId,
      'employeeId': employeeId,
      'latitude': _currentPosition?.latitude ?? 0.0,
      'longitude': _currentPosition?.longitude ?? 0.0
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        await _fetchAttendanceStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _checkedOut
                  ? 'Attendance completed for today'
                  : (_checkedIn ? 'Checked out successfully' : 'Checked in successfully'),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final employeeName = auth.userData?["employee_name"] ?? "Employee";
    final tenantName = auth.userData?["tenant_name"] ?? "";

   return Scaffold(
  backgroundColor: Colors.grey[100],
  body: _loading
      ? const Center(child: CircularProgressIndicator())
      : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card with tenant, welcome, quote
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tenant Name
                        Text(
                          tenantName.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple),
                        ),
                        const SizedBox(height: 10),
                        // Welcome Employee
                        Center(
                          child: Text(
                            "Welcome, $employeeName!",
                            style: const TextStyle(
                                fontFamily: 'Billabong',
                                fontSize: 36,
                                color: Colors.deepOrange),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Motivational Quote
                        Text(
                          "\"Success is the sum of small efforts, repeated day in and day out.\"",
                          style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[800]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Check-in / Check-out button or attendance completed
                _checkedOut
                    ? Column(
                        children: const [
                          Icon(Icons.check_circle_outline,
                              size: 60, color: Colors.green),
                          SizedBox(height: 10),
                          Text(
                            "Attendance Completed!\nThank you!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _handleCheckInOut,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _checkedIn
                                ? Colors.orangeAccent.shade700
                                : Colors.greenAccent.shade400,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 8,
                            textStyle: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          child: Text(_checkedIn ? "Check Out" : "Check In"),
                        ),
                      ),
              ],
            ),
          ),
        ),
);

  }
}
