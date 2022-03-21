import 'dart:convert';
import 'dart:io';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/ColorCodes.dart';
import '../screens/not_brand_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:package_info/package_info.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../handler/firebase_notification_handler.dart';
import 'package:http/http.dart' as http;
import '../constants/IConstants.dart';
import '../screens/signup_selection_screen.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/orderhistory_screen.dart';
import '../screens/not_product_screen.dart';
import '../screens/not_subcategory_screen.dart';
import '../screens/introduction_screen.dart';
import '../constants/images.dart';
import '../providers/notificationitems.dart';
import '../screens/orderexample.dart';
import 'package:flutter_translate/flutter_translate.dart';

const APP_STORE_URL = 'https://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=1563407384&mt=8';
const PLAY_STORE_URL = 'https://play.google.com/store/apps/details?id=com.fellahi.store';

class SplashScreenPage extends StatefulWidget {
  @override
  SplashScreenPageState createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _isHomeScreen = true;
  int timerCount = 3;
  Timer _clockTimer;
  Timer _timmer;
  bool timmer = true;

  void navigationToNextPage() async {

    prefs = await SharedPreferences.getInstance();
    prefs.setString("formapscreen", "");
    var LoginStatus = prefs.getString('LoginStatus');

    if (LoginStatus == null || LoginStatus != "true") {
      prefs.setString('skip', "yes");
    }
    Navigator.of(context).pushReplacementNamed(
      HomeScreen.routeName,
    );
  }

  startSplashScreenTimer() async {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    var _duration = new Duration(seconds: 3);
    _timmer = new Timer(_duration, navigationToNextPage);
    return _timmer;

  }

  @override
  void initState() {

    super.initState();

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      var LoginStatus = prefs.getString('LoginStatus');
      if (!prefs.containsKey("branch")) prefs.setString("branch", "999");
      try {
        if (Platform.isIOS || Platform.isAndroid) {
          final signcode = await SmsAutoFill().getAppSignature;
          prefs.setString('signature', signcode);
          handleDynamicLink();
        }
      } catch (e) {

      }
        try {
          if (Platform.isIOS || Platform.isAndroid) {
            await new FirebaseNotifications().setUpFirebase();
            _firebaseMessaging.configure(

              onMessage: (Map<String, dynamic> message) async {
                if (_timmer.isActive)
                  _timmer.cancel();
                timmer =false;
                final responseJson = json.encode(message);
                final responseJsonDecode = json.decode(responseJson);
                final notificationEncode = json.encode(responseJsonDecode['notification']);
                final notificationDecode = json.decode(notificationEncode);

                if (prefs.containsKey("userID"))
                  Provider.of<NotificationItemsList>(context, listen: false)
                      .fetchNotificationLogs(prefs.getString('userID'));

                return Fluttertoast.showToast(
                    msg: notificationDecode["body"].toString());
              },
              onResume: (Map<String, dynamic> message) async {
                if (_timmer.isActive) _timmer.cancel();
                timmer =false;
                String _mode = "";
                String _nid = "";
                String _ref = "";

                final responseJson = json.encode(message);
                final responseJsonDecode = json.decode(responseJson);
                if(Platform.isIOS) {
                  _mode = responseJsonDecode['mode'].toString();
                  _nid = responseJsonDecode["nid"].toString();
                  _ref = responseJsonDecode['ref'].toString();
                } else {
                  final dataEncode = json.encode(responseJsonDecode['data']);
                  final dataDecode = json.decode(dataEncode);
                  _mode = dataDecode["mode"].toString();
                  _nid = dataDecode["nid"].toString();
                  _ref = dataDecode["ref"].toString();
                }

                if (_mode == "1") {
                  //redirect to app home page
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                  Navigator.of(context).pushReplacementNamed(
                    HomeScreen.routeName,
                  );
                }
               else if (_mode == "2") {
                  // Order and 'ref' key is for fetching order id
                  _isHomeScreen = false;
                  if (LoginStatus != null) {
                    Navigator.of(context)
                        .pushNamed(orderexample.routeName, arguments: {
                      'orderid': _ref,
                      'fromScreen': "pushNotification",
                      'notificationId': _nid
                    });
                  }
                } else if (_mode == "3") {
                  //Web Link
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                } else if (_mode == "4") {
                  //Product with array of product id (Then have to call api)
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Navigator.of(context)
                      .pushNamed(NotProductScreen.routeName, arguments: {
                    'productId': _ref,
                    'fromScreen': "ClickLink",
                    'notificationId': _nid
                  });
                } else if (_mode == "5") {
                  //Sub category with array of sub category
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Navigator.of(context)
                      .pushNamed(NotSubcategoryScreen.routeName, arguments: {
                    'subcategoryId': _ref,
                    'fromScreen': "ClickLink",
                    'notificationId': _nid,
                  });
                } else if (_mode == "6") {
                  //redirect to app home page
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                  Navigator.of(context).pushReplacementNamed(
                    HomeScreen.routeName,
                  );
                } else if(_mode == "10") {
                  //redirect to app home page
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                  Navigator.of(context).pushReplacementNamed(
                      NotBrandScreen.routeName,
                      arguments: {
                        'brandsId': _ref,
                        'fromScreen': "ClickLink",
                        'notificationId': _nid,
                      }
                  );
                }

              },
              onLaunch: (Map<String, dynamic> message) async {
                if (_timmer.isActive) _timmer.cancel();
                final responseJson = json.encode(message);
                final responseJsonDecode = json.decode(responseJson);
                String _mode = "";
                String _nid = "";
                String _ref = "";
                if(Platform.isIOS) {
                  _mode = responseJsonDecode['mode'].toString();
                  _nid = responseJsonDecode["nid"].toString();
                  _ref = responseJsonDecode['ref'].toString();
                } else {
                  final dataEncode = json.encode(responseJsonDecode['data']);
                  final dataDecode = json.decode(dataEncode);
                  _mode = dataDecode["mode"].toString();
                  _nid = dataDecode["nid"].toString();
                  _ref = dataDecode["ref"].toString();
                }

                timmer =false;
                 if (_mode == "1") {
                //redirect to app home page
                _isHomeScreen = false;

                if (LoginStatus == null) {
                prefs.setString('skip', "yes");
                }
                if (LoginStatus == null) {
                prefs.setString('skip', "yes");
                }
                Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                Navigator.of(context).pushReplacementNamed(
                HomeScreen.routeName,
                );
                }
               else if (_mode == "2") {
                  // Order and 'ref' key is for fetching order id
                  _isHomeScreen = false;
                  if (LoginStatus != null) {
                    Navigator.of(context)
                        .pushNamed(orderexample.routeName, arguments: {
                      'orderid': _ref,
                      'fromScreen': "pushNotification",
                      'notificationId': _nid
                    });
                  }
                }


                else if(_mode == "3") {
                  //Web Link
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                } else if(_mode == "4") {
                  //Product with array of product id (Then have to call api)
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Navigator.of(context)
                      .pushNamed(NotProductScreen.routeName, arguments: {
                    'productId': _ref,
                    'fromScreen': "ClickLink",
                    'notificationId': _nid
                  });
                } else if(_mode == "5") {
                  //Sub category with array of sub category
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Navigator.of(context)
                      .pushNamed(NotSubcategoryScreen.routeName, arguments: {
                    'subcategoryId': _ref,
                    'fromScreen': "ClickLink",
                    'notificationId': _nid,
                  });
                } else if(_mode == "6") {
                  //redirect to app home page
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                  Navigator.of(context).pushReplacementNamed(
                    HomeScreen.routeName,
                  );
                } else if(_mode == "10") {
                  //redirect to app home page
                  _isHomeScreen = false;
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  if (LoginStatus == null) {
                    prefs.setString('skip', "yes");
                  }
                  Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(_nid, "1");
                  Navigator.of(context).pushReplacementNamed(
                      NotBrandScreen.routeName,
                      arguments: {
                        'brandsId': _ref,
                        'fromScreen': "ClickLink",
                        'notificationId': _nid,
                      }
                  );
                }

              },
            );
          }
          // INTRODUCTION SCREEN CHECK

          bool introduction = prefs.getBool('introduction');

          if (introduction == null) {
            Navigator.of(context).pushReplacementNamed(
                introductionscreen.routeName);
          } else {
            startSplashScreenTimer();
          }
        } catch (e) {
          timmer =false;
          prefs.setString("tokenid", "");
          prefs.setString('skip', "yes");
          Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
        }
      });




    try {
      // if (Platform.isIOS || Platform.isAndroid) {
      //   versionCheck(context);
      // }
      if (Platform.isAndroid) {
        versionCheck(context);
      } else if(Platform.isIOS) {
        versionCheckForIos();
      }
    } catch (e) {
    }
    }

  versionCheckForIos() async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
    double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version_ios');
      remoteConfig.getString('optional_update_version_ios');
      double forcedVersion = double.parse(remoteConfig
          .getString('force_update_current_version_ios')
          .trim()
          .replaceAll(".", ""));
      double optionalVersion = double.parse(remoteConfig
          .getString('optional_update_version_ios')
          .trim()
          .replaceAll(".", ""));

      if (forcedVersion > currentVersion) {
        _showForcedVersionDialog(context);
      } else if (optionalVersion > currentVersion) {
        _showOptionalVersionDialog(context);
      } else {
        // INTRODUCTION SCREEN CHECK
        /*await Provider.of<BrandItemsList>(context, listen: false).GetRestaurant().then((_) {

        });*/
        // INTRODUCTION SCREEN CHECK
        bool introduction = prefs.getBool('introduction');
        if(timmer)startSplashScreenTimer();
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
    } catch (exception) {
    }
  }
  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion =
    double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      remoteConfig.getString('optional_update_version');
      double forcedVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      double optionalVersion = double.parse(remoteConfig
          .getString('optional_update_version')
          .trim()
          .replaceAll(".", ""));

      if (forcedVersion > currentVersion) {
        _showForcedVersionDialog(context);
      } else if (optionalVersion > currentVersion) {
        _showOptionalVersionDialog(context);
      } else {
        // INTRODUCTION SCREEN CHECK

        bool introduction = prefs.getBool('introduction');

        if (introduction == null) {
          Navigator.of(context).pushReplacementNamed(
              introductionscreen.routeName);
        } else {
          if(timmer) startSplashScreenTimer();
        }
       // startSplashScreenTimer();
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
    } catch (exception) {
    }
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      // INTRODUCTION SCREEN CHECK

      bool introduction = prefs.getBool('introduction');

      if (introduction == null) {
        Navigator.of(context).pushReplacementNamed(
            introductionscreen.routeName);
      } else {
        startSplashScreenTimer();
      }
      //startSplashScreenTimer();
    } else {
      throw 'Could not launch $url';
    }
  }

  _forcedLaunchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
      // INTRODUCTION SCREEN CHECK

      bool introduction = prefs.getBool('introduction');


      if (introduction == null) {
        Navigator.of(context).pushReplacementNamed(
            introductionscreen.routeName);
      } else {
        startSplashScreenTimer();
      }
      //versionCheck(context);
      if (Platform.isAndroid) {
        versionCheck(context);
      } else if(Platform.isIOS) {
        versionCheckForIos();
      }
    } else {
      throw 'Could not launch $url';
    }
  }

  _showForcedVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _forcedLaunchURL(APP_STORE_URL),
            ),
          ],
        )
            : new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
                child: Text(btnLabel),
                onPressed: () {
                  _forcedLaunchURL(PLAY_STORE_URL);
                }
            ),
          ],
        );
      },
    );
  }

  _showOptionalVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(APP_STORE_URL),
            ),
            FlatButton(
                child: Text(btnLabelCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                  startSplashScreenTimer();
                }
            ),
          ],
        )
            : new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            FlatButton(
                child: Text(btnLabelCancel),
                onPressed: () {
                  Navigator.of(context).pop();
                  startSplashScreenTimer();
                }
            ),
          ],
        );
      },
    );
  }


  handleDynamicLink() async {
    // await Future.delayed(Duration(seconds: 3));

    var data = await FirebaseDynamicLinks.instance.getInitialLink();
    var deepLink = data?.link;
    if (deepLink != null) {
      var isRefer = deepLink.pathSegments.contains('refer');
      if (isRefer) {
        var code = deepLink.queryParameters['code'];

       prefs.setString("referCodeDynamic", code);

      }

    }
    /*await dynamicLink.getInitialLink();
    dynamicLink.onLink(onSuccess: (PendingDynamicLinkData data) async {
      handleSuccessLinking(data);
    }, onError: (OnLinkErrorException error) async {
    });*/
  }

  void handleSuccessLinking(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      var isRefer = deepLink.pathSegments.contains('refer');
      if (isRefer) {
        var code = deepLink.queryParameters['code'];

        prefs.setString("referCodeDynamic", code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //SystemChrome.setEnabledSystemUIOverlays([]);
    // full screen image for splash screen.
    return Scaffold(
      backgroundColor: ColorCodes.whiteColor,
      body: Center(
        child: new Image.asset(
          Images.logoImg,
          width: 250,
          height: 130,
        ),
      ),
    );
  }

  Future<void> fetchDelivery() async {
    // imp feature in adding async is the it automatically wrap into Future.

    var url = IConstants.API_PATH + 'restaurant/details';
    try {
      //  prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson['status'].toString() == "true") {
        final dataJson =
            json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);

        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) => data.add(
            dataJsondecode[index] as Map<String,
                dynamic>)); //store each category values in data list

        SharedPreferences prefs = await SharedPreferences.getInstance();

        for (int i = 0; i < data.length; i++) {
          prefs.setString("resId", data[i]['id'].toString());
          prefs.setString("minAmount", data[i]['minOrderAmount'].toString());
          prefs.setString(
              "deliveryCharge", data[i]['deliveryCharge'].toString());
        }
      }
    } catch (error) {
      throw error;
    }
  }
}
