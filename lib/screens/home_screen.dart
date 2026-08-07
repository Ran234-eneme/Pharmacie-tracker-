import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pharmacy.dart';
import '../services/location_service.dart';
import '../services/pharmacy_service.dart';
import '../widgets/pharmacy_list_tile.dart';

enum _LoadState { loading, success, error }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _locationService = LocationService();
  final _pharmacyService = PharmacyService();
  final _mapController = MapController();

  _LoadState _state = _LoadState.loading;
  String? _errorMessage;
  Position? _userPosition;
  List<Pharmacy> _pharmacies = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyPharmacies();
  }

  Future<void> _loadNearbyPharmacies() async {
    setState(() {
      _state = _LoadState.loading;
      _errorMessage = null;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      final pharmacies = await _pharmacyService.fetchNearbyPharmacies(
        lat: position.latitude,
        lon: position.longitude,
      );

      // Tri par distance croissante depuis la position de l'utilisateur.
      pharmacies.sort((a, b) {
        final distA = _locationService.distanceInMeters(
          position.latitude, position.longitude,
          a.location.latitude, a.location.longitude,
        );
        final distB = _locationService.distanceInMeters(
          position.latitude, position.longitude,
          b.location.latitude, b.location.longitude,
        );
        return distA.compareTo(distB);
      });

      setState(() {
        _userPosition = position;
        _pharmacies = pharmacies;
        _state = _LoadState.success;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _state = _LoadState.error;
      });
    }
  }

  double? _distanceTo(Pharmacy p) {
    if (_userPosition == null) return null;
    return _locationService.distanceInMeters(
      _userPosition!.latitude, _userPosition!.longitude,
      p.location.latitude, p.location.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacies à proximité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _state == _LoadState.loading ? null : _loadNearbyPharmacies,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _LoadState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Recherche des pharmacies proches...'),
            ],
          ),
        );

      case _LoadState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'Une erreur est survenue.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadNearbyPharmacies,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        );

      case _LoadState.success:
        if (_pharmacies.isEmpty) {
          return const Center(
            child: Text('Aucune pharmacie trouvée dans un rayon de 5 km.'),
          );
        }
        return Column(
          children: [
            SizedBox(
              height: 260,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    _userPosition!.latitude,
                    _userPosition!.longitude,
                  ),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.okeshstudios.pharmacie_tracker',
                  ),
                  MarkerLayer(
                    markers: [
                      // Position de l'utilisateur.
                      Marker(
                        point: LatLng(_userPosition!.latitude, _userPosition!.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                      ),
                      // Pharmacies.
                      ..._pharmacies.map(
                        (p) => Marker(
                          point: p.location,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.local_pharmacy, color: Colors.green, size: 32),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: _pharmacies.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final pharmacy = _pharmacies[index];
                  return PharmacyListTile(
                    pharmacy: pharmacy,
                    distanceMeters: _distanceTo(pharmacy),
                    onTap: () {
                      _mapController.move(pharmacy.location, 16);
                    },
                  );
                },
              ),
            ),
          ],
        );
    }
  }
}
