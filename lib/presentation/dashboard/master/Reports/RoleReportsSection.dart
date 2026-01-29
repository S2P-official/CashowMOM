import 'package:factory_app/presentation/dashboard/master/Overview/calibration/CalibrationApiService.dart';
import 'package:factory_app/presentation/dashboard/master/Overview/calibration/CalibrationSummaryResponse.dart';
import 'package:flutter/material.dart';

class RoleReportsSection extends StatelessWidget {
  final bool isTablet;
  final int tenantId;

  const RoleReportsSection({
    required this.isTablet,
    required this.tenantId,
  });

  static const roles = [
    {'name': 'Calibration', 'icon': Icons.tune},
    {'name': 'Roasting', 'icon': Icons.local_fire_department},
    {'name': 'Shelling', 'icon': Icons.settings},
    {'name': 'Borma', 'icon': Icons.precision_manufacturing},
    {'name': 'Peeling', 'icon': Icons.layers_clear},
    {'name': 'Grading', 'icon': Icons.rule},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today Role-wise Reports',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: roles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isTablet ? 1.5 : 1.25,
          ),
          itemBuilder: (_, index) {
            final role = roles[index];

            if (role['name'] == 'Calibration') {
              return FutureBuilder<CalibrationSummaryResponse>(
                future: CalibrationApiService()
                    .fetchTodaySummary(tenantId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!snapshot.hasData || snapshot.hasError) {
                    return _RoleCard(
                      title: 'Calibration',
                      icon: Icons.tune,
                      isTablet: isTablet,
                    );
                  }

                  return _CalibrationRoleCard(
                    data: snapshot.data!,
                    icon: Icons.tune,
                    isTablet: isTablet,
                  );
                },
              );
            }

            return _RoleCard(
              title: role['name'] as String,
              icon: role['icon'] as IconData,
              isTablet: isTablet,
            );
          },
        ),
      ],
    );
  }
}



class _CalibrationRoleCard extends StatelessWidget {
  final CalibrationSummaryResponse data;
  final IconData icon;
  final bool isTablet;

  const _CalibrationRoleCard({
    required this.data,
    required this.icon,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final entries = data.sizeWiseProductionQty.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final visibleEntries = entries.take(3).toList();
    final hasMore = entries.length > 3;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: isTablet ? 36 : 32,
            ),

            const SizedBox(height: 8),

            Text(
              'Calibration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 15 : 14,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Total Production',
              style: TextStyle(
                fontSize: isTablet ? 12 : 11,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green.shade200,
                ),
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

            const SizedBox(height: 12),

            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final e in visibleEntries)
                  _sizeChip(e.key, e.value),
                if (hasMore)
                  Text(
                    '...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeChip(String size, double qty) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.shade200,
        ),
      ),
      child: Text(
        '$size ${qty.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.green.shade800,
        ),
      ),
    );
  }
}




class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isTablet;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.isTablet,
    // ignore: unused_element_parameter
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isTablet ? 40 : 34,
                color: Colors.blue,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'View Report',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
