# Implementación del Canvas - Sistema de Nodos Completo

## Resumen

Se ha implementado un sistema completo de Canvas con funcionalidad avanzada para crear diagramas interactivos en la plataforma OSINT. El Canvas permite crear, editar, conectar y gestionar nodos con persistencia en base de datos SQLite.

## Archivos Creados/Modificados

### 1. Nuevos Archivos

#### `lib/providers/canvas_provider.dart`
Provider completo para gestión del estado del Canvas con integración a `graph_provider`:

**Características:**
- Gestión de nodos del canvas (CanvasNode)
- Gestión de conexiones entre nodos (CanvasConnection)
- Sincronización con EntityNodes y Relationships del grafo
- Estado de selección y modo de enlace
- Auto-guardado y marcado de cambios

**Modelos principales:**
- `CanvasNode`: Representa un nodo en el canvas
- `CanvasConnection`: Representa una conexión entre nodos
- `CanvasState`: Estado completo del canvas
- `CanvasNotifier`: Notifier para gestionar el estado

**Métodos clave:**
```dart
- addNode(): Agregar nuevo nodo
- updateNode(): Actualizar nodo existente
- removeNode(): Eliminar nodo y sus conexiones
- addConnection(): Crear conexión entre nodos
- removeConnection(): Eliminar conexión
- clearCanvas(): Limpiar todo el canvas
- loadFromGraph(): Cargar canvas desde el grafo
```

#### `lib/services/canvas_persistence_service.dart`
Servicio de persistencia SQLite para diagramas:

**Características:**
- Tabla SQLite para almacenar diagramas
- Métodos CRUD completos
- Soporte para múltiples canvas por investigación
- Sistema de canvas activo/inactivo
- Exportar/Importar diagramas en JSON

**Métodos principales:**
```dart
- saveCanvas(): Guardar nuevo canvas
- updateCanvas(): Actualizar canvas existente
- loadCanvas(): Cargar canvas por ID
- loadCanvasByInvestigation(): Cargar canvas activo de investigación
- deleteCanvas(): Eliminar canvas
- clearAllData(): Limpiar todos los datos
```

**Schema de base de datos:**
```sql
CREATE TABLE canvas_diagrams (
  id TEXT PRIMARY KEY,
  investigation_id TEXT NOT NULL,
  name TEXT,
  data TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  is_active INTEGER DEFAULT 0
)
```

### 2. Archivos Modificados

#### `lib/widgets/canvas/diagram_canvas_widget.dart`
Widget del Canvas completamente actualizado con Riverpod:

**Nuevas Características Implementadas:**

1. **Sistema de Conexiones Completo:**
   - Modo de enlace activable con botón toggle
   - Click en dos nodos para crear conexión
   - Flechas visuales entre nodos
   - Eliminación de conexiones

2. **Edición de Nodos:**
   - Doble click para editar texto
   - Dialog modal con TextField
   - Actualización en tiempo real
   - Auto-guardado tras edición

3. **Eliminación:**
   - Botón para eliminar nodo seleccionado
   - Confirmación antes de eliminar
   - Eliminación automática de conexiones asociadas
   - Botón para limpiar todo el canvas

4. **Persistencia:**
   - Auto-guardado tras cada cambio
   - Carga automática al abrir investigación
   - Sincronización con base de datos SQLite
   - Indicador de cambios sin guardar

5. **Integración con Providers:**
   - Uso de `canvasProvider` para estado
   - Sincronización con `entityNodesProvider`
   - Sincronización con `relationshipsProvider`
   - Actualización bidireccional

**Nuevos Controles en Toolbar:**
- Connect Nodes: Activar modo de enlace
- Delete Selected Node: Eliminar nodo seleccionado
- Save: Guardar canvas manualmente
- Clear All: Limpiar todo el canvas

**Callbacks Implementados:**
```dart
- _handleNodeTap(): Click en nodo (selección/enlace)
- _handleNodeDoubleTap(): Doble click (edición)
- _handleNodeAdded(): Nodo agregado al canvas
- _handleDeleteNode(): Eliminar nodo
- _handleDeleteLink(): Eliminar conexión
- _createLink(): Crear conexión entre nodos
- _autoSave(): Auto-guardado
```

## Cómo Usar el Canvas

### 1. Agregar Nodos

1. Selecciona el tipo de nodo en la toolbar (Rectangle, Circle, Diamond, Text)
2. Selecciona un color
3. Haz click en el canvas para agregar el nodo

### 2. Conectar Nodos

1. Click en el botón "Connect Nodes" para activar modo de enlace
2. Click en el primer nodo (origen)
3. Click en el segundo nodo (destino)
4. Se creará una flecha conectando ambos nodos

### 3. Editar Nodos

1. Doble click en cualquier nodo
2. Edita el texto en el dialog
3. Click en "Save" para aplicar cambios

### 4. Eliminar Elementos

**Eliminar un nodo:**
1. Click en el nodo para seleccionarlo
2. Click en el botón "Delete Selected Node"
3. Confirma la eliminación

**Limpiar todo:**
1. Click en el botón "Clear All"
2. Confirma la acción

### 5. Guardar

El canvas se guarda automáticamente tras cada cambio. También puedes guardar manualmente con el botón "Save".

## Integración con Investigaciones

El Canvas está diseñado para integrarse con el sistema de investigaciones:

```dart
DiagramCanvasWidget(
  investigationId: 'investigation-id-here',
  onSave: (context) {
    // Callback opcional cuando se guarda
  },
)
```

Los nodos del canvas se sincronizan automáticamente con:
- `EntityNode` en el grafo de relaciones
- Base de datos SQLite para persistencia
- Timeline de eventos (si aplicable)

## Arquitectura

```
┌─────────────────────────────────────────┐
│     DiagramCanvasWidget                 │
│     (UI + Interacción)                  │
└──────────────┬──────────────────────────┘
               │
               │ usa
               ▼
┌─────────────────────────────────────────┐
│     CanvasProvider                      │
│     (Estado del Canvas)                 │
└──────────┬────────────┬─────────────────┘
           │            │
           │ sincroniza │
           ▼            ▼
┌──────────────┐  ┌─────────────────────┐
│ GraphProvider│  │ CanvasPersistence   │
│              │  │ Service             │
│ EntityNodes  │  │                     │
│ Relationships│  │ SQLite DB           │
└──────────────┘  └─────────────────────┘
```

## Persistencia de Datos

### Estructura de Datos Guardada

```json
{
  "investigationId": "uuid",
  "nodes": {
    "node-1": {
      "id": "node-1",
      "componentId": "comp-1",
      "entityNodeId": "entity-1",
      "type": "rectangle",
      "label": "Process",
      "color": 4278190335,
      "position": {"dx": 100.0, "dy": 100.0},
      "size": {"width": 120.0, "height": 60.0}
    }
  },
  "connections": {
    "conn-1": {
      "id": "conn-1",
      "linkId": "link-1",
      "relationshipId": "rel-1",
      "sourceNodeId": "node-1",
      "targetNodeId": "node-2",
      "label": "connected"
    }
  }
}
```

## Tipos de Nodos

| Tipo | Forma | Uso Sugerido | Color Default |
|------|-------|--------------|---------------|
| Rectangle | Rectángulo | Procesos, acciones | Azul |
| Circle | Círculo | Inicio/Fin, eventos | Azul |
| Diamond | Diamante | Decisiones, preguntas | Azul |
| Text | Rectángulo pequeño | Notas, comentarios | Amarillo |

## Próximas Mejoras Sugeridas

1. **Deshacer/Rehacer:**
   - Implementar stack de historial
   - Botones Undo/Redo en toolbar

2. **Zoom y Pan:**
   - Controles de zoom
   - Navegación por el canvas

3. **Exportar Diagrama:**
   - Exportar a PNG/JPG
   - Exportar a PDF
   - Exportar a JSON

4. **Plantillas:**
   - Plantillas predefinidas de diagramas
   - Guardar diagrama como plantilla

5. **Estilos Personalizados:**
   - Más opciones de colores
   - Estilos de línea personalizados
   - Tamaños de nodo ajustables

6. **Agrupar Nodos:**
   - Crear grupos/clusters
   - Colapsar/expandir grupos

7. **Búsqueda en Canvas:**
   - Buscar nodos por texto
   - Resaltar resultados

## Testing

### Test Manual

1. Crear investigación
2. Abrir canvas
3. Agregar varios nodos de diferentes tipos
4. Conectar nodos entre sí
5. Editar texto de nodos
6. Eliminar un nodo
7. Guardar y cerrar
8. Reabrir investigación
9. Verificar que todo se restauró correctamente

### Casos de Prueba

- [x] Agregar nodos funciona correctamente
- [x] Conexiones entre nodos se crean correctamente
- [x] Edición de texto funciona
- [x] Eliminación de nodos funciona
- [x] Eliminación de conexiones funciona
- [x] Persistencia guarda correctamente
- [x] Carga desde DB funciona
- [x] Auto-guardado funciona
- [x] Limpiar canvas funciona
- [x] Integración con graph provider funciona

## Dependencias

El Canvas depende de:
- `diagram_editor: ^0.1.4` - Motor de diagramas
- `flutter_riverpod: ^2.5.1` - Gestión de estado
- `sqflite: ^2.4.1` - Base de datos SQLite
- `uuid: ^4.5.1` - Generación de IDs únicos

## Soporte

Para problemas o preguntas:
1. Revisar esta documentación
2. Verificar logs de la aplicación
3. Revisar el código en los archivos mencionados
4. Crear issue en el repositorio

## Changelog

### v1.0.0 (2025-10-29)
- Implementación inicial completa
- Sistema de nodos y conexiones
- Persistencia SQLite
- Integración con providers
- Edición y eliminación
- Auto-guardado
