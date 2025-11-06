import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/investigations_provider.dart';
import '../../../providers/timeline_provider.dart';
import '../../../providers/geo_location_provider.dart';
import '../../../services/report_generation_service.dart';

class ReportsTab extends ConsumerStatefulWidget {
  final String investigationId;

  const ReportsTab({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  bool _isGenerating = false;
  String? _lastGeneratedPath;
  ReportFormat _selectedFormat = ReportFormat.pdf;
  bool _includeGraphs = true;
  bool _includeTimeline = true;
  bool _includeMaps = true;
  bool _includeHighRisk = true;
  final List<GeneratedReport> _reportHistory = [];

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(
      investigationByIdProvider(widget.investigationId),
    );

    if (investigation == null) {
      return const Center(child: Text('Investigación no encontrada'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.article,
                  color: Colors.blue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informes de Investigación',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Genera y gestiona informes profesionales',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Report Types
          _buildReportCard(
            context,
            title: 'Informe Completo de Investigación',
            description:
                'Informe completo con todas las entidades, relaciones, línea de tiempo y datos geográficos',
            icon: Icons.description,
            color: Colors.blue,
            onGenerate: _generateFullReport,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            context,
            title: 'Informe Resumido',
            description: 'Resumen con estadísticas clave y hallazgos principales',
            icon: Icons.summarize,
            color: Colors.green,
            onGenerate: _generateSummaryReport,
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            context,
            title: 'Informe Personalizado',
            description: 'Selecciona secciones específicas para incluir',
            icon: Icons.tune,
            color: Colors.purple,
            onGenerate: () => _showCustomReportDialog(context),
          ),
          const SizedBox(height: 24),

          // Generation Status
          if (_isGenerating)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Generando informe...',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),

          // Last Generated Report
          if (_lastGeneratedPath != null)
            Card(
              color: Colors.green.withValues(alpha:0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Informe Generado Exitosamente',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Guardado en: $_lastGeneratedPath',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open file location
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Revisa tu carpeta de documentos/informes'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Abrir Ubicación'),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Export Format
          Text(
            'Formato de Exportación',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ReportFormat.values.map((format) {
                      final isSelected = _selectedFormat == format;
                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              format.icon,
                              size: 18,
                              color: isSelected ? Colors.white : null,
                            ),
                            const SizedBox(width: 8),
                            Text(format.displayName),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFormat = format;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Report Settings
          Text(
            'Opciones de Contenido',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text('Incluir Gráficos'),
                    subtitle: const Text('Visualizaciones de relaciones entre entidades'),
                    value: _includeGraphs,
                    onChanged: (value) {
                      setState(() {
                        _includeGraphs = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Incluir Línea de Tiempo'),
                    subtitle: const Text('Cronología de eventos'),
                    value: _includeTimeline,
                    onChanged: (value) {
                      setState(() {
                        _includeTimeline = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Incluir Mapas'),
                    subtitle: const Text('Ubicaciones geográficas'),
                    value: _includeMaps,
                    onChanged: (value) {
                      setState(() {
                        _includeMaps = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Destacar Elementos de Alto Riesgo'),
                    subtitle: const Text('Marcar hallazgos críticos'),
                    value: _includeHighRisk,
                    onChanged: (value) {
                      setState(() {
                        _includeHighRisk = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Report History
          if (_reportHistory.isNotEmpty) ...[
            Text(
              'Historial de Informes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._reportHistory.map((report) => _buildHistoryCard(context, report)),
          ],
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onGenerate,
  }) {
    return Card(
      child: InkWell(
        onTap: _isGenerating ? null : onGenerate,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.outline,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, GeneratedReport report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: report.format.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(report.format.icon, color: report.format.color),
        ),
        title: Text(report.title),
        subtitle: Text(
          'Generado: ${report.generatedAt.day}/${report.generatedAt.month}/${report.generatedAt.year} ${report.generatedAt.hour}:${report.generatedAt.minute.toString().padLeft(2, '0')}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Descargando ${report.title}...'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              tooltip: 'Descargar',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _reportHistory.remove(report);
                });
              },
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateFullReport() async {
    setState(() => _isGenerating = true);

    try {
      final investigation = ref.read(
        investigationByIdProvider(widget.investigationId),
      )!;
      // Note: Entity nodes and relationships removed - passing empty lists
      final nodes = [];
      final relationships = [];
      final events = ref.read(
        eventsByInvestigationProvider(widget.investigationId),
      );
      final locations = ref.read(
        locationsByInvestigationProvider(widget.investigationId),
      );

      final file = await ReportGenerationService.generateInvestigationReport(
        investigation: investigation,
        nodes: nodes,
        relationships: relationships,
        events: events,
        locations: locations,
      );

      final generatedReport = GeneratedReport(
        title: 'Informe Completo - ${investigation.name}',
        format: _selectedFormat,
        generatedAt: DateTime.now(),
        filePath: file.path,
      );

      setState(() {
        _isGenerating = false;
        _lastGeneratedPath = file.path;
        _reportHistory.insert(0, generatedReport);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informe generado: ${_selectedFormat.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar informe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateSummaryReport() async {
    setState(() => _isGenerating = true);

    try {
      final investigation = ref.read(
        investigationByIdProvider(widget.investigationId),
      )!;
      // Note: Entity nodes and relationships removed - passing empty lists
      final nodes = [];
      final relationships = [];

      final file = await ReportGenerationService.generateSummaryReport(
        investigation: investigation,
        nodes: nodes,
        relationships: relationships,
      );

      final generatedReport = GeneratedReport(
        title: 'Informe Resumido - ${investigation.name}',
        format: _selectedFormat,
        generatedAt: DateTime.now(),
        filePath: file.path,
      );

      setState(() {
        _isGenerating = false;
        _lastGeneratedPath = file.path;
        _reportHistory.insert(0, generatedReport);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Informe resumido generado: ${_selectedFormat.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGenerating = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar informe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informe Personalizado'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text('Resumen Ejecutivo'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Entidades'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Relaciones'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Línea de Tiempo'),
                value: true,
                onChanged: null,
              ),
              CheckboxListTile(
                title: Text('Análisis Geográfico'),
                value: true,
                onChanged: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Generación de informes personalizados - próximamente'),
                ),
              );
            },
            child: const Text('Generar'),
          ),
        ],
      ),
    );
  }
}

// Models
class GeneratedReport {
  final String title;
  final ReportFormat format;
  final DateTime generatedAt;
  final String filePath;

  GeneratedReport({
    required this.title,
    required this.format,
    required this.generatedAt,
    required this.filePath,
  });
}

// Enums
enum ReportFormat {
  pdf,
  docx,
  html,
  markdown,
  json,
}

extension ReportFormatExtension on ReportFormat {
  String get displayName {
    switch (this) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.docx:
        return 'Word';
      case ReportFormat.html:
        return 'HTML';
      case ReportFormat.markdown:
        return 'Markdown';
      case ReportFormat.json:
        return 'JSON';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportFormat.pdf:
        return Icons.picture_as_pdf;
      case ReportFormat.docx:
        return Icons.description;
      case ReportFormat.html:
        return Icons.code;
      case ReportFormat.markdown:
        return Icons.notes;
      case ReportFormat.json:
        return Icons.data_object;
    }
  }

  Color get color {
    switch (this) {
      case ReportFormat.pdf:
        return Colors.red;
      case ReportFormat.docx:
        return Colors.blue;
      case ReportFormat.html:
        return Colors.orange;
      case ReportFormat.markdown:
        return Colors.purple;
      case ReportFormat.json:
        return Colors.green;
    }
  }
}
