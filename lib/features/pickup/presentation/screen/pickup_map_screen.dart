import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:geolocator/geolocator.dart';

class CollectorRouteMapScreen extends StatefulWidget {
  const CollectorRouteMapScreen({super.key});

  @override
  State<CollectorRouteMapScreen> createState() =>
      _CollectorRouteMapScreenState();
}

class _CollectorRouteMapScreenState extends State<CollectorRouteMapScreen> {
  LatLng? userLocation;
  final LatLng collectorLocation = LatLng(-7.260445, 112.758845);

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final LocationSettings locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        );

        Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        setState(() {
          userLocation = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        toastification.show(
          type: ToastificationType.error,
          title: const Text("Gagal mendapatkan lokasi"),
          description: Text(e.toString()),
        );
      }
    } else if (status.isDenied) {
      toastification.show(
        type: ToastificationType.warning,
        title: const Text("Izin lokasi ditolak sementara"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else if (status.isPermanentlyDenied) {
      toastification.show(
        type: ToastificationType.error,
        title: const Text("Izin lokasi ditolak permanen"),
        description: const Text(
          "Buka pengaturan untuk mengaktifkan izin lokasi.",
        ),
      );
    }
  }

  Future<void> openMapWithGoogle(double latitude, double longitude) async {
    if (userLocation == null) return;
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=${userLocation!.latitude},${userLocation!.longitude}&destination=$latitude,$longitude';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      toastification.show(
        type: ToastificationType.error,
        title: const Text("Gagal membuka Google Maps"),
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(judul: "Lokasi Pengguna"),
      body:
          userLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: userLocation!,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: userLocation!,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 36,
                            ),
                          ),
                          Marker(
                            point: collectorLocation,
                            child: const Icon(
                              Icons.store,
                              color: Colors.green,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [userLocation!, collectorLocation],
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
