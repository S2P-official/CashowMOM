/* ===========================
   Calibration Summary Model
   =========================== */
class CalibrationSummaryResponse {
  final String date;
  final double totalProductionQty;
  final Map<String, double> sizeWiseProductionQty;

  CalibrationSummaryResponse({
    required this.date,
    required this.totalProductionQty,
    required this.sizeWiseProductionQty,
  });

  factory CalibrationSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CalibrationSummaryResponse(
      date: json['date'],
      totalProductionQty:
          (json['totalProductionQty'] as num).toDouble(),
      sizeWiseProductionQty:
          Map<String, double>.from(json['sizeWiseProductionQty']),
    );
  }
}
