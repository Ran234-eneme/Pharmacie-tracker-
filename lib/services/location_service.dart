import 'package:geolocator/geolocator.dart';

/// Gère la localisation de l'utilisateur : permissions + position actuelle.
class LocationService {
  /// Vérifie et demande les permissions nécessaires, puis retourne
  /// la position actuelle de l'utilisateur.
  ///
  /// Lève une exception avec un message clair si la localisation
  /// est désactivée ou refusée, à afficher directement à l'utilisateur.
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'La localisation est désactivée. Active-la dans les réglages de ton téléphone.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Permission de localisation refusée. Autorise-la pour trouver les pharmacies proches.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permission de localisation bloquée définitivement. Active-la dans les réglages de l\'app.',
      );
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Distance en mètres entre deux points (formule via Geolocator, basée sur Haversine).
  double distanceInMeters(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
