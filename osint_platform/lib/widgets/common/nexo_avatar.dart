import 'package:flutter/material.dart';

class NexoAvatar extends StatelessWidget {
  final double size;
  final bool withGradient;
  final bool circular;

  const NexoAvatar({
    super.key,
    this.size = 40,
    this.withGradient = false,
    this.circular = true,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      'assets/img/nexo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.smart_toy_outlined,
          size: size * 0.8,
          color: Colors.white,
        );
      },
    );

    if (circular) {
      return ClipOval(child: imageWidget);
    }

    return imageWidget;
  }
}
