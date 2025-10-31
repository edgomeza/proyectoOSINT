import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/ner_service.dart';
import '../../providers/graph_provider.dart';

class NERExtractionWidget extends ConsumerStatefulWidget {
  final String investigationId;

  const NERExtractionWidget({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<NERExtractionWidget> createState() =>
      _NERExtractionWidgetState();
}

class _NERExtractionWidgetState extends ConsumerState<NERExtractionWidget> {
  final _nerService = NERService();
  final _textController = TextEditingController();
  bool _isProcessing = false;
  bool _isServiceAvailable = false;
  NERResult? _result;

  @override
  void initState() {
    super.initState();
    _checkServiceHealth();
  }

  Future<void> _checkServiceHealth() async {
    final isAvailable = await _nerService.checkHealth();
    if (mounted) {
      setState(() => _isServiceAvailable = isAvailable);
    }
  }

  Future<void> _extractEntities() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _result = null;
    });

    try {
      final result = await _nerService.extractEntities(_textController.text);

      if (mounted) {
        setState(() {
          _result = result;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Extracción de Entidades NER',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Extraer entidades del texto usando IA',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Service Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isServiceAvailable
                            ? Colors.green.withValues(alpha:0.2)
                            : Colors.red.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isServiceAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isServiceAvailable ? Icons.check_circle : Icons.error,
                            size: 16,
                            color: _isServiceAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isServiceAvailable ? 'En Línea' : 'Fuera de Línea',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isServiceAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!_isServiceAvailable) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Servicio NER no disponible',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Inicie el backend Python NER para usar esta función:',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha:0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'cd ner_backend && python app.py',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _checkServiceHealth,
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reintentar Conexión'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Input
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Texto de Entrada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _textController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    hintText: 'Insertar el texto extraido de las entidades...\n\n'
                        'Ejemplo: "John Doe trabaja en Nueva York para Acme Corp. '
                        'Contacto: john@acme.com o +34 1230123."',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isServiceAvailable && !_isProcessing
                          ? _extractEntities
                          : null,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isProcessing ? 'Procesando...' : 'Extraer Entidades'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _textController.clear();
                        setState(() => _result = null);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Results
        if (_result != null) ...[
          Text(
            'Entidades extraidas (${_result!.entities.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _result!.entityCounts.entries.map((entry) {
                  return Chip(
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: Colors.blue.withValues(alpha:0.1),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Entity List
          Expanded(
            child: ListView.builder(
              itemCount: _result!.entities.length,
              itemBuilder: (context, index) {
                final entity = _result!.entities[index];
                return _buildEntityCard(context, entity);
              },
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _createAllEntities(context),
                  icon: const Icon(Icons.add_circle),
                  label: Text('Creadas todas las entidades (${_result!.entities.length})'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEntityCard(BuildContext context, ExtractedEntity entity) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getEntityColor(entity.label).withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEntityIcon(entity.label),
            color: _getEntityColor(entity.label),
          ),
        ),
        title: Text(entity.text),
        subtitle: Text(entity.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text('${(entity.confidence * 100).toInt()}%'),
              backgroundColor: Colors.green.withValues(alpha:0.1),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _createSingleEntity(context, entity),
              tooltip: 'Crear Entidad',
            ),
          ],
        ),
      ),
    );
  }

  Color _getEntityColor(String label) {
    switch (label.toUpperCase()) {
      case 'PERSONA':
      case 'PER':
        return Colors.blue;
      case 'ORG':
      case 'ORGANIZACION':
        return Colors.purple;
      case 'GPS':
      case 'UBI':
      case 'UBICACION':
        return Colors.green;
      case 'EMAIL':
        return Colors.orange;
      case 'TELEFONO':
        return Colors.cyan;
      case 'URL':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getEntityIcon(String label) {
    switch (label.toUpperCase()) {
      case 'PERSONA':
      case 'PER':
        return Icons.person;
      case 'ORG':
      case 'ORGANIZACION':
        return Icons.business;
      case 'GPS':
      case 'UBI':
      case 'UBICACION':
        return Icons.location_on;
      case 'EMAIL':
        return Icons.email;
      case 'TELEFONO':
        return Icons.phone;
      case 'URL':
        return Icons.link;
      default:
        return Icons.help_outline;
    }
  }

  void _createSingleEntity(BuildContext context, ExtractedEntity entity) {
    final nodes = _nerService.convertToEntityNodes(
      NERResult(
        text: _result!.text,
        entities: [entity],
        entityCounts: {entity.label: 1},
        model: _result!.model,
      ),
      investigationId: widget.investigationId,
    );

    for (final node in nodes) {
      ref.read(entityNodesProvider.notifier).addNode(node);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Entidad "${entity.text}" creada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _createAllEntities(BuildContext context) {
    if (_result == null) return;

    final nodes = _nerService.convertToEntityNodes(
      _result!,
      investigationId: widget.investigationId,
    );

    for (final node in nodes) {
      ref.read(entityNodesProvider.notifier).addNode(node);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${nodes.length} entidades creadas exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _result = null;
      _textController.clear();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
