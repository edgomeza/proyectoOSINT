# Plataforma OSINT - Frontend Flutter

Una plataforma local de inteligencia de código abierto (OSINT) diseñada para ayudar a investigadores a gestionar eficientemente grandes volúmenes de información.

## Características Implementadas

### 🎨 Diseño Moderno
- **Tema Dark/Light**: Soporte completo para modo oscuro y claro con toggle dinámico
- **Material Design 3**: Interfaz moderna y consistente
- **Google Fonts**: Tipografía Inter para una apariencia profesional
- **Animaciones Fluidas**: Implementadas con animate_do de Fernando Herrera
- **Diseño Responsivo**: Adaptable a diferentes tamaños de pantalla

### 🧭 Navegación
- **GoRouter**: Sistema de navegación robusto y declarativo (OBLIGATORIO según especificaciones)
- **Rutas Tipadas**: Navegación type-safe con parámetros
- **Deep Linking**: Soporte para enlaces profundos

### 🔄 Gestión de Estado
- **Riverpod**: State management moderno y eficiente (según especificaciones)
- **Providers**:
  - `investigationsProvider`: Gestión de investigaciones
  - `dataFormsProvider`: Gestión de formularios de datos
  - `viewModeProvider`: Control de vista simple/detallada
  - `themeModeProvider`: Control de tema dark/light

### 📱 Pantallas Implementadas

#### 1. Home Screen (Centro de Control) ✅
- **Vista Dual**:
  - **Vista Simplificada**: Enfocada en la investigación activa y acciones rápidas
  - **Vista Detallada**: Grid completo con todas las investigaciones y estadísticas
- **Características**:
  - Toggle entre vistas con animaciones
  - Cards animadas de investigaciones
  - Acciones rápidas contextuales
  - Estadísticas en tiempo real
  - Diseño moderno y atractivo

#### 2. Planning Screen (Planificación) ✅
- **Formulario Dinámico**: Campos para nombre, descripción, objetivos y preguntas clave
- **Validación**: Sistema de validación de formularios
- **Límites Cognitivos**: Máximo 5 objetivos y 5 preguntas
- **Animaciones**: Transiciones suaves con animate_do

## 🚀 Instalación y Uso

### Prerequisitos
- Flutter SDK (>= 3.9.2)
- Dart SDK

### Instalación

1. **Instalar dependencias**
```bash
flutter pub get
```

2. **Ejecutar la aplicación**
```bash
flutter run
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State Management
  go_router: ^14.2.7          # Navigation (OBLIGATORIO)
  animate_do: ^3.3.4          # Animations (Fernando Herrera)
  google_fonts: ^6.2.1        # Typography
  intl: ^0.19.0               # Internationalization
  uuid: ^4.5.1                # UUID Generation
```

## 🎯 Estructura del Proyecto

```
lib/
├── config/
│   ├── router.dart         # GoRouter configuration
│   └── theme.dart          # Dark/Light themes
├── models/
│   ├── investigation.dart
│   ├── investigation_phase.dart
│   ├── data_form.dart
│   └── data_form_status.dart
├── providers/              # Riverpod providers
│   ├── investigations_provider.dart
│   ├── data_forms_provider.dart
│   ├── theme_provider.dart
│   └── view_mode_provider.dart
├── screens/
│   ├── home/              # ✅ Implementada
│   ├── planning/          # ✅ Implementada
│   ├── collection/        # Placeholder
│   ├── processing/        # Placeholder
│   ├── analysis/          # Placeholder
│   └── reports/           # En mantenimiento
├── widgets/
│   ├── common/            # Widgets reutilizables
│   └── cards/             # Card components
└── main.dart
```

## 🎨 Paleta de Colores

### Dark Mode
- **Primary**: #6C63FF (Púrpura vibrante)
- **Secondary**: #00D9FF (Cyan brillante)
- **Background**: #0A0E27 (Azul oscuro profundo)

### Light Mode
- **Primary**: #6C63FF (Púrpura vibrante)
- **Secondary**: #00B8D4 (Cyan)
- **Background**: #F8F9FA (Gris claro)

## 🔧 Próximos Pasos

1. ⏳ **Collection Screen**: Formularios dinámicos de recopilación
2. ⏳ **Processing Screen**: Sistema de priorización inteligente
3. ⏳ **Analysis Screen**: Integración con Kibana
4. ⏳ **Reports Screen**: Generación de informes
5. ⏳ **Backend**: API REST con Python Flask/FastAPI
6. ⏳ **Database**: SQLite para metadatos
7. ⏳ **Docker**: Integración con ELK Stack

## 📝 Notas Técnicas

- **Material Design 3** con `useMaterial3: true`
- **Animaciones optimizadas** con animate_do
- **Gestión cognitiva**: Máximo 7 elementos por vista
- **Datos mock** incluidos para desarrollo
- **Type-safe navigation** con GoRouter

---

**Desarrollado con Flutter** 💙 | **Usando GoRouter, Riverpod y animate_do**
