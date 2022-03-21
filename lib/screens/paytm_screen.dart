//import 'dart:html';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import '../screens/payment_screen.dart';
import '../screens/orderconfirmation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/IConstants.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'dart:ui' as ui;

class PaytmScreen extends StatefulWidget {
  static const routeName = '/paytm-screen';

  @override
  _PaytmScreenState createState() => _PaytmScreenState();
}

class _PaytmScreenState extends State<PaytmScreen> {
  WebViewController _webController;
  bool _loadingPayment = true;
  String customerId = "";
  SharedPreferences _prefs;
  bool _isLoading = true;

  @override
  void dispose() {
    _webController = null;
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        customerId = _prefs.getString('userID');
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String channel = "";

    final routeArgs = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;
    final orderId = routeArgs['orderId'];
    final amount = routeArgs['orderAmount'] /*"1.0"*/;

    final queryParams =
        '?orderid=$orderId&customer=$customerId&price=$amount';

    debugPrint("urllllll " + IConstants.API_PAYTM + queryParams);

    try{
      if(io.Platform.isIOS) {
        channel = "IOS";
      } else {
        channel = "Android";
      }
    } catch(e){
      channel = "Web";
    }

  /*  if(!_isLoading) {
*//*      IFrameElement iframeElement = IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = IConstants.API_PAYTM + queryParams
        ..style.border = 'none';

      ui.platformViewRegistry.registerViewFactory(
        'GrocBay',
            (int viewId) => iframeElement,
      );*//*
    }*/

    return WillPopScope(
      onWillPop: () { // this is the block you need
        Navigator.pushReplacementNamed(context, PaymentScreen.routeName, arguments: {
          'minimumOrderAmountNoraml': routeArgs['minimumOrderAmountNoraml'],
          'deliveryChargeNormal': routeArgs['deliveryChargeNormal'],
          'minimumOrderAmountPrime': routeArgs['minimumOrderAmountPrime'],
          'deliveryChargePrime': routeArgs['deliveryChargePrime'],
          'minimumOrderAmountExpress': routeArgs['minimumOrderAmountExpress'],
          'deliveryChargeExpress': routeArgs['deliveryChargeExpress'],
          'deliveryType': routeArgs['deliveryType'],
          'note': routeArgs['note'],
        },);
        return Future.value(false);
      },
      child: _isLoading ?
      Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      )
          : channel == "Web" ? HtmlElementView(viewType: 'Fellahi') : SafeArea(
        child: Scaffold(
            body: Stack(
              children: <Widget>[
                if(_loadingPayment)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                    ),
                  ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: WebView(
                    //hidden: true,
                    debuggingEnabled: false,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller){
                      _webController = controller;
                      _webController
                          .loadUrl(IConstants.API_PAYTM + queryParams);

                    },
                    onPageFinished: (page){
                      debugPrint("Page . . . . .. " + page.toString());
                     // _isLoading=false;
                      if(page.contains("/order")) {
                        setState(() {
                          _loadingPayment = false;
                        });
                      }
                      if(page.contains("/cancelTransaction")) {
                        Navigator.of(context).pop();
                      }
                      if(!page.contains("/cancelTransaction")) {
                        if (page.contains("/callback.php") || page.contains("/Ok-Fail.php")) {
                          final routeArgs = ModalRoute
                              .of(context)
                              .settings
                              .arguments as Map<String, String>;

                          final orderId = routeArgs['orderId'];
                          Navigator.pushReplacementNamed(context, PaymentScreen.routeName, arguments: {
                            'minimumOrderAmountNoraml': routeArgs['minimumOrderAmountNoraml'],
                            'deliveryChargeNormal': routeArgs['deliveryChargeNormal'],
                            'minimumOrderAmountPrime': routeArgs['minimumOrderAmountPrime'],
                            'deliveryChargePrime': routeArgs['deliveryChargePrime'],
                            'minimumOrderAmountExpress': routeArgs['minimumOrderAmountExpress'],
                            'deliveryChargeExpress': routeArgs['deliveryChargeExpress'],
                            'deliveryType': routeArgs['deliveryType'],
                            'note': routeArgs['note'],
                          },);
                         /* Navigator.of(context).pushReplacementNamed(
                              OrderconfirmationScreen.routeName,
                              arguments: {
                                'orderstatus': "waiting",
                                'orderId': orderId.toString(),
                              }
                          );*/
                        }
                      }
                    },
                  ),
                ),
                if(!_loadingPayment)
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                    ),
                  ),
              ],
            )
        ),
      )
    );
  }
}


/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import '../screens/orderconfirmation_screen.dart';

class PaytmScreen extends StatefulWidget {
  static const routeName = '/paytm-screen';
  _PaytmScreenState createState() => _PaytmScreenState();
}

class _PaytmScreenState extends State<PaytmScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  SharedPreferences _prefs;
  String customerId = "";
  bool _isLoading = true;

  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;

  String status;

  @override
  void dispose() {
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        customerId = _prefs.getString('userID');
      });
    });

    flutterWebviewPlugin.close();


    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
        });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (mounted) {
        setState(() {
          */
/*"https://paytm.grocbay.com/pgResponse.php"*//*

          var arr = url.split('?');

          if(arr[0] == IConstants.API_PAYTM + "pgResponse.php") {
            flutterWebviewPlugin.close();
            final routeArgs = ModalRoute
                .of(context)
                .settings
                .arguments as Map<String, String>;

            final orderId = routeArgs['orderId'];

            Navigator.of(context).pushReplacementNamed(
                OrderconfirmationScreen.routeName,
                arguments: {
                  'orderstatus' : "waiting",
                  'orderId' : orderId.toString(),
                }
            );
          }
          if (url.contains('callback')) {
            flutterWebviewPlugin.getCookies().then((cookies) {
              // add logic to make show payment status
              flutterWebviewPlugin.close();
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;

    final orderId = routeArgs['orderId'];
    final amount = routeArgs['orderAmount'];
    customerId = _prefs.getString('userID');

    final queryParams =
        '?orderid=$orderId&customer=$customerId&price=1.0';

    return new WebviewScaffold(
        withJavascript: true,
        appCacheEnabled: true,
        scrollBar: true,
        withLocalStorage: true,
        withLocalUrl: true,
        hidden: true,
        resizeToAvoidBottomInset: true,
        url: */
/*"https://paytm.grocbay.com/?orderid=1009&customer=1000&price=500"*//*
 IConstants.API_PAYTM + queryParams,
        appBar: new GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
          ),
          title: new Text("Pay using PayTM"),
          //leading: Container(),
        ));
  }
}
*/
