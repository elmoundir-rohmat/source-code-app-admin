import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/ColorCodes.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../data/calculations.dart';

import '../providers/branditems.dart';
import '../screens/cart_screen.dart';
import '../screens/searchitem_screen.dart';
import '../widgets/selling_items.dart';
import '../constants/images.dart';

class BrandsScreen extends StatefulWidget {
  static const routeName = '/brands-screen';
  @override
  _BrandsScreenState createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<BrandsScreen> {
  int startItem = 0;
  bool isLoading = false;
  var _address = "";
  var load = true;
  var brandslistData;
  int previndex = -1;
  var _checkitem = false;
  var _currencyFormat = "";
  bool _checkmembership = false;
  ItemScrollController _scrollController;
  bool endOfProduct = false;
  bool _isOnScroll = false;
  String brandId = "";
  SharedPreferences prefs;
  var brandsData;
  bool _isWeb = false;

  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  _displayitem(String brandid, int index) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    setState(() {
      brandId = brandid;
      endOfProduct = false;
      load = true;
      _checkitem = false;
      startItem = 0;
      for (int i = 0; i < brandsData.items.length; i++) {
        if (index != i) {
          brandsData.items[i].boxbackcolor = Theme.of(context).buttonColor;
          brandsData.items[i].boxsidecolor =
              Theme.of(context).textSelectionTheme.selectionColor;
          brandsData.items[i].textcolor =
              Theme.of(context).textSelectionTheme.selectionColor;
        } else {
          brandsData.items[i].boxbackcolor = Theme.of(context).accentColor;
          brandsData.items[i].boxsidecolor = Theme.of(context).accentColor;
          brandsData.items[i].textcolor = Theme.of(context).buttonColor;
        }
      }

      Provider.of<BrandItemsList>(context, listen: false)
          .fetchBrandItems(brandId, startItem, "initialy")
          .then((_) {
        brandsData = Provider.of<BrandItemsList>(context, listen: false);
        startItem = brandsData.branditems.length;
        setState(() {
          load = false;
          if (brandsData.branditems.length <= 0) {
            _checkitem = false;
          } else {
            _checkitem = true;
          }
        });
      });
    });
  }

  @override
  void initState() {
    _scrollController = ItemScrollController();
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
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, String>;
      final indexvalue = routeArgs['indexvalue'];

      brandsData = Provider.of<BrandItemsList>(context, listen: false);
      for (int i = 0; i < brandsData.items.length; i++) {
        if (int.parse(indexvalue) != i) {
          brandsData.items[i].boxbackcolor = Theme.of(context).buttonColor;
          brandsData.items[i].boxsidecolor =
              Theme.of(context).textSelectionTheme.selectionColor;
          brandsData.items[i].textcolor =
              Theme.of(context).textSelectionTheme.selectionColor;
        } else {
          brandsData.items[i].boxbackcolor = Theme.of(context).accentColor;
          brandsData.items[i].boxsidecolor = Theme.of(context).accentColor;
          brandsData.items[i].textcolor = Theme.of(context).buttonColor;
        }
      }
      setState(() {
        brandId = routeArgs['brandId'];
      });

      Provider.of<BrandItemsList>(context, listen: false)
          .fetchBrandItems(brandId, startItem, "initialy")
          .then((_) {
        load = false;
        brandslistData = Provider.of<BrandItemsList>(context, listen: false);
        startItem = brandslistData.branditems.length;
        if (brandslistData.branditems.length <= 0) {
          setState(() {
            _checkitem = false;
          });
        } else {
          setState(() {
            _checkitem = true;
          });
        }
        Future.delayed(Duration.zero, () async {
          _scrollController.jumpTo(
            index: int.parse(indexvalue), /*duration: Duration(seconds: 1)*/
          );
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    brandsData = Provider.of<BrandItemsList>(context, listen: false);

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
                  height:50,
                  width:MediaQuery.of(context).size.width * 35/100,
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      /*SizedBox(
                        height: 15.0,
                      ),*/
                      _checkmembership
                          ?
                      Text('Total: ' + (Calculations.totalMember).toString() + _currencyFormat, style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),)
                          :
                      Text('Total: '  + (Calculations.total).toString()+ _currencyFormat, style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.bold),),
                      Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.green,fontWeight: FontWeight.w400,fontSize: 9),)
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
                      child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
                          child:Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children:[
                            SizedBox(height: 17,),
                            Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                            Icon(
                              Icons.arrow_right,
                              color: ColorCodes.whiteColor,
                            ),
                          ]
                          )

                      )
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return DefaultTabController(
      length: brandsData.items.length,
      child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context) ?_appBarMobile():null,
        body:
          Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(true),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 60,
              child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: brandsData.items.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          _displayitem(brandsData.items[i].id, i);
                        },
                        child: Container(
                          height: 40,
//                      width:150,
                          margin: EdgeInsets.only(left: 5.0, right: 5.0),
                          decoration: BoxDecoration(
                              color: brandsData.items[i].boxbackcolor,
                              borderRadius: BorderRadius.circular(3.0),
                              border: Border(
                                top: BorderSide(
                                  width: 1.0,
                                  color: brandsData.items[i].boxsidecolor,
                                ),
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: brandsData.items[i].boxsidecolor,
                                ),
                                left: BorderSide(
                                  width: 1.0,
                                  color: brandsData.items[i].boxsidecolor,
                                ),
                                right: BorderSide(
                                  width: 1.0,
                                  color: brandsData.items[i].boxsidecolor,
                                ),
                              )),
                          child: Padding(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  brandsData.items[i].title,
//                            textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: brandsData.items[i].textcolor),
                                ),
                              ],
                            ),
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

          _body(),
             //

          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
          child:_buildBottomNavigationBar(),

        ),
      ),
    );
  }
  _body(){
    return _isWeb ? _bodyweb() :
    _bodyMobile();
  }
  Widget _bodyweb(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 350:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 135;
    // return 
        return _checkitem
        ? Expanded(
      // fit: FlexFit.loose,
      child: SingleChildScrollView(
        child: NotificationListener<ScrollNotification>(
          // ignore: missing_return
            onNotification: (ScrollNotification scrollInfo) {
              if (!endOfProduct) if (!_isOnScroll &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                setState(() {
                  _isOnScroll = true;
                });
                Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(
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
                setState(() {
                  isLoading = true;
                });
              }
            },
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GridView.builder(
                      shrinkWrap: true,
                      controller: new ScrollController(
                          keepScrollOffset: true),
                      itemCount:
                      brandslistData.branditems.length,
                      gridDelegate:
                      new SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        crossAxisSpacing: 3,
                        childAspectRatio: aspectRatio,
                        mainAxisSpacing: 3,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return SellingItems(
                          "brands_screen",
                          brandslistData.branditems[index].id,
                          brandslistData.branditems[index].title,
                          brandslistData.branditems[index].imageUrl,
                          brandslistData.branditems[index].brand,
                          "",
                        );
                      }),
                  if (endOfProduct)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                      ),
                      margin: EdgeInsets.only(top: 10.0),
                      // width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          top: 25.0, bottom: 25.0),
                      /*child: Text(
                        "That's all folks!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),*/
                    ),
                  if(endOfProduct)
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
                ],
              ),
            )),
      ),
    )
        : Expanded(
        child:SingleChildScrollView(
          child:Column(
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
              SizedBox(height: 10,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
            ],
          ) ,
        )
    );
    Container(
      height: _isOnScroll ? 50 : 0,
      child: Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }
  Widget _bodyMobile(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 1;
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio = (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 350:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
   return load
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
             Provider.of<BrandItemsList>(context, listen: false).fetchBrandItems(
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
             setState(() {
               isLoading = true;
             });
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
                         itemBuilder: (BuildContext context, int index) {
                           return SellingItems(
                             "brands_screen",
                             brandslistData.branditems[index].id,
                             brandslistData.branditems[index].title,
                             brandslistData.branditems[index].imageUrl,
                             brandslistData.branditems[index].brand,
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
               if(endOfProduct)
                 if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),

             ],
           ),
         )),
   )
       : Expanded(
       child:SingleChildScrollView(
        child:Column(
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
           SizedBox(height: 10,),
         ],
       ) ,
     )


   );
    Container(
    height: _isOnScroll ? 50 : 0,
    child: Center(
    child: new CircularProgressIndicator(),
    ),
    );
  }
  Widget _appBarMobile() {
    return  AppBar(
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Text("Brands"),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),

      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  ColorCodes.whiteColor,
                  ColorCodes.whiteColor,
                ])
        ),
      ),
    );
  }
  @override
  bool get wantKeepAlive => true; // ** and here
}
