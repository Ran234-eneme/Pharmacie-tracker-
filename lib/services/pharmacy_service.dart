import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pharmacy.dart';

/// Récupère les pharmacies à proximité via l'API Overpass
/// (données OpenStreetMap, gratuites, sans clé API).
class PharmacyService {
  // Plusieurs miroirs Overpass en cas d'indisponibilité de l'un d'eux.
  static const List<String> _endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Recherche les pharmacies dans un rayon [radiusMeters] autour de
  /// [lat]/[lon]. Le tri par proximité n'est PAS fait ici — il se fait
  /// côté UI une fois la distance calculée.
  Future<List<Pharmacy>> fetchNearbyPharmacies({
    required double lat,
    required double lon,
    double radiusMeters = 5000,
  }) async {
    final query = '''
      [out:json][timeout:25];
      (
        node["amenity"="pharmacy"](around:$radiusMeters,$lat,$lon);
        way["amenity"="pharmacy"](around:$radiusMeters,$lat,$lon);
      );
      out center tags;
    ''';

    Exception? lastError;

    for (final endpoint in _endpoints) {
      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              body: {'data': query},
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final elements = (data['elements'] as List?) ?? [];
          return elements
              .map((e) => Pharmacy.fromOverpassElement(e as Map<String, dynamic>))
              .where((p) => p.location.latitude != 0.0 && p.location.longitude != 0.0)
              .toList();
        } else {
          lastError = Exception('Erreur serveur (${response.statusCode})');
        }
      } catch (e) {
        lastError = Exception('Erreur réseau : $e');
        continue;
      }
    }

    throw lastError ?? Exception('Impossible de récupérer les pharmacies.');
  }
}
