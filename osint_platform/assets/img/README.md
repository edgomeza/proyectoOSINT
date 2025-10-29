# Assets - Imágenes

## Imagen de Nexo

**IMPORTANTE:** Por favor, agrega la imagen de Nexo en esta carpeta.

### Requisitos:
- **Nombre del archivo:** `nexo.png` o `nexo.jpg`
- **Formato:** PNG o JPG
- **Tamaño recomendado:** 512x512 píxeles o superior
- **Fondo:** Preferiblemente transparente (PNG con canal alpha)

### Ubicación:
```
osint_platform/assets/img/nexo.png
```

### Uso:
La imagen de Nexo se utiliza en:
- Botón flotante de Nexo (visible en toda la aplicación)
- Vista del chatbot de Nexo
- Pantalla de inicio (Home)

### Actualizar el código después de agregar la imagen:

Una vez que agregues la imagen, actualiza los siguientes archivos para usar la imagen en lugar del icono placeholder:

1. **`lib/widgets/common/nexo_floating_button.dart`**
   ```dart
   // Reemplazar:
   Icon(Icons.smart_toy_outlined, ...)

   // Por:
   Image.asset('assets/img/nexo.png', width: 32, height: 32)
   ```

2. **`lib/screens/nexo/nexo_chat_screen.dart`**
   ```dart
   // En _buildHeader y _buildMessageBubble, reemplazar:
   Icon(Icons.smart_toy_outlined, ...)

   // Por:
   Image.asset('assets/img/nexo.png', width: 28, height: 28)
   ```

3. **`lib/screens/home/home_screen_redesigned.dart`**
   ```dart
   // En _buildNexoButton, reemplazar:
   Icon(Icons.smart_toy_outlined, ...)

   // Por:
   Image.asset('assets/img/nexo.png', width: 48, height: 48)
   ```

### Nota:
Si no tienes una imagen de Nexo, la aplicación usará un icono de Material Icons como placeholder temporal.
