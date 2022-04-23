import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/src/models/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locate;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/sms.dart';
import 'Model.dart';
import 'google_maps_directions.dart';



class MapScreen extends StatefulWidget {
  MapScreen({Key key});
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>  with WidgetsBindingObserver{

  PolylineResult result;
  BitmapDescriptor customIcon;

  // Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyBvR07aFM-1ddGVgt392lRnUge3weT6nUY";


  double currlat;

  double currlon;

  // CheckValidationModel li5;

  bool enableTypeahead = true;

  bool enableDropdown = true;
  var visibletravel = true;
  var cnt1=0;

  Model li;
  GoogleDirectionModel li1;

  int start=0;

  var direction='O';

  var cntsendsms=0;

  String lastloc;

  var otp;


  Completer<GoogleMapController> _controller = Completer();
  bool _serviceEnabled = false;
  var _kGooglePlex;
  Marker marker;
  int cnt = 0;
  TextEditingController AddressController = new TextEditingController();
  TextEditingController MobileNumberController = new TextEditingController();
  var loading = false;
  bool textcheck = false;
  final controller = Completer<GoogleMapController>();
  locate.Location location = new locate.Location();
  List<Location> locations;
  SmsSender sender = new SmsSender();

  locate.LocationData _locationData;

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
  void initState() {

    getLocationEnabled().then((value) {
      print("Service enabled${_serviceEnabled}");
      if (_serviceEnabled) {
        getlocation().then((value) {
          currlat=value.latitude;
          currlon=value.longitude;

        });
      }
        // CheckValidation();
    });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Container(
            child: Stack(
              // alignment: Alignment.bottomCenter,
              children: [

                GoogleMap(
                  compassEnabled: true,
                  mapToolbarEnabled: true,

                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                )

              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          FloatingActionButton(
            child: Icon(
                otp==0?
                Icons.numbers:Icons.nature_sharp),onPressed: (){

            otp==0?otp=1: otp=0;


          },),
          SizedBox(height: 10,),

        ],
      ),
    );
  }

  Future<void> getLocationEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
  }

  Future<locate.LocationData> getlocation() async {
    setState(() {
      loading = true;
    });
    _locationData = await location.getLocation();
    return _locationData;
  }

  Future<void> getlocationfromAddress(address) async {
    locations = await locationFromAddress(address);
  }

  Future<bool> setRegistered(mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobilenumber', mobilenumber);
    await prefs.setBool('seen', true);
  }

}

