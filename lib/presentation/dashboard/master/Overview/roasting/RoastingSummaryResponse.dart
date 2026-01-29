/* ===========================
   Calibration Summary Model
   =========================== */
class RoastingSummaryResponse {
  final String date;
  final double totalRoastedSum;
  final Map<String, double> cuttingLineWiseTotalRoasted;

  RoastingSummaryResponse({
    required this.date,
    required this.totalRoastedSum,
    required this.cuttingLineWiseTotalRoasted,
  });

  factory RoastingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return RoastingSummaryResponse(
      date: json['date'],
      totalRoastedSum:
          (json['totalRoastedSum'] as num).toDouble(),
      cuttingLineWiseTotalRoasted:
          Map<String, double>.from(json['cuttingLineWiseTotalRoasted']),
    );
  }
}
