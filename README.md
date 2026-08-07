# Pharmacie Tracker

Application Flutter qui localise les pharmacies à proximité de l'utilisateur,
en s'appuyant sur les données OpenStreetMap (via l'API Overpass — gratuite,
sans clé API).

## Fonctionnalités (v0.1)

- Demande la position de l'utilisateur
- Recherche les pharmacies dans un rayon de 5 km (Overpass API)
- Affiche une carte (OpenStreetMap) avec la position + les pharmacies
- Liste triée par distance croissante
- Tap sur une pharmacie → recentre la carte dessus

*(La fonctionnalité "pharmacie de garde" est volontairement exclue de cette
première version.)*

## Installation

Ce projet a été généré à la main (sans le SDK Flutter installé côté
génération), il te manque donc les fichiers de plateforme générés
automatiquement par `flutter create`. Étapes :

```bash
flutter create . --platforms=android,ios --org com.okeshstudios
flutter pub get
flutter run
