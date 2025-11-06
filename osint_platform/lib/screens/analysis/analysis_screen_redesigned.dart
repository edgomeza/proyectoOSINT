import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../widgets/common/phase_navigation.dart';
import '../../widgets/common/app_layout_wrapper.dart';
import '../../widgets/common/modern_app_bar.dart';
import '../../models/investigation_phase.dart';
import '../../models/entity_node.dart';
import '../../models/timeline_event.dart';
import '../../models/geo_location.dart';
import '../../providers/investigations_provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/geo_location_provider.dart';
import '../../widgets/timeline/timeline_widget.dart';
import '../../widgets/map/geographic_map_widget.dart';
import 'tabs/overview_tab.dart';
import 'tabs/advanced_search_tab.dart';
import '../../widgets/common/phase_navigation_buttons.dart';

class AnalysisScreenRedesigned extends ConsumerStatefulWidget {
  final String investigationId;

  const AnalysisScreenRedesigned({
    super.key,
    required this.investigationId,
  });

  @override
  ConsumerState<AnalysisScreenRedesigned> createState() =>
      _AnalysisScreenRedesignedState();
}

class _AnalysisScreenRedesignedState
    extends ConsumerState<AnalysisScreenRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final investigation = ref.watch(
      investigationByIdProvider(widget.investigationId),
    );

    if (investigation == null) {
      return AppLayoutWrapper(
        appBar: ModernAppBar(
          title: 'Análisis',
          leading: const PhaseNavigationButtons(),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Investigación no encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Ir al inicio'),
              ),
            ],
          ),
        ),
      );
    }

    // Get statistics
    final timelineStats = ref.watch(timelineStatsProvider);
    final geoStats = ref.watch(geoStatsProvider);

    return AppLayoutWrapper(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const PhaseNavigationButtons(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Análisis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              investigation.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          // Statistics Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${timelineStats.totalEvents}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${geoStats.totalLocations}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, size: 22),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Ayuda',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabChip(0, Icons.dashboard_outlined, 'Resumen', Colors.blue),
                  const SizedBox(width: 8),
                  _buildTabChip(1, Icons.timeline_outlined, 'Timeline', Colors.teal),
                  const SizedBox(width: 8),
                  _buildTabChip(2, Icons.map_outlined, 'Mapa', Colors.green),
                  const SizedBox(width: 8),
                  _buildTabChip(3, Icons.search_outlined, 'Búsqueda', Colors.orange),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: PhaseNavigation(
        investigationId: widget.investigationId,
        currentPhase: InvestigationPhase.analysis,
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      child: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          OverviewTab(investigationId: widget.investigationId),

          // Timeline Tab
          DynamicTimelineWidget(
            investigationId: widget.investigationId,
            onEventTap: (event) => _showEventDetails(context, event),
          ),

          // Map Tab
          GeographicMapWidget(
            investigationId: widget.investigationId,
            onLocationTap: (location) => _showLocationDetails(context, location),
          ),

          // Advanced Search Tab
          AdvancedSearchTab(investigationId: widget.investigationId),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    switch (_currentTabIndex) {
      case 1: // Timeline tab
        return FloatingActionButton.extended(
          heroTag: 'add_event',
          onPressed: () => _showAddEventDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar Evento'),
        );
      case 2: // Map tab
        return FloatingActionButton.extended(
          heroTag: 'add_location',
          onPressed: () => _showAddLocationDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Agregar Ubicación'),
        );
      default:
        return null;
    }
  }

  Widget _buildTabChip(int index, IconData icon, String label, Color color) {
    final isSelected = _currentTabIndex == index;

    return FadeIn(
      duration: const Duration(milliseconds: 400),
      delay: Duration(milliseconds: index * 80),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            _tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color, color.withAlpha(180)],
                    )
                  : null,
              color: isSelected ? null : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : color,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Fecha', event.timestamp.toString()),
              _buildDetailRow('Tipo', event.type.displayName),
              _buildDetailRow('Prioridad', event.priority.displayName),
              if (event.location != null)
                _buildDetailRow('Ubicación', event.location!),
              if (event.description != null) ...[
                const SizedBox(height: 8),
                Text(event.description!),
              ],
            ],
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

  void _showLocationDetails(BuildContext context, location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(location.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Tipo', location.type.displayName),
            _buildDetailRow('Riesgo', location.risk.displayName),
            _buildDetailRow(
              'Coordenadas',
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
            ),
            if (location.address != null)
              _buildDetailRow('Dirección', location.address!),
            if (location.description != null) ...[
              const SizedBox(height: 8),
              Text(location.description!),
            ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimelineEventType selectedType = TimelineEventType.other;
    EventPriority selectedPriority = EventPriority.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir nuevo evento'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del evento *',
                      hintText: 'Inserte el título del evento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TimelineEventType>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de evento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    initialValue: selectedType,
                    items: TimelineEventType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<EventPriority>(
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.priority_high),
                    ),
                    initialValue: selectedPriority,
                    items: EventPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Text(priority.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedPriority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Fecha y hora'),
                    subtitle: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null && dialogContext.mounted) {
                        final time = await showTimePicker(
                          context: dialogContext,
                          initialTime: TimeOfDay.fromDateTime(selectedDate),
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      hintText: 'Ubicación opcional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción opcional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                titleController.dispose();
                descriptionController.dispose();
                locationController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingrese un título para el evento'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final event = TimelineEvent(
                  title: title,
                  timestamp: selectedDate,
                  type: selectedType,
                  priority: selectedPriority,
                  description: descriptionController.text.trim(),
                  location: locationController.text.trim().isEmpty
                      ? null
                      : locationController.text.trim(),
                  investigationId: widget.investigationId,
                );

                ref.read(timelineEventsProvider.notifier).addEvent(event);

                titleController.dispose();
                descriptionController.dispose();
                locationController.dispose();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Evento "$title" añadido con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir Evento'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    GeoLocationType selectedType = GeoLocationType.poi;
    LocationRisk selectedRisk = LocationRisk.medium;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Añadir nueva ubicación'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Ubicación *',
                      hintText: 'Inserte el nombre de la ubicación',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<GeoLocationType>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Ubicación',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    initialValue: selectedType,
                    items: GeoLocationType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedType = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LocationRisk>(
                    decoration: const InputDecoration(
                      labelText: 'Nivel de Riesgo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.warning),
                    ),
                    initialValue: selectedRisk,
                    items: LocationRisk.values.map((risk) {
                      return DropdownMenuItem(
                        value: risk,
                        child: Text(risk.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedRisk = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: latController,
                          decoration: const InputDecoration(
                            labelText: 'Latitud *',
                            hintText: 'e.g. 40.7128',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_searching),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: lonController,
                          decoration: const InputDecoration(
                            labelText: 'Longitud *',
                            hintText: 'e.g. -74.0060',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_searching),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'Dirección opcional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción opcional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                nameController.dispose();
                addressController.dispose();
                descriptionController.dispose();
                latController.dispose();
                lonController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingrese un nombre para la ubicación'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final lat = double.tryParse(latController.text.trim());
                final lon = double.tryParse(lonController.text.trim());

                if (lat == null || lon == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, ingrese coordenadas válidas'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Las coordenadas están fuera de rango válido'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final location = GeoLocation(
                  name: name,
                  latitude: lat,
                  longitude: lon,
                  type: selectedType,
                  risk: selectedRisk,
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  investigationId: widget.investigationId,
                );

                ref.read(geoLocationsProvider.notifier).addLocation(location);

                nameController.dispose();
                addressController.dispose();
                descriptionController.dispose();
                latController.dispose();
                lonController.dispose();
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('Ubicación "$name" añadida con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir Ubicación'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayuda - Análisis'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta pantalla proporciona herramientas completas de análisis para tu investigación:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text('• Resumen: Estadísticas generales'),
              SizedBox(height: 8),
              Text('• Timeline: Eventos cronológicos'),
              SizedBox(height: 8),
              Text('• Mapa: Análisis geográfico con mapas de calor'),
              SizedBox(height: 8),
              Text('• Búsqueda: Búsqueda avanzada en todos los datos'),
              SizedBox(height: 16),
              Text(
                'Usa las pestañas para cambiar entre las diferentes vistas de análisis.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
