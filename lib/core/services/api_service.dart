import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // -------------------------------
  // BASE URL (single source)
  // -------------------------------
  final String baseUrl = "http://192.168.29.215:8080/api";

  // -------------------------------
  // COMMON HEADERS
  // -------------------------------
  Map<String, String> _headers({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ---------------------------------------------------
  // LOGIN REQUEST
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> login(
    String identifier,
    String password,
  ) async {
    try {
      final url = Uri.parse("$baseUrl/employees/login");

      final response = await http.post(
        url,
        headers: _headers(),
        body: jsonEncode({"identifier": identifier, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------
  // TOKEN VALIDATION
  // ---------------------------------------------------
  Future<Map<String, dynamic>?> validateToken(String token) async {
    try {
      final url = Uri.parse("$baseUrl/employees/validate");

      final response = await http.get(url, headers: _headers(token: token));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["valid"] == true) {
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ---------------------------------------------------
  // FETCH REPORTS BY TENANT
  // ---------------------------------------------------
  Future<List<dynamic>?> fetchReportsByTenant(int tenantId) async {
    try {
      final url = Uri.parse("$baseUrl/calibration-reports/tenant/$tenantId");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> submitCalibrationTasks({
    required int tenantId,
    required int employeeId,
    required List<Map<String, dynamic>> tasks,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl/calibration-reports/tenant/$tenantId/employee/$employeeId",
      );

      final body = tasks.map((task) {
        final qty = task["productionQty"] as double;

        return {
          "date": task["date"].split("T")[0],
          "lotMark": "${task["lot"]}-${task["mark"]}",
          "origin": task["origin"],
          "perBagWeight": 50.0,
          "sizeRange": task["size"],
          "noOfBags": (task["totalBags"] as int).toDouble(),
          "productionQty": qty,
          "totalProductionMts": qty / 2,
          "percentage": task["percentage"],
          "countPerKg": task["countPerKg"],
          "tenant": {"id": tenantId},
          "employee": {"id": employeeId},
        };
      }).toList();

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>?> fetchPendingShellingReports({
    required int tenantId,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl/shelling-reports/tenant/$tenantId/pending",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ApiService.dart

  Future<List<dynamic>?> fetchPendingBormaReports({
    required int tenantId,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl/shelling-reports/tenant/$tenantId/pending",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<dynamic>?> fetchPendingCalibrationReports({
    required int tenantId,
  }) async {
    try {
      final url = Uri.parse(
        "$baseUrl/calibration-reports/tenant/$tenantId/pending",
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
  Future<bool> submitRoastingReport({
  required int tenantId,
  required int employeeId,
  required Map<String, dynamic> report,
  required String cookingTime,
  required String dryMoisture,
  required String roaster,
  required String tempVn,
  required String roastDuration,
  required String soackingMoisture,
  required String moistureAfterRoast,
  required String totalRoasted,
  required String cuttingLine,
}) async {
  try {
    final postUrl = Uri.parse(
      "$baseUrl/roasting-reports/tenant/$tenantId/employee/$employeeId",
    );

    final patchUrl = Uri.parse(
      "$baseUrl/calibration-reports/${report["id"]}",
    );

    final postPayload = {
      "lotMark": report["lotMark"],
      "origin": report["origin"],
      "sizeRange": report["sizeRange"],
      "noOfBags": report["noOfBags"],
      "productionQty": report["productionQty"],
      "percentage": report["percentage"],
      "countPerKg": report["countPerKg"],
      "totalProductionMts": report["totalProductionMts"],

      // Cooking
      "cookingTime": cookingTime,
      "dryRcnMoisture": double.tryParse(dryMoisture),

      // Roasting
      "roasterName": roaster,
      "tempForVnMachine": tempVn,
      "roastingDuration": roastDuration,
      "soackingMoisture": soackingMoisture,
      "moistureAfterRoasting": moistureAfterRoast,
      "totalRoasted": totalRoasted,

      // Extra
      "cuttingLine": cuttingLine,

      "tenant": {"id": tenantId},
      "employee": {"id": employeeId},
    };

    final postResponse = await http.post(
      postUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(postPayload),
    );

    if (postResponse.statusCode == 200 ||
        postResponse.statusCode == 201) {
      final patchResponse = await http.patch(
        patchUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": "Completed"}),
      );

      return patchResponse.statusCode == 200;
    }

    return false;
  } catch (_) {
    return false;
  }
}


Future<List<Map<String, dynamic>>> fetchCookingReports({
  required int tenantId,
  required int employeeId,
}) async {
  try {
    final url = Uri.parse(
      "$baseUrl/roasting-reports/tenant/$tenantId/employee/$employeeId",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);

    final reports = data.map<Map<String, dynamic>>((report) {
      String lot = '';
      if (report["lotMark"] != null &&
          report["lotMark"].toString().contains("-")) {
        lot = report["lotMark"].split("-")[0];
      }

      return {
        "id": report["id"],
        "lot": lot,
        "date": report["date"] ?? '',
        "origin": report["origin"] ?? '',
        "size": report["sizeRange"] ?? '',
        "totalBags": report["noOfBags"]?.toInt() ?? 0,
        "productionQty": report["productionQty"] ?? 0,
        "percentage": report["percentage"] ?? 0,
        "countPerKg": report["countPerKg"] ?? 0,
        "status": report["status"] ?? '',

        // Cooking
        "cookingTime": report["cookingTime"] ?? '',
        "dryRcnMoisture": report["dryRcnMoisture"] ?? '',

        // Roasting
        "roasterName": report["roasterName"] ?? '',
        "tempForVnMachine": report["tempForVnMachine"] ?? '',
        "roastingDuration": report["roastingDuration"] ?? '',
        "soackingMoisture": report["soackingMoisture"] ?? '',
        "moistureAfterRoasting": report["moistureAfterRoasting"] ?? '',
        "totalRoasted": report["totalRoasted"] ?? '',
        "cuttingLine": report["cuttingLine"] ?? '',
      };
    }).toList();

    /// sort latest first
    reports.sort((a, b) {
      final ad = DateTime.tryParse(a["date"] ?? '') ?? DateTime(1970);
      final bd = DateTime.tryParse(b["date"] ?? '') ?? DateTime(1970);
      return bd.compareTo(ad);
    });

    return reports;
  } catch (_) {
    return [];
  }
}



Future<List<Map<String, dynamic>>> fetchShellingReports({
  required int tenantId,
  required int employeeId,
}) async {
  try {
    final url = Uri.parse(
      "$baseUrl/shelling-reports/tenant/$tenantId/employee/$employeeId",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);

    final reports = data.map<Map<String, dynamic>>((report) {
      String lot = '';
      if (report["lotMark"] != null &&
          report["lotMark"].toString().contains("-")) {
        lot = report["lotMark"].split("-")[0];
      }

      return {
        "id": report["id"],
        "lot": lot,
        "date": report["date"] ?? '',
        "origin": report["origin"] ?? '',
        "size": report["sizeRange"] ?? '',
        "totalBags": report["noOfBags"]?.toInt() ?? 0,
        "productionQty": report["productionQty"] ?? 0,
        "percentage": report["percentage"] ?? 0,
        "countPerKg": report["countPerKg"] ?? 0,
        "status": report["status"] ?? '',

        // Cooking
        "cookingTime": report["cookingTime"] ?? '',
        "dryRcnMoisture": report["dryRcnMoisture"] ?? '',

        // Roasting
        "roasterName": report["roasterName"] ?? '',
        "tempForVnMachine": report["tempForVnMachine"] ?? '',
        "roastingDuration": report["roastingDuration"] ?? '',
        "soackingMoisture": report["soackingMoisture"] ?? '',
        "moistureAfterRoasting": report["moistureAfterRoasting"] ?? '',
        "totalRoasted": report["totalRoasted"] ?? '',
        "cuttingLine": report["cuttingLine"] ?? '',
      };
    }).toList();

    // sort latest first
    reports.sort((a, b) {
      final ad = DateTime.tryParse(a["date"] ?? '') ?? DateTime(1970);
      final bd = DateTime.tryParse(b["date"] ?? '') ?? DateTime(1970);
      return bd.compareTo(ad);
    });

    return reports;
  } catch (_) {
    return [];
  }
}


Future<List<Map<String, dynamic>>> fetchRoastingReports({
  required int tenantId,
}) async {
  try {
    final url = Uri.parse("$baseUrl/roasting-reports/tenant/$tenantId/pending");

    final response = await http.get(url);
    if (response.statusCode != 200) return [];

    final List<dynamic> data = jsonDecode(response.body);

    // Sort newest first
    data.sort((a, b) {
      final ad = DateTime.tryParse(a["date"] ?? '') ?? DateTime(1970);
      final bd = DateTime.tryParse(b["date"] ?? '') ?? DateTime(1970);
      return bd.compareTo(ad);
    });

    return List<Map<String, dynamic>>.from(data);
  } catch (_) {
    return [];
  }
}

Future<bool> submitShellingReport({
  required int tenantId,
  required int employeeId,
  required Map<String, dynamic> report,
  required String wholes,
  required String broken,
  required String rejection,
  required String uncut,
  required String partly,
}) async {
  final postUrl = Uri.parse("$baseUrl/shelling-reports/tenant/$tenantId/employee/$employeeId");
  final patchUrl = Uri.parse("$baseUrl/roasting-reports/${report["id"]}");

  final payload = {
    "lotMark": report["lotMark"],
    "origin": report["origin"],
    "sizeRange": report["sizeRange"],
    "noOfBags": report["noOfBags"],
    "productionQty": report["productionQty"],
    "percentage": report["percentage"],
    "countPerKg": report["countPerKg"],
    "totalProductionMts": report["totalProductionMts"],
    "cookingTime": report["cookingTime"],
    "dryRcnMoisture": report["dryRcnMoisture"],
    "roasterName": report["roasterName"],
    "tempForVnMachine": report["tempForVnMachine"],
    "roastingDuration": report["roastingDuration"],
    "soackingMoisture": report["soackingMoisture"],
    "moistureAfterRoasting": report["moistureAfterRoasting"],
    "totalRoasted": report["totalRoasted"],

    "wholes": double.tryParse(wholes),
    "broken": double.tryParse(broken),
    "rejection": double.tryParse(rejection),
    "uncut": double.tryParse(uncut),
    "partly": double.tryParse(partly),

    "tenant": {"id": tenantId},
    "employee": {"id": employeeId},
  };

  try {
    final postRes = await http.post(
      postUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (postRes.statusCode != 200 && postRes.statusCode != 201) return false;

    final patchRes = await http.patch(
      patchUrl,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"status": "Completed"}),
    );

    return patchRes.statusCode == 200;
  } catch (_) {
    return false;
  }
}

  Future<dynamic> fetchReportsByTenantAndDate(int tenantId, String formattedDate) async {}

}
