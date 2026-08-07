import 'package:latlong2/latlong.dart';

/// Représente une pharmacie récupérée depuis OpenStreetMap (Overpass API).
class Pharmacy {
  final String id;
  final String name;
  final LatLng location;
  final String? address;
  final String? phone;
  final String? openingHours;

  Pharmacy({
    required this.id,
    required this.name,
    required this.location,
    this.address,
    this.phone,
    this.openingHours,
  });

  /// Construit une Pharmacy à partir d'un élément JSON renvoyé par Overpass.
  factory Pharmacy.fromOverpassElement(Map<String, dynamic> element) {
    final tags = (element['tags'] as Map?) ?? {};

    // Un "node" a lat/lon directement ; un "way"/"relation" a un "center".
    final double lat = (element['lat'] ?? element['center']?['lat'] ?? 0.0).toDouble();
    final double lon = (element['lon'] ?? element['center']?['lon'] ?? 0.0).toDouble();

    // Construction d'une adresse lisible à partir des tags OSM courants.
    final street = tags['addr:street'];
    final houseNumber = tags['addr:housenumber'];
    final city = tags['addr:city'];
    String? address;
    if (street != null) {
      address = [
        if (houseNumber != null) houseNumber,
        street,
        if (city != null) city,
      ].join(' ');
    }

    return Pharmacy(
      id: '${element['type']}/${element['id']}',
      name: tags['name'] ?? 'Pharmacie',
      location: LatLng(lat, lon),
      address: address,
      phone: tags['phone'] ?? tags['contact:phone'],
      openingHours: tags['opening_hours'],
    );
  }
}
