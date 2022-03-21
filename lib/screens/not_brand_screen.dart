import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../screens/searchitem_screen.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/IConstants.dart';
import '../providers/addressitems.dart';
import '../providers/branditems.dart';
import '../screens/cart_screen.dart';
import '../providers/notificationitems.dart';
import '../widgets/selling_items.dart';
import '../screens/home_screen.dart';
import '../constants/ColorCodes.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import '../constants/images.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../providers/carouselitems.dart';
import '../main.dart';
class NotBrandScreen extends StatefulWidget {
  static const routeName = '/not-brand-screen';
  @override
  _NotBrandScreenState createState() => _NotBrandScreenState();
}

class _NotBrandScreenState extends State<NotBrandScreen> {
  bool _isLoading = true;
  var itemslistData;
  bool _isInit = true;
  var _currencyFormat = "";
  bool _checkmembership = false;
  var brandsData;
  ItemScrollController _scrollController;
  int startItem = 0;
  bool isLoading = false;

  var load = true;
  var brandslistData;
  int previndex = -1;
  var _checkitem = false;

  bool endOfProduct = false;
  bool _isOnScroll = false;
  String brandId = "";
  SharedPreferences prefs;
  var currency_format = "";
  bool _isNotification = true;
  bool _isWeb =false;

  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<BrandItemsList>(context, listen: false).GetRestaurant().then((value) async {
        prefs = await SharedPreferences.getInstance();
        _currencyFormat = prefs.getString("currency_format");
      });
      Provider.of<AddressItemsList>(context, listen: false).fetchAddress();
      Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist();
      fetchDelivery();
    }
    _isInit = false;
  }

  @override
  void initState() {
    // TODO: implement initState

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
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final brandsId = routeArgs['brandsId'];

      if(routeArgs['fromScreen'] == "Banner"){
        Provider.of<CarouselItemsList>(context, listen: false).fetchBrandsItems(brandsId).then((_) {
          final brandsData = Provider.of<CarouselItemsList>(context, listen: false);
          setState(() {
            if (brandsData.brands.length > 0) {
              for (int i = 0; i < brandsData.brands.length; i++) {
                if (i != 0) {
                  brandsData.brands[i].boxbackcolor = ColorCodes.whiteColor;
                  brandsData.brands[i].boxsidecolor = ColorCodes.blackColor;
                  brandsData.brands[i].textcolor = ColorCodes.blackColor;
                } else {
                  brandsData.brands[i].boxbackcolor = ColorCodes.mediumBlueColor;
                  brandsData.brands[i].boxsidecolor = ColorCodes.mediumBlueColor;
                  brandsData.brands[i].textcolor = ColorCodes.whiteColor;
                }
              }
              _isLoading = false;
              Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(brandsData.brands[0].id, startItem, "initialy").then((_) {
                setState(() {
                  brandslistData = Provider.of<BrandItemsList>(context, listen: false);
                  startItem = brandslistData.branditems.length;
                  load = false;
                  if (brandslistData.branditems.length <= 0) {
                    _checkitem = false;
                  } else {
                    _checkitem = true;
                  }
                });
              });
            } else {
              _isLoading = false;
            }
          });
        });
      } else if (routeArgs['fromScreen'] == "ClickLink") {
        _isNotification  = false;
        Provider.of<NotificationItemsList>(context, listen: false)
            .updateNotificationStatus(routeArgs['notificationId'], "1");
      } else {
        _isNotification = true;
        if (routeArgs['notificationStatus'] == "0") {
          Provider.of<NotificationItemsList>(context, listen: false)
              .updateNotificationStatus(routeArgs['notificationId'], "1")
              .then((value) {
            Provider.of<NotificationItemsList>(context, listen: false)
                .fetchNotificationLogs(prefs.getString('userID'));
          });
        }
      }
      Provider.of<NotificationItemsList>(context, listen: false).fetchBrandsItems(brandsId).then((_) {
        final brandsData = Provider.of<NotificationItemsList>(context, listen: false);
        setState(() {
          if (brandsData.brands.length > 0) {
            for (int i = 0; i < brandsData.brands.length; i++) {
              if (i != 0) {
                brandsData.brands[i].boxbackcolor = ColorCodes.whiteColor;
                brandsData.brands[i].boxsidecolor = ColorCodes.blackColor;
                brandsData.brands[i].textcolor = ColorCodes.blackColor;
              } else {
                brandsData.brands[i].boxbackcolor = ColorCodes.mediumBlueColor;
                brandsData.brands[i].boxsidecolor = ColorCodes.mediumBlueColor;
                brandsData.brands[i].textcolor = ColorCodes.whiteColor;
              }
            }
            _isLoading = false;
            Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(brandsData.brands[0].id, startItem, "initialy").then((_) {
              setState(() {
                brandslistData = Provider.of<BrandItemsList>(context, listen: false);
                startItem = brandslistData.branditems.length;
                load = false;
                if (brandslistData.branditems.length <= 0) {
                  _checkitem = false;
                } else {
                  _checkitem = true;
                }
              });
            });
          } else {
            _isLoading = false;
          }
        });
      }); // only create the future once.
    });
    super.initState();
  }

  Future<void> fetchDelivery() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/details';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final dataJson =
        json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);

        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) => data.add(
            dataJsondecode[index] as Map<String,
                dynamic>)); //store each category values in data list


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

  _displayitem(String brandid, int index) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    setState(() {
      brandId = brandid;
      endOfProduct = false;
      load = true;
      _checkitem = false;
      startItem = 0;
      if(routeArgs['fromScreen'] == "Banner"){
        brandsData = Provider.of<CarouselItemsList>(context, listen: false);
      } else {
        brandsData = Provider.of<NotificationItemsList>(context, listen: false);
      }
      for (int i = 0; i < brandsData.brands.length; i++) {
        if (index != i) {
          brandsData.brands[i].boxbackcolor = ColorCodes.whiteColor;
          brandsData.brands[i].boxsidecolor = ColorCodes.blackColor;
          brandsData.brands[i].textcolor = ColorCodes.blackColor;
        } else {
          brandsData.brands[i].boxbackcolor = ColorCodes.mediumBlueColor;
          brandsData.brands[i].boxsidecolor = ColorCodes.mediumBlueColor;
          brandsData.brands[i].textcolor = ColorCodes.whiteColor;
        }
      }

      Provider.of<BrandItemsList>(context, listen: false)
          .fetchBrandItems(brandId, startItem, "initialy")
          .then((_) {
        brandslistData = Provider.of<BrandItemsList>(context, listen: false);
        startItem = brandslistData.branditems.length;
        setState(() {
          load = false;
          if (brandslistData.branditems.length <= 0) {
            _checkitem = false;
          } else {
            _checkitem = true;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

    if(routeArgs['fromScreen'] == "Banner"){
      brandsData = Provider.of<CarouselItemsList>(context, listen: false);
    } else {
      brandsData = Provider.of<NotificationItemsList>(context, listen: false);
    }

    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;

    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    // double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 350:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 150;

    _buildBottomNavigationBar() {
      return ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context, Box<Product> box, index) {
            return SingleChildScrollView(
              child: Container(
            //    height:(box.values.isEmpty) ?60:100,
                color: Colors.white,
                child:


                Column(
                  children: [
                    Container(
                      color: ColorCodes.greenColor,
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box<Product>(productBoxName)
                            .listenable(),
                        builder: (context, Box<Product> box, index) {
                          if (box.values.isEmpty) return SizedBox.shrink();

                          return Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: 50.0,
                            child: Row(
                              // mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  child: GestureDetector(
                                      onTap: () =>
                                      {
                                        setState(() {
                                          Navigator.of(context).pushNamed(
                                              CartScreen.routeName);
                                        })
                                      },
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
                                              ]))),
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
                                          double.parse((Calculations.total).toString()).toStringAsFixed(2)+_currencyFormat ,
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
                          );
                        },
                      ),
                    ),


                  ],
                ),
              ),
            );
          }
      );
    }
    gradientappbarmobile() {
      return  AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 8,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
            onPressed: () {
              Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
              return Future.value(false);
            }
        ),
        titleSpacing: 0,
        title: Text("Brands",),
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
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                SearchitemScreen.routeName,
              );
            },
            child: Icon(
              Icons.search,
              size: 22.0,
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
        ],
      );
    }

    return Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context) ?
        gradientappbarmobile() : null,
      backgroundColor: ColorCodes.whiteColor,
        body: Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            SizedBox(
              height: 15.0,
            ),
            if(!_isLoading)
              Container(
                constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                child: SizedBox(
                  height: 60,
                  child: ScrollablePositionedList.builder(
                    itemScrollController: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: brandsData.brands.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        SizedBox(
                          width: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            _displayitem(brandsData.brands[i].id, i);
                          },
                          child: Container(
                            height: 40,
//                      width:150,
                           // constraints: BoxConstraints(maxWidth: 850),
                            margin: EdgeInsets.only(left: 5.0, right: 5.0),
                            decoration: BoxDecoration(
                                color: brandsData.brands[i].boxbackcolor,
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border(
                                  top: BorderSide(
                                    width: 1.0,
                                    color: brandsData.brands[i].boxsidecolor,
                                  ),
                                  bottom: BorderSide(
                                    width: 1.0,
                                    color: brandsData.brands[i].boxsidecolor,
                                  ),
                                  left: BorderSide(
                                    width: 1.0,
                                    color: brandsData.brands[i].boxsidecolor,
                                  ),
                                  right: BorderSide(
                                    width: 1.0,
                                    color: brandsData.brands[i].boxsidecolor,
                                  ),
                                )),
                            child: Padding(
                              padding: EdgeInsets.only(left: 20.0, right: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    brandsData.brands[i].title,
//                            textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: brandsData.brands[i].textcolor),
                                  ),
                                ],
                              ),
                            ),
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
            load
                ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            )
                : _checkitem
                ? Flexible(
              fit: FlexFit.loose,
              child: NotificationListener<ScrollNotification>(
                // ignore: missing_return
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!endOfProduct) if (!_isOnScroll &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      setState(() {
                        _isOnScroll = true;
                      });
                      Provider.of<BrandItemsList>(context, listen: false)
                          .fetchBrandItems(
                          brandId, startItem, "scrolling")
                          .then((_) {
                        setState(() {
                          //itemslistData = Provider.of<ItemsList>(context, listen: false);
                          startItem = brandslistData.branditems.length;
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
                     /* setState(() {
                        isLoading = true;
                      });*/
                    }
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                          child: Column(
                            children: <Widget>[
                              GridView.builder(
                                  shrinkWrap: true,
                                  controller: new ScrollController(
                                      keepScrollOffset: false),
                                  itemCount:
                                  brandslistData.branditems.length,
                                  gridDelegate:
                                  new SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widgetsInRow,
                                    crossAxisSpacing: 3,
                                    childAspectRatio: aspectRatio,
                                    mainAxisSpacing: 3,
                                  ),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return SellingItems(
                                      "brands_screen",
                                      brandslistData.branditems[index].id,
                                      brandslistData
                                          .branditems[index].title,
                                      brandslistData
                                          .branditems[index].imageUrl,
                                      brandslistData
                                          .branditems[index].brand,
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
                                  padding: EdgeInsets.only(
                                      top: 25.0, bottom: 25.0),
                                 /* child: Text(
                                    "That's all folks!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),*/
                                ),


                            ],
                          ),
                        ),
                        if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address"))
                      ],
                    ),

                  )),
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
                child: new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            ),

          ],
        ),
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: _buildBottomNavigationBar(),

      ),
      );
  }

  @override
  bool get wantKeepAlive => true;
}
