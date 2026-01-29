/* ===========================
   Calibration API Service
   =========================== */
import 'dart:convert';

import 'package:factory_app/presentation/dashboard/master/Overview/borma/borma_summary_response.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BormaApiService {
  static const String baseUrl = 'http://192.168.29.215:8080/api';

  Future<BormaSummaryResponse> fetchTodaySummary(int tenantId) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final url =
        '$baseUrl/calibration-reports/tenant/$tenantId/date/$today';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return BormaSummaryResponse.fromJson(
        jsonDecode(response.body),
      );
    } else {
      throw Exception('Failed to load calibration summary');
    }
  }
}
