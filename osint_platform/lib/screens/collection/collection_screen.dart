import 'package:flutter/material.dart';

class CollectionScreen extends StatelessWidget {
  final String investigationId;

  const CollectionScreen({
    super.key,
    required this.investigationId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recopilación'),
      ),
      body: Center(
        child: Text('Collection Screen - ID: $investigationId'),
      ),
    );
  }
}
