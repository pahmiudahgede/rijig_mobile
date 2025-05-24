import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:url_launcher/url_launcher.dart';

class CollectorRouteMapScreen extends StatefulWidget {
  const CollectorRouteMapScreen({super.key});

  @override
  State<CollectorRouteMapScreen> createState() =>
      _CollectorRouteMapScreenState();
}

class _CollectorRouteMapScreenState extends State<CollectorRouteMapScreen> {
  final LatLng userLocation = LatLng(-7.250445, 112.768845);
  final LatLng collectorLocation = LatLng(-7.260445, 112.758845);

  Future<void> openMapWithGoogle(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("tidak dapat membuka google maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peta Lokasi"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: userLocation, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation,
                    child: Icon(Icons.location_on, color: redColor, size: 36),
                  ),
                  Marker(
                    point: collectorLocation,
                    child: Icon(Icons.store, color: primaryColor, size: 36),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [userLocation, collectorLocation],
                    strokeWidth: 4,
                    color: Colors.orange,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: PaddingCustom().paddingVertical(14),
              ),
              onPressed:
                  () => openMapWithGoogle(
                    collectorLocation.latitude,
                    collectorLocation.longitude,
                  ),
              child: const Text("Buka di Google Maps"),
            ),
          ),
        ],
      ),
    );
  }
}
