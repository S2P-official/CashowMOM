import 'package:flutter/material.dart';

class GradingdashboardPage extends StatelessWidget {
  const GradingdashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grading Dashboard'),
      ),
      body: const Center(
        child: Text(
          'Hello World',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
