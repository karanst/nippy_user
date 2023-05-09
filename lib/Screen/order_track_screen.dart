import 'dart:async';

import 'package:eshop_multivendor/Screen/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackScreen extends StatefulWidget {
  const OrderTrackScreen({Key? key}) : super(key: key);

  @override
  State<OrderTrackScreen> createState() => _OrderTrackScreenState();
}

class _OrderTrackScreenState extends State<OrderTrackScreen> {

  LocationData? currentLocation;
  // List<LatLng> polylineCoordinates = [];
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(22.69483805, 75.8539948170826);
  static const LatLng destination = LatLng(22.75617665, 75.90866593233139);


  // void getPolyPoints() async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     'AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU',
  //     PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
  //     PointLatLng(destination.latitude, destination.longitude),
  //   );
  //   if (result.points.isNotEmpty) {
  //     result.points.forEach(
  //           (PointLatLng point) => polylineCoordinates.add(
  //         LatLng(point.latitude, point.longitude),
  //       ),
  //     );
  //     setState(() {});
  //   }
  // }

  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
          (location) {
        currentLocation = location;
      },
    );
    print("this is current location --->>>> $currentLocation");
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen(
          (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  //
  // BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  // BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  // BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  // void setCustomMarkerIcon() {
  //   BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration.empty, "assets/logo/source.png")
  //       .then(
  //         (icon) {
  //       sourceIcon = icon;
  //     },
  //   );
  //   BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration.empty, "assets/logo/arrival.png")
  //       .then(
  //         (icon) {
  //       destinationIcon = icon;
  //     },
  //   );
  //   BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration.empty, "assets/logo/flag.png")
  //       .then(
  //         (icon) {
  //       currentLocationIcon = icon;
  //     },
  //   );
  // }


  @override
  void initState() {
    // getPolyPoints();
    getCurrentLocation();
    // setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentLocation == null? MapPage(
        true,
        // driveList: [],
        live: true,
        pick: "Vijay Nagar, Indore",
        dest: 'Mahalakshami Nagar, Indore',
        id: '12',
        // carType: widget.model.taxiType=="Bike"?"1":"2",
        // status1 :widget.model.acceptReject,
        SOURCE_LOCATION: sourceLocation,
         DEST_LOCATION: destination,
      ):Center(child: CircularProgressIndicator(),),


      // currentLocation == null
      //     ? const Center(child: Text("Loading"))
      //     : GoogleMap(
      //   initialCameraPosition: CameraPosition(
      //     target: LatLng(
      //         currentLocation!.latitude!, currentLocation!.longitude!),
      //     zoom: 13.5,
      //   ),
      //   markers: {
      //     Marker(
      //       markerId: const MarkerId("currentLocation"),
      //       position: LatLng(
      //           currentLocation!.latitude!, currentLocation!.longitude!),
      //     ),
      //     const Marker(
      //       markerId: MarkerId("source"),
      //       position: sourceLocation,
      //     ),
      //     const Marker(
      //       markerId: MarkerId("destination"),
      //       position: destination,
      //     ),
      //   },
      //   onMapCreated: (mapController) {
      //     _controller.complete(mapController);
      //   },
      //   polylines: {
      //     Polyline(
      //       polylineId: const PolylineId("route"),
      //       points: polylineCoordinates,
      //       color: const Color(0xFF7B61FF),
      //       width: 6,
      //     ),
      //   },
      // ),
    );
  }
}
