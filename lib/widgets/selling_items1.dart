import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../data/calculations.dart';
import 'package:hive/hive.dart';
import '../providers/notificationitems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/ColorCodes.dart';
import '../widgets/badge_discount.dart';
import '../widgets/badge_ofstock.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/membership_screen.dart';
import '../screens/singleproduct_screen.dart';

import '../providers/branditems.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../constants/images.dart';

class SellingItems extends StatefulWidget {
  final String _fromScreen;
  final String id;
  final String title;
  final String imageUrl;
  final String brand;
  final String shoppinglistid;

  SellingItems(this._fromScreen, this.id, this.title, this.imageUrl, this.brand,
      this.shoppinglistid);

  @override
  _SellingItemsState createState() => _SellingItemsState();
}

class _SellingItemsState extends State<SellingItems> {
  Box<Product> productBox;

  var _varlength = false;
  int varlength = 0;
  var itemvarData;
  var dialogdisplay = false;
  var _currencyFormat = "";
  var membershipdisplay = true;
  var _checkmembership = false;
  var colorRight = 0xff3d8d3c;
  var colorLeft = 0xff8abb50;
  var _checkmargin = true;
  Color varcolor;

  String varid;
  String varname;
  String varmrp;
  String varprice;
  String varmemberprice;
  String varminitem;
  String varmaxitem;
  int varLoyalty;
  String varstock;
  String varimageurl;
  bool discountDisplay;
  bool memberpriceDisplay;
  var margins;

  List variationdisplaydata = [];
  List variddata = [];
  List varnamedata = [];
  List varmrpdata = [];
  List varpricedata = [];
  List varmemberpricedata = [];
  List varminitemdata = [];
  List varmaxitemdata = [];
  List varLoyaltydata = [];
  List varstockdata = [];
  List vardiscountdata = [];
  List discountDisplaydata = [];
  List memberpriceDisplaydata = [];

  List checkBoxdata = [];
  var containercolor = [];
  var textcolor = [];
  var iconcolor = [];
  bool _isLoading = true;
  SharedPreferences prefs;
  bool _isWeb = false;
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
    productBox = Hive.box<Product>(productBoxName);
    Future.delayed(Duration.zero, () async {
      //await Provider.of<BrandItemsList>(context, listen: false).getLoyalty();
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _isLoading = false;
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
          for (int i = 0; i < productBox.length; i++) {
            if (productBox.values.elementAt(i).mode == 1) {
              _checkmembership = true;
            }
          }
        }
        dialogdisplay = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isStock = false;

    if (widget._fromScreen == "home_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else if (widget._fromScreen == "searchitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<ItemsList>(
        context,
        listen: false,
      ).findByIdsearch(widget.id);
    } else if (widget._fromScreen == "sellingitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdall(widget.id);
    } else if (widget._fromScreen == "not_product_screen") {
      itemvarData = null;
      itemvarData = Provider.of<NotificationItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else if (widget._fromScreen == "shoppinglistitem_screen") {
      itemvarData = null;
      itemvarData = Provider.of<BrandItemsList>(
        context,
        listen: false,
      ).findByIditempricevar(widget.shoppinglistid, widget.id);
    } else if (widget._fromScreen == "brands_screen") {
      itemvarData = null;
      variddata = [];
      varnamedata = [];
      varmrpdata = [];
      varpricedata = [];
      varmemberpricedata = [];
      varminitemdata = [];
      varmaxitemdata = [];
      varLoyaltydata = [];
      varstockdata = [];
      vardiscountdata = [];
      discountDisplaydata = [];
      memberpriceDisplaydata = [];

      checkBoxdata = [];
      containercolor = [];
      textcolor = [];

      itemvarData = Provider.of<BrandItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else {
      itemvarData = null;
      variddata = [];
      varnamedata = [];
      varmrpdata = [];
      varpricedata = [];
      varmemberpricedata = [];
      varminitemdata = [];
      varmaxitemdata = [];
      varLoyaltydata = [];
      varstockdata = [];
      vardiscountdata = [];
      discountDisplaydata = [];
      memberpriceDisplaydata = [];

      checkBoxdata = [];
      containercolor = [];
      // textcolor = [];

      itemvarData = Provider.of<ItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    }

    varlength = itemvarData.length;

    if (varlength > 1) {
      _varlength = true;
      variddata.clear();
      variationdisplaydata.clear();
      for (int i = 0; i < varlength; i++) {
        variddata.add(itemvarData[i].varid);
        variationdisplaydata.add(variddata[i]);
        varnamedata.add(itemvarData[i].varname);
        varmrpdata.add(itemvarData[i].varmrp);
        varpricedata.add(itemvarData[i].varprice);
        varmemberpricedata.add(itemvarData[i].varmemberprice);
        varminitemdata.add(itemvarData[i].varminitem);
        varmaxitemdata.add(itemvarData[i].varmaxitem);
        varLoyaltydata.add(itemvarData[i].varLoyalty);
        varstockdata.add(itemvarData[i].varstock);
        discountDisplaydata.add(itemvarData[i].discountDisplay);
        memberpriceDisplaydata.add(itemvarData[i].membershipDisplay);

        if (i == 0) {
          checkBoxdata.add(true);
          containercolor.add(0xffffffff);
          textcolor.add(0xFF2966A2);
          iconcolor.add(0xFF2966A2);
        } else {
          checkBoxdata.add(false);
          containercolor.add(0xffffffff);
          textcolor.add(0xff060606);
          iconcolor.add(0xFFC1C1C1);
        }

        /*var difference = (double.parse(itemvarData[i].varmrp) - int.parse(itemvarData[i].varprice));
        var profit = (difference / double.parse(itemvarData[0].varmrp)) * 100;
        vardiscountdata.add("$profit");*/

      }
    }

    if (varlength <= 0) {
    } else {
      if (!dialogdisplay) {
        varid = itemvarData[0].varid;
        varname = itemvarData[0].varname;
        varmrp = itemvarData[0].varmrp;
        varprice = itemvarData[0].varprice;
        varmemberprice = itemvarData[0].varmemberprice;
        varminitem = itemvarData[0].varminitem;
        varmaxitem = itemvarData[0].varmaxitem;
        varLoyalty = itemvarData[0].varLoyalty;
        varstock = itemvarData[0].varstock;
        discountDisplay = itemvarData[0].discountDisplay;
        memberpriceDisplay = itemvarData[0].membershipDisplay;
        //varimageurl = itemvarData[0].imageUrl;

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
             margins= "0";
          } else {
            var difference = (double.parse(varmrp) - double.parse(varprice));
            var profit = difference / double.parse(varmrp);
            margins = profit * 100;

            //discount price rounding
            margins = num.parse(margins.toStringAsFixed(0));
            margins = margins.toString();
          }
        }
      }
    }

    addToCart(int _itemCount) async {
      Product products = Product(
          itemId: int.parse(widget.id),
          varId: int.parse(varid),
          varName: varname,
          varMinItem: int.parse(varminitem),
          varMaxItem: int.parse(varmaxitem),
          itemLoyalty: varLoyalty,
          varStock: int.parse(varstock),
          varMrp: double.parse(varmrp),
          itemName: widget.title,
          itemQty: _itemCount,
          itemPrice: double.parse(varprice),
          membershipPrice: varmemberprice,
          itemActualprice: double.parse(varmrp),
          itemImage: widget.imageUrl,
          membershipId: 0,
          mode: 0);

      productBox.add(products);
    }

    incrementToCart(_itemCount) async {
      Product products = Product(
          itemId: int.parse(widget.id),
          varId: int.parse(varid),
          varName: varname,
          varMinItem: int.parse(varminitem),
          varMaxItem: int.parse(varmaxitem),
          itemLoyalty: varLoyalty,
          varStock: int.parse(varstock),
          varMrp: double.parse(varmrp),
          itemName: widget.title,
          itemQty: _itemCount,
          itemPrice: double.parse(varprice),
          membershipPrice: varmemberprice,
          itemActualprice: double.parse(varmrp),
          itemImage: widget.imageUrl,
          membershipId: 0,
          mode: 0);

      var items = Hive.box<Product>(productBoxName);

      for (int i = 0; i < items.length; i++) {
        if (Hive.box<Product>(productBoxName).values.elementAt(i).varId ==
            int.parse(varid)) {
          Hive.box<Product>(productBoxName).putAt(i, products);
        }
      }
    }

    if (_checkmembership) {
      //membershipdisplay = false;
      colorRight = 0xffffffff;
      colorLeft = 0xffffffff;
    } else {
      if (varmemberprice == '-' || varmemberprice == "0") {
        setState(() {
          membershipdisplay = false;
          colorRight = 0xffffffff;
          colorLeft = 0xffffffff;
        });
      } else {
        membershipdisplay = true;
        colorRight = 0xff3d8d3c;
        colorLeft = 0xff8abb50;
      }
    }

    /*if(double.parse(varprice) <= 0 || varprice.toString() == "" || double.parse(varprice) == double.parse(varmrp)){
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
    setState(() {
      if (int.parse(varstock) <= 0) {
        _isStock = false;
      } else {
        _isStock = true;
      }
    });

    Widget showoptions() {
      showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0)),
                    child: Container(
                      width: 500,
                      height: 320,
                      padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(widget.title,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                              GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image(
                                    height: 40,
                                    width: 40,
                                    image:
                                        AssetImage(Images.bottomsheetcancelImg),
                                    color: Colors.black,
                                  )),
                            ],
                          ),

                          //Text(
                          //'Size',
                          //style: TextStyle(
                          //    fontSize: 22, fontWeight: FontWeight.w300),
                          //),
                          Text(
                            'Please select any one option',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          SingleChildScrollView(
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: variationdisplaydata.length,
                                itemBuilder: (_, i) {
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          varid = itemvarData[i].varid;
                                          varname = itemvarData[i].varname;
                                          varmrp = itemvarData[i].varmrp;
                                          varprice = itemvarData[i].varprice;
                                          varmemberprice =
                                              itemvarData[i].varmemberprice;
                                          varminitem =
                                              itemvarData[i].varminitem;
                                          varmaxitem =
                                              itemvarData[i].varmaxitem;
                                          varLoyalty =
                                              itemvarData[i].varLoyalty;
                                          varstock = itemvarData[i].varstock;
                                          discountDisplay =
                                              itemvarData[i].discountDisplay;
                                          memberpriceDisplay =
                                              itemvarData[i].membershipDisplay;

                                          if (_checkmembership) {
                                            if (varmemberprice.toString() ==
                                                    '-' ||
                                                double.parse(varmemberprice) <=
                                                    0) {
                                              if (double.parse(varmrp) <= 0 ||
                                                  double.parse(varprice) <= 0) {
                                                margins = "0";
                                              } else {
                                                var difference =
                                                    (double.parse(varmrp) -
                                                        double.parse(varprice));
                                                var profit = difference /
                                                    double.parse(varmrp);
                                                margins = profit * 100;

                                                //discount price rounding
                                                margins = num.parse(
                                                    margins.toStringAsFixed(0));
                                                margins = margins.toString();
                                              }
                                            } else {
                                              var difference = (double.parse(
                                                      varmrp) -
                                                  double.parse(varmemberprice));
                                              var profit = difference /
                                                  double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(
                                                  margins.toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          } else {
                                            if (double.parse(varmrp) <= 0 ||
                                                double.parse(varprice) <= 0) {
                                              margins = "0";
                                            } else {
                                              var difference =
                                                  (double.parse(varmrp) -
                                                      double.parse(varprice));
                                              var profit = difference /
                                                  double.parse(varmrp);
                                              margins = profit * 100;

                                              //discount price rounding
                                              margins = num.parse(
                                                  margins.toStringAsFixed(0));
                                              margins = margins.toString();
                                            }
                                          }

                                          Future.delayed(Duration(seconds: 0),
                                              () {
                                            dialogdisplay = true;
                                            for (int j = 0;
                                                j < variddata.length;
                                                j++) {
                                              if (i == j) {
                                                setState(() {
                                                  checkBoxdata[i] = true;
                                                  containercolor[i] =
                                                      0xFFFFFFFF;
                                                  textcolor[i] = 0xFF2966A2;
                                                  iconcolor[i] = 0xFF2966A2;
                                                });
                                              } else {
                                                setState(() {
                                                  checkBoxdata[j] = false;
                                                  containercolor[j] =
                                                      0xFFFFFFFF;
                                                  iconcolor[j] = 0xFFC1C1C1;
                                                  textcolor[j] = 0xFF060606;
                                                });
                                              }
                                            }
                                          });
                                          // Navigator.of(context).pop(true);
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        padding: EdgeInsets.only(right: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _checkmembership
                                                ? //membered usesr
                                                itemvarData[i].membershipDisplay
                                                    ? RichText(
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color:
                                                                itemvarData[i]
                                                                    .varcolor,
                                                          ),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: varnamedata[
                                                                      i] +
                                                                  " - ",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            TextSpan(
                                                              text: varmemberpricedata[
                                                                      i] +
                                                                  " " +
                                                                  _currencyFormat,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            TextSpan(
                                                                text: varmrpdata[
                                                                        i] +
                                                                    _currencyFormat,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                    : itemvarData[i]
                                                            .discountDisplay
                                                        ? RichText(
                                                            text: TextSpan(
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                                color:
                                                                    itemvarData[
                                                                            i]
                                                                        .varcolor,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                TextSpan(
                                                                  text: varnamedata[
                                                                          i] +
                                                                      " - ",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18.0,
                                                                      color: Color(
                                                                          textcolor[
                                                                              i]),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                TextSpan(
                                                                  text: varpricedata[
                                                                          i] +
                                                                      " " +
                                                                      _currencyFormat,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18.0,
                                                                      color: Color(
                                                                          textcolor[
                                                                              i]),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                TextSpan(
                                                                    text: varmrpdata[
                                                                            i] +
                                                                        _currencyFormat,
                                                                    style:
                                                                        TextStyle(
                                                                      color: Color(
                                                                          textcolor[
                                                                              i]),
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                    )),
                                                              ],
                                                            ),
                                                          )
                                                        : new RichText(
                                                            text: new TextSpan(
                                                              style:
                                                                  new TextStyle(
                                                                fontSize: 14.0,
                                                                color:
                                                                    itemvarData[
                                                                            i]
                                                                        .varcolor,
                                                              ),
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text: varnamedata[
                                                                          i] +
                                                                      " - ",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        textcolor[
                                                                            i]),
                                                                  ),
                                                                ),
                                                                new TextSpan(
                                                                  text: " " +
                                                                      varmrpdata[
                                                                          i] +
                                                                      _currencyFormat,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Color(
                                                                        textcolor[
                                                                            i]),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                : itemvarData[i].discountDisplay
                                                    ? RichText(
                                                        text: TextSpan(
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            color:
                                                                itemvarData[i]
                                                                    .varcolor,
                                                          ),
                                                          children: <TextSpan>[
                                                            TextSpan(
                                                              text: varnamedata[
                                                                      i] +
                                                                  " - ",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            TextSpan(
                                                              text: varpricedata[
                                                                      i] +
                                                                  " " +
                                                                  _currencyFormat,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            TextSpan(
                                                                text: varmrpdata[
                                                                        i] +
                                                                    _currencyFormat,
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      textcolor[
                                                                          i]),
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                    : new RichText(
                                                        text: new TextSpan(
                                                          style: new TextStyle(
                                                            fontSize: 14.0,
                                                            color:
                                                                itemvarData[i]
                                                                    .varcolor,
                                                          ),
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text: varnamedata[
                                                                      i] +
                                                                  " - ",
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    textcolor[
                                                                        i]),
                                                              ),
                                                            ),
                                                            new TextSpan(
                                                              text: " " +
                                                                  varmrpdata[
                                                                      i] +
                                                                  _currencyFormat,
                                                              style: TextStyle(
                                                                fontSize: 18.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                    textcolor[
                                                                        i]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                            Icon(
                                                Icons
                                                    .radio_button_checked_outlined,
                                                color: Color(iconcolor[i])),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          //),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 40.0,
                                //width: (MediaQuery.of(context).size.width / 3) + 18,
                                width: 200,
                                child: ValueListenableBuilder(
                                  valueListenable:
                                      Hive.box<Product>(productBoxName)
                                          .listenable(),
                                  builder: (context, Box<Product> box, _) {
                                    if (box.values.length <= 0)
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            addToCart(int.parse(
                                                itemvarData[0].varminitem));
                                          },
                                          child: Container(
                                            height: 40.0,
                                            //width: (MediaQuery.of(context).size.width / 3) + 18,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).accentColor,
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Center(
                                                    child: Text(
                                                  translate('forconvience.ADD'),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                                Spacer(),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      bottomRight:
                                                          const Radius.circular(
                                                              3),
                                                      topRight:
                                                          const Radius.circular(
                                                              3),
                                                    ),
                                                  ),
                                                  height: 40,
                                                  width: 30,
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );

                                    try {
                                      Product item = Hive.box<Product>(
                                              productBoxName)
                                          .values
                                          .firstWhere((value) =>
                                              value.varId == int.parse(varid));
                                      return Container(
                                        child: Row(
                                          children: <Widget>[
                                            GestureDetector(
                                              onTap: () async {
                                                if (item.itemQty ==
                                                    int.parse(varminitem)) {
                                                  for (int i = 0;
                                                      i <
                                                          productBox
                                                              .values.length;
                                                      i++) {
                                                    if (productBox.values
                                                            .elementAt(i)
                                                            .varId ==
                                                        int.parse(varid)) {
                                                      productBox.deleteAt(i);
                                                      break;
                                                    }
                                                  }
                                                } else {
                                                  setState(() {
                                                    incrementToCart(
                                                        item.itemQty - 1);
                                                  });
                                                }
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      bottomLeft:
                                                          const Radius.circular(
                                                              3),
                                                      topLeft:
                                                          const Radius.circular(
                                                              3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "-",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            Expanded(
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  height: 40,
                                                  width: 30,
                                                  child: Center(
                                                    child: Text(
                                                      item.itemQty.toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (item.itemQty <
                                                    int.parse(varstock)) {
                                                  if (item.itemQty <
                                                      int.parse(varmaxitem)) {
                                                    incrementToCart(
                                                        item.itemQty + 1);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                        translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                                        backgroundColor:
                                                            Colors.black87,
                                                        textColor:
                                                            Colors.white);
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Sorry, Out of Stock!",
                                                      backgroundColor:
                                                          Colors.black87,
                                                      textColor: Colors.white);
                                                }
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                    borderRadius:
                                                        new BorderRadius.only(
                                                      bottomRight:
                                                          const Radius.circular(
                                                              3),
                                                      topRight:
                                                          const Radius.circular(
                                                              3),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Theme.of(context)
                                                            .primaryColor,
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
                                              itemvarData[0].varminitem));
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4) +
                                              15,
                                          decoration: new BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Center(
                                                  child: Text(
                                                translate('forconvience.ADD'),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .buttonColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                height: 40,
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
                                      );
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                      // ),
                    ),
                  );
                });
              })
          /*showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0)), //this right here
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                        child: Text(
                          "Available quantities for",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Text(
                          widget.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                              color: Color(0xff444348),
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        child: new ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: variationdisplaydata.length,
                          itemBuilder: (_, i) => GestureDetector(
                            onTap: () {
                              setState(() {
                                varid = itemvarData[i].varid;
                                varname = itemvarData[i].varname;
                                varmrp = itemvarData[i].varmrp;
                                varprice = itemvarData[i].varprice;
                                varmemberprice = itemvarData[i].varmemberprice;
                                varminitem = itemvarData[i].varminitem;
                                varmaxitem = itemvarData[i].varmaxitem;
                                varstock = itemvarData[i].varstock;
                                discountDisplay =
                                    itemvarData[i].discountDisplay;
                                memberpriceDisplay =
                                    itemvarData[i].membershipDisplay;

                                if (_checkmembership) {
                                  if (varmemberprice.toString() == '-' ||
                                      double.parse(varmemberprice) <= 0) {
                                    if (double.parse(varmrp) <= 0 ||
                                        double.parse(varprice) <= 0) {
                                      margins = "0";
                                    } else {
                                      var difference = (double.parse(varmrp) -
                                          double.parse(varprice));
                                      var profit =
                                          difference / double.parse(varmrp);
                                      margins = profit * 100;

                                      //discount price rounding
                                      margins =
                                          num.parse(margins.toStringAsFixed(0));
                                      margins = margins.toString();
                                    }
                                  } else {
                                    var difference = (double.parse(varmrp) -
                                        double.parse(varmemberprice));
                                    var profit =
                                        difference / double.parse(varmrp);
                                    margins = profit * 100;

                                    //discount price rounding
                                    margins =
                                        num.parse(margins.toStringAsFixed(0));
                                    margins = margins.toString();
                                  }
                                } else {
                                  if (double.parse(varmrp) <= 0 ||
                                      double.parse(varprice) <= 0) {
                                    margins = "0";
                                  } else {
                                    var difference = (double.parse(varmrp) -
                                        double.parse(varprice));
                                    var profit =
                                        difference / double.parse(varmrp);
                                    margins = profit * 100;

                                    //discount price rounding
                                    margins =
                                        num.parse(margins.toStringAsFixed(0));
                                    margins = margins.toString();
                                  }
                                }

                                dialogdisplay = true;
                                for (int j = 0; j < variddata.length; j++) {
                                  if (i == j) {
                                    checkBoxdata[i] = true;
                                    containercolor[i] = 0xff2e2d33;
                                    textcolor[i] = 0xffffffff;
                                    /*if(true) {
                                                              containercolor[i] = 0xff2e2d33;
                                                              textcolor[i] = 0xffffffff;
                                                            }*/ /*else {
                                                              containercolor[i] = 0xffffffff;
                                                              textcolor[i] = 0xff2e2d33;
                                                            }*/
                                  } else {
                                    checkBoxdata[j] = false;
                                    containercolor[j] = 0xffffffff;
                                    textcolor[j] = 0xff2e2d33;
                                  }
                                }

                                Future.delayed(Duration(seconds: 0), () {
                                  Navigator.of(context).pop(true);
                                });
                              });
                            },
                            child: Column(
                              children: [
                                Divider(
                                  color: Colors.grey,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: 40.0,
                                  margin:
                                      EdgeInsets.only(left: 10.0, right: 10.0),
                                  decoration: BoxDecoration(
                                      color: Color(containercolor[i]),
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border(
                                        top: BorderSide(
                                          width: 1.0,
                                          color: Color(containercolor[i]),
                                        ),
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color: Color(containercolor[i]),
                                        ),
                                        left: BorderSide(
                                          width: 1.0,
                                          color: Color(containercolor[i]),
                                        ),
                                        right: BorderSide(
                                          width: 1.0,
                                          color: Color(containercolor[i]),
                                        ),
                                      )),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      _checkmembership
                                          ? //membered usesr
                                          itemvarData[i].membershipDisplay
                                              ? new RichText(
                                                  text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 16.0,
                                                      color:
                                                          Color(textcolor[i]),
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                        text: varnamedata[i] +
                                                            " - ",
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                          text:
                                                              _currencyFormat +
                                                                  " " +
                                                                  varmrpdata[i],
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          )),
                                                      new TextSpan(
                                                        text: _currencyFormat +
                                                            " " +
                                                            varmemberpricedata[
                                                                i],
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : itemvarData[i].discountDisplay
                                                  ? new RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                            text:
                                                                varnamedata[i] +
                                                                    " - ",
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: Color(
                                                                  textcolor[i]),
                                                            ),
                                                          ),
                                                          new TextSpan(
                                                              text:
                                                                  _currencyFormat +
                                                                      " " +
                                                                      varmrpdata[
                                                                          i],
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              )),
                                                          new TextSpan(
                                                            text:
                                                                _currencyFormat +
                                                                    " " +
                                                                    varpricedata[
                                                                        i],
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: Color(
                                                                  textcolor[i]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : new RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                            text:
                                                                varnamedata[i] +
                                                                    " - ",
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: Color(
                                                                  textcolor[i]),
                                                            ),
                                                          ),
                                                          new TextSpan(
                                                            text:
                                                                _currencyFormat +
                                                                    " " +
                                                                    varmrpdata[
                                                                        i],
                                                            style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: Color(
                                                                  textcolor[i]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                          : //membered user end
                                          itemvarData[i].discountDisplay
                                              ? new RichText(
                                                  text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 16.0,
                                                      color:
                                                          Color(textcolor[i]),
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                        text: varnamedata[i] +
                                                            " - ",
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                          text:
                                                              _currencyFormat +
                                                                  " " +
                                                                  varmrpdata[i],
                                                          style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          )),
                                                      new TextSpan(
                                                        text: _currencyFormat +
                                                            " " +
                                                            varpricedata[i],
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : new RichText(
                                                  text: new TextSpan(
                                                    style: new TextStyle(
                                                      fontSize: 16.0,
                                                      color:
                                                          Color(textcolor[i]),
                                                    ),
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                        text: varnamedata[i] +
                                                            " - ",
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                        text: _currencyFormat +
                                                            " " +
                                                            varmrpdata[i],
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color: Color(
                                                              textcolor[i]),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  )),
                ),
              );
            },
          );
        },
      )
      */
          .then((_) => setState(() {
                variddata.clear();
                variationdisplaydata.clear();
              }));
    }

    if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) {
      return Container(
        // width: MediaQuery
        //     .of(context)
        //     .size
        //     .width/2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: Color(0xFFCFCFCF)),
        ),
        margin: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0, right: 5),
        child: Column(
          children: [
            Container(
                width: (MediaQuery.of(context).size.width / 4) + 15,
                child: Column(
                  children: [
                    if (_checkmargin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 5.0),
                            padding: EdgeInsets.all(3.0),
                            // color: Theme.of(context).accentColor,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3.0),
                              color: Color(0xff6CBB3C),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 28,
                              minHeight: 18,
                            ),
                            child: Text(
                              margins + "% OFF",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).buttonColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.only(top: 0),
              // width: (MediaQuery
              //     .of(context)
              //     .size
              //     .width / 2) - 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  !_isStock
                      ? Consumer<Calculations>(
                          builder: (_, cart, ch) => BadgeOfStock(
                            child: ch,
                            value: margins,
                            singleproduct: false,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  SingleproductScreen.routeName,
                                  arguments: {
                                    "itemid": widget.id,
                                    "itemname": widget.title,
                                    "itemimg": widget.imageUrl,
                                  });
                            },
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              placeholder: (context, url) => Image.asset(
                                Images.defaultProductImg,
                                width: ResponsiveLayout.isSmallScreen(context)
                                    ? 75
                                    : ResponsiveLayout.isMediumScreen(context)
                                        ? 90
                                        : 100,
                                height: ResponsiveLayout.isSmallScreen(context)
                                    ? 75
                                    : ResponsiveLayout.isMediumScreen(context)
                                        ? 90
                                        : 100,
                              ),
                              width: ResponsiveLayout.isSmallScreen(context)
                                  ? 75
                                  : ResponsiveLayout.isMediumScreen(context)
                                      ? 90
                                      : 100,
                              height: ResponsiveLayout.isSmallScreen(context)
                                  ? 75
                                  : ResponsiveLayout.isMediumScreen(context)
                                      ? 90
                                      : 100,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                                SingleproductScreen.routeName,
                                arguments: {
                                  "itemid": widget.id,
                                  "itemname": widget.title,
                                  "itemimg": widget.imageUrl,
                                });
                          },
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            placeholder: (context, url) => Image.asset(
                              Images.defaultProductImg,
                              width: ResponsiveLayout.isSmallScreen(context)
                                  ? 75
                                  : ResponsiveLayout.isMediumScreen(context)
                                      ? 90
                                      : 100,
                              height: ResponsiveLayout.isSmallScreen(context)
                                  ? 75
                                  : ResponsiveLayout.isMediumScreen(context)
                                      ? 90
                                      : 100,
                            ),
                            width: ResponsiveLayout.isSmallScreen(context)
                                ? 75
                                : ResponsiveLayout.isMediumScreen(context)
                                    ? 90
                                    : 100,
                            height: ResponsiveLayout.isSmallScreen(context)
                                ? 75
                                : ResponsiveLayout.isMediumScreen(context)
                                    ? 90
                                    : 100,
                            fit: BoxFit.fill,
                          ),
                        ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 10),
                  // width: (MediaQuery
                  //     .of(context)
                  //     .size
                  //     .width / 2) + 60,
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                            width: MediaQuery.of(context).size.width / 3,
                            // width: (MediaQuery
                            //     .of(context)
                            //     .size
                            //     .width / 4) + 15,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /* Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.brand,
                                          style: TextStyle(
                                              fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 12, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),*/
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          widget.title,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              fontSize: ResponsiveLayout
                                                      .isSmallScreen(context)
                                                  ? 15
                                                  : ResponsiveLayout
                                                          .isMediumScreen(
                                                              context)
                                                      ? 14
                                                      : 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                    child: Row(
                                  children: <Widget>[
                                    _checkmembership
                                        ? Row(
                                            children: <Widget>[
                                              Container(
                                                width: 25.0,
                                                height: 25.0,
                                                child: Image.asset(
                                                  Images.starImg,
                                                ),
                                              ),
                                              memberpriceDisplay
                                                  ? new RichText(
                                                      text: new TextSpan(
                                                        style: new TextStyle(
                                                          fontSize: ResponsiveLayout
                                                                  .isSmallScreen(
                                                                      context)
                                                              ? 14
                                                              : ResponsiveLayout
                                                                      .isMediumScreen(
                                                                          context)
                                                                  ? 14
                                                                  : 15,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ),
                                                        children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                                          new TextSpan(
                                                              text: '$varmemberprice ' +
                                                                  _currencyFormat,
                                                              style:
                                                                  new TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fontSize: ResponsiveLayout
                                                                        .isSmallScreen(
                                                                            context)
                                                                    ? 14
                                                                    : ResponsiveLayout.isMediumScreen(
                                                                            context)
                                                                        ? 14
                                                                        : 15,
                                                              )),
                                                          new TextSpan(
                                                              text: '$varmrp ' +
                                                                  _currencyFormat,
                                                              style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  : discountDisplay
                                                      ? new RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: ResponsiveLayout
                                                                      .isSmallScreen(
                                                                          context)
                                                                  ? 14
                                                                  : ResponsiveLayout
                                                                          .isMediumScreen(
                                                                              context)
                                                                      ? 14
                                                                      : 15,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text: '$varprice ' +
                                                                      _currencyFormat,
                                                                  style:
                                                                      new TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontSize: ResponsiveLayout.isSmallScreen(
                                                                            context)
                                                                        ? 14
                                                                        : ResponsiveLayout.isMediumScreen(context)
                                                                            ? 14
                                                                            : 15,
                                                                  )),
                                                              new TextSpan(
                                                                  text: '$varmrp ' +
                                                                      _currencyFormat,
                                                                  style:
                                                                      TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                                      : new RichText(
                                                          text: new TextSpan(
                                                            style:
                                                                new TextStyle(
                                                              fontSize: ResponsiveLayout
                                                                      .isSmallScreen(
                                                                          context)
                                                                  ? 14
                                                                  : ResponsiveLayout
                                                                          .isMediumScreen(
                                                                              context)
                                                                      ? 14
                                                                      : 15,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                            children: <
                                                                TextSpan>[
                                                              new TextSpan(
                                                                  text: '$varmrp ' +
                                                                      _currencyFormat,
                                                                  style:
                                                                      new TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontSize: ResponsiveLayout.isSmallScreen(
                                                                            context)
                                                                        ? 14
                                                                        : ResponsiveLayout.isMediumScreen(context)
                                                                            ? 14
                                                                            : 15,
                                                                  )),
                                                            ],
                                                          ),
                                                        )
                                            ],
                                          )
                                        : discountDisplay
                                            ? new RichText(
                                                text: new TextSpan(
                                                  style: new TextStyle(
                                                    fontSize: ResponsiveLayout
                                                            .isSmallScreen(
                                                                context)
                                                        ? 14
                                                        : ResponsiveLayout
                                                                .isMediumScreen(
                                                                    context)
                                                            ? 14
                                                            : 15,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(
                                                        text: '$varprice ' +
                                                            _currencyFormat,
                                                        style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: ResponsiveLayout
                                                                  .isSmallScreen(
                                                                      context)
                                                              ? 14
                                                              : ResponsiveLayout
                                                                      .isMediumScreen(
                                                                          context)
                                                                  ? 14
                                                                  : 15,
                                                        )),
                                                    new TextSpan(
                                                        text: '$varmrp ' +
                                                            _currencyFormat,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        )),
                                                  ],
                                                ),
                                              )
                                            : new RichText(
                                                text: new TextSpan(
                                                  style: new TextStyle(
                                                    fontSize: ResponsiveLayout
                                                            .isSmallScreen(
                                                                context)
                                                        ? 14
                                                        : ResponsiveLayout
                                                                .isMediumScreen(
                                                                    context)
                                                            ? 14
                                                            : 15,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(
                                                        text: '$varmrp ' +
                                                            _currencyFormat,
                                                        style: new TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          fontSize: ResponsiveLayout
                                                                  .isSmallScreen(
                                                                      context)
                                                              ? 14
                                                              : ResponsiveLayout
                                                                      .isMediumScreen(
                                                                          context)
                                                                  ? 14
                                                                  : 15,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                    Spacer(),
                                    if (double.parse(varLoyalty.toString()) > 0)
                                      Container(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Image.asset(
                                              Images.coinImg,
                                              height: 15.0,
                                              width: 20.0,
                                            ),
                                            SizedBox(width: 4),
                                            Text(varLoyalty.toString()),
                                          ],
                                        ),
                                      ),
                                  ],
                                )),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
//                SizedBox(height: 10,),
                Column(
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 40,
                      child: Column(
                        children: [
                          /* Container(

                            width: (MediaQuery
                                .of(context)
                                .size
                                .width / 4) + 15,
                            padding: EdgeInsets.only(bottom: 10,left: 10,right: 10),
                            child: _varlength
                                ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  showoptions();
                                });

                              },
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xff32B847)),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(2.0),
                                            bottomLeft:
                                            const Radius.circular(2.0),
                                          )),
                                      height: 30,
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 4.5, 0.0, 4.5),
                                      child: Text(
                                        "$varname",
                                        style:
                                        TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                        color: Color(0xff32B847),
                                        borderRadius: new BorderRadius.only(
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomRight:
                                          const Radius.circular(2.0),
                                        )),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Color(0xff32B847)),
                                        borderRadius: new BorderRadius.only(
                                          topLeft:
                                          const Radius.circular(2.0),
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                           bottomRight:
                                          const Radius.circular(2.0),
                                        )),
                                    height: 30,
                                    padding: EdgeInsets.fromLTRB(
                                        5.0, 4.5, 0.0, 4.5),
                                    child: Text(
                                      "$varname",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),*/
                          SizedBox(
                            width: 10,
                          ),
                          _isStock
                              ? Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  height: 30.0,
                                  width:
                                      (MediaQuery.of(context).size.width / 4) +
                                          15,
                                  child: ValueListenableBuilder(
                                    valueListenable:
                                        Hive.box<Product>(productBoxName)
                                            .listenable(),
                                    builder: (context, Box<Product> box, _) {
                                      if (box.values.length <= 0)
                                        return GestureDetector(
                                          onTap: () {
                                            addToCart(int.parse(
                                                itemvarData[0].varminitem));
                                          },
                                          child: Container(
                                            height: 30.0,
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4) +
                                                15,
                                            decoration: new BoxDecoration(
                                                color: Color(0xff32B847),
                                                borderRadius:
                                                    new BorderRadius.only(
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
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Center(
                                                    child: Text(
                                                  translate('forconvience.ADD'),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                                Spacer(),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff1BA130),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(2.0),
                                                        bottomLeft: const Radius
                                                            .circular(2.0),
                                                        topRight: const Radius
                                                            .circular(2.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(2.0),
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
                                        );

                                      try {
                                        Product item =
                                            Hive.box<Product>(productBoxName)
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
                                                      int.parse(varminitem)) {
                                                    for (int i = 0;
                                                        i <
                                                            productBox
                                                                .values.length;
                                                        i++) {
                                                      if (productBox.values
                                                              .elementAt(i)
                                                              .varId ==
                                                          int.parse(varid)) {
                                                        productBox.deleteAt(i);
                                                        break;
                                                      }
                                                    }
                                                  } else {
                                                    setState(() {
                                                      incrementToCart(
                                                          item.itemQty - 1);
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration:
                                                        new BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xff32B847),
                                                            ),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              bottomLeft:
                                                                  const Radius
                                                                          .circular(
                                                                      2.0),
                                                              topLeft: const Radius
                                                                      .circular(
                                                                  2.0),
                                                            )),
                                                    child: Center(
                                                      child: Text(
                                                        "-",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff32B847),
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              Expanded(
                                                child: Container(
//                                            width: 40,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff32B847),
                                                    ),
                                                    height: 30,
                                                    child: Center(
                                                      child: Text(
                                                        item.itemQty.toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .buttonColor,
                                                        ),
                                                      ),
                                                    )),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  if (item.itemQty <
                                                      int.parse(varstock)) {
                                                    if (item.itemQty <
                                                        int.parse(varmaxitem)) {
                                                      incrementToCart(
                                                          item.itemQty + 1);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                          translate('forconvience.no more item') ,// "Sorry, you can\'t add more of this item!",
                                                          backgroundColor:
                                                              Colors.black87,
                                                          textColor:
                                                              Colors.white);
                                                    }
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Sorry, Out of Stock!",
                                                        backgroundColor:
                                                            Colors.black87,
                                                        textColor:
                                                            Colors.white);
                                                  }
                                                },
                                                child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration:
                                                        new BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xff32B847),
                                                            ),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              bottomRight:
                                                                  const Radius
                                                                          .circular(
                                                                      2.0),
                                                              topRight: const Radius
                                                                      .circular(
                                                                  2.0),
                                                            )),
                                                    child: Center(
                                                      child: Text(
                                                        "+",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff32B847),
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
                                                itemvarData[0].varminitem));
                                          },
                                          child: Container(
                                            height: 30.0,
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4) +
                                                15,
                                            decoration: new BoxDecoration(
                                                color: Color(0xff32B847),
                                                borderRadius:
                                                    new BorderRadius.only(
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
                                              children: [
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Center(
                                                    child: Text(
                                                  translate('forconvience.ADD'),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )),
                                                Spacer(),
                                                Container(
                                                  decoration: BoxDecoration(
                                                      color: Color(0xff1BA130),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(2.0),
                                                        bottomLeft: const Radius
                                                            .circular(2.0),
                                                        topRight: const Radius
                                                            .circular(2.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(2.0),
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
                                        );
                                      }
                                    },
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Fluttertoast.showToast(
                                        msg: /*"You will be notified via SMS/Push notification, when the product is available"*/
                                        translate('forconvience.Out of stock popup') , //"Out Of Stock",
                                        fontSize: 12.0,
                                        backgroundColor: Colors.black87,
                                        textColor: Colors.white);
                                  },
                                  child: Container(
                                    height: 30.0,
                                    width: (MediaQuery.of(context).size.width /
                                            4) +
                                        15,
                                    decoration: new BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.grey,
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(2.0),
                                          topRight: const Radius.circular(2.0),
                                          bottomLeft:
                                              const Radius.circular(2.0),
                                          bottomRight:
                                              const Radius.circular(2.0),
                                        )),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Center(
                                            child: Text(
                                          /*'Notify Me'*/
                                          translate('forconvience.ADD'),
                                          style: TextStyle(
                                              /*fontWeight: FontWeight.w700,*/
                                              color: Colors
                                                  .white /*Colors.black87*/),
                                          textAlign: TextAlign.center,
                                        )),
                                        Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  new BorderRadius.only(
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
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  ],
                ),
                /* !_checkmembership
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
    //                   child: Padding(
    // padding: EdgeInsets.all(10),
    child: Container(
      height: 25,

      */ /*width:
      (MediaQuery
          .of(context)
          .size
          .width / 4) +
          15,*/ /*
      width: (MediaQuery.of(context).size.width/6.1) ,

      decoration:
      BoxDecoration(color: Color(0xffefef47)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
                       mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 10),
          Image.asset(
            Images.starImg,
            height: 12,
          ),
          SizedBox(width: 2),
          Text(
              "Membership Price " +
                  _currencyFormat +
                  varmemberprice,
              style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
          Spacer(),
          Icon(
            Icons.lock,
            color: Colors.black,
            size: 10,
          ),
          SizedBox(width: 2),
          Icon(
            Icons.arrow_forward_ios_sharp,
            color: Colors.black,
            size: 10,
          ),
          SizedBox(width: 10),
        ],
      ),
    ),
    //)



                    )
                        : SizedBox.shrink()
                        : SizedBox.shrink(),
                  ],
                ),*/
              ],
            ),
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: ColorCodes.borderColor),
            ),
            margin:
                EdgeInsets.only(left: 10.0, top: 5, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: (MediaQuery.of(context).size.width / 2) - 90,
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _checkmargin
                          ? !_isStock
                                  ? Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                                SingleproductScreen.routeName,
                                                arguments: {
                                                  "itemid": widget.id,
                                                  "itemname": widget.title,
                                                  "itemimg": widget.imageUrl,
                                                });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: 40.0, bottom: 10),
                                            child: CachedNetworkImage(
                                              imageUrl: widget.imageUrl,
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                Images.defaultProductImg,
                                                width: 100,
                                                height: 80,
                                              ),
                                              width: 100,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                  : Align(
                                      alignment: Alignment.center,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              SingleproductScreen.routeName,
                                              arguments: {
                                                "itemid": widget.id,
                                                "itemname": widget.title,
                                                "itemimg": widget.imageUrl,
                                              });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              top: 40.0, bottom: 10),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.imageUrl,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                              Images.defaultProductImg,
                                              width: 100,
                                              height: 80,
                                            ),
                                            width: 100,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                          : !_isStock
                              ? !_isStock
                                  ? GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              SingleproductScreen.routeName,
                                              arguments: {
                                                "itemid": widget.id,
                                                "itemname": widget.title,
                                                "itemimg": widget.imageUrl,
                                              });
                                        },
                                        child: CachedNetworkImage(
                                          imageUrl: widget.imageUrl,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                            Images.defaultProductImg,
                                            width: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? 75
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? 90
                                                    : 100,
                                            height: ResponsiveLayout
                                                    .isSmallScreen(context)
                                                ? 75
                                                : ResponsiveLayout
                                                        .isMediumScreen(context)
                                                    ? 90
                                                    : 100,
                                          ),
                                          width: ResponsiveLayout.isSmallScreen(
                                                  context)
                                              ? 75
                                              : ResponsiveLayout.isMediumScreen(
                                                      context)
                                                  ? 90
                                                  : 100,
                                          height: ResponsiveLayout
                                                  .isSmallScreen(context)
                                              ? 75
                                              : ResponsiveLayout.isMediumScreen(
                                                      context)
                                                  ? 90
                                                  : 100,
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                  : GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            SingleproductScreen.routeName,
                                            arguments: {
                                              "itemid": widget.id,
                                              "itemname": widget.title,
                                              "itemimg": widget.imageUrl,
                                            });
                                      },
                                      child: CachedNetworkImage(
                                        imageUrl: widget.imageUrl,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          Images.defaultProductImg,
                                          width: ResponsiveLayout.isSmallScreen(
                                                  context)
                                              ? 75
                                              : ResponsiveLayout.isMediumScreen(
                                                      context)
                                                  ? 90
                                                  : 100,
                                          height: ResponsiveLayout
                                                  .isSmallScreen(context)
                                              ? 80
                                              : ResponsiveLayout.isMediumScreen(
                                                      context)
                                                  ? 90
                                                  : 100,
                                        ),
                                        width: ResponsiveLayout.isSmallScreen(
                                                context)
                                            ? 75
                                            : ResponsiveLayout.isMediumScreen(
                                                    context)
                                                ? 90
                                                : 100,
                                        height: ResponsiveLayout.isSmallScreen(
                                                context)
                                            ? 80
                                            : ResponsiveLayout.isMediumScreen(
                                                    context)
                                                ? 90
                                                : 100,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                              : Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          SingleproductScreen.routeName,
                                          arguments: {
                                            "itemid": widget.id,
                                            "itemname": widget.title,
                                            "itemimg": widget.imageUrl,
                                          });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: 10.0, bottom: 8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.imageUrl,
                                        placeholder: (context, url) =>
                                            Image.asset(
                                          Images.defaultProductImg,
                                          width: 100,
                                          height: 80,
                                        ),
                                        width: 100,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                      /* */
                    ],
                  ),
                ),
                SizedBox(width: 5,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (MediaQuery.of(context).size.width / 2) + 60,
                      child: Container(
                         /* width:
                              (MediaQuery.of(context).size.width / 4) + 15,*/
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.60,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .primaryColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              _checkmembership
                                  ? Row(
                                children: <Widget>[
                                  Container(
                                    width: 25.0,
                                    height: 25.0,
                                    child: Image.asset(
                                      Images.membershipImg,
                                      color: Theme.of(context)
                                          .accentColor,
                                    ),
                                  ),
                                  memberpriceDisplay
                                      ? Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                                '$varmemberprice ' +
                                                    _currencyFormat,
                                                style: new TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold,
                                                    color: Theme.of(
                                                        context)
                                                        .primaryColor,
                                                    fontSize:
                                                    16.0)),
                                            SizedBox(width: 5,),
                                            Text(
                                                ' $varmrp ' +
                                                    _currencyFormat,
                                                style: TextStyle(
                                                  color:
                                                  Colors.grey,
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                )),
                                            /*Text(
                                              '/$varname',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: ColorCodes
                                                      .varcolor,
                                                  fontSize:
                                                  15),
                                            ),*/
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                  /* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                              new TextSpan(
                                                  text: _currencyFormat +
                                                      '$varmemberprice ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Theme.of(context).primaryColor,
                                                      fontSize: 18.0)),
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )*/
                                      : discountDisplay
                                      ? Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                                '$varprice ' +
                                                    _currencyFormat,
                                                style: new TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize:
                                                    16.0)),
                                            SizedBox(width: 5,),
                                            Text(
                                                ' $varmrp ' +
                                                    _currencyFormat,
                                                style:
                                                TextStyle(
                                                  color: Colors
                                                      .grey,
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                )),
                                          /*  Text(
                                              '/$varname',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: ColorCodes
                                                      .varcolor,
                                                  fontSize:
                                                  15),
                                            ),*/
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                  /* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color:Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: _currencyFormat +
                                                      '$varprice ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize:
                                                      18.0)),
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )*/
                                      : Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      /*Text(_currencyFormat +
                                                '$varmrp ',
                                                style: TextStyle(
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                )),
                                            SizedBox(height: 5,),*/
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                                '$varmrp ' +
                                                    _currencyFormat,
                                                style: new TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontSize:
                                                    16.0)),
                                            /*Text(
                                              '/$varname',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: TextStyle(
                                                  color: ColorCodes
                                                      .varcolor,
                                                  fontSize:
                                                  15),
                                            ),*/
                                          ],
                                        ),
                                      )
                                    ],
                                  ) /* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize:
                                                      18.0)),
                                            ],
                                          ),
                                        )*/
                                ],
                              )
                                  : discountDisplay
                                  ? Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                          '$varprice ' +
                                              _currencyFormat,
                                          style: new TextStyle(
                                              fontWeight:
                                              FontWeight
                                                  .bold,
                                              color: Theme.of(
                                                  context)
                                                  .primaryColor,
                                              fontSize:
                                              16.0)),
                                      SizedBox(width: 5,),
                                      Text(
                                          ' $varmrp ' +
                                              _currencyFormat,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            decoration:
                                            TextDecoration
                                                .lineThrough,
                                          )),
                                     /* Text(
                                        '/$varname',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: ColorCodes
                                                .varcolor,
                                            fontSize: 15),
                                      ),*/
                                    ],
                                  )
                                ],
                              )
                              /*new RichText(
                                      text: new TextSpan(
                                        style: new TextStyle(
                                          fontSize: 14.0,
                                          color:Theme.of(context).primaryColor,
                                        ),
                                        children: <TextSpan>[
                                          new TextSpan(
                                              text: _currencyFormat +
                                                  '$varprice ',
                                              style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 18.0)),
                                          new TextSpan(
                                              text: _currencyFormat +
                                                  '$varmrp ',
                                              style: TextStyle(
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              )),
                                        ],
                                      ),
                                    )*/
                                  : Column(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  /*Text( _currencyFormat +
                                            '$varmrp ',
                                            style: TextStyle(
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                            )),
                                        SizedBox(height: 5,),*/
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                            '$varmrp ' +
                                                _currencyFormat,
                                            style: new TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold,
                                                color: Theme.of(
                                                    context)
                                                    .primaryColor,
                                                fontSize:
                                                16.0)),
                                       /* Text(
                                          '/$varname',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: ColorCodes
                                                  .varcolor,
                                              fontSize: 15),
                                        ),*/
                                      ],
                                    ),
                                  )
                                ],
                              ) ,
                              /*   Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      widget.brand,
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),*/
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                 padding: EdgeInsets.only(right: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      '$varname',
                                     /* overflow: TextOverflow.ellipsis,
                                      maxLines: 2,*/
                                      style: TextStyle(
                                          color: ColorCodes
                                              .varcolor,
                                          fontSize:
                                          18),
                                    ),
                                  ),
                                  /*_checkmembership
                                      ? Row(
                                          children: <Widget>[
                                            Container(
                                              width: 25.0,
                                              height: 25.0,
                                              child: Image.asset(
                                                Images.membershipImg,
                                                color: Theme.of(context)
                                                    .accentColor,
                                              ),
                                            ),
                                            memberpriceDisplay
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          '$varmrp ' +
                                                              _currencyFormat,
                                                          style: TextStyle(
                                                            color:
                                                                Colors.grey,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                          )),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                                '$varmemberprice ' +
                                                                    _currencyFormat,
                                                                style: new TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .primaryColor,
                                                                    fontSize:
                                                                        16.0)),
                                                            Text(
                                                              '/$varname',
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                  color: ColorCodes
                                                                      .varcolor,
                                                                  fontSize:
                                                                      15),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                *//* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                              new TextSpan(
                                                  text: _currencyFormat +
                                                      '$varmemberprice ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color:
                                                      Theme.of(context).primaryColor,
                                                      fontSize: 18.0)),
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )*//*
                                                : discountDisplay
                                                    ? Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              '$varmrp ' +
                                                                  _currencyFormat,
                                                              style:
                                                                  TextStyle(
                                                                color: Colors
                                                                    .grey,
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough,
                                                              )),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                    '$varprice ' +
                                                                        _currencyFormat,
                                                                    style: new TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                        fontSize:
                                                                            16.0)),
                                                                Text(
                                                                  '/$varname',
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      color: ColorCodes
                                                                          .varcolor,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    *//* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color:Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: _currencyFormat +
                                                      '$varprice ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize:
                                                      18.0)),
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: TextStyle(
                                                    decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                  )),
                                            ],
                                          ),
                                        )*//*
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          *//*Text(_currencyFormat +
                                                '$varmrp ',
                                                style: TextStyle(
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                )),
                                            SizedBox(height: 5,),*//*
                                                          Expanded(
                                                            child: Row(
                                                                 children: [
                                                                Text(
                                                                    '$varmrp ' +
                                                                        _currencyFormat,
                                                                    style: new TextStyle(
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                        fontSize:
                                                                            16.0)),
                                                                Text(
                                                                  '/$varname',
                                                                  overflow: TextOverflow.ellipsis,
                                                                  maxLines: 2,
                                                                  style: TextStyle(
                                                                      color: ColorCodes
                                                                          .varcolor,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ) *//* new RichText(
                                          text: new TextSpan(
                                            style: new TextStyle(
                                              fontSize: 14.0,
                                              color: Theme.of(context).primaryColor,
                                            ),
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text:
                                                  _currencyFormat +
                                                      '$varmrp ',
                                                  style: new TextStyle(
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      color: Theme.of(context).primaryColor,
                                                      fontSize:
                                                      18.0)),
                                            ],
                                          ),
                                        )*//*
                                          ],
                                        )
                                      : discountDisplay
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '$varmrp ' +
                                                        _currencyFormat,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      decoration:
                                                          TextDecoration
                                                              .lineThrough,
                                                    )),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        '$varprice ' +
                                                            _currencyFormat,
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontSize:
                                                                16.0)),
                                                    Text(
                                                      '/$varname',
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          color: ColorCodes
                                                              .varcolor,
                                                          fontSize: 15),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          *//*new RichText(
                                      text: new TextSpan(
                                        style: new TextStyle(
                                          fontSize: 14.0,
                                          color:Theme.of(context).primaryColor,
                                        ),
                                        children: <TextSpan>[
                                          new TextSpan(
                                              text: _currencyFormat +
                                                  '$varprice ',
                                              style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 18.0)),
                                          new TextSpan(
                                              text: _currencyFormat +
                                                  '$varmrp ',
                                              style: TextStyle(
                                                decoration: TextDecoration
                                                    .lineThrough,
                                              )),
                                        ],
                                      ),
                                    )*//*
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                *//*Text( _currencyFormat +
                                            '$varmrp ',
                                            style: TextStyle(
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                            )),
                                        SizedBox(height: 5,),*//*
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                          '$varmrp ' +
                                                              _currencyFormat,
                                                          style: new TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontSize:
                                                                  16.0)),
                                                      Text(
                                                        '/$varname',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: ColorCodes
                                                                .varcolor,
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ) ,*//*new RichText(
                                      text: new TextSpan(
                                        style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        children: <TextSpan>[
                                          new TextSpan(
                                              text: _currencyFormat +
                                                  '$varmrp ',
                                              style: new TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 18.0)),
                                        ],
                                      ),
                                    )*/
                                 // SizedBox(width:10,),
                                  _isStock
                                      ? Container(
                                    height: 30.0,
                                    width: (MediaQuery.of(context)
                                        .size
                                        .width /
                                        4) +
                                        15,
                                    child: ValueListenableBuilder(
                                      valueListenable: Hive.box<Product>(
                                          productBoxName)
                                          .listenable(),
                                      builder:
                                          (context, Box<Product> box, _) {
                                        if (box.values.length <= 0)
                                          return GestureDetector(
                                            onTap: () {
                                              addToCart(int.parse(
                                                  itemvarData[0]
                                                      .varminitem));
                                            },
                                            child: Container(
                                              height: 30.0,
                                              width:
                                              (MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  4) +
                                                  15,
                                              decoration:
                                              new BoxDecoration(
                                                  color: Theme.of(
                                                      context)
                                                      .primaryColor,
                                                  borderRadius:
                                                  new BorderRadius
                                                      .only(
                                                    topLeft: const Radius
                                                        .circular(
                                                        2.0),
                                                    topRight: const Radius
                                                        .circular(
                                                        2.0),
                                                    bottomLeft:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                    bottomRight:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                  )),
                                              child: Center(
                                                  child: Text(
                                                    translate('forconvience.ADD'),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .buttonColor,
                                                    ),
                                                    textAlign:
                                                    TextAlign.center,
                                                  )),
                                              /* Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xff1BA130),
                                              borderRadius:
                                              new BorderRadius.only(
                                                topLeft:
                                                const Radius.circular(
                                                    2.0),
                                                bottomLeft:
                                                const Radius.circular(
                                                    2.0),
                                                topRight:
                                                const Radius.circular(
                                                    2.0),
                                                bottomRight:
                                                const Radius.circular(
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
                                            ),
                                          );

                                        try {
                                          Product item =
                                          Hive.box<Product>(
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
                                                      for (int i = 0;
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
                                                        color: Color(0xff32B847),
                                                          border:
                                                          Border
                                                              .all(
                                                            color: Color(
                                                                0xff32B847),
                                                          ),
                                                          borderRadius:
                                                          new BorderRadius
                                                              .only(
                                                            bottomLeft:
                                                            const Radius.circular(
                                                                2.0),
                                                            topLeft:
                                                            const Radius.circular(
                                                                2.0),
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
                                                        color: ColorCodes.whiteColor,
                                                        border: Border.all( color: Color(
                                                            0xff32B847)),
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
                                                            color: Theme.of(context).primaryColor,
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
                                                            translate('forconvience.no more item') ,// "Sorry, you can\'t add more of this item!",
                                                            backgroundColor:
                                                            Colors
                                                                .black87,
                                                            textColor:
                                                            Colors
                                                                .white);
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
                                                        color: Color(0xff32B847),
                                                          border:
                                                          Border
                                                              .all(
                                                            color: Color(
                                                                0xff32B847),
                                                          ),
                                                          borderRadius:
                                                          new BorderRadius
                                                              .only(
                                                            bottomRight:
                                                            const Radius.circular(
                                                                2.0),
                                                            topRight:
                                                            const Radius.circular(
                                                                2.0),
                                                          )),
                                                      child: Center(
                                                        child: Text(
                                                          "+",
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
                                              ],
                                            ),
                                          );
                                        } catch (e) {
                                          return GestureDetector(
                                            onTap: () {
                                              addToCart(int.parse(
                                                  itemvarData[0]
                                                      .varminitem));
                                            },
                                            child: Container(
                                              height: 30.0,
                                              width:
                                              (MediaQuery.of(context)
                                                  .size
                                                  .width /
                                                  4) +
                                                  15,
                                              decoration:
                                              new BoxDecoration(
                                                  color: Theme.of(
                                                      context)
                                                      .primaryColor,
                                                  borderRadius:
                                                  new BorderRadius
                                                      .only(
                                                    topLeft: const Radius
                                                        .circular(
                                                        2.0),
                                                    topRight: const Radius
                                                        .circular(
                                                        2.0),
                                                    bottomLeft:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                    bottomRight:
                                                    const Radius
                                                        .circular(
                                                        2.0),
                                                  )),
                                              child: Center(
                                                  child: Text(
                                                    translate('forconvience.ADD'),
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .buttonColor,
                                                    ),
                                                    textAlign:
                                                    TextAlign.center,
                                                  )),
                                              /*  Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xff1BA130),
                                              borderRadius:
                                              new BorderRadius.only(
                                                topLeft:
                                                const Radius.circular(
                                                    2.0),
                                                bottomLeft:
                                                const Radius.circular(
                                                    2.0),
                                                topRight:
                                                const Radius.circular(
                                                    2.0),
                                                bottomRight:
                                                const Radius.circular(
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
                                          translate('forconvience.Out of stock popup') , //"Out Of Stock",
                                          fontSize: 12.0,
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    },
                                    child: Container(
                                      height: 30.0,
                                      width: (MediaQuery.of(context)
                                          .size
                                          .width /
                                          4) +
                                          15,
                                      decoration: new BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey),
                                          color: Colors.grey,
                                          borderRadius:
                                          new BorderRadius.only(
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
                                      child: Center(
                                          child: Text(
                                            /*'Notify Me'*/
                                            translate('forconvience.ADD'),
                                            style: TextStyle(
                                              /*fontWeight: FontWeight.w700,*/
                                                color: Colors
                                                    .white /*Colors.black87*/),
                                            textAlign: TextAlign.center,
                                          )),
                                      /* Spacer(),
                                Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: new BorderRadius.only(
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
                                    color: Colors.white,
                                  ),
                                ),*/
                                    ),
                                  ),
                                ],
                              )),
                              SizedBox(
                                height: 10,
                              ),
                            ],
                          )),
                    ),
//                SizedBox(height: 10,),
                    /* Row(
                    children: [
                      Container(
                        width: (MediaQuery
                            .of(context)
                            .size
                            .width / 2) + 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                           */ /* Container(
                              width: (MediaQuery
                                  .of(context)
                                  .size
                                  .width / 4) + 15,
                              child: _varlength
                                  ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    showoptions();
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xff32B847)),
                                            borderRadius:
                                            new BorderRadius.only(
                                              topLeft:
                                              const Radius.circular(2.0),
                                              bottomLeft:
                                              const Radius.circular(2.0),
                                            )),
                                        height: 30,
                                        padding: EdgeInsets.fromLTRB(
                                            5.0, 4.5, 0.0, 4.5),
                                        child: Text(
                                          "$varname",
                                          style:
                                          TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Color(0xff32B847),
                                          borderRadius: new BorderRadius.only(
                                            topRight:
                                            const Radius.circular(2.0),
                                            bottomRight:
                                            const Radius.circular(2.0),
                                          )),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xff32B847)),
                                          borderRadius: new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(2.0),
                                            topRight:
                                            const Radius.circular(2.0),
                                            bottomLeft:
                                            const Radius.circular(2.0),
                                            bottomRight:
                                            const Radius.circular(2.0),
                                          )),
                                      height: 30,
                                      padding: EdgeInsets.fromLTRB(
                                          5.0, 4.5, 0.0, 4.5),
                                      child: Text(
                                        "$varname",
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),*/ /*
                            SizedBox(
                              width: 10,
                            ),

                          ],
                        ),
                      )
                    ],
                  ),*/
                    /*  !_checkmembership
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
                    /* Row(
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
                          padding: EdgeInsets.only(bottom: 10),
                          height: 25,
                          width: (MediaQuery
                              .of(context)
                              .size
                              .width / 2) +
                              40,
                          decoration:
                          BoxDecoration(color: Color(0xffefef47)),
                          child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 10),
                              Image.asset(
                                Images.starImg,
                                height: 12,
                              ),
                              SizedBox(width: 2),
                              Text(
                                  "Membership Price " +
                                      _currencyFormat +
                                      varmemberprice,
                                  style: TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 10 : ResponsiveLayout.isMediumScreen(context) ? 11 : 12,)),
                              Spacer(),
                              Icon(
                                Icons.lock,
                                color: Colors.black,
                                size: 10,
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_sharp,
                                color: Colors.black,
                                size: 10,
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
                  ],
                ),
              ],
            ),
          ),
          if (_checkmargin)
            Positioned(
              right: 10,
              top: 5,
              child: Container(
                margin: EdgeInsets.only(left: 5.0),
                padding: EdgeInsets.all(3.0),
                // color: Theme.of(context).accentColor,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomLeft: Radius.circular(3)),
                  color: ColorCodes.banner,
                ),
                constraints: BoxConstraints(
                  minWidth: 26,
                  minHeight: 16,
                ),
                child: Text(
                  margins + "% OFF",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).buttonColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      );
    }
  }
}
