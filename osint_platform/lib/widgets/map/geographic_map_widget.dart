import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/geo_location.dart';
import '../../providers/geo_location_provider.dart';

class GeographicMapWidget extends ConsumerStatefulWidget {
  final String investigationId;
  final Function(GeoLocation)? onLocationTap;
  final bool showFilters;
  final bool showHeatmap;

  const GeographicMapWidget({
    super.key,
    required this.investigationId,
    this.onLocationTap,
    this.showFilters = true,
    this.showHeatmap = false,
  });

  @override
  ConsumerState<GeographicMapWidget> createState() =>
      _GeographicMapWidgetState();
}

class _GeographicMapWidgetState extends ConsumerState<GeographicMapWidget> {
  final MapController _mapController = MapController();

  // Filters
  Set<GeoLocationType> selectedTypes = {};
  Set<LocationRisk> selectedRisks = {};
  bool showHeatmap = false;
  bool showPaths = false;

  // Default center (can be changed based on data)
  LatLng center = const LatLng(40.7128, -74.0060); // New York
  double zoom = 10.0;

  @override
  void initState() {
    super.initState();
    showHeatmap = widget.showHeatmap;
  }

  @override
  Widget build(BuildContext context) {
    final locations =
        ref.watch(locationsByInvestigationProvider(widget.investigationId));

    // Apply filters
    final filteredLocations = _filterLocations(locations);

    // Calculate center if we have locations
    if (filteredLocations.isNotEmpty && locations.isNotEmpty) {
      center = _calculateCenter(filteredLocations);
    }

    return Column(
      children: [
        if (widget.showFilters) _buildFilterBar(context),
        Expanded(
          child: filteredLocations.isEmpty
              ? _buildEmptyState()
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: zoom,
                        minZoom: 2,
                        maxZoom: 18,
                        onTap: (tapPosition, point) {
                          // Optional: Add location on tap
                        },
                      ),
                      children: [
                        // Tile Layer (OpenStreetMap)
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.osint.platform',
                          tileBuilder: _darkModeTileBuilder,
                        ),

                        // Heatmap Layer (simulated with circles)
                        if (showHeatmap)
                          CircleLayer(
                            circles: _buildHeatmapCircles(filteredLocations),
                          ),

                        // Path/Route Layer
                        if (showPaths && filteredLocations.length > 1)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: filteredLocations
                                    .map((loc) => loc.latLng)
                                    .toList(),
                                strokeWidth: 3,
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha:0.6),
                                borderStrokeWidth: 1,
                                borderColor: Colors.white.withValues(alpha:0.4),
                              ),
                            ],
                          ),

                        // Marker Layer
                        if (!showHeatmap)
                          MarkerLayer(
                            markers: _buildMarkers(context, filteredLocations),
                          ),
                      ],
                    ),
                    // Map Controls
                    _buildMapControls(context, filteredLocations),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Type Filter
            _buildFilterChip(
              context,
              icon: Icons.category,
              label: 'Type',
              onTap: () => _showTypeFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Risk Filter
            _buildFilterChip(
              context,
              icon: Icons.warning,
              label: 'Risk',
              onTap: () => _showRiskFilterDialog(context),
            ),
            const SizedBox(width: 8),

            // Heatmap Toggle
            _buildFilterChip(
              context,
              icon: showHeatmap ? Icons.heat_pump : Icons.place,
              label: showHeatmap ? 'Heatmap' : 'Markers',
              onTap: () => setState(() => showHeatmap = !showHeatmap),
            ),
            const SizedBox(width: 8),

            // Paths Toggle
            _buildFilterChip(
              context,
              icon: showPaths ? Icons.route : Icons.route_outlined,
              label: 'Routes',
              onTap: () => setState(() => showPaths = !showPaths),
            ),
            const SizedBox(width: 8),

            // Reset
            _buildFilterChip(
              context,
              icon: Icons.refresh,
              label: 'Reset',
              onTap: _resetFilters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildMapControls(
    BuildContext context,
    List<GeoLocation> locations,
  ) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        children: [
          // Zoom In
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),

          // Zoom Out
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              _mapController.move(
                _mapController.camera.center,
                _mapController.camera.zoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),

          // Fit All Markers
          if (locations.isNotEmpty)
            FloatingActionButton.small(
              heroTag: 'fit_bounds',
              onPressed: () => _fitBounds(locations),
              child: const Icon(Icons.fit_screen),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(
    BuildContext context,
    List<GeoLocation> locations,
  ) {
    return locations.map((location) {
      final color = _getLocationColor(location.type, location.risk);

      return Marker(
        point: location.latLng,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => widget.onLocationTap?.call(location),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shadow/Glow
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha:0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Marker Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha:0.9), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getLocationIcon(location.type),
                  color: Colors.white,
                  size: 16,
                ),
              ),
              // Risk Indicator
              if (location.risk == LocationRisk.critical ||
                  location.risk == LocationRisk.high)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<CircleMarker> _buildHeatmapCircles(List<GeoLocation> locations) {
    // Group locations by proximity for density calculation
    final densityMap = <LatLng, int>{};

    for (final location in locations) {
      // Round coordinates to create density clusters
      final roundedLat = (location.latitude * 100).round() / 100;
      final roundedLng = (location.longitude * 100).round() / 100;
      final key = LatLng(roundedLat, roundedLng);
      densityMap[key] = (densityMap[key] ?? 0) + 1;
    }

    final circles = <CircleMarker>[];

    for (final location in locations) {
      // Calculate density
      final roundedLat = (location.latitude * 100).round() / 100;
      final roundedLng = (location.longitude * 100).round() / 100;
      final key = LatLng(roundedLat, roundedLng);
      final density = densityMap[key] ?? 1;

      // Size and intensity based on density
      final baseRadius = 200.0;
      final radius = baseRadius + (density * 50);
      final intensity = (density / 10).clamp(0.2, 0.8);

      circles.add(
        CircleMarker(
          point: location.latLng,
          radius: radius,
          useRadiusInMeter: true,
          color: _getHeatmapColor(location.risk, intensity),
          borderColor: Colors.transparent,
          borderStrokeWidth: 0,
        ),
      );
    }

    return circles;
  }

  Color _getHeatmapColor(LocationRisk risk, double intensity) {
    Color baseColor;
    switch (risk) {
      case LocationRisk.critical:
        baseColor = Colors.red.shade900;
        break;
      case LocationRisk.high:
        baseColor = Colors.red.shade700;
        break;
      case LocationRisk.medium:
        baseColor = Colors.orange.shade600;
        break;
      case LocationRisk.low:
        baseColor = Colors.yellow.shade600;
        break;
      default:
        baseColor = Colors.blue.shade600;
    }
    return baseColor.withValues(alpha:intensity);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No locations to display',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add geographic locations to see them on the map',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  List<GeoLocation> _filterLocations(List<GeoLocation> locations) {
    return locations.where((location) {
      if (selectedTypes.isNotEmpty && !selectedTypes.contains(location.type)) {
        return false;
      }
      if (selectedRisks.isNotEmpty && !selectedRisks.contains(location.risk)) {
        return false;
      }
      return true;
    }).toList();
  }

  LatLng _calculateCenter(List<GeoLocation> locations) {
    double sumLat = 0;
    double sumLng = 0;

    for (final location in locations) {
      sumLat += location.latitude;
      sumLng += location.longitude;
    }

    return LatLng(
      sumLat / locations.length,
      sumLng / locations.length,
    );
  }

  void _fitBounds(List<GeoLocation> locations) {
    if (locations.isEmpty) return;

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (final location in locations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLng) minLng = location.longitude;
      if (location.longitude > maxLng) maxLng = location.longitude;
    }

    final bounds = LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  Color _getLocationColor(GeoLocationType type, LocationRisk risk) {
    if (risk == LocationRisk.critical) return Colors.red.shade900;
    if (risk == LocationRisk.high) return Colors.red.shade700;

    switch (type) {
      case GeoLocationType.residence:
        return Colors.blue.shade600;
      case GeoLocationType.business:
        return Colors.purple.shade600;
      case GeoLocationType.office:
        return Colors.indigo.shade600;
      case GeoLocationType.meeting:
        return Colors.orange.shade600;
      case GeoLocationType.event:
        return Colors.pink.shade600;
      case GeoLocationType.incident:
        return Colors.red.shade600;
      case GeoLocationType.surveillance:
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getLocationIcon(GeoLocationType type) {
    switch (type) {
      case GeoLocationType.residence:
        return Icons.home;
      case GeoLocationType.business:
        return Icons.business;
      case GeoLocationType.office:
        return Icons.apartment;
      case GeoLocationType.meeting:
        return Icons.handshake;
      case GeoLocationType.event:
        return Icons.event;
      case GeoLocationType.incident:
        return Icons.report_problem;
      case GeoLocationType.travel:
        return Icons.flight;
      case GeoLocationType.checkpoint:
        return Icons.flag;
      case GeoLocationType.poi:
        return Icons.star;
      case GeoLocationType.surveillance:
        return Icons.videocam;
      default:
        return Icons.place;
    }
  }

  Widget _darkModeTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    // Apply dark filter if in dark mode
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha:0.3),
          BlendMode.darken,
        ),
        child: tileWidget,
      );
    }
    return tileWidget;
  }

  void _showTypeFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Type'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: GeoLocationType.values.map((type) {
                return CheckboxListTile(
                  title: Text(type.displayName),
                  value: selectedTypes.contains(type),
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedTypes.add(type);
                      } else {
                        selectedTypes.remove(type);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedTypes.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showRiskFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Risk'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: LocationRisk.values.map((risk) {
              return CheckboxListTile(
                title: Text(risk.displayName),
                value: selectedRisks.contains(risk),
                onChanged: (value) {
                  setDialogState(() {
                    if (value == true) {
                      selectedRisks.add(risk);
                    } else {
                      selectedRisks.remove(risk);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => selectedRisks.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedTypes.clear();
      selectedRisks.clear();
      showHeatmap = false;
      showPaths = false;
    });
  }
}
