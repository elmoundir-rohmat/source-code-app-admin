//web


/*
import 'dart:async';
import 'dart:convert';
// import 'FakeUi.dart' if (dart.library.html) 'RealUi.dart' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' hide Point, Events;
import 'dart:io' as Platform;

import '../constants/ColorCodes.dart';
import '../providers/addressitems.dart';

import '../screens/map_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_google_places_web/flutter_google_places_web.dart';
import 'package:google_maps/google_maps.dart' hide Icon;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/images.dart';
import 'package:hive/hive.dart';
import 'dart:ui' as ui;
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../screens/return_screen.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../utils/ResponsiveLayout.dart';
import '../screens/login_screen.dart';
import '../constants/IConstants.dart';

import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';

import '../screens/addressbook_screen.dart';
import '../screens/confirmorder_screen.dart';
import '../handler/locationJs.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ExampleScreen extends StatefulWidget {
  static const routeName = '/address-screen';

  @override
  _ExampleScreenState createState() => _ExampleScreenState();

}
class _ExampleScreenState extends State<ExampleScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Box<Product> productBox;
  Widget _child;
  double _lat, _lng;
  String _address = "";
  String _fullAddress = "";
  bool _permissiongrant = false;
  int count = 0;
  int htmlId = 1;
  bool _isWeb = false;

  SharedPreferences prefs;
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  LatLng myLatlng;

  bool _isLoading = false;
  Marker marker;
  String addressid = "";
  GMap map;
  String addresstype = "";
  String _addresses = " ";

  String latitude = "";
  String _deliverylocation = "";
  String longitude = "";
  String branch = "";
  var _home = Color(0xff035733);
  var _work = Colors.grey;
  var _other = Colors.grey;
  var _addresstag = "home";
  double _homeWidth = 2.0;
  double _workWidth = 1.0;
  double _otherWidth = 1.0;
  String addressLine = "";
  final _form = GlobalKey<FormState>();
  TextEditingController _controllerHouseno = new TextEditingController();
  TextEditingController _controllerApartment = new TextEditingController();
  TextEditingController _controllerStreet = new TextEditingController();
  TextEditingController _controllerLandmark = new TextEditingController();
  TextEditingController _controllerArea = new TextEditingController();
  TextEditingController _controllerPincode = new TextEditingController();

  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    try {
      // String os = Platform.operatingSystem;
      if (Platform.Platform.isIOS) {
        setState(() {
          _isWeb = false;
        });
      } else {
        setState(() {
          _isWeb = false;
        });
      }
    } catch (e) {
      setState(() {
        _isWeb = true;
      });
    }



    Future.delayed(Duration.zero, () async {
      prefs  = await SharedPreferences.getInstance();
      setState(() {

        try {
          _lat = double.parse(prefs.getString("latitude"));
          _lng = double.parse(prefs.getString("longitude"));
        }catch (e){};
      });
      _child = SpinKitPulse(
        color: Colors.grey,
        size: 100.0,
      );
      setState(() {
        success1(
            double.parse(prefs.getString("latitude")),
            double.parse(prefs.getString("longitude"))
        );
      });


    });


   // getCurrentLocation();
    super.initState();
  }

  Future<void> success1(double latitude,
      double longitude,) async {
    debugPrint("lat ... long ..siccess 1"+latitude.toString()+longitude.toString());
    const _host = 'https://maps.google.com/maps/api/geocode/json';
    const apiKey =
        "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI&v=3.21.5a&libraries=drawing&signed_in=true&libraries=places,drawing,geometry.key";

    final uri =
    await Uri.parse('$_host?key=$apiKey&latlng=$latitude,$longitude');
    debugPrint("uri...."+uri.toString());
    http.Response response = await http.get(uri);


    final responseJson = json.decode(utf8.decode(response.bodyBytes));

    final resultJson = json.encode(responseJson['results']);
    final resultJsondecode = json.decode(resultJson);

    List data = []; //list for categories

    resultJsondecode.asMap().forEach((index, value) =>
        data.add(resultJsondecode[index] as Map<String, dynamic>));

    final addressJson = json.encode(data[0]['address_components']);
    final addressJsondecode = json.decode(addressJson);

    List dataAddress = []; //list for categories

    addressJsondecode.asMap().forEach((index, value) =>
        dataAddress.add(addressJsondecode[index] as Map<String, dynamic>));
setState(() {
  for (int i = 0; i < dataAddress.length; i++) {
    setState(() {
      if (i == 0) {
        if (i == dataAddress.length - 1) {
          _fullAddress = dataAddress[i]["long_name"];
        } else {
          _fullAddress = dataAddress[i]["long_name"] + ", ";
        }
      } else {
        if (i == dataAddress.length - 1) {
          _fullAddress = _fullAddress + dataAddress[i]["long_name"];
        } else {
          _fullAddress = _fullAddress + dataAddress[i]["long_name"] + ", ";
        }
      }
      setState(() {
        _address = dataAddress[dataAddress.length - 4]["long_name"];
      });

    });
  }
});


    setState(() {
      _permissiongrant = true;
      _lat = latitude;
      _lng = longitude;
    });
    _child = mapWidget();
  }

  success(pos) {
    try {
      setState(() {
        success1(

  pos.coords.latitude,
  pos.coords.longitude,

        );

      });



    } catch (ex) {}
  }

  void getCurrentLocation() async {
    getCurrentPosition(allowInterop((pos) => success(pos)));

    // getCurrentPosition(allowInterop((pos) => success(pos)));
  }

  Future<void> _addresstoLatLong(String address) async {
    String createdViewUpdate = "7";

    const _host = 'https://maps.google.com/maps/api/geocode/json';
    const apiKey =
        "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI&v=3.21.5a&libraries=drawing&signed_in=true&libraries=places,drawing,geometry.key";

    final uri = Uri.parse('$_host?key=$apiKey&address=$address');
    http.Response response = await http.get(uri);
    final responseJson = json.decode(utf8.decode(response.bodyBytes));

    final resultJson = json.encode(responseJson['results']);
    final resultJsondecode = json.decode(resultJson);

    final geometryJson = json.encode(resultJsondecode[0]["geometry"]);
    final geometryJsondecode = json.decode(geometryJson);

    final locationJson = json.encode(geometryJsondecode['location']);
    final locationJsondecode = json.decode(locationJson);
    Navigator.pop(context);
    setState(() {
      _lat = locationJsondecode["lat"];
      _lng = locationJsondecode["lng"];
      debugPrint("Location : " + _lat.toString() + _lng.toString());
      setState(() {
        ++htmlId;
      });
      success1(_lat, _lng);
      // _child = mapWidget();
      myLatlng = new LatLng(_lat, _lng);
      debugPrint("myLatlng???????????........");
      debugPrint(myLatlng.toString());
      final mapOptions = new MapOptions()
        ..zoom = 16
        ..center = new LatLng(_lat, _lng);

      final elem = DivElement()
        ..id = htmlId as String
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      final map = new GMap(elem, mapOptions);

      final marker = Marker(MarkerOptions()
        ..position = myLatlng
        ..clickable = true
        ..draggable = true
        ..map = map
        ..title = 'Your Products will be delivered here');

      marker.onDragend.listen((position) async {
        var latttt = position.latLng.lat;
        var longgg = position.latLng.lng;
        print("check..........." +
            latttt.toString() +
            "     " +
            longgg.toString());
        success1(position.latLng.lat, position.latLng.lng);
      });
      this.htmlId = createdViewUpdate as int;
      setState(() {
        _lat = MapOptions().center.lat;
        _lng = MapOptions().center.lng;
        // myLatlng = MapOptions().center;
      });
      return elem;
    }
    );
  }

  _saveaddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('newaddresstype', _addresstag);
    latitude = prefs.getString('latitude');
    longitude = prefs.getString('longitude');
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } else {
      _dialogforSaveadd(context);
      setState(() {
        _isLoading = true;
      });
      String apartment;
      String street;
      String landmark;
      String pincode;
      if (_controllerApartment.text == "") {
        apartment = "";
      } else {
        apartment = ", " + _controllerApartment.text;
      }
      if (_controllerStreet.text == "") {
        street = "";
      } else {
        street = ", " + _controllerStreet.text;
      }
      if (_controllerLandmark.text == "") {
        landmark = "";
      } else {
        landmark = ", " + _controllerLandmark.text;
      }
      if (_controllerPincode.text == "") {
        pincode = "";
      } else {
        pincode = ", " + _controllerPincode.text;
      }
      debugPrint("example screen 123. . . .. . . ");
      debugPrint(latitude + "                   " + longitude);
      prefs.setString('newaddress',
          (_controllerHouseno.text + apartment + street + landmark + ", " + _fullAddress + ". " ));
      if (addresstype == "edit") {
        Provider.of<AddressItemsList>(context, listen: false).UpdateAddress(
            addressid, latitude, longitude, branch).then((_) {
          debugPrint('Addres');
          Provider.of<AddressItemsList>(context, listen: false)
              .fetchAddress()
              .then((_) {
            _isLoading = false;
            debugPrint('Addres1');
            if (prefs.containsKey("addressbook")) {
              if (prefs.getString("addressbook") == "AddressbookScreen") {
                prefs.setString("addressbook", "");
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                    AddressbookScreen.routeName);
              } else if (prefs.getString("addressbook") == "returnscreen") {
                Navigator.of(context).pushReplacementNamed(
                    ReturnScreen.routeName);
              } else {
                debugPrint('Addres3');
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                    ConfirmorderScreen.routeName,
                    arguments: {
                      "prev": "address_screen",
                    }
                );
              }
            }
            else {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(
                  ConfirmorderScreen.routeName,
                  arguments: {
                    "prev": "address_screen",
                  }
              );
            }
          });
        });
      }
      else {
        debugPrint("example screen . . . .. . . ");
        debugPrint(latitude + "                   " + longitude);

        Provider.of<AddressItemsList>(context, listen: false).NewAddress(
              latitude, longitude, branch).then((_) {
            Provider.of<AddressItemsList>(context, listen: false)
                .fetchAddress()
                .then((_) {
              Navigator.of(context).pop();
              if (prefs.containsKey("addressbook")) {
                if (prefs.getString("addressbook") ==
                    "AddressbookScreen") {
                  prefs.setString("addressbook", "");
                  Navigator.of(context).pop();

                  Navigator.of(context).pushReplacementNamed(
                      AddressbookScreen.routeName);
                } else if (prefs.getString("addressbook") == "returnscreen") {
                  Navigator.of(context).pushReplacementNamed(
                      ReturnScreen.routeName);
                } else {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(
                      CartScreen.routeName,
                      arguments: {
                        "prev": "address_screen",
                      }
                  );
                }
              } else {
                if (productBox.length > 0) {
                  if (prefs.getString("mobile").toString() != "null") {
                    debugPrint("present");
                    prefs.setString("isPickup", "no");
                    //prefs.setString("isPickup", "no");
                    Navigator.of(context).pushReplacementNamed(
                        CartScreen.routeName,
                        arguments: {"prev": "cart_screen"});
                  }
                  else {
                    debugPrint(" not present");
                    debugPrint("mobile" + "if");
                    //prefs.setString('prevscreen', "confirmorder");
                    Navigator.of(context)
                        .pushNamed(LoginScreen.routeName,);
                  }

                } else {
                  Navigator.of(context).pushReplacementNamed(
                    HomeScreen.routeName,
                  );
                }
              }
            });
          });

      }
    }
  }

  _dialogforSaveadd(BuildContext context) {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: 100.0,
                      width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width,
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(),
                          SizedBox(width: 40.0,),
                          Text('Saving...'),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }


  _dialogforChangeLocation() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: 250.0,
                width: 300.0,
                margin: EdgeInsets.only(
                    left: 50.0, top: 20.0, right: 50.0, bottom: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    print("OnTap............ ");
                    print(FlutterGooglePlacesWeb.showResults);
                    print("name....." +
                        FlutterGooglePlacesWeb.value[
                        'name']); // '1600 Amphitheatre Parkway, Mountain View, CA, USA'
                    print(FlutterGooglePlacesWeb
                        .value['streetAddress']); // '1600 Amphitheatre Parkway'
                    print(FlutterGooglePlacesWeb.value['city']); // 'CA'
                    print(FlutterGooglePlacesWeb.value['country']);
                    setState(() {
                      _fullAddress = FlutterGooglePlacesWeb.value['name'];
                      _address = FlutterGooglePlacesWeb.value['streetAddress'];
                    });
                    _addresstoLatLong(FlutterGooglePlacesWeb.value['name']);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 250.0,
                        width: 230.0,
                        margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                        child: FlutterGooglePlacesWeb(
                          apiKey: kGoogleApiKey,
                          proxyURL: "https://groce-bay.herokuapp.com/",
                          // apiKey: "AIzaSyBSR3pigsWMH7goi_CthGQFckfb5QPOH8E",
                          //proxyURL: 'https://cors-anywhere.herokuapp.com/',
                        ),
                      ),
                      SizedBox(width: 5,),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                        margin: EdgeInsets.only(top: 40,),
                        height: 30,
                        width: 60,
                        child: Center(child: Text('SUBMIT', style: TextStyle(
                            fontSize: 13, color: Colors.white),)),
                      )

                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    print("build........ ");
    print(FlutterGooglePlacesWeb.showResults);
    debugPrint("After..............");
    debugPrint(_lat.toString());
    debugPrint(_lng.toString());
    debugPrint(prefs.getString("latitude").toString());
    debugPrint(prefs.getString("longitude").toString());
       _lat = double.parse(prefs.getString("latitude").toString()) ;
        _lng = double.parse(prefs.getString("longitude").toString());
    debugPrint(_lat.toString());
    debugPrint(_lng.toString());
    queryData = MediaQuery.of(context);
    wid = queryData.size.width;
    maxwid = wid * 0.90;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        bottomNavigationBar: _bottemnavigation(),
        body:

        Stack(
          children: [
            _child,
            Positioned(
                top: 50,
                right: 5,
                child: Column(
                  children: [

                    SizedBox(
                      height: 5,
                    ),
                    GestureDetector(
                      onTap: () async {
                        getCurrentLocation();
                      },
                      child: Container(
                        height: 40,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Theme
                              .of(context)
                              .primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                            child: Text(
                              'Locate me',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            )),
                      ),
                    ),
                  ],
                )),
          ],
        ),

      ),
    );
  }

  Widget mapWidget() {
    print("fullAddress..............");
    print(_lat);
    print(_lng);


    // ignore: undefined_prefixed_name
    bool val = ui.platformViewRegistry.registerViewFactory(
        String.fromCharCode(htmlId), (int viewId) {
      myLatlng = new LatLng(_lat, _lng);
      debugPrint("myLatlng........");
      debugPrint(myLatlng.toString());
      final mapOptions = new MapOptions()
        ..zoom = 16
        ..center = myLatlng;

      final elem = DivElement()
        ..id = String.fromCharCode(htmlId)
        ..style.width = "100%"
        ..style.height = "100%"
        ..style.border = 'none';

      map = new GMap(elem, mapOptions);
      map.onCenterChanged.listen((event) {
        success1(map.center.lat, map.center.lng);
        setState(() {
          myLatlng = map.center;
        });
        marker = Marker(MarkerOptions()
          ..position = myLatlng
          ..clickable = true
          ..draggable = true
          ..map = map
          ..visible = false
          ..title = 'Your Products will be delivered here');
        marker.onDragend.listen((position) async {
          var latttt = position.latLng.lat;
          var longgg = position.latLng.lng;
          print("check..........." +
              latttt.toString() +
              "     " +
              longgg.toString());
          success1(position.latLng.lat, position.latLng.lng);
        });

        debugPrint("mycenter latLang event : " + map.center.toString());
      });
      debugPrint("my Element : " + elem.toString());


      return elem;
    });

    debugPrint("val..................... " + val.toString());

    return Column(
      children: <Widget>[
        Container(
          // flex: 7,
          child: Expanded(
            child: Stack(children: <Widget>[
              HtmlElementView(
                viewType: String.fromCharCode(htmlId),
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.location_pin, color: Colors.redAccent, size: 30,),
              ),
            ]
            ),
          ),
        ),
      ],
    );
  }

  Future<void> checkLocation() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      Navigator.of(context).pop();
      return;
    } else {
      // imp feature in adding async is the it automatically wrap into Future.
      var url = IConstants.API_PATH + 'check-location';
      try {
        final response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "lat": _lat.toString(),
          "long": _lng.toString(),
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final responseJson = json.decode(response.body);
        debugPrint("checkLocation........");
        debugPrint(_lat.toString());
        debugPrint(_lng.toString());
        debugPrint(responseJson.toString());
        bool _isCartCheck = false;
        if (responseJson['status'].toString() == "yes") {
          if (prefs.getString("branch") == responseJson['branch'].toString()) {
            prefs.setString('deliverylocation', _fullAddress);
            prefs.setString("latitude", _lat.toString());
            prefs.setString("longitude", _lng.toString());

            _saveaddress();

          } else {
            // location();
            if (prefs.getString("formapscreen") == "addressscreen") {
              debugPrint("No...........");
              debugPrint(addressLine);
              final routeArgs = ModalRoute
                  .of(context)
                  .settings
                  .arguments as Map<String, String>;
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(
                  ExampleScreen.routeName, arguments: {
                'addresstype': "new",
                'addressid': "",
                'delieveryLocation': addressLine,
                'latitude': _lat.toString(),
                'longitude': _lng.toString(),
                'branch': responseJson['branch'].toString(),
                'houseNo': routeArgs['houseNo'],
                'apartment': routeArgs['apartment'],
                'street': routeArgs['street'],
                'landmark': routeArgs['landmark'],
                'area': routeArgs['area'],
                'pincode': routeArgs['pincode'],
              });
            } else {
              if (productBox.length > 0) { //Suppose cart is not empty
                _dialogforAvailability(
                    prefs.getString("branch"),
                    responseJson['branch'].toString(),
                    prefs.getString("deliverylocation"),
                    prefs.getString("latitude"),
                    prefs.getString("longitude"));
              } else {
                prefs.setString('branch', responseJson['branch'].toString());
                prefs.setString('deliverylocation', addressLine);
                prefs.setString("latitude", _lat.toString());
                prefs.setString("longitude", _lng.toString());
                if (prefs.getString("skip") == "no") {
                  addprimarylocation();
                } else {
                  Navigator.of(context).pop();
                  if (prefs.getString("formapscreen") == "" ||
                      prefs.getString("formapscreen") == "homescreen") {
                    if (prefs.containsKey("fromcart")) {
                      if (prefs.getString("fromcart") == "cart_screen") {
                        prefs.remove("fromcart");
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            MapScreen.routeName,
                            ModalRoute.withName(CartScreen.routeName));
                        Navigator.of(context).pushReplacementNamed(
                          CartScreen.routeName,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                            context, HomeScreen.routeName, (route) => false);
                      }
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);
                    }
                  } else
                  if (prefs.getString("formapscreen") == "addressscreen") {
                    Navigator.of(context)
                        .pushReplacementNamed(
                        ExampleScreen.routeName, arguments: {
                      'addresstype': "new",
                      'addressid': "",
                    });
                  }
                }
              }
            }
          }
        }
        else {
          Navigator.of(context).pop();
          showInSnackBar();
        }
      }
      catch (error) {
        throw error;
      }
    }
  }

  _dialogforAvailability(String prevBranch, String currentBranch,
      String deliveryLocation, String latitude, String longitude) async {
    String itemCount = "";
    itemCount = "   " + productBox.length.toString() + " " + "items";
    var currency_format = "";
    bool _checkMembership = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    currency_format = prefs.getString("currency_format");
    if (prefs.getString("membership") == "1") {
      _checkMembership = true;
    } else {
      _checkMembership = false;
    }

    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  insetPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 85 / 100,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10.0,),
                          new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: "Availability Check",
                                  style: TextStyle(color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),),
                                new TextSpan(text: itemCount,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12.0)
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Text("Changing area", style: TextStyle(
                            color: Colors.red, fontSize: 12.0,),),
                          SizedBox(height: 10.0,),
                          Text(
                            "Product prices, availability and promos are area specific and may change accordingly. Confirm if you wish to continue.",
                            style: TextStyle(fontSize: 12.0),),
                          Spacer(),
                          SizedBox(height: 5.0,),
                          Divider(),
                          SizedBox(height: 5.0,),

                          Row(
                            children: <Widget>[
                              Container(
                                width: 53.0,
                              ),
                              Expanded(
                                flex: 4,
                                child: Text("Items", style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.0),),),

                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 15.0,),
                                    Text("Reason", style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0,),
                          Divider(),
                          SizedBox(
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 30 / 100,
                            child: new ListView.builder(
                              //physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: productBox.length,
                                itemBuilder: (_, i) =>
                                    Row(
                                      children: <Widget>[
                                        FadeInImage(
                                          image: NetworkImage(productBox.values
                                              .elementAt(i)
                                              .itemImage),
                                          placeholder: AssetImage(
                                              Images.defaultProductImg),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(
                                          width: 3.0,
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            mainAxisAlignment: MainAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(productBox.values
                                                  .elementAt(i)
                                                  .itemName, style: TextStyle(
                                                  fontSize: 12.0)),
                                              SizedBox(height: 3.0,),
                                              _checkMembership ?
                                              (productBox.values
                                                  .elementAt(i)
                                                  .membershipPrice == '-' ||
                                                  productBox.values
                                                      .elementAt(i)
                                                      .membershipPrice == "0")
                                                  ?
                                              (productBox.values
                                                  .elementAt(i)
                                                  .itemPrice <= 0 ||
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice
                                                      .toString() == "" ||
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice ==
                                                      productBox.values
                                                          .elementAt(i)
                                                          .varMrp)
                                                  ?
                                              Text(currency_format + " " +
                                                  productBox.values
                                                      .elementAt(i)
                                                      .varMrp
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.0))
                                                  :
                                              Text(currency_format + " " +
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.0))
                                                  :
                                              Text(currency_format + " " +
                                                  productBox.values
                                                      .elementAt(i)
                                                      .membershipPrice,
                                                  style: TextStyle(
                                                      fontSize: 12.0))
                                                  :

                                              (productBox.values
                                                  .elementAt(i)
                                                  .itemPrice <= 0 ||
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice
                                                      .toString() == "" ||
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice ==
                                                      productBox.values
                                                          .elementAt(i)
                                                          .varMrp)
                                                  ?
                                              Text(currency_format + " " +
                                                  productBox.values
                                                      .elementAt(i)
                                                      .varMrp
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.0))
                                                  :
                                              Text(currency_format + " " +
                                                  productBox.values
                                                      .elementAt(i)
                                                      .itemPrice
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.0))
                                            ],
                                          ),
                                        ),

                                        Expanded(
                                            flex: 4,
                                            child: Text("Not available",
                                                style: TextStyle(
                                                    fontSize: 12.0))),
                                      ],
                                    )
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Divider(),
                          SizedBox(height: 20.0,),
                          new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Note: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,)),
                                new TextSpan(
                                  text: 'By clicking on confirm, we will remove the unavailable items from your basket.',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (prefs.getString("formapscreen") == "" ||
                                      prefs.getString("formapscreen") ==
                                          "homescreen") {
                                    if (prefs.containsKey("fromcart")) {
                                      if (prefs.getString("fromcart") ==
                                          "cart_screen") {
                                        prefs.remove("fromcart");
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                            MapScreen.routeName,
                                            ModalRoute.withName(
                                                CartScreen.routeName));

                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                          CartScreen.routeName,
                                        );
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, HomeScreen.routeName, (
                                            route) => false);
                                      }
                                    } else {
                                      Navigator.pushNamedAndRemoveUntil(
                                          context, HomeScreen.routeName, (
                                          route) => false);
                                    }
                                  } else if (prefs.getString("formapscreen") ==
                                      "addressscreen") {
                                    Navigator.of(context).pushReplacementNamed(
                                        ExampleScreen.routeName, arguments: {
                                      'addresstype': "new",
                                      'addressid': "",
                                    });
                                  }
                                },
                                child: new Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 35 / 100,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)
                                  ),
                                  child: new Center(
                                    child: Text("CANCEL"),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.0,),
                              GestureDetector(
                                onTap: () async {
                                  prefs.setString('branch', currentBranch);
                                  prefs.setString(
                                      'deliverylocation', addressLine);
                                  prefs.setString("latitude", _lat.toString());
                                  prefs.setString("longitude", _lng.toString());
                                  if (prefs.getString("skip") == "no") {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    try {
                                      // *//*if (Platform.isIOS || Platform.isAndroid) {
                                      //   //Hive.openBox<Product>(productBoxName);
                                      // }*//*
                                    } catch (e) {
                                      Hive.registerAdapter(ProductAdapter());
                                      //Hive.openBox<Product>(productBoxName);
                                    }
                                    addprimarylocation();
                                  } else {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    try {

                                    } catch (e) {
                                      //await Hive.openBox<Product>(productBoxName);
                                    }
                                    Navigator.of(context).pop();
                                    if (prefs.getString("formapscreen") == "" ||
                                        prefs.getString("formapscreen") ==
                                            "homescreen") {
                                      if (prefs.containsKey("fromcart")) {
                                        if (prefs.getString("fromcart") ==
                                            "cart_screen") {
                                          prefs.remove("fromcart");
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                              MapScreen.routeName,
                                              ModalRoute.withName(
                                                  CartScreen.routeName));

                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                            CartScreen.routeName,
                                          );
                                        } else {
                                          Navigator.pushNamedAndRemoveUntil(
                                              context, HomeScreen.routeName, (
                                              route) => false);
                                        }
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context, HomeScreen.routeName, (
                                            route) => false);
                                      }
                                    } else
                                    if (prefs.getString("formapscreen") ==
                                        "addressscreen") {
                                      Navigator.of(context)
                                          .pushReplacementNamed(
                                          ExampleScreen.routeName, arguments: {
                                        'addresstype': "new",
                                        'addressid': "",
                                      });
                                    }
                                  }
                                },
                                child: new Container(
                                    height: 30.0,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 35 / 100,
                                    decoration: BoxDecoration(
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                        border: Border.all(color: Theme
                                            .of(context)
                                            .primaryColor,)
                                    ),
                                    child: new Center(
                                      child: Text("CONFIRM",
                                        style: TextStyle(color: Colors.white),),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0,),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }


  Future<void> addprimarylocation() async {
    debugPrint("A d d p r i m r y .....");
    var url = IConstants.API_PATH + 'add-primary-location';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString("userID"),
        "latitude": _lat.toString(),
        "longitude": _lng.toString(),
        "area": _address,
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(response.body);

      if (responseJson["data"].toString() == "true") {
        Navigator.of(context).pop();
        if (prefs.getString("formapscreen") == "" ||
            prefs.getString("formapscreen") == "homescreen") {
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(MapScreen.routeName,
                  ModalRoute.withName(CartScreen.routeName));
              Navigator.of(context).pushReplacementNamed(
                CartScreen.routeName,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (route) => false);
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.routeName, (route) => false);
          }
        } else if (prefs.getString("formapscreen") == "addressscreen") {
          Navigator.of(context)
              .pushReplacementNamed(ExampleScreen.routeName, arguments: {
            'addresstype': "new",
            'addressid': "",
          });
        }
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  void showInSnackBar() {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(IConstants.APP_NAME +
            translate('forconvience.Fellahi is not yet available at your current location!!!') //" is not yet available at you current location!!!"
        )));
  }

  _bottemnavigation() {

    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.45,
      width: MediaQuery
          .of(context)
          .size
          .width,
      color: Colors.white,

      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),

            SizedBox(
              height: 3.0,
            ),
            GestureDetector(
              onTap: () {
                _dialogforChangeLocation();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  Icon(
                    Icons.location_pin,
                    size: 18.0,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 3.0,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _address,

                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),

                        Text(
                          _fullAddress,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: const EdgeInsets.only(left: 15.0, right: 5),
                    padding: const EdgeInsets.all(3.0),

                    child:
                    Text(translate('forconvience.CHANGE'),//'CHANGE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14.0,
                            //fontWeight: FontWeight.bold,
                            color: Theme
                                .of(context)
                                .primaryColor)),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 10.0,
            ),
            // Divider(),

            Text(

              addressLine,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              //textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.0, fontWeight: FontWeight.normal),
            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Form(
                  key: _form,
                  child: Container(
                    margin: EdgeInsets.only(left: 20.0, top: 10.0, right: 20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: TextFormField(
                            controller: _controllerHouseno,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                                labelText: translate('forconvience.House /Flat /Block No.'),//"House /Flat /Block No.",
                                labelStyle: new TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                )
                            ),
                            onFieldSubmitted: (_) {
                              //FocusScope.of(context).requestFocus(_lnameFocusNode);
                            },

                          ),
                        ),

                        SizedBox(height: 5.0,),

                        SizedBox(height: 5.0,),

                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20.0,),
                      Text(translate('forconvience.Save As'),//"Save As",
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black54,
                        ),),
                      SizedBox(height: 10.0,),
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(left: 20.0, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _addresstag = "Home";
                              _home = Theme
                                  .of(context)
                                  .primaryColor;
                              _work = Colors.grey;
                              _other = Colors.grey;
                              _homeWidth = 2.0;
                              _workWidth = 1.0;
                              _otherWidth = 1.0;
                            });
                          },
                          child: Container(
                            width: 60.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border(
                                  top: BorderSide(
                                    width: _homeWidth, color: _home,),
                                  bottom: BorderSide(
                                    width: _homeWidth, color: _home,),
                                  left: BorderSide(
                                      width: _homeWidth, color: _home),
                                  right: BorderSide(
                                      width: _homeWidth, color: _home),
                                )),
                            height: 35.0,
                            child: Center(
                              child: Text(
                                translate('forconvience.Home'),// "Home",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.0,),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          //behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _addresstag = "Work";
                              _home = Colors.grey;
                              _work = Theme
                                  .of(context)
                                  .primaryColor;
                              _other = Colors.grey;
                              _homeWidth = 1.0;
                              _workWidth = 2.0;
                              _otherWidth = 1.0;
                            });
                          },
                          child: Container(
                            width: 60.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border(
                                  top: BorderSide(
                                    width: _workWidth, color: _work,),
                                  bottom: BorderSide(
                                    width: _workWidth, color: _work,),
                                  left: BorderSide(
                                    width: _workWidth, color: _work,),
                                  right: BorderSide(
                                    width: _workWidth, color: _work,),
                                )),
                            height: 35.0,
                            child: Center(
                              child: Text(
                                translate('forconvience.Work'),// "Office",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.0,),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _addresstag = "Other";
                              _home = Colors.grey;
                              _work = Colors.grey;
                              _other = Theme
                                  .of(context)
                                  .primaryColor;
                              _homeWidth = 1.0;
                              _workWidth = 1.0;
                              _otherWidth = 2.0;
                            });
                          },
                          child: Container(
                            width: 60,
                            height: 35.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border(
                                  top: BorderSide(
                                    width: _otherWidth, color: _other,),
                                  bottom: BorderSide(
                                    width: _otherWidth, color: _other,),
                                  left: BorderSide(
                                    width: _otherWidth, color: _other,),
                                  right: BorderSide(
                                    width: _otherWidth, color: _other,),
                                )),
                            child: Center(
                              child: Text(
                                translate('forconvience.Other'), //"Other",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(left: 9, top: 10,),
                //   child: CheckboxListTile(
                //     contentPadding: EdgeInsets.all(0),
                //     title: Text('Set this as my default delivery address'),
                //     value: _isChecked,
                //     controlAffinity: ListTileControlAffinity.leading,
                //     onChanged: (bool value) {
                //       setState(() {
                //         _isChecked = value;
                //       });
                //     },
                //   ),
                // )
                SizedBox(height: 5,),
                //    _buildBottomNavigationBar(),
                // SizedBox(height: 30,),

              ],
            ),

            GestureDetector(
              onTap: () async {
                _dialogforSaveadd;
                checkLocation();
              },

              child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 50.0,
                  margin: EdgeInsets.only(
                    left: 10.0, top: 5.0, right: 10.0,),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor,
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border(
                        top: BorderSide(width: 1.0, color: Theme
                            .of(context)
                            .primaryColor,),
                        bottom: BorderSide(width: 1.0, color: Theme
                            .of(context)
                            .primaryColor,),
                        left: BorderSide(width: 1.0, color: Theme
                            .of(context)
                            .primaryColor,),
                        right: BorderSide(width: 1.0, color: Theme
                            .of(context)
                            .primaryColor,),
                      )),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        translate('forconvience.Save & Proceed'),//'Save & Proceed',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18.0),
                      ),
                    ],
                  )),
            ),


          ],
        ),
      ),
    );
    // });
    //});
  }
}

*/







//mobile



//mobile..........

import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/floatbuttonbadge.dart';

import '../screens/MultipleImagePicker_screen.dart';
import '../screens/cart_screen.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/categoryOne.dart';
import '../widgets/categoryThree.dart';
import '../widgets/expandable_categories.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/websiteSlider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../widgets/items.dart';
import '../widgets/app_drawer.dart';
import '../widgets/carousel_sliderimage.dart';
import '../widgets/brands_items.dart';
import '../widgets/advertise1_items.dart';
import '../widgets/badge.dart';

import '../providers/addressitems.dart';
import '../providers/carouselitems.dart';
import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../providers/advertise1items.dart';
import '../providers/sellingitems.dart';
import '../providers/membershipitems.dart';

import '../constants/images.dart';
import '../screens/map_screen.dart';
import '../screens/sellingitem_screen.dart';
import '../screens/category_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../constants/IConstants.dart';
import '../screens/membership_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../providers/notificationitems.dart';
import '../constants/ColorCodes.dart';
import '../widgets/categoryTwo.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/mobile_authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../screens/return_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/addressitems.dart';
import '../screens/addressbook_screen.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/map_screen.dart';
import '../screens/map_address_screen.dart';
import 'home_screen.dart';
import '../constants/ColorCodes.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:location/location.dart' as loc;

import '../constants/IConstants.dart';
import '../screens/address_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../constants/images.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class ExampleScreen extends StatefulWidget {
  static const routeName = '/example-screen';

  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final _form = GlobalKey<FormState>();

  TextEditingController _controllerHouseno = new TextEditingController();
  TextEditingController _controllerApartment = new TextEditingController();
  TextEditingController _controllerStreet = new TextEditingController();
  TextEditingController _controllerLandmark = new TextEditingController();
  TextEditingController _controllerArea = new TextEditingController();
  TextEditingController _controllerPincode = new TextEditingController();

  var addressitemsData;
  SharedPreferences prefs;
  var _home =Color(0xFF45B34C);
  var _work = Colors.grey;
  var _other = Colors.grey;
  var _addresstag = "home";
  double _homeWidth = 2.0;
  double _workWidth = 1.0;
  double _otherWidth = 1.0;
  bool _isLoading = false;
  String addresstype = "";
  String addressid = "";

  bool _isChecked = false;
  String _deliverylocation = "";
  String _latitude = "";
  String _longitude = "";
  String _branch = "";
  var _isWeb= false;
  MediaQueryData queryData;
  double wid;
  double maxwid;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController _controller;
  Position position;
  Widget _child;
  double _lat, _lng;
  String _address = "",addressLine="";
  CameraPosition cameraposition;
  Timer timer;
  bool _serviceEnabled = false;
  bool _permissiongrant = false;
  bool _isinit = true;
  int count = 0;
  Box<Product> productBox;

  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  @override
  void initState() {

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
      addresstype=routeArgs['addresstype'];
      addressid = routeArgs['addressid'];
      if(routeArgs['delieveryLocation'].toString() == "") {
        debugPrint("if,,,,,,,,,,,,,,,,,,,,,");
        setState(() {
          _deliverylocation = prefs.getString("deliverylocation");
          _latitude = prefs.getString('latitude');
          _longitude = prefs.getString('longitude');
          _branch = prefs.getString("branch");
          debugPrint("lataddemp"+_latitude);
          debugPrint("longaddwmp"+_longitude);
          //mapForAddress();
        });
      } else {
        debugPrint("else");
        setState(() {
          _deliverylocation = routeArgs['delieveryLocation'];
          _latitude = routeArgs['latitude'];
          _longitude = routeArgs['longitude'];
          _branch = routeArgs['branch'];
          addresstype= routeArgs['addresstype'];
          debugPrint("addedit"+addresstype);
          debugPrint("latadd"+_latitude.toString());
          debugPrint("longadd"+_longitude.toString());
          _controllerHouseno.text = routeArgs['houseNo'];
          _controllerApartment.text = routeArgs['apartment'];
          _controllerStreet.text = routeArgs['street'];
          _controllerLandmark.text = routeArgs['landmark'];
          _controllerArea.text = routeArgs['area'];
          _controllerPincode.text = routeArgs['pincode'];
          // mapForAddress();
        });

      }
      setState(() {
        _lat = double.parse(_latitude);
        _lng =  double.parse(_longitude);
        if (_controller == null) {
          _child = mapWidget();
        } else {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
            ),
          );
          getAddress(_lat, _lng);
          _child = mapWidget();
        }
      });

      // _controllerHouseno.text=_deliverylocation;
    });
    productBox = Hive.box<Product>(productBoxName);
    _child = SpinKitPulse(
      color: Colors.grey,
      size: 100.0,
    );


    super.initState();

    timer = Timer.periodic(
        Duration(seconds: 5),
            (Timer t) => _permissiongrant
            ? !_serviceEnabled ? getCurrentLocation() : closed()
            : "");


    try {
      if (Platform.isIOS) {
        setState(() {
          _isWeb = false;
        });
      } else {
        setState(() {
          _isWeb = false;
        });
      }
    } catch (e) {
      setState(() {
        _isWeb = true;
      });
    }

  }
  void closed() {
    timer?.cancel();
  }


  void mapForAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("new adreess map"+prefs.getString('newaddress').toString());
    var addresses;
    try {
      addresses = await Geocoder.local.findAddressesFromQuery(
          prefs.getString('newaddress').toString());
    }
    catch(e){
      addresses = await Geocoder.local.findAddressesFromQuery(
          prefs.getString('deli'));
    }
    var first = addresses.first;

    setState(() {
      _lat = first.coordinates.latitude;
      _lng = first.coordinates.longitude;
      debugPrint("maplat"+_lat.toString());
      debugPrint("maplong"+_lng.toString());
      getAddress(_lat, _lng);
    });

  }
  @override
  void dispose() {
    timer?.cancel();
    _controllerHouseno.dispose();
    _controllerApartment.dispose();
    _controllerStreet.dispose();
    _controllerLandmark.dispose();
    _controllerArea.dispose();
    _controllerPincode.dispose();
    super.dispose();
  }




  void getCurrentLocation() async {
    PermissionStatus permission =
    await LocationPermissions().requestPermissions();
    permission = await LocationPermissions().checkPermissionStatus();

    if (permission.toString() == "PermissionStatus.granted") {
      setState(() {
        _permissiongrant = true;
      });
      checkusergps();
    } else {
      setState(() {
        _permissiongrant = false;
      });
      // checkusergps();
      Prediction p = await PlacesAutocomplete.show(
          mode: Mode.overlay, context: context, apiKey: kGoogleApiKey);
      displayPrediction(p);
    }
  }

  checkusergps() async {
    loc.Location location = new loc.Location();
    var temp = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = temp;
    });
    if (!_serviceEnabled) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        setState(() {
          count++;
        });
        if (count == 1)

          location.requestService();
      }
    } else {
      Position res = await Geolocator().getCurrentPosition();
      setState(() {
        position = res;
        _lat = position.latitude;
        _lng = position.longitude;

        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
          ),
        );
        _child = mapWidget();
      });
      await getAddress(_lat, _lng);
    }
  }

  Set<Marker> _createMarker() {
    return <Marker>[
      Marker(
          markerId: MarkerId("home"),
          position: LatLng(_lat, _lng),
          draggable: false,
//          icon: BitmapDescriptor.,
          infoWindow:
          InfoWindow(title: "Your Products will be delivered here")),
    ].toSet();
  }

  List<Placemark> placemark;

  void getAddress(double latitude, double longitude) async {
    debugPrint("maplat"+latitude.toString());
    debugPrint("maplong"+longitude.toString());
    loc.Location location = new loc.Location();
    var temp = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = temp;
    });
    if (!_serviceEnabled) {
      checkusergps();
    }
    placemark =
    await Geolocator().placemarkFromCoordinates(latitude, longitude);
    setState(() {
      mapAddress();
    });

  }
  mapAddress()async{

    // _address=_deliverylocation;
    debugPrint("deliverylocation"+_deliverylocation);
    debugPrint("deliverylocation"+_deliverylocation);
    if (placemark[0].subLocality.toString() == "") {
      if (placemark[0].locality.toString() == "") {
        _address = "";
        addressLine="";
        _child = mapWidget();
      } else {
        // _address = placemark[0].locality.toString();
        final coordinates = new Coordinates(_lat, _lng);
        var addresses;
        addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);

        var first = addresses.first;

        //print("${first.featureName} :${first.subLocality}: ${first.locality}:${first.adminArea}:${first.adminArea}:${first.postalCode}:");
        setState(() {

          _address = (first.featureName!=null)?(first.featureName):first.featureName;
          addressLine=first.addressLine;
          debugPrint("addressline"+addressLine);
        });

        _child = mapWidget();
      }
    } else {
      // _address = final coordinates = new Coordinates(_lat, _lng);
      var addresses;
      addresses = await Geocoder.local.findAddressesFromCoordinates(new Coordinates(_lat, _lng));

      var first = addresses.first;
      // print("${first.featureName} :${first.subLocality}: ${first.locality}:${first.adminArea}:${first.postalCode}");
      setState(() {

        _address = (first.featureName!=null)?(first.featureName):first.featureName;
        addressLine=first.addressLine;
        debugPrint("addressline"+addressLine);
      });
      _child = mapWidget();
    }

  }


  Future<void> _onCameraMove(CameraPosition position) async {
    setState(() {
      _lat = position.target.latitude;
      _lng = position.target.longitude;
      // _createMarker();
    });
  }

  Future<void> _onCameraIdle() async {
    await getAddress(_lat, _lng);
  }

  changelocation(Place place) async {
    Navigator.of(context).pop();

    var addresses =
    await Geocoder.local.findAddressesFromQuery(place.description);
    var first = addresses.first;

    setState(() {
      _lat = first.coordinates.latitude;
      _lng = first.coordinates.longitude;
    });
    await getAddress(first.coordinates.latitude, first.coordinates.longitude);

    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
      ),
    );
  }

  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      setState(() {
        _lat = detail.result.geometry.location.lat;
        _lng = detail.result.geometry.location.lng;
        if (_controller == null) {
          _child = mapWidget();
        } else {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
            ),
          );

          getAddress(_lat, _lng);
          _child = mapWidget();
        }
      });
      debugPrint("longdisplay"+_lng.toString());
      debugPrint("latdisplay"+_lat.toString());

    }
  }

  checkusergps1() async {
    loc.Location location = new loc.Location();
    var temp = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = temp;
    });

    if (!_serviceEnabled) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        setState(() {
          count++;
        });

        location.requestService();
      }
    } else {
      await getAddress(_lat, _lng);

      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
        ),
      );
    }
  }

  _dialogforProcessing() {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AbsorbPointer(
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                  ),
                );
              }
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//systemNavigationBarColor:
//  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: Theme
          .of(context)
          .primaryColor, // status bar color
    ));


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true, key: _scaffoldKey,
        bottomNavigationBar: _bottomnavigation(),
        body:

        Stack(
          children: [
            _child,
            Positioned(
                top: 50,
                right: 5,
                child: Column(
                  children: [

                    SizedBox(
                      height: 5,
                    ),

                  ],
                )),
          ],
        ),

      ),
    );
  }
  _bottomnavigation(){

    return Container(

      //   height: MediaQuery.of(context).size.height/2.5,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child:
        Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),

                SizedBox(
                  height: 3.0,
                ),
                GestureDetector(
                  onTap: () async {
//                    _settingModalBottomSheet(context);

                    Prediction p = await PlacesAutocomplete.show(
                        mode: Mode.overlay,
                        context: context,
                        apiKey: kGoogleApiKey);
                    displayPrediction(p);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(
                        Icons.location_pin,
                        size: 18.0,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
                      Expanded(
                        child: Text(

                          addressLine,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          //textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      //  Spacer(),

                      Text(translate('forconvience.CHANGE'),//'CHANGE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0,
                              //fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                      // ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 10.0,
                ),
                // Divider(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Form(
                      key: _form,
                      child: Container(

                        margin: EdgeInsets.only(left: 20.0, top: 10.0, right: 20),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width ,
                              child: TextFormField(
                                controller: _controllerHouseno,
                                textAlign: TextAlign.left,
                                decoration: InputDecoration(
                                    labelText: translate('forconvience.House /Flat /Block No.'),//"House /Flat /Block No.",
                                    labelStyle: new TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    )
                                ),
                                onFieldSubmitted: (_) {
                                  //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                },

                              ),
                            ),

                            SizedBox(height: 5.0,),

                            SizedBox(height: 5.0,),

                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20.0,),
                          Text(translate('forconvience.Save As'),//"Save As",
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black54,
                            ),),
                          SizedBox(height: 10.0,),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 20.0,bottom:10),
                      child: Row(
                        children: <Widget>[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint("tap home");
                                setState(() {
                                  _addresstag = "Home";
                                  _home = Theme.of(context).primaryColor;
                                  _work = Colors.grey;
                                  _other = Colors.grey;
                                  _homeWidth = 2.0;
                                  _workWidth = 1.0;
                                  _otherWidth = 1.0;
                                  debugPrint("otehrcc,oor"+_home.toString());
                                });
                              },
                              child: Container(
                                width: 65.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _homeWidth, color: _home,),
                                      bottom: BorderSide(width: _homeWidth, color: _home,),
                                      left: BorderSide(width: _homeWidth, color: _home),
                                      right: BorderSide(width: _homeWidth, color: _home),
                                    )),
                                height: 35.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(
                                    child: Text(
                                      translate('forconvience.Home'),

                                      //"Home",
                                      style: TextStyle(

                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.0,),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              //behavior: HitTestBehavior.translucent,
                              onTap: () {
                                debugPrint("tap work");
                                setState(() {
                                  _addresstag = "Work";
                                  _home = Colors.grey;
                                  _work = Theme.of(context).primaryColor;
                                  _other = Colors.grey;
                                  _homeWidth = 1.0;
                                  _workWidth = 2.0;
                                  _otherWidth = 1.0;
                                  debugPrint("otehrcc,oor"+_work.toString());
                                });
                              },
                              child: Container(
                                width: 65.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _workWidth, color: _work,),
                                      bottom: BorderSide(width: _workWidth, color: _work,),
                                      left: BorderSide(width: _workWidth, color: _work,),
                                      right: BorderSide(width: _workWidth, color: _work,),
                                    )),
                                height: 35.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(
                                    child: Text(
                                      translate('forconvience.Work'),//"Office",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 15.0,),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                debugPrint("tap other");

                                setState(() {
                                  _addresstag = "Other";
                                  _home = Colors.grey;
                                  _work = Colors.grey;
                                  _other = Theme.of(context).primaryColor;
                                  _homeWidth = 1.0;
                                  _workWidth = 1.0;
                                  _otherWidth = 2.0;
                                  debugPrint("otehrcc,oor"+_other.toString());
                                });
                              },
                              child: Container(
                                width: 65,
                                height: 35.0,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(3.0),
                                    border: Border(
                                      top: BorderSide(width: _otherWidth, color: _other,),
                                      bottom: BorderSide(width: _otherWidth, color: _other,),
                                      left: BorderSide(width: _otherWidth, color: _other,),
                                      right: BorderSide(width: _otherWidth, color: _other,),
                                    )),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Center(
                                    child: Text(
                                      translate('forconvience.Other'), //"Other",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(left: 9, top: 10,),
                    //   child: CheckboxListTile(
                    //     contentPadding: EdgeInsets.all(0),
                    //     title: Text('Set this as my default delivery address'),
                    //     value: _isChecked,
                    //     controlAffinity: ListTileControlAffinity.leading,
                    //     onChanged: (bool value) {
                    //       setState(() {
                    //         _isChecked = value;
                    //       });
                    //     },
                    //   ),
                    // )
                    SizedBox(height: 5,),
                    //    _buildBottomNavigationBar(),
                    // SizedBox(height: 30,),

                  ],
                ),

                GestureDetector(
                  onTap: () async {
                    _dialogforProcessing();
                    checkLocation();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom:10.0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        margin: EdgeInsets.only(
                          left: 10.0, top: 5.0, right: 10.0, ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3.0),
                            border: Border(
                              top: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                              bottom: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                              left: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                              right: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              translate('forconvience.Save & Proceed'), //'Save & Proceed',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                            ),
                          ],
                        )),
                  ),
                ),

              ],
            ),
          ),
        ));
    // });
    //});
  }
  Widget mapWidget() {



    return Column(
      children: <Widget>[
        Expanded(
            flex: 7,
            child:

            Stack(children: <Widget>[
              GoogleMap(
                  mapType: MapType.normal,
                  // markers: _createMarker(),
                  mapToolbarEnabled: true,
                  onCameraIdle: _onCameraIdle,
                  onCameraMove: _onCameraMove,
                  myLocationEnabled: true,
                  padding: (Platform.isAndroid)?EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).size.height/3, right: 0, left: 0):null,

                  initialCameraPosition: CameraPosition(
                    target: LatLng(_lat, _lng),
                    zoom: 16.0,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  }

              ),

              //This is your marker
              Container(
                padding: (Platform.isAndroid)?EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).size.height/3, right: 0, left: 0):null,
                child: Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.location_pin,color: Colors.redAccent,size: 40,),
                ),
              ),


            ])

        ),

      ],
    );
  }


  _dialogforSaveadd(BuildContext context) {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: 100.0,
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                          SizedBox(width: 40.0,),
                          Text(
                            translate('forconvience.Saving'),
                            //'Saving...'
                          ),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }
  _saveaddress() async {
    prefs.setString('newaddresstype', _addresstag);
    debugPrint("addresstag" + _addresstag.toString());
    debugPrint("del loction"+_deliverylocation.toString());
    debugPrint("del loca"+prefs.getString('deliverylocation'));
    debugPrint("lat long"+prefs.getString('latitude')+"  "+prefs.getString('longitude'));
    _latitude=prefs.getString('latitude');
    _longitude=prefs.getString('longitude');
    final isValid = _form.currentState.validate();
    if (!isValid) {
      Navigator.of(context);
      return;
    } else {
      _dialogforSaveadd(context);
      setState(() {
        _isLoading = true;
      });

      String apartment;
      String street;
      String landmark;
      String pincode;

      if (_controllerApartment.text == "") {
        apartment = "";
      } else {
        apartment = ", " + _controllerApartment.text;
      }

      if (_controllerStreet.text == "") {
        street = "";
      } else {
        street = ", " + _controllerStreet.text;
      }

      if (_controllerLandmark.text == "") {
        landmark = "";
      } else {
        landmark = ", " + _controllerLandmark.text;
      }

      if (_controllerPincode.text == "") {
        pincode = "";
      } else {
        pincode = ", " + _controllerPincode.text;
      }
      debugPrint(translate('forconvience.ADD')+_address);
      debugPrint("addline"+addressLine);
      debugPrint("house no"+_controllerHouseno.text.toString());
      debugPrint("location"+_deliverylocation.toString());

      (_controllerHouseno.text.isEmpty)?
      prefs.setString('newaddress',
          (_controllerHouseno.text + apartment + street + landmark + " "+
              _controllerArea.text +" "+ addressLine.toString() + " - " +
              pincode)):
      prefs.setString('newaddress',
          (_controllerHouseno.text + apartment + street + landmark + ", " +
              _controllerArea.text + ", " + addressLine.toString() + " - " +
              pincode));
      if (addresstype == "edit") {
        Provider.of<AddressItemsList>(context, listen: false).UpdateAddress(
            addressid, _latitude, _longitude, _branch).then((_) {
          Provider.of<AddressItemsList>(context, listen: false)
              .fetchAddress()
              .then((_) {
            _isLoading = false;
            Navigator.of(context).pop();
            if (prefs.containsKey("addressbook")) {
              if (prefs.getString("addressbook") == "AddressbookScreen") {
                prefs.setString("addressbook", "");
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                    AddressbookScreen.routeName);
              } else if (prefs.getString("addressbook") == "returnscreen") {
                Navigator.of(context).pushReplacementNamed(
                    ReturnScreen.routeName);
              } else {
                Navigator.of(context).pop();

                if (prefs.getString('mobile').toString() != "null") {
                  debugPrint("present");
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  prefs.setString("isPickup", "no");
                  Navigator.of(context).pushReplacementNamed(
                      ConfirmorderScreen.routeName,
                      arguments: {"prev": "cart_screen"});
                }
                else {
                  debugPrint(" not present");
                  debugPrint("mobile" + "if");
                  //prefs.setString('prevscreen', "confirmorder");
                  Navigator.of(context)
                      .pushNamed(MobileAuthScreen.routeName,);
                }

              }
            }
            else {


              debugPrint("address" + prefs.getString('mobile').toString());
              if (prefs.getString('mobile').toString() != "null") {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                debugPrint("present");
                prefs.setString("isPickup", "no");
                Navigator.of(context).pushReplacementNamed(
                    ConfirmorderScreen.routeName,
                    arguments: {"prev": "cart_screen"});
              }
              else {
                debugPrint(" not present");
                debugPrint("mobile" + "if");
                //prefs.setString('prevscreen', "confirmorder");
                Navigator.of(context)
                    .pushNamed(MobileAuthScreen.routeName,);
              }

            }
          });
        });
      }
      else {
        debugPrint("example screen . . . .. . . ");
        debugPrint(_latitude + "                   " + _longitude);
        Provider.of<AddressItemsList>(context, listen: false).NewAddress(
            _latitude, _longitude, _branch).then((_) {
          Provider.of<AddressItemsList>(context, listen: false)
              .fetchAddress()
              .then((_) {
            Navigator.of(context).pop();
            if (prefs.containsKey("addressbook")) {
              if (prefs.getString("addressbook") == "AddressbookScreen") {
                prefs.setString("addressbook", "");
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed(
                    AddressbookScreen.routeName);
              } else if (prefs.getString("addressbook") == "myorderdisplay") {
                final routeArgs = ModalRoute
                    .of(context)
                    .settings
                    .arguments as Map<String, String>;
                final orderid = routeArgs['orderid'];

                Navigator.of(context).pushReplacementNamed(
                    ReturnScreen.routeName,
                    arguments: {
                      'orderid': orderid,
                    }
                );
              } else {
                if (productBox.length > 0) {
                  if (prefs.getString('mobile').toString() != "null") {
                    debugPrint("present");
                    prefs.setString("isPickup", "no");
                    Navigator.of(context).pop();
                    //Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(
                        ConfirmorderScreen.routeName,
                        arguments: {"prev": "cart_screen"});
                  }
                  else {
                    debugPrint(" not present");
                    debugPrint("mobile" + "if");
                    //prefs.setString('prevscreen', "confirmorder");
                    Navigator.of(context)
                        .pushNamed(MobileAuthScreen.routeName,);
                  }

                } else {
                  Navigator.of(context).pushReplacementNamed(
                    HomeScreen.routeName,
                  );
                }
              }
            } else {
              if (productBox.length > 0) {
                if (prefs.getString('mobile').toString() != "null") {
                  debugPrint("present");
                  prefs.setString("isPickup", "no");
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(
                      ConfirmorderScreen.routeName,
                      arguments: {"prev": "cart_screen"});
                }
                else {
                  debugPrint(" not present");
                  debugPrint("mobile" + "if");
                  //prefs.setString('prevscreen', "confirmorder");
                  Navigator.of(context)
                      .pushNamed(MobileAuthScreen.routeName,);
                }

              } else {
                Navigator.of(context).pushReplacementNamed(
                  HomeScreen.routeName,
                );
              }
            }
          });
        });
      }
    }
  }

  location() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Provider.of<AddressItemsList>(context,listen: false).UpdateAddress(addressitemsData.items[addressitemsData.items.length - 1].userid, _latitude, _longitude, _branch).then((_) {
      Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
        Navigator.of(context).pop();
        if (prefs.containsKey("addressbook")) {
          if (prefs.getString("addressbook") == "AddressbookScreen") {
            prefs.setString("addressbook", "");
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
                AddressbookScreen.routeName);
          } else if(prefs.getString("addressbook") == "myorderdisplay") {
            final routeArgs = ModalRoute
                .of(context)
                .settings
                .arguments as Map<String, String>;
            final orderid = routeArgs['orderid'];

            Navigator.of(context).pushReplacementNamed(ReturnScreen.routeName,
                arguments: {
                  'orderid' : orderid,
                }
            );
          } else {
            if(productBox.length > 0) {
              if (prefs.getString('mobile').toString()!="null") {
                debugPrint("present");
                prefs.setString("isPickup", "no");
                Navigator.of(context).pushReplacementNamed(
                    ConfirmorderScreen.routeName,
                    arguments: {"prev": "cart_screen"});
              }
              else{
                debugPrint(" not present");
                debugPrint("mobile" +"if");
                //prefs.setString('prevscreen', "confirmorder");
                Navigator.of(context)
                    .pushNamed(MobileAuthScreen.routeName,);
              }

            } else {
              Navigator.of(context).pushReplacementNamed(
                HomeScreen.routeName,
              );
            }
          }
        } else {
          if(productBox.length > 0) {
            if (prefs.getString('mobile').toString()!="null") {
              debugPrint("present");
              prefs.setString("isPickup", "no");
              Navigator.of(context).pushReplacementNamed(
                  ConfirmorderScreen.routeName,
                  arguments: {"prev": "cart_screen"});
            }
            else{
              debugPrint(" not present");
              debugPrint("mobile" +"if");
              //prefs.setString('prevscreen', "confirmorder");
              Navigator.of(context)
                  .pushNamed(MobileAuthScreen.routeName,);
            }

          } else {
            Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,
            );
          }
        }
      });
    });
  }

  Future<void> checkLocation() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      Navigator.of(context).pop();
      return;
    }else {
      // imp feature in adding async is the it automatically wrap into Future.
      var url = IConstants.API_PATH + 'check-location';
      try {
        final response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "lat": _lat.toString(),
          "long": _lng.toString(),
        });
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final responseJson = json.decode(response.body);
        debugPrint("checkLocation........");
        debugPrint(_lat.toString());
        debugPrint(_lng.toString());
        debugPrint(responseJson.toString());
        bool _isCartCheck = false;
        if (responseJson['status'].toString() == "yes") {
          if (prefs.getString("branch") == responseJson['branch'].toString()) {
            debugPrint("if.......");
            debugPrint("addresslline"+addressLine);
            IConstants.deliverylocationmain.value = addressLine;
            prefs.setString('deliverylocation', addressLine);
            prefs.setString("latitude", _lat.toString());
            prefs.setString("longitude", _lng.toString());
            IConstants.currentdeliverylocation.value = "Available";
            _saveaddress();

          } else {
            // location();
            if (prefs.getString("formapscreen") == "addressscreen") {
              debugPrint("No...........");
              debugPrint("addressline......." + addressLine);
              final routeArgs = ModalRoute
                  .of(context)
                  .settings
                  .arguments as Map<String, String>;
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(
                  ExampleScreen.routeName, arguments: {
                'addresstype': "new",
                'addressid': "",
                'delieveryLocation': addressLine,
                'latitude': _lat.toString(),
                'longitude': _lng.toString(),
                'branch': responseJson['branch'].toString(),
                'houseNo': routeArgs['houseNo'],
                'apartment': routeArgs['apartment'],
                'street': routeArgs['street'],
                'landmark': routeArgs['landmark'],
                'area': routeArgs['area'],
                'pincode': routeArgs['pincode'],
              });
            } else {
              debugPrint( " Delivery Location..........."+prefs.getString("deliverylocation"));
              if (productBox.length > 0) { //Suppose cart is not empty
                _dialogforAvailability(
                    prefs.getString("branch"),
                    responseJson['branch'].toString(),
                    prefs.getString("deliverylocation"),
                    prefs.getString("latitude"),
                    prefs.getString("longitude"));
              } else {
                prefs.setString('branch', responseJson['branch'].toString());
                IConstants.deliverylocationmain.value = addressLine;
                prefs.setString('deliverylocation', addressLine);
                prefs.setString("latitude", _lat.toString());
                prefs.setString("longitude", _lng.toString());
                if (prefs.getString("skip") == "no") {
                  addprimarylocation();
                } else {
                  Navigator.of(context).pop();
                  if (prefs.getString("formapscreen") == "" ||
                      prefs.getString("formapscreen") == "homescreen") {
                    if (prefs.containsKey("fromcart")) {
                      if (prefs.getString("fromcart") == "cart_screen") {
                        prefs.remove("fromcart");
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            MapScreen.routeName,
                            ModalRoute.withName(CartScreen.routeName));
                        Navigator.of(context).pushReplacementNamed(
                          CartScreen.routeName,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                            context, HomeScreen.routeName, (route) => false);
                      }
                    } else {
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.routeName, (route) => false);
                    }
                  } else
                  if (prefs.getString("formapscreen") == "addressscreen") {
                    Navigator.of(context)
                        .pushReplacementNamed(
                        ExampleScreen.routeName, arguments: {
                      'addresstype': "new",
                      'addressid': "",
                    });
                  }
                }
              }
            }
          }
        }
        else {
          Navigator.of(context).pop();
          showInSnackBar();
        }
      }
      catch (error) {
        throw error;
      }
    }
  }


  _dialogforAvailability(String prevBranch, String currentBranch, String deliveryLocation, String latitude, String longitude) async {
    String itemCount = "";
    itemCount = "   " + productBox.length.toString() + " " + "items";
    var currency_format = "";
    bool _checkMembership = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    currency_format = prefs.getString("currency_format");
    if(prefs.getString("membership") == "1"){
      _checkMembership = true;
    } else {
      _checkMembership = false;
    }

    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  insetPadding: EdgeInsets.only(left: 20.0, right: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: MediaQuery.of(context).size.height * 85 / 100,
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10.0,),
                          new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              children: <TextSpan>[
                                TextSpan(text: "Availability Check", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0),),
                                new TextSpan(text: itemCount, style: TextStyle(color: Colors.grey, fontSize: 12.0)
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Text("Changing area", style: TextStyle(color: Colors.red, fontSize: 12.0,),),
                          SizedBox(height: 10.0,),
                          Text("Product prices, availability and promos are area specific and may change accordingly. Confirm if you wish to continue.",
                            style: TextStyle(fontSize: 12.0),),
                          Spacer(),
                          SizedBox(height: 5.0,),
                          Divider(),
                          SizedBox(height: 5.0,),

                          Row(
                            children: <Widget>[
                              Container(
                                width: 53.0,
                              ),
                              Expanded(
                                flex: 4,
                                child: Text("Items", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),),),

                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 15.0,),
                                    Text("Reason", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.0,),
                          Divider(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 30 / 100,
                            child: new ListView.builder(
                              //physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: productBox.length,
                                itemBuilder: (_, i) => Row(
                                  children: <Widget>[
                                    FadeInImage(
                                      image: NetworkImage(productBox.values.elementAt(i).itemImage),
                                      placeholder: AssetImage(Images.defaultProductImg),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      width: 3.0,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          Text(productBox.values.elementAt(i).itemName, style: TextStyle(fontSize: 12.0)),
                                          SizedBox(height: 3.0,),
                                          _checkMembership ?
                                          (productBox.values.elementAt(i).membershipPrice == '-' || productBox.values.elementAt(i).membershipPrice == "0")
                                              ?
                                          (productBox.values.elementAt(i).itemPrice <= 0 ||
                                              productBox.values.elementAt(i).itemPrice.toString() == "" ||
                                              productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp)
                                              ?
                                          Text(currency_format + " " + productBox.values.elementAt(i).varMrp.toString(), style: TextStyle(fontSize: 12.0))
                                              :
                                          Text(currency_format + " " + productBox.values.elementAt(i).itemPrice.toString(), style: TextStyle(fontSize: 12.0))
                                              :
                                          Text(currency_format + " " + productBox.values.elementAt(i).membershipPrice, style: TextStyle(fontSize: 12.0))
                                              :

                                          (productBox.values.elementAt(i).itemPrice <= 0 ||
                                              productBox.values.elementAt(i).itemPrice.toString() == "" ||
                                              productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp)
                                              ?
                                          Text(currency_format + " " + productBox.values.elementAt(i).varMrp.toString(), style: TextStyle(fontSize: 12.0))
                                              :
                                          Text(currency_format + " " + productBox.values.elementAt(i).itemPrice.toString(), style: TextStyle(fontSize: 12.0))
                                        ],
                                      ),
                                    ),

                                    Expanded(
                                        flex: 4,
                                        child: Text("Not available", style: TextStyle(fontSize: 12.0))),
                                  ],
                                )
                            ),
                          ),
                          SizedBox(height: 10.0,),
                          Divider(),
                          SizedBox(height: 20.0,),
                          new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 12.0,
                                color: Colors.grey,
                              ),
                              children: <TextSpan>[
                                new TextSpan(text: 'Note: ', style: TextStyle(fontWeight: FontWeight.bold, )),
                                new TextSpan(text: 'By clicking on confirm, we will remove the unavailable items from your basket.',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (prefs.getString("formapscreen") == "" ||
                                      prefs.getString("formapscreen") == "homescreen") {
                                    if (prefs.containsKey("fromcart")) {
                                      if (prefs.getString("fromcart") == "cart_screen") {
                                        prefs.remove("fromcart");
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                            MapScreen.routeName,
                                            ModalRoute.withName(CartScreen.routeName));

                                        Navigator.of(context).pushReplacementNamed(
                                          CartScreen.routeName,
                                        );
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                                      }
                                    } else {
                                      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                                    }
                                  } else if (prefs.getString("formapscreen") == "addressscreen") {
                                    Navigator.of(context).pushReplacementNamed(ExampleScreen.routeName, arguments: {
                                      'addresstype': "new",
                                      'addressid': "",
                                    });
                                  }                               },
                                child: new Container(
                                  width: MediaQuery.of(context).size.width * 35 / 100,
                                  height: 30.0,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)
                                  ),
                                  child: new Center(
                                    child: Text("CANCEL"),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.0,),
                              GestureDetector(
                                onTap: () async {
                                  prefs.setString('branch', currentBranch);
                                  prefs.setString('deliverylocation', addressLine);
                                  prefs.setString("latitude", _lat.toString());
                                  prefs.setString("longitude", _lng.toString());
                                  if (prefs.getString("skip") == "no") {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    try {
                                      if (Platform.isIOS || Platform.isAndroid) {
                                        //Hive.openBox<Product>(productBoxName);
                                      }
                                    } catch (e) {
                                      Hive.registerAdapter(ProductAdapter());
                                      //Hive.openBox<Product>(productBoxName);
                                    }
                                    addprimarylocation();
                                  } else {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    try {
                                      if (Platform.isIOS || Platform.isAndroid) {
                                        //await Hive.openBox<Product>(productBoxName);

                                        debugPrint("Opening box . . . .  . . . ");
                                      }
                                    } catch (e) {
                                      //await Hive.openBox<Product>(productBoxName);
                                    }
                                    Navigator.of(context).pop();
                                    if (prefs.getString("formapscreen") == "" ||
                                        prefs.getString("formapscreen") == "homescreen") {
                                      if (prefs.containsKey("fromcart")) {
                                        if (prefs.getString("fromcart") == "cart_screen") {
                                          prefs.remove("fromcart");
                                          Navigator.of(context).pushNamedAndRemoveUntil(
                                              MapScreen.routeName,
                                              ModalRoute.withName(CartScreen.routeName));

                                          Navigator.of(context).pushReplacementNamed(
                                            CartScreen.routeName,
                                          );
                                        } else {
                                          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                                        }
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                                      }
                                    } else if (prefs.getString("formapscreen") == "addressscreen") {
                                      Navigator.of(context)
                                          .pushReplacementNamed(ExampleScreen.routeName, arguments: {
                                        'addresstype': "new",
                                        'addressid': "",
                                      });
                                    }
                                  }
                                },
                                child: new Container(
                                    height: 30.0,
                                    width: MediaQuery.of(context).size.width * 35 / 100,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        border: Border.all(color: Theme.of(context).primaryColor,)
                                    ),
                                    child: new Center(
                                      child: Text("CONFIRM", style: TextStyle(color: Colors.white),),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.0,),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }

  Future<void> addprimarylocation() async {
    debugPrint("A d d p r i m r y .....");
    var url = IConstants.API_PATH + 'add-primary-location';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString("userID"),
        "latitude": _lat.toString(),
        "longitude": _lng.toString(),
        "area": addressLine,
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(response.body);

      if (responseJson["data"].toString() == "true") {
        Navigator.of(context).pop();
        if (prefs.getString("formapscreen") == "" ||
            prefs.getString("formapscreen") == "homescreen") {
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(MapScreen.routeName,
                  ModalRoute.withName(CartScreen.routeName));
              Navigator.of(context).pushReplacementNamed(
                CartScreen.routeName,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }
        } else if (prefs.getString("formapscreen") == "addressscreen") {
          Navigator.of(context)
              .pushReplacementNamed(ExampleScreen.routeName, arguments: {
            'addresstype': "new",
            'addressid': "",
          });
        }
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  void showInSnackBar() {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(IConstants.APP_NAME +
            translate('forconvience.Fellahi is not yet available at your current location!!!') //" is not yet available at you current location!!!"
        )));
  }


}


