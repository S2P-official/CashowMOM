import 'dart:convert';
import 'package:factory_app/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class EmployeeAttendanceCalendarPage extends StatefulWidget {
  const EmployeeAttendanceCalendarPage({super.key});

  @override
  State<EmployeeAttendanceCalendarPage> createState() =>
      _EmployeeAttendanceCalendarPageState();
}

class _EmployeeAttendanceCalendarPageState
    extends State<EmployeeAttendanceCalendarPage> {
  static const String baseUrl = 'http://192.168.29.215:8080';

  DateTime _currentMonth = DateTime.now();
  List<DateTime> presentDates = [];
  bool isLoading = false;

  int? employeeId;

  @override
  void initState() {
    super.initState();

    // Delay provider access until context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      employeeId = auth.employeeId;

      if (employeeId != null) {
        _loadAttendance();
      }
    });
  }

  // ---------------- Load Attendance ----------------
  Future<void> _loadAttendance() async {
    if (employeeId == null) return;

    setState(() => isLoading = true);

    final startDate = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final endDate = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      DateUtils.getDaysInMonth(
        _currentMonth.year,
        _currentMonth.month,
      ),
    );

    final url =
        '$baseUrl/api/attendance/employee/$employeeId'
        '?startDate=${DateFormat('yyyy-MM-dd').format(startDate)}'
        '&endDate=${DateFormat('yyyy-MM-dd').format(endDate)}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        presentDates =
            data.map<DateTime>((d) => DateTime.parse(d)).toList();
      } else {
        presentDates = [];
      }
    } catch (_) {
      presentDates = [];
    }

    setState(() => isLoading = false);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final employeeName = auth.employeeName ?? 'Employee';

    return Scaffold(
      appBar: AppBar(
        title: Text('$employeeName Attendance'),
      ),
      body: Column(
        children: [
          _monthHeader(),
          _weekDaysHeader(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _calendarGrid(),
          ),
        ],
      ),
    );
  }

  // ---------------- Month Header ----------------
  Widget _monthHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
              _loadAttendance();
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_currentMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth =
                    DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
              _loadAttendance();
            },
          ),
        ],
      ),
    );
  }

  // ---------------- Week Days ----------------
  Widget _weekDaysHeader() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ---------------- Calendar Grid ----------------
  Widget _calendarGrid() {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth =
        DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final startOffset = firstDay.weekday % 7;
    final totalCells = startOffset + daysInMonth;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: totalCells,
      itemBuilder: (_, index) {
        if (index < startOffset) return const SizedBox.shrink();

        final day = index - startOffset + 1;
        final date =
            DateTime(_currentMonth.year, _currentMonth.month, day);

        final isPresent = presentDates.any(
          (d) =>
              d.year == date.year &&
              d.month == date.month &&
              d.day == date.day,
        );

        return Container(
          decoration: BoxDecoration(
            color: isPresent ? Colors.green : Colors.red.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$day',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
