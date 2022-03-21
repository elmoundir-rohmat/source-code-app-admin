
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/branditems.dart';
import '../widgets/selling_items.dart';
import '../screens/cart_screen.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ShoppinglistitemsScreen extends StatefulWidget {
  static const routeName = '/shoppinglistitems-screen';

  @override
  ShoppinglistitemsScreenState createState() => ShoppinglistitemsScreenState();
}

class ShoppinglistitemsScreenState extends State<ShoppinglistitemsScreen> {
  var _currencyFormat = "";
  bool _checkmembership = false;
  bool _isLoading = true;
  SharedPreferences prefs;
  bool _isWeb = false;
  String shoppinglistname="";
  String shoppinglistid="";
  ScrollController controller;
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
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _isLoading = false;
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, String>;

    shoppinglistid = routeArgs['shoppinglistid'];
    shoppinglistname = routeArgs['shoppinglistname'];


    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      body: _body(),
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),
      ),
    );
  }

  _buildBottomNavigationBar() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Product>(productBoxName).listenable(),
      builder: (context, Box<Product> box, index) {
        if (box.values.isEmpty) return SizedBox.shrink();
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 35 / 100,
                decoration:
                BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 8.0,
                    ),
                    _checkmembership
                        ? Text(
                      "Total: "  +
                          (Calculations.totalMember).toString()+
                          _currencyFormat,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )
                        : Text(
                      "Total: " +
                          (Calculations.total).toString() +
                          _currencyFormat,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    /*Text(
                        Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
                        style: TextStyle( final itemsData = Provider.of<BrandItemsList>(
      context,
      listen: false,
    ).findByIdlistitem(shoppinglistid);

                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 9),
                      ),*/
                    Text(
                      "Saved: "  +
                          Calculations.discount.toString()+
                          _currencyFormat,
                      style: TextStyle(
                          color: ColorCodes.discount,
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => {
                  setState(() {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  })
                },
                child: Container(
                   // color: Theme.of(context).primaryColor,
                    height: 50,
                    width: MediaQuery.of(context).size.width * 65 / 100,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                          ),
                          Text(
                            translate('bottomnavigation.viewcart'),
                            style: TextStyle(
                                fontSize: 16.0,
                                color: ColorCodes.whiteColor,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: ColorCodes.whiteColor,
                          ),
                        ])),
              ),
            ],
          ),
        );
      },
    );
  }


  _body(){
    final itemsData = Provider.of<BrandItemsList>(
      context,
      listen: false,
    ).findByIdlistitem(shoppinglistid);

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow =(_isWeb && !ResponsiveLayout.isSmallScreen(context))?2:1;

    if (deviceWidth > 1200) {
      widgetsInRow = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?4:1;
    }
    else if (deviceWidth > 768) {
      widgetsInRow = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?3:1;
    }http://localhost:35513/#/shoppinglist-screen
    double aspectRatio =(_isWeb && !ResponsiveLayout.isSmallScreen(context))?
     (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 400:
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    return  SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            Expanded(
                child: _isWeb?
                SingleChildScrollView(
                    child:
                    Column(
                      children: [
                        Align(
                           alignment: Alignment.center,
                            child: Container(
                              constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                              height: _isWeb?MediaQuery.of(context).size.height*0.60
                                :MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            color: Color(0xfff5f5f5),
                            child: new GridView.builder(
                                itemCount: itemsData.length,
                                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widgetsInRow,
                                  crossAxisSpacing: 2,
                                  childAspectRatio: aspectRatio,
                                  mainAxisSpacing: 2,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return SellingItems(
                                    "shoppinglistitem_screen",
                                    itemsData[index].itemid,
                                    itemsData[index].itemname,
                                    itemsData[index].imageurl,
                                    itemsData[index].brand,
                                    shoppinglistid,
                                  );
                                }),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        //footer
                        if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
                      ],
                    )
                ) : Container(
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xfff5f5f5),
                  child: new GridView.builder(
                      itemCount: itemsData.length,
                      gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        crossAxisSpacing: 2,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return SellingItems(
                          "shoppinglistitem_screen",
                          itemsData[index].itemid,
                          itemsData[index].itemname,
                          itemsData[index].imageurl,
                          itemsData[index].brand,
                          shoppinglistid,
                        );
                      }),
                ),
            ),
          ],));
  }

  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white),onPressed: ()=>Navigator.of(context).pop(),),
      title: Text(shoppinglistname,
              ),

      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme.of(context).accentColor,
                  Theme.of(context).primaryColor
                ]
            )
        ),
      ),
    );
  }



}