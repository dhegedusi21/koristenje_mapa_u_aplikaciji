import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAMPU Seminar',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  State createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng currentLocation = LatLng(46.3043, 16.3370);
  LatLng? tappedLocation;
  Set<Marker> permanentMarkers = Set();
  Set<Marker> temporaryMarkers = Set();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tappedLocation = null;
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    } else if (permission == LocationPermission.deniedForever) {

    }
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      // Set the default location to Varaždin, Croatia
      double varazdinLatitude = 46.3043;
      double varazdinLongitude = 16.3370;

      setState(() {
        currentLocation = LatLng(varazdinLatitude, varazdinLongitude);
        permanentMarkers.add(
          Marker(
            markerId: MarkerId('Trenutna Lokacija'),
            position: currentLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: 'Trenutna Lokacija',
            ),
          ),
        );
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      if (tappedLocation != null) {
        temporaryMarkers.removeWhere((marker) =>
        marker.position.latitude == tappedLocation!.latitude &&
            marker.position.longitude == tappedLocation!.longitude);
      }
      tappedLocation = location;
      temporaryMarkers.add(
        Marker(
          markerId: MarkerId(tappedLocation!.toString()),
          position: tappedLocation!,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  Future<void> _showNameDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Unesite ime POI-ja'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Ime',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Odustani'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addPOI();
              },
              child: Text('Dodaj'),
            ),
          ],
        );
      },
    );
  }

  void _addPOI() {
    if (tappedLocation != null) {
      permanentMarkers.add(
        Marker(
          markerId: MarkerId(tappedLocation!.toString()),
          position: tappedLocation!,
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: nameController.text.isNotEmpty ? nameController.text : 'POI',
          ),
        ),
      );
      setState(() {
        tappedLocation = null;
        temporaryMarkers.clear();
        nameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RAMPU Seminar'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              onTap: _onMapTap,
              initialCameraPosition: CameraPosition(
                target: currentLocation,
                zoom: 10.0,
              ),
              markers: permanentMarkers.union(temporaryMarkers),
            ),
          ),
          if (tappedLocation != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Odabrana Lokacija: ${tappedLocation!.latitude.toStringAsFixed(6)}, ${tappedLocation!.longitude.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              _showNameDialog();
            },
            child: Text('Dodaj POI'),
          ),
        ],
      ),
    );
  }
}
