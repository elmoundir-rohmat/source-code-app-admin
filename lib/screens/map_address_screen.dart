import 'dart:async';
import 'dart:convert';
import '../constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart' as loc;
import 'package:http/http.dart' as http;
import '../screens/mobile_authentication.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../providers/addressitems.dart';
import '../screens/addressbook_screen.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/return_screen.dart';
import '../screens/home_screen.dart';
import '../constants/IConstants.dart';

class MapAddressScreen extends StatefulWidget {
  static const routeName = '/map-address-screen';

  @override
  MapAddressScreenState createState() => MapAddressScreenState();
}

class MapAddressScreenState extends State<MapAddressScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController _controller;
  Position position;
  Widget _child;
  double _lat, _lng;
  String _address = "";
  String _fullAddress = "";
  CameraPosition cameraposition;
  var deliverlocation = "";
  SharedPreferences prefs;
  String _latitude = "";
  String _longitude = "";
  String _branch = "";
  Box<Product> productBox;
  var addressitemsData;

  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    _child = SpinKitPulse(
      color: Colors.grey,
      size: 100.0,
    );


    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        deliverlocation = prefs.getString("deliverylocation");
        addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
        mapForAddress();
        debugPrint("locmapinit"+addressitemsData.items.length.toString());
      });

    });

    super.initState();
  }

  void mapForAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("new adreess map"+prefs.getString('newaddress').toString());
    var addresses;
    try {
      addresses = await Geocoder.local.findAddressesFromQuery(
          deliverlocation);
    }
    catch(e){
      addresses = await Geocoder.local.findAddressesFromQuery(
          prefs.getString('deli'));
    }
    var first = addresses.first;

    setState(() {
      _lat = first.coordinates.latitude;
      _lng = first.coordinates.longitude;
    });
    await getAddress(_lat, _lng);
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

  void getAddress(double latitude, double longitude) async {
    loc.Location location = new loc.Location();
    _fullAddress = null;
    placemark =
    await Geolocator().placemarkFromCoordinates(latitude, longitude);
    setState(() {
      if (placemark[0].subLocality.toString() == "") {
        if (placemark[0].locality.toString() == "") {
        } else {
          _address = placemark[0].locality.toString();
        }
      } else {
        _address = placemark[0].subLocality.toString() /*+
           ", " +
            placemark[0].locality.toString()*/;

        //_child = mapWidget();
      }
      if(placemark[0].name.toString().trim() == placemark[0].thoroughfare.toString().trim()) {
        _fullAddress = placemark[0].name.toString().trim();
      } else if(placemark[0].thoroughfare.toString().trim() != ""){
        _fullAddress = placemark[0].name.toString().trim() + ", " + placemark[0].thoroughfare.toString().trim();
      }

      if(_fullAddress.toString().trim() == "null") {
        if(placemark[0].subLocality.toString().trim() != "")
          _fullAddress = placemark[0].subLocality;
      } else {
        if (placemark[0].subLocality.toString().trim() != "")
          _fullAddress = _fullAddress + ", " + placemark[0].subLocality;
      }

      if(placemark[0].locality.toString().trim() != "")
        if(_fullAddress != null) {
          _fullAddress = _fullAddress + ", " + placemark[0].locality;
        } else {
          _fullAddress = placemark[0].locality;
        }

      if(placemark[0].subAdministrativeArea.toString().trim() != "")
        _fullAddress = _fullAddress + ", " + placemark[0].subAdministrativeArea;

      if(placemark[0].administrativeArea.toString().trim() != "")
        _fullAddress = _fullAddress + ", " + placemark[0].administrativeArea;

      if(placemark[0].postalCode.toString().trim() != "")
        _fullAddress = _fullAddress + " " + placemark[0].postalCode;

      _child = mapWidget();
    });
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
                    child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                  ),
                );
              }
          );
        });
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

      if (responseJson['status'].toString() == "yes") {
        /*prefs.setString('deliverylocation', _address);
        prefs.setString("latitude", _lat.toString());
        prefs.setString("longitude", _lng.toString());*/

        _latitude = _lat.toString();
        _longitude = _lng.toString();
        _branch = responseJson['branch'].toString();
        final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
        prefs.setString('newaddress', (routeArgs['address'] + _address + " - " + routeArgs['pincode']));

        location();
      } else {
        Navigator.of(context).pop();
        showInSnackBar();
      }
    } catch (error) {
      throw error;
    }
  }

  location() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   /* final addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
*/
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
                //prefs.setString('prevscreen', "confirmorder");
                Navigator.of(context)
                    .pushNamed(MobileAuthScreen.routeName,);
              }
             /* Navigator.of(context).pushReplacementNamed(
                  ConfirmorderScreen.routeName,
                  arguments: {
                    "prev": "address_screen",
                  }
              );*/
            } else {
              Navigator.of(context).pushReplacementNamed(
                HomeScreen.routeName,
              );
            }
          }
        } else {
          if(productBox.length > 0) {
            if (prefs.getString('mobile').toString()!="null") {
              prefs.setString("isPickup", "no");
              Navigator.of(context).pushReplacementNamed(
                  ConfirmorderScreen.routeName,
                  arguments: {"prev": "cart_screen"});
            }
            else{
              //prefs.setString('prevscreen', "confirmorder");
              Navigator.of(context)
                  .pushNamed(MobileAuthScreen.routeName,);
            }
          /*  Navigator.of(context).pushReplacementNamed(
                ConfirmorderScreen.routeName,
                arguments: {
                  "prev": "address_screen",
                }
            );*/
          } else {
            Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {


    _buildBottomNavigationBar() {
      return SingleChildScrollView(
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
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
                    }
                    else {
                      if(productBox.length > 0) {
                        if (prefs.getString('mobile').toString()!="null") {
                          prefs.setString("isPickup", "no");
                          Navigator.of(context).pushReplacementNamed(
                              ConfirmorderScreen.routeName,
                              arguments: {"prev": "cart_screen"});
                        }
                        else{
                          //prefs.setString('prevscreen', "confirmorder");
                          Navigator.of(context)
                              .pushNamed(MobileAuthScreen.routeName,);
                        }
                       /* Navigator.of(context).pushReplacementNamed(
                            ConfirmorderScreen.routeName,
                            arguments: {
                              "prev": "address_screen",
                            }
                        );*/
                      } else {
                        Navigator.of(context).pushReplacementNamed(
                          HomeScreen.routeName,
                        );
                      }
                    }
                  } else {
                    if(productBox.length > 0) {
                      if (prefs.getString('mobile').toString()!="null") {
                        prefs.setString("isPickup", "no");
                        Navigator.of(context).pushReplacementNamed(
                            ConfirmorderScreen.routeName,
                            arguments: {"prev": "cart_screen"});
                      }
                      else{
                        //prefs.setString('prevscreen', "confirmorder");
                        Navigator.of(context)
                            .pushNamed(MobileAuthScreen.routeName,);
                      }
                     /* Navigator.of(context).pushReplacementNamed(
                          ConfirmorderScreen.routeName,
                          arguments: {
                            "prev": "address_screen",
                          }
                      );*/
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        HomeScreen.routeName,
                      );
                    }
                  }
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  color: Colors.black54,
                  height: 50.0,
                  child: Center(
                    child: Text(
                      'Don\'t know',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _dialogforProcessing();
                  checkLocation();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  color: Theme.of(context).accentColor,
                  height: 50.0,
                  child: Center(
                    child: Text(
                      'Use This Location',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
      );
    }

    return  Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [ColorCodes.whiteColor, ColorCodes.whiteColor]
        ),
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined, color: ColorCodes.blackColor),onPressed: ()=>Navigator.of(context).pop()),
        title: Text(
          "Your delivery address location",
        ),
      ),
      body: _child,
      bottomNavigationBar: _buildBottomNavigationBar(),);
  }

  Widget mapWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: GoogleMap(
            mapType: MapType.normal,
            markers: _createMarker(),
            mapToolbarEnabled: true,
            onCameraIdle: _onCameraIdle,
            onCameraMove: _onCameraMove,
            initialCameraPosition: CameraPosition(
              target: LatLng(_lat, _lng),
              zoom: 16.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
        ),
      ],
    );
  }

  void showInSnackBar() {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(IConstants.APP_NAME +
            " is not yet available at you current location!!!")));
  }
}