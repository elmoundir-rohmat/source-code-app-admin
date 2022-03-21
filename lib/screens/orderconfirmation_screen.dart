import 'dart:convert';
import 'dart:io';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import '../widgets/footer.dart';
import 'package:flutter/material.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/home_screen.dart';
import '../screens/myorder_screen.dart';
import '../constants/IConstants.dart';
import '../constants/ColorCodes.dart';

class OrderconfirmationScreen extends StatefulWidget {
  static const routeName = '/orderconfirmation-screen';

  @override
  OrderconfirmationScreenState createState() => OrderconfirmationScreenState();
}

class OrderconfirmationScreenState extends State<OrderconfirmationScreen> {
  bool _isOrderstatus = true;
  bool _isLoading = true;
  bool _isWeb = false;
  var _address = "";
  double wid;
  double maxwid;
  MediaQueryData queryData;
  bool iphonex = false;
  var _currencyFormat = "";
  var amount;
  var orderId;

  @override
  void initState() {
    Hive.openBox<Product>(productBoxName);
    /*try {
      if (Platform.isIOS || Platform.isAndroid) {
        final document = await getApplicationDocumentsDirectory();
        Hive.init(document.path);
        Hive.registerAdapter(ProductAdapter());
        Hive.openBox<Product>(productBoxName);

      }
    } catch (e) {
      Hive.registerAdapter(ProductAdapter());
      Hive.openBox<Product>(productBoxName);
    }*/


    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            iphonex = MediaQuery.of(context).size.height >= 812.0;
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
      final routeArgs = ModalRoute
          .of(context)
          .settings
          .arguments as Map<String, String>;
      final orderstatus = routeArgs['orderstatus'];
      orderId = routeArgs['orderId'];
      amount = routeArgs['orderAmount'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currencyFormat = prefs.getString("currency_format");

      if(orderstatus == "success"){
        setState(() {
          _isOrderstatus = true;
          _isLoading = false;
        });
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        for(int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
          if (Hive.box<Product>(productBoxName).values.elementAt(i).mode == 1){
            prefs.setString("membership", "0");
          }
        }
        //Hive.box<Product>(productBoxName).deleteFromDisk();
        Hive.box<Product>(productBoxName).clear();
        final orderId = routeArgs['orderId'];
        paymentStatus(orderId);
      }
    });
    super.initState();
  }

  Future<void> paymentStatus(String orderId) async { // imp feature in adding async is the it automatically wrap into Future.
    var name;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-order-status/' + orderId;
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(response.body);
      if(responseJson['status'].toString() == "yes") {
        for(int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
          facebookAppEvents.logPurchase(parameters: {
            "id":orderId,
          },amount: amount,currency:_currencyFormat);
          if (Hive.box<Product>(productBoxName).values.elementAt(i).mode == 1){
            prefs.setString("membership", "2");
          }
        }
        Hive.box<Product>(productBoxName).clear();
        setState(() {
          _isOrderstatus = true;
          _isLoading = false;
        });
      } else {
        for(int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
          if (Hive.box<Product>(productBoxName).values.elementAt(i).mode == 1){
            prefs.setString("membership", "0");
          }
        }
        Hive.box<Product>(productBoxName).clear();
        setState(() {
          _isOrderstatus = false;
          _isLoading = false;
        });
      }
/*      if(responseJson['status'].toString() == "200") {
        if(status == "paid") {
          Navigator.of(context).pushReplacementNamed(
              OrderconfirmationScreen.routeName,
              arguments: {
                'orderstatus' : "success",
              }
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
              OrderconfirmationScreen.routeName,
              arguments: {
                'orderstatus' : "failure",
              }
          );
        }
      } else {
      }*/

    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
     return WillPopScope(
        onWillPop: () { // this is the block you need
          //Hive.openBox<Product>(productBoxName);
          (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?
          //   SchedulerBinding.instance.addPostFrameCallback((_) {
          /* Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);*/
          // Navigator.of(context).pop();
          // debugPrint("web....... home.........");
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home-screen', (Route<dynamic> route) => false)
          //  })
              :

          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
          return Future.value(false);
        },
        child: Scaffold(
            appBar: ResponsiveLayout.isSmallScreen(context) ?
            gradientappbarmobile() : null,
            backgroundColor: ColorCodes.whiteColor,
            body:Column(
              //only for mobile
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                    Header(false),

                  _body(),
                ],
            ),
            bottomNavigationBar:  _isWeb ? SizedBox.shrink() : Container(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
                  child: _buildBottomNavigationBar()
              ),
            ),
        ),
     );
  }
  _buildBottomNavigationBar() {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.60;
    return SingleChildScrollView(
      child: Container(
        width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width,
        color: Theme.of(context).primaryColor,
        height: 50.0,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacementNamed(MyorderScreen.routeName);
              },
              child: Align(
                  alignment: Alignment.center,
                  child: Text(translate('forconvience.CHECK YOUR ORDER'), style: TextStyle(color: ColorCodes.whiteColor,fontWeight: FontWeight.bold),))),
        ),
      ),
    );
  }
  _body(){
    return _isWeb?_bodyweb():
    _bodymobile();
  }
_bodymobile() {
    return _isLoading ?
    Center(
      child: CircularProgressIndicator(
        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
      ),
    )
        :
    Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          /*SizedBox(
            height: 70.0,
          ),*/
         /* Text('Thank You for Choosing ' + IConstants.APP_NAME + '!',
            style: TextStyle(fontSize: 25.0, color: Color(0xFF616161)),
            textAlign: TextAlign.center,
          ),*/
         // SizedBox(height: 20),
          _isOrderstatus ? Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.check_circle_outline_outlined, color: Theme.of(context).primaryColor, size: 150,),
          )
              :
          Align(
            alignment: Alignment.center,
            child: Icon(Icons.cancel, color: Colors.red, size: 100.0),
          ),
          _isOrderstatus ?
          Container(
            height: 150.0,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                   translate('forconvience.You have Successfully placed your order'),
                    style: TextStyle(color: Color(0xEE616060),
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                  /*SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    "Your order is being processed by our delivery team and you should receive a confirmation from us shortly!",
                    style: TextStyle(color: Color(0xFF817E7E), fontSize: 15),
                    textAlign: TextAlign.center,
                  ),*/
                ],
              ),
            ),
          )
              :
          Container(
            height: 100.0,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Order Cancelled!",
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
        ]
    );
  }
  _bodyweb() {
        return     Expanded(
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(

                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                     /* SizedBox(
                        height: 50.0,
                      ),
                      Text('Thank You for Choosing ' + IConstants.APP_NAME + '!',
                        style: TextStyle(fontSize: 25.0, color: Color(0xFF616161)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),*/
                      _isOrderstatus ? Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.check_circle, color: Theme.of(context).primaryColor,//Color(0xFF3DBCAB),
                          size: 150,),
                      )
                          :
                      Align(
                        alignment: Alignment.center,

                        child: Icon(Icons.cancel, color: Colors.red, size: 100.0),
                      ),
                      _isOrderstatus ?
                      Container(

                        height: 150.0,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                translate('forconvience.You have Successfully placed your order'), // "Order Placed Successfully!",
                                style: TextStyle(color: Color(0xEE616060),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                             /* Text(
                                "Your order is being processed by our delivery team and you should receive a confirmation from us shortly!",
                                style: TextStyle(color: Color(0xFF817E7E), fontSize: 15),
                                textAlign: TextAlign.center,
                              ),*/
                            ],
                          ),
                        ),
                      )
                          :
                      Container(
                        width: MediaQuery.of(context).size.width * 30 / 100,
                        height: 100.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Order Cancelled!",
                                style: TextStyle(color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      _buildBottomNavigationBar(),
                      SizedBox(height: 30,),

                    ]
                ),
              ),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
            ],
          ),
        ),
      ),
    );
  }
  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined, color: ColorCodes.blackColor),onPressed: ()=>
          //Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,))),

      (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/home-screen', (Route<dynamic> route) => false)

          :

      SchedulerBinding.instance.addPostFrameCallback((_) {
       /* Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);*/
        Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
      })
      ),
      title: Text(translate('forconvience.Order Confirmation'),
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                 ColorCodes.whiteColor,
                  ColorCodes.whiteColor,
                ]
            )
        ),
      ),
    );
  }

}
