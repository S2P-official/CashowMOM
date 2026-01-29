/* ===========================
   Calibration Summary Model
   =========================== */
class ShellingSummaryResponse {
  final String date;
  final double wholes;
  final Map<String, double> broken;

  ShellingSummaryResponse({
    required this.date,
    required this.wholes,
    required this.broken,
  });

  factory ShellingSummaryResponse.fromJson(Map<String, dynamic> json) {
    return ShellingSummaryResponse(
      date: json['date'],
      wholes:
          (json['wholes'] as num).toDouble(),
      broken:
          Map<String, double>.from(json['broken']),
    );
  }
}
