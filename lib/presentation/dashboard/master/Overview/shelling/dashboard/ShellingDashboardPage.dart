import 'package:flutter/material.dart';

class ShellingDashboardPage extends StatelessWidget {
  const ShellingDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shelling Dashboard')),
      body: const Center(
        child: Text('Shelling detailed reports here'),
      ),
    );
  }
}
