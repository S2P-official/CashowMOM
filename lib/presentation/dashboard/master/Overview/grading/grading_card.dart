import 'package:factory_app/presentation/dashboard/master/Overview/grading/grading_summary_response.dart';
import 'package:flutter/material.dart';

class GradingRoleCard extends StatelessWidget {
  final GradingSummaryResponse data;
  final IconData icon;
  final bool isTablet;
  final VoidCallback onTap;

  const GradingRoleCard({
    super.key,
    required this.data,
    required this.icon,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.sizeWiseProductionQty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 20 : 14,
                    vertical: isTablet ? 16 : 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: Colors.blue,
                        size: isTablet ? 36 : 32,
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Grading',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data.totalProductionQty.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: isTablet ? 22 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: entries.take(3).map(
                          (e) {
                            return Chip(
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              label: Text(
                                '${e.key} ${e.value.toStringAsFixed(0)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.green.shade50,
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
