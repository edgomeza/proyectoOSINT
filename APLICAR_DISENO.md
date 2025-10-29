# Instrucciones para Aplicar el Nuevo Diseño a Todas las Vistas

## ✅ Ya Completado
- ✅ Sistema de encriptación
- ✅ Home rediseñada
- ✅ Chatbot Nexo
- ✅ Botón flotante de Nexo con imagen (assets/img/nexo.png)
- ✅ Tema con degradados
- ✅ Widgets comunes (ModernAppBar, AppLayoutWrapper)

## 📝 Pendiente: Aplicar a Vistas Restantes

### 1. Planning Screen
**Archivo:** `lib/screens/planning/planning_screen.dart`

**Cambios a aplicar:**

```dart
// 1. Importar widgets nuevos al inicio
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';

// 2. Reemplazar el Scaffold actual con AppLayoutWrapper
// ANTES:
return Scaffold(
  appBar: AppBar(...),
  body: ...,
  drawer: NavigationDrawer(...),
);

// DESPUÉS:
return AppLayoutWrapper(
  appBar: ModernAppBar(
    title: 'Planificación',
    subtitle: investigation?.name ?? '',
  ),
  child: SingleChildScrollView(
    child: ..., // Tu contenido existente
  ),
);
```

**Ajustes adicionales:**
- Eliminar el `drawer: NavigationDrawer()` (el botón de Nexo lo reemplaza)
- Envolver el contenido en un `Padding(padding: EdgeInsets.all(16))`
- Los colores ya se ajustarán automáticamente por el AppLayoutWrapper

---

### 2. Collection Screen
**Archivo:** `lib/screens/collection/collection_screen.dart`

**Cambios a aplicar:**

```dart
// 1. Importar widgets nuevos
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';

// 2. Reemplazar Scaffold
return AppLayoutWrapper(
  appBar: ModernAppBar(
    title: 'Recopilación',
    subtitle: investigation?.name ?? '',
  ),
  child: // Tu contenido existente,
);
```

---

### 3. Processing Screen
**Archivo:** `lib/screens/processing/processing_screen_redesigned.dart`

**Cambios a aplicar:**

```dart
// 1. Importar
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';

// 2. Reemplazar Scaffold
return AppLayoutWrapper(
  appBar: ModernAppBar(
    title: 'Procesamiento',
    subtitle: investigation?.name ?? '',
  ),
  child: // Tu contenido existente,
);
```

---

### 4. Analysis Screen
**Archivo:** `lib/screens/analysis/analysis_screen_redesigned.dart`

**Cambios a aplicar:**

```dart
// 1. Importar
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';

// 2. Reemplazar Scaffold
return AppLayoutWrapper(
  appBar: ModernAppBar(
    title: 'Análisis',
    subtitle: investigation?.name ?? '',
  ),
  child: // Tu contenido existente,
);
```

---

### 5. Reports Screen
**Archivo:** `lib/screens/reports/reports_screen.dart`

**Cambios a aplicar:**

```dart
// 1. Importar
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';

// 2. Reemplazar Scaffold
return AppLayoutWrapper(
  appBar: ModernAppBar(
    title: 'Informes',
    subtitle: investigation?.name ?? '',
  ),
  child: // Tu contenido existente,
);
```

---

### 6. Nexo Chat Screen - Actualizar Íconos
**Archivo:** `lib/screens/nexo/nexo_chat_screen.dart`

Reemplazar todas las ocurrencias de:
```dart
const Icon(
  Icons.smart_toy_outlined,
  size: XX,
  color: Colors.white,
)
```

Con:
```dart
ClipOval(
  child: Image.asset(
    'assets/img/nexo.png',
    width: XX,
    height: XX,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return const Icon(
        Icons.smart_toy_outlined,
        size: XX,
        color: Colors.white,
      );
    },
  ),
)
```

**Ubicaciones específicas:**
- Línea ~207: size: 28 → width: 28, height: 28
- Línea ~277: size: 64 → width: 64, height: 64
- Línea ~321: size: 20 → width: 20, height: 20
- Línea ~393: size: 20 → width: 20, height: 20

---

## 🎨 Características del Nuevo Diseño

### App Layout Wrapper
El `AppLayoutWrapper` proporciona:
- Degradado de fondo automático (azul oscuro / naranja claro)
- Botón flotante de Nexo automático
- Transiciones suaves entre temas

### Modern App Bar
El `ModernAppBar` proporciona:
- Diseño minimalista y profesional
- Title y subtitle
- Acciones predeterminadas (ELK, idioma, tema)
- Fondo transparente para mostrar el degradado

### Botón Flotante Nexo
- Se muestra automáticamente en todas las vistas
- Animación de pulso
- Usa la imagen real de Nexo (assets/img/nexo.png)

---

## 🚀 Pasos para Aplicar

### Opción 1: Manual (Recomendado para entender los cambios)
1. Abre cada archivo mencionado arriba
2. Agrega los imports necesarios
3. Reemplaza el Scaffold con AppLayoutWrapper
4. Reemplaza el AppBar con ModernAppBar
5. Guarda y ejecuta `flutter run`

### Opción 2: Buscar y Reemplazar (Rápido)
Para cada archivo, busca el patrón del Scaffold y reemplázalo con el nuevo código.

**Ejemplo en VSCode:**
1. Ctrl+H (Find and Replace)
2. Buscar: `return Scaffold(`
3. Reemplazar con: `return AppLayoutWrapper(`
4. Luego ajusta el appBar y otros detalles manualmente

---

## 🔍 Verificación

Después de aplicar los cambios, verifica:

1. ✅ Cada vista tiene el degradado de fondo correcto
2. ✅ El botón flotante de Nexo aparece en todas las vistas
3. ✅ Los colores cambian correctamente al cambiar de tema
4. ✅ No hay errores de compilación
5. ✅ La navegación funciona correctamente
6. ✅ La imagen de Nexo se muestra (no el ícono de robot)

---

## 📸 Resultado Esperado

### Modo Oscuro
- Fondo: Degradado azul (0xFF0A0E27 → 0xFF1A1F3A → 0xFF1E3A5F)
- Textos: Blanco con buen contraste
- Botón Nexo: Degradado azul brillante

### Modo Claro
- Fondo: Degradado naranja claro (0xFFFFF8F0 → 0xFFFFEEDD → 0xFFFFE4CC)
- Textos: Negro/gris oscuro con buen contraste
- Botón Nexo: Degradado naranja

---

## ⚠️ Problemas Comunes

### La imagen de Nexo no aparece
- Verifica que el archivo esté en `assets/img/nexo.png`
- Ejecuta `flutter pub get`
- Reinicia la app (hot restart, no hot reload)

### Colores no cambian
- Asegúrate de usar `AppLayoutWrapper` no `Scaffold`
- Verifica que no estés sobreescribiendo colores con valores fijos

### Botón flotante no aparece
- Verifica que `showNexoButton: true` en AppLayoutWrapper
- Asegúrate de no tener otro FloatingActionButton que lo tape

---

## 💡 Tips

- Si tienes un FloatingActionButton propio, pásalo como parámetro:
  ```dart
  AppLayoutWrapper(
    floatingActionButton: YourFAB(),
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    child: ...
  )
  ```

- Para ocultar el botón de Nexo en una vista específica:
  ```dart
  AppLayoutWrapper(
    showNexoButton: false,
    child: ...
  )
  ```

- Para agregar acciones custom al AppBar:
  ```dart
  ModernAppBar(
    title: 'Título',
    actions: [
      IconButton(...),
      IconButton(...),
    ],
  )
  ```

---

¿Necesitas ayuda? Revisa los archivos de ejemplo:
- `lib/screens/home/home_screen.dart` (ya actualizado)
- `lib/screens/home/home_screen_redesigned.dart` (ejemplo completo)
- `lib/screens/nexo/nexo_chat_screen.dart` (ejemplo con custom header)
