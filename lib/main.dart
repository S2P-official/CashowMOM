import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/auth_provider.dart';
import 'presentation/login/login_page.dart';
import 'presentation/home/home_page.dart';
import 'presentation/dashboard/calibration_dashboard.dart';
import 'presentation/dashboard/borma_dashboard.dart';
import 'presentation/dashboard/grading_dashboard.dart';
import 'presentation/dashboard/peeling_dashboard.dart';
import 'presentation/dashboard/roasting_dashboard.dart';
import 'presentation/dashboard/shelling_dashboard.dart';
import 'presentation/dashboard/master/master_dashboard.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final isLoggedIn = await authProvider.tryAutoLogin();

  runApp(MyApp(
    authProvider: authProvider,
    isLoggedIn: isLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.authProvider,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false, // -------- FIXED: Bottom bar fully visible
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            elevation: 12,
          ),
          primarySwatch: Colors.blue,
        ),
        home: isLoggedIn
            ? _getDashboardByRole(
                authProvider.userRole?.toLowerCase() ?? '',
                authProvider.userData?['tenant_name'] ?? 'Employee Dashboard',
                authProvider.userData?['tenant_id'],
                authProvider.userData?['employee_id'],
              )
            : LoginPage(),
      ),
    );
  }

  /// Returns dashboard based on employee role
  Widget _getDashboardByRole(
      String role,
      String tenantName,
      int? tenantId,
      int? employeeId,
      ) {

    switch (role) {
      case 'calibration':
        return CalibrationDashboardApp(
          tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,
        );
  

      case 'borma': 
        return BormaDashboardApp(tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,);

      case 'grading':
        return GradingDashboardApp(tenantName: tenantName);

      case 'peeling':
        return PeelingDashboardApp(tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,);

      case 'roasting':
        return RoastingDashboardApp(tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,);

      case 'shelling':
        return ShellingDashboardApp(tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,);

                case 'master':
        return MasterDashboardApp(
          tenantName: tenantName,
          tenantId: tenantId ?? 0,
          employeeId: employeeId ?? 0,
        );

      default:
        return HomePage();
    }
  }
}
