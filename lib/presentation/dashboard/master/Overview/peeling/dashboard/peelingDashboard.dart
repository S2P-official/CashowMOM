import 'package:flutter/material.dart';

class PeelingdashboardPage extends StatelessWidget {
  const PeelingdashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peeling Dashboard'),
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
