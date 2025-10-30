# Ejemplos de Integración de ELK Stack

Este documento muestra cómo integrar los servicios de ELK Stack en las diferentes pantallas de la aplicación OSINT.

## 1. Integración en Planning Screen

### Guardar plan de investigación en Elasticsearch

```dart
// lib/screens/planning/planning_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_elasticsearch_provider.dart';
import '../../models/data_form.dart';

class PlanningScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const PlanningScreen({required this.investigationId});

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  // ... existing code ...

  Future<void> _savePlanningData() async {
    final service = ref.read(investigationElasticsearchServiceProvider);

    // Crear DataForm con la información del plan
    final planDataForm = DataForm(
      id: const Uuid().v4(),
      category: 'planning',
      title: 'Plan de Investigación',
      description: _objectivesController.text,
      content: _keyQuestionsController.text,
      metadata: {
        'objectives': _objectivesController.text,
        'keyQuestions': _keyQuestionsController.text,
        'timeline': _timelineController.text,
        'resources': _resourcesController.text,
      },
      tags: ['plan', 'objetivos'],
      timestamp: DateTime.now(),
    );

    // Guardar en Elasticsearch
    final documentId = await service.indexDataForm(
      widget.investigationId,
      planDataForm,
    );

    if (documentId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan guardado en Elasticsearch')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing UI ...
      floatingActionButton: FloatingActionButton(
        onPressed: _savePlanningData,
        child: const Icon(Icons.save),
      ),
    );
  }
}
```

## 2. Integración en Collection Screen

### Guardar datos recopilados con categorización automática

```dart
// lib/screens/collection/collection_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_elasticsearch_provider.dart';
import '../../services/ner_service.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const CollectionScreen({required this.investigationId});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen> {
  final _nerService = NERService();

  Future<void> _saveCollectedData(String category, Map<String, dynamic> data) async {
    final esService = ref.read(investigationElasticsearchServiceProvider);

    // Extraer entidades del contenido si es texto
    List<Entity>? entities;
    if (data['content'] != null && data['content'] is String) {
      final nerResult = await _nerService.extractEntities(data['content']);
      if (nerResult != null) {
        entities = nerResult.map((e) => Entity(
          text: e['text'] as String,
          type: e['type'] as String,
          confidence: (e['confidence'] as num?)?.toDouble() ?? 0.0,
        )).toList();
      }
    }

    // Crear DataForm
    final dataForm = DataForm(
      id: const Uuid().v4(),
      category: category,
      title: data['title'] as String,
      description: data['description'] as String?,
      content: data['content'] as String?,
      metadata: data,
      tags: data['tags'] as List<String>?,
      source: data['source'] as String?,
      url: data['url'] as String?,
      author: data['author'] as String?,
      entities: entities,
      location: data['location'] != null
          ? Location(
              latitude: data['location']['lat'],
              longitude: data['location']['lng'],
              name: data['location']['name'],
            )
          : null,
      timestamp: DateTime.now(),
    );

    // Guardar en Elasticsearch
    final documentId = await esService.indexDataForm(
      widget.investigationId,
      dataForm,
    );

    if (documentId != null) {
      // Refrescar índice para búsqueda inmediata
      await esService.refreshInvestigationIndex(widget.investigationId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados: $documentId')),
      );

      // Invalidar búsquedas para recargar
      ref.invalidate(investigationSearchProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... existing UI with category tabs ...
      body: CategoryDataForm(
        onSave: (category, data) => _saveCollectedData(category, data),
      ),
    );
  }
}
```

## 3. Integración en Processing Screen

### Búsqueda y filtrado de datos para procesamiento

```dart
// lib/screens/processing/processing_screen_redesigned.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_elasticsearch_provider.dart';

class ProcessingScreenRedesigned extends ConsumerStatefulWidget {
  final String investigationId;

  const ProcessingScreenRedesigned({required this.investigationId});

  @override
  ConsumerState<ProcessingScreenRedesigned> createState() =>
      _ProcessingScreenRedesignedState();
}

class _ProcessingScreenRedesignedState
    extends ConsumerState<ProcessingScreenRedesigned> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Crear parámetros de búsqueda
    final searchParams = InvestigationSearchParams(
      investigationId: widget.investigationId,
      query: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory == 'all' ? null : _selectedCategory,
      size: 100,
    );

    // Obtener resultados de búsqueda
    final searchResults = ref.watch(investigationSearchProvider(searchParams));

    // Obtener estadísticas
    final stats = ref.watch(investigationStatsProvider(widget.investigationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procesamiento'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar en datos recopilados...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Filtros de categoría
              SizedBox(
                height: 50,
                child: stats.when(
                  data: (statsData) {
                    final byCategory = statsData['byCategory'] as Map<String, int>;
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: Text('Todos (${statsData['total']})'),
                          selected: _selectedCategory == 'all',
                          onSelected: (_) {
                            setState(() => _selectedCategory = 'all');
                          },
                        ),
                        ...byCategory.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: FilterChip(
                              label: Text('${entry.key} (${entry.value})'),
                              selected: _selectedCategory == entry.key,
                              onSelected: (_) {
                                setState(() => _selectedCategory = entry.key);
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: searchResults.when(
        data: (results) {
          if (results.isEmpty) {
            return const Center(
              child: Text('No se encontraron datos'),
            );
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.description != null)
                        Text(item.description!),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: [
                          Chip(
                            label: Text(item.category),
                            backgroundColor: Colors.blue.shade100,
                          ),
                          if (item.tags != null)
                            ...item.tags!.map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Colors.grey.shade200,
                            )),
                        ],
                      ),
                      if (item.entities != null && item.entities!.isNotEmpty)
                        Text(
                          'Entidades: ${item.entities!.map((e) => e.text).join(", ")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'process',
                        child: Text('Procesar'),
                      ),
                      const PopupMenuItem(
                        value: 'deduplicate',
                        child: Text('Deduplicar'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar'),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final service = ref.read(
                          investigationElasticsearchServiceProvider,
                        );
                        await service.deleteDataForm(
                          widget.investigationId,
                          item.id,
                        );
                        ref.invalidate(investigationSearchProvider);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
```

## 4. Integración en Analysis Screen

### Análisis y visualización de entidades extraídas

```dart
// lib/screens/analysis/analysis_screen_redesigned.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_elasticsearch_provider.dart';

class AnalysisScreenRedesigned extends ConsumerWidget {
  final String investigationId;

  const AnalysisScreenRedesigned({required this.investigationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entities = ref.watch(investigationEntitiesProvider(investigationId));
    final stats = ref.watch(investigationStatsProvider(investigationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Análisis')),
      body: Row(
        children: [
          // Panel izquierdo: Estadísticas
          Expanded(
            flex: 1,
            child: Card(
              child: stats.when(
                data: (statsData) {
                  final total = statsData['total'] as int;
                  final byCategory = statsData['byCategory'] as Map<String, int>;
                  final byTag = statsData['byTag'] as Map<String, int>;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Estadísticas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Total de documentos'),
                        trailing: Text('$total'),
                      ),
                      const Divider(),
                      Text(
                        'Por categoría',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...byCategory.entries.map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value}'),
                      )),
                      const Divider(),
                      Text(
                        'Tags más usados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...byTag.entries.take(10).map((e) => ListTile(
                        title: Text(e.key),
                        trailing: Text('${e.value}'),
                      )),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          // Panel central: Entidades
          Expanded(
            flex: 2,
            child: Card(
              child: entities.when(
                data: (entitiesData) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Entidades Extraídas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      ...entitiesData.entries.map((entry) {
                        final type = entry.key;
                        final entityList = entry.value;

                        return ExpansionTile(
                          title: Text(
                            '$type (${entityList.length})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entityList.map((entity) {
                                return ActionChip(
                                  label: Text(entity),
                                  onPressed: () {
                                    // Buscar documentos con esta entidad
                                    _searchByEntity(context, ref, entity);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          // Panel derecho: Visualización de Kibana (iframe)
          Expanded(
            flex: 2,
            child: Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Visualización en Kibana'),
                    trailing: IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () {
                        // Abrir Kibana en navegador
                        // launch('http://localhost:5601');
                      },
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.analytics, size: 64),
                          const SizedBox(height: 16),
                          const Text('Dashboard de Kibana'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              // Abrir Kibana
                            },
                            child: const Text('Abrir en Kibana'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _searchByEntity(BuildContext context, WidgetRef ref, String entity) {
    final params = InvestigationSearchParams(
      investigationId: investigationId,
      query: entity,
      size: 50,
    );

    // Navegar a pantalla de resultados o mostrar diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Documentos con "$entity"'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Consumer(
            builder: (context, ref, _) {
              final results = ref.watch(investigationSearchProvider(params));

              return results.when(
                data: (docs) => ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return ListTile(
                      title: Text(doc.title),
                      subtitle: Text(doc.description ?? ''),
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
```

## 5. Integración en Reports Screen

### Generar reportes con datos de Elasticsearch

```dart
// lib/screens/reports/reports_screen.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investigation_elasticsearch_provider.dart';
import '../../services/report_generation_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const ReportsScreen({required this.investigationId});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _reportService = ReportGenerationService();

  Future<void> _generateReport() async {
    final esService = ref.read(investigationElasticsearchServiceProvider);

    // Obtener todos los datos de la investigación
    final searchParams = InvestigationSearchParams(
      investigationId: widget.investigationId,
      size: 1000,
    );

    final allData = await ref.read(
      investigationSearchProvider(searchParams).future,
    );

    // Obtener estadísticas
    final stats = await ref.read(
      investigationStatsProvider(widget.investigationId).future,
    );

    // Obtener entidades
    final entities = await ref.read(
      investigationEntitiesProvider(widget.investigationId).future,
    );

    // Generar PDF
    final pdfBytes = await _reportService.generateInvestigationReport(
      investigationId: widget.investigationId,
      data: allData,
      stats: stats,
      entities: entities,
    );

    // Guardar o mostrar PDF
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Center(
        child: ElevatedButton(
          onPressed: _generateReport,
          child: const Text('Generar Reporte Completo'),
        ),
      ),
    );
  }
}
```

## 6. Dashboard de Monitoreo de ELK Stack

### Widget personalizado para mostrar estado detallado

```dart
// lib/widgets/elk_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/elk_stack_provider.dart';

class ELKDashboard extends ConsumerWidget {
  const ELKDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elkState = ref.watch(elkStackProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado de la Pila ELK',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildServiceStatus(
              'Elasticsearch',
              elkState.elasticsearch,
              Icons.search,
            ),
            const SizedBox(height: 8),
            _buildServiceStatus(
              'Logstash',
              elkState.logstash,
              Icons.stream,
            ),
            const SizedBox(height: 8),
            _buildServiceStatus(
              'Kibana',
              elkState.kibana,
              Icons.dashboard,
            ),
            if (elkState.globalError != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        elkState.globalError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Iniciar'),
                  onPressed: elkState.allServicesRunning
                      ? null
                      : () {
                          ref.read(elkStackProvider.notifier).startServices();
                        },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                  onPressed: elkState.elasticsearch.state == ServiceState.stopped
                      ? null
                      : () {
                          ref.read(elkStackProvider.notifier).stopServices();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatus(
    String name,
    ServiceStatus status,
    IconData icon,
  ) {
    Color color;
    switch (status.state) {
      case ServiceState.stopped:
        color = Colors.red;
        break;
      case ServiceState.starting:
        color = Colors.orange;
        break;
      case ServiceState.running:
        color = Colors.green;
        break;
      case ServiceState.error:
        color = Colors.red.shade900;
        break;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                _getStateText(status.state),
                style: TextStyle(color: color, fontSize: 12),
              ),
              if (status.error != null)
                Text(
                  status.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
            ],
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  String _getStateText(ServiceState state) {
    switch (state) {
      case ServiceState.stopped:
        return 'Detenido';
      case ServiceState.starting:
        return 'Iniciando...';
      case ServiceState.running:
        return 'En ejecución';
      case ServiceState.error:
        return 'Error';
    }
  }
}
```

## Conclusión

Estos ejemplos muestran cómo integrar los servicios de ELK Stack en las diferentes pantallas de la aplicación. La clave es:

1. **Usar providers de Riverpod** para gestión de estado y caché
2. **Indexar datos** al guardar información nueva
3. **Buscar y filtrar** usando Elasticsearch para operaciones rápidas
4. **Visualizar estadísticas** para insights de investigación
5. **Extraer entidades** para análisis automático

Todos los servicios están listos para usar y la pila ELK se gestiona automáticamente al abrir y cerrar la aplicación.
