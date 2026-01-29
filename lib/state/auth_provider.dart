import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  bool isLoading = true;

  Map<String, dynamic>? userData;

  final StorageService storage = StorageService();
  final ApiService api = ApiService();

  // --- GETTERS ---
  String? get userRole => userData?["role"];
  String? get employeeName => userData?["employee_name"];
  String? get employeeEmail => userData?["email"];
  String? get employeePhone => userData?["phone"];
  String? get tenantName => userData?["tenant_name"];

int? get employeeId => userData?["employee_id"];
int? get tenantId => userData?["tenant_id"];


  // ----------------- AUTO LOGIN -----------------
  Future<bool> tryAutoLogin() async {
    final token = await storage.getToken();

    if (token == null) {
      isLoggedIn = false;
      notifyListeners();
      return false;
    }

    final response = await api.validateToken(token);

    if (response != null) {
      userData = {
        "employee_id": response["employee_id"],
        "employee_name": response["employee_name"],
        "role": response["employee_role"],
        "tenant_id": response["tenant_id"],
        "tenant_name": response["tenant_name"],
        "email": response["employee_email"],
        "phone": response["employee_phone"],
        "department": response["employee_department"],
      };

      isLoggedIn = true;
      notifyListeners();
      return true;
    }

    // invalid token → logout
    await storage.clearToken();
    isLoggedIn = false;
    notifyListeners();
    return false;
  }

  // ----------------- LOGIN -----------------
  Future<bool> login(String username, String password) async {
    try {
      final response = await api.login(username, password);

      if (response != null && response["token"] != null) {
        await storage.saveToken(response["token"]);

        userData = {
          "employee_id": response["employee_id"],
          "employee_name": response["employee_name"],
          "role": response["role"],
          "tenant_id": response["tenant_id"],
          "tenant_name": response["tenant_name"],
          "email": response["email"],
          "phone": response["phone"],
          "department": response["department"],
        };

        isLoggedIn = true;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  // ----------------- LOGOUT -----------------
  Future<void> logout() async {
    await storage.clearToken();
    userData = null;
    isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
  isLoading = true;
  notifyListeners();
  await tryAutoLogin();
  isLoading = false;
  notifyListeners();
}



  bool _welcomeAccepted = false;
  bool get welcomeAccepted => _welcomeAccepted;

  void acceptWelcome() {
    _welcomeAccepted = true;
    notifyListeners();
  }

  void resetWelcome() {
    _welcomeAccepted = false;
  }
}