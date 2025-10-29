# Instrucciones de Configuración - Plataforma OSINT Rediseñada

## 🎨 Cambios Implementados

### 1. Sistema de Seguridad con Encriptación
- ✅ Contraseña al iniciar la aplicación
- ✅ Encriptación automática al cerrar la app
- ✅ Gestión segura de credenciales con `flutter_secure_storage`
- ✅ Primera vez: configuración de contraseña
- ✅ Subsecuentes: desbloqueo con contraseña

### 2. Diseño Minimalista con Degradados
- ✅ Modo oscuro: Degradado azul (0xFF2196F3 → 0xFF1976D2 → 0xFF0D47A1)
- ✅ Modo claro: Degradado naranja (0xFFFFB74D → 0xFFFF9800 → 0xFFF57C00)
- ✅ Contraste optimizado para legibilidad
- ✅ Animaciones suaves y profesionales

### 3. Selector de Idioma con Banderas
- ✅ Ya implementado previamente
- ✅ Banderas visuales: 🇪🇸 Español, 🇬🇧 English

### 4. Nueva Pantalla de Inicio (Home)
- ✅ Descripción de la aplicación
- ✅ Elementos interactivos
- ✅ Dos botones grandes:
  - **Nexo AI**: Chatbot inteligente
  - **Investigaciones**: Gestión de casos
- ✅ Diseño responsive y atractivo

### 5. Chatbot "Nexo"
- ✅ Vista completa del chatbot
- ✅ Interfaz de mensajería moderna
- ✅ Respuestas inteligentes simuladas
- ✅ Avatar de Nexo (placeholder hasta agregar imagen)

### 6. Botón Flotante de Nexo
- ✅ Presente en toda la aplicación
- ✅ Animación de pulso
- ✅ Acceso rápido al chatbot
- ✅ Diseño coherente con el tema

### 7. Docker para ELK Stack
- ✅ Elasticsearch (puerto 9200, 9300)
- ✅ Kibana (puerto 5601)
- ✅ Logstash (puerto 5044, 9600)
- ✅ NER Backend (puerto 8000)
- ✅ Configuración completa en `docker-compose.yml`

## 📋 Pasos para Ejecutar

### 1. Instalar Dependencias

```bash
cd osint_platform
flutter pub get
```

### 2. Agregar Imagen de Nexo (IMPORTANTE)

Coloca la imagen de Nexo en:
```
osint_platform/assets/img/nexo.png
```

**Especificaciones:**
- Formato: PNG o JPG
- Tamaño: 512x512 px o superior
- Fondo: Transparente (recomendado)

Consulta `osint_platform/assets/img/README.md` para más detalles.

### 3. Iniciar Servicios Docker (Opcional)

```bash
# Desde la raíz del proyecto
docker-compose up -d

# Verificar estado
docker-compose ps

# Ver logs
docker-compose logs -f
```

Consulta `README_DOCKER.md` para más información.

### 4. Ejecutar la Aplicación

```bash
cd osint_platform
flutter run
```

### 5. Primera Ejecución

Al iniciar por primera vez:
1. Se te pedirá configurar una contraseña
2. Ingresa una contraseña segura (mínimo 6 caracteres)
3. Confirma la contraseña
4. ¡Listo! La aplicación se desbloqueará

### 6. Ejecuciones Subsecuentes

- Se te pedirá ingresar la contraseña para desbloquear
- Al cerrar la app, los datos se encriptarán automáticamente

## 🎯 Funcionalidades Principales

### Home Rediseñado
- **Ruta:** `/` (pantalla inicial)
- Descripción de la plataforma OSINT
- Acceso rápido a Nexo y a Investigaciones

### Chatbot Nexo
- **Ruta:** `/nexo`
- Asistente inteligente para investigaciones
- Respuestas contextuales sobre OSINT
- Interfaz de chat moderna

### Investigaciones
- **Ruta:** `/investigations`
- Lista de todas las investigaciones
- Crear nuevas investigaciones
- Gestión de casos activos

### Botón Flotante Nexo
- Visible en todas las pantallas (excepto chat de Nexo)
- Acceso rápido al asistente
- Animación de pulso para llamar la atención

## 🔐 Seguridad

### Encriptación
- Contraseñas hasheadas con SHA-256
- Datos encriptados con AES-256
- Almacenamiento seguro con `flutter_secure_storage`

### Recomendaciones
- ✅ Usa una contraseña fuerte y única
- ✅ No compartas tu contraseña
- ✅ En producción, habilita seguridad en ELK Stack

## 🎨 Personalización de Colores

Los colores están definidos en:
```
osint_platform/lib/config/theme.dart
```

### Modo Oscuro (Azul)
```dart
darkPrimary: Color(0xFF2196F3)
darkSecondary: Color(0xFF1976D2)
darkAccent: Color(0xFF42A5F5)
```

### Modo Claro (Naranja)
```dart
lightPrimary: Color(0xFFFF9800)
lightSecondary: Color(0xFFFF6F00)
lightAccent: Color(0xFFFFB74D)
```

## 📁 Estructura de Archivos Nuevos

```
osint_platform/
├── lib/
│   ├── config/
│   │   └── theme.dart (actualizado con degradados)
│   ├── screens/
│   │   ├── auth/
│   │   │   └── lock_screen.dart (nueva)
│   │   ├── home/
│   │   │   └── home_screen_redesigned.dart (nueva)
│   │   └── nexo/
│   │       └── nexo_chat_screen.dart (nueva)
│   ├── services/
│   │   └── encryption_service.dart (nueva)
│   └── widgets/
│       └── common/
│           └── nexo_floating_button.dart (nueva)
├── assets/
│   └── img/
│       ├── README.md (nueva)
│       └── [nexo.png] (agregar manualmente)

docker-compose.yml (nuevo)
logstash/
├── config/
│   └── logstash.yml (nuevo)
└── pipeline/
    └── logstash.conf (nuevo)
.env.example (nuevo)
README_DOCKER.md (nuevo)
```

## 🐛 Troubleshooting

### Error: "App is locked"
- Ingresa la contraseña correcta
- Si olvidaste la contraseña, reinstala la app (perderás datos)

### Imagen de Nexo no aparece
- Verifica que la imagen esté en `assets/img/nexo.png`
- Ejecuta `flutter pub get`
- Reinicia la aplicación

### Docker no inicia
- Verifica que Docker esté corriendo
- Revisa los puertos (9200, 5601, 5044)
- Consulta `README_DOCKER.md`

### Error de compilación
```bash
# Limpiar caché
flutter clean
flutter pub get
flutter run
```

## 📞 Soporte

Para problemas técnicos:
1. Revisa los logs de la aplicación
2. Verifica que todas las dependencias estén instaladas
3. Consulta la documentación de Flutter

## 🚀 Próximos Pasos

1. Agregar la imagen real de Nexo
2. Integrar Nexo con un backend de IA real
3. Configurar ELK Stack en producción con seguridad
4. Implementar más funcionalidades de OSINT

---

**Nota:** Este es un proyecto de investigación OSINT con fines educativos y profesionales. Asegúrate de cumplir con todas las leyes y regulaciones aplicables al usar esta plataforma.
