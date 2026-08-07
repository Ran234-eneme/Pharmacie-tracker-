import 'package:flutter/material.dart';
import '../models/pharmacy.dart';

/// Affiche une pharmacie dans la liste : nom, distance, adresse.
class PharmacyListTile extends StatelessWidget {
  final Pharmacy pharmacy;
  final double? distanceMeters;
  final VoidCallback? onTap;

  const PharmacyListTile({
    super.key,
    required this.pharmacy,
    this.distanceMeters,
    this.onTap,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(Icons.local_pharmacy, color: Colors.green),
      ),
      title: Text(pharmacy.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: pharmacy.address != null ? Text(pharmacy.address!) : null,
      trailing: distanceMeters != null
          ? Text(
              _formatDistance(distanceMeters!),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            )
          : null,
      onTap: onTap,
    );
  }
}
