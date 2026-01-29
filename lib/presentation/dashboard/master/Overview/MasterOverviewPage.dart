import 'dart:convert';
import 'package:flutter/material.dart'; 
import 'package:http/http.dart' as http;

/* ===== EMPLOYEE PRESENCE ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/EmployeePresenceCard.dart';

/* ===== CALIBRATION ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/CalibrationApiService.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/CalibrationSummaryResponse.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/CalibrationCard.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/dashboard/CalibrationDashboardPage.dart';

/* ===== ROASTING ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/roasting/RoastingApiService.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/roasting/RoastingSummaryResponse.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/roasting/RoastingCard.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/roasting/dashboard/RoastingDashboardPage.dart';

/* ===== SHELLING ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/shelling/shelling_api_service.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/shelling/shelling_summary_response.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/shelling/shelling_card.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/shelling/dashboard/ShellingDashboardPage.dart';

/* ===== BORMA ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/borma/borma_api_service.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/borma/borma_summary_response.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/borma/borma_card.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/borma/dashboard/BormaDashboardPage.dart';

/* ===== PEELING ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/peeling/peeling_api_service.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/peeling/peeling_summary_response.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/peeling/peeling_card.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/peeling/dashboard/peelingDashboard.dart';

/* ===== GRADING ===== */
import 'package:factory_app/presentation/dashboard/master/Overview/grading/grading_api_service.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/grading/grading_summary_response.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/grading/grading_card.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/grading/dashboard/gradingDashboard.dart';

/* ===========================
   MASTER OVERVIEW PAGE
   =========================== */

class MasterOverviewPage extends StatefulWidget {
  final int tenantId;

  const MasterOverviewPage({super.key, required this.tenantId});

  @override
  State<MasterOverviewPage> createState() => _MasterOverviewPageState();
}

class _MasterOverviewPageState extends State<MasterOverviewPage> {
  static const String baseUrl = 'http://192.168.29.215:8080';

  late Future<List<Employee>> _presentEmployeesFuture;

  late Future<CalibrationSummaryResponse> calibrationFuture;
  late Future<RoastingSummaryResponse> roastingFuture;
  late Future<ShellingSummaryResponse> shellingFuture;
  late Future<BormaSummaryResponse> bormaFuture;
  late Future<PeelingSummaryResponse> peelingFuture;
  late Future<GradingSummaryResponse> gradingFuture;

  @override
  void initState() {
    super.initState();

    _presentEmployeesFuture = _fetchTodayPresentEmployees();

    calibrationFuture = CalibrationApiService().fetchTodaySummary(
      widget.tenantId,
    );
    roastingFuture = RoastingApiService().fetchTodaySummary(widget.tenantId);
    shellingFuture = ShellingApiService().fetchTodaySummary(widget.tenantId);
    bormaFuture = BormaApiService().fetchTodaySummary(widget.tenantId);
    peelingFuture = PeelingApiService().fetchTodaySummary(widget.tenantId);
    gradingFuture = GradingApiService().fetchTodaySummary(widget.tenantId);
  }

  Future<List<Employee>> _fetchTodayPresentEmployees() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/employees/tenant/${widget.tenantId}/today-present',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load employees');
    }

    final List data = jsonDecode(response.body);
    return data.map((e) => Employee.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final bool isTablet = constraints.maxWidth >= 720;

        return SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 28 : 16,
              vertical: 16,
            ),
            children: [
              EmployeePresenceCard(
                presentEmployeesFuture: _presentEmployeesFuture,
                isTablet: isTablet,
              ),
              const SizedBox(height: 24),
              _RoleReportsSection(
                tenantId: widget.tenantId,
                isTablet: isTablet,
                calibrationFuture: calibrationFuture,
                roastingFuture: roastingFuture,
                shellingFuture: shellingFuture,
                bormaFuture: bormaFuture,
                peelingFuture: peelingFuture,
                gradingFuture: gradingFuture,
              ),
              const SizedBox(height: 24),
              _RawMaterialSection(isTablet: isTablet),
            ],
          ),
        );
      },
    );
  }
}

/* ===========================
   ROLE REPORTS SECTION
   =========================== */

class _RoleReportsSection extends StatelessWidget {
  final bool isTablet;
  final int tenantId;

  final Future<CalibrationSummaryResponse> calibrationFuture;
  final Future<RoastingSummaryResponse> roastingFuture;
  final Future<ShellingSummaryResponse> shellingFuture;
  final Future<BormaSummaryResponse> bormaFuture;
  final Future<PeelingSummaryResponse> peelingFuture;
  final Future<GradingSummaryResponse> gradingFuture;

  const _RoleReportsSection({
    required this.isTablet,
    required this.tenantId,
    required this.calibrationFuture,
    required this.roastingFuture,
    required this.shellingFuture,
    required this.bormaFuture,
    required this.peelingFuture,
    required this.gradingFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Today Role-wise Reports', isTablet),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          children: [
            _futureCard(calibrationFuture, (data) {
              return CalibrationRoleCard(
                data: data,
                icon: Icons.tune,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CalibrationDashboardPage(tenantId: tenantId),
                  ),
                ),
              );
            }),
            _futureCard(roastingFuture, (data) {
              return RoastingRoleCard(
                data: data,
                icon: Icons.local_fire_department,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RoastingDashboardPage(tenantId: tenantId),
                  ),
                ),
              );
            }),
            _futureCard(shellingFuture, (data) {
              return ShellingRoleCard(
                data: data,
                icon: Icons.settings,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ShellingDashboardPage(),
                  ),
                ),
              );
            }),
            _futureCard(bormaFuture, (data) {
              return BormaRoleCard(
                data: data,
                icon: Icons.precision_manufacturing,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BormaDashboardPage()),
                ),
              );
            }),
            _futureCard(peelingFuture, (data) {
              return PeelingRoleCard(
                data: data,
                icon: Icons.layers_clear,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PeelingdashboardPage(),
                  ),
                ),
              );
            }),
            _futureCard(gradingFuture, (data) {
              return GradingRoleCard(
                data: data,
                icon: Icons.rule,
                isTablet: isTablet,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GradingdashboardPage(),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _futureCard<T>(Future<T> future, Widget Function(T data) builder) {
    return FutureBuilder<T>(
      future: future,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: SizedBox(
              height: 120,
              child: Center(
                child: Text('Loading...', style: TextStyle(fontSize: 14)),
              ),
            ),
          );
        }
        return builder(snapshot.data!);
      },
    );
  }
}

/* ===========================
   RAW MATERIAL SECTION
   =========================== */

class _RawMaterialSection extends StatelessWidget {
  final bool isTablet;

  const _RawMaterialSection({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Remaining Raw Material', isTablet),
        const SizedBox(height: 12),
        _materialTile('Cashew', '1,240 Kg'),
        _materialTile('Peanuts', '820 Kg'),
        _materialTile('Almonds', '430 Kg'),
      ],
    );
  }

  Widget _materialTile(String name, String qty) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.inventory_2, color: Colors.orange),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          qty,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}

/* ===========================
   HELPERS
   =========================== */

Widget _sectionTitle(String title, bool isTablet) {
  return Text(
    title,
    style: TextStyle(fontSize: isTablet ? 20 : 18, fontWeight: FontWeight.bold),
  );
}
