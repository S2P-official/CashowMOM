import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Generate Reports'),
        onPressed: () {},
      ),
    );
  }
}
