import 'package:flutter/material.dart';

class ProcessingScreen extends StatelessWidget {
  final String investigationId;

  const ProcessingScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesamiento'),
      ),
      body: Center(
        child: Text('Processing Screen - ID: $investigationId'),
      ),
    );
  }
}
