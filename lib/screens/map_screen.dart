/*import 'dart:async';
import 'dart:convert';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'FakeUi.dart' if (dart.library.html) 'RealUi.dart' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' hide Point, Events;
import 'dart:io' as Platform;
import 'package:flutter_google_places_web/flutter_google_places_web.dart';
import 'package:google_maps/google_maps.dart' hide Icon;
import '../constants/images.dart';
import 'package:hive/hive.dart';
import 'dart:ui' as ui;
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/hiveDB.dart';
import '../main.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/IConstants.dart';
import '../screens/address_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';

import '../handler/locationJs.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Box<Product> productBox;
  Widget _child;
  double _lat, _lng;
  String _address = "";
  String _fullAddress = "";
  bool _permissiongrant = false;
  int count = 0;
  String htmlId = "7";
  bool _isWeb =false;
  SharedPreferences prefs;
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";
  MediaQueryData queryData;
  double wid;
  double maxwid;

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
      prefs = await SharedPreferences.getInstance();
    });
    _child = SpinKitPulse(
      color: Colors.grey,
      size: 100.0,
    );
    getCurrentLocation();
    super.initState();
  }

  Future<void> success1(
      double latitude,
      double longitude,
      ) async {
    const _host = 'https://maps.google.com/maps/api/geocode/json';
    const apiKey =
        "AIzaSyBSR3pigsWMH7goi_CthGQFckfb5QPOH8E&v=3.21.5a&libraries=drawing&signed_in=true&libraries=places,drawing,geometry.key";

    final uri =
    await Uri.parse('$_host?key=$apiKey&latlng=$latitude,$longitude');
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
        _address = dataAddress[dataAddress.length - 4]["long_name"];
      });
    }

    setState(() {
      _permissiongrant = true;
      _lat = latitude;
      _lng = longitude;
      _child = mapWidget();
    });
  }

  success(pos) {
    try {
      success1(
        pos.coords.latitude,
        pos.coords.longitude,
      );
    } catch (ex) {}
  }

  void getCurrentLocation() async {
    getCurrentPosition(allowInterop((pos) => success(pos)));
  }

  Future<void> _addresstoLatLong(String address) async {
    String createdViewUpdate = "7";

    const _host = 'https://maps.google.com/maps/api/geocode/json';
    const apiKey =
        "AIzaSyBSR3pigsWMH7goi_CthGQFckfb5QPOH8E&v=3.21.5a&libraries=drawing&signed_in=true&libraries=places,drawing,geometry.key";

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

      final myLatlng = new LatLng(_lat, _lng);
      final mapOptions = new MapOptions()
        ..zoom = 8
        ..center = new LatLng(_lat, _lng);

      final elem = DivElement()
        ..id = htmlId
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
        success1(position.latLng.lat, position.latLng.lng);
      });
      this.htmlId = createdViewUpdate;
      return elem;
    });
    _child = mapWidget();
  }

  _dialogforProcessing() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          });
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
                      Flexible(
                        flex: 9,
                        child: Container(
                          height: 250.0,
                          width: 300.0,
                          margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          child: FlutterGooglePlacesWeb(
                            apiKey: kGoogleApiKey,
                            proxyURL: "https://cors-anywhere.herokuapp.com/",
                           // apiKey: "AIzaSyBSR3pigsWMH7goi_CthGQFckfb5QPOH8E",
                            //proxyURL: 'https://cors-anywhere.herokuapp.com/',
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 58,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 20.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
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
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;

    return Scaffold(
         resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: Column(
            children: [
              if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Header(false),
              Expanded(

                child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(

                            height: MediaQuery.of(context).size.height,
                            child: _child
                        ),
                      ],
                    )

                ),
              ),

            ],
          ),
      );
  }

  Widget mapWidget() {

    // ignore: undefined_prefixed_name
    bool val =
    ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {
      final myLatlng = new LatLng(_lat, _lng);
      final mapOptions = new MapOptions()
        ..zoom = 8
        ..center = new LatLng(_lat, _lng);

      final elem = DivElement()
        ..id = htmlId
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
        success1(position.latLng.lat, position.latLng.lng);
      });
      return elem;
    });

    return  SingleChildScrollView(
        child: Column(
            children: [
              Container(
                 // flex: 7,
                  constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                height: MediaQuery.of(context).size.height * 0.70,
                  child: HtmlElementView(
                    viewType: htmlId,
                  )),
              Container(
               // flex: 3,
                  constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                height: MediaQuery.of(context).size.height * 0.30,
                //child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                             translate('forconvience.Select delivery location'),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              translate('forconvience.YOUR LOCATION'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, fontSize: 10.0),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 3.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            _dialogforChangeLocation();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Icon(
                                      Icons.location_on,
                                      size: 20.0,
                                      color: Colors.green,
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
                                  ],
                                ),
                              ),
                              //Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(translate('forconvience.CHANGE'),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context).primaryColor)),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                        GestureDetector(
                          onTap: () async {
                            _dialogforProcessing();
                            checkLocation();
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              margin: EdgeInsets.only(
                                  left: 10.0, top: 5.0, right: 10.0, bottom: 10.0),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.circular(3.0),
                                  border: Border(
                                    top: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    bottom: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    left: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                    right: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).accentColor,
                                    ),
                                  )),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                  translate('forconvience.Confirm location & Proceed'),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.0),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    )
              //  ),
              ),
              if(_isWeb) Footer(address: prefs.getString("restaurant_address"))
            ],
        //  ),
        ),

    );
  }

  Future<void> checkLocation() async {
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
      bool _isCartCheck = false;
      if (responseJson['status'].toString() == "yes") {
        if(prefs.getString("branch") == responseJson['branch'].toString()) {
          if (prefs.getString("formapscreen") == "addressscreen") {
            final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(AddressScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': _address,
              'latitude': _lat.toString(),
              'longitude': _lng.toString(),
              'branch': responseJson['branch'].toString(),
              'houseNo' : routeArgs['houseNo'],
              'apartment' : routeArgs['apartment'],
              'street' :  routeArgs['street'],
              'landmark' : routeArgs['landmark'],
              'area' : routeArgs['area'],
              'pincode' : routeArgs['pincode'],
            });
          } else {
            prefs.setString('branch', responseJson['branch'].toString());
            prefs.setString('deliverylocation', _address);
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
                    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                  }
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                }
              }
            }
          }
        } else {
          if (prefs.getString("formapscreen") == "addressscreen") {
            final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(AddressScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': _address,
              'latitude': _lat.toString(),
              'longitude': _lng.toString(),
              'branch': responseJson['branch'].toString(),
              'houseNo' : routeArgs['houseNo'],
              'apartment' : routeArgs['apartment'],
              'street' :  routeArgs['street'],
              'landmark' : routeArgs['landmark'],
              'area' : routeArgs['area'],
              'pincode' : routeArgs['pincode'],
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
              prefs.setString('deliverylocation', _address);
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
                      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                    }
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                  }
                } else if (prefs.getString("formapscreen") == "addressscreen") {
                  Navigator.of(context)
                      .pushReplacementNamed(
                      AddressScreen.routeName, arguments: {
                    'addresstype': "new",
                    'addressid': "",
                  });
                }
              }
            }
          }
        }
      } else {
        Navigator.of(context).pop();
        showInSnackBar();
      }
    } catch (error) {
      throw error;
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
                                    Navigator.of(context).pushReplacementNamed(AddressScreen.routeName, arguments: {
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
                                  prefs.setString('deliverylocation', _address);
                                  prefs.setString("latitude", _lat.toString());
                                  prefs.setString("longitude", _lng.toString());
                                  if (prefs.getString("skip") == "no") {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    addprimarylocation();
                                  } else {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
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
                                          .pushReplacementNamed(AddressScreen.routeName, arguments: {
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
              Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }
        } else if (prefs.getString("formapscreen") == "addressscreen") {
          Navigator.of(context)
              .pushReplacementNamed(AddressScreen.routeName, arguments: {
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
            translate('forconvience.Fellahi is not yet available at your current location!!!'))));
  }
}*/



//web..............................................................


//web....


/*
import 'dart:async';
import 'dart:convert';
// import 'FakeUi.dart' if (dart.library.html) 'RealUi.dart' as ui;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' hide Point, Events;
import 'dart:io' as Platform;

import 'package:flutter_google_places_web/flutter_google_places_web.dart';
import 'package:google_maps/google_maps.dart' hide Icon;
import 'package:hive/hive.dart';
import 'dart:ui' as ui;
import 'package:js/js.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/IConstants.dart';
import '../screens/address_screen.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/images.dart';
import '../handler/locationJs.dart';



class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
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

  String brandsName = "";
  SharedPreferences prefs;
  bool _isDelivering = true;
  bool _isSkip = false;
  String _deliverLocation = "";
  int unreadCount = 0;
  bool _isUnreadNot = false;
  bool checkSkip = false;
  String photourl = "";
  String name = "";
  String phone = "";
  String countryName = " ";
  String countrycode = " ";
  bool _isAvailable = false;
  TextEditingController controller = TextEditingController();
  bool _showOtp = false;
  int _timeRemaining = 30;
  Timer _timer;
  bool _isLoading = false;
  String apple = "";
  String email = "";
  String mobile = "";
  String tokenid = "";

  //SharedPreferences prefs;
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";//"AIzaSyBSR3pigsWMH7goi_CthGQFckfb5QPOH8E";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  LatLng myLatlng;

  Marker marker;

  GMap map;

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
      prefs = await SharedPreferences.getInstance();
    });
    _child = SpinKitPulse(
      color: Colors.grey,
      size: 100.0,
    );
    getCurrentLocation();
    super.initState();
  }

  Future<void> success1(double latitude,
      double longitude,) async {
    const _host = 'https://maps.google.com/maps/api/geocode/json';
    const apiKey =
        "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI&v=3.21.5a&libraries=drawing&signed_in=true&libraries=places,drawing,geometry.key";

    final uri =
    await Uri.parse('$_host?key=$apiKey&latlng=$latitude,$longitude');
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
        _address = dataAddress[dataAddress.length - 4]["long_name"];
      });
    }

    setState(() {
      _permissiongrant = true;
      _lat = latitude;
      _lng = longitude;
    });
    _child = mapWidget();
  }

  success(pos) {
    try {
      success1(
        pos.coords.latitude,
        pos.coords.longitude,
      );
    } catch (ex) {}
  }

  void getCurrentLocation() async {
    getCurrentPosition(allowInterop((pos) => success(pos)));
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
      setState(() {
        ++htmlId;
      });
      success1(_lat, _lng);
      // _child = mapWidget();
      myLatlng = new LatLng(_lat, _lng);
      final mapOptions = new MapOptions()
        ..zoom = 15
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

  _dialogforProcessing() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          });
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
    queryData = MediaQuery.of(context);
    wid = queryData.size.width;
    maxwid = wid * 0.90;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      bottomNavigationBar: _bottemnavigation(),
      body: _child,
    );
  }

  Widget mapWidget() {

    // ignore: undefined_prefixed_name
    bool val = ui.platformViewRegistry.registerViewFactory(
        String.fromCharCode(htmlId), (int viewId) {
      myLatlng = new LatLng(_lat, _lng);
      final mapOptions = new MapOptions()
        ..zoom = 15
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

          success1(position.latLng.lat, position.latLng.lng);
        });

      });


      return elem;
    });


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
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'check-location';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "lat": _lat.toString(),
        "long": _lng.toString(),
      });




      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("ismap","true");
      prefs.setString("ismapfetch","true");
      final responseJson = json.decode(response.body);
      bool _isCartCheck = false;
      if (responseJson['status'].toString() == "yes") {
        prefs.setString('defaultlocation', "true");
        prefs.setString("isdelivering","true");
        if (prefs.getString("branch") == responseJson['branch'].toString()) {



          setState(() {
            checkSkip = false;
            if (prefs.getString('FirstName') != null) {
              if (prefs.getString('LastName') != null) {
                name = prefs.getString('FirstName') +
                    " " +
                    prefs.getString('LastName');
              } else {
                name = prefs.getString('FirstName');
              }
            } else {
              name = "";
            }

            //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
            if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
              email = "";
            } else {
              email = prefs.getString('Email');
            }
            mobile = prefs.getString('Mobilenum');
            tokenid = prefs.getString('tokenid');

            if (prefs.getString('mobile') != null) {
              phone = prefs.getString('mobile');
            } else {
              phone = "";
            }
            if (prefs.getString('photoUrl') != null) {
              photourl =prefs.getString('photoUrl');
            } else {
              photourl = "";
            }
          });

          if (prefs.getString("formapscreen") == "addressscreen") {
            final routeArgs = ModalRoute
                .of(context)
                .settings
                .arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
                AddressScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': _address,
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
            prefs.setString('branch', responseJson['branch'].toString());
            prefs.setString('deliverylocation', _fullAddress);
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
              }
            }
          }
        } else {
          if (prefs.getString("formapscreen") == "addressscreen") {
            final routeArgs = ModalRoute
                .of(context)
                .settings
                .arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(
                AddressScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': _address,
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
              prefs.setString('deliverylocation', _fullAddress);
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
                } else if (prefs.getString("formapscreen") == "addressscreen") {
                  Navigator.of(context)
                      .pushReplacementNamed(
                      AddressScreen.routeName, arguments: {
                    'addresstype': "new",
                    'addressid': "",
                  });
                }
              }
            }
          }
        }
      } else {
        Navigator.of(context).pop();
        showInSnackBar();
      }
    } catch (error) {
      throw error;
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
                                    Navigator.of(context).pushReplacementNamed(AddressScreen.routeName, arguments: {
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
                                  prefs.setString('deliverylocation', _fullAddress);
                                  prefs.setString("latitude", _lat.toString());
                                  prefs.setString("longitude", _lng.toString());
                                  if (prefs.getString("skip") == "no") {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
                                    addprimarylocation();
                                  } else {
                                    //Hive.box<Product>(productBoxName).deleteFromDisk();
                                    Hive.box<Product>(productBoxName).clear();
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
                                          .pushReplacementNamed(AddressScreen.routeName, arguments: {
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
              prefs.setString('LoginStatus', "true");

              //prefs.setString('LoginStatus', "true");
              setState(() {
                checkSkip = false;
                if (prefs.getString('FirstName') != null) {
                  if (prefs.getString('LastName') != null) {
                    name = prefs.getString('FirstName') +
                        " " +
                        prefs.getString('LastName');
                  } else {
                    name = prefs.getString('FirstName');
                  }
                } else {
                  name = "";
                }

                //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
                if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
                  email = "";
                } else {
                  email = prefs.getString('Email');
                }
                mobile = prefs.getString('Mobilenum');
                tokenid = prefs.getString('tokenid');

                if (prefs.getString('mobile') != null) {
                  phone = prefs.getString('mobile');
                } else {
                  phone = "";
                }
                if (prefs.getString('photoUrl') != null) {
                  photourl =prefs.getString('photoUrl');
                } else {
                  photourl = "";
                }
              });





              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (route) => false);
            }
          } else {
            prefs.setString('deliverylocation', _fullAddress);
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.routeName, (route) => false);
          }
        } else if (prefs.getString("formapscreen") == "addressscreen") {
          Navigator.of(context)
              .pushReplacementNamed(AddressScreen.routeName, arguments: {
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
            translate('forconvience.Fellahi is not yet available at your current location!!!')//" is not yet available at you current location!!!"
        )));
  }

  _bottemnavigation() {

    return Container(
      // flex: 3,
        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))
            ? BoxConstraints(maxWidth: maxwid)
            : null,
        height: MediaQuery
            .of(context)
            .size
            .height * 0.30,
        //child: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate('forconvience.Select delivery location'),//'Select delivery location',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18.0),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate('forconvience.YOUR LOCATION'),//'YOUR LOCATION',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 10.0),
                ),
              ],
            ),
            SizedBox(
              height: 3.0,
            ),
            GestureDetector(
              onTap: () {
                _dialogforChangeLocation();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.location_on,
                          size: 20.0,
                          color: Colors.green,
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
                      ],
                    ),
                  ),
                  //Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(translate('forconvience.CHANGE'),//'CHANGE',
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Theme
                                  .of(context)
                                  .primaryColor)),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () async {

                _dialogforProcessing();

                checkLocation();
              },
              child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 50.0,
                  margin: EdgeInsets.only(
                      left: 10.0, top: 5.0, right: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .accentColor,
                      borderRadius: BorderRadius.circular(3.0),
                      border: Border(
                        top: BorderSide(
                          width: 1.0,
                          color: Theme
                              .of(context)
                              .accentColor,
                        ),
                        bottom: BorderSide(
                          width: 1.0,
                          color: Theme
                              .of(context)
                              .accentColor,
                        ),
                        left: BorderSide(
                          width: 1.0,
                          color: Theme
                              .of(context)
                              .accentColor,
                        ),
                        right: BorderSide(
                          width: 1.0,
                          color: Theme
                              .of(context)
                              .accentColor,
                        ),
                      )),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        translate('forconvience.Confirm location & Proceed'),//'Confirm location & Proceed',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18.0),
                      ),
                    ],
                  )),
            ),
          ],
        )
      //  ),
    );
  }

}

*/

//mobile......


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
import '../screens/example_screen.dart';
import '../screens/mobile_authentication.dart';
import 'package:flutter_translate/flutter_translate.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {

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
  SharedPreferences prefs;
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";
  Future _mapFuture = Future.delayed(Duration(milliseconds: 250), () => true);
  bool _initialIndicator = true;

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  void initState() {
    super.initState();
    productBox = Hive.box<Product>(productBoxName);
    _child = SpinKitPulse(
      color: Colors.grey,
      size: 100.0,
    );
    getCurrentLocation();

    timer = Timer.periodic(
        Duration(seconds: 5),
            (Timer t) => _permissiongrant
            ? !_serviceEnabled ? getCurrentLocation() : closed()
            : "");
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
    });
  }


  void closed() {
    timer?.cancel();
  }

  @override
  void dispose() {
    timer?.cancel();
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
       checkusergps();
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
      setState(() {
        addressLine= prefs.getString("restaurant_location");
        prefs.setString("latitude", prefs.getString("restaurant_lat"));
        prefs.setString("longitude", prefs.getString("restaurant_long"));
        IConstants.deliverylocationmain.value = addressLine;
      });

      prefs.setString("nopermission","yes");
      if (Theme.of(context).platform == TargetPlatform.android) {
        setState(() {
          count++;
          _initialIndicator = false;
        });
        if (count == 1)

          location.requestService();

        setState(() {
          _lat = double.parse(prefs.getString("latitude"));
          _lng = double.parse(prefs.getString("longitude"));
          cameraposition = CameraPosition(
            target: LatLng(_lat, _lng),
            zoom: 15.0,
          );
          _child = mapWidget();
        });



        Position res = await Geolocator().getCurrentPosition();
        setState(() {
          position = res;
          _lat = position.latitude;
          _lng = position.longitude;
          cameraposition = CameraPosition(
            target: LatLng(_lat, _lng),
            zoom: 15.0,
          );
          _initialIndicator = false;
          _child = mapWidget();
        });
        await getAddress(_lat, _lng);
      }
    } else {
      setState(() {
        _lat = double.parse(prefs.getString("latitude"));
        _lng = double.parse(prefs.getString("longitude"));
        cameraposition = CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 15.0,
        );
        _child = mapWidget();
      });

      Position res = await Geolocator().getCurrentPosition();
      setState(() {
        position = res;
        _lat = position.latitude;
        _lng = position.longitude;
        cameraposition = CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 15.0,
        );
        _initialIndicator = false;
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
//          icon: BitmapDescriptor.,
          infoWindow:
          InfoWindow(title: "Your Products will be delivered here")),
    ].toSet();
  }

  List<Placemark> placemark;

  void getAddress(double latitude, double longitude) async {
    loc.Location location = new loc.Location();
    var temp = await location.serviceEnabled();
    setState(() {
      _serviceEnabled = temp;
    });
    if (!_serviceEnabled) {
      checkusergps();
    }
    // else {
      placemark =
      await Geolocator().placemarkFromCoordinates(latitude, longitude);

      if (placemark[0].subLocality.toString() == "") {
        if (placemark[0].locality.toString() == "") {
          _address = "";
          addressLine = "";
          _child = mapWidget();
        } else {
          // _address = placemark[0].locality.toString();
          final coordinates = new Coordinates(_lat, _lng);
          var addresses;
          addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
          setState(() {
            var first = addresses.first;

            _address = (first.featureName != null) ? (first.featureName) : first
                .featureName;
            setState(() {
              addressLine = first.addressLine;
            });
            //(first.subLocality!=null)?(first.subLocality+","+first.locality+","+first.adminArea)
            // :(first.locality+","+first.adminArea);
          });

          _child = mapWidget();
        }
      } else {
        // _address = final coordinates = new Coordinates(_lat, _lng);
        var addresses;
        addresses = await Geocoder.local.findAddressesFromCoordinates(
            new Coordinates(_lat, _lng));
        setState(() {
          var first = addresses.first;

          _address =
          (first.featureName != null) ? (first.featureName) : first.featureName;
          setState(() {
            addressLine = first.addressLine;
          });

        });
        _child = mapWidget();
      }
    //}
  }

  Future<void> _onCameraMove(CameraPosition position) async {
    setState(() {
      _lat = position.target.latitude;
      _lng = position.target.longitude;
      _createMarker();
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
        CameraPosition(target: LatLng(_lat, _lng), zoom: 15.0),
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
              CameraPosition(target: LatLng(_lat, _lng), zoom: 15.0),
            ),
          );
          _initialIndicator = false;
          _child = mapWidget();
        }
      });
      await getAddress(_lat, _lng);
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
          CameraPosition(target: LatLng(_lat, _lng), zoom: 15.0),
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
                    child: CircularProgressIndicator(),
                  ),
                );
              }
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          resizeToAvoidBottomInset: false, key: _scaffoldKey,bottomNavigationBar: _bottomnavigation(),
          body: Stack(
            children: <Widget>[
            _child,
              _initialIndicator ? AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            )
              :
              SizedBox.shrink(),
            ],
          ),
      ),
    );
  }
  _bottomnavigation(){

    return SingleChildScrollView(
      child: Container(
          height: MediaQuery.of(context).size.height*0.27,
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    translate('forconvience.Select delivery location'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    translate('forconvience.YOUR LOCATION'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 10.0),
                  ),
                ],
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
                child: Container(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(
                        Icons.check_circle_outline,
                        size: 16.0,
                        color: Theme.of(context).accentColor,
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
                      Expanded(
                        child: Text(

                          addressLine??"",
                          //textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Spacer(),
                      Text(translate('forconvience.CHANGE'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14.0,
                              color: Theme.of(context).primaryColor)),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                height: 8.0,
              ),
              // Divider(),

              // Divider(),
              GestureDetector(
                onTap: () async {
                  _dialogforProcessing();
                  prefs.setString("ismap","true");
                  prefs.setString("ismapfetch","true");

                  checkLocation();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom:8.0,top:5),
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
                            translate('forconvience.Confirm location & Proceed'),
                            style: TextStyle(
                                color: Colors.white, fontSize: 18.0),
                          ),
                        ],
                      )),
                ),
              ),

            ],
          )),
    );
    // });
  }

  Widget mapWidget() {
    return FutureBuilder(
      future: _mapFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }

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
                      //myLocationButtonEnabled: true,
                      myLocationEnabled: true,
                      onCameraMove: _onCameraMove,
                      padding: (Platform.isAndroid)?EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).size.height/2, right: 0, left: 0) : null,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_lat, _lng),
                        zoom: 15.0,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                      }
                  ),
                  //This is your marker
                  Container(
                    padding: (Platform.isAndroid)?EdgeInsets.only(bottom: 10, top: MediaQuery.of(context).size.height/2, right: 0, left: 0):null,
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.location_pin,color: Colors.redAccent,size: 30,),
                    ),
                  ),
                ])

            ),

          ],
        );
      },
    );
  }


  Future<void> checkLocation() async {
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
      bool _isCartCheck = false;
      if (responseJson['status'].toString() == "yes") {
        prefs.setString('defaultlocation', "true");
        prefs.setString("isdelivering","true");
        if(prefs.getString("branch") == responseJson['branch'].toString()) {
          IConstants.deliverylocationmain.value = addressLine;
          prefs.setString("deliverylocation",addressLine);
          prefs.setString("latitude", _lat.toString());
          prefs.setString("longitude", _lng.toString());
          prefs.setString("branch", responseJson['branch'].toString());
          IConstants.currentdeliverylocation.value = "Available";
          if (prefs.getString("formapscreen") == "addressscreen") {

            final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(ExampleScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': addressLine,
              'latitude': _lat.toString(),
              'longitude': _lng.toString(),
              'branch': responseJson['branch'].toString(),
              'houseNo' : routeArgs['houseNo'],
              'apartment' : routeArgs['apartment'],
              'street' :  routeArgs['street'],
              'landmark' : routeArgs['landmark'],
              'area' : routeArgs['area'],
              'pincode' : routeArgs['pincode'],
            });
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

                    Navigator.of(context)
                        .pushNamed(MobileAuthScreen.routeName,);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                  }
                } else {
                  Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                }
              }
            }
          }
        } else {
          if (prefs.getString("formapscreen") == "addressscreen") {
            final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed(ExampleScreen.routeName, arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': addressLine,
              'latitude': _lat.toString(),
              'longitude': _lng.toString(),
              'branch': responseJson['branch'].toString(),
              'houseNo' : routeArgs['houseNo'],
              'apartment' : routeArgs['apartment'],
              'street' :  routeArgs['street'],
              'landmark' : routeArgs['landmark'],
              'area' : routeArgs['area'],
              'pincode' : routeArgs['pincode'],
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
                      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                    }
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
                  }
                } else if (prefs.getString("formapscreen") == "addressscreen") {
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
      } else {
        prefs.setString("isdelivering","false");
        Navigator.of(context).pop();
        IConstants.currentdeliverylocation.value = "Not Available";
        showInSnackBar();
      }
    } catch (error) {
      throw error;
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
        // IConstants.currentdeliverylocation.value = "Available";
        Navigator.of(context).pop();
        if (prefs.getString("formapscreen") == "" ||
            prefs.getString("formapscreen") == "homescreen") {
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context)
                  .pushNamed(MobileAuthScreen.routeName,);

            } else {
              Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
            }
          } else {
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }
        } else if (prefs.getString("formapscreen") == "addressscreen") {
          //IConstants.currentdeliverylocation.value = "Available";
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
            " "+translate('forconvience.Fellahi is not yet available at your current location!!!'))));
  }
}



