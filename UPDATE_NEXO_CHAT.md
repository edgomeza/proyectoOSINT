# Actualización Rápida para Nexo Chat Screen

El archivo `lib/screens/nexo/nexo_chat_screen.dart` necesita ser actualizado para usar el widget `NexoAvatar` en lugar de los íconos.

## Cambios a Realizar

### 1. Agregar el import al inicio del archivo:

```dart
import '../../widgets/common/nexo_avatar.dart';
```

### 2. Reemplazar los 4 íconos de Nexo:

**Ubicación aproximada Línea 200-210** (En `_buildHeader`):
```dart
// ANTES:
child: const Icon(
  Icons.smart_toy_outlined,
  size: 28,
  color: Colors.white,
),

// DESPUÉS:
child: const NexoAvatar(size: 28),
```

**Ubicación aproximada Línea 270-280** (En `_buildEmptyState`):
```dart
// ANTES:
child: const Icon(
  Icons.smart_toy_outlined,
  size: 64,
  color: Colors.white,
),

// DESPUÉS:
child: const NexoAvatar(size: 64),
```

**Ubicación aproximada Línea 315-325** (En `_buildMessageBubble` para mensajes de Nexo):
```dart
// ANTES:
child: const Icon(
  Icons.smart_toy_outlined,
  size: 20,
  color: Colors.white,
),

// DESPUÉS:
child: const NexoAvatar(size: 20),
```

**Ubicación aproximada Línea 387-397** (En `_buildTypingIndicator`):
```dart
// ANTES:
child: const Icon(
  Icons.smart_toy_outlined,
  size: 20,
  color: Colors.white,
),

// DESPUÉS:
child: const NexoAvatar(size: 20),
```

## Verificación

Busca en el archivo por `Icons.smart_toy_outlined` y deberías encontrar exactamente 4 ocurrencias. Reemplaza cada una con `NexoAvatar` del tamaño correspondiente.

## Comando Rápido (Opcional)

Si prefieres hacerlo manualmente con búsqueda y reemplazo:

1. Abre `lib/screens/nexo/nexo_chat_screen.dart`
2. Busca: `Icons.smart_toy_outlined`
3. Para cada ocurrencia, reemplaza el bloque completo de `Icon(...)` con `NexoAvatar(size: XX)`

## Resultado

Después de estos cambios, el chatbot de Nexo mostrará la imagen real de Nexo en lugar del ícono de robot.
