/* ===========================
   Calibration Summary Model
   =========================== */
class PeelingSummaryResponse {
  final String date;
  final double totalProductionQty;
  final Map<String, double> sizeWiseProductionQty;

  PeelingSummaryResponse({
    required this.date,
    required this.totalProductionQty,
    required this.sizeWiseProductionQty,
  });

  factory PeelingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return PeelingSummaryResponse(
      date: json['date'],
      totalProductionQty:
          (json['totalProductionQty'] as num).toDouble(),
      sizeWiseProductionQty:
          Map<String, double>.from(json['sizeWiseProductionQty']),
    );
  }
}
