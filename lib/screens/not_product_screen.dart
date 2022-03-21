import 'dart:convert';
import 'dart:io';
import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/IConstants.dart';
import '../providers/addressitems.dart';
import '../providers/branditems.dart';
import '../screens/cart_screen.dart';
import '../providers/notificationitems.dart';
import '../widgets/selling_items.dart';
import '../screens/home_screen.dart';
import '../data/calculations.dart';
import 'package:flutter_translate/flutter_translate.dart';

class NotProductScreen extends StatefulWidget {
  static const routeName = '/not-product-screen';
  @override
  _NotProductScreenState createState() => _NotProductScreenState();
}

class _NotProductScreenState extends State<NotProductScreen> {
  bool _isLoading = true;
  var itemslistData;
  bool _isInit = true;
  var _currencyFormat = "";
  bool _checkmembership = false;
  bool iphonex = false;
  bool _isWeb = false;

  @override
  void initState() {
    super.initState();
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currencyFormat=prefs.getString("currency_format");
      setState(() {
        if(prefs.getString("membership") == "1"){
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final productId = routeArgs['productId'];

      if(routeArgs['fromScreen'] == "ClickLink") {
        Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" );
      } else {
        if(routeArgs['notificationStatus'] == "0"){
          Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" ).then((value){
            Provider.of<NotificationItemsList>(context,listen: false).fetchNotificationLogs(
                prefs.getString('userID'));
          });
        }
      }
      Provider.of<NotificationItemsList>(context,listen: false).fetchProductItems(productId).then((_) {
        setState(() {
          itemslistData = Provider.of<NotificationItemsList>(context,listen: false);
          if (itemslistData.items.length <= 0) {
            _isLoading = false;
          } else {
            _isLoading = false;
          }
        });

      }); // only create the future once.
    });
  }

  @override
  didChangeDependencies() {
    if (_isInit){
      setState(() {
        _isLoading = true;
      });

      // Provider.of<AddressItemsList>(context,listen: false).fetchAddress();
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist();
      Provider.of<BrandItemsList>(context,listen: false).GetRestaurant().then((value) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {

          _currencyFormat = prefs.getString("currency_format");
        });

      });
      //fetchDelivery();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> fetchDelivery () async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/details';
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );

      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final dataJson = json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);

        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) =>
            data.add(dataJsondecode[index] as Map<String, dynamic>)
        ); //store each category values in data list

        SharedPreferences prefs = await SharedPreferences.getInstance();


        for (int i = 0; i < data.length; i++){
          prefs.setString("resId", data[i]['id'].toString());
          prefs.setString("minAmount", data[i]['minOrderAmount'].toString());
          prefs.setString("deliveryCharge", data[i]['deliveryCharge'].toString());
        }
      }

    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 3;
    } else if (deviceWidth > 768) {
      widgetsInRow = 2;
    }
    double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

    _buildBottomNavigationBar() {
      return Container(
        color: ColorCodes.greenColor,
        child: ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName)
              .listenable(),
          builder: (context, Box<Product> box, index) {
            if (box.values.isEmpty) return SizedBox.shrink();

            return
              GestureDetector(
                onTap: () =>
                {
                  setState(() {
                    Navigator.of(context).pushNamed(
                        CartScreen.routeName);
                  })
                },
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 50.0,
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    // mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text(
                          Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
                          style: TextStyle(
                              fontSize: 16.0,
                              color: ColorCodes
                                  .whiteColor,
                              fontWeight: FontWeight
                                  .bold),
                        ),
                      ),
                      Center(
                        child: Container(
                          /* color: Theme
                                .of(context)
                                .primaryColor,*/
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center,
                                children: [
                                  Text(
                                    translate('bottomnavigation.viewcart'),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: ColorCodes
                                            .whiteColor,
                                        fontWeight: FontWeight
                                            .bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  /*   Icon(
                                                  Icons.arrow_right,
                                                  color: ColorCodes.whiteColor,
                                                ),*/
                                ])),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          /* _checkmembership
                                      ? Text(
                                    "Total: " +
                                        _currencyFormat +
                                        (Calculations.totalMember).toString(),
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 16
                                    ),
                                    )
                                      : */
                          Text(
                            /* "Total: " +*/
                            " "+
                                double.parse((Calculations.total).toString()).toStringAsFixed(2)+ _currencyFormat ,
                            style: TextStyle(
                                fontSize: 16.0,
                                color: ColorCodes
                                    .whiteColor,
                                fontWeight: FontWeight
                                    .bold),
                            textAlign: TextAlign.center,
                          ),


                          /*  Text(
                                          "Saved: " +
                                              _currencyFormat +
                                              Calculations.discount.toString(),
                                          style: TextStyle(
                                              color: ColorCodes.discount,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14),
                                        ),*/
                        ],
                      ),
                    ],
                  ),
                ),
              );
          },
        ),
      );
      /* ValueListenableBuilder(
        valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty)
            return SizedBox.shrink();

          return Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 50.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  height:50,
                  width:MediaQuery.of(context).size.width * 35/100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      _checkmembership
                          ?
                      Text( (Calculations.totalMember).toString()+_currencyFormat , style: TextStyle(color: Colors.black),)
                          :
                      Text((Calculations.total).toString()+_currencyFormat , style: TextStyle(color: Colors.black),),
                      Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
                    ],
                  ),),
                GestureDetector(
                    onTap: () =>
                    {
                      setState(() {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      })
                    },
                    child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
                        child:Column(children:[
                          SizedBox(height: 17,),
                          Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                        ]
                        )
                    )
                ),
              ],
            ),
          );
        },
      );*/
    }

    bool _isNotification = false;
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    if(routeArgs['fromScreen'] == "ClickLink") {
      _isNotification = false;
      Provider.of<NotificationItemsList>(context,listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" );
    } else {
      _isNotification = true;
    }

    return _isNotification ?
    Scaffold(
      backgroundColor: ColorCodes.whiteColor,
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [ ColorCodes.whiteColor,
              ColorCodes.whiteColor,]
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          translate('forconvience.offer'),//'Offers',
          style: TextStyle(color: ColorCodes.backbutton),
        ),
      ),

      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      )
          :
      GridView.builder(
          itemCount: itemslistData.items.length,
          gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widgetsInRow,
            crossAxisSpacing: 3,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return SellingItems(
              "not_product_screen",
              itemslistData.items[index].id,
              itemslistData.items[index].title,
              itemslistData.items[index].imageUrl,
              itemslistData.items[index].brand,
              "",
            );
          }),
      bottomNavigationBar:  Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),

      ),
    )
        :
    WillPopScope(
      onWillPop: () { // this is the block you need
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/home-screen', (Route<dynamic> route) => false);
        //Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: ColorCodes.whiteColor,
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [ ColorCodes.whiteColor,
                ColorCodes.whiteColor,]
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false);
               // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              }),
          title: Text(
            translate('forconvience.offer'), //'Offers',
            style: TextStyle(color: ColorCodes.backbutton),
          ),
          /*title: Text(
              "Offers",
            ),*/
        ),

        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :

        GridView.builder(
            itemCount: itemslistData.items.length,
            gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widgetsInRow,
              crossAxisSpacing: 3,
              childAspectRatio: aspectRatio,
              mainAxisSpacing: 3,
            ),

            itemBuilder: (BuildContext context, int index) {
              return SellingItems(
                "not_product_screen",
                itemslistData.items[index].id,
                itemslistData.items[index].title,
                itemslistData.items[index].imageUrl,
                itemslistData.items[index].brand,
                "",
              );
            }),
        bottomNavigationBar:  Padding(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
          child: _buildBottomNavigationBar(),
        ),
      ),

    );
  }
}