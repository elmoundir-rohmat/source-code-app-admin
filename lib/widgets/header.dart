import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fellahi_e/providers/featuredCategory.dart';
import 'package:fellahi_e/screens/items_screen.dart';
import 'package:flutter_facebook_login_web/flutter_facebook_login_web.dart';


import '../screens/mobile_authentication.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_sidebar/flutter_sidebar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/itemslist.dart';
import '../screens/otppopup_screen.dart';
import '../screens/singleproduct_screen.dart';

import '../widgets/app_drawer.dart';

import '../widgets/selling_items.dart';
import '../widgets/footer.dart';
import '../screens/location_screen.dart';
import '../screens/addressbook_screen.dart';
import '../screens/customer_support_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/myorder_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../constants/ColorCodes.dart';
import '../constants/IConstants.dart';
import '../screens/address_screen.dart';
import '../screens/home_screen.dart';
import '../screens/policy_screen.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../utils/ResponsiveLayout.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../providers/notificationitems.dart';
import '../providers/sellingitems.dart';
import '../screens/cart_screen.dart';
import '../screens/category_screen.dart';
import '../screens/map_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/searchitem_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../screens/subcategory_screen.dart';
import '../widgets/badge.dart';
import "package:http/http.dart" as http;
import '../constants/images.dart';
import 'expansion_drawer.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart' as loc;

import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_translate/flutter_translate.dart';



GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class Header extends StatefulWidget {
  bool _isHome=false;
  Header(this._isHome);
  @override
  _HeaderState createState() => _HeaderState();


}

class _HeaderState extends State<Header> {
  final GlobalKey _scaffoldKey = new GlobalKey();
  final _form = GlobalKey<FormState>();
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
  GlobalKey actionKey;
  double height, width, xPosition, yPosition;
  bool isDropdownOpened = false;
  OverlayEntry floatingDropdown;
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController lastnamecontroller = new TextEditingController();

  FocusNode emailfocus = FocusNode();
  FocusNode passwordfocus = FocusNode();
  final TextEditingController emailcontrolleralert = new TextEditingController();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  final TextEditingController otpcontroller = new TextEditingController();
  final TextEditingController newpasscontroller = new TextEditingController();

  MediaQueryData queryData;
  final _lnameFocusNode = FocusNode();
  final _formsignup = GlobalKey<FormState>();
  String fn = "",fn1="",fn2="";
  String ln = "",ln1="",ln2="";
  String ea = "",ea1="",ea2="";
  bool _obscureText = true;
  final TextEditingController namecontroller = new TextEditingController();
  final TextEditingController emailcontrollersignup = new TextEditingController();
  final TextEditingController passwordcontrollersignup = new TextEditingController();
  final _formalert = GlobalKey<FormState>();
  final _formreset = GlobalKey<FormState>();
  final _lnameFocusNodesignup = FocusNode();
  String fnsignup = "";
  String lnsignup = "";
  String easignup = "";
  bool _isWeb = false;
  bool _isShowItem = false;
  bool _isNoItem = false;
  StreamController<int> _events;
  FocusNode _focus = new FocusNode();
  var searchData;
  List searchDispaly = [];
  String searchValue = "";
  bool _isSearchShow = false;

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();

  var _showCall = false;

  var mobilenum = "";

  String otp1, otp2, otp3, otp4;

  var otpvalue = "";

  final _debouncer = Debouncer(milliseconds: 500);


  double _lat, _lng;
  Position position;
  int count = 0;
  Timer timer;
  bool _serviceEnabled = false;
  bool _permissiongrant = false;
  String _mapaddress = "",addressLine="";
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  bool navigatpass = false;
 // bool isMapfetch = false;
  Color textColor = Colors.blue;
  int _enterCounter = 0;
  int _exitCounter = 0;
  double x = 0.0;
  double y = 0.0;
  double wid;
  double maxwid;

  @override
  void initState() {
    //_getdeleverlocation();
    Hive.openBox<Product>(productBoxName);
    _events = new StreamController<int>.broadcast();
    //final StreamController<bool> streamController = StreamController<bool>.broadcast();
    _events.add(30);
    //_timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _getmobilenum();
   //IConstants.deliverylocationmain.value = addressLine;
   /* if( prefs.getBool('defaultlocation').toString()=="null" && prefs.getString("ismap").toString()=="null") {
      getCurrentLocation();

    }*/

//

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      String  defaultloc=prefs.getString('defaultlocation');
      fetchPrimary();

    });
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

    //  fetchPrimary();
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          AppleSignIn.onCredentialRevoked.listen((_) {});
          if (await AppleSignIn.isAvailable()) {
            setState(() {
              _isAvailable = true;
            });
          } else {
            setState(() {
              _isAvailable = false;
            });
          }
        }
      } catch (e) {}


      if(!_isWeb)
        _listenotp();

      prefs = await SharedPreferences.getInstance();



      setState(() {
        setState(() {
          if(prefs.containsKey("LoginStatus")) {
            if(prefs.getString('LoginStatus') == "true") {
              prefs.setString('skip', "no");
              checkSkip = false;
            } else {
              prefs.setString('skip', "yes");
              checkSkip = true;
            }
          } else {
            prefs.setString('skip', "yes");
            checkSkip = true;
          }

          if (prefs.getString('applesignin') == "yes") {
            apple = prefs.getString('apple');
          } else {
            apple = "";
          }
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');
        });

        if (prefs.getString('mobile') != null) {
          phone = prefs.getString('mobile');
        } else {
          phone = "";
        }
        if (prefs.getString('photoUrl') != null) {
          photourl = prefs.getString('photoUrl');
        } else {
          photourl = "";
        }


        if (prefs.getString('skip') == "yes") {
          _isSkip = true;
        } else {
          _isSkip = false;
        }


      //  _getdeleverlocation();
       // _deliverLocation = prefs.getString("deliverylocation");
       // if (!prefs.containsKey("welcomeSheet") && prefs.getString('LoginStatus') != "true" && !_isWeb) welcomeSheet();
        //welcomeSheet();
        if (prefs.getString('skip') == "yes") {
          _isUnreadNot = false;
        } else {
          Provider.of<NotificationItemsList>(context,listen: false)
              .fetchNotificationLogs(prefs.getString('userID'))
              .then((_) {
            final notificationData =
            Provider.of<NotificationItemsList>(context,listen: false);
            if (notificationData.notItems.length <= 0) {
              setState(() {
                _isUnreadNot = false;
              });
            } else {
              if (notificationData
                  .notItems[notificationData.notItems.length - 1]
                  .unreadcount <=
                  0) {
                setState(() {
                  _isUnreadNot = false;
                });
              } else {
                setState(() {
                  _isUnreadNot = true;
                  unreadCount = notificationData
                      .notItems[notificationData.notItems.length - 1]
                      .unreadcount;
                });
              }
            }
          });
        }
      });
    });
    _googleSignIn.signInSilently();
    _focus.addListener(_onFocusChange);
    super.initState();

  }

  void closed() {
    timer?.cancel();
  }



  void _incrementEnter(PointerEvent details) {
    setState(() {
      _enterCounter++;
    });
  }

  void _incrementExit(PointerEvent details) {
    setState(() {
      textColor = Colors.blue;
      _exitCounter++;
    });
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      textColor = Colors.red;
      x = details.position.dx;
      y = details.position.dy;
    });
  }


  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
          prefs.setString("nopermission","no");
          prefs.setString("available", "yes");
          prefs.setString("isdelivering","true");

          /* if (prefs.getString("formapscreen") == "addressscreen") {
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
          }
          else {
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
                    *//*  Navigator.of(context).pushNamedAndRemoveUntil(
                        MapScreen.routeName,
                        ModalRoute.withName(CartScreen.routeName));

                    Navigator.of(context).pushReplacementNamed(
                      CartScreen.routeName,
                    );*//*
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
          }*/
        }
        else {
          /* if (prefs.getString("formapscreen") == "addressscreen") {
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
          }*/
        }
      } else {
        //Navigator.of(context).pop();
        prefs.setString("nopermission","yes");
        prefs.setString("available", "no");
        prefs.setString("isdelivering","false");
        IConstants.currentdeliverylocation.value = "Not Available";
        setState(() {
        //  _deliverLocation=prefs.getString("deliverylocation");
        });


       // showInSnackBar();
      }
    } catch (error) {
      throw error;
    }
  }

  void showInSnackBar() {
    int count=0;
   // HomeScreen.scaffoldKey.currentState.removeCurrentSnackBar();

    HomeScreen.scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(IConstants.APP_NAME +
            " is not yet available at you current location!!!")));
  }

  void getCurrentLocation() async {
    PermissionStatus permission =
    await LocationPermissions().requestPermissions();
    permission = await LocationPermissions().checkPermissionStatus();

    if (permission.toString() == "PermissionStatus.granted") {
      setState(() {
        _permissiongrant = true;


      });
      prefs.setString("nopermission","no");
      checkusergps();
    } else {
      prefs.setString("ismapfetch","true");
      setState(() {
        _permissiongrant = false;
        if (!prefs.containsKey("deliverylocation")) {
          Provider.of<BrandItemsList>(context, listen: false).GetRestaurant().then((_) {
            setState(() {
              prefs.setString("deliverylocation", prefs.getString("restaurant_location"));
              prefs.setString("latitude", prefs.getString("restaurant_lat"));
              prefs.setString("longitude", prefs.getString("restaurant_long"));
              _deliverLocation = prefs.getString("deliverylocation");
              prefs.setString("isdelivering","false");
              IConstants.deliverylocationmain.value = _deliverLocation;
              prefs.setString("nopermission","yes");
            });
          });
        } else {
          setState(() {
            _deliverLocation = prefs.getString("deliverylocation");
            prefs.setString("latitude", _lat.toString());
            prefs.setString("longitude", _lng.toString());
            prefs.setString("isdelivering","false");
            IConstants.deliverylocationmain.value = _deliverLocation;
            prefs.setString("nopermission","yes");
          });

        }
      });

      // checkusergps();
      /*Prediction p = await PlacesAutocomplete.show(
          mode: Mode.overlay, context: context, apiKey: kGoogleApiKey);
      displayPrediction(p);
*/
    }
  }



  Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId);
      setState(() {
        _lat = detail.result.geometry.location.lat;
        _lng = detail.result.geometry.location.lng;
        /* if (_controller == null) {
          _child = mapWidget();
        } else {
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(_lat, _lng), zoom: 16.0),
            ),
          );
          _child = mapWidget();
        }*/
      });
      await getAddress(_lat, _lng);
    }
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
    placemark =
    await Geolocator().placemarkFromCoordinates(latitude, longitude);

    if (placemark[0].subLocality.toString() == "") {
      if (placemark[0].locality.toString() == "") {
        _mapaddress = "";
        addressLine="";
        //_child = mapWidget();
      } else {

        // _address = placemark[0].locality.toString();
        final coordinates = new Coordinates(_lat, _lng);
        var addresses;
        addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
        setState(() {
          var first = addresses.first;

          _mapaddress = (first.featureName!=null)?(first.featureName):first.featureName;
          addressLine=first.addressLine;//(first.subLocality!=null)?(first.subLocality+","+first.locality+","+first.adminArea)
          prefs.setString("default location","true");
          prefs.setString('defaultlocation', "true");


          setState(() {
            _deliverLocation=addressLine;
            prefs.setString("deliverylocation",addressLine);
            prefs.setString("latitude", _lat.toString());
            prefs.setString("longitude", _lng.toString());//prefs.getString("deliverylocation");//
          });

         // prefs.setString("delivery")
         // _deliverLocation=addressLine;
          // :(first.locality+","+first.adminArea);
          checkLocation();


        });

        // _child = mapWidget();
      }
    } else {
      // _address = final coordinates = new Coordinates(_lat, _lng);
      var addresses;
      addresses = await Geocoder.local.findAddressesFromCoordinates(
          new Coordinates(_lat, _lng));
      setState(() {
        var first = addresses.first;

        _mapaddress = (first.featureName!=null)?(first.featureName):first.featureName;
        addressLine=first.addressLine;
        prefs.setString("default location","true");
        prefs.setString('defaultlocation', "true");
        //prefs.setString("deliverylocation",addressLine);
        setState(() {
          _deliverLocation=addressLine;
          prefs.setString("deliverylocation",addressLine);
          prefs.setString("latitude", _lat.toString());
          prefs.setString("longitude", _lng.toString());
          //prefs.getString("deliverylocation");//addressLine;
        });
        checkLocation();

       // prefs.setString("deliverylocation",addressLine);
       // _deliverLocation=addressLine;
        /*  addressLine = (first.subLocality != null) ? (first.subLocality + "," +
              first.locality + "," + first.adminArea)
              : (first.locality + "," + first.adminArea);*/
      });
      // _child = mapWidget();
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
        _deliverLocation=prefs.getString("deliverylocation");
        prefs.setString("latitude", _lat.toString());
        prefs.setString("longitude", _lng.toString());
        IConstants.deliverylocationmain.value = _deliverLocation;
      });

      prefs.setString("nopermission","yes");
      if (Theme.of(context).platform == TargetPlatform.android) {
        setState(() {
          count++;
        });
        if (count == 1)
          location.requestService();
         /* showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                    translate('forconvience.Location unavailable')  //"Location unavailable"
                ),
                content:  Text(
                    translate('forconvience.Please enable location') //'Please enable the location from device settings.'
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () async {
                      setState(() {
                        count = 0;
                      });
                      //await AppSettings.openLocationSettings();
                      location.requestService();
                      Navigator.of(context, rootNavigator: true).pop();
                      //checkusergps();
                    },
                  ),
                ],
              );
            },
          );*/
      }
    } else {
      prefs.setString("nopermission","no");
      Position res = await Geolocator().getCurrentPosition();
      setState(() {
        position = res;
        _lat = position.latitude;
        _lng = position.longitude;
        /* cameraposition = CameraPosition(
          target: LatLng(_lat, _lng),
          zoom: 16.0,
        );*/
        //_child = mapWidget();
      });
      await getAddress(_lat, _lng);
    }
  }
  void _onFocusChange() {
    setState(() {
      if (_focus.hasFocus.toString() == "true") {
        _isShowItem = true;
        _isLoading = false;
      } else {
        _isShowItem = true;
      }
      //drop
      if (isDropdownOpened) {
        floatingDropdown.remove();
      } else {
        floatingDropdown = _searchBar();
        Overlay.of(context).insert(floatingDropdown);
      }
      isDropdownOpened = !isDropdownOpened;
    });
  }
  search(String value) async {
    await Provider.of<ItemsList>(context,listen: false).fetchsearchItems(value).then((_) {
      setState(() {
        searchData = Provider.of<ItemsList>(context,listen: false);

        //searchDispaly = searchData.searchitems.title;
        _isSearchShow = true;
        searchDispaly = searchData.searchitems.toList();
        if (searchDispaly.length <= 0) {
          _isNoItem = true;
        } else {
          _isNoItem = false;
        }
        if (isDropdownOpened) {
          floatingDropdown.remove();
        } else {
          floatingDropdown = _searchBar();
          Overlay.of(context).insert(floatingDropdown);
        }
        isDropdownOpened = !isDropdownOpened;

        /*searchData = Provider.of<ItemsList>(context, listen: false);
        searchDispaly = searchData.searchitems
            .where((elem) =>
            elem.title
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase()))
            .toList();
        _isSearchShow = true;*/
      });
    });
  }
  onSubmit(String value) async {
    //FocusScope.of(context).requestFocus(_focus);
    /*_focus = new FocusNode();
    FocusScope.of(context).requestFocus(_focus);*/
    await Provider.of<ItemsList>(context,listen: false).fetchsearchItems(value).then((_) {
      searchData = Provider.of<ItemsList>(context,listen: false);
      searchDispaly = searchData.searchitems.toList();
      if (searchDispaly.length <= 0) {
        _isNoItem = true;
      } else {
        _isNoItem = false;
      }
      _isShowItem = true;
      _isLoading = false;

      if (isDropdownOpened) {
        floatingDropdown.remove();
      } else {
        floatingDropdown = _searchBar();
        Overlay.of(context).insert(floatingDropdown);
      }
      isDropdownOpened = !isDropdownOpened;
      Navigator.of(context)
          .pushNamed(SearchitemScreen.routeName,arguments: {
        "itemname" : value,
      });
      // floatingDropdown.remove();
    });

  }

  void _startTimer() {

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //setState(() {
      (_timeRemaining > 0) ? _timeRemaining-- : _timer.cancel();
      //});
      _events.add(_timeRemaining);
    });
  }
  void _listenotp() async {
    await SmsAutoFill().listenForCode;
  }

   welcomeSheet() {
   // _getdeleverlocation();
    prefs.setBool("welcomeSheet", true);
    // _deliverLocation = prefs.getString("deliverylocation");
    SingingCharacter _character = SingingCharacter.english;

    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 300,
           // height:300,
            //height: 432,
           // width: double.infinity,
            color: Colors.white,
            padding: EdgeInsets.only(top: 18.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Welcome to '+IConstants.APP_NAME,
                  style: TextStyle(fontSize: 20),
                ),
                Container(
                    padding: EdgeInsets.only(
                        left: 36.0, right: 36.0, bottom: 18.0),
                    child: Divider(
                      thickness: 1.0,
                    )),
                Text(
                    'Product catalogue and offers are location specific'),
                Container(
                  margin: EdgeInsets.only(
                      left: 36.0, top: 8.0, right: 36.0, bottom: 8.0),
                  height: 44.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: Theme.of(context).accentColor,
                    border: Border.all(
                      width: 1.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: RaisedButton(
                    elevation: 0,
                    onPressed: () {
                      prefs.setString("formapscreen", "homescreen");
                      Navigator.of(context)
                          .pushNamed(MapScreen.routeName);
                    },
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'CHOOSE LOCATION',
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text('Existing customer'),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(
                        SignupSelectionScreen.routeName);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                        left: 36.0,
                        top: 8.0,
                        right: 36.0,
                        bottom: 8.0),
                    height: 44.0,
                    width: double.infinity,
                    child: RaisedButton(
                      elevation: 0,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          SignupSelectionScreen.routeName,
                        );
                      },
                      child: Text(
                        'LOGIN',
                        style: TextStyle(color: Color(0x6060609C)),
                      ),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                  ),
                ),

                //                        fetchDelivery();
                // deliverlocation = prefs.getString("deliverylocation");
                GestureDetector(
                  // splashColor: Colors.red,
                  //color: Colors.green,
                  // textColor: Colors.white,
                  child: Text(
                    'Explore $_deliverLocation',
                    style: TextStyle(
                      color: ColorCodes.lightblue,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // setState(() {
                    //   txt='FlatButton tapped';
                    // });
                  },
                ),
                // FlatButton('Explore $_deliverLocation',
                //     style: TextStyle(color: Color(0xFF38559E))),
                SizedBox(height: 20),
              //  Text('Choose your preferred language'),
             /*   Container(
                  width: double.infinity,
                  color: Color(0xffCFDAFF).withOpacity(0.44),
                  margin: EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Container(
                          height: 20,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(child: Text('EN')),
                        ),
                        title: Text('English'),
                        trailing: Radio(
                            value: SingingCharacter.english,
                            groupValue: _character,
                            onChanged: (SingingCharacter value) {
                              setState(() {
                                _character = value;
                              });
                            }),
                      ),
                      ListTile(
                        leading: Container(
                          height: 20,
                          width: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(child: Text('AR')),
                        ),
                        title: Text('عربى'),
                        trailing: Radio(
                            value: SingingCharacter.arabic,
                            groupValue: _character,
                            onChanged: (SingingCharacter value) {
                              setState(() {
                                _character = value;
                              });
                            }),
                      ),
                    ],
                  ),
                ),*/
             /*   Container(
                  height: 40,
                  width: double.infinity,
                  color: Theme.of(context).accentColor,
                  child: Center(
                    child: Container(
                      width: 32.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )*/
              ],
            ),
          ),
            /*  Positioned(
                right: 12,
                bottom: 200,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                            image: AssetImage(Images.cancelImg))),
                  ),
                ),
              )*/
        );
      },
    );
  }

  //for login dropdown
  OverlayEntry _createLoginDropdown() {
    return OverlayEntry(builder: (context) {
      return Container(
        margin: EdgeInsets.only(top: 70),
        child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 220.0,
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: _loginDropdown(),
            )
        ),
      );
      /*return Container(
        margin: EdgeInsets.only(top: 70),
        child: Align(
          alignment: Alignment.centerRight,
          child: Positioned(
            child: Container(
              width: 220.0,
              margin: const EdgeInsets.only(left: 10.0, right: 20.0),
              child: _loginDropdown(),
            ),
          ),
        ),
      );*/
    });
  }
  //for search bar
  OverlayEntry _searchBar(){
    RenderBox renderBox=context.findRenderObject();
    var size =renderBox.size;
    return OverlayEntry(builder:(context){
      return Positioned(
        width:600,
        top:70,
        right: 270,
        child: Container(
          color:Colors.white,
          child:searchList(),
        ),
      );
    });
  }
  Widget searchList(){
    final popularSearch = Provider.of<SellingItemsList>(context,listen: false);
    return Column(
      children: [
        Material(
          elevation:35,
          child: _isLoading?
          Container(
            height: 100,
            child: Center(child:CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
            ))
          ):
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              //height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.all(8.0),
              color: Theme.of(context).backgroundColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_isSearchShow)
                    SizedBox(
                      child: new ListView.builder(
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: searchDispaly.length,
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, i) => Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                floatingDropdown.remove();
                                Navigator.of(context).pushNamed(
                                    SingleproductScreen.routeName,
                                    arguments: {
                                      "itemid" : searchDispaly[i].id.toString(),
                                      "itemname" : searchDispaly[i].title.toString(),
                                      "itemimg" : searchDispaly[i].imageUrl.toString(),
                                    }
                                );
                                _isShowItem = true;
                                _isLoading = true;
                                // FocusScope.of(context)
                                //     .requestFocus(new FocusNode());
                                //onSubmit(searchValue);
                              },
                              child: Container(
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 2.0,
                                        color: Theme.of(context)
                                            .backgroundColor,
                                      ),
                                    )),
                                width: MediaQuery.of(context)
                                    .size
                                    .width,
                                child: Text(
                                  searchDispaly[i].title,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.all(14.0),
                    child: Text("Popular Searches"),
                  ),
                  SizedBox(
                    child: new ListView.builder(
                      shrinkWrap: true,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: popularSearch.items.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (_, i) => Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              floatingDropdown.remove();
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid" : popularSearch.items[i].id.toString(),
                                    "itemname" : popularSearch.items[i].title.toString(),
                                    "itemimg" : popularSearch.items[i].imageUrl.toString(),
                                  }
                              );
                              _isShowItem = true;
                              _isLoading = true;
                              FocusScope.of(context)
                                  .requestFocus(new FocusNode());
                              onSubmit(
                                  popularSearch.items[i].title);
                            },
                            child: Container(
                              padding: EdgeInsets.all(14.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 2.0,
                                      color: Theme.of(context)
                                          .backgroundColor,
                                    ),
                                  )),
                              width:
                              MediaQuery.of(context).size.width,
                              child: Text(
                                popularSearch.items[i].title,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
  // after login dropdown
  OverlayEntry _createFloatingDropdown() {
    return OverlayEntry(builder: (context) {
      return Container(
        margin: EdgeInsets.only(top: 70),
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 220.0,
            // color:ColorCodes.whiteColor,
            margin: const EdgeInsets.only(left: 10.0, right: 20.0),
            child: _dropdown(),
          ),
        ),
      );
    });
  }
  _getmobilenum() async {
    prefs = await SharedPreferences.getInstance();
    mobilenum = prefs.getString("Mobilenum");
  }


  void _getTime() {
    setState(() {
      _timeRemaining == 0 ? _timeRemaining = 0 : _timeRemaining--;
      _events.add(_timeRemaining);
    });

  }
  void onTapDown(BuildContext context, TapDownDetails details) {
    setState(() {
      floatingDropdown.remove();
    });
  }


  @override
  Widget build(BuildContext context) {

 //   _getdeleverlocation();
    return GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      child: Container(
        color: Colors.white,
        child:
        ResponsiveLayout.isSmallScreen(context)
            ?
          createHeaderForMobile()
            : createHeaderForWeb(),
      ),
    );
  }

  addFirstnameToSF(String value) async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FirstName', value);
  }

  addLastnameToSF(String value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('LastName', value);
  }


  addEmailToSF(String value) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
  }


  _saveForm() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    _dialogforProcessing();
    LoginUser();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }

  Future<void> LoginUser() async {

    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'useremail-login';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": prefs.getString('Email'),
        "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      /* if(responseJson['data'].toString()=="Wrong Email!!!"){
        Fluttertoast.showToast(msg: "Wrong email id or password.",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        Navigator.of(context).pop(true);
      }*/
      if (responseJson['status'].toString() == "200") {
        final data = responseJson['data'] as Map<String, dynamic>;
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['userID'].toString());
        prefs.setString('FirstName', data['name'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('deliverylocation', data['area'].toString());
        IConstants.deliverylocationmain.value=data['area'].toString();
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



        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('Name', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }

//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*  Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/
        prefs.setString('skip', "no");
        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);

      } else if (responseJson['status'].toString() == "400") {
        if(responseJson['data'].toString()=="Wrong Email!!!"){
         /* Fluttertoast.showToast(msg: translate('forconvience.invalid email'),//"Wrong email id or password.",
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
        //r  Navigator.of(context).pop();
          Navigator.of(context).pop();

          _customToast(translate('forconvience.invalid email'));

        }
        else if(responseJson['data'].toString()=="Wrong Password!!!"){
          /*Fluttertoast.showToast(msg: translate('forconvience.invalid password'),//"Wrong email id or password.",
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
         // Navigator.of(context).pop();
          Navigator.of(context).pop();
          _customToast(translate('forconvience.invalid password'));

        }
        else {
          //Fluttertoast.showToast(msg: responseJson['data']);
          Navigator.of(context).pop();
          _customToast(responseJson['data']);

        }

      }
      /*else if (responseJson['status'].toString() == "400") {
        Navigator.of(context).pop(true);

      }*/
    } catch (error) {
      //  Navigator.of(context).pop(true);
      throw error;
    }

  }

  Future<void> checkemail() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-check';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "email": prefs.getString('Email'),
          }
      );
      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
         /* Fluttertoast.showToast(msg: translate('forconvience.Email id already exists!!!') //"Email id already exists!!!"
          );*/

         return _customToast(translate('forconvience.Email id already exists!!!'));
         Navigator.of(context).pop(true);
         // Navigator.of(context).pop(true);
         // _dialogforSignIn();
         // Navigator.of(context).pop();
          /*return  _dialogforSignIn();*/
          /* Navigator.of(context).pushReplacementNamed(
              SignupSelectionScreen.routeName);*/
        } else if (responseJson['type'].toString() == "new") {
          return SignupUser();
        }
      } else {
        Navigator.of(context).pop();
       return _customToast("Something went wrong!!!");
       // return Fluttertoast.showToast(msg: "Something went wrong!!!");

      }

    } catch (error) {
      throw error;
    }
  }
  /*Future<void> checkemail() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-check';
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": prefs.getString('Email'),
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        //return SignupUser();
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
      throw error;
    }
  }*/
  addMobilenumToSF(String value) async {
    prefs.setString('Mobilenum', value);
  }

  /*_saveForm() async {

    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    Provider.of<BrandItemsList>(context,listen: false).LoginUser();
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    _dialogforOtp();

  }*/

  Future<void> checkMobilenum() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/mobile-check';
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          return Fluttertoast.showToast(msg: "Mobile number already exists!!!");
        } else if (responseJson['type'].toString() == "new") {
          Provider.of<BrandItemsList>(context,listen: false).LoginUser();
          Navigator.of(context).pop();
          return _dialogforOtp;
        }
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> _handleSignIn() async {
    prefs.setString('skip', "no");
    prefs.setString('applesignin', "no");
    try {
      final response = await _googleSignIn.signIn();
      response.email.toString();
      response.displayName.toString();
      response.photoUrl.toString();

      prefs.setString('FirstName', response.displayName.toString());
      prefs.setString('LastName', "");
      prefs.setString('Email', response.email.toString());
      prefs.setString("photoUrl", response.photoUrl.toString());

      prefs.setString('prevscreen', "signingoogle");
      checkusertype("Googlesigin");
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Sign in failed!",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
  }

  void initiateFacebookLogin() async {
    final facebookSignIn = FacebookLoginWeb();
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
   // final FacebookLoginResult result = await facebookSignIn.logIn(['email']);
    // final facebookLogin = FacebookLogin();
    // facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    // final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.error:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Sign in failed!",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
           // msg: "Sign in cancelled by user!",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:

        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
        final profile = json.decode(graphResponse.body);

        prefs.setString("FBAccessToken", token);

        prefs.setString('FirstName', profile['first_name'].toString());
        prefs.setString('LastName', profile['last_name'].toString());
        prefs.setString('Email', profile['email'].toString());

        final pictureencode = json.encode(profile['picture']);
        final picturedecode = json.decode(pictureencode);

        final dataencode = json.encode(picturedecode['data']);
        final datadecode = json.decode(dataencode);

        prefs.setString("photoUrl", datadecode['url'].toString());

        prefs.setString('prevscreen', "signinfacebook");
        checkusertype("Facebooksigin");
        //onLoginStatusChanged(true);
        break;
    }
  }

  Future<void> appleLogIn() async {
    prefs.setString('applesignin', "yes");
    _dialogforProcessing();
    prefs.setString('skip', "no");
    if (await AppleSignIn.isAvailable()) {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          var url = IConstants.API_PATH + 'customer/email-login';
          try {
            final response = await http.post(url, body: {
              // await keyword is used to wait to this operation is complete.
              "email": result.credential.user.toString(),
              "tokenId": prefs.getString('tokenid'),
            });
            final responseJson = json.decode(utf8.decode(response.bodyBytes));
            if (responseJson['type'].toString() == "old") {
              if (responseJson['data'] != "null") {
                final data = responseJson['data'] as Map<String, dynamic>;

                if (responseJson['status'].toString() == "true") {
                  prefs.setString('apiKey', data['apiKey'].toString());
                  prefs.setString('userID', data['userID'].toString());
                  prefs.setString('membership', data['membership'].toString());
                  prefs.setString("mobile", data['mobile'].toString());
                  prefs.setString("latitude", data['latitude'].toString());
                  prefs.setString("longitude", data['longitude'].toString());

                  prefs.setString('name', data['name'].toString());
                  prefs.setString('FirstName', data['name'].toString());
                  prefs.setString('FirstName', data['username'].toString());
                  prefs.setString('LastName', "");
                  prefs.setString('Email', data['email'].toString());
                  prefs.setString("photoUrl", "");
                  prefs.setString('apple', data['apple'].toString());
                } else if (responseJson['status'].toString() == "false") {}
              }
              prefs.setString('LoginStatus', "true");
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

                //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
                  photourl = prefs.getString('photoUrl');
                } else {
                  photourl = "";
                }
              });
              _getprimarylocation();
            } else {
              prefs.setString('apple', result.credential.user.toString());
              prefs.setString(
                  'FirstName', result.credential.fullName?.givenName);
              prefs.setString(
                  'LastName', result.credential.fullName?.familyName);
              prefs.setString("photoUrl", "");

              if (result.credential.email.toString() == "null") {
                prefs.setString('prevscreen', "signInAppleNoEmail");
                Navigator.of(context).pop();
                /*Navigator.of(context).pushReplacementNamed(
                  LoginScreen.routeName,);*/
              } else {
                prefs.setString('Email', result.credential.email);
                prefs.setString('prevscreen', "signInApple");
                checkusertype("signInApple");
              }
            }
          } catch (error) {
            Navigator.of(context).pop();
            throw error;
          }

          break;
        case AuthorizationStatus.error:
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              msg: "Sign in failed!",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          break;
        case AuthorizationStatus.cancelled:
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              //msg: "Sign in cancelled by user!",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          break;
      }
    } else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Apple SignIn is not available for your device!",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
  }

  Future<void> checkusertype(String prev) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-login';
    try {
      var response;
      if (prev == "signInApple") {
        response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
          "apple": prefs.getString('apple'),
        });
      } else {
        response = await http.post(url, body: {
          // await
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
        });
      }

      final responseJson = json.decode(response.body);
      if (responseJson['type'].toString() == "old") {
        if (responseJson['data'] != "null") {
          final data = responseJson['data'] as Map<String, dynamic>;

          if (responseJson['status'].toString() == "true") {
            prefs.setString('apiKey', data['apiKey'].toString());
            prefs.setString('userID', data['userID'].toString());
            prefs.setString('membership', data['membership'].toString());
            prefs.setString("mobile", data['mobile'].toString());
            prefs.setString("latitude", data['latitude'].toString());
            prefs.setString("longitude", data['longitude'].toString());
          } else if (responseJson['status'].toString() == "false") {}
        }

        prefs.setString('LoginStatus', "true");
        prefs.setString('LoginStatus', "true");
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        /* Navigator.of(context).pop();
        Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/
        SignupUser();
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  /*Future<void> checkusertype(String prev) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-login';
    try {
      var response;
      if (prev == "signInApple") {
        response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
          "apple": prefs.getString('apple'),
        });
      } else {
        response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
        });
      }

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['type'].toString() == "old") {
        if (responseJson['data'] != "null") {
          final data = responseJson['data'] as Map<String, dynamic>;

          if (responseJson['status'].toString() == "true") {
            prefs.setString('apiKey', data['apiKey'].toString());
            prefs.setString('userID', data['userID'].toString());
            prefs.setString('membership', data['membership'].toString());
            prefs.setString("mobile", data['mobile'].toString());
            prefs.setString("latitude", data['latitude'].toString());
            prefs.setString("longitude", data['longitude'].toString());
          } else if (responseJson['status'].toString() == "false") {}
        }

        prefs.setString('LoginStatus', "true");
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        Navigator.of(context).pop();

        *//* Navigator.of(context).pushReplacementNamed(
          LoginScreen.routeName,
        );*//*
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }*/

  Future<void> _getprimarylocation() async {
    var url = IConstants.API_PATH + 'customer/get-profile';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);
      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list
      for (int i = 0; i < data.length; i++) {
        prefs.setString("deliverylocation", data[i]['area']);

        if (prefs.containsKey("deliverylocation")) {
          Navigator.of(context).pop();
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  CartScreen.routeName,
                  ModalRoute.withName(HomeScreen.routeName));
            } else {
              Navigator.of(context).popUntil(ModalRoute.withName(
                HomeScreen.routeName,
              ));
            }
          } else {

            Navigator.of(context).pushNamed(
              HomeScreen.routeName,
            );
          }
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
        }
      }
      //Navigator.of(context).pop();
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  Future<void> facebooklogin() {
    prefs.setString('skip', "no");
    prefs.setString('applesignin', "no");
    initiateFacebookLogin();
  }

  _verifyOtp() async {
    //var otpval = otp1 + otp2 + otp3 + otp4;


    //SharedPreferences prefs = await SharedPreferences.getInstance();


    if (controller.text == prefs.getString('Otp')) {
      setState(() {
        _isLoading = true;
      });

      if (prefs.getString('type') == "old") {
        prefs.setString('LoginStatus', "true");
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      }
      else {

        if (prefs.getString('prevscreen') == 'signingoogle' ||
            prefs.getString('prevscreen') == 'signupselectionscreen' ||
            prefs.getString('prevscreen') == 'signInAppleNoEmail' ||
            prefs.getString('prevscreen') == 'signInApple' ||
            prefs.getString('prevscreen') == 'signinfacebook') {
          return signupUser();

        } else {
          prefs.setString('prevscreen', "otpconfirmscreen");
          await Future.delayed(Duration(seconds: 2));
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          _dialogforAddInfo();
        }
      }
    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      _customToast("Please enter valid Otp");
    }
  }

  Future<void> Otpin30sec() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-30';
    try {
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> otpCall() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-call';
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }



  Future<void> SignupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/password-register';

    String channel = "";
    try {
      if (Platform.isIOS) {
        channel = "IOS";
      } else {
        channel = "Android";
      }
    } catch (e) {
      channel = "Web";
    }

    try {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String apple = "";
      if (prefs.getString('applesignin') == "yes") {
        apple = prefs.getString('apple');
      } else {
        apple = "";
      }

      String name =
      prefs.getString('FirstName') ;

     //  var resBody = {};
     //  resBody["device"] = channel.toString();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username":  prefs.getString('FirstName'),
        "email": prefs.getString('Email'),
        "mobileNumber": "",
        "path": apple,
        "tokenId": prefs.getString('tokenid'),
        "guestUserId" : prefs.getString('guestuserId'),
        "branch": prefs.getString('branch'),
        "password" :  prefs.getString('Password') ,
        "device": channel.toString(),
      });

      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));
        prefs.setString("skip", "no");
        prefs.setString('LoginStatus', "true");

        //Navigator.of(context).pop();
        // if(prefs.getString("latitude").toString()!="null"||prefs.getString("longitude").toString()!="null") {
       // prefs.setString('LoginStatus', "true");
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        if (prefs.getString("ismap").toString() == "true") {

          addprimarylocation();
        } else if (prefs.getString("isdelivering").toString() == "true") {
          // Navigator.of(context).pop();
          addprimarylocation();
        } else {
          Navigator.of(context).pop();
          prefs.setString("formapscreen", "homescreen");
          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
          /* Navigator.of(context).pushReplacementNamed(
              LocationScreen.routeName,
            );*/
        }
        /*}
        else{
          Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,
          );
        }*/


        /*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*/

      } else if (responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
        _customToast(responseJson['data'].toString());
        Fluttertoast.showToast(
            msg: responseJson['data'].toString(),
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      setState(() {});
      throw error;
    }
  }


  Future<void> addprimarylocation() async {
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


    var url = IConstants.API_PATH + 'add-primary-location';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString("userID"),
        "latitude": prefs.getString("latitude"),
        "longitude":prefs.getString("longitude"),
        "area": IConstants.deliverylocationmain.value.toString(),
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(response.body);
      if (responseJson["data"].toString() == "true") {
        if(prefs.getString("ismap").toString()=="true") {
          if(prefs.getString("fromcart").toString()=="cart_screen"){
            // Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamed(MobileAuthScreen.routeName,);

          }
          else{
            /* Navigator.of(context).pop();
            return Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,
            );*/

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
                photourl = prefs.getString('photoUrl');
              } else {
                photourl = "";
              }
            });
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }


        }
        else if(prefs.getString("isdelivering").toString()=="true"){
          //if(prefs.getString("nopermission").toString()!="null"){
          /*if(prefs.getString("isdelivering").toString()=="true"){*/

          /*Navigator.of(context).pushReplacementNamed(
            HomeScreen.routeName,
          );*/
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
              photourl = prefs.getString('photoUrl');
            } else {
              photourl = "";
            }
          });
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);


        }
        else {
          prefs.setString("formapscreen", "homescreen");
          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
          /*Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,
          );*/
        }
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  /*Future<void> SignupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/register';
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      String apple = "";
      if (prefs.getString('applesignin') == "yes") {
        apple = prefs.getString('apple');
      } else {
        apple = "";
      }

      String name =
          prefs.getString('FirstName') + " " + prefs.getString('LastName');

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": prefs.getString('Email'),
        "mobileNumber": prefs.getString('Mobilenum'),
        "path": apple,
        "tokenId": prefs.getString('tokenid'),
        "branch": prefs.getString('branch'),
        "signature" : prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));

        prefs.setString('LoginStatus', "true");
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        Navigator.of(context).pop();

        return Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );

        *//*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*//*

      } else if (responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: responseJson['data'].toString(),
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      setState(() {});
      throw error;
    }
  }*/

  _saveAddInfoForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //checkemail();
    _dialogforProcessing();
    SignupUser();
  }
  _ForgotPassword() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _formalert.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formalert.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    Navigator.of(context).pop(true);
    _dialogforProcessing();
    Forgotpass();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }
  _ResetPassword() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _formreset.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formreset.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    _dialogforProcessing();
    Resetpass();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }

  Future<void> Resetpass() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'reset-password';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id":prefs.getString('userID'),
        "password": newpasscontroller.text,//prefs.getString('Password'),
        /* "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,*/
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      // final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == "200") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        //Navigator.pop(context);
       /* Fluttertoast.showToast(msg: responseJson['data'].toString(),
            backgroundColor: Colors.black87,
            textColor: Colors.white);*/
        _customToast(responseJson['data'].toString());
        // Navigator.pop(context);
        //Navigator.of(context).pop();
        // Navigator.of(context).pop();
        /*
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('Otp', responseJson['otp'].toString());
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['id'].toString());
        prefs.setString('FirstName', data['username'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('LoginStatus', "true");
        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('Name', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }
       */

        //Navigator.of(context).pop();
        // _resetpass();
        // Navigator.of(context).pop();
        //_dialogresetforForgotpass();
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/


      } else if (responseJson['status'].toString() == "400") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        _customToast("Something Went Wrong !!");
       /* Fluttertoast.showToast(msg: "Something Went Wrong !!",
            backgroundColor: Colors.black87,
            textColor: Colors.white);*/
        // Navigator.pop(context);
      }
    } catch (error) {
      Navigator.of(context).pop(true);
      throw error;
    }
  }

  Future<void> Forgotpass() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'forgot-password';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": emailcontrolleralert.text,//prefs.getString('Email'),
        /* "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,*/
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == "200") {
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('Otp', responseJson['otp'].toString());
        //  prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['id'].toString());
        /* prefs.setString('FirstName', data['username'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('LoginStatus', "true");
        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('Name', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }*/
        Navigator.of(context).pop();
        //Navigator.of(context).pop();
        //Navigator.of(context).pop();
        _resetpass();
        // Navigator.of(context).pop();
        //_dialogresetforForgotpass();
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/


      } else if (responseJson['status'].toString() == "400") {}
    } catch (error) {
      // Navigator.of(context).pop();

      throw error;
    }
  }

  _resetpass()
  {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                //  height: 350.0,
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?350:350,//MediaQuery.of(context).size.width / 3.3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/4:MediaQuery.of(context).size.width / 2.7,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:20.0,top: 10,bottom: 10),
                            child: Text(
                              translate('forconvience.Password Reset'),
                              //' Password Reset',
                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap:(){
                                Navigator.pop(context);
                              }
                              ,child: Icon(Icons.close)),
                          SizedBox(width: 5,),
                          //Image.asset(Images.phoneImg),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 10.0,
                      ),
/*
                    Padding(
                      padding: const EdgeInsets.only(left:20.0),
                      child: Text('Enter your email address',style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),*/
                      Form(
                          key: _formreset,
                          child:
                          Column(
                            children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.2,
                                height: 50,
                                margin:  EdgeInsets.only(
                                    left: 20.0, top: 8, right: 20.0, bottom: 8),
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                ),
                                child:
                                TextFormField(
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.number,
                                  //controller: emailcontrolleralert,
                                  /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColor,
                                  // keyboardType: TextInputType.emailAddress,
                                  //autofocus: true,

                                  decoration: new InputDecoration(
                                    //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                      hintText: translate('forconvience.Enter OTP'),//'Enter Otp',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                      )


                                  ),

                                  validator: (value) {
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    String otp=prefs.getString('Otp');
                                    if (value.isEmpty) {
                                      return  translate('forconvience.Please enter OTP');//'Please enter Otp.';//translate('forconvience.Please enter Email Address');//'Please enter Email Address.';

                                    } else if (value!=otp) {
                                      /*Fluttertoast.showToast(msg: "Please enter valid Otp.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);*/
                                      return  translate('forconvience.Please enter valid Otp');//'Please enter valid Otp.';
                                    }
                                    return null;
                                  },
                                  //it means user entered a valid input

                                  /* onSaved: (value) {
                                    addEmailToSF(value);
                                  },*/
                                ),
                              ),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.2,
                                height: 50,
                                margin:  EdgeInsets.only(
                                    left: 20.0, top: 8, right: 20.0, bottom: 8),
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                ),
                                child:
                                TextFormField(
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.left,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: newpasscontroller,
                                  /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColor,
                                  // keyboardType: TextInputType.emailAddress,
                                  //autofocus: true,

                                  decoration: new InputDecoration(
                                    //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                      hintText: translate('forconvience.New Password'),//'New Password',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                      )


                                  ),

                                  validator: (value) {
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return  translate('forconvience.Please enter New Password');//'Please enter New Password.';//translate('forconvience.Please enter Email Address');//'Please enter Email Address.';

                                    }
                                    /*  if (value.isEmpty) {
                                      // return 'Please enter Email Address.';

                                      Fluttertoast.showToast(msg: "Please enter New Password.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    }*/ /*else if (!regExp.hasMatch(value)) {
                                Fluttertoast.showToast(msg: "Please enter valid Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                                // return 'Please enter valid Email Address';
                              }*/
                                    return null;
                                  },
                                  //it means user entered a valid input

                                  /* onSaved: (value) {
                                    addPasswordToSF(value);
                                  },*/
                                ),
                              ),

                            ],
                          )


                      ),

                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () {
                          //  _enabled ? _onTap:
                          // clikform();
                          //   _dialogforProcessing();
                          setState(() {
                            _isLoading = true;
                            count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          // Navigator.of(context).pop();
                          _ResetPassword();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 40,
                          padding: EdgeInsets.all(5.0),
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 5, right: 20.0, bottom: 5),
                          decoration: BoxDecoration(
                              color: ColorCodes.darkgreen,
                              border: Border.all(
                                color: ColorCodes.darkgreen,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                    color: ColorCodes.greenColor,
                  ),
                ),*/
                          child: Center(
                            child: Text(
                              translate('forconvience.Reset Password'), // "Reset Password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }


  Future<void> signupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/register';

    try {
      String channel = "";
      try {
        if (Platform.isIOS) {
          channel = "IOS";
        } else {
          channel = "Android";
        }
      } catch (e) {
        channel = "Web";
      }
      //  SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": email,
        "mobileNumber": mobile,
        "path": apple,
        "tokenId": tokenid,
        "device":channel.toString(),
        "signature":
        prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;

      if (responseJson['status'].toString() == "true") {
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());

        prefs.setString('LoginStatus', "true");
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

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
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
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });

        return Navigator.of(context).pushNamedAndRemoveUntil(
            MapScreen.routeName, ModalRoute.withName('/'));
      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  _customToast(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
          );



        });
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
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            );
          });
        });
  }
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  _saveFormsignup() async {
    final isValid = _formsignup.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formsignup.currentState.save();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //checkemail();
    _dialogforProcessing();
    checkemail();



    //  Login();
    setState(() {
      _isLoading = false;
    });
    //SignupUser();
    // LoginEmail();
  }


  _dialogforSignUp() {

    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3.3,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.7,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          translate('forconvience.Sign Up'),//"SignUp",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                          Form(
                            key: _formsignup,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                /*Text(
                      '* What should we call you?',
                      style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                    ),
                    SizedBox(height: 10),*/
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: namecontroller,
                                  decoration: InputDecoration(
                                    hintText: translate('forconvience.Name'),//'Name',
                                    prefixIcon: Icon(Icons.person_outline, size: 20,),
                                    hoverColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fnsignup = "  "+translate('forconvience.please enter name');//"  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fnsignup = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fnsignup,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red,fontSize: 12),
                                ),
                                SizedBox(height: 10.0),
                                /* Text(
                      'Tell us your e-mail',
                      style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),*/
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailcontrollersignup,
                                  /*style: new TextStyle(
                          decorationColor: Theme.of(context).primaryColor),*/
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined, size: 20,),
                                    hintText: translate('forconvience.Email') ,//'Email',
                                    fillColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Email Address'); //'Please enter Email Address.';
                                    } else if (!regExp.hasMatch(value)) {
                                      return translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';
                                    }
                                    return null;
                                  },
                                  /* if (value.isEmpty) {
                          setState(() {
                            fn1 = "  Please Enter Email";
                          });
                          return '';
                        }
                        else if (value == "")
                          emailValid = true;
                        else
                          emailValid = RegExp(
                                  )
                              .hasMatch(value);

                        if (!emailValid) {
                          setState(() {
                            ea1 = ' Please enter a valid email address';
                          });
                          return '';
                        }
                        setState(() {
                          ea2 = "";
                        });
                        return null; //it means user entered a valid input
                      },*/
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                SizedBox(height: 20.0),

                                TextFormField(
                                  controller: passwordcontrollersignup,
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.text,
                                  obscureText: _obscureText,
                                  style: new TextStyle(
                                    //  decorationColor: Theme.of(context).primaryColor
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline, size: 20,),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _toggle();
                                      },
                                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                    ),
                                    hintText: translate('forconvience.Password') , //'Password',
                                    fillColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Password');//'Please enter Password.';
                                    }
                                    return null;
                                    /* if (value.isEmpty) {
                          setState(() {
                            fn2 = "  Please Enter Name";
                          });
                          return '';
                        }
                        setState(() {
                          fn2 = "";
                        });
                        return null;*/
                                  },
                                  onSaved: (value) {
                                    addPasswordToSF(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                         /* Form(
                            key: _form,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  '* '+ translate('forconvience.What should we call you ?'),
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: firstnamecontroller,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    hoverColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fn = "  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fn = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fn,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Tell us your e-mail',
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  style: new TextStyle(
                                      decorationColor: Theme.of(context).primaryColor),
                                  decoration: InputDecoration(
                                    hintText: 'xyz@gmail.com',
                                    fillColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    if (value == "")
                                      emailValid = true;
                                    else
                                      emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value);

                                    if (!emailValid) {
                                      setState(() {
                                        ea = ' Please enter a valid email address';
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      ea = "";
                                    });
                                    return null; //it means user entered a valid input
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ea,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' We\'ll email you as a reservation confirmation.',
                                  style: TextStyle(fontSize: 15.2, color: Color(0xFF929292)),
                                ),
                              ],
                            ),
                          ),*/
                        ),
                        //  Spacer(),



/*            GestureDetector(
              onTap: () {
                _saveForm();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: Color(0xFF2966A2),
                child: Center(
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )*/
                      ],
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {


                          setState(() {
                            _isLoading = true;
                            count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              :
                          /*prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");*/
                          _saveFormsignup();
                          //_saveAddInfoForm();
                          //_saveFormsignup();
                         // _dialogforProcessing();

                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          height: 60.0,
                          child: Center(
                            child: Text(
                              translate('forconvience.CONTINUE'),// "CONTINUE",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ),
                ]),
              ),
            );
          });
        });
  }
  _dialogforAddInfo() {

    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3.3,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.7,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Add your info",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                    '* '+ translate('forconvience.What should we call you ?'),
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: firstnamecontroller,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    hoverColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fn = "  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fn = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fn,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Tell us your e-mail',
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  style: new TextStyle(
                                      decorationColor: Theme.of(context).primaryColor),
                                  decoration: InputDecoration(
                                    hintText: 'xyz@gmail.com',
                                    fillColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    if (value == "")
                                      emailValid = true;
                                    else
                                      emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value);

                                    if (!emailValid) {
                                      setState(() {
                                        ea = ' Please enter a valid email address';
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      ea = "";
                                    });
                                    return null; //it means user entered a valid input
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ea,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' We\'ll email you as a reservation confirmation.',
                                  style: TextStyle(fontSize: 15.2, color: Color(0xFF929292)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //  Spacer(),



/*            GestureDetector(
              onTap: () {
                _saveForm();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: Color(0xFF2966A2),
                child: Center(
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )*/
                      ],
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _saveAddInfoForm();
                          _dialogforProcessing();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          height: 60.0,
                          child: Center(
                            child: Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ),
                ]),
              ),
            );
          });
        });
  }

 /* addEmailToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
  }*/
  addPasswordToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Password', value);
  }
  _dialogforForgotpass() {
    /*return  showDialog(
       context: context,
       builder: (context) {
         return StatefulBuilder(builder: (context, setState) {
           return WillPopScope(
             onWillPop: () {
               return Future.value(true);
             },
             child:Column(
               children: [
                 Row(
                   children: [
                     Text('Forgot Password'),
                     Spacer(),
                     Icon(Icons.close),

                     //Image.asset(Images.phoneImg),
                   ],
                 ),

                 Text('Enter your email address'),

                 Container(
                   width: MediaQuery
                       .of(context)
                       .size
                       .width / 1.2,
                   height: 45,
                   margin: EdgeInsets.only(bottom: 8.0),
                   padding: EdgeInsets.only(
                       left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4.0),
                     border: Border.all(width: 0.5, color: Colors.grey),
                   ),
                   child: TextFormField(
                     style: TextStyle(fontSize: 16.0),
                     textAlign: TextAlign.left,
                     inputFormatters: [
                       LengthLimitingTextInputFormatter(12)
                     ],

                     cursorColor: Theme
                         .of(context)
                         .primaryColor,
                     keyboardType: TextInputType.number,
                     //autofocus: true,

                     decoration: new InputDecoration(
                       //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                         border: InputBorder.none,
                         focusedBorder: InputBorder.none,
                         enabledBorder: InputBorder.none,
                         errorBorder: InputBorder.none,
                         disabledBorder: InputBorder.none,
                         // prefixIcon: Icon(Icons.person_outline, size: 20,),
                         hintText: 'Email',
                         hintStyle: TextStyle(
                           color: Colors.black,
                         )


                     ),

                     validator: (value) {
                       String patttern = r'(^(?:[+0]9)?[0-9]{6,10}$)';
                       RegExp regExp = new RegExp(patttern);
                       if (value.isEmpty) {
                         return 'Please enter a Mobile number.';
                       } else if (!regExp.hasMatch(value)) {
                         return 'Please enter valid mobile number';
                       }
                       return null;
                     },
                     //it means user entered a valid input

                     onSaved: (value) {
                       addMobilenumToSF(value);
                     },
                   ),
                 ),

               ],
             ),


           );
         });



       });*/
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                 // height: 240.0,
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?240:240,//MediaQuery.of(context).size.width / 3.3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/4:MediaQuery.of(context).size.width / 2.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:20.0,top: 10,bottom: 10),
                            child: Text( translate('forconvience.Forgot password?') ,//'Forgot Password',
                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap:(){
                                Navigator.pop(context);
                              }
                              ,child: Icon(Icons.close,color: ColorCodes.closebtncolor,)),
                          SizedBox(width: 5,),
                          //Image.asset(Images.phoneImg),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 10.0,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left:20.0),
                        child: Text( translate('forconvience.Email') ,//'Enter your email address',
                          style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Form(
                        key: _formalert,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 50,
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 8, right: 20.0, bottom: 8),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(width: 0.5, color: Colors.grey),
                          ),
                          child:
                          TextFormField(
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailcontrolleralert,
                            /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                            cursorColor: Theme
                                .of(context)
                                .primaryColor,
                            // keyboardType: TextInputType.emailAddress,
                            //autofocus: true,

                            decoration: new InputDecoration(
                              //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                hintText: translate('forconvience.Email') ,//'Email address',
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                )


                            ),

                            validator: (value) {
                              RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                              if (value.isEmpty) {
                                //Navigator.of(context).pop(true);
                                navigatpass = false;
                                return translate('forconvience.Please enter Email Address') ;//'Please enter Email Address.';
                                Fluttertoast.showToast(msg: "Please enter Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                              } else if (!regExp.hasMatch(value)) {
                                navigatpass = false;
                                Fluttertoast.showToast(msg: translate('forconvience.Please enter valid Email Address'),//"Please enter valid Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                                Navigator.of(context).pop(true);
                                return  translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';

                              }else{
                                navigatpass = true;
                              }

                              return null;
                            },
                            //it means user entered a valid input

                            /* onSaved: (value) {
                              addEmailToSF(value);
                            },*/
                          ),
                        ),
                      ),

                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () {
                          //  _enabled ? _onTap:
                          // clikform();
                          //   _dialogforProcessing();
                          setState(() {
                            if(navigatpass)
                              _isLoading = true;
                            count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          //  Navigator.of(context).pop();
                          _ForgotPassword();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 40,
                          padding: EdgeInsets.all(5.0),
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 5, right: 20.0, bottom: 5),
                          decoration: BoxDecoration(
                              color: ColorCodes.darkgreen,
                              border: Border.all(
                                color: ColorCodes.darkgreen,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                    color: ColorCodes.greenColor,
                  ),
                ),*/
                          child: Center(
                            child: Text(
                              translate('forconvience.SEND') , // "SEND",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforSignIn() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 2,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 3.0,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          translate('forconvience.Sign in') ,//"Sign in",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Column(
                    children: [
                      Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20,),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/80,horizontal: 30),
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 5,
                                shadowColor: Colors.grey,
                                child:

                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: emailcontroller,
                                  focusNode: emailfocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.go,
                                  decoration: InputDecoration(
                                    hintText:translate('forconvience.Email') ,//'Email',
                                    prefixIcon: Icon(Icons.person_outline, size: 20,),
                                    hoverColor: Colors.green,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (_) {
                                    emailfocus.unfocus();
                                    FocusScope.of(context).requestFocus(passwordfocus);
                                  },
                                  validator: (value) {
                                    String reg=r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    bool emailValid;
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Email Address') ;//'Please enter Email Address.';
                                    } else if (!regExp.hasMatch(value)) {
                                      Fluttertoast.showToast(msg: translate('forconvience.Please enter valid Email Address'),//"Please enter valid Email Address.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                      setState(() {
                                        _isLoading =false;
                                      });
                                      return translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/170,horizontal: 30),
                              child: Material(

                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 5,

                                shadowColor: Colors.grey,
                                child: TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: passwordcontroller,
                                  focusNode: passwordfocus,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText:translate('forconvience.Password') , //'Password',
                                    prefixIcon: Icon(Icons.lock_outline, size: 20,),
                                    hoverColor: Colors.green,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (_) {
                                    passwordfocus.unfocus();
                                    //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {

                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Password') ; //'Please enter Password.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addPasswordToSF(value);
                                  },
                                ),
                              ),
                            ),

                          ],
                        ),


                      ),
                      GestureDetector(
                        onTap:(){
                         _dialogforForgotpass();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 30.0,
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/130, bottom: MediaQuery.of(context).size.height/80,right:30),

                          child: Text(
                            translate('forconvience.Forgot password?') ,
                            //"Forgot Password?",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //  _enabled ? _onTap:
                          // clikform();
                          //   _dialogforProcessing();
                          setState(() {
                            _isLoading = true;
                            count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          _saveForm();
                        },
                        child:
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 2,
                          height: 50,
                          margin:EdgeInsets.symmetric(horizontal:30.0),
                          padding: EdgeInsets.all(5.0),

                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),

                          child: Center(
                            child: Text(
                              translate('forconvience.Sign in') ,// "SIGN IN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/20,left: 28.0,right:28,bottom:MediaQuery.of(context).size.height/20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color(
                                  0xff707070,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(4.0),
                              width: 23.0,
                              height: 23.0,
                              /* decoration: BoxDecoration(
                                  border: Border.all(
                                   // color: Color(0xff707070),
                                  ),
                                  shape: BoxShape.circle,
                                ),*/
                              child: Center(
                                  child: Text(
                                    translate('forconvience.OR') , //"OR",
                                    style:
                                    TextStyle(fontSize: 11.0, color: Color(0xff727272)),
                                  )),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color(
                                  0xff707070,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 28),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                             _dialogforProcessing();
                              _handleSignIn();
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: Container(

                                  padding: EdgeInsets.only(
                                      left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.only(right:23.0,left:23,),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          SvgPicture.asset(Images.googleImg, width: 25, height: 25,),
                                          //Image.asset(Images.googleImg,width: 20,height: 40,),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Text(
                                            translate('forconvience.Sign in with google') , //"Sign in with Google",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: ColorCodes.signincolor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/70, horizontal: 28),
                            child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _dialogforProcessing();
                                facebooklogin();
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10.0,  right: 5.0, top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),

                                    // border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
                                  ),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.only(right:23.0,left: 23),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          SvgPicture.asset(Images.facebookImg, width: 25, height: 25,),
                                          //Image.asset(Images.facebookImg,width: 20,height: 40,),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Text(
                                            translate('forconvience.Sign in with Facebook') ,// "Sign in with Facebook",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: ColorCodes.signincolor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isAvailable)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 28),
                              child: GestureDetector(
                                onTap: () {
                                  appleLogIn();
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(4.0),
                                  elevation: 2,
                                  shadowColor: Colors.grey,
                                  child: Container(

                                    padding: EdgeInsets.only(
                                        left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),),
                                    child:
                                    Padding(
                                      padding: const EdgeInsets.only(right:23.0,left:23,),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SvgPicture.asset(Images.appleImg, width: 25, height: 25,),
                                            //Image.asset(Images.appleImg, width: 20,height: 40,),
                                            SizedBox(
                                              width: 14,
                                            ),
                                            Text(
                                              translate('forconvience.Sign in with Apple')  , //"Sign in with Apple",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorCodes.signincolor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // if (_isAvailable)
                          //     Container(
                          //       margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/700, horizontal: 28),
                          //       child: GestureDetector(
                          //         onTap: () {
                          //           appleLogIn();
                          //         },
                          //         child: Material(
                          //           borderRadius: BorderRadius.circular(4.0),
                          //           elevation: 3,
                          //
                          //           shadowColor: Colors.grey,
                          //           child: Container(
                          //             padding: EdgeInsets.only(
                          //                 left: 10.0,  right: 5.0, top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                          //             decoration: BoxDecoration(
                          //               borderRadius: BorderRadius.circular(4.0),),
                          //             child:
                          //             Padding(
                          //               padding: const EdgeInsets.only(right:23.0,left: 23),
                          //               child: Center(
                          //                 child: Row(
                          //                   mainAxisAlignment: MainAxisAlignment.start,
                          //                   children: <Widget>[
                          //                     Image.asset(Images.appleImg),
                          //                     SizedBox(
                          //                       width: 14,
                          //                     ),
                          //                     Text(
                          //                       "Se connecter avec Apple",
                          //                       textAlign: TextAlign.center,
                          //                       style: TextStyle(fontSize: 16,
                          //                           fontWeight: FontWeight.bold,
                          //                           color: ColorCodes.signincolor),
                          //                     )
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                        ],
                      ),
                      Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/120),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal:28,
                                //vertical: MediaQuery.of(context).size.height/120
                              ),
                              child: new RichText(
                                textAlign: TextAlign.left,
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(text:" "+ translate('forconvience.Not a member yet?' ) ,//' Not a member yet? ',
                                        style: TextStyle(color: ColorCodes.signincolor,
                                            fontWeight:FontWeight.bold,fontSize: 16)),
                                    new TextSpan(
                                        text: " "+translate('forconvience.Signup now') ,//' Signup now',
                                        style: new TextStyle(color: Theme.of(context).primaryColor,fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                          Navigator.of(context).pop();
                                         // _dialogforSignIn();
                                          _dialogforSignUp();
                                         // _dialogforAddInfo();
                                            /*Navigator.of(context)
                                                .pushNamed(SignupScreen.routeName);*/
                                          }),
                                  ],
                                ),
                              ),
                            ),
                            // Spacer(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(28, MediaQuery.of(context).size.height/22, 28, MediaQuery.of(context).size.height/170),
                                child:

                                new RichText(textAlign: TextAlign.center,
                                  text: new TextSpan(

                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(text:" "+translate('forconvience.By continuing you agree to') ), //' By continuing you agree to '),
                                      new TextSpan(
                                          text: " "+translate('forconvience.Terms signup'),//' Terms and Conditions',
                                          style: new TextStyle(color: ColorCodes.darkgreen),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context)
                                                  .pushNamed(PolicyScreen.routeName, arguments: {
                                                'title': translate('forconvience.Terms and conditions'),//"Terms of Use",
                                                'body': prefs.getString("restaurant_terms"),
                                              });
                                            }),
                                      new TextSpan(text:" "+translate('forconvience.and to') //' and to'
                                      ),
                                      new TextSpan(
                                          text: " "+translate('forconvience.privacy signup'),//' Privacy Policy',
                                          style: new TextStyle(color: ColorCodes.darkgreen),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context)
                                                  .pushNamed(PolicyScreen.routeName, arguments: {
                                                'title': translate('forconvience.privacy signup'),//"Privacy",
                                                'body': prefs.getString("privacy"),
                                              });
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),),
                    ],
                  )
               /*   Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52,
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Images.countryImg,
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Country/Region",
                                      style: TextStyle(
                                        color: Color(0xff808080),
                                      )),
                                  Text(countryName + " (" + countrycode + ")",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52.0,
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Image.asset(Images.phoneImg),
                              SizedBox(
                                width: 14,
                              ),
                              Container(
                                  width:
                                  MediaQuery.of(context).size.width / 4.0,
                                  child: Form(
                                    key: _form,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.left,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12)
                                      ],
                                      cursorColor:
                                      Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: new InputDecoration.collapsed(
                                          hintText: 'Enter Your Mobile Number',
                                          hintStyle: TextStyle(
                                            color: Colors.black12,
                                          )),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter a Mobile number.';
                                        }
                                        return null; //it means user entered a valid input
                                      },
                                      onSaved: (value) {
                                        addMobilenumToSF(value);
                                      },
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 8.0, bottom: 36.0),
                          child: Text(
                            "We'll call or text you to confirm your number. Standard message data rates apply.",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff3B3B3B)),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              prefs.setString('skip', "no");
                              prefs.setString('prevscreen', "mobilenumber");
                              // prefs.setString('Mobilenum', value);

                              _saveForm();
                              _dialogforProcessing();

                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 32,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  width: 1.0,
                                  color: ColorCodes.greenColor,
                                ),
                              ),
                              child: Text(
                                "LOGIN USING OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    color: Color(0xff070707)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 12.0, bottom: 32.0),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: 'By continuing you agree to the '),
                                new TextSpan(
                                    text: ' terms of service',
                                    style:
                                    new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Terms of Use",
                                              'body': prefs.getString(
                                                  "restaurant_terms"),
                                            });
                                      }),
                                new TextSpan(text: ' and'),
                                new TextSpan(
                                    text: ' Privacy Policy',
                                    style:
                                    new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Privacy",
                                              'body':
                                              prefs.getString("privacy"),
                                            });
                                      }),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                              Container(
                                //padding: EdgeInsets.all(4.0),
                                width: 23.0,
                                height: 23.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff707070),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                          fontSize: 10.0, color: Color(0xff727272)),
                                    )),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 44,
                          width: MediaQuery.of(context).size.width / 1.2,
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5,
                                color: Color(0xff4B4B4B).withOpacity(1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    _handleSignIn();
                                  },
                                  child: SvgPicture.asset(Images.googleImg, *//*width: 20,height: 30,*//*),),
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    facebooklogin();
                                  },
                                  child: SvgPicture.asset(Images.facebookImg, *//*width: 20,height: 30,*//*),),
                              if (_isAvailable)
                                GestureDetector(
                                    onTap: () {
                                      appleLogIn();
                                    },
                                    child: SvgPicture.asset(Images.appleImg, *//*width: 20,height: 30,*//*),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ]),
              ),
            );
          });
        });
  }

  _dialogforOtp () async{

    return alertOtp(context);
  }


  void alertOtp(BuildContext ctx) {
    mobile=prefs.getString("Mobilenum");
    var alert = AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        content: StreamBuilder<int>(
            stream: _events.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return
                Container(
                    height:(_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3,
                    width:(_isWeb && ResponsiveLayout.isSmallScreen(context)) ?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.5,
                    child:
                    Column(children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        padding: EdgeInsets.only(left: 20.0),
                        color: ColorCodes.lightGreyWebColor,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Signup using OTP",
                              style: TextStyle(
                                  color: ColorCodes.mediumBlackColor,
                                  fontSize: 20.0),
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child:

                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 25.0),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Please check OTP sent to your mobile number',
                                  style: TextStyle(
                                      color: Color(0xFF404040),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.0),

                                  // textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(width: 20.0),
                                  Text(
                                    countrycode + '  $mobile',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        fontSize: 16.0),
                                  ),
                                  SizedBox(width: 30.0),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      _dialogforSignIn();

                                    },
                                    child: Container(
                                      height: 35,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Color(0x707070B8), width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text('Change',
                                              style: TextStyle(
                                                  color: Color(0xFF070707), fontSize: 13))),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  'Enter OTP',
                                  style: TextStyle(color: Color(0xFF727272), fontSize: 14),
                                  //textAlign: TextAlign.left,
                                ),
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                                // Auto Sms
                                Container(
                                    height: 40,
                                    //width: MediaQuery.of(context).size.width*80/100,
                                    width:(_isWeb && ResponsiveLayout.isSmallScreen(context)) ?MediaQuery.of(context).size.width/2:MediaQuery.of(context).size.width / 3,
                                    //padding: EdgeInsets.zero,
                                    child: PinFieldAutoFill(
                                        controller: controller,
                                        decoration: UnderlineDecoration(
                                            colorBuilder:
                                            FixedColorBuilder(Color(0xFF707070))),
                                        onCodeChanged: (text){
                                          otpvalue = text;
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) => setState(() {}));
                                        },
                                        onCodeSubmitted: (text) {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) => setState(() {
                                            otpvalue = text;
                                          }));
                                        },
                                        codeLength: 4,
                                        currentCode: otpvalue
                                    )),
                              ]),
                              SizedBox(
                                height: 20,
                              ),
                              _showOtp
                                  ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*50/100:MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Color(0xFF6D6D6D),
                                              width: 1.5),
                                        ),
                                        child:
                                        Center(child: Text('Resend OTP')),
                                      ),
                                    ),
                                    Container(
                                      height: 28,
                                      width: 28,
                                      margin: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text(
                                            'OR',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                    ),
                                    _timeRemaining == 0
                                        ?
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        behavior:
                                        HitTestBehavior.translucent,
                                        onTap: () {
                                          otpCall();
                                          _timeRemaining = 60;
                                        },
                                        child: Expanded(
                                          child: Container(
                                            height: 40,
                                            //width: MediaQuery.of(context).size.width*32/100,
                                            decoration: BoxDecoration(

                                              borderRadius:
                                              BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.green,
                                                  width: 1.5),
                                            ),

                                            child: Center(
                                                child: Text('Call me Instead')),
                                          ),
                                        ),
                                      ),
                                    )
                                        : Expanded(
                                      child: Container(
                                        height: 40,
                                        //width: MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Color(0xFF6D6D6D),
                                              width: 1.5),
                                        ),
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              children: <TextSpan>[
                                                new TextSpan(
                                                    text: 'Call in',
                                                    style: TextStyle(
                                                        color: Colors.black)),
                                                new TextSpan(text: ' 00:$_timeRemaining',
                                                  style: TextStyle(
                                                    color: Color(
                                                        0xffdbdbdb),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ])
                                  : Row(
                                mainAxisAlignment:

                                MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  _timeRemaining == 0
                                      ? MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        //  _showCall = true;
                                        _showOtp = true;
                                        _timeRemaining += 30;
                                        Otpin30sec();
                                      },
                                      child: Expanded(
                                        child: Container(
                                          height: 40,
                                          width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*30/100:MediaQuery.of(context).size.width*15/100,
                                          //width: MediaQuery.of(context).size.width*32/100,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.green, width: 1.5),
                                          ),
                                          child: Center(
                                              child: Text('Resend OTP')),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Expanded(
                                    child: Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*40/100,
                                      decoration: BoxDecoration(
                                        borderRadius:BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Color(0x707070B8),
                                            width: 1.5),
                                      ),
                                      child: Center(
                                        child: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: 'Resend Otp in',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              new TextSpan(
                                                text: ' 00:$_timeRemaining',
                                                style: TextStyle(
                                                  color: Color(0xffdbdbdb),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 28,
                                    width: 28,
                                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),

                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(
                                          'OR',
                                          style: TextStyle(fontSize: 10),
                                        )),
                                  ),

                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius:BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text('Call me Instead')),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),

                      /* Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 40.0),
                          Center(
                              child: Text(
                            'Please check OTP sent to your mobile number',
                            style: TextStyle(
                                color: Color(0xFF404040),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )),
                          SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[

                              SizedBox(width: 20.0),
                              Text(
                                countrycode + '  $mobile',
                                style: new TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontSize: 18.0),
                              ),
                              SizedBox(width: 40.0),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    _dialogforSignIn();

                                  },
                                  child: Container(
                                    height: 35,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Color(0x707070B8), width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text('Change',
                                            style: TextStyle(
                                                color: Color(0xFF070707)))),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25.0),
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text('Enter OTP',
                                style: TextStyle(
                                    color: Color(0xFF727272), fontSize: 18)),
                          ),
                          Row(children: [
                            SizedBox(
                              width: 30,
                            ),
                            // Auto Sms
                            Container(
                                height: 40,
                                //width: MediaQuery.of(context).size.width*80/100,
                                width: MediaQuery.of(context).size.width / 3.5,
                                //padding: EdgeInsets.zero,
                                child: PinFieldAutoFill(
                                  controller: controller,
                                  decoration: UnderlineDecoration(
                                      colorBuilder:
                                          FixedColorBuilder(Color(0xFF707070))),
                                  onCodeChanged: (text){
                                    otpvalue = text;
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) => setState(() {}));
                                  },
                                  onCodeSubmitted: (text) {
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) => setState(() {
                                      otpvalue = text;
                                    }));
                                  },
                                  codeLength: 4,
                                    currentCode: otpvalue
                                ))
                          ]),
                          SizedBox(
                            height: 25,
                          ),

                       //   GrocBay new Resend OTP buttons

                          _showOtp
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*50/100:MediaQuery.of(context).size.width*32/100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Color(0xFF6D6D6D),
                                                width: 1.5),
                                          ),
                                          child:
                                              Center(child: Text('Resend OTP')),
                                        ),
                                      ),
                                      Container(
                                        height: 28,
                                        width: 28,
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Color(0xFF6D6D6D),
                                              width: 1.5),
                                        ),
                                        child: Center(
                                            child: Text(
                                          'OR',
                                          style: TextStyle(fontSize: 10),
                                        )),
                                      ),
                                      _timeRemaining == 0
                                          ? MouseRegion(
                                              cursor: SystemMouseCursors.click,
                                              child: GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  otpCall();
                                                  _timeRemaining = 60;
                                                },
                                                child: Expanded(
                                                  child: Container(
                                                    height: 40,
                                                    //width: MediaQuery.of(context).size.width*32/100,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: Colors.green,
                                                          width: 1.5),
                                                    ),
                                                    child: Center(
                                                        child: Text(
                                                            'Call me Instead')),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Expanded(
                                              child: Container(
                                                height: 40,
                                                //width: MediaQuery.of(context).size.width*32/100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: Color(0xFF6D6D6D),
                                                      width: 1.5),
                                                ),
                                                child: Center(
                                                  child: RichText(
                                                    text: TextSpan(
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text: 'Call in',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                        new TextSpan(
                                                          text:
                                                              ' 00:$_timeRemaining',
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xffdbdbdb),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                    ])
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _timeRemaining == 0
                                        ? MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              behavior:
                                                  HitTestBehavior.translucent,
                                              onTap: () {
                                                // _showCall = true;
                                                _showOtp = true;
                                                _timeRemaining += 30;
                                                Otpin30sec();
                                              },
                                              child: Expanded(
                                                child: Container(
                                                  height: 40,
                                                   width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*30/100:MediaQuery.of(context).size.width*15/100,
                                                  //width: MediaQuery.of(context).size.width*32/100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: Colors.green,
                                                        width: 1.5),
                                                  ),
                                                  child: Center(
                                                      child:
                                                          Text('Resend OTP')),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            child: Container(
                                              height: 40,
                                              //width: MediaQuery.of(context).size.width*40/100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: Color(0x707070B8),
                                                    width: 1.5),
                                              ),
                                              child: Center(
                                                child: RichText(
                                                  text: TextSpan(
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                          text: 'Resend Otp in',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black)),
                                                      new TextSpan(
                                                        text:
                                                            ' 00:$_timeRemaining',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xffdbdbdb),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                    Container(
                                      height: 28,
                                      width: 28,
                                      margin: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child: Text(
                                        'OR',
                                        style: TextStyle(fontSize: 10),
                                      )),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        //width: MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Color(0xFF6D6D6D),
                                              width: 1.5),
                                        ),
                                        child: Center(
                                            child: Text('Call me Instead')),
                                      ),
                                    ),
                                  ],
                                ),
                         // This expands the row element vertically because it's inside a column


                        ]),*/


                      Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _verifyOtp();
                              _dialogforProcessing();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  )),
                              height: 60.0,
                              child: Center(
                                child: Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).buttonColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ])
                );
            }));
    _startTimer();
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return alert;
        });
  }

  Widget _loginDropdown() {
    return Column(
      children: <Widget>[
        //SizedBox(height: 5),
        Material(
          elevation: 1,
          child: Container(
            margin: EdgeInsets.only(top: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                //SizedBox(height: 10),
                MouseRegion (
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      floatingDropdown.remove();
                      _dialogforSignIn();
                    },
                    child: Container(
                      height: 40,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                          child: Text(
                              translate('forconvience.Sign in') +"/"+"Sign Up" ,  //'Login/ Sign Up',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,//ColorCodes.whiteColor,
                                  fontSize: 16))),
                    ),
                  ),
                ),
               // SizedBox(height: 5),
               /* FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                   *//* Navigator.of(context)
                        .pushReplacementNamed(CustomerSupportScreen.routeName);*//*
                  },
                  child: _DropDownItem(Icons.headset,
                    translate('appdrawer.customer support'), //"Customer Support"
                  ),
                ),*/
                //SizedBox(height: 5),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _dropdown() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Material(
          elevation: 35,
          // shape: ArrowShape(),
          child: Container(
            //height: 4 * itemHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: <Widget>[
                SizedBox(height: 5),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    if (photourl != null)
                      CircleAvatar(
                        radius: 24.0,
                        backgroundColor: Color(0xffD3D3D3),
                        backgroundImage: NetworkImage(photourl),
                      ),
                    if (photourl == null)
                      CircleAvatar(
                        radius: 24.0,
                        backgroundColor: Color(0xffD3D3D3),
                      ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            style: TextStyle(
                                color: Color(0xff535353), fontSize: 18.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            '$phone',
                            /*overflow: TextOverflow.ellipsis,*/ style: TextStyle(
                              color: Color(0xff535353), fontSize: 14.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context)
                        .pushReplacementNamed(MyorderScreen.routeName);
                  },
                  child: _DropDownItem(Icons.note, translate('appdrawer.myorders'),//"My Orders"
                  ),
                ),
              /*  FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context)
                        .pushReplacementNamed(ShoppinglistScreen.routeName);
                  },
                  child: _DropDownItem(Icons.list, "Shopping list"),
                ),*/
                FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context)
                        .pushReplacementNamed(AddressbookScreen.routeName);
                  },
                  child: _DropDownItem(Icons.library_books,
                    translate('appdrawer.addressBook'),// "Address book"
                  ),
                ),
               /* FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context)
                        .pushReplacementNamed(MembershipScreen.routeName);
                  },
                  child: _DropDownItem(Icons.star, "Membership"),
                ),*/
                /*FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context)
                        .pushReplacementNamed(WalletScreen.routeName, arguments: {'type': "loyalty"});
                  },
                  child: _DropDownItem(Icons.wallet_membership, "Wallet"),
                ),
                FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                    Navigator.of(context).pushNamed(WalletScreen.routeName,
                        arguments: {'type': "loyalty"});
                  },
                  child: _DropDownItem(Icons.library_books, "Loyalty"),
                ),*/
               /* FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () {
                    floatingDropdown.remove();
                   *//* Navigator.of(context)
                        .pushReplacementNamed(CustomerSupportScreen.routeName);*//*
                  },
                  child: _DropDownItem(Icons.headset, translate('appdrawer.customer support'),//"Customer Support"
                  ),
                ),*/
                FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () async {
                    floatingDropdown.remove();
                   prefs.remove('LoginStatus');
                    try {
                      // prefs.remove('LoginStatus');
                      if (prefs.getString('prevscreen') == 'signingoogle') {
                        prefs.setString("photoUrl", "");
                        await _googleSignIn.signOut();
                      } else if (prefs.getString('prevscreen') == 'signinfacebook') {
                        prefs.getString("FBAccessToken");
                        //var facebookSignIn = FacebookLogin();
                        var facebookSignIn = FacebookLoginWeb();
                        final graphResponse = await http.delete(
                            'https://graph.facebook.com/v2.12/me/permissions/?access_token=${prefs.getString("FBAccessToken")}&httpMethod=DELETE&ref=logout&destroy=true');
                        prefs.setString("photoUrl", "");
                        await facebookSignIn.logOut().then((value) {
                        });
                      }
                    } catch (e) {
                    }
                    String countryCode =prefs.getString("country_code");
                    String branch =prefs.getString("branch");
                    String _tokenId =prefs.getString("tokenid");
                    prefs.clear();
                    prefs.setBool('introduction', true);
                     prefs.setString('country_code', countryCode);
                   prefs.setString("branch", branch);
                    prefs.setString('skip', "yes");
                 prefs.setString('tokenid', _tokenId);
                    //_dialogforSignIn();
                    /*Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));*/
                    Navigator.pushNamedAndRemoveUntil(
                        context, HomeScreen.routeName, (route) => false);

                    setState(() {
                      checkSkip = true;
                    });
                  },
                  child: _DropDownItem(Icons.exit_to_app,  translate('appdrawer.logout'),//"Logout"
                  ),
                ),

                /* FlatButton(
                  hoverColor: Color(0xffCCE6FF),
                  onPressed: () async {
                    floatingDropdown.remove();
                    prefs.remove('LoginStatus');
                    try {
                      if (Platform.isIOS || Platform.isAndroid) {
                        // prefs.remove('LoginStatus');
                        if (prefs.getString('prevscreen') == 'signingoogle') {
                          prefs.setString("photoUrl", "");
                          await _googleSignIn.signOut();
                          String countryCode = prefs.getString("country_code");
                          prefs.clear();
                          prefs.setBool('introduction', true);
                          prefs.setString('country_code', countryCode);
                          Navigator.of(context).pushReplacementNamed(
                            SignupSelectionScreen.routeName,
                          );
                        } else if (prefs.getString('prevscreen') ==
                            'signinfacebook') {
                          prefs.getString("FBAccessToken");
                          var facebookSignIn = FacebookLogin();

                          final graphResponse = await http.delete(
                              'https://graph.facebook.com/v2.12/me/permissions/?access_token=${prefs.getString("FBAccessToken")}&httpMethod=DELETE&ref=logout&destroy=true');

                          prefs.setString("photoUrl", "");
                          await facebookSignIn.logOut().then((value) {
                            String countryCode =
                            prefs.getString("country_code");
                            prefs.clear();
                            prefs.setBool('introduction', true);
                            prefs.setString('country_code', countryCode);

                            Navigator.of(context).pushReplacementNamed(
                              SignupSelectionScreen.routeName,
                            );
                          });
                        } else {
                          String countryCode = prefs.getString("country_code");
                          prefs.clear();
                          prefs.setBool('introduction', true);
                          prefs.setString('country_code', countryCode);
                          Navigator.of(context).pushReplacementNamed(
                            HomeScreen.routeName,
                          );
                        }
                      }
                    } catch (e) {
                      String countryCode = prefs.getString("country_code");
                      String branch = prefs.getString("branch");
                      prefs.clear();
                      prefs.setBool('introduction', true);
                      prefs.setString('country_code', countryCode);
                      prefs.setString("branch", branch);
                      prefs.setString('skip', "yes");
                      prefs.setString('LoginStatus', "true");
                      //_dialogforSignIn();
                      Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                    }
                  },
                  child: _DropDownItem(Icons.exit_to_app, "Logout"),
                ),*/
              ],
            ),
          ),
        )
      ],
    );
  }







  createHeaderForWeb() {
    /*queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.95;*/
    final brandsData = Provider.of<BrandItemsList>(context,listen: false);
    final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    final discountitemData = Provider.of<SellingItemsList>(context,listen: false);
    final subcategoryData = Provider.of<FeaturedCategoryList>(context, listen: false);
    _deliverLocation = prefs.getString("deliverylocation");
    if (brandsData.items.length > 0 ||
        sellingitemData.items.length > 0 ||
        categoriesData.items.length > 0 ||
        discountitemData.itemsdiscount.length > 0 || subcategoryData.catTwoitems.length > 0) {
      _isDelivering = true;
    } else {
      _isDelivering = false;
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.topRight,
              colors: [
                ColorCodes.whiteColor,
                ColorCodes.whiteColor
                // Theme.of(context).primaryColor,
                // Theme.of(context).accentColor
              ],
            ),
          ),




          width: MediaQuery.of(context).size.width,
          height: 60.0,
          child: Row(
            children: [
             /* SizedBox(
                width: 10.0,
              ),*/
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap:() {
                    if(!widget._isHome)Navigator.pushNamedAndRemoveUntil(
                        context, HomeScreen.routeName, (route) => false);
                  },
                  child: Image.asset(
                    Images.logoAppbarImg,
                    width: 150,
                    //color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              /*Container(
                height: 60.0,
                child: VerticalDivider(
                  color: Color(0xff707070),
                  thickness: 1.5,
                ),
              ),*/


              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                     prefs.setString("formapscreen", "homescreen");
                      Navigator.of(context).pushNamed(MapScreen.routeName);
                      floatingDropdown.remove();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.location_on_outlined,
                          color:Theme.of(context).primaryColor //ColorCodes.whiteColor,
                        ),
                        SizedBox(
                          width: 14.0,
                        ),
                        Expanded(
                          child: Text(
                            _deliverLocation,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style:
                            TextStyle(color: ColorCodes.greyColor,//Colors.white,
                                fontSize: 17.0),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: ColorCodes.greyColor,//Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        if (isDropdownOpened) {
                          floatingDropdown.remove();
                        } else {
                          floatingDropdown = _searchBar();
                          Overlay.of(context).insert(floatingDropdown);
                        }
                        isDropdownOpened = !isDropdownOpened;
                      });
                    },
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: ColorCodes.searchwebColor,
                        borderRadius: BorderRadius.circular(6),
                       // border: Border.all(color: ColorCodes.searchwebColor),

                          /*border:Border.all(width: 0.0,
                              //style: BorderStyle.solid,
                          color: ColorCodes.greyColor,)*/
                      ),
                      child: Center(

                        child: TextField(
                            autofocus: false,
                            focusNode: _focus,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              // fillColor: Colors.white,
                              //border: InputBorder.none,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorCodes.searchwebColor, width: 0.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: ColorCodes.searchwebColor, width: 0.0),
                              ),
                              contentPadding: EdgeInsets.only(top:13,left:20,right:10),
                              hintText: translate('header.search'),//'Search for Products ',
                              hintStyle: TextStyle(
                                color: ColorCodes.greyColor,//Colors.black,
                              ),
                              suffixIcon:
                              Icon(Icons.search, color: Colors.black),
                              focusColor: Colors.white,
                              fillColor: Colors.white,
                              filled: (_focus.hasFocus.toString() == "true")
                                  ? true
                                  : false,
                            ),
                            onSubmitted: (value) {
                              searchValue = value;
                              _isShowItem = true;
                              _isLoading = true;
                              onSubmit(value);
                              _focus.requestFocus();
                            },
                            onChanged: (String newVal) {
                              setState(() {
                                searchValue = newVal;

                                if (newVal.length == 0) {
                                  _isSearchShow = false;
                                } else if (newVal.length == 2) {
                                  //Provider.of<ItemsList>(context).fetchsearchItems(newVal);
                                  _debouncer.run(() {
                                    search(newVal);
                                    _focus.requestFocus();
                                  });
                                } else if (newVal.length >= 3) {
                                  _debouncer.run(() {
                                    search(newVal);
                                    //  onSubmit(newVal);
                                    _focus.requestFocus();
                                    //perform search here
                                  });

                                  /*searchDispaly = searchData.searchitems
                                                    .where((elem) =>
                                                    elem.title
                                                        .toString()
                                                        .toLowerCase()
                                                        .contains(newVal.toLowerCase()))
                                                    .toList();
                                                _isSearchShow = true;*/
                                }
                              });
                            }),
                      ),
                      // child: Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 10.0,
                      //     ),
                      //     Expanded(
                      //       child: Text(
                      //         'Search from 10,000+ Products',
                      //         overflow: TextOverflow.ellipsis,
                      //         maxLines: 1,
                      //         style: TextStyle(
                      //           color: Color(0xffBFBFBF),
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ),
                      //     Icon(
                      //       Icons.search,
                      //       color: Color(0xffBBBBBB),
                      //       size: 24.0,
                      //     ),
                      //     SizedBox(
                      //       width: 5.0,
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 26.0,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName,
                        arguments: {"prev": "home_screen"});
                    floatingDropdown.remove();
                  },
                  child: Container(
                    //width: 132.0,
                    height: 50.0,
                    /*decoration: BoxDecoration(
                      color: Color(0xff008149),
                      borderRadius: BorderRadius.circular(4.0),
                    ),*/
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                          Hive.box<Product>(productBoxName).listenable(),
                          builder: (context, Box<Product> box, index) {
                            if (box.values.isEmpty)
                              return Image.asset(
                                Images.cartImg,
                                color: Theme.of(context).primaryColor,//Colors.white,
                                width: 24,
                                height: 24,
                              );

                            int cartCount = 0;
                            for (int i = 0;
                            i < Hive.box<Product>(productBoxName).length;
                            i++) {
                              cartCount = cartCount +
                                  Hive.box<Product>(productBoxName)
                                      .values
                                      .elementAt(i)
                                      .itemQty;
                            }
                            return Consumer<Calculations>(
                              builder: (_, cart, ch) => Badge(
                                child: ch,
                                value: cartCount.toString(),
                              ),
                              child: Image.asset(
                                Images.cartImg,
                                color: Theme.of(context).primaryColor,//Colors.white,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        // Text(
                        //   'Cart',
                        //   style: TextStyle(
                        //     color: Theme.of(context).primaryColor,//Colors.white,
                        //     fontSize: 17,
                        //   ),
                        // ),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 26.0,
              ),
              checkSkip
                  ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (isDropdownOpened) {
                      isDropdownOpened = !isDropdownOpened;
                      floatingDropdown.remove();
                    } else {
                      floatingDropdown = _createLoginDropdown();
                      Overlay.of(context).insert(floatingDropdown);
                    }
                    isDropdownOpened = !isDropdownOpened;
                    /*setState(() {

                          });*/
                  },
                  child: Container(
                    height: 45.0,
                    /*decoration: BoxDecoration(
                      color: Color(0xff008149),
                      borderRadius: BorderRadius.circular(4.0),
                    ),*/
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Icon(Icons.person_outline_rounded,
                            color: Colors.white, size: 24.0),
                        SizedBox(
                          width: 9.0,
                        ),
                        new Text(
                          translate('forconvience.Sign in') ,//"Login",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,//Colors.white,
                            fontSize: 17,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      if (isDropdownOpened) {
                        isDropdownOpened = !isDropdownOpened;
                        floatingDropdown.remove();
                      } else {
                        floatingDropdown = _createFloatingDropdown();
                        Overlay.of(context).insert(floatingDropdown);
                      }
                      isDropdownOpened = !isDropdownOpened;
                    });
                  },
                  child: Container(
                    height: 45.0,
                   /* decoration: BoxDecoration(
                      color: Color(0xff008149),
                      borderRadius: BorderRadius.circular(4.0),
                    ),*/
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14.0,
                        ),
                        (photourl != null)
                            ? Center(
                                child: new Text(
                                  translate('forconvience.profile') ,//"Login",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,//Colors.white,
                                    fontSize: 17,
                                  ),
                                ),)
                            :
                        //CircleAvatar(radius: 15.0, backgroundColor: Colors.white,),
                        //Image.asset("assets/images/profile.png"),
                        //SizedBox(width: 9.0,),
                        new Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              )
            ],
          ),
        ),

        Divider(
          color: ColorCodes.borderColor,
        ),
        Align(
          //alignment: Alignment.start,
          child: Container(
            constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.93):null,
            height: 50.0,
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Align(

                    alignment: Alignment.center,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap:() {
                          if(!widget._isHome)Navigator.pushNamedAndRemoveUntil(
                              context, HomeScreen.routeName, (route) => false);
                        },
                        child: Text( translate('bottomnavigation.home'),
                          style:TextStyle(
                            color: Theme.of(context).primaryColor,//Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),)
                    ),
                  ),
                ),
                new ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategoryData.catTwoitems.length,
                    itemBuilder: (_, i) => MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(ItemsScreen.routeName, arguments: {
                            'maincategory': subcategoryData.catTwoitems[i].title.toString(),
                            'catId': subcategoryData.catTwoitems[i].catid.toString(),
                            'catTitle': subcategoryData.catTwoitems[i].title.toString(),
                            'subcatId': subcategoryData.catTwoitems[i].subcatid.toString(),
                            'indexvalue': i.toString(),
                            'prev': "category_item"
                          });

                          floatingDropdown.remove();
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20.0,
                            ),
                            Text(
                              subcategoryData.catTwoitems[i].title,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,//Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              /*borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10)
              ),*/
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 3),
                )
              ],
            )
        ),
      ],
    );


/*  return Column(
    //  crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.topRight,
              colors: [
                Colors.white,
                Colors.white
               *//* Theme.of(context).primaryColor,
                Theme.of(context).accentColor*//*
              ],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: 80.0,
          child: Row(
            children: [
              SizedBox(
                width: 20.0,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap:() {
                    if(!widget._isHome)Navigator.of(context).pushNamed(HomeScreen.routeName);
                  },
                  child: Image.asset(
                    Images.logoAppbarImg,
                    width: 220,
                  ),
                ),
              ),

              SizedBox(
                width: 24.0,
              ),
              Container(
                height: 60.0,
                child: VerticalDivider(
                  color: Color(0xff707070),
                  thickness: 1.5,
                ),
              ),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      prefs.setString("formapscreen", "homescreen");
                      Navigator.of(context).pushNamed(MapScreen.routeName);
                      floatingDropdown.remove();
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 34.0,
                        ),
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 14.0,
                        ),
                        Expanded(
                          child: Text(
                            _deliverLocation,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style:
                            TextStyle(color: Colors.black, fontSize: 17.0),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20.0,
              ),
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {

                      setState(() {
                        if (isDropdownOpened) {
                          floatingDropdown.remove();
                        } else {
                          floatingDropdown = _searchBar();
                          Overlay.of(context).insert(floatingDropdown);
                        }
                        isDropdownOpened = !isDropdownOpened;
                      });
                    },
                    child: Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border:Border.all(width: 0.0,
                              style: BorderStyle.solid)
                      ),
                      child: TextField(
                          autofocus: false,
                          focusNode: _focus,
                          textInputAction: TextInputAction.search,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            // fillColor: Colors.white,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                            hintText:translate('header.search'),
                            hintStyle: TextStyle(
                              color: Color(0xffBFBFBF),
                            ),
                            suffixIcon: Icon(Icons.search, size:22,color: Color(0xffBBBBBB)),
                            focusColor: Colors.white,
                            fillColor: Colors.white,
                            filled: (_focus.hasFocus.toString() == "true")?true:false,
                          ),

                          onSubmitted: (value) {
                            searchValue = value;
                            _isShowItem = true;
                            _isLoading = true;
                            onSubmit(value);
                            _focus.requestFocus();
                          },
                          onChanged: (String newVal) {
                            setState(() {
                              searchValue = newVal;

                              if (newVal.length == 0) {
                                _isSearchShow = false;
                              } else if (newVal.length == 2) {
                                //Provider.of<ItemsList>(context, listen: false).fetchsearchItems(newVal);
                                //search(newVal);

                              } else if (newVal.length >= 3) {
                                _debouncer.run(() {
                                  search(newVal);
                                  //  onSubmit(newVal);
                                  _focus.requestFocus();
                                  //perform search here
                                });

                                *//*searchDispaly = searchData.searchitems
                                                  .where((elem) =>
                                                  elem.title
                                                      .toString()
                                                      .toLowerCase()
                                                      .contains(newVal.toLowerCase()))
                                                  .toList();
                                              _isSearchShow = true;*//*
                              }
                            });
                          }
                      ),
                      // child: Row(
                      //   children: [
                      //     SizedBox(
                      //       width: 10.0,
                      //     ),
                      //     Expanded(
                      //       child: Text(
                      //         'Search from 10,000+ Products',
                      //         overflow: TextOverflow.ellipsis,
                      //         maxLines: 1,
                      //         style: TextStyle(
                      //           color: Color(0xffBFBFBF),
                      //           fontSize: 16,
                      //         ),
                      //       ),
                      //     ),
                      //     Icon(
                      //       Icons.search,
                      //       color: Color(0xffBBBBBB),
                      //       size: 24.0,
                      //     ),
                      //     SizedBox(
                      //       width: 5.0,
                      //     ),
                      //   ],
                      // ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 26.0,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName,
                        arguments: {"prev": "home_screen"});
                    floatingDropdown.remove();
                  },
                  child: Container(
                    //width: 132.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:Border.all(width: 0.0,
                            style: BorderStyle.solid)
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        ValueListenableBuilder(
                          valueListenable:
                          Hive.box<Product>(productBoxName).listenable(),
                          builder: (context, Box<Product> box, index) {
                            if (box.values.isEmpty)
                              return Image.asset(
                                Images.cartImg,
                                color: Colors.black,
                                width: 24,
                                height: 24,
                              );

                            int cartCount = 0;
                            for (int i = 0;
                            i < Hive.box<Product>(productBoxName).length;
                            i++) {
                              cartCount = cartCount +
                                  Hive.box<Product>(productBoxName)
                                      .values
                                      .elementAt(i)
                                      .itemQty;
                            }
                            return Consumer<Calculations>(
                              builder: (_, cart, ch) => Badge(
                                child: ch,
                                value: cartCount.toString(),
                              ),
                              child: Image.asset(
                                Images.cartImg,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          'Cart',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 26.0,
              ),
              checkSkip
                  ? MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (isDropdownOpened) {
                      isDropdownOpened = !isDropdownOpened;
                      floatingDropdown.remove();
                    } else {
                      floatingDropdown = _createLoginDropdown();
                      Overlay.of(context).insert(floatingDropdown);
                    }
                    isDropdownOpened = !isDropdownOpened;
                    *//*setState(() {

                          });*//*

                  },
                  child: Container(
                    height: 45.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:Border.all(width: 0.0,
                            style: BorderStyle.solid)
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 10.0),
                        Icon(Icons.person_outline_rounded,
                            color: Colors.black, size: 24.0),
                        SizedBox(
                          width: 9.0,
                        ),
                        new Text(
                          translate('forconvience.Sign in') ,//"Login",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() {
                      if (isDropdownOpened) {
                        isDropdownOpened = !isDropdownOpened;
                        floatingDropdown.remove();
                      } else {
                        floatingDropdown = _createFloatingDropdown();
                        Overlay.of(context).insert(floatingDropdown);
                      }
                      isDropdownOpened = !isDropdownOpened;
                    });

                  },
                  child: Container(
                    height: 45.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:Border.all(width: 0.0,
                            style: BorderStyle.solid)
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14.0,
                        ),
                        (photourl != null)
                            ? CircleAvatar(
                          radius: 15.0,
                          backgroundColor: Color(0xffD3D3D3),
                          backgroundImage: NetworkImage(photourl),
                        )
                            :
                        //CircleAvatar(radius: 15.0, backgroundColor: Colors.white,),
                        //Image.asset("assets/images/profile.png"),
                        //SizedBox(width: 9.0,),
                        new Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20.0,
              )
            ],
          ),
        ),

        *//*Divider(
          color: Colors.black,
        ),*//*
        new SizedBox(
          height: 10.0,
          child: new Center(
            child: new Container(
              margin: new EdgeInsetsDirectional.only(start: 1.0, end: 1.0),
              height: 3.0,
              color: Colors.black,
            ),
          ),
        ),

        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          child: new ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: categoriesData.items.length,
              itemBuilder: (_, i) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                   *//* Navigator.of(context)
                        .pushNamed(SubcategoryScreen.routeName, arguments: {
                      'catId': categoriesData.items[i].catid,
                      'catTitle': categoriesData.items[i].title,
                    });*//*
                    Navigator.of(context).pushNamed(
                        ItemsScreen.routeName, arguments: {
                      'maincategory': categoriesData.items[i].title,
                      'catId': categoriesData.items[i].catid,
                      'catTitle': categoriesData.items[i].title,
                      'subcatId': categoriesData.items[i].catid,
                      'indexvalue': i.toString(),
                      'prev': "category_item"
                    });
                    floatingDropdown.remove();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20.0,
                      ),
                      Text(
                        categoriesData.items[i].title,
                        style: TextStyle(
                          color: Color(0xff706C6C),
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                    ],
                  ),
                ),
              )),
        )
      ],
    );*/
  }

  fetchPrimary(){
    String isMapfetch,isdefaultloc;
    isMapfetch = prefs.getString("ismapfetch").toString();
     isdefaultloc=prefs.getString('defaultlocation').toString();//(prefs.getBool('defaultlocation')!=null)?prefs.getBool('defaultlocation'):false;
    if(prefs.getString("defaultlocation").toString()!="null" && prefs.getString("ismapfetch").toString()!="null"){
      setState(() {
        _deliverLocation = prefs.getString("deliverylocation");
        IConstants.deliverylocationmain.value = _deliverLocation;
        IConstants.currentdeliverylocation.value = "Available";
      });
    }else{

      getCurrentLocation();
    }
  }
  createHeaderForMobile() {
    final brandsData = Provider.of<BrandItemsList>(context,listen: false);
    final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    final discountitemData = Provider.of<SellingItemsList>(context,listen: false);

    if (brandsData.items.length > 0 ||
        sellingitemData.items.length > 0 ||
        categoriesData.items.length > 0 ||
        discountitemData.itemsdiscount.length > 0) {
      _isDelivering = true;
    } else {
      _isDelivering = false;
    }
    setState(() {
      HomeScreen.scaffoldKey.currentState.isDrawerOpen?  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.white,
      )) :  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Theme.of(context).primaryColor,
      ));
    });
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Theme.of(context).primaryColor,
              Color(0xFF45B343),
              Theme.of(context).primaryColor,
            ],
          ),
        ),
        //color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: _isDelivering ? 140.0 : 140.0,
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              /*SizedBox(
                width: 12,
              ),*/
              IconButton(
                padding: EdgeInsets.only(left: 0.0),
                icon: Icon(
                  Icons.menu,
                  color: Theme.of(context).buttonColor,
                  size: 28.0,
                ),
                onPressed: () {
                  HomeScreen.scaffoldKey.currentState.openDrawer();

                  setState(() {
                    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
                      statusBarColor: Colors.white,
                    ));
                  });

                },
              ),
             // SizedBox(width: MediaQuery.of(context).size.width*0.20,),
              Spacer(),
              SizedBox(width: 30,),
              Center(
                child: Image. asset(
                  Images.logoAppbarImg,
                  color: Colors.white,
                  height: 50,
                  width: 138,
                ),
              ),
              Spacer(),
             /* SizedBox(
                width: 10,
              ),*/
              _isUnreadNot
                  ? _isSkip
                  ?
              ValueListenableBuilder(
              valueListenable: IConstants.currentdeliverylocation,
              builder: (context, value, widget) {
                return Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(80),
                      color: Theme
                          .of(context)
                          .primaryColor),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      if (value != "Not Available" )
                        /*if(_isSkip)
                      Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      );*/
                        Navigator.of(context).pushNamed(
                            NotificationScreen.routeName);
                    },
                    child: Icon(
                      Icons.notifications_none,
                      color: ColorCodes.whiteColor,
                    ),
                  ),
                );

              }
              )
                  : ValueListenableBuilder(
              valueListenable: IConstants.currentdeliverylocation,
    builder: (context, value, widget) {
      return Consumer<NotificationItemsList>(
        builder: (_, cart, ch) =>
            Badge(
              child: ch,
              color: ColorCodes.badgeColor,
              value: unreadCount.toString(),
            ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (value != "Not Available" ) {
              /*_isSkip
                  ?
              Navigator.of(context).pushNamed(
                SignupSelectionScreen.routeName,
              )
                  :*/ Navigator.of(context).pushNamed(
                  NotificationScreen.routeName);
              /*Navigator.of(context)
                  .pushNamed(NotificationScreen.routeName);*/
            }
          },
          child: Container(
            margin: EdgeInsets.only(
                top: 10, right: 10, bottom: 10),
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme
                    .of(context)
                    .primaryColor),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {

                /*_isSkip
                    ? Navigator.of(context).pushNamed(
                  SignupSelectionScreen.routeName,
                )
                    :*/ Navigator.of(context).pushNamed(
                    NotificationScreen.routeName);
              },
              child: Icon(
                Icons.notifications_none,
                size: 22,
                color: ColorCodes.whiteColor,
              ),
            ),
          ),
        ),
      );
    }
                  )
                  : ValueListenableBuilder(
                  valueListenable: IConstants.currentdeliverylocation,
    builder: (context, value, widget) {
      return Container(
        width: 25,
        height: 25,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Theme
                .of(context)
                .primaryColor),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (value != "Not Available")
              /*_isSkip
                  ?
              Navigator.of(context).pushNamed(
                SignupSelectionScreen.routeName,
              )
                  :*/ Navigator.of(context).pushNamed(
                  NotificationScreen.routeName);
             /* Navigator.of(context)
                  .pushNamed(NotificationScreen.routeName);*/
          },
          child: Icon(
            Icons.notifications_none,
            size: 22,
            color: ColorCodes.whiteColor,
          ),
        ),
      );
    }
                  ),
              SizedBox(
                width: 10,
              ),
              ValueListenableBuilder(
    valueListenable: IConstants.currentdeliverylocation,
    builder: (context, value, widget) {

      return ValueListenableBuilder(
        valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty)
            return GestureDetector(
              onTap: () {
                if (value != "Not Available")
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              child: Container(
                margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme
                        .of(context)
                        .primaryColor),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 22,
                  color: ColorCodes.whiteColor,
                ),
              ),
            );

          int cartCount = 0;
          for (int i = 0;
          i < Hive
              .box<Product>(productBoxName)
              .length;
          i++) {
            cartCount = Hive
                .box<Product>(productBoxName)
                .length; /*cartCount +
                          Hive.box<Product>(productBoxName)
                              .values
                              .elementAt(i)
                              .itemQty;*/
          }
          return Consumer<Calculations>(
            builder: (_, cart, ch) =>
                Badge(
                  child: ch,
                  color: ColorCodes.badgeColor,
                  value: cartCount.toString(),
                ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              child: Container(
                margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme
                        .of(context)
                        .primaryColor),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 22,
                  color: ColorCodes.whiteColor,
                ),
              ),
            ),
          );
        },

      );
    }
              ),
              SizedBox(width: 5),
            ],
          ),
          SizedBox(
            height: 5,
          ),

            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
              width: MediaQuery.of(context).size.width,
              //margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.only(left: 15),
              child: IntrinsicHeight(
                child: Row(
                  children: [
    ValueListenableBuilder(
    //TODO 2nd: listen playerPointsToAdd
    valueListenable: IConstants.currentdeliverylocation,
    builder: (context, value, widget) {
     return GestureDetector(
        onTap: () {
          if (value != "Not Available")
            Navigator.of(context).pushNamed(
              CategoryScreen.routeName,
            );
        },
        child: Image.asset(
          Images.categoriesImg,
          height: 25,
          color: ColorCodes.whiteColor,
        ),
      );
    }),
                    SizedBox(width: 5),
                    VerticalDivider(
                      color: ColorCodes.whiteColor,
                      endIndent: 8,
                      indent: 8,
                    ),
                    SizedBox(width: 5),
                    ValueListenableBuilder(
                    //TODO 2nd: listen playerPointsToAdd
                    valueListenable: IConstants.currentdeliverylocation,
    builder: (context, value, widget) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
    onTap: () {
      if(value != "Not Available" )
    if (_isDelivering)
    Navigator.of(context)
        .pushNamed(SearchitemScreen.routeName);
    },
    child: Container(
    width: MediaQuery.of(context).size.width * 0.78,
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(
    translate('header.search'),
    style: TextStyle(
    color: ColorCodes.whiteColor,
    ),
    ),
    //SizedBox(width: MediaQuery.of(context).size.width),
    Icon(
    Icons.search,
    size:22,
    color: Colors.white,
    )
    ],
    ),
    ),
    );
    }),
                  ],
                ),
              ),
            ),
          Spacer(),
          Container(
            height: 4,
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).accentColor,
          ),
          Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: ColorCodes.grey,
                      blurRadius: 15.0,
                      offset: Offset(0.0, 0.75))
                ],
                color: Theme.of(context).buttonColor,
              ),
              width: MediaQuery.of(context).size.width,
              height: 38,
              child: Row(children: [
                // IconButton(icon: Icon(Icons.location_on,size:18,color: Colors.black,)),
                SizedBox(
                  width: 15,
                ),
                Icon(Icons.location_on,
                    color: ColorCodes.blackColor, size: 16),
                SizedBox(
                  width: 5.0,
                ),

                Expanded(
                  child:
                 /* Text(
                    (_deliverLocation!=null)? _deliverLocation:"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: ColorCodes.locationColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),*/
                  (IConstants.deliverylocationmain != "null" || IConstants.deliverylocationmain.value != "")?
                      ValueListenableBuilder(
                    //TODO 2nd: listen playerPointsToAdd
                    valueListenable: IConstants.deliverylocationmain,
                    builder: (context, value, widget) {
                      //TODO here you can setState or whatever you need
                      return Text(
                        //TODO e.g.: create condition with playerPointsToAdd's value
                          value != "" ?value.toString():
                          (_deliverLocation!=null)? _deliverLocation:"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: ColorCodes.locationColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold),);

                    },
                  ):  Text(
                    (_deliverLocation!=null)? _deliverLocation:"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: ColorCodes.locationColor,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),

                ),
                SizedBox(
                  width: 5,
                ),
                GestureDetector(
                    onTap: () async {
                      prefs.setString("formapscreen", "homescreen");
                      Navigator.of(context).pushNamed(MapScreen.routeName);
                    },
                    child: Text(
                      translate('header.change'),
                      style: TextStyle(
                          color: ColorCodes.locationColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    )),
                SizedBox(
                  width: 15,
                )
              ]))
        ]));
  }

 /* _getdeleverlocation() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _deliverLocation = prefs.getString("deliverylocation");
    });

  }*/
}

Widget _DropDownItem(IconData iconData, String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: <Widget>[
        Icon(
          iconData,
          color: Color(0xff535353),
        ),
        SizedBox(
          width: 8.0,
        ),
        Text(
          text,
          style: TextStyle(color: Color(0xff535353), fontSize: 17),
        ),
      ],
    ),
  );
}
class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}


