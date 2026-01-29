/* ===========================
   Calibration Summary Model
   =========================== */
class GradingSummaryResponse {
  final String date;
  final double totalProductionQty;
  final Map<String, double> sizeWiseProductionQty;

  GradingSummaryResponse({
    required this.date,
    required this.totalProductionQty,
    required this.sizeWiseProductionQty,
  });

  factory GradingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return GradingSummaryResponse(
      date: json['date'],
      totalProductionQty:
          (json['totalProductionQty'] as num).toDouble(),
      sizeWiseProductionQty:
          Map<String, double>.from(json['sizeWiseProductionQty']),
    );
  }
}
