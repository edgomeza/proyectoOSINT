# Implementación de la Pila ELK en la Plataforma OSINT

## Descripción General

Se ha implementado completamente la integración de la pila ELK (Elasticsearch, Logstash, Kibana) en la plataforma OSINT. La implementación incluye:

1. **Gestión automática de servicios Docker**: Inicio y detención automática al abrir y cerrar la aplicación
2. **Monitoreo en tiempo real**: Widget que muestra el estado real de los servicios
3. **Integración completa con Elasticsearch**: Servicios para indexar, buscar y gestionar datos de investigaciones
4. **Gestión del ciclo de vida**: Los servicios se detienen automáticamente al cerrar la app

## Componentes Implementados

### 1. Servicios Core

#### `docker_service.dart`
Servicio para gestionar contenedores Docker:
- Inicia servicios con `docker-compose up -d`
- Detiene servicios con `docker-compose down`
- Monitorea el estado de los servicios cada 5 segundos
- Verifica disponibilidad de Docker y Docker Compose
- Soporta ambas versiones: `docker compose` (v2) y `docker-compose` (v1)

**Características:**
```dart
// Inicializar
final dockerService = DockerService();
dockerService.initialize('/path/to/project');

// Iniciar servicios
await dockerService.startServices();

// Obtener estado
final status = await dockerService.getServicesStatus();

// Detener servicios
await dockerService.stopServices();
```

#### `elasticsearch_service.dart`
Servicio para interactuar con Elasticsearch:
- Operaciones CRUD completas (crear, leer, actualizar, eliminar)
- Búsqueda simple y avanzada con Query DSL
- Bulk indexing para operaciones masivas
- Agregaciones y estadísticas
- Health checks y monitoreo

**Características:**
```dart
// Inicializar
final esService = ElasticsearchService();
esService.initialize(host: 'localhost', port: 9200);

// Crear índice
await esService.createIndex('my-index', mappings: {...});

// Indexar documento
await esService.indexDocument('my-index', {'field': 'value'});

// Buscar
final results = await esService.search('my-index', query: 'search term');

// Bulk indexing
await esService.bulkIndexDocuments('my-index', documents);
```

#### `investigation_elasticsearch_service.dart`
Servicio de alto nivel para gestionar investigaciones:
- Crea índices específicos por investigación
- Indexa DataForms con mapping optimizado
- Búsqueda avanzada con filtros múltiples
- Estadísticas por categoría y tags
- Extracción de entidades agrupadas por tipo

**Características:**
```dart
// Inicializar índice de investigación
await service.initializeInvestigationIndex(investigation);

// Indexar datos
await service.indexDataForm(investigationId, dataForm);

// Búsqueda avanzada
final results = await service.searchInInvestigation(
  investigationId,
  query: 'términos de búsqueda',
  category: 'personas',
  tags: ['importante'],
  startDate: DateTime(2024, 1, 1),
  size: 20,
);

// Obtener estadísticas
final stats = await service.getInvestigationStats(investigationId);

// Obtener entidades
final entities = await service.getEntitiesByType(investigationId);
```

### 2. Providers (Riverpod)

#### `elk_stack_provider.dart`
Provider para gestionar el estado de la pila ELK:
- Estados: stopped, starting, running, error
- Monitoreo en tiempo real
- Stream de actualizaciones de estado
- Integración con health checks

**Estados del servicio:**
- `stopped`: Servicio detenido (rojo)
- `starting`: Servicio iniciando (naranja)
- `running`: Servicio en ejecución (verde)
- `error`: Error en el servicio (rojo oscuro)

**Uso:**
```dart
// Leer estado
final elkState = ref.watch(elkStackProvider);

// Verificar si todos los servicios están corriendo
final allRunning = ref.watch(allServicesRunningProvider);

// Inicializar servicios
ref.read(elkStackProvider.notifier).initialize(projectPath);

// Detener servicios
ref.read(elkStackProvider.notifier).stopServices();
```

#### `investigation_elasticsearch_provider.dart`
Provider para operaciones de investigación:
- Búsqueda con caché automático
- Estadísticas de investigación
- Extracción de entidades

**Uso:**
```dart
// Buscar en investigación
final searchParams = InvestigationSearchParams(
  investigationId: 'inv-123',
  query: 'términos',
  category: 'personas',
);
final results = ref.watch(investigationSearchProvider(searchParams));

// Obtener estadísticas
final stats = ref.watch(investigationStatsProvider('inv-123'));

// Obtener entidades
final entities = ref.watch(investigationEntitiesProvider('inv-123'));
```

### 3. Widgets

#### `elk_services_indicator.dart`
Widget que muestra el estado de los servicios ELK:
- Indicadores visuales por servicio (ES, LS, KB)
- Colores según estado (rojo, naranja, verde)
- Tooltips con información detallada
- Efecto glow en servicios activos
- Actualización en tiempo real

**Ubicación:**
- Barra de aplicación moderna (`modern_app_bar.dart`)
- Pantalla de inicio (`home_screen_redesigned.dart`)

### 4. Configuración de Inicio Automático

#### `main.dart`
La aplicación ahora:
1. Inicializa los servicios ELK al desbloquear la app
2. Monitorea el estado de los servicios en tiempo real
3. Detiene los servicios al cerrar o pausar la app
4. Detecta automáticamente la ruta del proyecto Docker

**Flujo de inicio:**
1. Usuario desbloquea la app → `_handleUnlocked()`
2. Se llama a `_initializeELKServices()`
3. Se obtiene la ruta del proyecto automáticamente
4. Se inicializa el provider de ELK Stack
5. Los servicios Docker se inician automáticamente
6. El widget muestra el estado en tiempo real

**Flujo de cierre:**
1. App entra en pausa/cierre → `didChangeAppLifecycleState()`
2. Se llama a `_stopELKServices()`
3. Los servicios Docker se detienen con `docker-compose down`
4. Se liberan recursos

## Estructura de Índices Elasticsearch

### Naming Convention
Los índices se crean con el patrón: `osint-investigation-{investigation-id}`

### Mapping
```json
{
  "properties": {
    "id": {"type": "keyword"},
    "investigationId": {"type": "keyword"},
    "category": {"type": "keyword"},
    "type": {"type": "keyword"},
    "title": {
      "type": "text",
      "fields": {
        "keyword": {"type": "keyword"}
      }
    },
    "description": {"type": "text"},
    "content": {"type": "text"},
    "metadata": {"type": "object"},
    "entities": {
      "type": "nested",
      "properties": {
        "text": {"type": "keyword"},
        "type": {"type": "keyword"},
        "confidence": {"type": "float"}
      }
    },
    "tags": {"type": "keyword"},
    "source": {"type": "keyword"},
    "url": {"type": "keyword"},
    "author": {"type": "keyword"},
    "location": {
      "type": "object",
      "properties": {
        "latitude": {"type": "float"},
        "longitude": {"type": "float"},
        "name": {"type": "keyword"}
      }
    },
    "timestamp": {"type": "date"},
    "collectedAt": {"type": "date"},
    "createdAt": {"type": "date"},
    "updatedAt": {"type": "date"}
  }
}
```

## Configuración Docker

### docker-compose.yml
La pila incluye 4 servicios:

1. **Elasticsearch** (puerto 9200)
   - Versión: 8.11.0
   - Modo: single-node
   - Memoria: 512MB
   - Seguridad: deshabilitada (desarrollo)

2. **Kibana** (puerto 5601)
   - Versión: 8.11.0
   - Conectado a Elasticsearch
   - Dashboard de visualización

3. **Logstash** (puertos 5044, 9600)
   - Versión: 8.11.0
   - Memoria: 256MB
   - Pipelines configurados

4. **NER Backend** (puerto 8000)
   - Python Flask
   - Named Entity Recognition
   - Integrado con Elasticsearch

### Health Checks
Todos los servicios incluyen health checks:
- Elasticsearch: `curl http://localhost:9200`
- Kibana: `curl http://localhost:5601/api/status`
- Servicios dependientes esperan a que Elasticsearch esté healthy

## Ejemplos de Uso Completos

### Ejemplo 1: Indexar datos de una investigación

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/investigation_elasticsearch_provider.dart';

class DataCollectionScreen extends ConsumerWidget {
  final String investigationId;

  const DataCollectionScreen({required this.investigationId});

  Future<void> saveData(WidgetRef ref, DataForm dataForm) async {
    final service = ref.read(investigationElasticsearchServiceProvider);

    // Indexar el formulario de datos
    final documentId = await service.indexDataForm(investigationId, dataForm);

    if (documentId != null) {
      // Éxito: recargar datos
      ref.invalidate(investigationSearchProvider);
      print('Documento indexado: $documentId');
    } else {
      print('Error al indexar documento');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widget implementation...
  }
}
```

### Ejemplo 2: Búsqueda con filtros

```dart
class SearchScreen extends ConsumerWidget {
  final String investigationId;

  Future<void> performSearch(WidgetRef ref) async {
    final params = InvestigationSearchParams(
      investigationId: investigationId,
      query: 'John Doe',
      category: 'personas',
      tags: ['sospechoso', 'importante'],
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      size: 50,
    );

    final results = await ref.read(investigationSearchProvider(params).future);

    print('Encontrados ${results.length} resultados');
    for (final result in results) {
      print('- ${result.title}: ${result.description}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchParams = InvestigationSearchParams(
      investigationId: investigationId,
    );

    final searchResults = ref.watch(investigationSearchProvider(searchParams));

    return searchResults.when(
      data: (results) => ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return ListTile(
            title: Text(result.title),
            subtitle: Text(result.description ?? ''),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Ejemplo 3: Estadísticas de investigación

```dart
class StatsScreen extends ConsumerWidget {
  final String investigationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(investigationStatsProvider(investigationId));

    return stats.when(
      data: (data) {
        final total = data['total'] as int;
        final byCategory = data['byCategory'] as Map<String, int>;
        final byTag = data['byTag'] as Map<String, int>;

        return Column(
          children: [
            Text('Total de documentos: $total'),
            Text('Por categoría:'),
            ...byCategory.entries.map((e) =>
              Text('  ${e.key}: ${e.value}')
            ),
            Text('Por tag:'),
            ...byTag.entries.map((e) =>
              Text('  ${e.key}: ${e.value}')
            ),
          ],
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
  }
}
```

### Ejemplo 4: Operaciones en lote

```dart
class BulkImportScreen extends ConsumerWidget {
  Future<void> importData(WidgetRef ref, List<DataForm> dataForms) async {
    final service = ref.read(investigationElasticsearchServiceProvider);

    // Indexar todos los documentos en lote
    final success = await service.bulkIndexDataForms(
      investigationId,
      dataForms,
    );

    if (success) {
      // Refrescar el índice para que los datos estén disponibles inmediatamente
      await service.refreshInvestigationIndex(investigationId);

      print('${dataForms.length} documentos indexados correctamente');

      // Invalidar cache para recargar
      ref.invalidate(investigationSearchProvider);
    }
  }
}
```

## Requisitos del Sistema

1. **Docker**: Docker Engine instalado y en ejecución
2. **Docker Compose**: v1.x o v2.x
3. **Recursos mínimos**:
   - RAM: 2GB disponibles
   - Disco: 2GB de espacio libre
   - CPU: 2 cores recomendados

## Comandos Útiles

### Verificar estado de servicios
```bash
cd /home/user/proyectoOSINT
docker-compose ps
```

### Ver logs de servicios
```bash
docker-compose logs -f elasticsearch
docker-compose logs -f logstash
docker-compose logs -f kibana
```

### Reiniciar servicios manualmente
```bash
docker-compose restart
```

### Detener servicios manualmente
```bash
docker-compose down
```

### Limpiar datos (cuidado: elimina todos los datos)
```bash
docker-compose down -v
```

## Acceso a Servicios

- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601
- **Logstash API**: http://localhost:9600
- **NER Backend**: http://localhost:8000

## Solución de Problemas

### Los servicios no inician
1. Verificar que Docker esté en ejecución: `docker --version`
2. Verificar logs: `docker-compose logs`
3. Verificar puertos disponibles: `lsof -i :9200`

### Elasticsearch no responde
1. Esperar 30-60 segundos (inicio normal)
2. Verificar memoria disponible
3. Ver logs: `docker-compose logs elasticsearch`

### Widget muestra error
1. Verificar que docker-compose.yml existe en la ruta del proyecto
2. Verificar permisos de ejecución de Docker
3. Ver consola de Flutter para errores específicos

## Próximas Mejoras

- [ ] Implementar autenticación en Elasticsearch
- [ ] Agregar TLS/SSL para conexiones seguras
- [ ] Implementar backups automáticos de índices
- [ ] Agregar dashboards predefinidos en Kibana
- [ ] Implementar alertas basadas en queries
- [ ] Optimizar queries para grandes volúmenes de datos
- [ ] Agregar soporte para geo-búsquedas avanzadas

## Referencias

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Riverpod Documentation](https://riverpod.dev/)
