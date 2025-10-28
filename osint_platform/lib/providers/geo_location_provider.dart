import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/geo_location.dart';
import 'package:latlong2/latlong.dart';

/// State Notifier for managing geographic locations
class GeoLocationsNotifier extends StateNotifier<List<GeoLocation>> {
  GeoLocationsNotifier() : super([]);

  void addLocation(GeoLocation location) {
    state = [...state, location];
  }

  void updateLocation(GeoLocation updatedLocation) {
    state = [
      for (final location in state)
        if (location.id == updatedLocation.id) updatedLocation else location,
    ];
  }

  void removeLocation(String locationId) {
    state = state.where((location) => location.id != locationId).toList();
  }

  void clearLocations() {
    state = [];
  }

  GeoLocation? getLocationById(String id) {
    try {
      return state.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  List<GeoLocation> getLocationsByType(GeoLocationType type) {
    return state.where((location) => location.type == type).toList();
  }

  List<GeoLocation> getLocationsByRisk(LocationRisk risk) {
    return state.where((location) => location.risk == risk).toList();
  }

  List<GeoLocation> searchLocations(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((location) {
      return location.name.toLowerCase().contains(lowerQuery) ||
          (location.description?.toLowerCase().contains(lowerQuery) ?? false) ||
          (location.address?.toLowerCase().contains(lowerQuery) ?? false) ||
          (location.city?.toLowerCase().contains(lowerQuery) ?? false) ||
          location.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Get locations within a bounding box
  List<GeoLocation> getLocationsInBounds(LatLng southwest, LatLng northeast) {
    return state.where((location) {
      return location.latitude >= southwest.latitude &&
          location.latitude <= northeast.latitude &&
          location.longitude >= southwest.longitude &&
          location.longitude <= northeast.longitude;
    }).toList();
  }

  /// Get locations within a radius (in kilometers) from a center point
  List<GeoLocation> getLocationsNearby(LatLng center, double radiusKm) {
    final distance = const Distance();
    return state.where((location) {
      final locationPoint = LatLng(location.latitude, location.longitude);
      final distanceKm = distance.as(LengthUnit.Kilometer, center, locationPoint);
      return distanceKm <= radiusKm;
    }).toList();
  }

  /// Get locations related to a specific entity
  List<GeoLocation> getLocationsForEntity(String entityId) {
    return state.where((location) => location.entityIds.contains(entityId)).toList();
  }

  /// Get locations related to a specific event
  List<GeoLocation> getLocationsForEvent(String eventId) {
    return state.where((location) => location.eventIds.contains(eventId)).toList();
  }
}

/// Provider for geographic locations
final geoLocationsProvider =
    StateNotifierProvider<GeoLocationsNotifier, List<GeoLocation>>((ref) {
  return GeoLocationsNotifier();
});

/// Derived provider: Get locations by investigation ID
final locationsByInvestigationProvider =
    Provider.family<List<GeoLocation>, String>((ref, investigationId) {
  final locations = ref.watch(geoLocationsProvider);
  return locations
      .where((location) => location.investigationId == investigationId)
      .toList();
});

/// Derived provider: Get high-risk locations
final highRiskLocationsProvider = Provider<List<GeoLocation>>((ref) {
  final locations = ref.watch(geoLocationsProvider);
  return locations
      .where((location) =>
          location.risk == LocationRisk.high ||
          location.risk == LocationRisk.critical)
      .toList();
});

/// Derived provider: Geographic statistics
final geoStatsProvider = Provider<GeoStats>((ref) {
  final locations = ref.watch(geoLocationsProvider);

  LatLng? center;
  if (locations.isNotEmpty) {
    double sumLat = 0;
    double sumLng = 0;
    for (final loc in locations) {
      sumLat += loc.latitude;
      sumLng += loc.longitude;
    }
    center = LatLng(sumLat / locations.length, sumLng / locations.length);
  }

  return GeoStats(
    totalLocations: locations.length,
    locationsByType: _countByType(locations),
    locationsByRisk: _countByRisk(locations),
    centerPoint: center,
  );
});

Map<GeoLocationType, int> _countByType(List<GeoLocation> locations) {
  final counts = <GeoLocationType, int>{};
  for (final location in locations) {
    counts[location.type] = (counts[location.type] ?? 0) + 1;
  }
  return counts;
}

Map<LocationRisk, int> _countByRisk(List<GeoLocation> locations) {
  final counts = <LocationRisk, int>{};
  for (final location in locations) {
    counts[location.risk] = (counts[location.risk] ?? 0) + 1;
  }
  return counts;
}

class GeoStats {
  final int totalLocations;
  final Map<GeoLocationType, int> locationsByType;
  final Map<LocationRisk, int> locationsByRisk;
  final LatLng? centerPoint;

  GeoStats({
    required this.totalLocations,
    required this.locationsByType,
    required this.locationsByRisk,
    this.centerPoint,
  });
}
