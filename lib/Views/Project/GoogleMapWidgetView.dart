import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:search_map_place/search_map_place.dart';
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

  Location location = new Location();
  static const LatLng _center = const LatLng(24.7136, 46.6753);
  String pickedLocation;

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
      body: Stack(
        children: <Widget>[
          // Replace this container with your Map widget
          GoogleMap(
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) async {
              _googleMapController.complete(controller);
            },

            rotateGesturesEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
          ),
          PlacePicker(
            apiKey: "AIzaSyDKdZ_rD-q3ENKmik8M_iUAAZFVQEdnREI",   // Google maps API Key.
            onPlacePicked: (result) {
              pickedLocation = result.geometry.location.lat.toString() + "," + result.geometry.location.lng.toString();
              Get.back(result: pickedLocation);
            },
            selectInitialPosition: true,
            enableMyLocationButton: true,
            initialPosition: _center,
            useCurrentLocation: true,
            myLocationButtonCooldown: 2,
          )
        ],
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
