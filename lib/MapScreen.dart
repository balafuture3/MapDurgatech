import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
// import 'dart:math';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_sms/flutter_sms.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding_platform_interface/src/models/location.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_map_polyutil/google_map_polyutil.dart';
// import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:location/location.dart' as locate;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_maintained/sms.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';

import 'ModelNew.dart';
import 'google_maps_directions.dart';



class MapScreen extends StatefulWidget {
  MapScreen({Key key, this.username});
  String username;
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>  with WidgetsBindingObserver{
  var otp=0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if(state.name=="paused") {
      print("timer close");
      timer.cancel();
    }
    if(state.name=="resumed") {
      _controller.future.then((value)
      {
        value.setMapStyle("[]");
      });
      timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        print(markers.length);
        if (markers.length > 2)
          Getdata();
      });
    }
   print(state.name);
  }
  PolylineResult result;
  BitmapDescriptor customIcon;
  double _originLatitude = 26.48424, _originLongitude = 50.04551;
  double _destLatitude = 26.46423, _destLongitude = 50.06358;
  // Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = "AIzaSyBvR07aFM-1ddGVgt392lRnUge3weT6nUY";
  List<Marker> listmarker = new List();
  var stringlist = ["Select Type", "Office", "Customer"];
  var dropdownValue1 = "Select Type";

  // static CustomerOfficeList li3;

  var enableStartTravel = true;

  String cardcode;

  // SuccessResponse li4;

  var enableEndTravel = true;

  var enableWorkStart = true;

  var enableWorkEnd = true;

  Timer timer;

  double currlat;

  double currlon;

  // CheckValidationModel li5;

  bool enableTypeahead = true;

  bool enableDropdown = true;
  var visibletravel = true;
  var cnt1=0;

  ModelNew li;
  GoogleDirectionModel li1;

  int start=0;

  var direction='O';

  var cntsendsms=0;

  String lastloc;

  Future<void> Contacheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _seen = (prefs.getBool('seen') ?? false);
    if (_seen) {
      MobileNumberController.text = prefs.getString("mobilenumber");

    }
  }
  Future<Response> GetBatdata() async {
    var url;

    url = Uri.parse("http://14.98.224.37:903/GetData");

    // print(url);
    // print(headers);

    // setState(() {
    //   loading = true;
    // });
    Map data = {

      "direction":direction,
      // "status":status

    };
    print(jsonEncode(data));
    var response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      li = ModelNew.fromJson(json.decode(response.body));
    }}

  Future<Response> Getdata() async {
    var url;

    url = Uri.parse("http://www.balasblog.co.in/dtZomoto/Getdata.php");

    // print(url);
    // print(headers);

    // setState(() {
    //   loading = true;
    // });
    Map data = {

      "direction":direction,
      // "status":status

    };
    // print(jsonEncode(data));
    var response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    // print(response.body);
    if (response.statusCode == 200)
    {

     li=ModelNew.fromJson(json.decode(response.body));
     // print(li.data[li.data.length-1].temp);
     // markers.elementAt(markers.length-1);
     markers.clear();
     markers.add(Marker(position: LatLng(_originLatitude,_originLongitude), markerId: MarkerId("Driver"),
         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
         ,
         infoWindow: InfoWindow(title: "Start Location"),
         draggable: true,onDragEnd: (lat) {
           setState(() {
             _originLatitude = lat.latitude;
             _originLongitude = lat.longitude;
           });
           _getPolyline();
           GetDirections(_originLatitude.toStringAsFixed(6)+','+_originLongitude.toStringAsFixed(6),_destLatitude.toStringAsFixed(6)+','+_destLongitude.toStringAsFixed(6));

         }));
     markers.add(
       Marker(position: LatLng(_destLatitude,_destLongitude), markerId: MarkerId("sd"),
           infoWindow: InfoWindow(title: "Stop Location"),draggable: true,onDragEnd: (lat){
             setState(() {
               _destLatitude = lat.latitude;
               _destLongitude = lat.longitude;
             });
             _getPolyline();
             GetDirections(_originLatitude.toStringAsFixed(6)+','+_originLongitude.toStringAsFixed(6),_destLatitude.toStringAsFixed(6)+','+_destLongitude.toStringAsFixed(6));

           }),);


     markers.add(Marker(
       anchor: const Offset(0.5, 0.5),
       icon: customIcon,
       position: LatLng(double.parse(li.data[li.data.length-1].location.split(',')[0]), double.parse(li.data[li.data.length-1].location.split(',')[1])),
       markerId: MarkerId("Vehicle"),
         infoWindow: InfoWindow(title: "Vehicle")
     ));
     _kGooglePlex = CameraPosition(target: LatLng(double.parse(li.data[li.data.length-1].location.split(',')[0]), double.parse(li.data[li.data.length-1].location.split(',')[1])), zoom: 16);

     // GoogleMapPolyUtil.isLocationOnEdge(
     //     point: LatLng(double.parse(li.result[li.result.length-1].data.split(',')[0]), double.parse(li.result[li.result.length-1].data.split(',')[1])),
     //     polygon: polylineCoordinates
     // ).then((result) => print(result));
     //
     // GoogleMapPolyUtil.isLocationOnPath(
     //     point: LatLng(double.parse(li.result[li.result.length-1].data.split(',')[0]), double.parse(li.result[li.result.length-1].data.split(',')[1])),
     //     polygon: polylineCoordinates
     // ).then((result) => print(result));
     //
     // GoogleMapPolyUtil.distanceToLine(
     //     point: LatLng(double.parse(li.result[li.result.length-1].data.split(',')[0]), double.parse(li.result[li.result.length-1].data.split(',')[1])),
     //     start: polylineCoordinates.first,
     //     end: polylineCoordinates.last,
     // ).then((result) => print(result));
if(li1!=null)
     for(int i=0;i<li1.routes[0].legs[0].steps.length;i++) {
       // print("current "+li.result[li.result.length - 1].data);
       print(li.data[li.data.length - 1].location+"=="+li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6)+','+li1.routes[0].legs[0].steps[i].endLocation.lng.toStringAsFixed(6));
       if (li.data[li.data.length - 1].location==li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6)+','+li1.routes[0].legs[0].steps[i].endLocation.lng.toStringAsFixed(6))
     if(li1.routes[0].legs[0].steps.length-1!=i) {
    print("inside check");
       if(li1.routes[0].legs[0].steps[i + 1].maneuver.toString()=="turn-right") {

         direction = "R";
         // if(li.result[li.result.length - 1].data==lastloc) {
         //   // Fluttertoast.showToast(msg: "Moving");
         //   direction = "S";
         // }
         // else
         //   Fluttertoast.showToast(msg: "Turning Right");
       }
       else if(li1.routes[0].legs[0].steps[i + 1].maneuver.toString()=="turn-left") {

         direction = "L";
    //      if(li.result[li.result.length - 1].data==lastloc){
    //        // Fluttertoast.showToast(msg: "Moving");
    //        direction = "S";
    //      }
    // else
    //        Fluttertoast.showToast(msg: "Turning Left");
       }
       print("man--" + li1.routes[0].legs[0].steps[i + 1].maneuver.toString());
     }
       else {
       if (li.data[li.data.length - 1].location ==
           li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6) + ',' +
               li1.routes[0].legs[0].steps[li1.routes[0].legs[0].steps.length -
                   1].endLocation.lng.toStringAsFixed(6)) {
         if(cntsendsms==0) {
           cntsendsms++;
           Fluttertoast.showToast(msg: "Destination Reached");
           // sender.sendSms(new SmsMessage(MobileNumberController.text, 'Destination Reached, Your OTP is ${math.Random().nextInt(999999).toStringAsFixed(6).padLeft(6, '0')}'));
         }
         //   _sendSMS("Destination Reached", ["7418230370"]);
         // }
         direction="E";
         print("End Location");



       }
     }
     }
     print("current "+li.data[li.data.length - 1].location);
     lastloc=li.data[li.data.length - 1].location;
     // for(int i=0;i<li1.routes[0].legs[0].steps.length;i++) {
     //
     //   print(li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6)+','+li1.routes[0].legs[0].steps[i].endLocation.lng.toStringAsFixed(6));
     //
     //
     // }
      // Fluttertoast.showToast(msg: response.body);
      // Navigator.pop(context);
      // GetTokenReport();
      // InsertQuotDetail();
      // Userid = liLogin.userid.toStringAsFixed(6);
      // superuser = liLogin.superuser == 1 ? true : false;
      // print(liLogin.status);
      // if (liLogin.status == 1)
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => DashBoard(
      //             name: emailController.text,
      //           )));
      // else
      //   showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: Text(
      //             "Alert!",
      //           ),
      //           content: Text("Invalid User Details"),
      //         );
      //       });

      // .cookie.split(';')[0]}");
      setState(() {

      });
    }

    setState(() {
      loading = false;
    });
    return response;
  }
  Future<Response> GetDirections(from,to) async {
    var url;

    url = Uri.parse("https://maps.googleapis.com/maps/api/directions/json?origin=$from&destination=$to&key=AIzaSyBvR07aFM-1ddGVgt392lRnUge3weT6nUY");

    print(url);
    // print(headers);

    // setState(() {
    //   loading = true;
    // });
    // Map data = {
    //
    //   "docno":docno,
    //   "status":status
    //
    // };
    // print(jsonEncode(data));
    var response = await http.get(
      url,
      // body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    log(json.encode(json.decode(response.body)));
    if (response.statusCode == 200)
    {
     li1=GoogleDirectionModel.fromJson(json.decode(response.body));
     print("Steps Lenth");
     print(li1.routes[0].legs[0].steps.length);
     Fluttertoast.showToast(msg: li1.routes[0].legs[0].distance.text);
     for(int i=0;i<li1.routes[0].legs[0].steps.length;i++)
     {
       print("distance"+li1.routes[0].legs[0].steps[i].distance.text);
       print("maneuver"+li1.routes[0].legs[0].steps[i].maneuver.toString());
       print("polyline"+li1.routes[0].legs[0].steps[i].polyline.points.toString());
       print("duration"+li1.routes[0].legs[0].steps[i].duration.text);
       print("End Loc Lat"+li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6));
       print("End Loc Lon"+li1.routes[0].legs[0].steps[i].endLocation.lng.toStringAsFixed(6));
     }

    }

    setState(() {
      loading = false;
    });
    return response;
  }
  Future<Response> GetdataFirstTime() async {
    var url;

    url = Uri.parse("http://www.balasblog.co.in/dtZomoto/Getdata.php");

    // print(url);
    // print(headers);

    setState(() {
      loading = true;
    });
    Map data = {

      "direction":direction,


    };
    // print(jsonEncode(data));
    var response = await http.post(
      url,
      // body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    print(response.body);
    if (response.statusCode == 200)
    {

     li=ModelNew.fromJson(json.decode(response.body));
     print(li.data[li.data.length-1].temp);
     markers.clear();
     markers.add(Marker(
       anchor: const Offset(0.5, 0.5),
       icon: customIcon,
       position: LatLng(double.parse(li.data[li.data.length-1].location.split(',')[0]), double.parse(li.data[li.data.length-1].location.split(',')[1])),
       markerId: MarkerId("Vehicle"),
       infoWindow: InfoWindow(title: "Vehicle")
     ));
     _kGooglePlex = CameraPosition(target: LatLng(double.parse(li.data[li.data.length-1].location.split(',')[0]), double.parse(li.data[li.data.length-1].location.split(',')[1])), zoom: 16);
      // Fluttertoast.showToast(msg: response.body);
      // Navigator.pop(context);
      // GetTokenReport();
      // InsertQuotDetail();
      // Userid = liLogin.userid.toStringAsFixed(6);
      // superuser = liLogin.superuser == 1 ? true : false;
      // print(liLogin.status);
      // if (liLogin.status == 1)
      //   Navigator.pushReplacement(
      //       context,
      //       MaterialPageRoute(
      //           builder: (context) => DashBoard(
      //             name: emailController.text,
      //           )));
      // else
      //   showDialog(
      //       context: context,
      //       builder: (BuildContext context) {
      //         return AlertDialog(
      //           title: Text(
      //             "Alert!",
      //           ),
      //           content: Text("Invalid User Details"),
      //         );
      //       });

      // .cookie.split(';')[0]}");
    }

    setState(() {
      loading = false;
    });
    return response;
  }
  Future<Response> StartStop(val) async {
    var url;
    url = Uri.parse("http://www.balasblog.co.in/dtZomoto/dt_updatestatus.php");
    Map data = {
      "status":val
    };
    print(jsonEncode(data));
    var response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    print(response.body);
    if (response.statusCode == 200)
    {

      // li=Model.fromJson(json.decode(response.body));

    }

    setState(() {
      loading = false;
    });
    return response;
  }
  Future<Response> OtpSend(val) async {
    var url;
    url = Uri.parse("http://14.98.224.37:903/UpdateOTP");
    Map data = {
      "status":val
    };
    print(jsonEncode(data));
    var response = await http.post(
      url,
      body: jsonEncode(data),
      headers: {
        "Content-Type": "application/json",
      },
    );
    print(response.body);
    if (response.statusCode == 200)
    {

      // li=Model.fromJson(json.decode(response.body));

    }

    setState(() {
      loading = false;
    });
    return response;
  }
//
//   Future<http.Response> CheckValidation() async {
//     setState(() {
//       loading = true;
//     });
//     var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//   <soap12:Body>
//     <IN_MOB_VALIDATIONNEW xmlns="http://tempuri.org/">
//       <UserID>${LoginScreenState.empID}</UserID>
//     </IN_MOB_VALIDATIONNEW>
//   </soap12:Body>
// </soap12:Envelope>''';
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_VALIDATIONNEW';
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
// //    print(String_values.base_url);
//     print(url);
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "text/xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setStatus(true, false, false, false);
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       if (parsedXml.text != "[]") {
//         final decoded = json.decode(parsedXml.text);
//         li5 = CheckValidationModel.fromJson(decoded[0]);
//         print(li5.cUSNAME1);
//         setState(() {
//           if (li5.wORKSTART == "Y" &&
//               li5.wORKEND == "Y" &&
//               li5.sTOPTRAVEL == "Y" &&
//               li5.sTARTTRAVEL == "Y") {
//           } else {
//             if (li5.tYPENAME != "")
//               dropdownValue1 = li5.tYPENAME;
//             else
//               dropdownValue1 = li5.tYPENAME1;
//             if (li5.cUSNAME != "")
//               _typeAheadController.text = li5.cUSNAME;
//             else
//               _typeAheadController.text = li5.cUSNAME1;
//             if (li5.cUSCODE != "")
//               cardcode = li5.cUSCODE;
//             else
//               cardcode = li5.cUSCODE1;
//             if (li5.sTARTTRAVEL == "Y" && li5.wORKEND == "N") {
//               enableTypeahead = false;
//               enableDropdown = false;
//             } else {
//               enableTypeahead = true;
//               enableDropdown = true;
//             }
//             li5.wORKSTART == "Y" ? enableWorkStart = false : true;
//             if (li5.wORKEND == "Y") {
//               enableWorkEnd = false;
//               enableWorkStart = true;
//             } else
//               enableWorkEnd = true;
//             li5.sTARTTRAVEL == "Y" ? enableStartTravel = false : true;
//             li5.sTOPTRAVEL == "Y" ? enableEndTravel = false : true;
//
//             if (li5.tYPENAME == "Office") {
//               if (li5.cUSNAME != "") {
//                 if (li5.cUSNAME.toLowerCase() ==
//                     LoginScreenState.homeLoc.toLowerCase()) {
//                   setState(() {
//                     visibletravel = false;
//                   });
//                 }
//               } else if (li5.cUSNAME1 != "") {
//                 if (li5.cUSNAME1.toLowerCase() ==
//                     LoginScreenState.homeLoc.toLowerCase()) {
//                   setState(() {
//                     visibletravel = false;
//                   });
//                 }
//               }
//             }
//
//             if (li5.tYPENAME1 == "Office") {
//               if (li5.cUSNAME != "") {
//                 if (li5.cUSNAME.toLowerCase() ==
//                     LoginScreenState.homeLoc.toLowerCase()) {
//                   setState(() {
//                     visibletravel = false;
//                   });
//                 }
//               } else if (li5.cUSNAME1 != "") {
//                 if (li5.cUSNAME1.toLowerCase() ==
//                     LoginScreenState.homeLoc.toLowerCase()) {
//                   setState(() {
//                     visibletravel = false;
//                   });
//                 }
//               }
//             }
//           }
//         });
//
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) =>
//         //           Dashboard()),
//         // );
//
//       }
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     print("response: ${response.statusCode}");
//     print("response: ${response.body}");
//     return response;
//   }
//
//   Future<http.Response> StartTravel() async {
//     setState(() {
//       loading = true;
//     });
//     String location;
//     if (_serviceEnabled) {
//       location = "";
//       AddressController.text = "";
//     } else
//       location = currlat.toStringAsFixed(6) + ',' + currlon.toStringAsFixed(6);
//
//     var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//   <soap12:Body>
//     <IN_MOB_STARTATTENDANCE xmlns="http://tempuri.org/">
//       <TypeCode>${dropdownValue1}</TypeCode>
//       <TypeName>${dropdownValue1}</TypeName>
//       <CusCode>${cardcode}</CusCode>
//       <CusName>${_typeAheadController.text}</CusName>
//       <StartTravel>Y</StartTravel>
//       <StartLatLang>${location}</StartLatLang>
//       <StartAddress>${AddressController.text}</StartAddress>
//       <Remarks>test</Remarks>
//       <UserID>${LoginScreenState.empID}</UserID>
//     </IN_MOB_STARTATTENDANCE>
//   </soap12:Body>
// </soap12:Envelope>''';
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_STARTATTENDANCE';
//     http: //15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_STARTATTENDANCE
//     print(url);
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
// //    print(String_values.base_url);
// //
// //
// // <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
// //   <soap:Body>
// //     <IN_MOB_STARTATTENDANCE xmlns="http://tempuri.org/">
// //       <TRAVELTYPE>${dropdownValue1}</TRAVELTYPE>
// //       <CUSTOMERCODE>${cardcode}</CUSTOMERCODE>
// //       <CUSTOMERNAME>${_typeAheadController.text}</CUSTOMERNAME>
// //       <TRAVELSTART>Y</TRAVELSTART>
// //       <T_STARTDATE>${DateFormat("yyyy-MM-dd").format(DateTime.now())}</T_STARTDATE>
// //       <T_STARTTIME>${DateFormat("hh:mm a").format(DateTime.now())}</T_STARTTIME>
// //       <T_STARTLATLANG>${currlat.toStringAsFixed(6)+','+currlon.toStringAsFixed(6)}</T_STARTLATLANG>
// //       <T_STARTADDRESS>${AddressController.text}</T_STARTADDRESS>
// //       <USERID>${LoginScreenState.empID}</USERID>
// //     </IN_MOB_STARTATTENDANCE>
// //   </soap:Body>
// // </soap:Envelope>
//
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "application/soap+xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setStatus(true, false, false, false);
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       if (parsedXml.text != "[]") {
//         final decoded = json.decode(parsedXml.text);
//         li4 = SuccessResponse.fromJson(decoded[0]);
//         print(li4.sTATUSMSG);
//         if (li4.sTATUS == "1") {
//           setState(() {
//             enableStartTravel = false;
//           });
//
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         } else
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) =>
//         //           Dashboard()),
//         // );
//
//       } else
//         Fluttertoast.showToast(
//             msg: "Please check your login details,No users found",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             timeInSecForIosWeb: 1,
//             backgroundColor: String_values.primarycolor,
//             textColor: Colors.white,
//             fontSize: 16.0);
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     print("response: ${response.statusCode}");
//     print("response: ${response.body}");
//     return response;
//   }
//
//   Future<http.Response> EndTravel() async {
//     setState(() {
//       loading = true;
//     });
//     String location;
//     if (_serviceEnabled) {
//       location = "";
//       AddressController.text = "";
//     } else
//       location = currlat.toStringAsFixed(6) + ',' + currlon.toStringAsFixed(6);
//     var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//   <soap12:Body>
//     <IN_MOB_STOPATTENDANCE xmlns="http://tempuri.org/">
//       <TypeCode>${dropdownValue1}</TypeCode>
//       <TypeName>${dropdownValue1}</TypeName>
//       <CusCode>${cardcode}</CusCode>
//       <CusName>${_typeAheadController.text}</CusName>
//       <StartTravel>Y</StartTravel>
//       <StartLatLang>${location}</StartLatLang>
//       <StartAddress>${AddressController.text}</StartAddress>
//       <Remarks>test</Remarks>
//       <UserID>${LoginScreenState.empID}</UserID>
//     </IN_MOB_STOPATTENDANCE>
//   </soap12:Body>
// </soap12:Envelope>''';
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_STOPATTENDANCE';
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
//
//     print(url);
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "application/soap+xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       if (parsedXml.text != "[]") {
//         final decoded = json.decode(parsedXml.text);
//         li4 = SuccessResponse.fromJson(decoded[0]);
//         print(li4.sTATUSMSG);
//         if (li4.sTATUS == "1") {
//           setState(() {
//             dropdownValue1 = "Select Type";
//             _typeAheadController.text = "";
//             setStatus(false, false, false, false);
//             enableStartTravel = true;
//             enableWorkStart = true;
//             enableWorkEnd = true;
//           });
//
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         } else
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) =>
//         //           Dashboard()),
//         // );
//
//       } else
//         Fluttertoast.showToast(
//             msg: "Please check your login details,No users found",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             timeInSecForIosWeb: 1,
//             backgroundColor: String_values.primarycolor,
//             textColor: Colors.white,
//             fontSize: 16.0);
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     print("response: ${response.statusCode}");
//     print("response: ${response.body}");
//     return response;
//   }
//
//   Future<http.Response> WorkStart() async {
//     setState(() {
//       loading = true;
//     });
//     String location;
//     if (_serviceEnabled) {
//       location = "";
//       AddressController.text = "";
//     } else
//       location = currlat.toStringAsFixed(6) + ',' + currlon.toStringAsFixed(6);
//     var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//   <soap12:Body>
//     <IN_MOB_WORKSTRATATTENDANCE xmlns="http://tempuri.org/">
//       <TypeCode>${dropdownValue1}</TypeCode>
//       <TypeName>${dropdownValue1}</TypeName>
//       <CusCode>${cardcode}</CusCode>
//       <CusName>${_typeAheadController.text}</CusName>
//       <StartTravel>Y</StartTravel>
//       <StartLatLang>${location}</StartLatLang>
//       <StartAddress>${AddressController.text}</StartAddress>
//       <Remarks>test</Remarks>
//       <UserID>${LoginScreenState.empID}</UserID>
//     </IN_MOB_WORKSTRATATTENDANCE>
//   </soap12:Body>
// </soap12:Envelope>''';
//     print(envelope);
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_WORKSTRATATTENDANCE';
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
// //    print(String_values.base_url);
//     print(url);
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "application/soap+xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       if (parsedXml.text != "[]") {
//         final decoded = json.decode(parsedXml.text);
//         li4 = SuccessResponse.fromJson(decoded[0]);
//         print(li4.sTATUSMSG);
//         if (li4.sTATUS == "1") {
//           setStatus(true, false, true, false);
//           setState(() {
//             enableTypeahead = false;
//             enableDropdown = false;
//             enableWorkStart = false;
//             enableWorkEnd = true;
//           });
//
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         } else
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) =>
//         //           Dashboard()),
//         // );
//
//       } else
//         Fluttertoast.showToast(
//             msg: "Please check your login details,No users found",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             timeInSecForIosWeb: 1,
//             backgroundColor: String_values.primarycolor,
//             textColor: Colors.white,
//             fontSize: 16.0);
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     print("response: ${response.statusCode}");
//     print("response: ${response.body}");
//     return response;
//   }
//
//   Future<http.Response> WorkEnd() async {
//     setState(() {
//       loading = true;
//     });
//     String location;
//     if (_serviceEnabled) {
//       location = "";
//       AddressController.text = "";
//     } else
//       location = currlat.toStringAsFixed(6) + ',' + currlon.toStringAsFixed(6);
//     var envelope = '''<?xml version="1.0" encoding="utf-8"?>
// <soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
//   <soap12:Body>
//     <IN_MOB_WORKENDATTENDANCE xmlns="http://tempuri.org/">
//       <TypeCode>${dropdownValue1}</TypeCode>
//       <TypeName>${dropdownValue1}</TypeName>
//       <CusCode>${cardcode}</CusCode>
//       <CusName>${_typeAheadController.text}</CusName>
//       <StartTravel>Y</StartTravel>
//       <StartLatLang>${location}</StartLatLang>
//       <StartAddress>${AddressController.text}</StartAddress>
//       <Remarks>test</Remarks>
//       <UserID>${LoginScreenState.empID}</UserID>
//     </IN_MOB_WORKENDATTENDANCE>
//   </soap12:Body>
// </soap12:Envelope>
// ''';
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_WORKENDATTENDANCE';
//     print(url);
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
// //    print(String_values.base_url);
//
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "application/soap+xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       if (parsedXml.text != "[]") {
//         final decoded = json.decode(parsedXml.text);
//         li4 = SuccessResponse.fromJson(decoded[0]);
//         print(li4.sTATUSMSG);
//         if (li4.sTATUS == "1" || li4.sTATUS == "2") {
//           print("true");
//           // setStatus(true, false, true, true);
//           setState(() {
//             enableTypeahead = true;
//             enableDropdown = true;
//             enableWorkEnd = false;
//             enableWorkStart = true;
//           });
//
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         } else
//           Fluttertoast.showToast(
//               msg: li4.sTATUSMSG,
//               toastLength: Toast.LENGTH_LONG,
//               gravity: ToastGravity.SNACKBAR,
//               timeInSecForIosWeb: 1,
//               backgroundColor: String_values.primarycolor,
//               textColor: Colors.white,
//               fontSize: 16.0);
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(
//         //       builder: (context) =>
//         //           Dashboard()),
//         // );
//
//       } else
//         Fluttertoast.showToast(
//             msg: "Please check your login details,No users found",
//             toastLength: Toast.LENGTH_LONG,
//             gravity: ToastGravity.SNACKBAR,
//             timeInSecForIosWeb: 1,
//             backgroundColor: String_values.primarycolor,
//             textColor: Colors.white,
//             fontSize: 16.0);
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     print("response: ${response.statusCode}");
//     print("response: ${response.body}");
//     return response;
//   }
//
//   Future<http.Response> customerListorOfficeList(formid) async {
//     setState(() {
//       loading = true;
//     });
//     var envelope = '''
// <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
//   <soap:Body>
//     <IN_MOB_GETCUSTOMER xmlns="http://tempuri.org/">
//       <FORMID>$formid</FORMID>
//     </IN_MOB_GETCUSTOMER>
//   </soap:Body>
// </soap:Envelope>
// ''';
//     print(envelope);
//     var url =
//         'http://15.206.119.30:2021/Muratech/Service.asmx?op=IN_MOB_GETCUSTOMER';
//     // Map data = {
//     //   "username": EmailController.text,
//     //   "password": PasswordController.text
//     // };
// //    print("data: ${data}");
// //    print(String_values.base_url);
//
//     var response = await http.post(url,
//         headers: {
//           "Content-Type": "text/xml; charset=utf-8",
//         },
//         body: envelope);
//     if (response.statusCode == 200) {
//       setState(() {
//         loading = false;
//       });
//
//       xml.XmlDocument parsedXml = xml.XmlDocument.parse(response.body);
//       print(parsedXml.text);
//       final decoded = json.decode(parsedXml.text);
//       li3 = CustomerOfficeList.fromJson(decoded);
//       print(li3.details[0].cardName);
//
//       // setState(() {
//       //   stringlist.clear();
//       //   stringlist.add("Select Category");
//       //   for (int i = 0; i < li4.details.length; i++)
//       //     stringlist.add(li4.details[i].categoryName);
//       // });
//
//       // if ("li2.name" != null) {
//       //   Fluttertoast.showToast(
//       //       msg:"",
//       //       toastLength: Toast.LENGTH_LONG,
//       //       gravity: ToastGravity.SNACKBAR,
//       //       timeInSecForIosWeb: 1,
//       //       backgroundColor: String_Values.primarycolor,
//       //       textColor: Colors.white,
//       //       fontSize: 16.0);
//       // } else
//       //   Fluttertoast.showToast(
//       //       msg: "Please check your login details,No users found",
//       //       toastLength: Toast.LENGTH_LONG,
//       //       gravity: ToastGravity.SNACKBAR,
//       //       timeInSecForIosWeb: 1,
//       //       backgroundColor: String_Values.primarycolor,
//       //       textColor: Colors.white,
//       //       fontSize: 16.0);
//     } else {
//       Fluttertoast.showToast(
//           msg: "Http error!, Response code ${response.statusCode}",
//           toastLength: Toast.LENGTH_LONG,
//           gravity: ToastGravity.SNACKBAR,
//           timeInSecForIosWeb: 1,
//           backgroundColor: String_values.primarycolor,
//           textColor: Colors.white,
//           fontSize: 16.0);
//       setState(() {
//         loading = false;
//       });
//       print("Retry");
//     }
//     // print("response: ${response.statusCode}");
//     // print("response: ${response.body}");
//     return response;
//   }

  // LatLngBounds getBounds(List<Marker> markers) {
  //   var lngs = markers.map<double>((m) => m.position.longitude).toList();
  //   var lats = markers.map<double>((m) => m.position.latitude).toList();
  //
  //   double topMost = lngs.reduce(max);
  //   double leftMost = lats.reduce(min);
  //   double rightMost = lats.reduce(max);
  //   double bottomMost = lngs.reduce(min);
  //
  //   LatLngBounds bounds = LatLngBounds(
  //     northeast: LatLng(rightMost, topMost),
  //     southwest: LatLng(leftMost, bottomMost),
  //   );
  //
  //   return bounds;
  // }
  //
  // static Future<bool> setStatus(tstart, tend, wstart, wend) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('tstart', tstart);
  //   await prefs.setBool('tend', tend);
  //   await prefs.setBool('wstart', wstart);
  //   await prefs.setBool('wend', wstart);
  //   return true;
  // }

  Completer<GoogleMapController> _controller = Completer();
  bool _serviceEnabled = false;
  var _kGooglePlex;
  Marker marker;
  String destinationaddress;
  String imei;
  int cnt = 0;
  Set<Marker> markers = Set();
  // Position position;
  TextEditingController AddressController = new TextEditingController();
  TextEditingController _typeAheadController = new TextEditingController();
  TextEditingController MobileNumberController = new TextEditingController();
  var loading = false;
  bool textcheck = false;
  final controller = Completer<GoogleMapController>();
  BitmapDescriptor pinLocationIcon;
  BitmapDescriptor pinLocationIcon1;
  List<Placemark> placemarks;
  locate.Location location = new locate.Location();
  List<Location> locations;
  SmsSender sender = new SmsSender();
  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline =  Polyline(
      geodesic: true,
      width: 2,
        polylineId: id, color: Colors.red, points: polylineCoordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  _getPolyline() async {
    polylineCoordinates.clear();
    print(_originLatitude, );
    print(_originLongitude, );
    print(_destLatitude, );
    print(_destLongitude, );
    // polylineCoordinates.add(LatLng(_originLatitude, _originLongitude));
    // polylineCoordinates.add(LatLng(_destLatitude, _destLongitude));

   result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(_originLatitude, _originLongitude),
        PointLatLng(_destLatitude, _destLongitude),
        travelMode: TravelMode.driving,
        // wayPoints: [PolylineWayPoint(location: "Pollachi")]
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    else
      print("empty");
    _addPolyLine();
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
  // Polyline route = new Polyline(
  //     polylineId: PolylineId("route"),
  //     geodesic: true,
  //     points: po,
  //     width: 20,
  //     color: Colors.blue);
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();

    // TODO: implement dispose
    super.dispose();
  }
  @override
  void deactivate() {
    timer.cancel();
    // TODO: implement deactivate
    super.deactivate();
  }
  void initState() {
 Contacheck();
    WidgetsBinding.instance.addObserver(this);
// prevstatus();

    BitmapDescriptor.fromAssetImage(

        ImageConfiguration(size: Size(1, 1)), 'location.png',)
        .then((d) {
      customIcon = d;
    });
    GetdataFirstTime().then((value)
    {
      timer= Timer.periodic(const Duration(seconds: 2), (timer) {
        // print(markers.length);
        if(markers.length>2)
        Getdata();});
    });
    // _kGooglePlex = CameraPosition(target: LatLng(0, 0), zoom: 16);
    //
    // enableTypeahead = true;
    // enableDropdown = true;
    //
    // getLocationEnabled().then((value) {
    //   print("Service enabled${_serviceEnabled}");
    //   if (_serviceEnabled) {
    //     getlocation().then((value) {
    //       print("getlocation");
    //       if (position.latitude != null) {
    //         _originLatitude=position.latitude;
    //         _originLongitude=position.longitude;
    //         currlat = position.latitude;
    //
    //         currlon = position.longitude;
    //
    //         placefromLATLNG();
    //       }
    //       // CheckValidation();
    //     });
    //   }
    //     // CheckValidation();
    // });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Future<void> _launchInBrowser(String url) async {
    //   if (await canLaunch(url)) {
    //     await launch(
    //       url,
    //       forceSafariVC: false,
    //       forceWebView: false,
    //       headers: <String, String>{'my_header_key': 'my_header_value'},
    //     );
    //   } else {
    //     throw 'Could not launch $url';
    //   }
    // }
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Container(
            child: Stack(
              // alignment: Alignment.bottomCenter,
              children: [
              // Animarker(
              // curve: Curves.bounceOut,
              // rippleRadius: 0.2,
              // useRotation: false,
              // duration: Duration(milliseconds: 2300),
              // mapId: controller.future
              //     .then<int>((value) => value.mapId), //Grab Google Map Id
              // markers: markers,
              // child:
              GoogleMap(
                  compassEnabled: true,
                  mapToolbarEnabled: true,

                  onTap: (LatLng){
                    if(markers.length==1)
                      {
                        _originLatitude=LatLng.latitude;
                        _originLongitude=LatLng.longitude;
                        markers.add(Marker(position: LatLng, markerId: MarkerId("Driver"),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
                        ,
                            infoWindow: InfoWindow(title: "Start Location"),
                            draggable: true,onDragEnd: (lat) {
                              setState(() {
                                _originLatitude = lat.latitude;
                                _originLongitude = lat.longitude;
                              });
                              _getPolyline();
                              GetDirections(_originLatitude.toStringAsFixed(6)+','+_originLongitude.toStringAsFixed(6),_destLatitude.toStringAsFixed(6)+','+_destLongitude.toStringAsFixed(6));

                            }));

                      }
                    else {
                      _destLatitude = LatLng.latitude;
                      _destLongitude = LatLng.longitude;

                      markers.add(
                          Marker(position: LatLng, markerId: MarkerId("sd"),
                              infoWindow: InfoWindow(title: "Stop Location"),draggable: true,onDragEnd: (lat){
                                setState(() {
                                  _destLatitude = lat.latitude;
                                  _destLongitude = lat.longitude;
                                });
                                _getPolyline();
                                GetDirections(_originLatitude.toStringAsFixed(6)+','+_originLongitude.toStringAsFixed(6),_destLatitude.toStringAsFixed(6)+','+_destLongitude.toStringAsFixed(6));

                              }),);
                      _getPolyline();
                      GetDirections(_originLatitude.toStringAsFixed(6)+','+_originLongitude.toStringAsFixed(6),_destLatitude.toStringAsFixed(6)+','+_destLongitude.toStringAsFixed(6));
                    }
                    // DirectionsService.init('AIzaSyB28TEZPLhB60JhhwFpcx86GjJHIPPxZ9U');
                    //
                    // final directionsService = DirectionsService();
                    //
                    // final request = DirectionsRequest(
                    //   origin: 'New York',
                    //   destination: 'San Francisco',
                    //   travelMode: TravelMode.driving,
                    // );
                    //
                    // directionsService.route(request,
                    //         (DirectionsResult response, DirectionsStatus status) {
                    //       if (status == DirectionsStatus.ok) {
                    //         print("dsfadsaf");
                    //         // do something with successful response
                    //       } else {
                    //         print("false");
                    //         // do something with error response
                    //       }
                    //     });
                    // googleMap.polylines.add(route);
                    setState(() {

                    });
                  },
                  // padding: EdgeInsets.only(top: height / 2),
                  // myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  polylines: Set<Polyline>.of(polylines.values),
                  initialCameraPosition: _kGooglePlex,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  markers: markers,
                )
        // ),
                // Container(
                //   color: Colors.transparent,
                //   child: Padding(
                //     padding: const EdgeInsets.only(
                //         left: 16, right: 16, bottom: 16,top: 16),
                //     child: TextField(
                //       controller: AddressController,
                //       enabled: false,
                //       minLines: 2,
                //       maxLines: 25,
                //       style: TextStyle(fontSize: 12),
                //       decoration: InputDecoration(
                //         labelText: "Your Address",
                //         border: OutlineInputBorder(
                //           borderRadius:
                //           BorderRadius.circular(5.0),
                //         ),
                //       ),
                //     ),
                //   ),
                // )
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
                Icons.info_outline),
            onPressed: (){
              if(markers.length>2)
                {
                  showDialog(context: context, builder: (BuildContext context) {
                    return AlertDialog(
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Vehicle Location",style: TextStyle(color: Colors.blue),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(li.data[li.data.length - 1].location),
                          ),
                          SizedBox(height: 20,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Start Location",style: TextStyle(color: Colors.blue),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(li1.routes[0].legs[0].startAddress),
                          ),
                          SizedBox(height: 20,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("End Location",style: TextStyle(color: Colors.blue),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(li1.routes[0].legs[0].endAddress),
                          ),
                          SizedBox(height: 20,),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Turning Points",style: TextStyle(color: Colors.blue),),
                          ),
                      for(int i=0;i<li1.routes[0].legs[0].steps.length;i++)
Padding(
  padding: const EdgeInsets.all(8.0),
  child:   TextField(controller: TextEditingController(text: li1.routes[0].legs[0].steps[i].endLocation.lat.toStringAsFixed(6)+','+li1.routes[0].legs[0].steps[i].endLocation.lng.toStringAsFixed(6)),),
)
                        ],
                      ),
                    ),);
                  },);
                }
              else
                Fluttertoast.showToast(msg: "Please choose Route");



          },),
          SizedBox(height: 10,),
          FloatingActionButton(
            child: Icon(
              start==0?
                Icons.play_arrow:Icons.stop),onPressed: (){
              print(markers.length);
              if(markers.length==3) {
                print(result.points);
                if (start == 0)
                  start = 1;
                else
                  start = 0;
                StartStop(start);
              }
              else {
                print("Choose Route");
                Fluttertoast.showToast(msg: "Please Choose Route");
              }
            // print(_originLatitude, );
            // print(_originLongitude, );
            // print(_destLatitude, );
            // print(_destLongitude, );
              // markers.clear();
              // polylines.clear();
            // markers.add(Marker(position: LatLng(_originLatitude,_originLongitude),
            //     markerId: MarkerId("ggf"),
            //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),));
            // markers.add(Marker(position: LatLng(_destLatitude,_destLongitude), markerId: MarkerId("sd")));
            // if(cnt1==0) {
            //   cnt1++;
            //   markers.add(Marker(
            //     anchor: const Offset(0.5, 0.5),
            //     icon: customIcon,
            //     position: LatLng(_originLatitude, _originLongitude),
            //     markerId: MarkerId("Vehicle"),
            //   ));
            // }
            // else
            //   {
            //     markers.add(Marker(
            //       anchor: const Offset(0.5, 0.5),
            //       icon: customIcon,
            //       position: LatLng(_originLatitude-0.0002,_originLongitude), markerId: MarkerId("Vehicle"),
            //     ));
              // }

            // _getPolyline();
            // polylines
            // markers.clear();
            // polylines.clear();
            setState(() {

            });
          },),
          SizedBox(height: 10,),
          FloatingActionButton(child: Icon(Icons.clear),onPressed: ()
          {
            cntsendsms=0;
            cnt1=0;
            markers.clear();
            polylines.clear();
            GetdataFirstTime();
            // getLocationEnabled().then((value) {
            //   print("Service enabled${_serviceEnabled}");
            //   if (_serviceEnabled) {
            //     getlocation().then((value) {
            //       print("getlocation");
            //       if (position.latitude != null) {
            //         // _originLatitude=position.latitude;
            //         // _originLongitude=position.longitude;
            //         currlat = position.latitude;
            //
            //         currlon = position.longitude;
            //         placefromLATLNG();
            //       }
            //       // CheckValidation();
            //     });
            //   }
            //   // CheckValidation();
            // });
            setState(() {

            });
          },),
          SizedBox(height: 50,),
          // FloatingActionButton(child: Icon(Icons.perm_contact_cal),onPressed: ()
          // {
          //   showDialog(context: context, builder: (BuildContext context) {
          //     return AlertDialog(
          //       title: Text("Mobile Number for OTP"),
          //       content: SingleChildScrollView(
          //         child: Column(
          //           children: [
          //             TextField(
          //               controller: MobileNumberController,
          //             )
          //           ],
          //         ),
          //       ),
          //       actions: [TextButton(onPressed: (){
          //         setRegistered(MobileNumberController.text);
          //         Navigator.pop(context);
          //
          //       }, child: Text("OK"))],
          //     );
          //   },);
          // },),
          // SizedBox(height: 10,),
          // FloatingActionButton(
          //   child: Icon(
          //       otp==0?
          //       Icons.numbers:Icons.nature_sharp),onPressed: (){
          //
          //     OtpSend(otp==0?"10101010":"0000000000");
          //     otp==0?otp=1: otp=0;
          //
          //   // print(_originLatitude, );
          //   // print(_originLongitude, );
          //   // print(_destLatitude, );
          //   // print(_destLongitude, );
          //   // markers.clear();
          //   // polylines.clear();
          //   // markers.add(Marker(position: LatLng(_originLatitude,_originLongitude),
          //   //     markerId: MarkerId("ggf"),
          //   //   icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),));
          //   // markers.add(Marker(position: LatLng(_destLatitude,_destLongitude), markerId: MarkerId("sd")));
          //   // if(cnt1==0) {
          //   //   cnt1++;
          //   //   markers.add(Marker(
          //   //     anchor: const Offset(0.5, 0.5),
          //   //     icon: customIcon,
          //   //     position: LatLng(_originLatitude, _originLongitude),
          //   //     markerId: MarkerId("Vehicle"),
          //   //   ));
          //   // }
          //   // else
          //   //   {
          //   //     markers.add(Marker(
          //   //       anchor: const Offset(0.5, 0.5),
          //   //       icon: customIcon,
          //   //       position: LatLng(_originLatitude-0.0002,_originLongitude), markerId: MarkerId("Vehicle"),
          //   //     ));
          //   // }
          //
          //   // _getPolyline();
          //   // polylines
          //   // markers.clear();
          //   // polylines.clear();
          //   setState(() {
          //
          //   });
          // },),
          // SizedBox(height: 10,),
          // FloatingActionButton(child: Icon(Icons.battery_std_outlined),onPressed: ()
          // {
          //   // GetBatdata().then((value) =>
          //   // showDialog(context: context, builder: (BuildContext context) {
          //   //   return Scaffold(
          //   //       body: Center(
          //   //           child: Container(
          //   //             height: MediaQuery.of(context).size.height/2,
          //   //             width: MediaQuery.of(context).size.width/2,
          //   //               child: SfRadialGauge(
          //   //                   axes: <RadialAxis>[
          //   //                     RadialAxis(minimum: 0, maximum: 20,
          //   //                         ranges: <GaugeRange>[
          //   //                           GaugeRange(startValue: 0, endValue: 10, color:Colors.red),
          //   //                           GaugeRange(startValue: 10,endValue: 14,color: Colors.green),
          //   //                           GaugeRange(startValue: 14,endValue: 20,color: Colors.red)],
          //   //                         pointers: <GaugePointer>[
          //   //                           NeedlePointer(value: li!=null?double.parse(li.result[li.result.length-1].Battery.trim()):"12")],
          //   //                         annotations: <GaugeAnnotation>[
          //   //                           GaugeAnnotation(widget: Container(child:
          //   //                           Text(li!=null?"${li.result[li.result.length-1].Battery.trim()} V":"12 V",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold))),
          //   //                               angle: 90, positionFactor: 0.5
          //   //                           )]
          //   //                     )])
          //   //           )));
          //   // },));
          // },),
          // SizedBox(height: 50,),
        ],
      ),
      // appBar: AppBar(
      //   title: Text("Location"),
      // ),
      // floatingActionButton: FloatingActionButton(
      //     child: Icon(Icons.directions),
      //     onPressed: () {
      //       print("${locations[0].latitude},${locations[0].longitude}");
      //       getlocationfromAddress(destinationaddress).then((value) {
      //         _launchInBrowser(
      //             "https://www.google.com/maps/dir/?api=1&origin=${position.latitude},${position.longitude}&destination=${locations[0].latitude},${locations[0].longitude}&travelmode=driving");
      //       });
      //     })
    );
  }

  // Future<void> getimei() async {
  // //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // //   setState(() {
  // //     loading=true;
  // //   });
  // //   AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
  // // print(androidDeviceInfo);
  // }
  Future<void> getLocationEnabled() async {
    _serviceEnabled = await location.serviceEnabled();
  }

  Future<void> getlocation() async {
    setState(() {
      loading = true;
    });

    // List<String> multiImei = await ImeiPlugin.getImeiMulti(); //for double-triple SIM phones
    // String uuid = await ImeiPlugin.getId();
    // position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);
    // marker = Marker(
    //   markerId: MarkerId("Driver"),
    //   position: LatLng(position.latitude, position.longitude),
    // );
  }

  Future<void> getlocationfromAddress(address) async {
    locations = await locationFromAddress(address);
  }

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'start.png');
  }

  void setCustomMapPin1() async {
    pinLocationIcon1 = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'factory.png');
  }

  // Future<void> boundarytake() async {
  //   GoogleMapController controller = await _controller.future;
  //   setState(() {
  //     controller
  //         .moveCamera(CameraUpdate.newLatLngBounds(getBounds(listmarker), 150));
  //   });
  // }

  Future<void> placefromLATLNG() async {
    placemarks = await placemarkFromCoordinates(currlat, currlon);
    AddressController.text = placemarks[0].name +
        ',' +
        placemarks[0].street +
        ',' +
        placemarks[0].subLocality +
        ',' +
        placemarks[0].locality +
        ',' +
        placemarks[0].administrativeArea +
        ',' +
        placemarks[0].country +
        ',' +
        placemarks[0].postalCode;
    print(AddressController.text);
    setState(() {
      // marker = Marker(
      //   markerId: MarkerId("Driver"),
      //   position: LatLng(currlat, currlon),
      // );
      // markers.clear();
      // markers.add(marker);
      _kGooglePlex = CameraPosition(target: LatLng(currlat, currlon), zoom: 16);

      loading = false;

      //    print("Markers "+markers.length.toStringAsFixed(6));
    });
  }

  Future<bool> setRegistered(mobilenumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('mobilenumber', mobilenumber);
    await prefs.setBool('seen', true);
  }
  // Future<void> prevstatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   enableStartTravel = !prefs.getBool('tstart');
  //   enableEndTravel = !prefs.getBool('tend');
  //   enableWorkStart = !prefs.getBool('wstart');
  //   enableWorkEnd = !prefs.getBool('wend');
  // }
}



// class BackendService {
//   static Future<List> getSuggestions(String query) async {
//     List<String> s = new List();
//     if (MapScreenState.li3.details.length == 0) {
//       // return ["No details"];
//     } else {
//       for (int i = 0; i < MapScreenState.li3.details.length; i++)
//         if (MapScreenState.li3.details[i].cardName
//             .toStringAsFixed(6)
//             .toLowerCase()
//             .contains(query.toLowerCase()) ||
//             MapScreenState.li3.details[i].cardName
//                 .toStringAsFixed(6)
//                 .toLowerCase()
//                 .contains(query.toLowerCase()))
//           s.add("${MapScreenState.li3.details[i].cardName}");
//       // s.add("${MapScreenState.li3.data[i].itemName}-${MapScreenState.li3.data[i].itemCode}");
//       return s;
//     }
//   }
// }
// class Delivery_Pickup extends StatefulWidget {
//   @override
//   _Delivery_PickupState createState() => _Delivery_PickupState();
// }
//
// class _Delivery_PickupState extends State<Delivery_Pickup> {
//   String _url = 'https://flutter.dev';
//   Future<void> _launchInBrowser(String url) async {
//     if (await canLaunch(url)) {
//       await launch(
//         url,
//         forceSafariVC: false,
//         forceWebView: false,
//         headers: <String, String>{'my_header_key': 'my_header_value'},
//       );
//     } else {
//       throw 'Could not launch $url';
//     }
//   }
//
//   Future<void> _launchUniversalLinkIos(String url) async {
//     if (await canLaunch(url)) {
//       final bool nativeAppLaunchSucceeded = await launch(
//         url,
//         forceSafariVC: false,
//         universalLinksOnly: true,
//       );
//       if (!nativeAppLaunchSucceeded) {
//         await launch(
//           url,
//           forceSafariVC: true,
//         );
//       }
//     }
//   }
//
//   void _launchURL() async => await canLaunch(_url)
//       ? await launch(_url)
//       : throw 'Could not launch $_url';
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("My Schedule"),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             RaisedButton(onPressed: () {
//               _launchInBrowser(
//                   "https://www.google.com/maps/dir/43.7967876,-79.5331616/43.5184049,-79.8473993/@43.6218599,-79.6908486,9z/data=!4m2!4m1!3e0");
//             })
//           ],
//         ),
//       ),
//     );
//   }
// }
