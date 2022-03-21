


import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../widgets/expansion_drawer.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/ColorCodes.dart';
import '../widgets/badge.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/categoryitems.dart';
import '../providers/itemslist.dart';

import '../screens/cart_screen.dart';
import '../screens/searchitem_screen.dart';
import '../widgets/selling_items.dart';
import '../data/calculations.dart';
import 'category_screen.dart';
import '../constants/images.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ItemsScreen extends StatefulWidget {
  static const routeName = '/items-screen';
  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int startItem = 0;
  bool isLoading = false;
  var load = true;
  bool _initLoad = true;
  bool _isSubcategory = true;
  var itemslistData;
  int previndex = -1;
  var _checkitem = false;
  var currency_format = "";
  var subcategoryData;
  var subNestedcategoryData;
  ItemScrollController _scrollController;
  ItemScrollController _scrollControllerCategory;
  String subCategoryId = "";
  String subcatType = "";
  bool _isOnScroll = false;
  String maincategory = "";
  String subcatTitle="";
  bool _isMaincategoryset = false;
  SharedPreferences prefs;
  bool endOfProduct = false;
  bool _checkmembership = false;
  bool _isNested = true;
  bool _isWeb = false;
  var parentcatid;
  var subcatidinitial;
  ScrollController _controller=ScrollController();
  MediaQueryData queryData;
  double wid;
  double maxwid;
  int _nestedIndex = 0;
  bool iphonex = false;
  _displayitem(String catid, int index) {
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, String>;
    setState(() {
      endOfProduct = false;
      load = true;
      _checkitem = false;
      startItem = 0;

      final subcatId = routeArgs['subcatId'];
      final catId = routeArgs['catId'];
      subcatidinitial=routeArgs['subcatId'];
      parentcatid=routeArgs['catId'];
       Provider.of<CategoriesItemsList>(context, listen: false).fetchNestedCategory(catId.toString(), "subitemScreen").then((value) {
        setState(() {
          subNestedcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);
          //_initLoad = false;

          for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
            if (subNestedcategoryData.itemsubNested[i].catid == subcatId.toString()) {
              _nestedIndex = i;
            }
          }

          //..new subcategorynesteditems ........
          for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
            if (i != _nestedIndex) {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.blackColor;
              subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.normal;
            } else {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.indigo;
              subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.bold;

            }
          }


          for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
            if (index != i) {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.blackColor;
              //subcategoryData.itemNested[i].fontweight = FontWeight.normal;

            } else {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.indigo;
              //subcategoryData.itemNested[i].fontweight = FontWeight.bold;

              //subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.w900;
            }
          }
          for (int i = 0; i < subcategoryData.itemNested.length; i++) {
            if (index != i) {
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.normal;
            } else {
              if (routeArgs['prev'] != "category_item") {
                if (!_isMaincategoryset)
                  maincategory = subcategoryData.itemNested[i].title;
                _isNested = true;
              }
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = Theme.of(context).primaryColor;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.bold;

            }
          }

          String subcatid = subcategoryData.itemNested[index].catid;
          setState(() {
            subCategoryId = subcategoryData.itemNested[index].catid;
            subcatType = subcategoryData.itemNested[index].type.toString();
          });
          Provider.of<ItemsList>(context, listen: false)
              .fetchItems(subcatid, subcatType, startItem, "initialy")
              .then((_) {
            itemslistData = Provider.of<ItemsList>(context, listen: false);
            startItem = itemslistData.items.length;
            setState(() {
              load = false;
              if (itemslistData.items.length <= 0) {
                _checkitem = false;
              } else {
                _checkitem = true;
              }
            });
          });
        });

        });
      });

      ////neww.............

  }

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

    _scrollController = ItemScrollController();
    _scrollControllerCategory = ItemScrollController();
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        }
      } catch (e) {
      }
      int _nestedIndex = 0;
      prefs = await SharedPreferences.getInstance();
      setState(() {
        currency_format = prefs.getString("currency_format");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final subcatId = routeArgs['subcatId'];
      final catId = routeArgs['catId'];
      subcatidinitial=routeArgs['subcatId'];
      parentcatid=routeArgs['catId'];
      if (routeArgs['prev'] == "category_item") {
        maincategory = routeArgs['maincategory'];
        _isNested = false;


      }
      // await Provider.of<CategoriesItemsList>(context, listen: false).fetchNestedCategory(catId.toString(), "subitemScreen").then((value) {
      //   setState(() {
      //     subNestedcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);
      //     //_initLoad = false;
      //
      //     for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
      //       if (subNestedcategoryData.itemsubNested[i].catid == subcatId.toString()) {
      //         _nestedIndex = i;
      //       }
      //     }
      //
      //     //..new subcategorynesteditems ........
      //     for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
      //       if (i != _nestedIndex) {
      //         subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.blackColor;
      //         subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.normal;
      //       } else {
      //         subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.indigo;
      //         subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.bold;
      //
      //       }
      //     }
      //
      //
      //   });
      // });
      Provider.of<CategoriesItemsList>(context, listen: false).fetchNestedCategory(subcatId.toString(), "itemScreen").then((_) {
        setState(() {
          subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);

          if (routeArgs['prev'] != "category_item") {
            final parentId = subcategoryData
                .itemNested[subcategoryData.itemNested.length - 1].parentId;
            final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
            for (int i = 0; i < categoriesData.items.length; i++) {
              if (categoriesData.items[i].catid == parentId) {
                maincategory = categoriesData.items[i].title;
                _isMaincategoryset = true;
                _isNested = true;
              } else {
                _isMaincategoryset = false;
              }
            }
          }

          int index = 0;
          String subcatid;
          int count = 0;
          for (int i = 0; i < subcategoryData.itemNested.length; i++) {
            if (subcategoryData.itemNested[i].catid == subcatId.toString()) {
              count++;
              index = i;
              subcatid = subcategoryData.itemNested[index].catid;
              subCategoryId = subcategoryData.itemNested[index].catid;
              subcatType = subcategoryData.itemNested[index].type;

            } else {
              //subcatid = subcategoryData.itemNested[int.parse("0")].catid;
            }
          }
          if (count <= 1) {
            if (routeArgs['prev'] == "category_item")
              maincategory = routeArgs['catTitle'];
            _isNested = true;
          }
          // *//*/..new subcategorynesteditems ........
          // for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
          //   if (i != index) {
          //     subNestedcategoryData.itemsubNested[i].textcolor = Colors.black;
          //   } else {
          //     subNestedcategoryData.itemsubNested[i].textcolor = Colors.indigo;
          //   }
          // }*//*
          for (int i = 0; i < subcategoryData.itemNested.length; i++) {
            if (i != index) {
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.normal;
            } else {
              if (routeArgs['prev'] != "category_item") {
                if (!_isMaincategoryset)
                  maincategory = subcategoryData.itemNested[i].title;
                _isNested = true;
              }
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = Theme.of(context).primaryColor;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.bold;
            }
          }

          _isSubcategory = false;
          _initLoad = false;

          Provider.of<ItemsList>(context, listen: false).fetchItems(subcatid, subcatType, startItem, "initialy").then((_) {
            itemslistData = Provider.of<ItemsList>(context, listen: false);
            startItem = itemslistData.items.length;
            setState(() {
              load = false;

              if (itemslistData.items.length <= 0) {
                _checkitem = false;
              } else {
                _checkitem = true;
              }
            });
            Future.delayed(Duration.zero, () async {
              _scrollControllerCategory.jumpTo(
                index: _nestedIndex - 1,

              );
            });
            Future.delayed(Duration.zero, () async {
              _scrollController.jumpTo(
                index: index,

              );
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget itemsWidget() {
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow =  (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ? 2 : 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 360:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

    return Flexible(
      child: Column(
        children: [
          // Divider(),
          SizedBox(height: 10,),
         if(!_isWeb)
           SizedBox(
            height: 45,
            child:
            ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: subcategoryData.itemNested.length,
              itemBuilder: (_, i) => Column(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          subcatidinitial=subcategoryData.itemNested[i].catid;
                          // if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                          //   ExpansionDrawer(parentcatid,subcatidinitial);
                        });
                        _displayitem(subcategoryData.itemNested[i].catid, i);

                      },
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2.0,
                                color: subcategoryData.itemNested[i].boxsidecolor,
                              ),
                            )),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                (subcategoryData.itemNested[i].title=="All") ? translate('forconvience.All'):
                                subcategoryData.itemNested[i].title,
//                            textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: subcategoryData.itemNested[i].fontweight,
                                    color: subcategoryData.itemNested[i].textcolor),
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
          Divider(color:ColorCodes.greyColor,height:1),
         // SizedBox(height:5),
          load ?
          Center(
            child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
            ),
          )
              :
          _checkitem
              ? Flexible(
            fit: FlexFit.loose,
            child: NotificationListener<
                ScrollNotification>(
              // ignore: missing_return
                onNotification:
                    (ScrollNotification scrollInfo) {
                  if (!endOfProduct) if (!_isOnScroll &&
                      // ignore: missing_return
                      scrollInfo.metrics.pixels ==
                          scrollInfo
                              .metrics.maxScrollExtent) {
                    setState(() {
                      _isOnScroll = true;
                    });
                    Provider.of<ItemsList>(context, listen: false)
                        .fetchItems(
                        subCategoryId,
                        subcatType,
                        startItem,
                        "scrolling")
                        .then((_) {
                      setState(() {
                        //itemslistData = Provider.of<ItemsList>(context, listen: false);
                        startItem =
                            itemslistData.items.length;
                        if (prefs
                            .getBool("endOfProduct")) {
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
                  MouseRegion(
                  cursor: SystemMouseCursors.click,
                        child: GridView.builder(
                            shrinkWrap: true,
                            controller:
                            new ScrollController(
                                keepScrollOffset:
                                false),
                            itemCount:
                            itemslistData.items.length,
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
                                "item_screen",
                                itemslistData.items[index].id,
                                itemslistData.items[index].title,
                                itemslistData.items[index].imageUrl,
                                itemslistData.items[index].brand,
                                "",
                              );
                            }),
                      ),
                      if (endOfProduct)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                          ),
                          margin: EdgeInsets.only(top: 10.0),
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(top: 25.0, bottom: 25.0),
                          // *//*child: Text(
                          //   "That's all folks!",
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //   ),
                          // ),*//*
                        ),

                    ],
                  ),
                )

            ),

          )
              : Expanded(
            child: Align(
              alignment: Alignment.center,
              child: new Image.asset(
                Images.noItemImg,
                fit: BoxFit.fill,
                height: 200.0,
                width: 200.0,
//                    fit: BoxFit.cover
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
           //if(_isWeb && ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
        ],
      ),
    );
  }

  _displayCategory(String subcatId) {
    Provider.of<CategoriesItemsList>(context, listen: false).fetchNestedCategory(subcatId, "itemScreen").then((_) {
      setState(() {
        subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);
        int index = 0;
        String subcatid;
        int count = 0;
        for (int i = 0; i < subcategoryData.itemNested.length; i++) {
          if (subcategoryData.itemNested[i].catid == subcatId) {
            count++;
            index = i;
            subcatid = subcategoryData.itemNested[index].catid;
            subCategoryId = subcategoryData.itemNested[index].catid;
            subcatType = subcategoryData.itemNested[index].type;
          } else {
            //subcatid = subcategoryData.itemNested[int.parse("0")].catid;
          }
        }
        for (int i = 0; i < subcategoryData.itemNested.length; i++) {
          if (i != index) {
            subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
            subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
            subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          } else {
            subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
            subcategoryData.itemNested[i].boxsidecolor = Theme.of(context).primaryColor;
            subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          }
        }
        _isSubcategory = false;
        _initLoad = false;
        Provider.of<ItemsList>(context, listen: false).fetchItems(subcatid, subcatType, startItem, "initialy").then((_) {
          itemslistData = Provider.of<ItemsList>(context, listen: false);
          startItem = itemslistData.items.length;
          setState(() {
            load = false;
            if (itemslistData.items.length <= 0) {
              _checkitem = false;
            } else {
              _checkitem = true;
            }
          });
          Future.delayed(Duration.zero, () async {
            _scrollController.jumpTo(
              index: index,

            );
          });
        });
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    final itemslistData = Provider.of<ItemsList>(context, listen: false);
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.95;
    _buildBottomNavigationBar() {
      return ValueListenableBuilder(
        valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty) return SizedBox.shrink();

          return
          //   Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: 50.0,
          //   child: Row(
          //     mainAxisSize: MainAxisSize.max,
          //     //mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: <Widget>[
          //       Container(
          //         color: Theme.of(context).primaryColor,
          //         height: 50,
          //         width: MediaQuery.of(context).size.width * 35 / 100,
          //         child: Column(
          //           children: <Widget>[
          //             SizedBox(
          //               height: 8.0,
          //             ),
          //             _checkmembership
          //                 ? Text("Total: " +
          //                 currency_format +
          //                 (Calculations.totalMember).toString(),
          //               style: TextStyle(color: ColorCodes.whiteColor,
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16
          //               ),
          //             )
          //                 : Text("Total: " + currency_format + (Calculations.total).toString(),
          //               style: TextStyle(
          //                   color: ColorCodes.whiteColor,
          //                   fontWeight: FontWeight.bold,
          //                   fontSize: 16
          //               ),
          //             ),
          //             Text(
          //               Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
          //               style: TextStyle(
          //                   color: ColorCodes.discount,
          //                   fontWeight: FontWeight.w400,
          //                   fontSize: 14),
          //             )
          //           ],
          //         ),
          //       ),
          //       MouseRegion(
          //         cursor: SystemMouseCursors.click,
          //         child: GestureDetector(
          //             onTap: () => {
          //               setState(() {
          //                 Navigator.of(context)
          //                     .pushNamed(CartScreen.routeName);
          //               })
          //             },
          //             child:
          //             Container(
          //                 color: Theme.of(context).primaryColor,
          //                 height: 50,
          //                 width: MediaQuery.of(context).size.width * 65 / 100,
          //                 child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       SizedBox(
          //                         width: 80,
          //                       ),
          //                       Text(
          //                         translate('bottomnavigation.viewcart'),
          //                         style: TextStyle(
          //                             fontSize: 16.0,
          //                             color: ColorCodes.whiteColor,
          //                             fontWeight: FontWeight.bold),
          //                         textAlign: TextAlign.center,
          //                       ),
          //                       Icon(
          //                         Icons.arrow_right,
          //                         color: ColorCodes.whiteColor,
          //                       ),
          //                     ]))),
          //       ),
          //     ],
          //   ),
          // );
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 50.0,
              decoration:BoxDecoration(color: Theme
                  .of(context)
                  .primaryColor),
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
                                CartScreen.routeName,
                                arguments: {"prev": "category_item"});
                          })
                        },
                        child: Container(
                          //   color: Theme
                          //       .of(context)
                          //       .primaryColor,
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
                                  //    Icon(
                                  //                 Icons.arrow_right,
                                  //                 color: ColorCodes.whiteColor,
                                  //               ),
                                ]))),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      //  _checkmembership
                      //             ? Text(
                      //           "Total: " +
                      //               _currencyFormat +
                      //               (Calculations.totalMember).toString(),
                      //           style: TextStyle(color: Colors.white,
                      //               fontSize: 16
                      //           ),
                      //           )
                      //             :
                      Text(

                        " "+
                            double.parse((Calculations.total).toString()).toStringAsFixed(2)+currency_format ,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: ColorCodes
                                .whiteColor,
                            fontWeight: FontWeight
                                .bold),
                        textAlign: TextAlign.center,
                      ),


                      //  Text(
                      //                 "Saved: " +
                      //                     _currencyFormat +
                      //                     Calculations.discount.toString(),
                      //                 style: TextStyle(
                      //                     color: ColorCodes.discount,
                      //                     fontWeight: FontWeight.w400,
                      //                     fontSize: 14),
                      //               ),
                    ],
                  ),
                ],
              ),
            );
        },
      );

      // if(Calculations.itemCount > 0) {
      //   return Container(
      //     width: MediaQuery
      //         .of(context)
      //         .size
      //         .width,
      //     height: 50.0,
      //     child: Row(
      //       mainAxisSize: MainAxisSize.max,
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: <Widget>[
      //         Container(
      //           height:50,
      //           width:MediaQuery.of(context).size.width * 35/100,
      //           child: Column(
      //             children: <Widget>[
      //               SizedBox(
      //                 height: 15.0,
      //               ),
      //               _checkmembership
      //                   ?
      //               Text(currency_format + (Calculations.totalMember).toString(), style: TextStyle(color: Colors.black),)
      //                   :
      //               Text(currency_format + (Calculations.total).toString(), style: TextStyle(color: Colors.black),),
      //               Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
      //             ],
      //           ),),
      //         GestureDetector(
      //             onTap: () =>
      //             {
      //               setState(() {
      //                 Navigator.of(context).pushNamed(CartScreen.routeName);
      //               })
      //             },
      //             child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
      //                 child:Column(children:[
      //                   SizedBox(height: 17,),
      //                   Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
      //                 ]
      //                 )
      //             )
      //         ),
      //       ],
      //     ),
      //   );
      // }
    }
    Widget _appBarMobile() {
      return  AppBar(
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        title:

        Text(
        //  maincategory=="Offers"?
          translate('bottomnavigation.categories'),
              //:maincategory,
          style: TextStyle(color: ColorCodes.backbutton),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            width: 25,
            height: 25,
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
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
            width: 15,
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
                    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
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
                  // Container(
                  //   margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                  //   width: 25,
                  //   height: 25,
                  //   decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(100),
                  //       color: Theme.of(context).buttonColor),
                  //   child: Icon(
                  //     Icons.shopping_cart_outlined,
                  //     size: 18,
                  //     color:  ColorCodes.blackColor,
                  //   ),
                  // ),
                );

              int cartCount = 0;
              for (int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
                cartCount = Hive.box<Product>(productBoxName).length;//cartCount + Hive.box<Product>(productBoxName).values.elementAt(i).itemQty;
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
                    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
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
                 //  Container(
                 //    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                 //    width: 25,
                 //    height: 25,
                 //    decoration: BoxDecoration(
                 //        borderRadius: BorderRadius.circular(100),
                 //        color: Theme.of(context).buttonColor),
                 //    child: Icon(
                 //      Icons.shopping_cart_outlined,
                 //      size: 18,
                 //      color:  ColorCodes.blackColor,
                 //    ),
                 //  ),
                ),
              );
            },
          ),
          SizedBox(width: 10,)
          // Container(
          //   width: 30,
          //   height: 30,
          //   margin: EdgeInsets.only(top: 14.0, bottom: 14.0),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(100),
          //     color: Colors.white,
          //   ),
          //   child: MouseRegion(
          //     cursor: SystemMouseCursors.click,
          //     child: GestureDetector(
          //       onTap: () {
          //         Navigator.of(context).pushNamed(
          //           SearchitemScreen.routeName,
          //         );
          //       },
          //       child: Icon(
          //         Icons.search,
          //         color: ColorCodes.blackColor,
          //       ),
          //     ),
          //   ),
          // ),
          // SizedBox(width: 10),
          // Container(
          //   margin: EdgeInsets.only(top: 14.0, bottom: 14.0),
          //   child: ValueListenableBuilder(
          //     valueListenable: Hive.box<Product>(productBoxName).listenable(),
          //     builder: (context, Box<Product> box, index) {
          //       if (box.values.isEmpty)
          //         return Container(
          //           width: 30,
          //           height: 30,
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(100),
          //               color: Theme.of(context).buttonColor),
          //           child:  MouseRegion(
          //               cursor: SystemMouseCursors.click,
          //             child: GestureDetector(
          //               onTap: () {
          //                 Navigator.of(context).pushNamed(CartScreen.routeName);
          //               },
          //               child:  Image.asset(
          //               Images.cartImg,
          //               color: Colors.black,
          //             ),
          //             ),
          //           ),
          //         );
          //       int cartCount = 0;
          //       for (int i = 0;
          //       i < Hive.box<Product>(productBoxName).length;
          //       i++) {
          //         cartCount = cartCount +
          //             Hive.box<Product>(productBoxName)
          //                 .values
          //                 .elementAt(i)
          //                 .itemQty;
          //       }
          //       return Container(
          //         //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          //         child: Consumer<Calculations>(
          //           builder: (_, cart, ch) => Badge(
          //             child: ch,
          //             color: Colors.orange,
          //             value: cartCount.toString(),
          //           ),
          //           child: Container(
          //             width: 30,
          //             height: 30,
          //             //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
          //             decoration: BoxDecoration(
          //                 borderRadius: BorderRadius.circular(100),
          //                 color: Theme.of(context).buttonColor),
          //             child: GestureDetector(
          //               onTap: () {
          //                 Navigator.of(context).pushNamed(CartScreen.routeName);
          //               },
          //               child: Image.asset(
          //                 Images.cartImg,
          //                 color: Colors.black,
          //               ),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ),
          // SizedBox(width: 10),
        ],
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
    Widget _body(){
      return _initLoad
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      )
          : _isNested
          ?  Container(
        height:MediaQuery.of(context).size.height,
        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
        child: Column(
          children: [
           // Container(
           //    margin: EdgeInsets.only(left: 10, top: 10.0),
           //
           //    child: Row(
           //      children: [
           //        Column(
           //          children: [
           //            MouseRegion(
           //              cursor: SystemMouseCursors.click,
           //              child: GestureDetector(
           //                onTap: () => Navigator.of(context).pushNamed(CategoryScreen.routeName),
           //                child: Container(
           //                  width: 30.0,
           //                  height: 18.0,
           //                  margin: EdgeInsets.only(bottom: 5.0),
           //                  decoration: BoxDecoration(
           //                    borderRadius: BorderRadius.circular(2.0),
           //                    color: ColorCodes.mediumBlueColor,
           //                  ),
           //                  child: Icon(
           //                    Icons.dehaze,
           //                    color: ColorCodes.whiteColor,
           //                    size: 15.0,
           //                  ),
           //                ),
           //              ),
           //            ),
           //            Text("All categories",
           //                style: TextStyle(
           //                    color: ColorCodes.mediumBlackColor,
           //                    fontWeight: FontWeight.bold,
           //                    fontSize: 14.0)
           //            )
           //          ],
           //        ),
           //        SizedBox(
           //          width: 5,
           //        ),
           //        Flexible(
           //          child: Container(
           //            width: MediaQuery.of(context).size.width,
           //            padding: EdgeInsets.only(top: 10),
           //            height: 80,
           //            child: ScrollablePositionedList.builder(
           //              itemScrollController: _scrollControllerCategory,
           //              //shrinkWrap: true,
           //              scrollDirection: Axis.horizontal,
           //              itemCount: subNestedcategoryData.itemsubNested.length,
           //              itemBuilder: (context, i) {
           //                if (i == 0) return Container();
           //                return MouseRegion(
           //                  cursor: SystemMouseCursors.click,
           //                  child: GestureDetector(
           //                    onTap: () {
           //                      //   _displayitem(
           //                      // subcategoryData.itemNested[i].catid, i);
           //
           //                     //   _displayitem(
           //                     // subNestedcategoryData
           //                     //     .itemsubNested[i].catid,
           //                     // i);
           //                      setState(() {
           //                        _isSubcategory = true;
           //                        load = true;
           //                        for (int j = 0; j < subNestedcategoryData.itemsubNested.length; j++) {
           //                          if (subNestedcategoryData.itemsubNested[j].catid != subNestedcategoryData.itemsubNested[i].catid) {
           //                            subNestedcategoryData.itemsubNested[j].textcolor = ColorCodes.blackColor;
           //                            subNestedcategoryData.itemsubNested[j].fontweight = FontWeight.normal;
           //                          } else {
           //                            subNestedcategoryData.itemsubNested[j].textcolor = ColorCodes.indigo;
           //                            subNestedcategoryData.itemsubNested[j].fontweight = FontWeight.bold;
           //                          }
           //                        }
           //                        subcatidinitial=subNestedcategoryData.itemsubNested[i].catid;
           //                       // ExpansionDrawer(parentcatid,subcatidinitial);
           //                      });
           //
           //
           //                      _displayCategory(subNestedcategoryData.itemsubNested[i].catid);
           //
           //                    },
           //                    child: Container(
           //                        margin: EdgeInsets.all(5),
           //                        padding: EdgeInsets.symmetric(
           //                            horizontal: 5),
           //                        height: 70,
           //                        child: Column(
           //                          children: [
           //                            CachedNetworkImage(
           //                              imageUrl: subNestedcategoryData.itemsubNested[i].imageUrl,
           //                              placeholder: (context, url) => Image.asset(Images.defaultCategoryImg),
           //                              height: 30,
           //                              width: 40,
           //                              fit: BoxFit.cover,
           //                            ),
           //                            Text(
           //                              subNestedcategoryData.itemsubNested[i].title,
           //                              style: TextStyle(
           //                                  color: subNestedcategoryData.itemsubNested[i].textcolor,
           //                                  fontWeight: subNestedcategoryData.itemsubNested[i].fontweight,
           //                                  fontSize: 12),
           //                            ),
           //                          ],
           //                        )),
           //                  ),
           //                );
           //              },
           //            ),
           //          ),
           //        )
           //      ],
           //    ),
           //  ),
           // Divider(),
          //   Container(
          //       padding: EdgeInsets.all(10),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(itemslistData.items.length.toString() + ' Results'),
          //           Row(
          //             children: [
          //               Text("Filter",
          //                   style: TextStyle(color: ColorCodes.mediumBlackColor, fontSize: 14.0)),
          //               Container(
          //                   height: 15.0,
          //                   child: VerticalDivider(color: ColorCodes.dividerColor)
          //               ),
          //               Text("Sort",
          //                   style: TextStyle(
          //                       color: ColorCodes.mediumBlackColor,
          //                       fontSize: 14.0)),
          //               SizedBox(
          //                 width: 10.0,
          //               ),
          //               Image.asset(
          //                 Images.sortImg,
          //                 width: 22,
          //                 height: 16.0,
          //               ),
          //               SizedBox(width: 10),
          //             ],
          //           ),
          //         ],
          //       )),
            _isSubcategory ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            ) :
            itemsWidget(),
            //SizedBox(height: 10,),
           // if(_isWeb) Footer(address: prefs.getString("restaurant_address")),
          ],
        ),
      )
          :  Container(
        height:MediaQuery.of(context).size.height,
        child: Column(
          children: [
           //  Container(
           //    margin: EdgeInsets.all(10),
           //    child: Row(
           //      mainAxisAlignment: MainAxisAlignment.spaceBetween,
           //      children: [
           //        Column(
           //          children: [
           //            MouseRegion(
           //              cursor: SystemMouseCursors.click,
           //              child: GestureDetector(
           //                onTap: () => Navigator.of(context)
           //                    .pushNamed(CategoryScreen.routeName),
           //                child: Container(
           //                  width: 30.0,
           //                  height: 18.0,
           //                  decoration: BoxDecoration(
           //                    borderRadius: BorderRadius.circular(2.0),
           //                    color: ColorCodes.mediumBlueColor,
           //                  ),
           //                  child: Icon(
           //                    Icons.dehaze,
           //                    color: ColorCodes.whiteColor,
           //                    size: 15.0,
           //                  ),
           //                ),
           //              ),
           //            ),
           //            SizedBox(
           //              height: 5,
           //            ),
           //            Text("All categories",
           //                style: TextStyle(
           //                    color: ColorCodes.mediumBlackColor,
           //                    fontWeight: FontWeight.bold,
           //                    fontSize: 14.0))
           //          ],
           //        ),
           //        Row(
           //          children: [
           //            Text("Filter",
           //                style: TextStyle(
           //                    color: ColorCodes.mediumBlackColor,
           //                    fontSize: 14.0)),
           //            Container(
           //                height: 15.0,
           //                child: VerticalDivider(color: ColorCodes.dividerColor)),
           //            Text("Sort",
           //                style: TextStyle(color: ColorCodes.mediumBlackColor, fontSize: 14.0)),
           //            SizedBox(
           //              width: 10.0,
           //            ),
           //            Image.asset(
           //              Images.sortImg,
           //              width: 22,
           //              height: 16.0,
           //            ),
           //            SizedBox(width: 10),
           //          ],
           //        ),
           //      ],
           //    ),
           //  ),
            itemsWidget(),
            //SizedBox(height: 10,),
            //if(_isWeb) Footer(address: prefs.getString("restaurant_address")),
          ],
        ),
      );

    }

    _bodyweb(){
      return
        SingleChildScrollView(
        child:
        Column(
          children: [
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            Container(
              constraints: BoxConstraints(maxWidth: maxwid),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                    ExpansionDrawer(parentcatid,subcatidinitial),
                    SizedBox(width: 15,),
                    Flexible(
                        child:
                        _body()
                    ),
                  ],
                ),
            ),
              // ),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
          ],
        )
      );
    }

    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?_appBarMobile():null,
      backgroundColor: ColorCodes.whiteColor,
      body: (_isWeb )?
          _bodyweb():
          _body(),
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() :
      Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),

      ),
    );
  }


}





//webb...........................



/*
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../widgets/expansion_drawer.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../constants/ColorCodes.dart';
import '../widgets/badge.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/categoryitems.dart';
import '../providers/itemslist.dart';

import '../screens/cart_screen.dart';
import '../screens/searchitem_screen.dart';
import '../widgets/selling_items.dart';
import '../data/calculations.dart';
import 'category_screen.dart';
import '../constants/images.dart';

class ItemsScreen extends StatefulWidget {
  static const routeName = '/items-screen';
  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int startItem = 0;
  bool isLoading = false;
  var load = true;
  bool _initLoad = true;
  bool _isSubcategory = true;
  var itemslistData;
  int previndex = -1;
  var _checkitem = false;
  var currency_format = "";
  var subcategoryData;
  var subNestedcategoryData;
  ItemScrollController _scrollController;
  ItemScrollController _scrollControllerCategory;
  String subCategoryId = "";
  String subcatType = "";
  bool _isOnScroll = false;
  String maincategory = "";
  String subcatTitle="";
  bool _isMaincategoryset = false;
  SharedPreferences prefs;
  bool endOfProduct = false;
  bool _checkmembership = false;
  bool _isNested = true;
  bool _isWeb = false;
  var parentcatid;
  var subcatidinitial;
  ScrollController _controller=ScrollController();
  MediaQueryData queryData;
  double wid;
  double maxwid;

  _displayitem(String catid, int index) {
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, String>;
    setState(() {
      endOfProduct = false;
      load = true;
      _checkitem = false;
      startItem = 0;
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final subcatId = routeArgs['subcatId'];
      final catId = routeArgs['catId'];
      subcatidinitial=routeArgs['subcatId'];
      parentcatid=routeArgs['catId'];
      if (routeArgs['prev'] == "category_item") {
        maincategory = routeArgs['maincategory'];
        _isNested = false;


      }
      int _nestedIndex = 0;
      Provider.of<CategoriesItemsList>(context,listen: false).fetchNestedCategory(catId.toString(), "subitemScreen").then((value) {
        setState(() {
          subNestedcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);
          //_initLoad = false;

          for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
            if (subNestedcategoryData.itemsubNested[i].catid == subcatId.toString()) {
              _nestedIndex = i;
            }
          }

          //..new subcategorynesteditems ........
          for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
            if (i != _nestedIndex) {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.blackColor;
              subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.normal;
            } else {
              subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.indigo;
              subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.bold;

            }
          }


        });
      });
      ////neww.............
      for (int i = 0; i < subNestedcategoryData.itemsubNested.length; i++) {
        if (index != i) {
          subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.blackColor;
          //subcategoryData.itemNested[i].fontweight = FontWeight.normal;

        } else {
          subNestedcategoryData.itemsubNested[i].textcolor = ColorCodes.indigo;
          //subcategoryData.itemNested[i].fontweight = FontWeight.bold;

          //subNestedcategoryData.itemsubNested[i].fontweight = FontWeight.w900;
        }
      }
      for (int i = 0; i < subcategoryData.itemNested.length; i++) {
        if (index != i) {
          subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
          subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
          subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          subcategoryData.itemNested[i].fontweight = FontWeight.normal;
        } else {
          if (routeArgs['prev'] != "category_item") {
            if (!_isMaincategoryset)
              maincategory = subcategoryData.itemNested[i].title;
            _isNested = true;
          }
          subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
          subcategoryData.itemNested[i].boxsidecolor = ColorCodes.blackColor;
          subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          subcategoryData.itemNested[i].fontweight = FontWeight.bold;

        }
      }

      String subcatid = subcategoryData.itemNested[index].catid;
      setState(() {
        subCategoryId = subcategoryData.itemNested[index].catid;
        subcatType = subcategoryData.itemNested[index].type.toString();
      });
      Provider.of<ItemsList>(context,listen: false)
          .fetchItems(subcatid, subcatType, startItem, "initialy")
          .then((_) {
        itemslistData = Provider.of<ItemsList>(context,listen: false);
        startItem = itemslistData.items.length;
        setState(() {
          load = false;
          if (itemslistData.items.length <= 0) {
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

    _scrollController = ItemScrollController();
    _scrollControllerCategory = ItemScrollController();
    Future.delayed(Duration.zero, () async {
      int _nestedIndex = 0;
      prefs = await SharedPreferences.getInstance();
      setState(() {
        currency_format = prefs.getString("currency_format");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      final subcatId = routeArgs['subcatId'];
      final catId = routeArgs['catId'];
      subcatidinitial=routeArgs['subcatId'];
      parentcatid=routeArgs['catId'];
      if (routeArgs['prev'] == "category_item") {
        maincategory = routeArgs['maincategory'];
        _isNested = false;


      }

      Provider.of<CategoriesItemsList>(context,listen: false).fetchNestedCategory(subcatId.toString(), "itemScreen").then((_) {
        setState(() {
          subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);

          if (routeArgs['prev'] != "category_item") {
            final parentId = subcategoryData
                .itemNested[subcategoryData.itemNested.length - 1].parentId;
            final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
            for (int i = 0; i < categoriesData.items.length; i++) {
              if (categoriesData.items[i].catid == parentId) {
                maincategory = categoriesData.items[i].title;
                _isMaincategoryset = true;
                _isNested = true;
              } else {
                _isMaincategoryset = false;
              }
            }
          }

          int index = 0;
          String subcatid;
          int count = 0;
          for (int i = 0; i < subcategoryData.itemNested.length; i++) {
            if (subcategoryData.itemNested[i].catid == subcatId.toString()) {
              count++;
              index = i;
              subcatid = subcategoryData.itemNested[index].catid;
              subCategoryId = subcategoryData.itemNested[index].catid;
              subcatType = subcategoryData.itemNested[index].type;

            } else {
              //subcatid = subcategoryData.itemNested[int.parse("0")].catid;
            }
          }
          if (count <= 1) {
            if (routeArgs['prev'] == "category_item")
              maincategory = routeArgs['catTitle'];
            _isNested = true;
          }

          for (int i = 0; i < subcategoryData.itemNested.length; i++) {
            if (i != index) {
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.normal;
            } else {
              if (routeArgs['prev'] != "category_item") {
                if (!_isMaincategoryset)
                  maincategory = subcategoryData.itemNested[i].title;
                _isNested = true;
              }
              subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
              subcategoryData.itemNested[i].boxsidecolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
              subcategoryData.itemNested[i].fontweight = FontWeight.bold;
            }
          }

          _isSubcategory = false;
          _initLoad = false;

          Provider.of<ItemsList>(context,listen: false).fetchItems(subcatid, subcatType, startItem, "initialy").then((_) {
            itemslistData = Provider.of<ItemsList>(context,listen: false);
            startItem = itemslistData.items.length;
            setState(() {
              load = false;

              if (itemslistData.items.length <= 0) {
                _checkitem = false;
              } else {
                _checkitem = true;
              }
            });
            Future.delayed(Duration.zero, () async {
              _scrollControllerCategory.jumpTo(
                index: _nestedIndex - 1,

              );
            });
            Future.delayed(Duration.zero, () async {
              _scrollController.jumpTo(
                index: index,

              );
            });
          });
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget itemsWidget() {
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow =  (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ? 2 : 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 4;
    } else if (deviceWidth > 768) {
      widgetsInRow = 3;
    }
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 360:
    (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;

    return Flexible(
      child: Column(
        children: [
          Divider(),
          SizedBox(
            height: 60,
            child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: subcategoryData.itemNested.length,
              itemBuilder: (_, i) => Column(
                children: [
                  SizedBox(
                    width: 10.0,
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          subcatidinitial=subcategoryData.itemNested[i].catid;
                          // if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                          //   ExpansionDrawer(parentcatid,subcatidinitial);
                        });
                        _displayitem(subcategoryData.itemNested[i].catid, i);

                      },
                      child: Container(
                        height: 40,
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2.0,
                                color: subcategoryData.itemNested[i].boxsidecolor,
                              ),
                            )),
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 5.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                subcategoryData.itemNested[i].title,
//                            textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: subcategoryData.itemNested[i].fontweight,
                                    color: subcategoryData.itemNested[i].textcolor),
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
          load ?
          Center(
            child: CircularProgressIndicator(),
          )
              :
          _checkitem
              ? Flexible(
            fit: FlexFit.loose,
            child: NotificationListener<
                ScrollNotification>(
              // ignore: missing_return
                onNotification:
                    (ScrollNotification scrollInfo) {
                  if (!endOfProduct) if (!_isOnScroll &&
                      // ignore: missing_return
                      scrollInfo.metrics.pixels ==
                          scrollInfo
                              .metrics.maxScrollExtent) {
                    setState(() {
                      _isOnScroll = true;
                    });
                    Provider.of<ItemsList>(context,listen: false)
                        .fetchItems(
                        subCategoryId,
                        subcatType,
                        startItem,
                        "scrolling")
                        .then((_) {
                      setState(() {
                        //itemslistData = Provider.of<ItemsList>(context);
                        startItem =
                            itemslistData.items.length;
                        if (prefs
                            .getBool("endOfProduct")) {
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
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GridView.builder(
                            shrinkWrap: true,
                            controller:
                            new ScrollController(
                                keepScrollOffset:
                                false),
                            itemCount:
                            itemslistData.items.length,
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
                                "item_screen",
                                itemslistData.items[index].id,
                                itemslistData.items[index].title,
                                itemslistData.items[index].imageUrl,
                                itemslistData.items[index].brand,
                                "",
                              );
                            }),
                      ),
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
            child: Align(
              alignment: Alignment.center,
              child: new Image.asset(
                Images.noItemImg,
                fit: BoxFit.fill,
                height: 200.0,
                width: 200.0,
//                    fit: BoxFit.cover
              ),
            ),
          ),
          if(!_isWeb)Container(
            height: _isOnScroll ? 50 : 0,
            child: Center(
              child: new CircularProgressIndicator(),
            ),
          ),
          //if(_isWeb && ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
        ],
      ),
    );
  }

  _displayCategory(String subcatId) {
    Provider.of<CategoriesItemsList>(context,listen: false).fetchNestedCategory(subcatId, "itemScreen").then((_) {
      setState(() {
        subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);
        int index = 0;
        String subcatid;
        int count = 0;
        for (int i = 0; i < subcategoryData.itemNested.length; i++) {
          if (subcategoryData.itemNested[i].catid == subcatId) {
            count++;
            index = i;
            subcatid = subcategoryData.itemNested[index].catid;
            subCategoryId = subcategoryData.itemNested[index].catid;
            subcatType = subcategoryData.itemNested[index].type;
          } else {
            //subcatid = subcategoryData.itemNested[int.parse("0")].catid;
          }
        }
        for (int i = 0; i < subcategoryData.itemNested.length; i++) {
          if (i != index) {
            subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
            subcategoryData.itemNested[i].boxsidecolor = Colors.transparent;
            subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          } else {
            subcategoryData.itemNested[i].boxbackcolor = Colors.transparent;
            subcategoryData.itemNested[i].boxsidecolor = ColorCodes.blackColor;
            subcategoryData.itemNested[i].textcolor = ColorCodes.blackColor;
          }
        }
        _isSubcategory = false;
        _initLoad = false;
        Provider.of<ItemsList>(context,listen: false).fetchItems(subcatid, subcatType, startItem, "initialy").then((_) {
          itemslistData = Provider.of<ItemsList>(context,listen: false);
          startItem = itemslistData.items.length;
          setState(() {
            load = false;
            if (itemslistData.items.length <= 0) {
              _checkitem = false;
            } else {
              _checkitem = true;
            }
          });
          Future.delayed(Duration.zero, () async {
            _scrollController.jumpTo(
              index: index,
              /*duration: Duration(seconds: 1)*/
            );
          });
        });
      });
    });
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    final itemslistData = Provider.of<ItemsList>(context,listen: false);
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
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
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  color: Theme.of(context).primaryColor,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 35 / 100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      _checkmembership
                          ? Text("Total: " +
                          currency_format +
                          (Calculations.totalMember).toString(),
                        style: TextStyle(color: ColorCodes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      )
                          : Text("Total: " + currency_format + (Calculations.total).toString(),
                        style: TextStyle(
                            color: ColorCodes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      Text(
                        Calculations.itemCount.toString() + " item",
                        style: TextStyle(
                            color: ColorCodes.discount,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      )
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {
                        setState(() {
                          Navigator.of(context)
                              .pushNamed(CartScreen.routeName);
                        })
                      },
                      child: Container(
                          color: Theme.of(context).primaryColor,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 65 / 100,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                ),
                                Text(
                                  'VIEW CART',
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
                              ]))),
                ),
              ],
            ),
          );
        },
      );

      /*if(Calculations.itemCount > 0) {
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
                    Text(currency_format + (Calculations.totalMember).toString(), style: TextStyle(color: Colors.black),)
                        :
                    Text(currency_format + (Calculations.total).toString(), style: TextStyle(color: Colors.black),),
                    Text(Calculations.itemCount.toString() + " item", style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
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
                        Text('VIEW CART', style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      ]
                      )
                  )
              ),
            ],
          ),
        );
      }*/
    }
    Widget _appBarMobile() {
      return  AppBar(
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        title:

        Text(
          //  maincategory=="Offers"?
          translate('bottomnavigation.categories'),
          //:maincategory,
          style: TextStyle(color: ColorCodes.backbutton),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          Container(
            width: 25,
            height: 25,
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
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
            width: 15,
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
                    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
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

                );

              int cartCount = 0;
              for (int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
                cartCount = Hive.box<Product>(productBoxName).length;//cartCount + Hive.box<Product>(productBoxName).values.elementAt(i).itemQty;
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
                    margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
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

                ),
              );
            },
          ),
          SizedBox(width: 10,)

        ],
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
    Widget _body(){
      return _initLoad
          ? Center(
        child: CircularProgressIndicator(),
      )
          : _isNested
          ?  Container(
        height:MediaQuery.of(context).size.height,
        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
        child: Column(
          children: [

            Divider(),
            Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(itemslistData.items.length.toString() + ' Results'),
                    Row(
                      children: [

                        Container(
                            height: 15.0,
                            child: VerticalDivider(color: ColorCodes.dividerColor)
                        ),

                        SizedBox(
                          width: 10.0,
                        ),

                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                )),
            _isSubcategory ? Center(
              child: CircularProgressIndicator(),
            ) :
            itemsWidget(),
            SizedBox(height: 10,),
            // if(_isWeb) Footer(address: prefs.getString("restaurant_address")),
          ],
        ),
      )
          :  Container(
        height:MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [

                      SizedBox(
                        width: 10.0,
                      ),

                      SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            itemsWidget(),
            SizedBox(height: 10,),
            //if(_isWeb) Footer(address: prefs.getString("restaurant_address")),
          ],
        ),
      );

    }

    _bodyweb(){
      return
        SingleChildScrollView(
            child:
            Column(
              children: [
                if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                  Header(false),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.95),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
                        ExpansionDrawer(parentcatid,subcatidinitial),
                      SizedBox(width: 15,),
                      Flexible(
                          child:
                          _body()
                      ),
                    ],
                  ),
                ),
                // ),
                if (_isWeb) Footer(address: prefs.getString("restaurant_address")),
              ],
            )
        );
    }

    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context) ?_appBarMobile():null,
      backgroundColor: ColorCodes.whiteColor,
      body: (_isWeb )?
      _bodyweb():
      _body(),
      bottomNavigationBar:  _isWeb ? SizedBox.shrink() :_buildBottomNavigationBar(),
    );
  }


}*/



