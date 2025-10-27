import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  final String investigationId;

  const AnalysisScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis'),
      ),
      body: Center(
        child: Text('Analysis Screen - ID: $investigationId'),
      ),
    );
  }
}
