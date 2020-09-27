import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapWidgetView extends StatefulWidget {
  @override
  _GoogleMapWidgetViewState createState() => _GoogleMapWidgetViewState();
}

class _GoogleMapWidgetViewState extends State<GoogleMapWidgetView> {
  Completer<GoogleMapController> _googleMapController = Completer();
  static const LatLng _center = const LatLng(24.7136, 46.6753);

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  @override
  void initState() {
    this.askLocationPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose event location'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
      ),
      body: GoogleMap(
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) async {
          _googleMapController.complete(controller);
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }

  askLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }
}
