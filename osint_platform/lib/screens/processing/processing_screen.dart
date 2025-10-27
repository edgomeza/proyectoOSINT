import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/navigation_drawer.dart';
import '../../widgets/cards/processing_card.dart';
import '../../providers/data_forms_provider.dart';
import '../../providers/investigations_provider.dart';
import '../../models/data_form.dart';
import '../../models/data_form_status.dart';

enum SortOption {
  smartPriority,
  date,
  completeness,
  category,
}

class ProcessingScreen extends ConsumerStatefulWidget {
  final String investigationId;

  const ProcessingScreen({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  DataFormCategory? _selectedCategoryFilter;
  DataFormStatus? _selectedStatusFilter;
  SortOption _sortOption = SortOption.smartPriority;

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(investigationByIdProvider(widget.investigationId));
    var forms = ref.watch(dataFormsByInvestigationProvider(widget.investigationId))
        .where((form) =>
            form.status == DataFormStatus.collected ||
            form.status == DataFormStatus.inReview ||
            form.status == DataFormStatus.reviewed
        )
        .toList();

    // Aplicar filtros
    if (_selectedCategoryFilter != null) {
      forms = forms.where((form) => form.category == _selectedCategoryFilter).toList();
    }
    if (_selectedStatusFilter != null) {
      forms = forms.where((form) => form.status == _selectedStatusFilter).toList();
    }

    // Aplicar ordenamiento
    _sortForms(forms);

    if (investigation == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
            tooltip: 'Volver al inicio',
          ),
          title: const Text('Procesamiento'),
        ),
        body: const Center(
          child: Text('Investigación no encontrada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'Volver al inicio',
        ),
        title: const Text('Procesamiento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFiltersDialog,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: 'Ordenar',
          ),
        ],
      ),
      drawer: const AppNavigationDrawer(),
      body: forms.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildStatsBar(forms),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: forms.length > 7 ? 7 : forms.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProcessingCard(
                          form: forms[index],
                          onMarkReviewed: () => _markAsReviewed(forms[index]),
                          onSendToElasticsearch: () => _sendToElasticsearch(forms[index]),
                        ),
                      );
                    },
                  ),
                ),
                if (forms.length > 7) _buildMoreItemsIndicator(forms.length),
              ],
            ),
    );
  }

  void _sortForms(List<DataForm> forms) {
    switch (_sortOption) {
      case SortOption.smartPriority:
        forms.sort((a, b) => b.smartPriority.compareTo(a.smartPriority));
        break;
      case SortOption.date:
        forms.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case SortOption.completeness:
        forms.sort((a, b) => b.completeness.compareTo(a.completeness));
        break;
      case SortOption.category:
        forms.sort((a, b) => a.category.name.compareTo(b.category.name));
        break;
    }
  }

  Widget _buildStatsBar(List<DataForm> forms) {
    final inReview = forms.where((f) => f.status == DataFormStatus.inReview).length;
    final reviewed = forms.where((f) => f.status == DataFormStatus.reviewed).length;
    final collected = forms.where((f) => f.status == DataFormStatus.collected).length;

    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(
              label: 'Recopilados',
              count: collected,
              color: Colors.blue,
              icon: Icons.inbox,
            ),
            _buildStatChip(
              label: 'En Revisión',
              count: inReview,
              color: Colors.orange,
              icon: Icons.rate_review,
            ),
            _buildStatChip(
              label: 'Revisados',
              count: reviewed,
              color: Colors.green,
              icon: Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeIn(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay formularios para procesar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los formularios enviados desde Recopilación aparecerán aquí',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.go('/investigation/${widget.investigationId}/collection');
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Ir a Recopilación'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItemsIndicator(int totalCount) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border(
            top: BorderSide(color: Colors.amber.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
            const SizedBox(width: 12),
            Text(
              'Mostrando 7 de $totalCount elementos (límite cognitivo)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.amber.shade900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _markAsReviewed(DataForm form) {
    ref.read(dataFormsProvider.notifier).changeStatus(
          form.id,
          DataFormStatus.reviewed,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Formulario marcado como revisado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendToElasticsearch(DataForm form) {
    ref.read(dataFormsProvider.notifier).changeStatus(
          form.id,
          DataFormStatus.sent,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Formulario enviado a Elasticsearch'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            context.go('/investigation/${widget.investigationId}/analysis');
          },
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Categoría',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _selectedCategoryFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryFilter = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ...DataFormCategory.values.map((category) {
                    return FilterChip(
                      label: Text(category.displayName),
                      selected: _selectedCategoryFilter == category,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryFilter = selected ? category : null;
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Estado',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedStatusFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Recopilados'),
                    selected: _selectedStatusFilter == DataFormStatus.collected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? DataFormStatus.collected : null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('En Revisión'),
                    selected: _selectedStatusFilter == DataFormStatus.inReview,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? DataFormStatus.inReview : null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FilterChip(
                    label: const Text('Revisados'),
                    selected: _selectedStatusFilter == DataFormStatus.reviewed,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? DataFormStatus.reviewed : null;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategoryFilter = null;
                _selectedStatusFilter = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Limpiar filtros'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SortOption>(
              title: const Text('Prioridad Inteligente'),
              subtitle: const Text('Algoritmo de priorización automática'),
              value: SortOption.smartPriority,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Fecha de actualización'),
              subtitle: const Text('Más recientes primero'),
              value: SortOption.date,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Completitud'),
              subtitle: const Text('Más completos primero'),
              value: SortOption.completeness,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortOption>(
              title: const Text('Categoría'),
              subtitle: const Text('Agrupados por tipo'),
              value: SortOption.category,
              groupValue: _sortOption,
              onChanged: (value) {
                setState(() {
                  _sortOption = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
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
