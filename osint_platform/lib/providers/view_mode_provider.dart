import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ViewMode {
  simple, // Vista simplificada (foco cognitivo)
  detailed, // Vista detallada (control completo)
}

// Provider para el modo de vista (simple/detallada)
final viewModeProvider = StateProvider<ViewMode>((ref) {
  return ViewMode.simple; // Por defecto vista simplificada
});

// Provider para toggle del modo de vista
final viewModeToggleProvider = Provider<Function>((ref) {
  return () {
    final currentMode = ref.read(viewModeProvider);
    ref.read(viewModeProvider.notifier).state =
        currentMode == ViewMode.simple ? ViewMode.detailed : ViewMode.simple;
  };
});
