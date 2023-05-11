import 'dart:async';

import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Session.dart';
import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/Order_Model.dart';
import 'package:eshop_multivendor/Provider/HomeProvider.dart';
import 'package:eshop_multivendor/Screen/HomePage.dart';
import 'package:eshop_multivendor/Screen/map_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LiveTrackPage extends StatefulWidget {
  final String? driverId, distance;
  final OrderModel? data;
  final OrderItem? sellerData;

  const LiveTrackPage({Key? key, this.driverId, this.distance, this.data, this.sellerData}) : super(key: key);

  @override
  _LiveTrackPageState createState() => _LiveTrackPageState();
}
DatabaseReference ref = FirebaseDatabase.instance.ref("users/123");
class _LiveTrackPageState extends State<LiveTrackPage> {


  Stream<DatabaseEvent> stream = ref.onValue;


  GoogleMapController? mapController;
  Completer<GoogleMapController> _controller = Completer();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  double _originLatitude = 22.7196, _originLongitude = 75.8577;
  double _destLatitude = 23.2599, _destLongitude = 77.4126;
  String googleAPiKey = "AIzaSyBq52y-MtlJa6wtmzZ1XIz3LTbwBpaWXuU";
  Marker? driverMarker;


  late BitmapDescriptor myIcon;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(22.7196, 75.8577),
    zoom: 18,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(22.7196, 75.8577),
      // tilt: 59.440717697143555,
      zoom: 18);

  double dNewLat = 0;
  double dNewLong = 0;




  Timer? timer;

  void moveMarker(double latitude, double longitude) {
    setState(() {
      driverMarker = driverMarker!.copyWith(
        positionParam: LatLng(latitude, longitude),
      );
    });
  }

  Future<void> _driver(dlat , dLong) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
    driverMarker = Marker(
      markerId: MarkerId('Driver'),
      position: LatLng(dNewLat, dNewLong),
      icon: myIcon,
      infoWindow: InfoWindow(
        title: 'Driver Name',
        snippet: 'address',
      ),
    );
    setState(() {
      markers[MarkerId('place_name')] = driverMarker!;
    });
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        geodesic: true,
        jointType: JointType.round,
        width: 5,
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving , optimizeWaypoints: true);
    if (result.points.isNotEmpty) {
      print(result.points);
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }

  double? lat, long;
  LocationPermission? permission;
  Position? currentLocation;
  Future getUserCurrentLocation() async {

    permission = await Geolocator.requestPermission();
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      if (mounted)
        setState(() {
          currentLocation = position;
          lat = currentLocation!.latitude;
          long = currentLocation!.longitude;
        });


    });
    print("LOCATION===" + currentLocation.toString());
  }

  getDriverLocation(String driverId){
    Map parameter = {
      USER_ID: driverId.toString(),
    };
    apiBaseHelper.postAPICall(getDriverLocationApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

       setState(() {
         dNewLat = double.parse(data['latitude']);
         dNewLong = double.parse(data['longitude']);
       });
       print("this is driver lat long $dNewLat and $dNewLong");
        // _driver(dNewLat , dNewLong);
        moveMarker(dNewLat, dNewLong);

      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  // setPolylines() async {
  //   _polylines.clear();
  //   if (widget.live && widget.status1 != null && widget.status1 == "1") {
  //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //         googleAPIKey,
  //         PointLatLng(driveLat, driveLng),
  //         PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
  //         travelMode: TravelMode.driving,
  //         optimizeWaypoints: true);
  //     print("${result.points} >>>>>>>>>>>>>>>>..");
  //     print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
  //     print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
  //     print(result.errorMessage);
  //     if (result.points.isNotEmpty) {
  //       // loop through all PointLatLng points and convert them
  //       // to a list of LatLng, required by the Polyline
  //       result.points.forEach((PointLatLng point) {
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //       });
  //     } else {
  //       print("Failed");
  //     }
  //     setState(() {
  //       // create a Polyline instance
  //       // with an id, an RGB color and the list of LatLng pairs
  //       Polyline polyline = Polyline(
  //           width: 8,
  //           polylineId: PolylineId("poly"),
  //           color: Theme.of(context).primaryColorDark,
  //           points: polylineCoordinates);
  //       // add the constructed polyline as a set of points
  //       // to the polyline set, which will eventually
  //       // end up showing up on the map
  //       _polylines.add(polyline);
  //     });
  //   } else {
  //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //         googleAPIKey,
  //         PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
  //         PointLatLng(DEST_LOCATION!.latitude, DEST_LOCATION!.longitude),
  //         travelMode: TravelMode.driving,
  //         optimizeWaypoints: true);
  //     print("${result.points} >>>>>>>>>>>>>>>>..");
  //     print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
  //     print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
  //     print(result.errorMessage);
  //     if (result.points.isNotEmpty) {
  //       // loop through all PointLatLng points and convert them
  //       // to a list of LatLng, required by the Polyline
  //       result.points.forEach((PointLatLng point) {
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //       });
  //     } else {
  //       print("Failed");
  //     }
  //     setState(() {
  //       // create a Polyline instance
  //       // with an id, an RGB color and the list of LatLng pairs
  //       Polyline polyline = Polyline(
  //           width: 8,
  //           polylineId: PolylineId("poly"),
  //           color: Theme.of(context).primaryColorDark,
  //           points: polylineCoordinates);
  //       // add the constructed polyline as a set of points
  //       // to the polyline set, which will eventually
  //       // end up showing up on the map
  //       _polylines.add(polyline);
  //     });
  //   }
  //
  //   /*if (widget.status1 != null &&
  //       widget.status1 == "1" &&
  //       driveLat != 0 &&
  //       widget.live) {
  //     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //         googleAPIKey,
  //         PointLatLng(driveLat, driveLng),
  //         PointLatLng(SOURCE_LOCATION!.latitude, SOURCE_LOCATION!.longitude),
  //         travelMode: TravelMode.driving,
  //         optimizeWaypoints: true);
  //     print("${result.points} >>>>>>>>>>>>>>>>..");
  //     print("$SOURCE_LOCATION >>>>>>>>>>>>>>>>..");
  //     print("$DEST_LOCATION >>>>>>>>>>>>>>>>..");
  //     print(result.errorMessage);
  //     if (result.points.isNotEmpty) {
  //       // loop through all PointLatLng points and convert them
  //       // to a list of LatLng, required by the Polyline
  //       result.points.forEach((PointLatLng point) {
  //         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //       });
  //     } else {
  //       print("Failed");
  //     }
  //     setState(() {
  //       // create a Polyline instance
  //       // with an id, an RGB color and the list of LatLng pairs
  //       Polyline polyline = Polyline(
  //           width: 5,
  //           polylineId: PolylineId("poly"),
  //           color: AppTheme.primaryColor,
  //           points: polylineCoordinates);
  //       // add the constructed polyline as a set of points
  //       // to the polyline set, which will eventually
  //       // end up showing up on the map
  //       _polylines.add(polyline);
  //     });
  //   } else {
  //
  //   }*/
  // }
  //
  // void setSourceAndDestinationIcons() async {
  //   sourceIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/aPin.png');
  //   if (widget.live) {
  //     driverIcon = await BitmapDescriptor.fromAssetImage(
  //         ImageConfiguration(devicePixelRatio: 0.2),
  //         'assets/images/driving.png');
  //   }
  //   destinationIcon = await BitmapDescriptor.fromAssetImage(
  //       ImageConfiguration(devicePixelRatio: 2.5), 'assets/images/bPin.png');
  //   if (widget.status) {
  //     SOURCE_LOCATION = widget.SOURCE_LOCATION;
  //     DEST_LOCATION = widget.DEST_LOCATION;
  //     setMapPins();
  //     setPolylines();
  //
  //     /* if (widget.live) {
  //
  //     }*/
  //   }
  // }


  // getDriverLocation()async{
  //   stream.listen((DatabaseEvent event) {
  //     dynamic a = event.snapshot.value;
  //     dNewLat = a["address"]["lat"];
  //     dNewLong = a["address"]["long"];
  //     print('Event Type: ${event.type}'); // DatabaseEventType.value;
  //   });
  // }
  // Timer mytimer = Timer.periodic(Duration(seconds: 5), (timer) {
  //   //code to run on every 5 seconds
  // });

  @override
  void initState() {
    super.initState();
    setState((){
      _originLatitude = double.parse(widget.data!.lat.toString());
      _originLongitude = double.parse(widget.data!.long.toString());
      _destLatitude = double.parse(widget.sellerData!.sellerLat.toString());
      _destLongitude = double.parse(widget.sellerData!.sellerLong.toString());
    });


    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(10, 10)), 'assets/images/driver.png')
        .then((onValue) {
          setState(() {
            driverMarker = Marker(
                markerId: MarkerId('marker_1'),
                position: LatLng(37.7749, -122.4194),
                icon: onValue// Initial position
            );
          });
      // myIcon = onValue;
    });
    print("this is driver id ${widget.driverId}");
    getDriverLocation(widget.driverId.toString());
    _getPolyline();
    // timer = Timer.periodic(Duration(seconds: 2), (Timer t) => getDriverLocation());
    timer = Timer.periodic(Duration(seconds: 3), (timer) {
      getDriverLocation(widget.driverId.toString());
    });

  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      widget.data!.lat != null ? 
      MapPage(
        true,
        id: widget.driverId != null &&
            widget.driverId != ""
            ? widget.driverId
            : "",
        live: widget.driverId != null &&
            widget.driverId != ""
            ? true
            : false,
        SOURCE_LOCATION: LatLng(_originLatitude, _originLongitude),
        DEST_LOCATION: LatLng(_destLatitude, _destLongitude),
        status1: '1',
        zoom: 14,
      )
            : Center(
        child: CircularProgressIndicator(),
    ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width/2,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: colors.primary
        ),
        child:   Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Distance - ",
                // getTranslated(context,
                //     "PAYMENT_MTHD")! +
                //     " - ",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: colors.whiteTemp, fontSize: 14),
              ),
              Text(
                widget.distance != null || widget.distance != ''?
                widget.distance.toString()
                    : '',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: colors.whiteTemp, fontWeight: FontWeight.w600, fontSize: 14),
              ),

            ],
          ),
        ),
      ),
      // GoogleMap(
      //   mapType: MapType.normal,
      //   initialCameraPosition: _kGooglePlex,
      //   // markers: markers.values.toSet(),
      //   // polylines: Set<Polyline>.of(polylines.values),
      //   myLocationEnabled: true,
      //   markers: Set<Marker>.of([driverMarker!]), // Add the marker to the map
      //   onMapCreated: (GoogleMapController controller) {
      //     mapController = controller;
      //   },
      //   // onMapCreated: _onMapCreated,
      //   // onMapCreated: (GoogleMapController controller) {
      //   //   _controller.complete(controller);
      //   // },
      // ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () {
    //       _driver(dNewLat , dNewLong);
    //     },
    //     child: Icon(Icons.center_focus_strong),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
