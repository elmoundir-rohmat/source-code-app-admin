import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../screens/home_screen.dart';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/ColorCodes.dart';
import 'package:share/share.dart';
import '../data/hiveDB.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/badge_discount.dart';
import '../widgets/footer.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../screens/singleproductimage_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/membership_screen.dart';
import '../screens/searchitem_screen.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../providers/branditems.dart';
import '../constants/IConstants.dart';
import '../widgets/badge_ofstock.dart';
import '../data/calculations.dart';
import '../widgets/badge.dart';
import '../widgets/items.dart';
import '../constants/images.dart';
import '../main.dart';
import 'map_screen.dart';
import '../widgets/header.dart';

class SingleproductScreen extends StatefulWidget {
  static const routeName = '/singleproduct-screen';

  @override
  _SingleproductScreenState createState() => _SingleproductScreenState();
}

class _SingleproductScreenState extends State<SingleproductScreen>
    with TickerProviderStateMixin {
  Box<Product> productBox;
  var _currencyFormat = "";
  bool _isLoading = true;
  var singleitemData;
  var singleitemvar;
  var multiimage;
  bool _isWeb = false;
  bool _checkmembership = false;
  bool membershipdisplay = true;
  var _checkmargin = true;
  var margins;
  bool _isStock = false;
  SharedPreferences prefs;
  var shoplistData;
  String dropdownValue = 'One';

  String varmemberprice;
  String varprice;
  String varmrp;
  String varid;
  String varname;
  String varstock;
  String varminitem;
  String varmaxitem;
  int varLoyalty;
  bool discountDisplay;
  bool memberpriceDisplay;
  Color varcolor;
  bool _isDelivering = false;
  String itemname = "";
  String itemimg = "";
  String itemdescription = "";
  String itemmanufact = "";
  bool _isdescription = false;
  bool _ismanufacturer = false;
  String _displayimg = "";
  bool _similarProduct = false;
  String _deliverlocation = "";
  final _form = GlobalKey<FormState>();
  List<String> _varMarginList = List<String>();

  List<Tab> tabList = List();
  TabController _tabController;

  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  @override
  void initState() {

    productBox = Hive.box<Product>(productBoxName);
    if (_isdescription)
      tabList.add(new Tab(
        text: 'Description',
      ));
    if (_ismanufacturer)
      tabList.add(new Tab(
        text: 'Manufacturer Details',
      ));
    _tabController = new TabController(
      vsync: this,
      length: tabList.length,
    );
//    _tabController = new TabController(vsync: this,length: 2,);
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
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist().then((value) {
        final shoplistData = Provider.of<BrandItemsList>(context, listen: false);
      });

      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
      });
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      _deliverlocation = prefs.getString("deliverylocation");
      final itemid = routeArgs['itemid'];
      await Provider.of<ItemsList>(context,listen: false).fetchSingleItems(itemid).then((_) {
        setState(() {
          Provider.of<SellingItemsList>(context,listen: false)
              .fetchNewItems(routeArgs['itemid'].toString())
              .then((_) {
            setState(() {
              _isLoading = false;
              singleitemData = Provider.of<ItemsList>(context,listen: false);
              singleitemvar =
                  Provider.of<ItemsList>(context,listen: false).findByIdsingleitems(itemid);
              varmemberprice = singleitemvar[0].varmemberprice;
              varmrp = singleitemvar[0].varmrp;
              varprice = singleitemvar[0].varprice;
              varid = singleitemvar[0].varid;
              varname = singleitemvar[0].varname;
              varstock = singleitemvar[0].varstock;
              varminitem = singleitemvar[0].varminitem;
              varmaxitem = singleitemvar[0].varmaxitem;
              varLoyalty = singleitemvar[0].varLoyalty;
              varcolor = singleitemvar[0].varcolor;
              discountDisplay = singleitemvar[0].discountDisplay;
              memberpriceDisplay = singleitemvar[0].membershipDisplay;

              if (varmemberprice == '-' || varmemberprice == "0") {
                setState(() {
                  membershipdisplay = false;
                });
              } else {
                membershipdisplay = true;
              }

              for(int i = 0; i < singleitemvar.length; i ++) {
                if (_checkmembership) {
                  if (singleitemvar[i].varmemberprice.toString() == '-' || double.parse(singleitemvar[i].varmemberprice) <= 0) {
                    if (double.parse(singleitemvar[i].varmrp) <= 0 ||
                        double.parse(singleitemvar[i].varprice) <= 0) {
                      _varMarginList.add("0");
                    } else {
                      var difference = (double.parse(singleitemvar[i].varmrp) - double.parse(singleitemvar[i].varprice));
                      var profit = difference / double.parse(singleitemvar[i].varmrp);
                      var margins;
                      margins = profit * 100;

                      //discount price rounding
                      margins = num.parse(margins.toStringAsFixed(0));
                      _varMarginList.add(margins.toString());
                    }
                  } else {
                    var difference =
                    (double.parse(singleitemvar[i].varmrp) - double.parse(singleitemvar[i].varmemberprice));
                    var profit = difference / double.parse(singleitemvar[i].varmrp);
                    var margins;
                    margins = profit * 100;

                    //discount price rounding
                    margins = num.parse(margins.toStringAsFixed(0));
                    _varMarginList.add(margins.toString());
                  }
                } else {
                  if (double.parse(singleitemvar[i].varmrp) <= 0 || double.parse(singleitemvar[i].varprice) <= 0) {
                    margins = "0";
                  } else {
                    var difference =
                    (double.parse(singleitemvar[i].varmrp) - double.parse(singleitemvar[i].varprice));
                    var profit = difference / double.parse(singleitemvar[i].varmrp);
                    var margins;
                    margins = profit * 100;

                    //discount price rounding
                    margins = num.parse(margins.toStringAsFixed(0));
                    _varMarginList.add(margins.toString());
                  }
                }
              }

              if (_checkmembership) {
                if (varmemberprice.toString() == '-' ||
                    double.parse(varmemberprice) <= 0) {
                  if (double.parse(varmrp) <= 0 ||
                      double.parse(varprice) <= 0) {
                    margins = "0";
                  } else {
                    var difference =
                    (double.parse(varmrp) - double.parse(varprice));
                    var profit = difference / double.parse(varmrp);
                    margins = profit * 100;

                    //discount price rounding
                    margins = num.parse(margins.toStringAsFixed(0));
                    margins = margins.toString();
                  }
                } else {
                  var difference =
                  (double.parse(varmrp) - double.parse(varmemberprice));
                  var profit = difference / double.parse(varmrp);
                  margins = profit * 100;

                  //discount price rounding
                  margins = num.parse(margins.toStringAsFixed(0));
                  margins = margins.toString();
                }
              } else {
                if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                  margins = "0";
                } else {
                  var difference =
                  (double.parse(varmrp) - double.parse(varprice));
                  var profit = difference / double.parse(varmrp);
                  margins = profit * 100;

                  //discount price rounding
                  margins = num.parse(margins.toStringAsFixed(0));
                  margins = margins.toString();
                }
              }

/*              if(double.parse(varprice) <= 0 || varprice.toString() == "" || double.parse(varprice) == double.parse(varmrp)){
                discountedPriceDisplay = false;
              } else {
                discountedPriceDisplay = true;
              }*/
              if (margins == "NaN") {
                _checkmargin = false;
              } else {
                if (int.parse(margins) <= 0) {
                  _checkmargin = false;
                } else {
                  _checkmargin = true;
                }
              }
              if (int.parse(varstock) <= 0) {
                _isStock = false;
              } else {
                _isStock = true;
              }

              itemname = singleitemData.singleitems[0].title;
              itemimg = singleitemData.singleitems[0].imageUrl;

              if (singleitemData.singleitems[0].description.toString() != "null" &&
                  singleitemData.singleitems[0].description.toString().length > 0) {
                itemdescription = singleitemData.singleitems[0].description;
                _isdescription = true;
              }
              if (singleitemData.singleitems[0].manufacturedesc.toString() != "null" &&
                  singleitemData.singleitems[0].manufacturedesc.toString().length > 0) {
                itemmanufact = singleitemData.singleitems[0].manufacturedesc;
                _ismanufacturer = true;
              }

              if(_isdescription)
                tabList.add(new Tab(
                  text: 'Description',
                ));
              if(_ismanufacturer)
                tabList.add(new Tab(
                  text: 'Manufacturer Details',
                ));
              _tabController = new TabController(
                vsync: this,
                length: tabList.length,
              );

              multiimage = Provider.of<ItemsList>(context,listen: false).findByIdmulti(varid);
              _displayimg = multiimage[0].imageUrl;
            });
          });
        });
      });
    });
//    _tabController = new TabController(vsync: this,length: 2,);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _getPage(Tab tab) {
    switch (tab.text) {
      case 'Description':
        return ReadMoreText(
          itemdescription,
          trimLines: 2,
          trimCollapsedText: '...Show more',
          trimExpandedText: '...Show less',
          colorClickableText: Theme
              .of(context)
              .primaryColor,
        );
      case 'Manufacturer Details':
        return ReadMoreText(
          itemmanufact,
          trimLines: 2,
          trimCollapsedText: '...Show more',
          trimExpandedText: '...Show less',
          colorClickableText: Theme
              .of(context)
              .primaryColor,
        );
    }
  }

  addListnameToSF(String value) async {
    prefs.setString('list_name', value);
  }

  _saveFormTwo() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    Navigator.of(context).pop();
    _dialogforProceesing(context, "Creating List...");

    Provider.of<BrandItemsList>(context,listen: false).CreateShoppinglist().then((_) {
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist().then((_) {
        shoplistData = Provider.of<BrandItemsList>(context, listen: false);
        Navigator.of(context).pop();
        _dialogforShoppinglistTwo(context);
      });
    });
  }

  additemtolist() {
    _dialogforProceesing(context, "Add item to list...");
    for (int i = 0; i < shoplistData.itemsshoplist.length; i++) {
      //adding item to multiple list
      if (shoplistData.itemsshoplist[i].listcheckbox) {
        for (int j = 0; j < productBox.length; j++) {
          Provider.of<BrandItemsList>(context,listen: false)
              .AdditemtoShoppinglist(
              productBox.values
                  .elementAt(j)
                  .itemId
                  .toString(),
              productBox.values
                  .elementAt(j)
                  .varId
                  .toString(),
              shoplistData.itemsshoplist[i].listid)
              .then((_) {
            if (i == (shoplistData.itemsshoplist.length - 1) &&
                j == (productBox.length - 1)) {
              Navigator.of(context).pop();

              Provider.of<BrandItemsList>(context,listen: false)
                  .fetchShoppinglist()
                  .then((_) {
                shoplistData =
                    Provider.of<BrandItemsList>(context, listen: false);
              });
              for (int i = 0; i < shoplistData.itemsshoplist.length; i++) {
                shoplistData.itemsshoplist[i].listcheckbox = false;
              }
            }
          });
        }
      }
    }
  }

  additemtolistTwo() {
    final shoplistDataTwo = Provider.of<BrandItemsList>(context, listen: false);
    _dialogforProceesing(context, "Add item to list...");
    for (int i = 0; i < shoplistDataTwo.itemsshoplist.length; i++) {
      //adding item to multiple list
      if (shoplistDataTwo.itemsshoplist[i].listcheckbox == true) {
        addtoshoppinglisttwo(i);
      }
    }
  }

  addtoshoppinglisttwo(i) async {
    final shoplistDataTwo = Provider.of<BrandItemsList>(context, listen: false);
    final routeArgs =
    ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;
    final itemid = routeArgs['itemid'];

    Product products = Product(
        itemId: int.parse(itemid),
        varId: int.parse(varid),
        varName: varname,
        varMinItem: int.parse(varminitem),
        varMaxItem: int.parse(varmaxitem),
        itemLoyalty: varLoyalty,
        varStock: int.parse(varstock),
        varMrp: double.parse(varmrp),
        itemName: itemname,
        //itemQty: _itemCount,
        itemPrice: double.parse(varprice),
        membershipPrice: varmemberprice,
        itemActualprice: double.parse(varmrp),
        itemImage: itemimg,
        membershipId: 0,
        mode: 0);

    Provider.of<BrandItemsList>(context,listen: false)
        .AdditemtoShoppinglist(products.itemId.toString(),
        products.varId.toString(), shoplistDataTwo.itemsshoplist[i].listid)
        .then((_) {
      Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist().then((_) {
        shoplistData = Provider.of<BrandItemsList>(context, listen: false);
        Navigator.of(context).pop();
      });
    });
  }

  _dialogforProceesing(BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  height: 100.0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                      ),
                      SizedBox(
                        width: 40.0,
                      ),
                      Text(text),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforCreatelistTwo(BuildContext context, shoplistData) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  // color: Theme.of(context).primaryColor,
                  height: 250.0,
                  margin: EdgeInsets.only(
                      left: 20.0, top: 10.0, right: 10.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Create shopping list',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Form(
                        key: _form,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a list name.';
                                }
                                return null; //it means user entered a valid input
                              },
                              onSaved: (value) {
                                addListnameToSF(value);
                              },
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: "Shopping list name",
                                labelStyle: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'ex: Monthly Grocery',
                                hintStyle: TextStyle(
                                    color: Colors.black12, fontSize: 10.0),
                                //prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme
                                            .of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          _saveFormTwo();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                'Create Shopping List',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme
                                    .of(context)
                                    .buttonColor),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme
                                    .of(context)
                                    .buttonColor),
                              )),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforShoppinglistTwo(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          final x = Provider.of<BrandItemsList>(context, listen: false);
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 10.0, top: 20.0, right: 10.0, bottom: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Add to list',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          child: new ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: x.itemsshoplist.length,
                            itemBuilder: (_, i) =>
                                Row(
                                  children: [
                                    Checkbox(
                                      value: x.itemsshoplist[i].listcheckbox,
                                      onChanged: (bool value) {
                                        setState(() {
                                          x.itemsshoplist[i].listcheckbox =
                                              value;
                                        });
                                      },
                                    ),
                                    Text(x.itemsshoplist[i].listname,
                                        style: TextStyle(fontSize: 18.0)),
                                  ],
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();

                            _dialogforCreatelistTwo(context, shoplistData);

                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              x.itemsshoplist[i].listcheckbox = false;
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Create New",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            bool check = false;
                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              if (x.itemsshoplist[i].listcheckbox)
                                setState(() {
                                  check = true;
                                });
                            }
                            if (check) {
                              Navigator.of(context).pop();
                              additemtolistTwo();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select atleast one list!",
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white);
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            // color: Theme.of(context).primaryColor,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  translate('forconvience.ADD'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .buttonColor,
                                    fontSize: 12,),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            for (int i = 0; i < x.itemsshoplist.length; i++) {
                              x.itemsshoplist[i].listcheckbox = false;
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            // color: Theme.of(context).primaryColor,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .buttonColor),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    final routeArgs =
    ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;
    final itemid = routeArgs['itemid'];

    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    if (sellingitemData.itemsnew.length <= 0) {
      _similarProduct = false;
    } else {
      _similarProduct = true;
    }
    addToCart(int _itemCount) async {
      Product products = Product(
          itemId: int.parse(itemid),
          varId: int.parse(varid),
          varName: varname,
          varMinItem: int.parse(varminitem),
          varMaxItem: int.parse(varmaxitem),
          itemLoyalty: varLoyalty,
          varStock: int.parse(varstock),
          varMrp: double.parse(varmrp),
          itemName: itemname,
          itemQty: _itemCount,
          itemPrice: double.parse(varprice),
          membershipPrice: varmemberprice,
          itemActualprice: double.parse(varmrp),
          itemImage: itemimg,
          membershipId: 0,
          mode: 0);

      productBox.add(products);
    }

    incrementToCart(int _itemCount) async {
      Product products = Product(
          itemId: int.parse(itemid),
          varId: int.parse(varid),
          varName: varname,
          varMinItem: int.parse(varminitem),
          varMaxItem: int.parse(varmaxitem),
          itemLoyalty: varLoyalty,
          varStock: int.parse(varstock),
          varMrp: double.parse(varmrp),
          itemName: itemname,
          itemQty: _itemCount,
          itemPrice: double.parse(varprice),
          membershipPrice: varmemberprice,
          itemActualprice: double.parse(varmrp),
          itemImage: itemimg,
          membershipId: 0,
          mode: 0);

      var items = Hive.box<Product>(productBoxName);

      for (int i = 0; i < items.length; i++) {
        if (Hive
            .box<Product>(productBoxName)
            .values
            .elementAt(i)
            .varId ==
            int.parse(varid)) {
          Hive.box<Product>(productBoxName).putAt(i, products);
        }
      }
    }

    _buildBottomNavigationBar() {
      return
        ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName).listenable(),
          builder: (context, Box<Product> box, index) {
            if (box.values.isEmpty)
             // return SizedBox.shrink();

            return Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: 50.0,
              child:   GestureDetector(
                  onTap: () =>
                  {
                   _isStock?
                  addToCart(int.parse(
                  varminitem))

            :
              Fluttertoast.showToast(
              msg:  /*"You will be notified via SMS/Push notification, when the product is available"  */
              translate('forconvience.Out of stock popup'), //"Out Of Stock",
              fontSize: 12.0,
              backgroundColor:
              Colors.black87,
              textColor: Colors.white)


                  /*  setState(() {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    })*/
                  },
                  child: Container(
                      color: _isStock?Theme.of(context).primaryColor:Colors.grey,
                      /*  height: 50,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 65 / 100,*/
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(
                              translate('forconvience.ADD TO CART'),
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: ColorCodes.whiteColor,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            /* Icon(
                            Icons.arrow_right,
                            color: ColorCodes.whiteColor,
                          ),*/
                          ]))),
            );
            return
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                color: ColorCodes.greenColor,
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
                              /*color: Theme
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
              );
          },
        );
    }

    Widget _appBar() {
      return GradientAppBar(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            ColorCodes.whiteColor,
            ColorCodes.whiteColor,
          ]
        ),
        title: Text(itemname),
        actions: <Widget>[
          Container(
            width: 35,
            height: 35,
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                Icons.search, size:22,
                color: Theme
                    .of(context)
                    .primaryColor,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            width: 35,
            height: 35,
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                if (Platform.isIOS) {
                  Share.share('Download ' +
                      IConstants.APP_NAME +
                      ' from App Store https://apps.apple.com/us/app/id1563407384');
                } else {
                  Share.share('Download ' +
                      IConstants.APP_NAME +
                      ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
                }
              },
              child: Icon(
                Icons.share_outlined,
                color: Theme
                    .of(context)
                    .primaryColor,
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
                  child: Container(
                    margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).buttonColor),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
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
                  color: Colors.green,
                  value: cartCount.toString(),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(CartScreen.routeName);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).buttonColor),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              );
            },
          ),
          /*Container(
            margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<Product>(productBoxName).listenable(),
              builder: (context, Box<Product> box, index) {
                if (box.values.isEmpty)
                  return Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme
                            .of(context)
                            .buttonColor),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(CartScreen.routeName);
                      },
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 20,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      ),
                    ),
                  );
                int cartCount = 0;
                for (int i = 0;
                i < Hive
                    .box<Product>(productBoxName)
                    .length;
                i++) {
                  cartCount = cartCount +
                      Hive
                          .box<Product>(productBoxName)
                          .values
                          .elementAt(i)
                          .itemQty;
                }
                return Container(
                  //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        Badge(
                          child: ch,
                          color: Colors.green,
                          value: cartCount.toString(),
                        ),
                    child: Container(
                      //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      width: 35,
                      height: 35,
                      //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme
                              .of(context)
                              .buttonColor),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        },
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),*/
          SizedBox(width: 10)
        ],
      );
    }

    Widget createHeaderForMobile() {
      return Container(
        height: 50,
        width: MediaQuery
            .of(context)
            .size
            .width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              ColorCodes.whiteColor,
              ColorCodes.whiteColor,
            ],
          ),
        ),
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(padding: EdgeInsets.only(left: 30)),

            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Icon(
                Icons.arrow_back_ios_outlined,
                size: 20,
                color: ColorCodes.backbutton,
              ),
              onTap: () {
                Navigator.of(context).popUntil(
                    ModalRoute.withName(HomeScreen.routeName,));
              },
            ),

            Padding(padding: EdgeInsets.only(left: 30)),

            Text(itemname, style: TextStyle(
              color:ColorCodes.backbutton,
              fontSize: 21,
              //fontWeight: FontWeight.bold,
            ),),

            Spacer(),

            Container(
              width: 25,
              height: 25,
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                  color: Theme
                      .of(context)
                      .primaryColor,
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
                    child: Container(
                      margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme.of(context).buttonColor),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
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
                    child: Container(
                      margin: EdgeInsets.only(top: 10, right: 10, bottom: 10),
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Theme.of(context).buttonColor),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            Padding(padding: EdgeInsets.only(right: 20)),
          ],
        ),
      );
    }


    Widget _responsiveAppBar() {
      if (ResponsiveLayout.isSmallScreen(context)) {
        return createHeaderForMobile();
      } else {
        return Header(false);
      }
    }



    Widget _firstHalfImage() {
      return Container(
        padding: EdgeInsets.only(left: 130, right: 130),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !_isStock
                ? Consumer<Calculations>(
              builder: (_, cart, ch) =>
                  BadgeOfStock(
                    child: ch,
                    value: margins,
                    singleproduct: true,
                    item: false,
                  ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                      SingleProductImageScreen.routeName,
                      arguments: {
                        "itemid": itemid,
                        "itemname": itemname,
                        "itemimg": itemimg,
                      });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: GFCarousel(
                    autoPlay: true,
                    viewportFraction: 1.0,
                    height: 173,
                    pagination: true,
                    passiveIndicator: Colors.white,
                    activeIndicator:
                    Theme
                        .of(context)
                        .accentColor,
                    autoPlayInterval: Duration(seconds: 8),
                    items: <Widget>[
                      for (var i = 0;
                      i < multiimage.length;
                      i++)
                        Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(
                                              5.0)),
                                      child: CachedNetworkImage(
                                          imageUrl:
                                          multiimage[i]
                                              .imageUrl,
                                          placeholder: (context,
                                              url) =>
                                              Image.asset(
                                                  Images
                                                      .defaultProductImg),
                                          fit: BoxFit.fill))),
                            );
                          },
                        )
                    ],
                  ),
                ),
              ),
            )
                : GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                    SingleProductImageScreen.routeName,
                    arguments: {
                      "itemid": itemid,
                      "itemname": itemname,
                      "itemimg": itemimg,
                    });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: GFCarousel(
                  autoPlay: true,
                  viewportFraction: 1.0,
                  height: 173,
                  pagination: true,
                  passiveIndicator: Colors.white,
                  activeIndicator:
                  Theme
                      .of(context)
                      .accentColor,
                  autoPlayInterval: Duration(seconds: 8),
                  items: <Widget>[
                    for (var i = 0; i < multiimage.length; i++)
                      Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {},
                            child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 5.0),
                                child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(
                                            5.0)),
                                    child: CachedNetworkImage(
                                      imageUrl: multiimage[i]
                                          .imageUrl,
                                      placeholder: (context,
                                          url) =>
                                          Image.asset(
                                              Images.defaultProductImg),
                                      fit: BoxFit.fill,
                                    )
                                )),
                          );
                        },
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _addButton() {
      return Container(
        //width: 500,
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.end,
          children: [
/*            SizedBox(
              height: 10,
            ),*/
            _isStock
                ? Container(
              height: 30.0,
              width: (MediaQuery.of(context).size.width / 8.5),
              child: ValueListenableBuilder(
                valueListenable:
                Hive.box<Product>(
                    productBoxName)
                    .listenable(),
                builder: (context,
                    Box<Product> box, _) {
                  if (box.values.length <= 0)
                    return GestureDetector(
                      onTap: () {
                        addToCart(int.parse(
                            varminitem));
                      },
                      child: Container(
                        height: 30.0,
                        width: (MediaQuery.of(context).size.width / 4) + 15,
                        decoration:
                        new BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius:
                            new BorderRadius
                                .only(
                              topLeft:
                              const Radius.circular(
                                  2.0),
                              topRight:
                              const Radius.circular(
                                  2.0),
                              bottomLeft:
                              const Radius.circular(
                                  2.0),
                              bottomRight:
                              const Radius.circular(
                                  2.0),
                            )),
                        child: /*Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),*/
                        Center(
                            child: Text(
                              translate('forconvience.ADD'),
                              style:
                              TextStyle(
                                color: ColorCodes.whiteColor,
                                fontSize: 12,
                              ),
                              textAlign:
                              TextAlign
                                  .center,
                            )),
                        /*Spacer(),
                            Container(
                              decoration:
                              BoxDecoration(
                                  color: Color(
                                      0xff1BA130),
                                  borderRadius:
                                  new BorderRadius.only(
                                    topLeft:
                                    const Radius.circular(2.0),
                                    bottomLeft:
                                    const Radius.circular(2.0),
                                    topRight:
                                    const Radius.circular(2.0),
                                    bottomRight:
                                    const Radius.circular(2.0),
                                  )),
                              height: 30,
                              width: 25,
                              child: Icon(
                                Icons.add,
                                size: 12,
                                color: Colors
                                    .white,
                              ),
                            ),
                          ],
                        ),*/
                      ),
                    );

                  try {
                    Product item = Hive
                        .box<
                        Product>(
                        productBoxName)
                        .values
                        .firstWhere((value) =>
                    value.varId ==
                        int.parse(varid));
                    return Container(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () async {
                              if (item.itemQty ==
                                  int.parse(
                                      varminitem)) {
                                for (int i =
                                0;
                                i <
                                    productBox
                                        .values
                                        .length;
                                i++) {
                                  if (productBox
                                      .values
                                      .elementAt(
                                      i)
                                      .varId ==
                                      int.parse(
                                          varid)) {
                                    productBox
                                        .deleteAt(
                                        i);
                                    break;
                                  }
                                }
                              } else {
                                setState(() {
                                  incrementToCart(
                                      item.itemQty -
                                          1);
                                });
                              }
                            },
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration:
                                new BoxDecoration(
                                    border: Border
                                        .all(
                                      color:
                                      Color(0xff32B847),
                                    ),
                                    borderRadius:
                                    new BorderRadius.only(
                                      bottomLeft:
                                      const Radius.circular(2.0),
                                      topLeft:
                                      const Radius.circular(2.0),
                                    )),
                                child: Center(
                                  child: Text(
                                    "-",
                                    textAlign:
                                    TextAlign
                                        .center,
                                    style:
                                    TextStyle(
                                      color: ColorCodes.whiteColor,
                                    ),
                                  ),
                                )),
                          ),
                          Expanded(
                            child: Container(
//                                            width: 40,
                                decoration:
                                BoxDecoration(
                                  color: Color(
                                      0xff32B847),
                                ),
                                height: 30,
                                child: Center(
                                  child: Text(
                                    item.itemQty
                                        .toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme
                                          .of(context)
                                          .buttonColor,
                                    ),
                                  ),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (item.itemQty <
                                  int.parse(
                                      varstock)) {
                                if (item.itemQty <
                                    int.parse(
                                        varmaxitem)) {
                                  incrementToCart(
                                      item.itemQty +
                                          1);
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                      translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                      backgroundColor:
                                      Colors
                                          .black87,
                                      textColor:
                                      Colors.white);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg:
                                    "Sorry, Out of Stock!",
                                    backgroundColor:
                                    Colors
                                        .black87,
                                    textColor:
                                    Colors
                                        .white);
                              }
                            },
                            child: Container(
                                width: 30,
                                height: 30,
                                decoration:
                                new BoxDecoration(
                                    border: Border
                                        .all(
                                      color:
                                      Color(0xff32B847),
                                    ),
                                    borderRadius:
                                    new BorderRadius.only(
                                      bottomRight:
                                      const Radius.circular(2.0),
                                      topRight:
                                      const Radius.circular(2.0),
                                    )),
                                child: Center(
                                  child: Text(
                                    "+",
                                    textAlign:
                                    TextAlign
                                        .center,
                                    style:
                                    TextStyle(
                                      color: Color(
                                          0xff32B847),
                                    ),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    return GestureDetector(
                      onTap: () {
                        addToCart(int.parse(
                            varminitem));
                      },
                      child: Container(
                        height: 30.0,
                        width: 50,
                        decoration:
                        new BoxDecoration(
                            color: Color(
                                0xff32B847),
                            borderRadius:
                            new BorderRadius
                                .only(
                              topLeft:
                              const Radius.circular(
                                  2.0),
                              topRight:
                              const Radius.circular(
                                  2.0),
                              bottomLeft:
                              const Radius.circular(
                                  2.0),
                              bottomRight:
                              const Radius.circular(
                                  2.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                           /* SizedBox(
                              width: 10,
                            ),*/
                            Center(
                                child: Text(
                                  translate('forconvience.ADD'),
                                  style:
                                  TextStyle(
                                    color: Theme
                                        .of(
                                        context)
                                        .buttonColor,
                                    fontSize: 12,

                                  ),
                                  textAlign:
                                  TextAlign
                                      .center,
                                )),
                            Spacer(),
                            Container(
                              decoration:
                              BoxDecoration(
                                  color: Color(
                                      0xff1BA130),
                                  borderRadius:
                                  new BorderRadius.only(
                                    topLeft:
                                    const Radius.circular(2.0),
                                    bottomLeft:
                                    const Radius.circular(2.0),
                                    topRight:
                                    const Radius.circular(2.0),
                                    bottomRight:
                                    const Radius.circular(2.0),
                                  )),
                              height: 30,
                              width: 25,
                              child: Icon(
                                Icons.add,
                                size: 12,
                                color: Colors
                                    .white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            )
                : GestureDetector(
              onTap: () {
                Fluttertoast.showToast(
                    msg: /*"You will be notified via SMS/Push notification, when the product is available"*/
                    translate('forconvience.Out of stock popup'),//"Out Of Stock",
                    fontSize: 12.0,
                    backgroundColor:
                    Colors.black87,
                    textColor: Colors.white);
              },
              child: Container(
                height: 30.0,
                //width: (MediaQuery.of(context).size.width / 4) + 15,
                width: 160,
                decoration: new BoxDecoration(
                    border: Border.all(
                        color: Colors.grey),
                    color: Colors.grey,
                    borderRadius:
                    new BorderRadius.only(
                      topLeft: const Radius
                          .circular(2.0),
                      topRight: const Radius
                          .circular(2.0),
                      bottomLeft: const Radius
                          .circular(2.0),
                      bottomRight:
                      const Radius
                          .circular(2.0),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   /* SizedBox(
                      width: 10,
                    ),*/
                    Center(
                        child: Text(
                          /*'Notify Me'*/
                          translate('forconvience.ADD'),
                          style: TextStyle(
                            /*fontWeight: FontWeight.w700,*/
                              color: Colors
                                  .white,
                            fontSize: 12,/*Colors.black87*/),
                          textAlign:
                          TextAlign.center,
                        )),
                    Spacer(),
                    Container(
                      decoration:
                      BoxDecoration(
                          color: Colors
                              .black12,
                          borderRadius:
                          new BorderRadius
                              .only(
                            topRight:
                            const Radius
                                .circular(
                                2.0),
                            bottomRight:
                            const Radius
                                .circular(
                                2.0),
                          )),
                      height: 30,
                      width: 25,
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    _quantityPopup() {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  //height: 200,
                  width: MediaQuery.of(context).size.width / 3.0,
                  //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50.0,
                            color: ColorCodes.lightGreyWebColor,
                            padding: EdgeInsets.only(left: 20.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Select your quantity",
                                  style: TextStyle(
                                      color: ColorCodes.mediumBlackColor,
                                      fontSize: 20.0),
                                )),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: singleitemvar.length,
                              itemBuilder: (_, i) =>
                                  GestureDetector(
                                    onTap: () {
                                      for (int k = 0;
                                      k < singleitemvar.length;
                                      k++) {
                                        if (i == k) {
                                          singleitemvar[k].varcolor =
                                              Color(0xff012961);
                                        } else {
                                          singleitemvar[k].varcolor =
                                              Color(0xffBEBEBE);
                                        }
                                        setState(() {
                                          varmemberprice = singleitemvar[i]
                                              .varmemberprice;
                                          varmrp = singleitemvar[i].varmrp;
                                          varprice =
                                              singleitemvar[i].varprice;
                                          varid = singleitemvar[i].varid;
                                          varname =
                                              singleitemvar[i].varname;
                                          varstock =
                                              singleitemvar[i].varstock;
                                          varminitem =
                                              singleitemvar[i].varminitem;
                                          varmaxitem = singleitemvar[i].varmaxitem;
                                          varLoyalty = singleitemvar[i].varLoyalty;
                                          varcolor =
                                              singleitemvar[i].varcolor;
                                          discountDisplay = singleitemvar[i]
                                              .discountDisplay;
                                          memberpriceDisplay =
                                              singleitemvar[i]
                                                  .membershipDisplay;

                                          if (varmemberprice == '-' ||
                                              varmemberprice == "0") {
                                            setState(() {
                                              membershipdisplay = false;
                                            });
                                          } else {
                                            membershipdisplay = true;
                                          }

                                          if (_checkmembership) {
                                            if (varmemberprice.toString() ==
                                                '-' ||
                                                double.parse(
                                                    varmemberprice) <=
                                                    0) {
                                              if (double.parse(varmrp) <=
                                                  0 ||
                                                  double.parse(varprice) <=
                                                      0) {
                                                margins = "0";
                                              } else {
                                                var difference =
                                                (double.parse(varmrp) -
                                                    double.parse(
                                                        varprice));
                                                var profit = difference /
                                                    double.parse(varmrp);
                                                margins = profit * 100;

                                                //discount price rounding
                                                margins = num.parse(margins
                                                    .toStringAsFixed(0));
                                                margins =
                                                    margins.toString();
                                              }
                                            } else {
                                              var difference =
                                              (double.parse(varmrp) -
                                                  double.parse(
                                                      varmemberprice));
                                              var profit = difference /
                                                  double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(margins
                                                  .toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          } else {
                                            if (double.parse(varmrp) <= 0 ||
                                                double.parse(varprice) <=
                                                    0) {
                                              margins = "0";
                                            } else {
                                              var difference =
                                              (double.parse(varmrp) -
                                                  double.parse(
                                                      varprice));
                                              var profit = difference /
                                                  double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(margins
                                                  .toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          }

                                          if (margins == "NaN") {
                                            _checkmargin = false;
                                          } else {
                                            if (int.parse(margins) <= 0) {
                                              _checkmargin = false;
                                            } else {
                                              _checkmargin = true;
                                            }
                                          }
                                          multiimage =
                                              Provider.of<ItemsList>(
                                                  context,listen: false)
                                                  .findByIdmulti(varid);
                                          _displayimg =
                                              multiimage[0].imageUrl;
                                          for (int j = 0;
                                          j < multiimage.length;
                                          j++) {
                                            if (j == 0) {
                                              multiimage[j].varcolor =
                                                  Color(0xff114475);
                                            } else {
                                              multiimage[j].varcolor =
                                                  Color(0xffBEBEBE);
                                            }
                                          }
                                        });
                                      }
                                      setState(() {
                                        if (int.parse(varstock) <= 0) {
                                          _isStock = false;
                                        } else {
                                          _isStock = true;
                                        }
                                      });
                                    },
                                    child: Row(
                                      children: <Widget>[
//                                              Spacer(),
                                        _checkmargin
                                            ? Consumer<Calculations>(
                                          builder: (_, cart, ch) =>
                                              Align(
                                                alignment:
                                                Alignment.topLeft,
                                                child: BadgeDiscount(
                                                  child: ch,
                                                  value: /*margins*/_varMarginList[i],
                                                ),
                                              ),
                                          child: Container(
                                              padding: EdgeInsets.all(10.0),
                                              // width: MediaQuery.of(context).size.width,
                                              alignment: Alignment.center,
                                              height: 60.0,
                                              //width: 290,
                                              margin: EdgeInsets.only(bottom: 10.0),
                                              decoration:
                                              BoxDecoration(
                                                  color: ColorCodes.fill,
                                                  borderRadius: BorderRadius.circular(
                                                      5.0),
                                                  border: Border(
                                                    top: BorderSide(
                                                        width:
                                                        1.0,
                                                        color: singleitemvar[
                                                        i]
                                                            .varcolor),
                                                    bottom: BorderSide(
                                                        width:
                                                        1.0,
                                                        color: singleitemvar[
                                                        i]
                                                            .varcolor),
                                                    left: BorderSide(
                                                        width:
                                                        1.0,
                                                        color: singleitemvar[
                                                        i]
                                                            .varcolor),
                                                    right: BorderSide(
                                                        width:
                                                        1.0,
                                                        color: singleitemvar[
                                                        i]
                                                            .varcolor),
                                                  )),
                                              child: Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    singleitemvar[i]
                                                        .varname,
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                      fontSize:
                                                      14, /*color: singleitemvar[i].varcolor*/
                                                    ),
                                                  ),
                                                  Container(
                                                      child: Row(
                                                        children: <
                                                            Widget>[
                                                          _checkmembership
                                                              ? Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: <
                                                                Widget>[
                                                              memberpriceDisplay
                                                                  ? Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 25.0,
                                                                        height: 25.0,
                                                                        child: Image
                                                                            .asset(
                                                                          Images
                                                                              .starImg,
                                                                        ),
                                                                      ),
                                                                      Text(

                                                                              singleitemvar[i]
                                                                                  .varmemberprice+ _currencyFormat ,
                                                                          style: new TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize: 14.0)),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                      singleitemvar[i]
                                                                          .varmrp+_currencyFormat ,
                                                                      style: TextStyle(
                                                                          decoration: TextDecoration
                                                                              .lineThrough,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize: 10.0)),
                                                                ],
                                                              )
                                                                  : discountDisplay
                                                                  ? Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 25.0,
                                                                        height: 25.0,
                                                                        child: Image
                                                                            .asset(
                                                                          Images
                                                                              .starImg,
                                                                        ),
                                                                      ),
                                                                      Text(

                                                                              singleitemvar[i]
                                                                                  .varprice+ _currencyFormat ,
                                                                          style: new TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize: 14.0)),
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                      singleitemvar[i]
                                                                          .varmrp+_currencyFormat,
                                                                      style: TextStyle(
                                                                          decoration: TextDecoration
                                                                              .lineThrough,
                                                                          color: Colors
                                                                              .grey,
                                                                          fontSize: 10.0)),
                                                                ],
                                                              )
                                                                  : Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 25.0,
                                                                        height: 25.0,
                                                                        child: Image
                                                                            .asset(
                                                                          Images
                                                                              .starImg,
                                                                        ),
                                                                      ),
                                                                      Text(

                                                                              singleitemvar[i]
                                                                                  .varmrp+  _currencyFormat ,
                                                                          style: new TextStyle(
                                                                              fontWeight: FontWeight
                                                                                  .bold,
                                                                              color: Colors
                                                                                  .black,
                                                                              fontSize: 14.0)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          )
                                                              : discountDisplay
                                                              ? Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                  singleitemvar[i]
                                                                      .varprice+_currencyFormat ,
                                                                  style: new TextStyle(
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize: 14.0)),
                                                              Text(
                                                                  singleitemvar[i]
                                                                      .varmrp+_currencyFormat ,
                                                                  style: TextStyle(
                                                                      decoration: TextDecoration
                                                                          .lineThrough,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize: 10.0)),
                                                            ],
                                                          )
                                                              : Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                  singleitemvar[i]
                                                                      .varmrp+_currencyFormat ,
                                                                  style: new TextStyle(
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize: 14.0)),
                                                            ],
                                                          )
                                                        ],
                                                      )),
                                                  Icon(
                                                      Icons
                                                          .radio_button_checked_outlined,
                                                      color:
                                                      singleitemvar[
                                                      i]
                                                          .varcolor)
                                                ],
                                              )),
                                        )
                                            : Container(
                                            padding: EdgeInsets.all(10.0),
                                            //width:290,
                                            //height: 60.0,
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(bottom: 10.0),
                                            decoration: BoxDecoration(
                                                color: ColorCodes.fill,
                                                borderRadius: BorderRadius.circular(5.0),
                                                border: Border(
                                                  top: BorderSide(
                                                      width: 1.0,
                                                      color: singleitemvar[i].varcolor),
                                                  bottom: BorderSide(
                                                      width: 1.0,
                                                      color: singleitemvar[i].varcolor),
                                                  left: BorderSide(
                                                      width: 1.0,
                                                      color:
                                                      singleitemvar[
                                                      i]
                                                          .varcolor),
                                                  right: BorderSide(
                                                      width: 1.0,
                                                      color:
                                                      singleitemvar[
                                                      i]
                                                          .varcolor),
                                                )),
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                Text(
                                                  singleitemvar[i]
                                                      .varname,
                                                  textAlign:
                                                  TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize:
                                                    14, /*color: singleitemvar[i].varcolor*/
                                                  ),
                                                ),
                                                Container(
                                                    child: Row(
                                                      children: <Widget>[
                                                        _checkmembership
                                                            ? Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                          children: <
                                                              Widget>[
                                                            memberpriceDisplay
                                                                ? Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 25.0,
                                                                      height: 25.0,
                                                                      child: Image
                                                                          .asset(
                                                                        Images.starImg,
                                                                      ),
                                                                    ),
                                                                    Text(

                                                                            singleitemvar[i]
                                                                                .varmemberprice+_currencyFormat ,
                                                                        style: new TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize: 14.0)),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    singleitemvar[i]
                                                                        .varmrp+_currencyFormat ,
                                                                    style: TextStyle(
                                                                        decoration: TextDecoration
                                                                            .lineThrough,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize: 10.0)),
                                                              ],
                                                            )
                                                                : discountDisplay
                                                                ? Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 25.0,
                                                                      height: 25.0,
                                                                      child: Image
                                                                          .asset(
                                                                        Images.starImg,
                                                                      ),
                                                                    ),
                                                                    Text(

                                                                            singleitemvar[i]
                                                                                .varprice+_currencyFormat ,
                                                                        style: new TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize: 14.0)),
                                                                  ],
                                                                ),
                                                                Text(
                                                                    singleitemvar[i]
                                                                        .varmrp+_currencyFormat ,
                                                                    style: TextStyle(
                                                                        decoration: TextDecoration
                                                                            .lineThrough,
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize: 10.0)),
                                                              ],
                                                            )
                                                                : Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 25.0,
                                                                      height: 25.0,
                                                                      child: Image
                                                                          .asset(
                                                                        Images.starImg,
                                                                      ),
                                                                    ),
                                                                    Text(

                                                                            singleitemvar[i]
                                                                                .varmrp+_currencyFormat ,
                                                                        style: new TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold,
                                                                            color: Colors
                                                                                .black,
                                                                            fontSize: 14.0)),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )
                                                            : discountDisplay
                                                            ? Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: [
                                                            Text(

                                                                    singleitemvar[i]
                                                                        .varprice+_currencyFormat ,
                                                                style: new TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors.black,
                                                                    fontSize: 14.0)),
                                                            Text(

                                                                    singleitemvar[i]
                                                                        .varmrp+  _currencyFormat ,
                                                                style: TextStyle(
                                                                    decoration: TextDecoration
                                                                        .lineThrough,
                                                                    color: Colors.grey,
                                                                    fontSize: 10.0)),
                                                          ],
                                                        )
                                                            : Column(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.center,
                                                          children: [
                                                            Text(

                                                                    singleitemvar[i]
                                                                        .varmrp+ _currencyFormat ,
                                                                style: new TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Colors.black,
                                                                    fontSize: 14.0)),
                                                          ],
                                                        )
                                                      ],
                                                    )),
                                                Icon(
                                                    Icons
                                                        .radio_button_checked_outlined,
                                                    color:
                                                    singleitemvar[i]
                                                        .varcolor)
                                              ],
                                            ))
//                                              Spacer(),
                                      ],
                                    ),
                                  ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _addButton(),
                              SizedBox(width: 20),
                            ],
                          ),

                          SizedBox(height: 20),
                        ]),
                  ),
                ),
              );
            });
          });
    }

    Widget _footer() {
      if (ResponsiveLayout.isSmallScreen(context) || ResponsiveLayout.isMediumScreen(context) || ResponsiveLayout.isLargeScreen(context)) {
        return Footer(
          address: prefs.getString("restaurant_address"),
        );
      } else if (Platform.isIOS || Platform.isAndroid) {
        return Container();
      }
    }

    Widget webBody() {
      return SafeArea(
        child: _isLoading
            ? Center(
          child: new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            : Column(
          children: [
            _responsiveAppBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            _firstHalfImage(),

                            // Top half
                            Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 20.0, top: 50.0, right: 10.0, bottom: 20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          singleitemData.singleitems[0].title,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color:Theme.of(context).primaryColor,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        if(double.parse(varLoyalty.toString()) > 0)
                                          Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 20.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(varLoyalty.toString()),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if(discountDisplay)
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                    Row(
                                      children: [

                                        /* Text(
                                        singleitemData.singleitems[0].brand,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Spacer(),*/
                                        if(discountDisplay)
                                          new RichText(
                                              text: new TextSpan(
                                                  style:
                                                  new TextStyle(
                                                    //  fontSize: 18.0,
                                                    color: Colors
                                                        .black,
                                                  ),
                                                  children: <
                                                      TextSpan>[
                                                    new TextSpan(
                                                        text:
                                                        '$varmrp '+_currencyFormat ,
                                                        style: TextStyle(
                                                            decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                            fontSize:
                                                            16,
                                                            color: Colors
                                                                .grey))
                                                  ])),
                                        if (_checkmargin)
                                          Container(
                                            margin: EdgeInsets.only(left: 50.0),
                                            padding: EdgeInsets.all(3.0),
                                            // color: Theme.of(context).accentColor,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(3.0),
                                              color: Color(0xffFF9400),
                                            ),
                                            constraints: BoxConstraints(
                                              minWidth: 28,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              translate('forconvience.OFF')+" "+margins + " % ",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                  Theme.of(context).buttonColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),

                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          /* width:
                                            MediaQuery.of(context).size.width / 2 +
                                                40,*/
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: <Widget>[

                                              _checkmembership
                                                  ? Row(
                                                children: <Widget>[
                                                  memberpriceDisplay
                                                      ? Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      new RichText(
                                                          text: new TextSpan(
                                                              style: new TextStyle(
                                                                fontSize:
                                                                14.0,
                                                                color:
                                                                Colors.black,
                                                              ),
                                                              children: <TextSpan>[
                                                                /* new TextSpan(
                                                            text:
                                                            'Product MRP: ',
                                                            style:
                                                            new TextStyle(fontSize: 16.0)),*/
                                                                new TextSpan(
                                                                    text:
                                                                    '$varmrp '+_currencyFormat ,
                                                                    style: new TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 25.0))
                                                              ])),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 25.0,
                                                            height: 25.0,
                                                            child: Image
                                                                .asset(
                                                              Images.starImg,
                                                            ),
                                                          ),
                                                          new RichText(
                                                              text: new TextSpan(
                                                                  style: new TextStyle(
                                                                    fontSize:
                                                                    14.0,
                                                                    color:
                                                                    Colors.black,
                                                                  ),
                                                                  children: <TextSpan>[
                                                                    /* new TextSpan(
                                                                text:
                                                                'Selling Price: ',
                                                                style:
                                                                new TextStyle(fontSize: 16.0)),*/
                                                                    new TextSpan(
                                                                        text:
                                                                        '$varmemberprice '+_currencyFormat ,
                                                                        style: new TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 25.0))
                                                                  ])),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                      : discountDisplay
                                                      ? Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      new RichText(
                                                          text: new TextSpan(
                                                              style: new TextStyle(
                                                                fontSize:
                                                                14.0,
                                                                color:
                                                                Colors.black,
                                                              ),
                                                              children: <TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                    'Product MRP: ',
                                                                    style:
                                                                    new TextStyle(fontSize: 16.0)),
                                                                new TextSpan(
                                                                    text:
                                                                    '$varmrp '+ _currencyFormat ,
                                                                    style: TextStyle(
                                                                        decoration: TextDecoration.lineThrough,
                                                                        fontSize: 12,
                                                                        color: Colors.grey))
                                                              ])),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width:
                                                            25.0,
                                                            height:
                                                            25.0,
                                                            child: Image
                                                                .asset(
                                                              Images.starImg,
                                                            ),
                                                          ),
                                                          Text(

                                                              '$varprice '+ _currencyFormat ,
                                                              style: new TextStyle(
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                  fontSize: 16.0)),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                      : Row(
                                                    children: [
                                                      Container(
                                                        width: 25.0,
                                                        height: 25.0,
                                                        child: Image
                                                            .asset(
                                                          Images.starImg,
                                                        ),
                                                      ),
                                                      new RichText(
                                                          text: new TextSpan(
                                                              style: new TextStyle(
                                                                fontSize:
                                                                14.0,
                                                                color:
                                                                Colors.black,
                                                              ),
                                                              children: <TextSpan>[
                                                                new TextSpan(
                                                                    text:
                                                                    'Selling Price: ',
                                                                    style:
                                                                    new TextStyle(fontSize: 16.0)),
                                                                new TextSpan(
                                                                    text:
                                                                    '$varmrp '+ _currencyFormat ,
                                                                    style: new TextStyle(
                                                                        fontWeight: FontWeight.bold,
                                                                        fontSize: 16.0))
                                                              ])),
                                                    ],
                                                  )
                                                ],
                                              )
                                                  : discountDisplay
                                                  ? Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: [

                                                  new RichText(
                                                      text: new TextSpan(
                                                          style:
                                                          new TextStyle(
                                                            // fontSize: 14.0,
                                                            color: Colors
                                                                .black,
                                                          ),
                                                          children: <
                                                              TextSpan>[
                                                            new TextSpan(
                                                                text:
                                                                '$varprice '+_currencyFormat ,
                                                                style: new TextStyle(
                                                                    color: Theme.of(context).primaryColor,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                    fontSize:
                                                                    20.0))
                                                          ])),
                                                ],
                                              )
                                                  :
                                              new RichText(
                                                  text: new TextSpan(
                                                      style: new TextStyle(
                                                        //fontSize: 14.0,
                                                        color: Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        /*new TextSpan(
                                                    text:
                                                    'Selling Price: ',
                                                    style:
                                                    new TextStyle(
                                                        fontSize:
                                                        16.0)),*/
                                                        new TextSpan(
                                                            text:

                                                            '$varmrp '+ _currencyFormat ,
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                color: Theme.of(context).primaryColor,
                                                                fontSize: 20.0))
                                                      ])),
                                              Center (
                                                child: Text(
                                                  ' /'+singleitemvar[0] .varname,

                                                  textAlign: TextAlign .center,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: ColorCodes
                                                        .varcolor,
                                                  ),
                                                ),
                                              ),
                                              /* Text(
                                              "(Inclusive of all taxes)",
                                              style: TextStyle(
                                                  fontSize: 8, color: Colors.grey),
                                            ),*/

                                            ],
                                          ),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height:20),
                                    Container(
                                      /*  width:
                                            MediaQuery.of(context).size.width / 2 -
                                                60,*/
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          /*  if(double.parse(varLoyalty.toString()) > 0)
                                            Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Image.asset(Images.coinImg,
                                                    height: 15.0,
                                                    width: 20.0,),
                                                  SizedBox(width: 4),
                                                  Text(varLoyalty.toString()),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),*/
                                          _isStock
                                              ? Container(
                                            height: 30.0,
                                            width: (MediaQuery.of(context)
                                                .size
                                                .width /
                                                4) +
                                                20,
                                            child: ValueListenableBuilder(
                                              valueListenable:
                                              Hive.box<Product>(
                                                  productBoxName)
                                                  .listenable(),
                                              builder: (context,
                                                  Box<Product> box, _) {
                                                if (box.values.length <= 0)
                                                  return GestureDetector(
                                                    onTap: () {
                                                      addToCart(int.parse(
                                                          varminitem));
                                                    },
                                                    child: Container(
                                                      height: 30.0,
                                                      width: (MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width /
                                                          4) +
                                                          15,
                                                      decoration:
                                                      new BoxDecoration(
                                                          color: Color(
                                                              0xff32B847),
                                                          borderRadius:
                                                          new BorderRadius
                                                              .only(
                                                            topLeft:
                                                            const Radius.circular(
                                                                2.0),
                                                            topRight:
                                                            const Radius.circular(
                                                                2.0),
                                                            bottomLeft:
                                                            const Radius.circular(
                                                                2.0),
                                                            bottomRight:
                                                            const Radius.circular(
                                                                2.0),
                                                          )),
                                                      child:
                                                      /*Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),*/
                                                      Center(
                                                          child: Text(
                                                            translate('forconvience.ADD'),
                                                            style:
                                                            TextStyle(
                                                              color: Theme.of(
                                                                  context)
                                                                  .buttonColor,
                                                              fontSize: 12,
                                                            ),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                          )),
                                                      //  Spacer(),
                                                      /* Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                            color: Color(
                                                                                0xff1BA130),
                                                                            borderRadius:
                                                                                new BorderRadius.only(
                                                                              topLeft:
                                                                                  const Radius.circular(2.0),
                                                                              bottomLeft:
                                                                                  const Radius.circular(2.0),
                                                                              topRight:
                                                                                  const Radius.circular(2.0),
                                                                              bottomRight:
                                                                                  const Radius.circular(2.0),
                                                                            )),
                                                                    height: 30,
                                                                    width: 25,
                                                                    child: Icon(
                                                                      Icons.add,
                                                                      size: 12,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),*/
                                                      //],
                                                      //  ),
                                                    ),
                                                  );

                                                try {
                                                  Product item = Hive.box<
                                                      Product>(
                                                      productBoxName)
                                                      .values
                                                      .firstWhere((value) =>
                                                  value.varId ==
                                                      int.parse(varid));
                                                  return Container(
                                                    child: Row(
                                                      children: <Widget>[
                                                        GestureDetector(
                                                          onTap: () async {
                                                            if (item.itemQty ==
                                                                int.parse(
                                                                    varminitem)) {
                                                              for (int i =
                                                              0;
                                                              i <
                                                                  productBox
                                                                      .values
                                                                      .length;
                                                              i++) {
                                                                if (productBox
                                                                    .values
                                                                    .elementAt(
                                                                    i)
                                                                    .varId ==
                                                                    int.parse(
                                                                        varid)) {
                                                                  productBox
                                                                      .deleteAt(
                                                                      i);
                                                                  break;
                                                                }
                                                              }
                                                            } else {
                                                              setState(() {
                                                                incrementToCart(
                                                                    item.itemQty -
                                                                        1);
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration:
                                                              new BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color:
                                                                    Color(0xff32B847),
                                                                  ),
                                                                  borderRadius:
                                                                  new BorderRadius.only(
                                                                    bottomLeft:
                                                                    const Radius.circular(2.0),
                                                                    topLeft:
                                                                    const Radius.circular(2.0),
                                                                  )),
                                                              child: Center(
                                                                child: Text(
                                                                  "-",
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  style:
                                                                  TextStyle(
                                                                    color: Color(
                                                                        0xff32B847),
                                                                  ),
                                                                ),
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: Container(
//                                            width: 40,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: Color(
                                                                    0xff32B847),
                                                              ),
                                                              height: 30,
                                                              child: Center(
                                                                child: Text(
                                                                  item.itemQty
                                                                      .toString(),
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  style:
                                                                  TextStyle(
                                                                    color: Theme.of(context)
                                                                        .buttonColor,
                                                                  ),
                                                                ),
                                                              )),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (item.itemQty <
                                                                int.parse(
                                                                    varstock)) {
                                                              if (item.itemQty <
                                                                  int.parse(
                                                                      varmaxitem)) {
                                                                incrementToCart(
                                                                    item.itemQty +
                                                                        1);
                                                              } else {
                                                                Fluttertoast.showToast(
                                                                    msg:
                                                                    translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                                                    backgroundColor:
                                                                    Colors
                                                                        .black87,
                                                                    textColor:
                                                                    Colors.white);
                                                              }
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                  "Sorry, Out of Stock!",
                                                                  backgroundColor:
                                                                  Colors
                                                                      .black87,
                                                                  textColor:
                                                                  Colors
                                                                      .white);
                                                            }
                                                          },
                                                          child: Container(
                                                              width: 30,
                                                              height: 30,
                                                              decoration:
                                                              new BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color:
                                                                    Color(0xff32B847),
                                                                  ),
                                                                  borderRadius:
                                                                  new BorderRadius.only(
                                                                    bottomRight:
                                                                    const Radius.circular(2.0),
                                                                    topRight:
                                                                    const Radius.circular(2.0),
                                                                  )),
                                                              child: Center(
                                                                child: Text(
                                                                  "+",
                                                                  textAlign:
                                                                  TextAlign
                                                                      .center,
                                                                  style:
                                                                  TextStyle(
                                                                    color: Color(
                                                                        0xff32B847),
                                                                  ),
                                                                ),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                } catch (e) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      addToCart(int.parse(
                                                          varminitem));
                                                    },
                                                    child: Container(
                                                      height: 30.0,
                                                      width: (MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width /
                                                          4) +
                                                          15,
                                                      decoration:
                                                      new BoxDecoration(
                                                          color: Color(
                                                              0xff32B847),
                                                          borderRadius:
                                                          new BorderRadius
                                                              .only(
                                                            topLeft:
                                                            const Radius.circular(
                                                                2.0),
                                                            topRight:
                                                            const Radius.circular(
                                                                2.0),
                                                            bottomLeft:
                                                            const Radius.circular(
                                                                2.0),
                                                            bottomRight:
                                                            const Radius.circular(
                                                                2.0),
                                                          )),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          /* SizedBox(
                                                        width: 10,
                                                      ),*/
                                                          Center(
                                                              child: Text(
                                                                translate('forconvience.ADD'),
                                                                style:
                                                                TextStyle(
                                                                  color: Theme.of(
                                                                      context)
                                                                      .buttonColor, fontSize: 12,
                                                                ),
                                                                textAlign:
                                                                TextAlign
                                                                    .center,
                                                              )),
                                                          // Spacer(),
                                                          /* Container(
                                                        decoration:
                                                        BoxDecoration(
                                                            color: Color(
                                                                0xff1BA130),
                                                            borderRadius:
                                                            new BorderRadius.only(
                                                              topLeft:
                                                              const Radius.circular(2.0),
                                                              bottomLeft:
                                                              const Radius.circular(2.0),
                                                              topRight:
                                                              const Radius.circular(2.0),
                                                              bottomRight:
                                                              const Radius.circular(2.0),
                                                            )),
                                                        height: 30,
                                                        width: 25,
                                                        child: Icon(
                                                          Icons.add,
                                                          size: 12,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      ),*/
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          )
                                              : GestureDetector(
                                            onTap: () {
                                              Fluttertoast.showToast(
                                                  msg:  /*"You will be notified via SMS/Push notification, when the product is available"  */
                                                  translate('forconvience.Out of stock popup'), //"Out Of Stock",
                                                  fontSize: 12.0,
                                                  backgroundColor:
                                                  Colors.black87,
                                                  textColor: Colors.white);
                                            },
                                            child: Container(
                                              height: 30.0,
                                              width: (MediaQuery.of(context).size.width / 4) + 15,
                                              decoration: new BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                  color: Colors.grey,
                                                  borderRadius:
                                                  new BorderRadius.only(
                                                    topLeft: const Radius
                                                        .circular(2.0),
                                                    topRight: const Radius
                                                        .circular(2.0),
                                                    bottomLeft: const Radius
                                                        .circular(2.0),
                                                    bottomRight:
                                                    const Radius
                                                        .circular(2.0),
                                                  )),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                // crossAxisAlignment:CrossAxisAlignment.center,
                                                children: [
                                                  /* SizedBox(
                                                width: 10,
                                              ),*/
                                                  Center(
                                                      child: Text(
                                                        /*'Notify Me'*/
                                                        translate('forconvience.ADD'),
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors
                                                              .white ,
                                                          fontSize: 10,),
                                                        textAlign:
                                                        TextAlign.center,
                                                      )),
                                                  //  Spacer(),
                                                  /* Container(
                                                decoration:
                                                BoxDecoration(
                                                    color: Colors
                                                        .black12,
                                                    borderRadius:
                                                    new BorderRadius
                                                        .only(
                                                      topRight:
                                                      const Radius
                                                          .circular(
                                                          2.0),
                                                      bottomRight:
                                                      const Radius
                                                          .circular(
                                                          2.0),
                                                    )),
                                                height: 30,
                                                width: 25,
                                                child: Icon(
                                                  Icons.add,
                                                  size: 12,
                                                  color: Colors.white,
                                                ),
                                              ),*/
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    /*!_checkmembership
                                      ? membershipdisplay
                                          ? SizedBox(
                                              height: 10,
                                            )
                                          : SizedBox(
                                              height: 1,
                                            )
                                      : SizedBox(
                                          height: 1,
                                        ),*/
                                    /*   Row(
                                    children: [
                                      !_checkmembership
                                          ? membershipdisplay
                                              ? GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pushNamed(
                                                      MembershipScreen.routeName,
                                                    );
                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: (MediaQuery.of(context)
                                                            .size
                                                            .width) -
                                                        20,
                                                    decoration: BoxDecoration(
                                                        color: Color(0xffEBF5FF)),
                                                    child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        SizedBox(width: 10),
                                                        Image.asset(
                                                          Images.starImg,
                                                          height: 12,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text("MembershipPrice:  ",
                                                            style: TextStyle(
                                                                fontSize: 12.0)),
                                                        Text(
                                                            _currencyFormat +
                                                                " " +
                                                                varmemberprice,
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: 14.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.lock,
                                                          color: Colors.black,
                                                          size: 12,
                                                        ),
                                                        SizedBox(width: 2),
                                                        Icon(
                                                          Icons
                                                              .arrow_forward_ios_sharp,
                                                          color: Colors.black,
                                                          size: 12,
                                                        ),
                                                        SizedBox(width: 10),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : SizedBox.shrink()
                                          : SizedBox.shrink(),
                                    ],
                                  ),*/
                                    /*  SizedBox(
                                    height: 20.0,
                                  ),
                                  Text(
                                    "Pack Sizes",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),*/
                                    /*new ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: singleitemvar.length,
                                    itemBuilder: (_, i) => Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              for (int k = 0; k < singleitemvar.length; k++) {
                                                if (i == k) {
                                                  singleitemvar[k].varcolor = Color(0xff012961);
                                                } else {
                                                  singleitemvar[k].varcolor = Color(0xffBEBEBE);
                                                }
                                                setState(() {
                                                  varmemberprice = singleitemvar[i] .varmemberprice;
                                                  varmrp = singleitemvar[i].varmrp;
                                                  varprice = singleitemvar[i].varprice;
                                                  varid = singleitemvar[i].varid;
                                                  varname = singleitemvar[i].varname;
                                                  varstock = singleitemvar[i].varstock;
                                                  varminitem = singleitemvar[i].varminitem;
                                                  varmaxitem = singleitemvar[i].varmaxitem;
                                                  varLoyalty = singleitemvar[i].varLoyalty;
                                                  varcolor = singleitemvar[i].varcolor;
                                                  discountDisplay = singleitemvar[i] .discountDisplay;
                                                  memberpriceDisplay = singleitemvar[i].membershipDisplay;

                                                  if (varmemberprice == '-' ||
                                                      varmemberprice == "0") {
                                                    setState(() {
                                                      membershipdisplay = false;
                                                    });
                                                  } else {
                                                    membershipdisplay = true;
                                                  }

                                                  if (_checkmembership) {
                                                    if (varmemberprice.toString() == '-' ||
                                                        double.parse(varmemberprice) <= 0) {
                                                      if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                                        margins = "0";
                                                      } else {
                                                        var difference = (double.parse(varmrp) - double.parse(varprice));
                                                        var profit = difference / double.parse(varmrp);
                                                        margins = profit * 100;

                                                        //discount price rounding
                                                        margins = num.parse(margins.toStringAsFixed(0));
                                                        margins = margins.toString();
                                                      }
                                                    } else {
                                                      var difference = (double.parse(varmrp) - double.parse(varmemberprice));
                                                      var profit = difference / double.parse(varmrp);
                                                      margins = profit * 100;

                                                      //discount price rounding
                                                      margins = num.parse(margins.toStringAsFixed(0));
                                                      margins = margins.toString();
                                                    }
                                                  } else {
                                                    if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                                      margins = "0";
                                                    } else {
                                                      var difference = (double.parse(varmrp) - double.parse(varprice));
                                                      var profit = difference / double.parse(varmrp);
                                                      margins = profit * 100;

                                                      //discount price rounding
                                                      margins = num.parse(margins.toStringAsFixed(0));
                                                      margins = margins.toString();
                                                    }
                                                  }

                                                  if (margins == "NaN") {
                                                    _checkmargin = false;
                                                  } else {
                                                    if (int.parse(margins) <= 0) {
                                                      _checkmargin = false;
                                                    } else {
                                                      _checkmargin = true;
                                                    }
                                                  }
                                                  multiimage = Provider.of<ItemsList>(context, listen: false).findByIdmulti(varid);
                                                  _displayimg = multiimage[0].imageUrl;
                                                  for (int j = 0; j < multiimage.length; j++) {
                                                    if (j == 0) {
                                                      multiimage[j].varcolor = Color(0xff114475);
                                                    } else {
                                                      multiimage[j].varcolor = Color(0xffBEBEBE);
                                                    }
                                                  }
                                                });
                                              }
                                              setState(() {
                                                if (int.parse(varstock) <= 0) {
                                                  _isStock = false;
                                                } else {
                                                  _isStock = true;
                                                }
                                              });
                                            },
                                            child: Row(
                                              children: <Widget>[
//                                              Spacer(),
                                                _checkmargin
                                                    ? Consumer<Calculations>(
                                                        builder: (_, cart, ch) =>
                                                            Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: BadgeDiscount(
                                                            child: ch,
                                                            value: */
                                    /*margins*/
                                    /*_varMarginList[i],
                                                          ),
                                                        ),
                                                        child: Container(
                                                            padding: EdgeInsets.all(10.0),
                                                            width: MediaQuery.of(context).size.width - 20,
                                                            //height: 60.0,
                                                            alignment: Alignment.center,
                                                            margin: EdgeInsets.only(
                                                                bottom: 10.0),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: ColorCodes.fill,
                                                                    borderRadius:
                                                                        BorderRadius .circular(5.0),
                                                                    border: Border(
                                                                      top: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                      bottom: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                      left: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                      right: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                    )),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(
                                                                  singleitemvar[i] .varname,
                                                                  textAlign: TextAlign .center,
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                      color: singleitemvar[i].varcolor
                                                                  ),
                                                                ),
                                                                Container(
                                                                    child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    _checkmembership
                                                                        ? Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: <
                                                                                Widget>[
                                                                              memberpriceDisplay
                                                                                  ? Column(
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 25.0,
                                                                                              height: 25.0,
                                                                                              child: Image.asset(
                                                                                                Images.starImg,
                                                                                              ),
                                                                                            ),
                                                                                            Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                          ],
                                                                                        ),
                                                                                        Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                      ],
                                                                                    )
                                                                                  : discountDisplay
                                                                                      ? Column(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 25.0,
                                                                                                  height: 25.0,
                                                                                                  child: Image.asset(
                                                                                                    Images.starImg,
                                                                                                  ),
                                                                                                ),
                                                                                                Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                              ],
                                                                                            ),
                                                                                            Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                          ],
                                                                                        )
                                                                                      : Column(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 25.0,
                                                                                                  height: 25.0,
                                                                                                  child: Image.asset(
                                                                                                    Images.starImg,
                                                                                                  ),
                                                                                                ),
                                                                                                Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                            ],
                                                                          )
                                                                        : discountDisplay
                                                                            ? Column(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.center,
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                  Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                ],
                                                                              )
                                                                            : Column(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.center,
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                ],
                                                                              )
                                                                  ],
                                                                )),
                                                                Icon(
                                                                    Icons
                                                                        .radio_button_checked_outlined,
                                                                    color:
                                                                        singleitemvar[
                                                                                i]
                                                                            .varcolor)
                                                              ],
                                                            )),
                                                      )
                                                    : Container(
                                                        padding:
                                                            EdgeInsets.all(10.0),
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                20,
                                                        //height: 60.0,
                                                        alignment: Alignment.center,
                                                        margin: EdgeInsets.only(
                                                            bottom: 10.0),
                                                        decoration: BoxDecoration(
                                                            color: ColorCodes.fill,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(5.0),
                                                            border: Border(
                                                              top: BorderSide(
                                                                  width: 1.0,
                                                                  color:
                                                                      singleitemvar[
                                                                              i]
                                                                          .varcolor),
                                                              bottom: BorderSide(
                                                                  width: 1.0,
                                                                  color:
                                                                      singleitemvar[
                                                                              i]
                                                                          .varcolor),
                                                              left: BorderSide(
                                                                  width: 1.0,
                                                                  color:
                                                                      singleitemvar[
                                                                              i]
                                                                          .varcolor),
                                                              right: BorderSide(
                                                                  width: 1.0,
                                                                  color:
                                                                      singleitemvar[
                                                                              i]
                                                                          .varcolor),
                                                            )),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              singleitemvar[i]
                                                                  .varname,
                                                              textAlign:
                                                                  TextAlign.center,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    14,  color: singleitemvar[i].varcolor
                                                              ),
                                                            ),
                                                            Container(
                                                                child: Row(
                                                              children: <Widget>[
                                                                _checkmembership
                                                                    ? Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment
                                                                                .center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .center,
                                                                        children: <
                                                                            Widget>[
                                                                          memberpriceDisplay
                                                                              ? Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          width: 25.0,
                                                                                          height: 25.0,
                                                                                          child: Image.asset(
                                                                                            Images.starImg,
                                                                                          ),
                                                                                        ),
                                                                                        Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                      ],
                                                                                    ),
                                                                                    Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                  ],
                                                                                )
                                                                              : discountDisplay
                                                                                  ? Column(
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 25.0,
                                                                                              height: 25.0,
                                                                                              child: Image.asset(
                                                                                                Images.starImg,
                                                                                              ),
                                                                                            ),
                                                                                            Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                          ],
                                                                                        ),
                                                                                        Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                      ],
                                                                                    )
                                                                                  : Column(
                                                                                      children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 25.0,
                                                                                              height: 25.0,
                                                                                              child: Image.asset(
                                                                                                Images.starImg,
                                                                                              ),
                                                                                            ),
                                                                                            Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                        ],
                                                                      )
                                                                    : discountDisplay
                                                                        ? Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                  _currencyFormat + singleitemvar[i].varprice,
                                                                                  style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                              Text(
                                                                                  _currencyFormat + singleitemvar[i].varmrp,
                                                                                  style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                            ],
                                                                          )
                                                                        : Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                  _currencyFormat + singleitemvar[i].varmrp,
                                                                                  style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                            ],
                                                                          )
                                                              ],
                                                            )),
                                                            Icon(
                                                                Icons
                                                                    .radio_button_checked_outlined,
                                                                color:
                                                                    singleitemvar[i]
                                                                        .varcolor)
                                                          ],
                                                        ))
//                                              Spacer(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        //Divider(),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),*/
                                    Divider(
                                      thickness: 1.0,
                                    ),
                                    /* Column(
                                    children: [
                                      Text("Available Quality",style: TextStyle(fontWeight: FontWeight.bold),),
                                      SizedBox(
                                        height:80,
                                        child: new ListView.builder(
                                          shrinkWrap: true,
                                          // physics: NeverScrollableScrollPhysics(),
                                          itemCount: singleitemvar.length,
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (_, i) => Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  for (int k = 0;
                                                  k < singleitemvar.length;
                                                  k++) {
                                                    if (i == k) {
                                                      singleitemvar[k].varcolor =
                                                          Color(0xff012961);
                                                    } else {
                                                      singleitemvar[k].varcolor =
                                                          Color(0xffBEBEBE);
                                                    }
                                                    setState(() {
                                                      varmemberprice = singleitemvar[i]
                                                          .varmemberprice;
                                                      varmrp = singleitemvar[i].varmrp;
                                                      varprice =
                                                          singleitemvar[i].varprice;
                                                      varid = singleitemvar[i].varid;
                                                      varname =
                                                          singleitemvar[i].varname;
                                                      varstock =
                                                          singleitemvar[i].varstock;
                                                      varminitem =
                                                          singleitemvar[i].varminitem;
                                                      varmaxitem =
                                                          singleitemvar[i].varmaxitem;
                                                      varcolor =
                                                          singleitemvar[i].varcolor;
                                                      discountDisplay = singleitemvar[i]
                                                          .discountDisplay;
                                                      memberpriceDisplay =
                                                          singleitemvar[i]
                                                              .membershipDisplay;

                                                      if (varmemberprice == '-' ||
                                                          varmemberprice == "0") {
                                                        setState(() {
                                                          membershipdisplay = false;
                                                        });
                                                      } else {
                                                        membershipdisplay = true;
                                                      }

                                                      if (_checkmembership) {
                                                        if (varmemberprice.toString() ==
                                                            '-' ||
                                                            double.parse(
                                                                varmemberprice) <=
                                                                0) {
                                                          if (double.parse(varmrp) <=
                                                              0 ||
                                                              double.parse(varprice) <=
                                                                  0) {
                                                            margins = "0";
                                                          } else {
                                                            var difference =
                                                            (double.parse(varmrp) -
                                                                double.parse(
                                                                    varprice));
                                                            var profit = difference /
                                                                double.parse(varmrp);
                                                            margins = profit * 100;

                                                            //discount price rounding
                                                            margins = num.parse(margins
                                                                .toStringAsFixed(0));
                                                            margins =
                                                                margins.toString();
                                                          }
                                                        } else {
                                                          var difference =
                                                          (double.parse(varmrp) -
                                                              double.parse(
                                                                  varmemberprice));
                                                          var profit = difference /
                                                              double.parse(varmrp);
                                                          margins = profit * 100;

                                                          //discount price rounding
                                                          margins = num.parse(margins
                                                              .toStringAsFixed(0));
                                                          margins = margins.toString();
                                                        }
                                                      } else {
                                                        if (double.parse(varmrp) <= 0 ||
                                                            double.parse(varprice) <=
                                                                0) {
                                                          margins = "0";
                                                        } else {
                                                          var difference =
                                                          (double.parse(varmrp) -
                                                              double.parse(
                                                                  varprice));
                                                          var profit = difference /
                                                              double.parse(varmrp);
                                                          margins = profit * 100;

                                                          //discount price rounding
                                                          margins = num.parse(margins
                                                              .toStringAsFixed(0));
                                                          margins = margins.toString();
                                                        }
                                                      }

                                                      if (margins == "NaN") {
                                                        _checkmargin = false;
                                                      } else {
                                                        if (int.parse(margins) <= 0) {
                                                          _checkmargin = false;
                                                        } else {
                                                          _checkmargin = true;
                                                        }
                                                      }
                                                      multiimage =
                                                          Provider.of<ItemsList>(
                                                              context)
                                                              .findByIdmulti(varid);
                                                      _displayimg =
                                                          multiimage[0].imageUrl;
                                                      for (int j = 0;
                                                      j < multiimage.length;
                                                      j++) {
                                                        if (j == 0) {
                                                          multiimage[j].varcolor =
                                                              Color(0xff114475);
                                                        } else {
                                                          multiimage[j].varcolor =
                                                              Color(0xffBEBEBE);
                                                        }
                                                      }
                                                    });
                                                  }
                                                  setState(() {
                                                    if (int.parse(varstock) <= 0) {
                                                      _isStock = false;
                                                    } else {
                                                      _isStock = true;
                                                    }
                                                  });
                                                },
                                                child:Container(
                                                  height: 50,
                                                  width:80,
                                                  padding:EdgeInsets.all(10),
                                                  margin:EdgeInsets.all(5),
                                                  decoration:BoxDecoration(
                                                    borderRadius:BorderRadius.circular(4),
                                                    border:Border.all(color:singleitemvar[i].varcolor),
                                                    color:Colors.white,
                                                  ),
                                                  child:Center(child: Text( singleitemvar[i].varname,style:TextStyle(fontSize:14,color: singleitemvar[i].varcolor,fontWeight:FontWeight.bold))),
                                                ),
//                                     child: Row(
//                                       children: <Widget>[
// //                                              Spacer(),
//                                         _checkmargin
//                                             ? Consumer<Calculations>(
//                                           builder: (_, cart, ch) =>
//                                               Align(
//                                                 alignment:
//                                                 Alignment.topLeft,
//                                                 child: BadgeDiscount(
//                                                   child: ch,
//                                                   value: margins,
//                                                 ),
//                                               ),
//                                           child: Container(
//                                               padding: EdgeInsets.all(
//                                                   10.0),
//                                               width: MediaQuery.of(
//                                                   context)
//                                                   .size
//                                                   .width -
//                                                   20,
//                                               height: 60.0,
//                                               alignment:
//                                               Alignment.center,
//                                               margin: EdgeInsets.only(
//                                                   bottom: 10.0),
//                                               decoration:
//                                               BoxDecoration(
//                                                   color:
//                                                   ColorCodes
//                                                       .fill,
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                       5.0),
//                                                   border: Border(
//                                                     top: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     bottom: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     left: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     right: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                   )),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     singleitemvar[i]
//                                                         .varname,
//                                                     textAlign:
//                                                     TextAlign
//                                                         .center,
//                                                     style: TextStyle(
//                                                         fontSize:
//                                                         14,  color: singleitemvar[i].varcolor
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                       child: Row(
//                                                         children: <
//                                                             Widget>[
//                                                           _checkmembership
//                                                               ? Row(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: <
//                                                                 Widget>[
//                                                               memberpriceDisplay
//                                                                   ? Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                   Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                                 ],
//                                                               )
//                                                                   : discountDisplay
//                                                                   ? Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                   Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                                 ],
//                                                               )
//                                                                   : Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           )
//                                                               : discountDisplay
//                                                               ? Column(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                               Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                             ],
//                                                           )
//                                                               : Column(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                             ],
//                                                           )
//                                                         ],
//                                                       )),
//                                                   Icon(
//                                                       Icons
//                                                           .radio_button_checked_outlined,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor)
//                                                 ],
//                                               )),
//                                         )
//                                             : Container(
//                                             padding:
//                                             EdgeInsets.all(10.0),
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width -
//                                                 20,
//                                             height: 60.0,
//                                             alignment: Alignment.center,
//                                             margin: EdgeInsets.only(
//                                                 bottom: 10.0),
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.fill,
//                                                 borderRadius:
//                                                 BorderRadius
//                                                     .circular(5.0),
//                                                 border: Border(
//                                                   top: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   bottom: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   left: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   right: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                 )),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   singleitemvar[i]
//                                                       .varname,
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontSize:
//                                                       14,  color: singleitemvar[i].varcolor
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                     child: Row(
//                                                       children: <Widget>[
//                                                         _checkmembership
//                                                             ? Row(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                           children: <
//                                                               Widget>[
//                                                             memberpriceDisplay
//                                                                 ? Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                                 Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                               ],
//                                                             )
//                                                                 : discountDisplay
//                                                                 ? Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                                 Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                               ],
//                                                             )
//                                                                 : Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             )
//                                                           ],
//                                                         )
//                                                             : discountDisplay
//                                                             ? Column(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment.center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment.center,
//                                                           children: [
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varprice,
//                                                                 style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varmrp,
//                                                                 style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                           ],
//                                                         )
//                                                             : Column(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment.center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment.center,
//                                                           children: [
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varmrp,
//                                                                 style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                           ],
//                                                         )
//                                                       ],
//                                                     )),
//                                                 Icon(
//                                                     Icons
//                                                         .radio_button_checked_outlined,
//                                                     color:
//                                                     singleitemvar[i]
//                                                         .varcolor)
//                                               ],
//                                             ))
// //                                              Spacer(),
//                                       ],
//                                     ),
                                              ),
                                              //Divider(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),*/
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (_ismanufacturer)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Origine:  ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                          Text(itemmanufact,style: TextStyle(fontSize: 14,),),
                                        ],
                                      ),
                                    if(_isdescription)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical:8.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(translate('forconvience.Discription')+":  ",//"Discription:  ",
                                              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            Text(itemdescription,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w100),),
                                          ],
                                        ),
                                      ),
                                    ///itemmanufact

                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    /*  Row(
                                    children: [
                                      SizedBox(width: 10),
                                      GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            final shoplistData =
                                                Provider.of<BrandItemsList>(context,
                                                    listen: false);

                                            if (shoplistData.itemsshoplist.length <=
                                                0) {
                                              _dialogforCreatelistTwo(
                                                  context, shoplistData);
                                              //_dialogforShoppinglist(context);
                                            } else {
                                              _dialogforShoppinglistTwo(context);
                                            }
                                          },
                                          child: Row(
                                            children: [
                                            Icon(
                                               Icons.list_alt_outlined,
                                               color: Colors.grey,
                                             ),
                                              SizedBox(width: 5),
                                              Text("ADD TO LIST"),
                                            ],
                                          ),
                                      ),
                                      //     child: Icon(
                                      //       Icons.list_alt_outlined,
                                      //       color: Colors.grey,
                                      //     )),
                                      // SizedBox(width: 5),
                                      // Text("ADD TO LIST"),
                                      Spacer(),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            if (Platform.isIOS) {
                                              Share.share('Download ' +
                                                  IConstants.APP_NAME +
                                                  ' from App Store https://apps.apple.com/us/app/id1563407384');
                                            } else {
                                              Share.share('Download ' +
                                                  IConstants.APP_NAME +
                                                  ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
                                            }
                                          },
                                          child: Icon(
                                            Icons.share_outlined,
                                            color: Colors.grey,
                                          )),
                                      SizedBox(width: 5),
                                      Text("SHARE"),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 25.0,
                                  ),*/
                                    /*Divider(
                                    thickness: 5,
                                  ),*/
                                    SizedBox(
                                      height: 25.0,
                                    ),
                                    _similarProduct
                                        ? Container(
                                      child: Column(
                                        children: <Widget>[
                                          new Row(
                                            children: <Widget>[
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                sellingitemData.newitemname,
                                                style: TextStyle(
                                                    fontSize: 20.0,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10.0),
                                          new Row(
                                            children: <Widget>[
                                              Expanded(
                                                  child: SizedBox(
                                                    height: 275.0,
                                                    child: new ListView.builder(
                                                      shrinkWrap: true,
                                                      scrollDirection:
                                                      Axis.horizontal,
                                                      itemCount: sellingitemData
                                                          .itemsnew.length,
                                                      itemBuilder: (_, i) => Column(
                                                        children: [
                                                          Items(
                                                            "singleproduct_screen",
                                                            sellingitemData
                                                                .itemsnew[i].id,
                                                            sellingitemData
                                                                .itemsnew[i].title,
                                                            sellingitemData
                                                                .itemsnew[i]
                                                                .imageUrl,
                                                            sellingitemData
                                                                .itemsnew[i].brand,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                        : Container(),
                                  ],
                                ),
                              ),
                            ),
                            /*Container(
                              padding: EdgeInsets.only(right: 10),
                              width: MediaQuery.of(context).size.width / 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        singleitemData.singleitems[0].brand,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      //Spacer(),
                                      //Padding(padding: EdgeInsets.only(left: 500)),
                                      if (_checkmargin)
                                        Container(
                                          width: 88,
                                          height: 25,
                                          margin: EdgeInsets.only(left: 5.0),
                                          padding: EdgeInsets.all(3.0),
                                          // color: Theme.of(context).accentColor,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(3.0),
                                            color: ColorCodes.accentColor,
                                          ),
                                          *//*constraints: BoxConstraints(
                                            minWidth: 38,
                                            minHeight: 18,
                                          ),*//*
                                          child: Text(
                                            translate('forconvience.OFF') + " " + margins + "% ",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color:
                                                Theme
                                                    .of(context)
                                                    .buttonColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.only(top: 10)),
                                      Text(
                                        singleitemData.singleitems[0].title,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      _checkmembership
                                          ? Row(
                                        children: <Widget>[
                                          memberpriceDisplay
                                              ? Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              new RichText(
                                                  text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize:
                                                        14.0,
                                                        color:
                                                        Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                            'Product MRP: ',
                                                            style:
                                                            new TextStyle(fontSize: 16.0)),
                                                        new TextSpan(
                                                            text:
                                                                '$varmrp '+_currencyFormat ,
                                                            style: new TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16.0))
                                                      ])),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 25.0,
                                                    height: 25.0,
                                                    child: Image
                                                        .asset(
                                                      Images.starImg,
                                                    ),
                                                  ),
                                                  new RichText(
                                                      text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize:
                                                            14.0,
                                                            color:
                                                            Colors.black,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                                text:
                                                                'Selling Price: ',
                                                                style:
                                                                new TextStyle(fontSize: 16.0)),
                                                            new TextSpan(
                                                                text:
                                                                    '$varmemberprice '+ _currencyFormat ,
                                                                style: new TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 16.0))
                                                          ])),
                                                ],
                                              ),
                                            ],
                                          )
                                              : discountDisplay
                                              ? Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              new RichText(
                                                  text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize:
                                                        14.0,
                                                        color:
                                                        Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                            'Product MRP: ',
                                                            style:
                                                            new TextStyle(fontSize: 20.0, color: Colors.grey)),
                                                        new TextSpan(
                                                            text:
                                                                '$varmrp '+ _currencyFormat ,
                                                            style: TextStyle(
                                                                decoration: TextDecoration
                                                                    .lineThrough,
                                                                fontSize: 20,
                                                                color: Colors.grey))
                                                      ])),
                                              Row(
                                                children: [
                                                  Container(
                                                    width:
                                                    25.0,
                                                    height:
                                                    25.0,
                                                    child: Image
                                                        .asset(
                                                      Images.starImg,
                                                    ),
                                                  ),
                                                  Text(

                                                          '$varprice '+_currencyFormat ,
                                                      style: new TextStyle(
                                                          fontWeight:
                                                          FontWeight.bold,
                                                          fontSize: 16.0)),
                                                ],
                                              ),
                                            ],
                                          )
                                              : Row(
                                            children: [
                                              Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image
                                                    .asset(
                                                  Images.starImg,
                                                ),
                                              ),
                                              new RichText(
                                                  text: new TextSpan(
                                                      style: new TextStyle(
                                                        fontSize:
                                                        14.0,
                                                        color:
                                                        Colors.black,
                                                      ),
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                            'Selling Price: ',
                                                            style:
                                                            new TextStyle(fontSize: 16.0)),
                                                        new TextSpan(
                                                            text:
                                                                '$varmrp '+ _currencyFormat ,
                                                            style: new TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16.0))
                                                      ])),
                                            ],
                                          )
                                        ],
                                      )
                                          : discountDisplay
                                          ? Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          new RichText(
                                              text: new TextSpan(
                                                  style:
                                                  new TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors
                                                        .black,
                                                  ),
                                                  children: <
                                                      TextSpan>[
                                                    new TextSpan(
                                                        text:
                                                        'Product MRP: ',
                                                        style: new TextStyle(
                                                            fontSize:
                                                            20.0, color: Colors.grey)),
                                                    new TextSpan(
                                                        text:
                                                            ' $varmrp '+ _currencyFormat ,
                                                        style: TextStyle(
                                                            decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                            fontSize:
                                                            20,
                                                            color: Colors.grey))
                                                  ])),
                                          Padding(padding: EdgeInsets.only(bottom: 20)),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              new RichText(
                                                  text: new TextSpan(
                                                      style:
                                                      new TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors
                                                            .black,
                                                      ),
                                                      children: <TextSpan>[
                                                        new TextSpan(
                                                            text:
                                                            'Selling Price: ',
                                                            style: new TextStyle(
                                                                fontSize:
                                                                20.0)),
                                                        new TextSpan(
                                                            text:
                                                                ' $varprice  '+_currencyFormat ,
                                                            style: new TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                                fontSize:
                                                                20.0))
                                                      ])),
                                              //Spacer(),
                                              //Padding(padding: EdgeInsets.only(left: 400)),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      Images.coinImg,
                                                      height: 25.0,
                                                      width: 30.0,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text("10", style: TextStyle(
                                                      fontSize: 19,
                                                    ),),

                                                  ],
                                                ),
                                              ),



                                            ],
                                          ),

                                        ],
                                      )
                                          : Container(
                                        child: Row(
                                          children: [
                                            RichText(
                                                text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 14.0,
                                                      color: Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                          text:
                                                          'Selling Price: ',
                                                          style:
                                                          new TextStyle(
                                                              fontSize:
                                                              20.0)),

                                                      new TextSpan(
                                                          text:

                                                              '$varmrp '+ _currencyFormat ,
                                                          style: new TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                              fontSize: 20.0))
                                                    ])),
                                            Spacer(),
                                            //Padding(padding: EdgeInsets.only(left: 200)),
                                            Text("10"),
                                            SizedBox(width: 4),
                                            Image.asset(
                                              Images.coinImg,
                                              height: 15.0,
                                              width: 20.0,
                                            ),
                                          ],

                                        ),
                                      ),
                                      *//*Text(
                                        "(Inclusive of all taxes)",
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),*//*

                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 20),
                                    width: MediaQuery.of(context).size.width / 1.7,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        *//*  SizedBox(
                                              height: 10,
                                          ),*//*
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _quantityPopup();
                                            });
                                          },
                                          child:
                                          Container(
                                            width: 200,
                                            child: Row(

                                              children: [
                                                SizedBox(
                                                  height: 10.0,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Color(0xff32B847)),
                                                        borderRadius: new BorderRadius.only(
                                                          topLeft: const Radius.circular(2.0),
                                                          bottomLeft: const Radius.circular(2.0),
                                                        )),
                                                    height: 30,
                                                    padding: EdgeInsets.fromLTRB(5.0, 4.5, 5.0, 4.5),
                                                    child: Text(
                                                      "$varname",
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff32B847),
                                                      borderRadius: new BorderRadius.only(
                                                        topRight: const Radius.circular(2.0),
                                                        bottomRight: const Radius.circular(2.0),
                                                      )),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),




                                        //SizedBox(width: 300),

                                        //Spacer(),

                                        _addButton(),

                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      !_checkmembership
                                          ? membershipdisplay
                                          ? GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                            MembershipScreen.routeName,
                                          );
                                        },
                                        child: Container(
                                          height: 35,
                                          //width: (MediaQuery.of(context).size.width / 2 ),
                                          width: MediaQuery.of(context).size.width / 2.1,
                                          decoration: BoxDecoration(
                                              color: ColorCodes.beige),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 10),
                                                    Image.asset(
                                                      Images.starImg,
                                                      height: 12,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text("Membership Price:  ",
                                                        style: TextStyle(
                                                            fontSize: 16.0)),
                                                    SizedBox(width: 90),
                                                    Text(

                                                            " " +
                                                            varmemberprice+ _currencyFormat ,
                                                        style: TextStyle(
                                                            color: ColorCodes.greyColor,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.normal)),
                                                  ],
                                                ),
                                              ),

                                              //Spacer(),
                                              Container(
                                                child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.lock,
                                                        color: Colors.black,
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text('Unlock',
                                                          style: TextStyle(
                                                              color: ColorCodes.greyColor,
                                                              fontSize: 16.0)),
                                                      SizedBox(width: 10),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_sharp,
                                                        color: Colors.black,
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 10),
                                                    ]
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      )
                                          : SizedBox.shrink()
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ],
                              ),
                            ),*/
                          ],
                        ),
                      ),

                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(
                        thickness: 1.0,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (_isdescription && _ismanufacturer)
                      /*     Padding(
                          padding: const EdgeInsets.all(1.0),*/
                      //child: new
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0, left: 30, right: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Manufacturer Details:  "+itemmanufact),
                              Text(translate('forconvience.Discription')+":  "//"Discription:  "
                                  + itemdescription),


                              /*    Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  new Container(
                                    width: 500,
                                    child: new TabBar(
                                        controller: _tabController,
                                        labelColor: Colors.black,
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        indicatorColor: Colors.black,
                                        indicatorSize: TabBarIndicatorSize.tab,
                                        tabs: tabList),
                                  ),

                                  Container(
                                      child: Row(
                                        children: [
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                final shoplistData =
                                                Provider.of<BrandItemsList>(context,
                                                    listen: false);

                                                if (shoplistData.itemsshoplist.length <=
                                                    0) {
                                                  _dialogforCreatelistTwo(
                                                      context, shoplistData);
                                                  //_dialogforShoppinglist(context);
                                                } else {
                                                  _dialogforShoppinglistTwo(context);
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.list_alt_outlined,
                                                    color: Colors.grey,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text("ADD TO LIST", style: TextStyle(
                                                      fontSize: 16, color: ColorCodes.mediumBlackColor,
                                                      fontWeight: FontWeight.bold),),
                                                ],
                                              ),
                                            ),
                                          ),

                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              if (Platform.isIOS) {
                                                Share.share('Download ' +
                                                    IConstants.APP_NAME +
                                                    ' from App Store https://apps.apple.com/us/app/id1563407384');
                                              } else {
                                                Share.share('Download ' +
                                                    IConstants.APP_NAME +
                                                    ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
                                              }
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 20.0,
                                                ),
                                                Icon(Icons.share, color: Colors.grey, size: 26),
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                Text(
                                                  "Share",
                                                  style: TextStyle(
                                                      fontSize: 20, color: ColorCodes.mediumBlackColor,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                                //Spacer(),
                                              ],
                                            ),
                                          ),
                                      ],
                                      ),
                                  ),

                                ],
                              ),

                              Container(
                                height: 100,
                                child: new TabBarView(
                                  controller: _tabController,
                                  children: tabList.map((Tab tab) {
                                    return _getPage(tab);
                                  }).toList(),
                                ),
                              )*/
                            ],
                          ),
                        ),
                      //),
                      SizedBox(
                        height: 5.0,
                      ),




                      Container(
                        margin: EdgeInsets.only(
                            left: 10, top: 20, right: 10, bottom: 20),
                        child: Column(
                          children: <Widget>[

                            _similarProduct
                                ? Container(
                              child: Column(
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Text(
                                        sellingitemData.newitemname,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.0),
                                  new Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: SizedBox(
                                            height: 270.0,
                                            child: new ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection:
                                              Axis.horizontal,
                                              itemCount: sellingitemData
                                                  .itemsnew.length,
                                              itemBuilder: (_, i) =>
                                                  Column(
                                                    children: [
                                                      Items(
                                                        "singleproduct_screen",
                                                        sellingitemData
                                                            .itemsnew[i].id,
                                                        sellingitemData
                                                            .itemsnew[i].title,
                                                        sellingitemData
                                                            .itemsnew[i]
                                                            .imageUrl,
                                                        sellingitemData
                                                            .itemsnew[i].brand,
                                                      ),
                                                    ],
                                                  ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            )
                                : Container(),
                          ],
                        ),
                      ),
                      //if (ResponsiveLayout.isSmallScreen(context) || ResponsiveLayout.isMediumScreen(context) || ResponsiveLayout.isLargeScreen(context))
                      _footer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }



    Widget mobileBody() {
      return SafeArea(
        child: _isLoading
            ? Center(
          child: new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    !_isStock
                        ? Consumer<Calculations>(
                      builder: (_, cart, ch) => BadgeOfStock(
                        child: ch,
                        value: margins,
                        singleproduct: true,
                        item: false,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                              SingleProductImageScreen.routeName,
                              arguments: {
                                "itemid": itemid,
                                "itemname": itemname,
                                "itemimg": itemimg,
                              });
                        },
                        child: GFCarousel(
                          autoPlay: true,
                          viewportFraction: 1.0,
                          height: 173,
                          pagination: true,
                          passiveIndicator: Colors.white,
                          activeIndicator:
                          Theme.of(context).accentColor,
                          autoPlayInterval: Duration(seconds: 8),
                          items: <Widget>[
                            for (var i = 0;
                            i < multiimage.length;
                            i++)
                              Builder(
                                builder: (BuildContext context) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    5.0)),
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                multiimage[i]
                                                    .imageUrl,
                                                placeholder: (context,
                                                    url) =>
                                                    Image.asset(
                                                        Images.defaultProductImg),
                                                fit: BoxFit.fill))),
                                  );
                                },
                              )
                          ],
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            SingleProductImageScreen.routeName,
                            arguments: {
                              "itemid": itemid,
                              "itemname": itemname,
                              "itemimg": itemimg,
                            });
                      },
                      child: GFCarousel(
                        autoPlay: true,
                        viewportFraction: 1.0,
                        height: 173,
                        pagination: true,
                        passiveIndicator: Colors.white,
                        activeIndicator:
                        Theme.of(context).accentColor,
                        autoPlayInterval: Duration(seconds: 8),
                        items: <Widget>[
                          for (var i = 0; i < multiimage.length; i++)
                            Builder(
                              builder: (BuildContext context) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 5.0),
                                      child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.all(
                                              Radius.circular(
                                                  5.0)),
                                          child: CachedNetworkImage(
                                              imageUrl: multiimage[i]
                                                  .imageUrl,
                                              placeholder: (context,
                                                  url) =>
                                                  Image.asset(
                                                      Images.defaultProductImg),
                                              fit: BoxFit.fill))),
                                );
                              },
                            )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20.0, top: 20.0, right: 10.0, bottom: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                singleitemData.singleitems[0].title,
                                style: TextStyle(
                                    fontSize: 20,
                                    color:Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              if(double.parse(varLoyalty.toString()) > 0)
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.coinImg,
                                        height: 20.0,
                                        width: 20.0,),
                                      SizedBox(width: 4),
                                      Text(varLoyalty.toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if(discountDisplay)
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [

                              /* Text(
                                      singleitemData.singleitems[0].brand,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),*/
                              if(discountDisplay)
                              new RichText(
                                  text: new TextSpan(
                                      style:
                                      new TextStyle(
                                      //  fontSize: 18.0,
                                        color: Colors
                                            .black,
                                      ),
                                      children: <
                                          TextSpan>[
                                        new TextSpan(
                                            text:
                                                '$varmrp '+_currencyFormat ,
                                            style: TextStyle(
                                                decoration:
                                                TextDecoration
                                                    .lineThrough,
                                                fontSize:
                                                16,
                                                color: Colors
                                                    .grey))
                                      ])),
                              if (_checkmargin)
                                Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  padding: EdgeInsets.all(3.0),
                                  // color: Theme.of(context).accentColor,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(3.0),
                                    color: Color(0xffFF9400),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 28,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    translate('forconvience.OFF')+" "+margins + " % ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color:
                                        Theme.of(context).buttonColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),

                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                /* width:
                                          MediaQuery.of(context).size.width / 2 +
                                              40,*/
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: <Widget>[

                                    _checkmembership
                                        ? Row(
                                      children: <Widget>[
                                        memberpriceDisplay
                                            ? Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            new RichText(
                                                text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize:
                                                      14.0,
                                                      color:
                                                      Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                     /* new TextSpan(
                                                          text:
                                                          'Product MRP: ',
                                                          style:
                                                          new TextStyle(fontSize: 16.0)),*/
                                                      new TextSpan(
                                                          text:
                                                              '$varmrp '+_currencyFormat ,
                                                          style: new TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 25.0))
                                                    ])),
                                            Row(
                                              children: [
                                                Container(
                                                  width: 25.0,
                                                  height: 25.0,
                                                  child: Image
                                                      .asset(
                                                    Images.starImg,
                                                  ),
                                                ),
                                                new RichText(
                                                    text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize:
                                                          14.0,
                                                          color:
                                                          Colors.black,
                                                        ),
                                                        children: <TextSpan>[
                                                         /* new TextSpan(
                                                              text:
                                                              'Selling Price: ',
                                                              style:
                                                              new TextStyle(fontSize: 16.0)),*/
                                                          new TextSpan(
                                                              text:
                                                                  '$varmemberprice '+_currencyFormat ,
                                                              style: new TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 25.0))
                                                        ])),
                                              ],
                                            ),
                                          ],
                                        )
                                            : discountDisplay
                                            ? Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            new RichText(
                                                text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize:
                                                      14.0,
                                                      color:
                                                      Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                          text:
                                                          'Product MRP: ',
                                                          style:
                                                          new TextStyle(fontSize: 16.0)),
                                                      new TextSpan(
                                                          text:
                                                              '$varmrp '+ _currencyFormat ,
                                                          style: TextStyle(
                                                              decoration: TextDecoration.lineThrough,
                                                              fontSize: 12,
                                                              color: Colors.grey))
                                                    ])),
                                            Row(
                                              children: [
                                                Container(
                                                  width:
                                                  25.0,
                                                  height:
                                                  25.0,
                                                  child: Image
                                                      .asset(
                                                    Images.starImg,
                                                  ),
                                                ),
                                                Text(

                                                        '$varprice '+ _currencyFormat ,
                                                    style: new TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16.0)),
                                              ],
                                            ),
                                          ],
                                        )
                                            : Row(
                                          children: [
                                            Container(
                                              width: 25.0,
                                              height: 25.0,
                                              child: Image
                                                  .asset(
                                                Images.starImg,
                                              ),
                                            ),
                                            new RichText(
                                                text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize:
                                                      14.0,
                                                      color:
                                                      Colors.black,
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                          text:
                                                          'Selling Price: ',
                                                          style:
                                                          new TextStyle(fontSize: 16.0)),
                                                      new TextSpan(
                                                          text:
                                                              '$varmrp '+ _currencyFormat ,
                                                          style: new TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 16.0))
                                                    ])),
                                          ],
                                        )
                                      ],
                                    )
                                        : discountDisplay
                                        ? Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [

                                        new RichText(
                                            text: new TextSpan(
                                                style:
                                                new TextStyle(
                                                 // fontSize: 14.0,
                                                  color: Colors
                                                      .black,
                                                ),
                                                children: <
                                                    TextSpan>[
                                                  new TextSpan(
                                                      text:
                                                          '$varprice '+_currencyFormat ,
                                                      style: new TextStyle(
                                                          color: Theme.of(context).primaryColor,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold,
                                                          fontSize:
                                                          20.0))
                                                ])),
                                      ],
                                    )
                                        :
                                    new RichText(
                                        text: new TextSpan(
                                            style: new TextStyle(
                                              //fontSize: 14.0,
                                              color: Colors.black,
                                            ),
                                            children: <TextSpan>[
                                              /*new TextSpan(
                                                  text:
                                                  'Selling Price: ',
                                                  style:
                                                  new TextStyle(
                                                      fontSize:
                                                      16.0)),*/
                                              new TextSpan(
                                                  text:

                                                      '$varmrp '+ _currencyFormat ,
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize: 20.0))
                                            ])),
                                    Center (
                                      child: Text(
                                        ' /'+singleitemvar[0] .varname,

                                        textAlign: TextAlign .center,
                                        style: TextStyle(
                                            fontSize: 18,
                                          color: ColorCodes
                                              .varcolor,
                                        ),
                                      ),
                                    ),
                                    /* Text(
                                            "(Inclusive of all taxes)",
                                            style: TextStyle(
                                                fontSize: 8, color: Colors.grey),
                                          ),*/

                                  ],
                                ),
                              ),
                              Container(
                                /*  width:
                                          MediaQuery.of(context).size.width / 2 -
                                              60,*/
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    /*  if(double.parse(varLoyalty.toString()) > 0)
                                          Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Image.asset(Images.coinImg,
                                                  height: 15.0,
                                                  width: 20.0,),
                                                SizedBox(width: 4),
                                                Text(varLoyalty.toString()),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),*/
                                    _isStock
                                        ? Container(
                                      height: 30.0,
                                      width: (MediaQuery.of(context)
                                          .size
                                          .width /
                                          4) +
                                          20,
                                      child: ValueListenableBuilder(
                                        valueListenable:
                                        Hive.box<Product>(
                                            productBoxName)
                                            .listenable(),
                                        builder: (context,
                                            Box<Product> box, _) {
                                          if (box.values.length <= 0)
                                            return GestureDetector(
                                              onTap: () {
                                                addToCart(int.parse(
                                                    varminitem));
                                              },
                                              child: Container(
                                                height: 30.0,
                                                width: (MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width /
                                                    4) +
                                                    15,
                                                decoration:
                                                new BoxDecoration(
                                                    color: Color(
                                                        0xff32B847),
                                                    borderRadius:
                                                    new BorderRadius
                                                        .only(
                                                      topLeft:
                                                      const Radius.circular(
                                                          2.0),
                                                      topRight:
                                                      const Radius.circular(
                                                          2.0),
                                                      bottomLeft:
                                                      const Radius.circular(
                                                          2.0),
                                                      bottomRight:
                                                      const Radius.circular(
                                                          2.0),
                                                    )),
                                                child:
                                                /*Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 10,
                                                                ),*/
                                                Center(
                                                    child: Text(
                                                      translate('forconvience.ADD'),
                                                      style:
                                                      TextStyle(
                                                        color: Theme.of(
                                                            context)
                                                            .buttonColor,
                                                        fontSize: 12,
                                                      ),
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                    )),
                                                //  Spacer(),
                                                /* Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color: Color(
                                                                              0xff1BA130),
                                                                          borderRadius:
                                                                              new BorderRadius.only(
                                                                            topLeft:
                                                                                const Radius.circular(2.0),
                                                                            bottomLeft:
                                                                                const Radius.circular(2.0),
                                                                            topRight:
                                                                                const Radius.circular(2.0),
                                                                            bottomRight:
                                                                                const Radius.circular(2.0),
                                                                          )),
                                                                  height: 30,
                                                                  width: 25,
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),*/
                                                //],
                                                //  ),
                                              ),
                                            );

                                          try {
                                            Product item = Hive.box<
                                                Product>(
                                                productBoxName)
                                                .values
                                                .firstWhere((value) =>
                                            value.varId ==
                                                int.parse(varid));
                                            return Container(
                                              child: Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () async {
                                                      if (item.itemQty ==
                                                          int.parse(
                                                              varminitem)) {
                                                        for (int i =
                                                        0;
                                                        i <
                                                            productBox
                                                                .values
                                                                .length;
                                                        i++) {
                                                          if (productBox
                                                              .values
                                                              .elementAt(
                                                              i)
                                                              .varId ==
                                                              int.parse(
                                                                  varid)) {
                                                            productBox
                                                                .deleteAt(
                                                                i);
                                                            break;
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          incrementToCart(
                                                              item.itemQty -
                                                                  1);
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                        new BoxDecoration(
                                                            border: Border
                                                                .all(
                                                              color:
                                                              Color(0xff32B847),
                                                            ),
                                                            borderRadius:
                                                            new BorderRadius.only(
                                                              bottomLeft:
                                                              const Radius.circular(2.0),
                                                              topLeft:
                                                              const Radius.circular(2.0),
                                                            )),
                                                        child: Center(
                                                          child: Text(
                                                            "-",
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                            style:
                                                            TextStyle(
                                                              color: Color(
                                                                  0xff32B847),
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                  Expanded(
                                                    child: Container(
//                                            width: 40,
                                                        decoration:
                                                        BoxDecoration(
                                                          color: Color(
                                                              0xff32B847),
                                                        ),
                                                        height: 30,
                                                        child: Center(
                                                          child: Text(
                                                            item.itemQty
                                                                .toString(),
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                            style:
                                                            TextStyle(
                                                              color: Theme.of(context)
                                                                  .buttonColor,
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      if (item.itemQty <
                                                          int.parse(
                                                              varstock)) {
                                                        if (item.itemQty <
                                                            int.parse(
                                                                varmaxitem)) {
                                                          incrementToCart(
                                                              item.itemQty +
                                                                  1);
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                              translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                                              backgroundColor:
                                                              Colors
                                                                  .black87,
                                                              textColor:
                                                              Colors.white);
                                                        }
                                                      } else {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                            "Sorry, Out of Stock!",
                                                            backgroundColor:
                                                            Colors
                                                                .black87,
                                                            textColor:
                                                            Colors
                                                                .white);
                                                      }
                                                    },
                                                    child: Container(
                                                        width: 30,
                                                        height: 30,
                                                        decoration:
                                                        new BoxDecoration(
                                                            border: Border
                                                                .all(
                                                              color:
                                                              Color(0xff32B847),
                                                            ),
                                                            borderRadius:
                                                            new BorderRadius.only(
                                                              bottomRight:
                                                              const Radius.circular(2.0),
                                                              topRight:
                                                              const Radius.circular(2.0),
                                                            )),
                                                        child: Center(
                                                          child: Text(
                                                            "+",
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                            style:
                                                            TextStyle(
                                                              color: Color(
                                                                  0xff32B847),
                                                            ),
                                                          ),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } catch (e) {
                                            return GestureDetector(
                                              onTap: () {
                                                addToCart(int.parse(
                                                    varminitem));
                                              },
                                              child: Container(
                                                height: 30.0,
                                                width: (MediaQuery.of(
                                                    context)
                                                    .size
                                                    .width /
                                                    4) +
                                                    15,
                                                decoration:
                                                new BoxDecoration(
                                                    color: Color(
                                                        0xff32B847),
                                                    borderRadius:
                                                    new BorderRadius
                                                        .only(
                                                      topLeft:
                                                      const Radius.circular(
                                                          2.0),
                                                      topRight:
                                                      const Radius.circular(
                                                          2.0),
                                                      bottomLeft:
                                                      const Radius.circular(
                                                          2.0),
                                                      bottomRight:
                                                      const Radius.circular(
                                                          2.0),
                                                    )),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                   /* SizedBox(
                                                      width: 10,
                                                    ),*/
                                                    Center(
                                                        child: Text(
                                                          translate('forconvience.ADD'),
                                                          style:
                                                          TextStyle(
                                                            color: Theme.of(
                                                                context)
                                                                .buttonColor, fontSize: 12,
                                                          ),
                                                          textAlign:
                                                          TextAlign
                                                              .center,
                                                        )),
                                                   // Spacer(),
                                                   /* Container(
                                                      decoration:
                                                      BoxDecoration(
                                                          color: Color(
                                                              0xff1BA130),
                                                          borderRadius:
                                                          new BorderRadius.only(
                                                            topLeft:
                                                            const Radius.circular(2.0),
                                                            bottomLeft:
                                                            const Radius.circular(2.0),
                                                            topRight:
                                                            const Radius.circular(2.0),
                                                            bottomRight:
                                                            const Radius.circular(2.0),
                                                          )),
                                                      height: 30,
                                                      width: 25,
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 12,
                                                        color: Colors
                                                            .white,
                                                      ),
                                                    ),*/
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    )
                                        : GestureDetector(
                                      onTap: () {
                                        Fluttertoast.showToast(
                                            msg:  /*"You will be notified via SMS/Push notification, when the product is available"  */
                                            translate('forconvience.Out of stock popup'), //"Out Of Stock",
                                            fontSize: 12.0,
                                            backgroundColor:
                                            Colors.black87,
                                            textColor: Colors.white);
                                      },
                                      child: Container(
                                        height: 30.0,
                                        width: (MediaQuery.of(context).size.width / 4) + 15,
                                        decoration: new BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey),
                                            color: Colors.grey,
                                            borderRadius:
                                            new BorderRadius.only(
                                              topLeft: const Radius
                                                  .circular(2.0),
                                              topRight: const Radius
                                                  .circular(2.0),
                                              bottomLeft: const Radius
                                                  .circular(2.0),
                                              bottomRight:
                                              const Radius
                                                  .circular(2.0),
                                            )),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                         // crossAxisAlignment:CrossAxisAlignment.center,
                                          children: [
                                           /* SizedBox(
                                              width: 10,
                                            ),*/
                                            Center(
                                                child: Text(
                                                  /*'Notify Me'*/
                                                  translate('forconvience.ADD'),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors
                                                          .white ,
                                                    fontSize: 10,),
                                                  textAlign:
                                                  TextAlign.center,
                                                )),
                                          //  Spacer(),
                                           /* Container(
                                              decoration:
                                              BoxDecoration(
                                                  color: Colors
                                                      .black12,
                                                  borderRadius:
                                                  new BorderRadius
                                                      .only(
                                                    topRight:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                    bottomRight:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                  )),
                                              height: 30,
                                              width: 25,
                                              child: Icon(
                                                Icons.add,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          /*!_checkmembership
                                    ? membershipdisplay
                                        ? SizedBox(
                                            height: 10,
                                          )
                                        : SizedBox(
                                            height: 1,
                                          )
                                    : SizedBox(
                                        height: 1,
                                      ),*/
                          /*   Row(
                                  children: [
                                    !_checkmembership
                                        ? membershipdisplay
                                            ? GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).pushNamed(
                                                    MembershipScreen.routeName,
                                                  );
                                                },
                                                child: Container(
                                                  height: 35,
                                                  width: (MediaQuery.of(context)
                                                          .size
                                                          .width) -
                                                      20,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffEBF5FF)),
                                                  child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      SizedBox(width: 10),
                                                      Image.asset(
                                                        Images.starImg,
                                                        height: 12,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text("MembershipPrice:  ",
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                      Text(
                                                          _currencyFormat +
                                                              " " +
                                                              varmemberprice,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize: 14.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Spacer(),
                                                      Icon(
                                                        Icons.lock,
                                                        color: Colors.black,
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 2),
                                                      Icon(
                                                        Icons
                                                            .arrow_forward_ios_sharp,
                                                        color: Colors.black,
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 10),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox.shrink()
                                        : SizedBox.shrink(),
                                  ],
                                ),*/
                          /*  SizedBox(
                                  height: 20.0,
                                ),
                                Text(
                                  "Pack Sizes",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),*/
                          /*new ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: singleitemvar.length,
                                  itemBuilder: (_, i) => Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            for (int k = 0; k < singleitemvar.length; k++) {
                                              if (i == k) {
                                                singleitemvar[k].varcolor = Color(0xff012961);
                                              } else {
                                                singleitemvar[k].varcolor = Color(0xffBEBEBE);
                                              }
                                              setState(() {
                                                varmemberprice = singleitemvar[i] .varmemberprice;
                                                varmrp = singleitemvar[i].varmrp;
                                                varprice = singleitemvar[i].varprice;
                                                varid = singleitemvar[i].varid;
                                                varname = singleitemvar[i].varname;
                                                varstock = singleitemvar[i].varstock;
                                                varminitem = singleitemvar[i].varminitem;
                                                varmaxitem = singleitemvar[i].varmaxitem;
                                                varLoyalty = singleitemvar[i].varLoyalty;
                                                varcolor = singleitemvar[i].varcolor;
                                                discountDisplay = singleitemvar[i] .discountDisplay;
                                                memberpriceDisplay = singleitemvar[i].membershipDisplay;

                                                if (varmemberprice == '-' ||
                                                    varmemberprice == "0") {
                                                  setState(() {
                                                    membershipdisplay = false;
                                                  });
                                                } else {
                                                  membershipdisplay = true;
                                                }

                                                if (_checkmembership) {
                                                  if (varmemberprice.toString() == '-' ||
                                                      double.parse(varmemberprice) <= 0) {
                                                    if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                                      margins = "0";
                                                    } else {
                                                      var difference = (double.parse(varmrp) - double.parse(varprice));
                                                      var profit = difference / double.parse(varmrp);
                                                      margins = profit * 100;

                                                      //discount price rounding
                                                      margins = num.parse(margins.toStringAsFixed(0));
                                                      margins = margins.toString();
                                                    }
                                                  } else {
                                                    var difference = (double.parse(varmrp) - double.parse(varmemberprice));
                                                    var profit = difference / double.parse(varmrp);
                                                    margins = profit * 100;

                                                    //discount price rounding
                                                    margins = num.parse(margins.toStringAsFixed(0));
                                                    margins = margins.toString();
                                                  }
                                                } else {
                                                  if (double.parse(varmrp) <= 0 || double.parse(varprice) <= 0) {
                                                    margins = "0";
                                                  } else {
                                                    var difference = (double.parse(varmrp) - double.parse(varprice));
                                                    var profit = difference / double.parse(varmrp);
                                                    margins = profit * 100;

                                                    //discount price rounding
                                                    margins = num.parse(margins.toStringAsFixed(0));
                                                    margins = margins.toString();
                                                  }
                                                }

                                                if (margins == "NaN") {
                                                  _checkmargin = false;
                                                } else {
                                                  if (int.parse(margins) <= 0) {
                                                    _checkmargin = false;
                                                  } else {
                                                    _checkmargin = true;
                                                  }
                                                }
                                                multiimage = Provider.of<ItemsList>(context, listen: false).findByIdmulti(varid);
                                                _displayimg = multiimage[0].imageUrl;
                                                for (int j = 0; j < multiimage.length; j++) {
                                                  if (j == 0) {
                                                    multiimage[j].varcolor = Color(0xff114475);
                                                  } else {
                                                    multiimage[j].varcolor = Color(0xffBEBEBE);
                                                  }
                                                }
                                              });
                                            }
                                            setState(() {
                                              if (int.parse(varstock) <= 0) {
                                                _isStock = false;
                                              } else {
                                                _isStock = true;
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
//                                              Spacer(),
                                              _checkmargin
                                                  ? Consumer<Calculations>(
                                                      builder: (_, cart, ch) =>
                                                          Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: BadgeDiscount(
                                                          child: ch,
                                                          value: */
                          /*margins*/
                          /*_varMarginList[i],
                                                        ),
                                                      ),
                                                      child: Container(
                                                          padding: EdgeInsets.all(10.0),
                                                          width: MediaQuery.of(context).size.width - 20,
                                                          //height: 60.0,
                                                          alignment: Alignment.center,
                                                          margin: EdgeInsets.only(
                                                              bottom: 10.0),
                                                          decoration:
                                                              BoxDecoration(
                                                                  color: ColorCodes.fill,
                                                                  borderRadius:
                                                                      BorderRadius .circular(5.0),
                                                                  border: Border(
                                                                    top: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                    bottom: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                    left: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                    right: BorderSide(width: 1.0, color: singleitemvar[i].varcolor),
                                                                  )),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                singleitemvar[i] .varname,
                                                                textAlign: TextAlign .center,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                    color: singleitemvar[i].varcolor
                                                                ),
                                                              ),
                                                              Container(
                                                                  child: Row(
                                                                children: <
                                                                    Widget>[
                                                                  _checkmembership
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            memberpriceDisplay
                                                                                ? Column(
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 25.0,
                                                                                            height: 25.0,
                                                                                            child: Image.asset(
                                                                                              Images.starImg,
                                                                                            ),
                                                                                          ),
                                                                                          Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                        ],
                                                                                      ),
                                                                                      Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                    ],
                                                                                  )
                                                                                : discountDisplay
                                                                                    ? Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 25.0,
                                                                                                height: 25.0,
                                                                                                child: Image.asset(
                                                                                                  Images.starImg,
                                                                                                ),
                                                                                              ),
                                                                                              Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                            ],
                                                                                          ),
                                                                                          Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                        ],
                                                                                      )
                                                                                    : Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 25.0,
                                                                                                height: 25.0,
                                                                                                child: Image.asset(
                                                                                                  Images.starImg,
                                                                                                ),
                                                                                              ),
                                                                                              Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                          ],
                                                                        )
                                                                      : discountDisplay
                                                                          ? Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                              ],
                                                                            )
                                                                          : Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.center,
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.center,
                                                                              children: [
                                                                                Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                              ],
                                                                            )
                                                                ],
                                                              )),
                                                              Icon(
                                                                  Icons
                                                                      .radio_button_checked_outlined,
                                                                  color:
                                                                      singleitemvar[
                                                                              i]
                                                                          .varcolor)
                                                            ],
                                                          )),
                                                    )
                                                  : Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width -
                                                              20,
                                                      //height: 60.0,
                                                      alignment: Alignment.center,
                                                      margin: EdgeInsets.only(
                                                          bottom: 10.0),
                                                      decoration: BoxDecoration(
                                                          color: ColorCodes.fill,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5.0),
                                                          border: Border(
                                                            top: BorderSide(
                                                                width: 1.0,
                                                                color:
                                                                    singleitemvar[
                                                                            i]
                                                                        .varcolor),
                                                            bottom: BorderSide(
                                                                width: 1.0,
                                                                color:
                                                                    singleitemvar[
                                                                            i]
                                                                        .varcolor),
                                                            left: BorderSide(
                                                                width: 1.0,
                                                                color:
                                                                    singleitemvar[
                                                                            i]
                                                                        .varcolor),
                                                            right: BorderSide(
                                                                width: 1.0,
                                                                color:
                                                                    singleitemvar[
                                                                            i]
                                                                        .varcolor),
                                                          )),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            singleitemvar[i]
                                                                .varname,
                                                            textAlign:
                                                                TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  14,  color: singleitemvar[i].varcolor
                                                            ),
                                                          ),
                                                          Container(
                                                              child: Row(
                                                            children: <Widget>[
                                                              _checkmembership
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        memberpriceDisplay
                                                                            ? Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        width: 25.0,
                                                                                        height: 25.0,
                                                                                        child: Image.asset(
                                                                                          Images.starImg,
                                                                                        ),
                                                                                      ),
                                                                                      Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                    ],
                                                                                  ),
                                                                                  Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                ],
                                                                              )
                                                                            : discountDisplay
                                                                                ? Column(
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 25.0,
                                                                                            height: 25.0,
                                                                                            child: Image.asset(
                                                                                              Images.starImg,
                                                                                            ),
                                                                                          ),
                                                                                          Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                        ],
                                                                                      ),
                                                                                      Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                                    ],
                                                                                  )
                                                                                : Column(
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          Container(
                                                                                            width: 25.0,
                                                                                            height: 25.0,
                                                                                            child: Image.asset(
                                                                                              Images.starImg,
                                                                                            ),
                                                                                          ),
                                                                                          Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  )
                                                                      ],
                                                                    )
                                                                  : discountDisplay
                                                                      ? Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                                _currencyFormat + singleitemvar[i].varprice,
                                                                                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                            Text(
                                                                                _currencyFormat + singleitemvar[i].varmrp,
                                                                                style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
                                                                          ],
                                                                        )
                                                                      : Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Text(
                                                                                _currencyFormat + singleitemvar[i].varmrp,
                                                                                style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
                                                                          ],
                                                                        )
                                                            ],
                                                          )),
                                                          Icon(
                                                              Icons
                                                                  .radio_button_checked_outlined,
                                                              color:
                                                                  singleitemvar[i]
                                                                      .varcolor)
                                                        ],
                                                      ))
//                                              Spacer(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //Divider(),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),*/
                          Divider(
                            thickness: 1.0,
                          ),
                          /* Column(
                                  children: [
                                    Text("Available Quality",style: TextStyle(fontWeight: FontWeight.bold),),
                                    SizedBox(
                                      height:80,
                                      child: new ListView.builder(
                                        shrinkWrap: true,
                                        // physics: NeverScrollableScrollPhysics(),
                                        itemCount: singleitemvar.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (_, i) => Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                for (int k = 0;
                                                k < singleitemvar.length;
                                                k++) {
                                                  if (i == k) {
                                                    singleitemvar[k].varcolor =
                                                        Color(0xff012961);
                                                  } else {
                                                    singleitemvar[k].varcolor =
                                                        Color(0xffBEBEBE);
                                                  }
                                                  setState(() {
                                                    varmemberprice = singleitemvar[i]
                                                        .varmemberprice;
                                                    varmrp = singleitemvar[i].varmrp;
                                                    varprice =
                                                        singleitemvar[i].varprice;
                                                    varid = singleitemvar[i].varid;
                                                    varname =
                                                        singleitemvar[i].varname;
                                                    varstock =
                                                        singleitemvar[i].varstock;
                                                    varminitem =
                                                        singleitemvar[i].varminitem;
                                                    varmaxitem =
                                                        singleitemvar[i].varmaxitem;
                                                    varcolor =
                                                        singleitemvar[i].varcolor;
                                                    discountDisplay = singleitemvar[i]
                                                        .discountDisplay;
                                                    memberpriceDisplay =
                                                        singleitemvar[i]
                                                            .membershipDisplay;

                                                    if (varmemberprice == '-' ||
                                                        varmemberprice == "0") {
                                                      setState(() {
                                                        membershipdisplay = false;
                                                      });
                                                    } else {
                                                      membershipdisplay = true;
                                                    }

                                                    if (_checkmembership) {
                                                      if (varmemberprice.toString() ==
                                                          '-' ||
                                                          double.parse(
                                                              varmemberprice) <=
                                                              0) {
                                                        if (double.parse(varmrp) <=
                                                            0 ||
                                                            double.parse(varprice) <=
                                                                0) {
                                                          margins = "0";
                                                        } else {
                                                          var difference =
                                                          (double.parse(varmrp) -
                                                              double.parse(
                                                                  varprice));
                                                          var profit = difference /
                                                              double.parse(varmrp);
                                                          margins = profit * 100;

                                                          //discount price rounding
                                                          margins = num.parse(margins
                                                              .toStringAsFixed(0));
                                                          margins =
                                                              margins.toString();
                                                        }
                                                      } else {
                                                        var difference =
                                                        (double.parse(varmrp) -
                                                            double.parse(
                                                                varmemberprice));
                                                        var profit = difference /
                                                            double.parse(varmrp);
                                                        margins = profit * 100;

                                                        //discount price rounding
                                                        margins = num.parse(margins
                                                            .toStringAsFixed(0));
                                                        margins = margins.toString();
                                                      }
                                                    } else {
                                                      if (double.parse(varmrp) <= 0 ||
                                                          double.parse(varprice) <=
                                                              0) {
                                                        margins = "0";
                                                      } else {
                                                        var difference =
                                                        (double.parse(varmrp) -
                                                            double.parse(
                                                                varprice));
                                                        var profit = difference /
                                                            double.parse(varmrp);
                                                        margins = profit * 100;

                                                        //discount price rounding
                                                        margins = num.parse(margins
                                                            .toStringAsFixed(0));
                                                        margins = margins.toString();
                                                      }
                                                    }

                                                    if (margins == "NaN") {
                                                      _checkmargin = false;
                                                    } else {
                                                      if (int.parse(margins) <= 0) {
                                                        _checkmargin = false;
                                                      } else {
                                                        _checkmargin = true;
                                                      }
                                                    }
                                                    multiimage =
                                                        Provider.of<ItemsList>(
                                                            context)
                                                            .findByIdmulti(varid);
                                                    _displayimg =
                                                        multiimage[0].imageUrl;
                                                    for (int j = 0;
                                                    j < multiimage.length;
                                                    j++) {
                                                      if (j == 0) {
                                                        multiimage[j].varcolor =
                                                            Color(0xff114475);
                                                      } else {
                                                        multiimage[j].varcolor =
                                                            Color(0xffBEBEBE);
                                                      }
                                                    }
                                                  });
                                                }
                                                setState(() {
                                                  if (int.parse(varstock) <= 0) {
                                                    _isStock = false;
                                                  } else {
                                                    _isStock = true;
                                                  }
                                                });
                                              },
                                              child:Container(
                                                height: 50,
                                                width:80,
                                                padding:EdgeInsets.all(10),
                                                margin:EdgeInsets.all(5),
                                                decoration:BoxDecoration(
                                                  borderRadius:BorderRadius.circular(4),
                                                  border:Border.all(color:singleitemvar[i].varcolor),
                                                  color:Colors.white,
                                                ),
                                                child:Center(child: Text( singleitemvar[i].varname,style:TextStyle(fontSize:14,color: singleitemvar[i].varcolor,fontWeight:FontWeight.bold))),
                                              ),
//                                     child: Row(
//                                       children: <Widget>[
// //                                              Spacer(),
//                                         _checkmargin
//                                             ? Consumer<Calculations>(
//                                           builder: (_, cart, ch) =>
//                                               Align(
//                                                 alignment:
//                                                 Alignment.topLeft,
//                                                 child: BadgeDiscount(
//                                                   child: ch,
//                                                   value: margins,
//                                                 ),
//                                               ),
//                                           child: Container(
//                                               padding: EdgeInsets.all(
//                                                   10.0),
//                                               width: MediaQuery.of(
//                                                   context)
//                                                   .size
//                                                   .width -
//                                                   20,
//                                               height: 60.0,
//                                               alignment:
//                                               Alignment.center,
//                                               margin: EdgeInsets.only(
//                                                   bottom: 10.0),
//                                               decoration:
//                                               BoxDecoration(
//                                                   color:
//                                                   ColorCodes
//                                                       .fill,
//                                                   borderRadius:
//                                                   BorderRadius
//                                                       .circular(
//                                                       5.0),
//                                                   border: Border(
//                                                     top: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     bottom: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     left: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                     right: BorderSide(
//                                                         width:
//                                                         1.0,
//                                                         color: singleitemvar[
//                                                         i]
//                                                             .varcolor),
//                                                   )),
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                 MainAxisAlignment
//                                                     .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     singleitemvar[i]
//                                                         .varname,
//                                                     textAlign:
//                                                     TextAlign
//                                                         .center,
//                                                     style: TextStyle(
//                                                         fontSize:
//                                                         14,  color: singleitemvar[i].varcolor
//                                                     ),
//                                                   ),
//                                                   Container(
//                                                       child: Row(
//                                                         children: <
//                                                             Widget>[
//                                                           _checkmembership
//                                                               ? Row(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: <
//                                                                 Widget>[
//                                                               memberpriceDisplay
//                                                                   ? Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                   Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                                 ],
//                                                               )
//                                                                   : discountDisplay
//                                                                   ? Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                   Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                                 ],
//                                                               )
//                                                                   : Column(
//                                                                 children: [
//                                                                   Row(
//                                                                     children: [
//                                                                       Container(
//                                                                         width: 25.0,
//                                                                         height: 25.0,
//                                                                         child: Image.asset(
//                                                                           Images.starImg,
//                                                                         ),
//                                                                       ),
//                                                                       Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               )
//                                                             ],
//                                                           )
//                                                               : discountDisplay
//                                                               ? Column(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                               Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                             ],
//                                                           )
//                                                               : Column(
//                                                             mainAxisAlignment:
//                                                             MainAxisAlignment.center,
//                                                             crossAxisAlignment:
//                                                             CrossAxisAlignment.center,
//                                                             children: [
//                                                               Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                             ],
//                                                           )
//                                                         ],
//                                                       )),
//                                                   Icon(
//                                                       Icons
//                                                           .radio_button_checked_outlined,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor)
//                                                 ],
//                                               )),
//                                         )
//                                             : Container(
//                                             padding:
//                                             EdgeInsets.all(10.0),
//                                             width:
//                                             MediaQuery.of(context)
//                                                 .size
//                                                 .width -
//                                                 20,
//                                             height: 60.0,
//                                             alignment: Alignment.center,
//                                             margin: EdgeInsets.only(
//                                                 bottom: 10.0),
//                                             decoration: BoxDecoration(
//                                                 color: ColorCodes.fill,
//                                                 borderRadius:
//                                                 BorderRadius
//                                                     .circular(5.0),
//                                                 border: Border(
//                                                   top: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   bottom: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   left: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                   right: BorderSide(
//                                                       width: 1.0,
//                                                       color:
//                                                       singleitemvar[
//                                                       i]
//                                                           .varcolor),
//                                                 )),
//                                             child: Row(
//                                               mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .spaceBetween,
//                                               children: [
//                                                 Text(
//                                                   singleitemvar[i]
//                                                       .varname,
//                                                   textAlign:
//                                                   TextAlign.center,
//                                                   style: TextStyle(
//                                                       fontSize:
//                                                       14,  color: singleitemvar[i].varcolor
//                                                   ),
//                                                 ),
//                                                 Container(
//                                                     child: Row(
//                                                       children: <Widget>[
//                                                         _checkmembership
//                                                             ? Row(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                           children: <
//                                                               Widget>[
//                                                             memberpriceDisplay
//                                                                 ? Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varmemberprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                                 Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                               ],
//                                                             )
//                                                                 : discountDisplay
//                                                                 ? Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varprice, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                                 Text(_currencyFormat + singleitemvar[i].varmrp, style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                               ],
//                                                             )
//                                                                 : Column(
//                                                               children: [
//                                                                 Row(
//                                                                   children: [
//                                                                     Container(
//                                                                       width: 25.0,
//                                                                       height: 25.0,
//                                                                       child: Image.asset(
//                                                                         Images.starImg,
//                                                                       ),
//                                                                     ),
//                                                                     Text(_currencyFormat + singleitemvar[i].varmrp, style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                                   ],
//                                                                 ),
//                                                               ],
//                                                             )
//                                                           ],
//                                                         )
//                                                             : discountDisplay
//                                                             ? Column(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment.center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment.center,
//                                                           children: [
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varprice,
//                                                                 style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varmrp,
//                                                                 style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 10.0)),
//                                                           ],
//                                                         )
//                                                             : Column(
//                                                           mainAxisAlignment:
//                                                           MainAxisAlignment.center,
//                                                           crossAxisAlignment:
//                                                           CrossAxisAlignment.center,
//                                                           children: [
//                                                             Text(
//                                                                 _currencyFormat + singleitemvar[i].varmrp,
//                                                                 style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14.0)),
//                                                           ],
//                                                         )
//                                                       ],
//                                                     )),
//                                                 Icon(
//                                                     Icons
//                                                         .radio_button_checked_outlined,
//                                                     color:
//                                                     singleitemvar[i]
//                                                         .varcolor)
//                                               ],
//                                             ))
// //                                              Spacer(),
//                                       ],
//                                     ),
                                            ),
                                            //Divider(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),*/
                          SizedBox(
                            height: 10,
                          ),
                          if (_ismanufacturer)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Origine:  ",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                Text(itemmanufact,style: TextStyle(fontSize: 14,),),
                              ],
                            ),
                          if(_isdescription)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical:8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(translate('forconvience.Discription')+":  ",//"Discription:  ",
                                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                Text(itemdescription,style: TextStyle(fontSize: 14,fontWeight: FontWeight.w100),),
                              ],
                            ),
                          ),
                          ///itemmanufact

                          SizedBox(
                            height: 5.0,
                          ),
                          /*  Row(
                                  children: [
                                    SizedBox(width: 10),
                                    GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          final shoplistData =
                                              Provider.of<BrandItemsList>(context,
                                                  listen: false);

                                          if (shoplistData.itemsshoplist.length <=
                                              0) {
                                            _dialogforCreatelistTwo(
                                                context, shoplistData);
                                            //_dialogforShoppinglist(context);
                                          } else {
                                            _dialogforShoppinglistTwo(context);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                          Icon(
                                             Icons.list_alt_outlined,
                                             color: Colors.grey,
                                           ),
                                            SizedBox(width: 5),
                                            Text("ADD TO LIST"),
                                          ],
                                        ),
                                    ),
                                    //     child: Icon(
                                    //       Icons.list_alt_outlined,
                                    //       color: Colors.grey,
                                    //     )),
                                    // SizedBox(width: 5),
                                    // Text("ADD TO LIST"),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          if (Platform.isIOS) {
                                            Share.share('Download ' +
                                                IConstants.APP_NAME +
                                                ' from App Store https://apps.apple.com/us/app/id1563407384');
                                          } else {
                                            Share.share('Download ' +
                                                IConstants.APP_NAME +
                                                ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
                                          }
                                        },
                                        child: Icon(
                                          Icons.share_outlined,
                                          color: Colors.grey,
                                        )),
                                    SizedBox(width: 5),
                                    Text("SHARE"),
                                    SizedBox(width: 10),
                                  ],
                                ),
                                SizedBox(
                                  height: 25.0,
                                ),*/
                          /*Divider(
                                  thickness: 5,
                                ),*/
                          SizedBox(
                            height: 25.0,
                          ),
                          _similarProduct
                              ? Container(
                            child: Column(
                              children: <Widget>[
                                new Row(
                                  children: <Widget>[
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      sellingitemData.newitemname,
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Theme.of(context)
                                              .primaryColor,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    Spacer(),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                new Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: SizedBox(
                                          height: 275.0,
                                          child: new ListView.builder(
                                            shrinkWrap: true,
                                            scrollDirection:
                                            Axis.horizontal,
                                            itemCount: sellingitemData
                                                .itemsnew.length,
                                            itemBuilder: (_, i) => Column(
                                              children: [
                                                Items(
                                                  "singleproduct_screen",
                                                  sellingitemData
                                                      .itemsnew[i].id,
                                                  sellingitemData
                                                      .itemsnew[i].title,
                                                  sellingitemData
                                                      .itemsnew[i]
                                                      .imageUrl,
                                                  sellingitemData
                                                      .itemsnew[i].brand,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : Container(),
                        ],
                      ),
                    ),
                    // footer comes here
                    if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: prefs.getString("restaurant_address")),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }



    Widget mainBody() {
      if (ResponsiveLayout.isSmallScreen(context)) {
        return mobileBody();
      } else {
        return webBody();
      }
    }

    return Scaffold(
      //appBar: _appBar(),
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      AppBarMobile() : null,
      backgroundColor: ColorCodes.whiteColor,
      body:mainBody(),
      bottomNavigationBar:_isWeb ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),
      ),
    );

  }

  AppBarMobile(){
    return  AppBar(
      toolbarHeight: 55.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Text(itemname,style: TextStyle(
        color: ColorCodes.backbutton,
      ),),
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
               /* Container(
                  margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).buttonColor),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color:  ColorCodes.blackColor,
                  ),
                ),*/
              );

            int cartCount = 0;
            for (int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
              cartCount =Hive.box<Product>(productBoxName).length; //cartCount + Hive.box<Product>(productBoxName).values.elementAt(i).itemQty;
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
                /*Container(
                  margin: EdgeInsets.only(top: 15, right: 10, bottom: 15),
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Theme.of(context).buttonColor),
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
}
