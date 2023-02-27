import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:intl/intl.dart';
import 'package:lab_mis/services/notification.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../model/appointment.dart';

class MapScreen extends StatefulWidget {
  static const String idScreen = "mapScreen";
  final List<Termin> _appointments;
  MapScreen(this._appointments);

  @override
  _MapScreenState createState() => _MapScreenState(_appointments);
}

class _MapScreenState extends State<MapScreen> {
  final NotificationService service = NotificationService();
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> markers = <Marker>[];
  Map<PolylineId, Polyline> polylines = {};
  final List<Termin> _appointments;
  String googleAPI = 'AIzaSyBZjkjS5oxwbkKpc4LAp5KU25QHwPrpy3M';

  _MapScreenState(this._appointments);

  @override
  void initState() {
    super.initState();
    _setMarkers(_appointments);
    _setGeofence();
  }

  void _notification() async {
    await service.showNotification(
        id: 0,
        title: 'You have scheduled exams in this location!',
        body: 'Check your calendar');
  }

  void _setGeofence() {
    const double fenceLat = 42.0043165;
    const double fenceLong = 21.4096452;
    const double fenceRadius = 300.0; // meters

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      double distance = Geolocator.distanceBetween(
          position.latitude, position.longitude, fenceLat, fenceLong);
      if (distance <= fenceRadius) {
        _notification();
      }
    });
  }

  static const CameraPosition _kGoogle = CameraPosition(
    target: LatLng(42.00189631487379, 21.40748422242309),
    zoom: 14.4746,
  );

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  void _getShortestRoute(LatLng userLocationCoordinates,
      LatLng destinationLocationCoordinates) async {
    PolylinePoints polylinePoints = PolylinePoints();

    addPolyLine(List<LatLng> polylineCoordinates) {
      PolylineId id = const PolylineId("poly");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 8,
      );
      polylines[id] = polyline;
      setState(() {});
    }

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleAPI,
      PointLatLng(
          userLocationCoordinates.latitude, userLocationCoordinates.longitude),
      PointLatLng(destinationLocationCoordinates.latitude,
          destinationLocationCoordinates.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    addPolyLine(polylineCoordinates);
  }

  void _setMarkers(appointments) {
    for (var i = 0; i < appointments.length; i++) {
      markers.add(Marker(
          markerId: MarkerId(i.toString()),
          position:
              LatLng(appointments[i].location.latitude, appointments[i].location.longitude),
          infoWindow: InfoWindow(
            title: appointments[i].title,
            snippet: DateFormat("yyyy-MM-dd HH:mm:ss").format(appointments[i].date),
          ),
          icon: BitmapDescriptor.defaultMarker, //Icon for Marker
          onTap: () {
            //on tap we get shortest route to the selected location
            getUserCurrentLocation().then((userLocation) async {
              LatLng destinationLocationCoordinates = LatLng(
                  appointments[i].location.latitude, appointments[i].location.longitude);
              LatLng userLocationCoordinates =
                  LatLng(userLocation.latitude, userLocation.longitude);
              _getShortestRoute(
                  userLocationCoordinates, destinationLocationCoordinates);
            });
          }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps"),
      ),
      body: SafeArea(
        child: GoogleMap(
          //adding marker for every exam location
          markers: Set<Marker>.of(markers),
          polylines: Set<Polyline>.of(polylines.values),
          initialCameraPosition: _kGoogle,
          mapType: MapType.normal,
          myLocationEnabled: true,
          compassEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () async {
          getUserCurrentLocation().then((value) async {
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 16,
            );

            final GoogleMapController controller = await _controller.future;
            controller
                .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {});
          });
        },
        child: const Icon(
          Icons.center_focus_strong_rounded,
          color: Colors.black,
        ),
      ),
    );
  }
}
