/* ===========================
   Calibration Summary Model
   =========================== */
class BormaSummaryResponse {
  final String date;
  final double totalProductionQty;
  final Map<String, double> sizeWiseProductionQty;

  BormaSummaryResponse({
    required this.date,
    required this.totalProductionQty,
    required this.sizeWiseProductionQty,
  });

  factory BormaSummaryResponse.fromJson(Map<String, dynamic> json) {
    return BormaSummaryResponse(
      date: json['date'],
      totalProductionQty:
          (json['totalProductionQty'] as num).toDouble(),
      sizeWiseProductionQty:
          Map<String, double>.from(json['sizeWiseProductionQty']),
    );
  }
}
