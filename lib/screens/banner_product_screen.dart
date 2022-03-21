import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/ColorCodes.dart';
import '../providers/notificationitems.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../screens/cart_screen.dart';
import '../widgets/selling_items.dart';
import '../data/calculations.dart';
import '../providers/itemslist.dart';
import '../constants/images.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'home_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';


class BannerProductScreen extends StatefulWidget {
  static const routeName = '/banner-product-screen';
  @override
  _BannerProductScreenState createState() => _BannerProductScreenState();
}

class _BannerProductScreenState extends State<BannerProductScreen> {
  bool _isLoading = true;
  var itemslistData;
  var _currencyFormat = "";
  bool _checkmembership = false;
  bool _checkitem = false;
  bool endOfProduct = false;
  bool _isOnScroll = false;
  SharedPreferences prefs;
  int startItem = 0;
  bool _isWeb =false;
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  @override
  void initState() {

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
      prefs = await SharedPreferences.getInstance();
      try {
        setState(() {
          _currencyFormat = prefs.getString("currency_format");
          if (prefs.getString("membership") == "1") {
            _checkmembership = true;
          } else {
            _checkmembership = false;
          }
        });
      }
      catch(e){}
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final type = routeArgs['type'];
      final id = routeArgs['id'];


      if(type == "category") {
        Provider.of<ItemsList>(context, listen: false).fetchItems(id, "0", startItem, "initialy").then((_) {
          itemslistData = Provider.of<ItemsList>(context, listen: false);
          setState(() {
            startItem = itemslistData.items.length;
            _isLoading = false;

            if (itemslistData.items.length <= 0) {
              _checkitem = false;
            } else {
              _checkitem = true;
            }
          });
        });
      } else {
        Provider.of<NotificationItemsList>(context, listen: false).fetchProductItems(id).then((_) {
          setState(() {
            itemslistData = Provider.of<NotificationItemsList>(context, listen: false);
            _isLoading = false;
            if (itemslistData.items.length <= 0) {
              _checkitem = false;
            } else {
              _checkitem = true;
            }
          });
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final type = routeArgs['type'];
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.95;
    if (deviceWidth > 1200) {
      widgetsInRow = 5;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 290:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;
    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, size:20,color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text("Products",),
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
    _buildBottomNavigationBar() {
      return  Container(
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
                                translate('bottomnavigation.viewcart'), //translate('bottomnavigation.viewcart'),
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


      /*ValueListenableBuilder(
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
                      Text((Calculations.totalMember).toString()+_currencyFormat , style: TextStyle(color: Colors.black),)
                          :
                      Text( (Calculations.total).toString()+_currencyFormat , style: TextStyle(color: Colors.black),),
                      Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
                    ],
                  ),),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () =>
                      {
                        setState(() {
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        })
                      },
                      child: Container(
                          color: Theme.of(context).primaryColor,
                          height:50,width:MediaQuery.of(context).size.width*65/100,
                          child:Column(children:[
                            SizedBox(height: 17,),
                            Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                          ]
                          )
                      )
                  ),
                ),
              ],
            ),
          );
        },
      );*/
    }
   /*_body(){
     return  _isLoading
         ? Center(
               child: CircularProgressIndicator(
                 valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
               ),
          )
         :Expanded(
           child: SingleChildScrollView(
             child: Column(
               children: [
                 Container(
                   constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                   child: Column(
                     children: [
                       GridView.builder(
                           shrinkWrap: true,
                       itemCount: itemslistData.items.length,
                       physics: ScrollPhysics(),
                       gridDelegate:
                       new SliverGridDelegateWithFixedCrossAxisCount(
                         crossAxisCount: widgetsInRow,
                         crossAxisSpacing: 3,
                         childAspectRatio: aspectRatio,
                         mainAxisSpacing: 3,
                       ),
                       itemBuilder: (BuildContext context, int index) {
                         return SellingItems(
                           (type == "category") ? "item_screen" : "not_product_screen",
                           itemslistData.items[index].id,
                           itemslistData.items[index].title,
                           itemslistData.items[index].imageUrl,
                           itemslistData.items[index].brand,
                           "",
                         );
                       }),

                     ],
                   ),
                 ),
                 if(_isWeb) Footer(address: prefs.getString("restaurant_address"))
               ],
             ),
           ),
         );
   }*/


    _body(){
      return  _isLoading ?
      Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        ),
      ):
          
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                child: Column(
                  children: [
                    GridView.builder(
                        shrinkWrap: true,
                        itemCount: itemslistData.items.length,
                        physics: ScrollPhysics(),
                        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: widgetsInRow,
                          crossAxisSpacing: 3,
                          childAspectRatio: aspectRatio,
                          mainAxisSpacing: 3,
                        ),
                        itemBuilder: (BuildContext context, int index) {
                          return SellingItems(
                            (type == "category") ? "item_screen" : "not_product_screen",
                            itemslistData.items[index].id,
                            itemslistData.items[index].title,
                            itemslistData.items[index].imageUrl,
                            itemslistData.items[index].brand,
                            "",
                          );
                        }),

                  ],
                ),
              ),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address"))
            ],
          ),
        ),
      );
    }
/*    Widget _itemDisplay1() {
      return GridView.builder(
          itemCount: itemslistData.items.length,
        physics: ScrollPhysics(),
          gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widgetsInRow,
            crossAxisSpacing: 3,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return SellingItems(
              (type == "category") ? "item_screen" : "not_product_screen",
              itemslistData.items[index].id,
              itemslistData.items[index].title,
              itemslistData.items[index].imageUrl,
              itemslistData.items[index].brand,
              "",
            );
          });
    }*/


/*    Widget _itemDisplay1() {
      return GridView.builder(
          itemCount: itemslistData.items.length,
        physics: ScrollPhysics(),
          gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widgetsInRow,
            crossAxisSpacing: 3,
            childAspectRatio: aspectRatio,
            mainAxisSpacing: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return SellingItems(
              (type == "category") ? "item_screen" : "not_product_screen",
              itemslistData.items[index].id,
              itemslistData.items[index].title,
              itemslistData.items[index].imageUrl,
              itemslistData.items[index].brand,
              "",
            );
          });
    }*/


    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: ColorCodes.whiteColor,

      body:

      Column(
        children: [
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _isLoading
              ? Expanded(
                child: Center(
            child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
            ),
          ),
              )
              :
          (type == "category") ? Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _checkitem
                    ? Flexible(
                  fit: FlexFit.loose,
                  child: NotificationListener<
                      ScrollNotification>(
                    // ignore: missing_return
                      onNotification:
                      // ignore: missing_return
                          (ScrollNotification scrollInfo) {
                        if (!endOfProduct) if (!_isOnScroll &&
                            // ignore: missing_return
                            scrollInfo.metrics.pixels ==
                                scrollInfo
                                    .metrics.maxScrollExtent) {
                          setState(() {
                            _isOnScroll = true;
                          });
                          Provider.of<ItemsList>(context, listen: false).fetchItems(routeArgs['id'], "0", startItem, "scrolling").then((_) {
                            setState(() {
                              //itemslistData = Provider.of<ItemsList>(context, listen: false);
                              startItem = itemslistData.items.length;
                              if (prefs.getBool("endOfProduct")) {
                                _isOnScroll = false;
                                endOfProduct = true;
                              } else {
                                _isOnScroll = false;
                                endOfProduct = false;
                              }
                            });
                          });
                        }
                      },

                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            GridView.builder(
                                shrinkWrap: true,
                                controller: new ScrollController(keepScrollOffset:false),
                                itemCount: itemslistData.items.length,
                                gridDelegate:
                                new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widgetsInRow,
                                  crossAxisSpacing: 3,
                                  childAspectRatio: aspectRatio,
                                  mainAxisSpacing: 3,
                                ),
                                itemBuilder:
                                    (BuildContext context,
                                    int index) {
                                  return SellingItems(
                                    (type == "category") ? "item_screen" : "not_product_screen",
                                    itemslistData.items[index].id,
                                    itemslistData.items[index].title,
                                    itemslistData.items[index].imageUrl,
                                    itemslistData.items[index].brand,
                                    "",
                                  );
                                }),
                            if (endOfProduct)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                ),
                                margin: EdgeInsets.only(top: 10.0),
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                                /*child: Text(
                                  "That's all folks!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),*/
                              ),

                          ],
                        ),
                      )

                  ),

                )
                    : Flexible(
                  fit: FlexFit.loose,
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: new Image.asset(
                              Images.noItemImg, fit: BoxFit.fill,
                              height: 200.0,
                              width: 200.0,
//                    fit: BoxFit.cover
                            ),
                          ),
                          if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address"))
                        ],
                      ),
                    ),
                  ),
                ),
                if(!_isWeb)Container(
                  height: _isOnScroll ? 50 : 0,
                  child: Center(
                    child: new CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                  ),
                ),
              ],
            ),
          ) : _checkitem ?
          _body()
              :
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: new Image.asset(
                        Images.noItemImg, fit: BoxFit.fill,
                        height: 200.0,
                        width: 200.0,
//                    fit: BoxFit.cover
                      ),
                    ),
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address:prefs.getString("restaurant_address"))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

     /* Column(
        children: [
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _isLoading
              ? Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
            ),
          )
              :
          (type == "category") ? Column(
            children: [
              _checkitem
                  ? Flexible(
                fit: FlexFit.loose,
                child: NotificationListener<
                    ScrollNotification>(
                  // ignore: missing_return
                    onNotification:
                        // ignore: missing_return
                        (ScrollNotification scrollInfo) {
                      if (!endOfProduct) if (!_isOnScroll &&
                          // ignore: missing_return
                          scrollInfo.metrics.pixels ==
                              scrollInfo
                                  .metrics.maxScrollExtent) {
                        setState(() {
                          _isOnScroll = true;
                        });
                        Provider.of<ItemsList>(context, listen: false).fetchItems(routeArgs['id'], "0", startItem, "scrolling").then((_) {
                          setState(() {
                            //itemslistData = Provider.of<ItemsList>(context, listen: false);
                            startItem = itemslistData.items.length;
                            if (prefs.getBool("endOfProduct")) {
                              _isOnScroll = false;
                              endOfProduct = true;
                            } else {
                              _isOnScroll = false;
                              endOfProduct = false;
                            }
                          });
                        });

                        // start loading data
                        *//*setState(() {
                          isLoading = true;
                        });*//*
                      }
                    },

                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          GridView.builder(
                              shrinkWrap: true,
                              controller: new ScrollController(keepScrollOffset: false),
                              itemCount: itemslistData.items.length,
                              gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: widgetsInRow,
                                crossAxisSpacing: 3,
                                childAspectRatio: aspectRatio,
                                mainAxisSpacing: 3,
                              ),
                              itemBuilder:
                                  (BuildContext context,
                                  int index) {
                                return SellingItems(
                                  (type == "category") ? "item_screen" : "not_product_screen",
                                  itemslistData.items[index].id,
                                  itemslistData.items[index].title,
                                  itemslistData.items[index].imageUrl,
                                  itemslistData.items[index].brand,
                                  "",
                                );
                              }),
                          if (endOfProduct)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black12,
                              ),
                              margin: EdgeInsets.only(top: 10.0),
                              width: MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                              child: Text(
                                "That's all folks!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),

                        ],
                      ),
                    )

                ),

              )
                  : Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: new Image.asset(
                            Images.noItemImg, fit: BoxFit.fill,
                            height: 200.0,
                            width: 200.0,
//                    fit: BoxFit.cover
                          ),
                        ),
                        if(_isWeb) Footer(address: prefs.getString("restaurant_address"))
                      ],
                    ),
                  ),
                ),
              ),
              if(!_isWeb)Container(
                height: _isOnScroll ? 50 : 0,
                child: Center(
                  child: new CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                  ),
                ),
              ),
            ],
          ) : _checkitem ?
          _body()
              :
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: new Image.asset(
                        Images.noItemImg, fit: BoxFit.fill,
                        height: 200.0,
                        width: 200.0,
//                    fit: BoxFit.cover
                      ),
                    ),
                    if(_isWeb) Footer(address: prefs.getString("restaurant_address"))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),*/
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),

      ),
    );
  }
}