import 'dart:io';

import 'package:fellahi_e/screens/orderexample.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../constants/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import '../screens/not_brand_screen.dart';
import '../widgets/badge.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/footer.dart';

import '../main.dart';
import '../screens/home_screen.dart';
import '../screens/not_product_screen.dart';
import '../screens/not_subcategory_screen.dart';
import '../screens/orderhistory_screen.dart';
import '../providers/notificationitems.dart';
import '../constants/images.dart';
import 'cart_screen.dart';
import 'searchitem_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotificationScreen extends StatefulWidget {
  static const routeName = '/notification-screen';
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  bool _isNotification = true;
  bool _isWeb = false;
  var _address = "";
  bool _isloading = true;
  SharedPreferences prefs;
  ScrollController _controller = new ScrollController();
  MediaQueryData queryData;
  double wid;
  double maxwid;
  var notificationData;

  @override
  void initState() {
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
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
      await Provider.of<NotificationItemsList>(context,listen: false)
          .fetchNotificationLogs(prefs.getString('userID')==null ||prefs.getString('userID')==""?prefs.getString('guestuserId'):prefs.getString('userID')).then((_) {
         notificationData = Provider.of<NotificationItemsList>(context,listen: false);
         setState(() {
           if (notificationData.notItems.length <= 0) {
             debugPrint("if..........");
             _isNotification = false;
             _isloading=false;
             debugPrint("if.........."+_isloading.toString());
           } else {
             debugPrint("else..........");
             _isNotification = true;
             _isloading=false;
             debugPrint("else.........."+_isloading.toString());
           }

         });

      });
    });
  }
    @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context) ?
        gradientappbarmobile() : null,
        backgroundColor: ColorCodes.whiteColor,
        body:Column(
            children: <Widget>[
              if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Header(false),
              _isloading ?
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                  ),
                ),
              )
                  : _body(),
            ]
        ),
    );
  }
  _body() {
    return _isWeb ? _bodyweb() :
    _bodyMobile();
  }
  gradientappbarmobile() {
    return AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
          onPressed: () => Navigator.of(context).pop()),
      title: Text(
        translate('forconvience.Notification '),style: TextStyle(color: ColorCodes.backbutton),
      ),
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.whiteColor,
                  ColorCodes.whiteColor
                ])),
      ),
      actions:<Widget> [
        Container(
          height: 30,
          width: 30,
          margin: EdgeInsets.only(top: 13, left: 13, bottom: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                SearchitemScreen.routeName,
              );
            },
            child: Icon(
              Icons.search,
              size: 22,
              color:  ColorCodes.blackColor,
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context, Box<Product> box, index) {
            if (box.values.isEmpty)
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                child:
                Container(
                  margin: EdgeInsets.only(top: 13, right: 13, bottom: 13),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).buttonColor),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                    color: ColorCodes.blackColor,
                  ),
                ),
              /*  Container(
                  margin: EdgeInsets.only(top: 13, right: 13, bottom: 13),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    // color: Theme.of(context).buttonColor
                  ),

                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color:  ColorCodes.blackColor,
                  ),
                ),*/
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
                color: ColorCodes.banner,
                value: cartCount.toString(),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                child:
                Container(
                  margin: EdgeInsets.only(top: 15, right: 13, bottom: 10),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).buttonColor),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 22,
                    color: ColorCodes.blackColor,
                  ),
                ),
              /*  Container(
                  margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    // color: Theme.of(context).buttonColor
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color:  ColorCodes.blackColor,
                  ),
                ),*/
              ),
            );
          },
        ),
        SizedBox(width: 10),
      ],
    );

  }
 Widget _bodyweb() {
   queryData = MediaQuery.of(context);
   wid= queryData.size.width;
   maxwid=wid*0.90;
    final notificationData = Provider.of<NotificationItemsList>(context, listen: false);
    if (notificationData.notItems.length <= 0) {
      _isNotification = false;
      _isloading=false;
    } else {
      _isNotification = true;
      _isloading=false;
    }
     return !_isNotification
      ?    Flexible(
         child: SingleChildScrollView(
           child: Container(
           child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 80.0, right: 80.0),
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: new Image.asset(
                        Images.notificationImg)),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  translate('forconvience.no notification'), //"Don't have any item in the notification list",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                  },
                  child: Container(
                    width: 110.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child: Center(
                        child: Text(
                          translate('forconvience.Go to Home'),//'Go To Home',
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(color: Colors.white, fontSize: 16.0),
                        )),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(address: _address)
            ],
      ),
    ),
         ),
       )
      : Expanded(
        child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

              child: SizedBox(
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    itemCount: notificationData.notItems.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        //print date

                        if (notificationData
                            .notItems[i].notificationFor ==
                            "2") {
                          // Order and fetching order id
                          Navigator.of(context).pushNamed(
                             orderexample.routeName,
                              arguments: {
                                'orderid': notificationData
                                    .notItems[i].data,
                                'fromScreen':
                                "pushNotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id,
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "3") {
                          //Web Link
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "4") {
                          //Product with array of product id (Then have to call api)
                          Navigator.of(context).pushNamed(
                              NotProductScreen.routeName,
                              arguments: {
                                'productId': notificationData
                                    .notItems[i].data,
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id,
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "5") {
                          //Sub category with array of sub category
                          Navigator.of(context).pushNamed(NotSubcategoryScreen.routeName,
                              arguments: {
                                'subcategoryId' : notificationData.notItems[i].data,
                                'fromScreen' : "NotificationScreen",
                                'notificationId' : notificationData.notItems[i].id,
                                'notificationStatus': notificationData.notItems[i].status,

                              }
                          );
                        } else if (notificationData.notItems[i].notificationFor == "6") {
                          //redirect to app home page
                          if (notificationData.notItems[i].status == "0")
                            Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(notificationData.notItems[i].id, "1");
                          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "3") {
                          //Web Link
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "4") {
                          //Product with array of product id (Then have to call api)
                          Navigator.of(context).pushNamed(
                              NotProductScreen.routeName,
                              arguments: {
                                'productId': notificationData
                                    .notItems[i].data,
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id,
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "5") {
                          //Sub category with array of sub category
                          Navigator.of(context).pushNamed(
                              NotSubcategoryScreen.routeName,
                              arguments: {
                                'subcategoryId': notificationData
                                    .notItems[i].data,
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id,
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status
                              });
                        } else if (notificationData.notItems[i].notificationFor == "6") {
                          //redirect to app home page
                          if (notificationData.notItems[i].status == "0")
                            Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(notificationData.notItems[i].id, "1");
                          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                        } else if(notificationData.notItems[i].notificationFor == "10") {
                          Navigator.of(context).pushReplacementNamed(NotBrandScreen.routeName,
                              arguments: {
                                'brandsId' : notificationData.notItems[i].data,
                                'fromScreen' : "NotificationScreen",
                                'notificationId' : notificationData.notItems[i].id,
                                'notificationStatus': notificationData.notItems[i].status
                              }
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 8.0, top: 8.0, right: 10.0,bottom:8.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(color: Colors.white, borderRadius:BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                            border: Border.all(
                                width: 2,
                                color: Color(0xFFCAE5FC))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // CircleAvatar(
                            //     radius: 12, backgroundColor: Colors.transparent,
                            //     child: Image.asset('assets/images/icon_android.png')),
                            SizedBox(width: 5),
                            if(notificationData.notItems[i].status == "0")
                              Text(notificationData.notItems[i].message, style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            if(notificationData.notItems[i].status == "1")
                              Text(notificationData.notItems[i].message, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold,color: Colors.black),),
                            SizedBox(height: 5.0,),
                            Text(
                              notificationData
                                  .notItems[i].dateTime,
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),),
                          ],
                        ),
                      ),
                      // child: Container(
                      //   height: 80,
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   margin: EdgeInsets.fromLTRB(20, 10, 40, 5),
                      //   decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(15),
                      //           topRight: Radius.circular(15),
                      //           bottomRight: Radius.circular(15)),
                      //       border: Border.all(
                      //           width: 2,
                      //           color: Color(0xFFCAE5FC))),
                      //   child: Column(
                      //     mainAxisAlignment:
                      //         MainAxisAlignment.center,
                      //     crossAxisAlignment:
                      //         CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         notificationData.notItems[i].message,
                      //         style: TextStyle(
                      //             fontSize: 15.0,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.black),
                      //       ),
                      //       SizedBox(height: 5),
                      //       Text(
                      //         notificationData
                      //             .notItems[i].dateTime,
                      //         style: TextStyle(
                      //           fontSize: 12.0,
                      //           fontWeight: FontWeight.w500,
                      //           color: Colors.grey,
                      //         ),),
                      //         SizedBox(height: 5),
                      //         Text(
                      //           notificationData
                      //               .notItems[i].dateTime,
                      //           style: TextStyle(
                      //             fontSize: 12.0,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ),
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
    Footer(address: _address)
          ],

        )),
      );}
  Widget _bodyMobile() {
debugPrint("notification length"+notificationData.notItems.length.toString());
    return !_isNotification
        ?         Expanded(
      child: SingleChildScrollView(
        child: Container(
          // height: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100.0,
              ),
              Align(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 80.0, right: 80.0),
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: new Image.asset(
                        Images.notificationImg)),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                margin: EdgeInsets.only(left: 30.0, right: 30.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  translate('forconvience.no notification'),  //"Don't have any item in the notification list",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                },
                child: Container(
                  width: 150.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Center(
                      child: Text(
                        translate('forconvience.Go to Home'),// 'Go To Home',
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(color: Colors.white, fontSize: 16.0),
                      )),
                ),
              ),
              SizedBox(height: 20.0,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(address: _address)
            ],
          ),
        ),
      ),
    )
        : Expanded(
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                child: SizedBox(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    itemCount: notificationData.notItems.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () {
                        debugPrint("notificationData id"+notificationData.notItems[i].id.toString());
                        debugPrint("notificationData id"+notificationData.notItems[i].status.toString());
                        if (notificationData
                            .notItems[i].notificationFor ==
                            "2") {
                          debugPrint("order");
                          // Order and fetching order id
                          Navigator.of(context).pushNamed(
                              orderexample.routeName,
                              arguments: {
                                'orderid': notificationData
                                    .notItems[i].data.toString(),
                                'fromScreen':
                                "pushNotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id.toString(),
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status.toString()
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "3") {
                          //Web Link
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "4") {
                          debugPrint("notificationData id"+notificationData.notItems[i].id.toString());
                          debugPrint("notificationData id"+notificationData.notItems[i].status.toString());
                          debugPrint("notificationData id"+notificationData.notItems[i].data.toString());
                          debugPrint("notroductr");
                          //Product with array of product id (Then have to call api)
                          Navigator.of(context).pushNamed(
                              NotProductScreen.routeName,
                              arguments: {
                                'productId': notificationData
                                    .notItems[i].data.toString(),
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id.toString(),
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status.toString()
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "5") {
                          debugPrint("notificationData id"+notificationData.notItems[i].id.toString());
                          debugPrint("notificationData id"+notificationData.notItems[i].status.toString());
                          debugPrint("notsub");
                          //Sub category with array of sub category
                          Navigator.of(context).pushNamed(NotSubcategoryScreen.routeName,
                              arguments: {
                                'subcategoryId' : notificationData.notItems[i].data.toString(),
                                'fromScreen' : "NotificationScreen",
                                'notificationId' : notificationData.notItems[i].id.toString(),
                                'notificationStatus': notificationData.notItems[i].status.toString(),

                              }
                          );
                        } else if (notificationData.notItems[i].notificationFor == "6") {
                          //redirect to app home page
                          if (notificationData.notItems[i].status == "0")
                            Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(notificationData.notItems[i].id, "1");
                          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "3") {
                          //Web Link
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "4") {
                          debugPrint("notprodyuc");
                          //Product with array of product id (Then have to call api)
                          Navigator.of(context).pushNamed(
                              NotProductScreen.routeName,
                              arguments: {
                                'productId': notificationData
                                    .notItems[i].data.toString(),
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id.toString(),
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status.toString()
                              });
                        } else if (notificationData
                            .notItems[i].notificationFor ==
                            "5") {
                          debugPrint("notsub");
                          //Sub category with array of sub category
                          Navigator.of(context).pushNamed(
                              NotSubcategoryScreen.routeName,
                              arguments: {
                                'subcategoryId': notificationData
                                    .notItems[i].data.toString(),
                                'fromScreen': "NotificationScreen",
                                'notificationId':
                                notificationData.notItems[i].id.toString(),
                                'notificationStatus':
                                notificationData
                                    .notItems[i].status.toString()
                              });
                        } else if (notificationData.notItems[i].notificationFor == "6") {
                          //redirect to app home page
                          if (notificationData.notItems[i].status == "0")
                            Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(notificationData.notItems[i].id, "1");
                          Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
                        } else if(notificationData.notItems[i].notificationFor == "10") {
                          debugPrint("notbrand");
                          Navigator.of(context).pushReplacementNamed(NotBrandScreen.routeName,
                              arguments: {
                                'brandsId' : notificationData.notItems[i].data.toString(),
                                'fromScreen' : "NotificationScreen",
                                'notificationId' : notificationData.notItems[i].id.toString(),
                                'notificationStatus': notificationData.notItems[i].status.toString()
                              }
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 12.0, top: 10.0, right: 12.0,
                            bottom:8.0
                        ),
                        padding: EdgeInsets.only(left:10.0,right:10,bottom:10,top:10),
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius:BorderRadius.all(
                                Radius.circular(10),
                            /*topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomRight: Radius.circular(15)*/
                            ),
                           /* border: Border(

                              bottom: BorderSide(width: 1,
                                  color: ColorCodes.greenColor,
                              ),
                                )*/
                            border: Border.all(
                              color:notificationData.notItems[i].status == "0"? ColorCodes.greenColor:Colors.grey,
                              width: 1,
                            )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // CircleAvatar(
                            //     radius: 12, backgroundColor: Colors.transparent,
                            //     child: Image.asset('assets/images/icon_android.png')),
                            //SizedBox(height: 5),
                            SizedBox(width: 5),

                            if(notificationData.notItems[i].status == "0")
                              Text(notificationData.notItems[i].title, style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                            if(notificationData.notItems[i].status == "1")
                              Text(notificationData.notItems[i].title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,color: Colors.grey),),

                            SizedBox(height: 8),

                           /* if(notificationData.notItems[i].status == "0")
                              Text(notificationData.notItems[i].message, style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                            if(notificationData.notItems[i].status == "1")
                              Text(notificationData.notItems[i].message, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold,color: Colors.grey),),
                            SizedBox(height: 5.0,),*/
                            Text(
                              notificationData
                                  .notItems[i].message,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: notificationData.notItems[i].status == "0"?Colors.black:Colors.grey,
                              ),),
                            /*SizedBox(height: 5),
                            Divider(color: ColorCodes.greenColor,)*/

                          ],
                        ),
                      ),
                      // child: Container(
                      //   height: 80,
                      //   padding: EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   margin: EdgeInsets.fromLTRB(20, 10, 40, 5),
                      //   decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.only(
                      //           topLeft: Radius.circular(15),
                      //           topRight: Radius.circular(15),
                      //           bottomRight: Radius.circular(15)),
                      //       border: Border.all(
                      //           width: 2,
                      //           color: Color(0xFFCAE5FC))),
                      //   child: Column(
                      //     mainAxisAlignment:
                      //         MainAxisAlignment.center,
                      //     crossAxisAlignment:
                      //         CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         notificationData.notItems[i].message,
                      //         style: TextStyle(
                      //             fontSize: 15.0,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.black),
                      //       ),
                      //       SizedBox(height: 5),
                      //       Text(
                      //         notificationData
                      //             .notItems[i].dateTime,
                      //         style: TextStyle(
                      //           fontSize: 12.0,
                      //           fontWeight: FontWeight.w500,
                      //           color: Colors.grey,
                      //         ),),
                      //         SizedBox(height: 5),
                      //         Text(
                      //           notificationData
                      //               .notItems[i].dateTime,
                      //           style: TextStyle(
                      //             fontSize: 12.0,
                      //             fontWeight: FontWeight.w500,
                      //             color: Colors.grey,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(address: _address)
            ],

          )),
    );}
          
}
