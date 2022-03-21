/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/ColorCodes.dart';
import '../data/calculations.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../widgets/badge_discount.dart';

import '../providers/branditems.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../screens/singleproduct_screen.dart';
import '../screens/membership_screen.dart';
import '../widgets/badge_ofstock.dart';
import '../data/hiveDB.dart';
import '../constants/images.dart';

class Items extends StatefulWidget {
  final String _fromScreen;
  final String id;
  final String title;
  final String imageUrl;
  final String brand;

  Items(this._fromScreen, this.id, this.title, this.imageUrl, this.brand);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Box<Product> productBox;

  bool _varlength = false;
  int varlength = 0;
  var itemvarData;
  bool dialogdisplay = false;
  bool bottomsheetdisplay = false;
  var _currencyFormat = "";
  bool membershipdisplay = true;
  bool _checkmembership = false;
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
  bool discountDisplay;
  bool memberpriceDisplay;
  var margins;
  int _groupValue;

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
  var iconcolor = [];
  var textcolor = [];
  SharedPreferences prefs;
  bool _isLoading = true;

  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _isLoading = false;
        dialogdisplay = true;
      });
    });
    super.initState();
  }

  Future<void> _checkMembership() async {
    if(prefs.getString("membership") == "1"){
      _checkmembership = true;
    } else {
      _checkmembership = false;
      for (int i = 0; i < productBox.length; i++) {
        if (productBox.values.elementAt(i).mode == 1) {
          _checkmembership = true;
        }
      }
    }
  }

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }



  Widget showoptions() {
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

    incrementToCart(int _itemCount) async {
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

    showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return  Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)),
                  child: Container(
                    width: 800,
                    //height: 200,
                    padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                    child: Column(

                      mainAxisSize: MainAxisSize.min,
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

                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                  onTap: ()=> Navigator.pop(context),
                                  child: Image(
                                    height: 40,
                                    width: 40,
                                    image: AssetImage(Images.bottomsheetcancelImg),color: Colors.black,)),
                            ),
                          ],
                        ),

                        Text(
                          'Please select any one option',
                          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),

                        //Text(
                        //'Size',
                        //style: TextStyle(color: Theme.of(context).primaryColor,
                        // fontSize: 18, fontWeight: FontWeight.bold),
                        //),

                        SizedBox(
                          height: 20,
                        ),
                        SingleChildScrollView(
                          child:  ListView.builder(
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
                                        varminitem = itemvarData[i].varminitem;
                                        varmaxitem = itemvarData[i].varmaxitem;
                                        varLoyalty = itemvarData[i].varLoyalty;
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
                                            var difference =
                                            (double.parse(varmrp) -
                                                double.parse(varmemberprice));
                                            var profit =
                                                difference / double.parse(varmrp);
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
                                            var profit =
                                                difference / double.parse(varmrp);
                                            margins = profit * 100;

                                            //discount price rounding
                                            margins = num.parse(
                                                margins.toStringAsFixed(0));
                                            margins = margins.toString();
                                          }
                                        }
                                        Future.delayed(Duration(seconds: 0), () {
                                          dialogdisplay = true;
                                          for (int j = 0;
                                          j < variddata.length;
                                          j++) {
                                            if (i == j) {
                                              checkBoxdata[i] = true;
                                              containercolor[i] = 0xFFFFFFFF;
                                              textcolor[i] = 0xFF2966A2;
                                              iconcolor[i] = 0xFF2966A2;
                                            } else {
                                              checkBoxdata[j] = false;
                                              containercolor[i] = 0xFFFFFFFF;
                                              iconcolor[j] = 0xFFC1C1C1;
                                              textcolor[j] = 0xFF060606;
                                            }
                                          }
                                        });
                                        // Navigator.of(context).pop(true);
                                      });
                                    },
                                    child: Container(
                                      height: 50,
                                      padding: EdgeInsets.only(right: 10),
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
                                                color: itemvarData[i]
                                                    .varcolor,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: varnamedata[i] +
                                                      " - ",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Color(
                                                          textcolor[i]),
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                TextSpan(
                                                  text: _currencyFormat +
                                                      varmemberpricedata[
                                                      i] +
                                                      " ",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Color(
                                                          textcolor[i]),
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                    _currencyFormat +
                                                        varmrpdata[
                                                        i],
                                                    style: TextStyle(
                                                      color: Color(
                                                          textcolor[i]),
                                                      decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                    )),
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
                                                  text: _currencyFormat +
                                                      varpricedata[
                                                      i] +
                                                      " ",
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
                                                    text: _currencyFormat +
                                                        varmrpdata[
                                                        i],
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
                                                  text:
                                                  _currencyFormat +
                                                      " " +
                                                      varmrpdata[
                                                      i],
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
                                          )
                                              : itemvarData[i].discountDisplay
                                              ? RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 14.0,
                                                color: itemvarData[i]
                                                    .varcolor,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: varnamedata[i] +
                                                      " - ",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Color(
                                                          textcolor[i]),
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                TextSpan(
                                                  text: _currencyFormat +
                                                      varpricedata[
                                                      i] +
                                                      " ",
                                                  style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Color(
                                                          textcolor[i]),
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                                TextSpan(
                                                    text:
                                                    _currencyFormat +
                                                        varmrpdata[
                                                        i],
                                                    style: TextStyle(
                                                      color: Color(
                                                          textcolor[i]),
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
                                                color: itemvarData[i]
                                                    .varcolor,
                                              ),
                                              children: <TextSpan>[
                                                new TextSpan(
                                                  text: varnamedata[i] +
                                                      " - ",
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                    FontWeight.bold,
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
                                                    fontSize: 18.0,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color(
                                                        textcolor[i]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                              Icons.radio_button_checked_outlined,
                                              color: Color(iconcolor[i])),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        ),
                        // ),
                        //Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 40.0,
                              width: (MediaQuery.of(context).size.width / 3) + 18,
                              child: ValueListenableBuilder(
                                valueListenable: Hive.box<Product>(productBoxName)
                                    .listenable(),
                                builder: (context, Box<Product> box, _) {
                                  if (box.values.length <= 0)
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          addToCart(
                                              int.parse(itemvarData[0].varminitem));
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width:
                                          (MediaQuery.of(context).size.width /
                                              3) +
                                              18,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(3),
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
                                                      color:
                                                      Theme.of(context).buttonColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                  new BorderRadius.only(
                                                    bottomRight:
                                                    const Radius.circular(3),
                                                    topRight:
                                                    const Radius.circular(3),
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
                                    Product item =
                                    Hive.box<Product>(productBoxName)
                                        .values
                                        .firstWhere((value) =>
                                    value.varId == int.parse(varid));
                                    return Container(
                                      child: Row(
                                        children: <Widget>[
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (item.itemQty ==
                                                    int.parse(varminitem)) {
                                                  for (int i = 0;
                                                  i < productBox.values.length;
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
                                                      color: Theme.of(context).primaryColor,
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
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                ),
                                                height: 40,
                                                width: 30,
                                                child: Center(
                                                  child: Text(
                                                    item.itemQty.toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                          MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () {
                                                if (item.itemQty <
                                                    int.parse(varstock)) {
                                                  if (item.itemQty < int.parse(varmaxitem)) {
                                                    incrementToCart(item.itemQty + 1);
                                                  } else {
                                                    Fluttertoast.showToast(
                                                        msg:
                                                        "Sorry, you can\'t add more of this item!",
                                                        backgroundColor:
                                                        Colors.black87,
                                                        textColor: Colors.white);
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(msg: "Sorry, Out of Stock!", backgroundColor: Colors.black87, textColor: Colors.white);
                                                }
                                              },
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: new BoxDecoration(
                                                    border: Border.all(
                                                      color: Theme.of(context).primaryColor,
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
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } catch (e) {
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          addToCart(
                                              int.parse(itemvarData[0].varminitem));
                                        },
                                        child: Container(
                                          height: 40.0,
                                          width:
                                          (MediaQuery.of(context).size.width /
                                              4) +
                                              15,
                                          decoration: new BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(3),
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
                                                      color:
                                                      Theme.of(context).buttonColor,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  )),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).primaryColor,
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
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 20,)
                          ],
                        ),
                        SizedBox(width: 20)
                      ],
                    ),
                  ),
                  );


                //);
              });
            })
        .then((_) => setState(() {
              variddata.clear();
              variationdisplaydata.clear();
            }));
  }

  @override
  Widget build(BuildContext context) {
    bool _isStock = false;

    if(!_isLoading)
      _checkMembership();

    if (widget._fromScreen == "home_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else if (widget._fromScreen == "singleproduct_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdnew(widget.id);
    } else if (widget._fromScreen == "Discount") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIddiscount(widget.id);
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
      iconcolor = [];

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
      textcolor = [];
      iconcolor = [];

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
      }
    }

    if (varlength <= 0) {
    } else {
      if (!dialogdisplay) {
        varid = itemvarData[0].varid;
        varcolor = itemvarData[0].varcolor;
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

    incrementToCart(int _itemCount) async {
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

    return Expanded(
      child: Container(
        width: 200.0,
        height: MediaQuery.of(context).size.height,//aaaaaaaaaaaaaaaaaa
        child: Container(
          margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
          decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.only(
                topRight: const Radius.circular(2.0),
                topLeft: const Radius.circular(2.0),
                bottomLeft: const Radius.circular(2.0),
                bottomRight: const Radius.circular(2.0),
              )),
          child:  Column(
              children: <Widget>[
                _checkmargin
                    ? Consumer<Calculations>(
                        builder: (_, cart, ch) => Align(
                              alignment: Alignment.topLeft,
                              child: BadgeDiscount(
                                child: ch,
                                value: margins,
                              ),
                            ),
                        child: !_isStock
                            ? Consumer<Calculations>(
                                builder: (_, cart, ch) => BadgeOfStock(
                                  child: ch,
                                  value: margins,
                                  singleproduct: false,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child:MouseRegion(
                                    cursor: SystemMouseCursors.click,
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
                                          margin: EdgeInsets.only(top: 10.0),
                                          child: CachedNetworkImage(
                                            imageUrl: widget.imageUrl,
                                            placeholder: (context, url) =>
                                                Image.asset(
                                                  Images.defaultProductImg,
                                              width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                              height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                            ),
                                            width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                            height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                    ),
                                  ),
                                ),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
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
                                      margin: EdgeInsets.only(top: 10.0),
                                      child: CachedNetworkImage(
                                        imageUrl: widget.imageUrl,
                                        placeholder: (context, url) => Image.asset(
                                          Images.defaultProductImg,
                                          width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                          height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                        ),
                                        width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                        height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                    : !_isStock
                        ? Consumer<Calculations>(
                            builder: (_, cart, ch) => BadgeOfStock(
                              child: ch,
                              value: margins,
                              singleproduct: false,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
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
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      placeholder: (context, url) => Image.asset(
                                        Images.defaultProductImg,
                                        width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                        height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      ),
                                      width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Align(
                            alignment: Alignment.center,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
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
                                  margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageUrl,
                                    placeholder: (context, url) => Image.asset(
                                      Images.defaultProductImg,
                                      width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                      height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    ),
                                    width: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    height: ResponsiveLayout.isSmallScreen(context) ? 75 : ResponsiveLayout.isMediumScreen(context) ? 90 : 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.brand,
                        style: TextStyle(
                          fontSize: ResponsiveLayout.isSmallScreen(context) ? 11 : ResponsiveLayout.isMediumScreen(context) ? 12 : 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style:
                            TextStyle(fontSize: ResponsiveLayout.isSmallScreen(context) ? 13 : ResponsiveLayout.isMediumScreen(context) ? 14 : 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Product>(productBoxName).listenable(),
                      builder: (context, Box<Product> box, index) {
                        if(prefs.getString("membership") == "1"){
                          _checkmembership = true;
                        } else {
                          _checkmembership = false;
                          for (int i = 0; i < productBox.length; i++) {
                            if (productBox.values.elementAt(i).mode == 1) {
                              _checkmembership = true;
                            }
                          }
                        }
                          return _checkmembership
                              ? Row(
                            children: <Widget>[
                              Container(
                                width: 10.0,
                                height: 9.0,
                                margin: EdgeInsets.only(right: 3.0),
                                child: Image.asset(
                                  Images.starImg,
                                  color: ColorCodes.starColor,
                                ),
                              ),
                              memberpriceDisplay
                                  ? new RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                                    new TextSpan(
                                        text: _currencyFormat +
                                            '$varmemberprice ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                    new TextSpan(
                                        text: _currencyFormat + '$varmrp ',
                                        style: TextStyle(
                                            decoration:
                                            TextDecoration.lineThrough,
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                  ],
                                ),
                              )
                                  : discountDisplay
                                  ? new RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: _currencyFormat +
                                            '$varprice ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,

                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                    new TextSpan(
                                        text: _currencyFormat +
                                            '$varmrp ',
                                        style: TextStyle(
                                            decoration: TextDecoration
                                                .lineThrough,
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                                  ],
                                ),
                              )
                                  : new RichText(
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.black,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(
                                        text: _currencyFormat +
                                            '$varmrp ',
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                  ],
                                ),
                              )
                            ],
                          )
                              : discountDisplay
                              ? new RichText(
                            text: new TextSpan(
                              style: new TextStyle(
                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: _currencyFormat + '$varprice ',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                                new TextSpan(
                                    text: _currencyFormat + '$varmrp ',
                                    style: TextStyle(
                                        decoration:
                                        TextDecoration.lineThrough,
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 13 : 14,)),
                              ],
                            ),
                          )
                              : new RichText(
                            text: new TextSpan(
                              style: new TextStyle(
                                fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: _currencyFormat + '$varmrp ',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: ResponsiveLayout.isSmallScreen(context) ? 14 : ResponsiveLayout.isMediumScreen(context) ? 15 : 16,)),
                              ],
                            ),
                          );
                      },
                    ),
                    Spacer(),
                    if(double.parse(varLoyalty.toString()) > 0)
                      Container(
                        child: Row(
                          children: [
                            Image.asset(Images.coinImg,
                            height: 15.0,
                            width: 20.0,),
                          SizedBox(width: 4),
                          Text(varLoyalty.toString()),
                        ],
                      ),
                    ),
                    SizedBox(width: 10)
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                _varlength
                    ? MouseRegion(
                  cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () {
                            showoptions();
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10.0,
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
                                  padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
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
                    )
                    : Row(
                        children: [
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xff32B847)),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(2.0),
                                    topRight: const Radius.circular(2.0),
                                    bottomLeft: const Radius.circular(2.0),
                                    bottomRight: const Radius.circular(2.0),
                                  )),
                              height: 30,
                              padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                              child: Text(
                                "$varname",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                        ],
                      ),
                SizedBox(
                  height: 8,
                ),
                _isStock
                    ? Container(
                        height: 30.0,
//                width: MediaQuery.of(context).size.width,
                        child: ValueListenableBuilder(
                          valueListenable:
                              Hive.box<Product>(productBoxName).listenable(),
                          builder: (context, Box<Product> box, _) {
                            if (box.values.length <= 0)
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    addToCart(int.parse(itemvarData[0].varminitem));
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                          decoration: new BoxDecoration(
                                              color: Color(0xff32B847),
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(2.0),
                                                topRight:
                                                    const Radius.circular(2.0),
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
                                              Text(
                                                translate('forconvience.ADD'),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                    fontSize: 12, fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              Spacer(),
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              );

                            try {
                              Product item = Hive.box<Product>(productBoxName)
                                  .values
                                  .firstWhere(
                                      (value) => value.varId == int.parse(varid));
                              return Container(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 10),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (item.itemQty ==
                                              int.parse(varminitem)) {
                                            for (int i = 0;
                                                i < productBox.values.length;
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
                                              incrementToCart(item.itemQty - 1);
                                            });
                                          }
                                        },
                                        child: Container(
                                            width: 40,
                                            height: 30,
                                            decoration: new BoxDecoration(
                                                color: Color(0xff32B847),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft:
                                                      const Radius.circular(2.0),
                                                  bottomLeft:
                                                      const Radius.circular(2.0),
                                                )),
                                            child: Center(
                                              child: Text(
                                                "-",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(context).buttonColor,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
//                                width: 40,
                                        height: 30,
                                        child: Center(
                                          child: Text(
                                            item.itemQty.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xff32B847),
                                            ),
                                          ),
                                        )),
                                    Spacer(),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (item.itemQty < int.parse(varstock)) {
                                            if (item.itemQty <
                                                int.parse(varmaxitem)) {
                                              incrementToCart(item.itemQty + 1);
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                      "Sorry, you can\'t add more of this item!",
                                                  backgroundColor: Colors.black87,
                                                  textColor: Colors.white);
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: "Sorry, Out of Stock!",
                                                backgroundColor: Colors.black87,
                                                textColor: Colors.white);
                                          }
                                        },
                                        child: Container(
                                            width: 40,
                                            height: 30,
                                            decoration: new BoxDecoration(
                                                color: Color(0xff32B847),
                                                borderRadius: new BorderRadius.only(
                                                  topRight:
                                                      const Radius.circular(2.0),
                                                  bottomRight:
                                                      const Radius.circular(2.0),
                                                )),
                                            child: Center(
                                              child: Text(
                                                "+",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(context).buttonColor,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              );
                            } catch (e) {
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    addToCart(int.parse(itemvarData[0].varminitem));
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                          decoration: new BoxDecoration(
                                              color: Color(0xff32B847),
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(2.0),
                                                topRight:
                                                    const Radius.circular(2.0),
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
                                              Text(
                                                translate('forconvience.ADD'),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .buttonColor,
                                                    fontSize: 12),
                                                textAlign: TextAlign.center,
                                              ),
                                              Spacer(),
                                              Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xff1BA130),
                                                    borderRadius:
                                                        new BorderRadius.only(
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    : MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: */
/*"You will be notified via SMS/Push notification, when the product is available"*//*
 "Out Of Stock",
                                fontSize: 12.0,
                                backgroundColor: Colors.black87,
                                textColor: Colors.white);
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                  decoration: new BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight: const Radius.circular(2.0),
                                        bottomLeft: const Radius.circular(2.0),
                                        bottomRight: const Radius.circular(2.0),
                                      )),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        translate('forconvience.ADD'),
                                        style: TextStyle(
                                            color: Theme.of(context).buttonColor,
                                            fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                      Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black12,
                                            borderRadius: new BorderRadius.only(
                                              topRight: const Radius.circular(2.0),
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
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                    ),
                //SizedBox(height: 5),
                Spacer(),
                ValueListenableBuilder(
                  valueListenable: Hive.box<Product>(productBoxName).listenable(),
                  builder: (context, Box<Product> box, index) {
                    if(prefs.getString("membership") == "1"){
                      _checkmembership = true;
                    } else {
                      _checkmembership = false;
                      for (int i = 0; i < productBox.length; i++) {
                        if (productBox.values.elementAt(i).mode == 1) {
                          _checkmembership = true;
                        }
                      }
                    }
                    return Column(
                      children: [
                        Row(
                          children: <Widget>[
                            !_checkmembership
                                ? membershipdisplay
                                ? GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  MembershipScreen.routeName,
                                );
                              },
                              child: Container(
                                height: 25,
                                width: 187,
                                decoration:
                                BoxDecoration(color: Color(0xffefef47)),
                                child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(width: 10),
                                    Image.asset(
                                      Images.starImg,
                                      width: 12,
                                      height: 11,
                                      fit: BoxFit.fill,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                        "Membership Price " +
                                            _currencyFormat +
                                            varmemberprice,
                                        style: TextStyle(fontSize: 10.0)),
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
                        ),
                        !_checkmembership
                            ? membershipdisplay
                            ? SizedBox(
                          height: 10,
                        )
                            : SizedBox(
                          height: 1,
                        )
                            : SizedBox(
                          height: 1,
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
    );
  }
}
*/



//mobile



//web.....


import 'dart:io';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/ColorCodes.dart';
import '../data/calculations.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../widgets/badge_discount.dart';

import '../providers/branditems.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../screens/singleproduct_screen.dart';
import '../screens/membership_screen.dart';
import '../widgets/badge_ofstock.dart';
import '../data/hiveDB.dart';
import '../constants/images.dart';

class Items extends StatefulWidget {
  final String _fromScreen;
  final String id;
  final String title;
  final String imageUrl;
  final String brand;

  Items(this._fromScreen, this.id, this.title, this.imageUrl, this.brand);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Box<Product> productBox;

  bool _varlength = false;
  int varlength = 0;
  var itemvarData;
  bool dialogdisplay = false;
  bool bottomsheetdisplay = false;
  var _currencyFormat = "";
  bool membershipdisplay = true;
  bool _checkmembership = false;
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
  bool discountDisplay;
  bool memberpriceDisplay;
  var margins;
  int _groupValue;

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
  var iconcolor = [];
  var textcolor = [];
  SharedPreferences prefs;
  bool _isLoading = true;
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
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _isLoading = false;
        dialogdisplay = true;
      });
    });
    super.initState();
  }

  Future<void> _checkMembership() async {
    if(prefs.getString("membership") == "1"){
      _checkmembership = true;
    } else {
      _checkmembership = false;
      for (int i = 0; i < productBox.length; i++) {
        if (productBox.values.elementAt(i).mode == 1) {
          _checkmembership = true;
        }
      }
    }
  }

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }



  Widget showoptions() {
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

    incrementToCart(int _itemCount) async {
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

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return  Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                width: 800,
                //height: 200,
                padding: EdgeInsets.fromLTRB(30, 20, 20, 20),
                child: Column(

                  mainAxisSize: MainAxisSize.min,
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

                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                              onTap: ()=> Navigator.pop(context),
                              child: Image(
                                height: 40,
                                width: 40,
                                image: AssetImage(Images.bottomsheetcancelImg),color: Colors.black,)),
                        ),
                      ],
                    ),

                    Text(
                      'Please select any one option',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),

                    //Text(
                    //'Size',
                    //style: TextStyle(color: Theme.of(context).primaryColor,
                    // fontSize: 18, fontWeight: FontWeight.bold),
                    //),

                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      child:  ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: variationdisplaydata.length,
                          itemBuilder: (_, i) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  setState(() {
                                    varid = itemvarData[i].varid;
                                    varname = itemvarData[i].varname;
                                    varmrp = itemvarData[i].varmrp;
                                    varprice = itemvarData[i].varprice;
                                    varmemberprice =
                                        itemvarData[i].varmemberprice;
                                    varminitem = itemvarData[i].varminitem;
                                    varmaxitem = itemvarData[i].varmaxitem;
                                    varLoyalty = itemvarData[i].varLoyalty;
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
                                        var difference =
                                        (double.parse(varmrp) -
                                            double.parse(varmemberprice));
                                        var profit =
                                            difference / double.parse(varmrp);
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
                                        var profit =
                                            difference / double.parse(varmrp);
                                        margins = profit * 100;

                                        //discount price rounding
                                        margins = num.parse(
                                            margins.toStringAsFixed(0));
                                        margins = margins.toString();
                                      }
                                    }
                                    Future.delayed(Duration(seconds: 0), () {
                                      dialogdisplay = true;
                                      for (int j = 0;
                                      j < variddata.length;
                                      j++) {
                                        if (i == j) {
                                          checkBoxdata[i] = true;
                                          containercolor[i] = 0xFFFFFFFF;
                                          textcolor[i] = 0xFF2966A2;
                                          iconcolor[i] = 0xFF2966A2;
                                        } else {
                                          checkBoxdata[j] = false;
                                          containercolor[i] = 0xFFFFFFFF;
                                          iconcolor[j] = 0xFFC1C1C1;
                                          textcolor[j] = 0xFF060606;
                                        }
                                      }
                                    });
                                    // Navigator.of(context).pop(true);
                                  });
                                },
                                child: Container(
                                  height: 50,
                                  padding: EdgeInsets.only(right: 10),
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
                                            color: itemvarData[i]
                                                .varcolor,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: varnamedata[i] +
                                                  " - ",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Color(
                                                      textcolor[i]),
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                            TextSpan(
                                              text: _currencyFormat +
                                                  varmemberpricedata[
                                                  i] +
                                                  " ",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Color(
                                                      textcolor[i]),
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                            TextSpan(
                                                text:
                                                _currencyFormat +
                                                    varmrpdata[
                                                    i],
                                                style: TextStyle(
                                                  color: Color(
                                                      textcolor[i]),
                                                  decoration:
                                                  TextDecoration
                                                      .lineThrough,
                                                )),
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
                                              text: _currencyFormat +
                                                  varpricedata[
                                                  i] +
                                                  " ",
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
                                                text: _currencyFormat +
                                                    varmrpdata[
                                                    i],
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
                                              text:
                                              _currencyFormat +
                                                  " " +
                                                  varmrpdata[
                                                  i],
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
                                      )
                                          : itemvarData[i].discountDisplay
                                          ? RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: itemvarData[i]
                                                .varcolor,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: varnamedata[i] +
                                                  " - ",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Color(
                                                      textcolor[i]),
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                            TextSpan(
                                              text: _currencyFormat +
                                                  varpricedata[
                                                  i] +
                                                  " ",
                                              style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Color(
                                                      textcolor[i]),
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                            TextSpan(
                                                text:
                                                _currencyFormat +
                                                    varmrpdata[
                                                    i],
                                                style: TextStyle(
                                                  color: Color(
                                                      textcolor[i]),
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
                                            color: itemvarData[i]
                                                .varcolor,
                                          ),
                                          children: <TextSpan>[
                                            new TextSpan(
                                              text: varnamedata[i] +
                                                  " - ",
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight:
                                                FontWeight.bold,
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
                                                fontSize: 18.0,
                                                fontWeight:
                                                FontWeight.bold,
                                                color: Color(
                                                    textcolor[i]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                          Icons.radio_button_checked_outlined,
                                          color: Color(iconcolor[i])),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ),
                    // ),
                    //Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        (int.parse(varstock) <= 0 )?
                        GestureDetector(
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: /*"You will be notified via SMS/Push notification, when the product is available"*/ "Out Of Stock",
                                fontSize: 12.0,
                                backgroundColor: Colors.black87,
                                textColor: Colors.white);
                          },
                          child: Container(
                            height: 30.0,
                            width:
                            (MediaQuery.of(context).size.width / 4) +
                                15,
                            decoration: new BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.grey,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(2.0),
                                  topRight: const Radius.circular(2.0),
                                  bottomLeft: const Radius.circular(2.0),
                                  bottomRight: const Radius.circular(2.0),
                                )),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Center(
                                    child: Text(
                                      /*'Notify Me'*/ "ADD",
                                      style: TextStyle(
                                        /*fontWeight: FontWeight.w700,*/ color:
                                      Colors
                                          .white /*Colors.black87*/),
                                      textAlign: TextAlign.center,
                                    )),
                                Spacer(),
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
                                ),
                              ],
                            ),
                          ),
                        ):
                        Container(
                          height: 40.0,
                          width: (MediaQuery.of(context).size.width / 3) + 18,
                          child: ValueListenableBuilder(
                            valueListenable: Hive.box<Product>(productBoxName)
                                .listenable(),
                            builder: (context, Box<Product> box, _) {
                              if (box.values.length <= 0)
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      addToCart(
                                          int.parse(itemvarData[0].varminitem));
                                    },
                                    child: Container(
                                      height: 40.0,
                                      width:
                                      (MediaQuery.of(context).size.width /
                                          3) +
                                          18,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                              child: Text(
                                                'ADD',
                                                style: TextStyle(
                                                  color:
                                                  Theme.of(context).buttonColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                          Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                              new BorderRadius.only(
                                                bottomRight:
                                                const Radius.circular(3),
                                                topRight:
                                                const Radius.circular(3),
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
                                Product item =
                                Hive.box<Product>(productBoxName)
                                    .values
                                    .firstWhere((value) =>
                                value.varId == int.parse(varid));
                                return Container(
                                  child: Row(
                                    children: <Widget>[
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (item.itemQty ==
                                                int.parse(varminitem)) {
                                              for (int i = 0;
                                              i < productBox.values.length;
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
                                                  color: Theme.of(context).primaryColor,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                            ),
                                            height: 40,
                                            width: 30,
                                            child: Center(
                                              child: Text(
                                                item.itemQty.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )),
                                      ),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (item.itemQty < int.parse(varstock)) {
                                              if (item.itemQty < int.parse(varmaxitem)) {
                                                incrementToCart(item.itemQty + 1);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                    "Sorry, you can\'t add more of this item!",
                                                    backgroundColor:
                                                    Colors.black87,
                                                    textColor: Colors.white);
                                              }
                                            } else {
                                              Fluttertoast.showToast(msg: "Sorry, Out of Stock!", backgroundColor: Colors.black87, textColor: Colors.white);
                                            }
                                          },
                                          child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: new BoxDecoration(
                                                border: Border.all(
                                                  color: Theme.of(context).primaryColor,
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
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      addToCart(
                                          int.parse(itemvarData[0].varminitem));
                                    },
                                    child: Container(
                                      height: 40.0,
                                      width:
                                      (MediaQuery.of(context).size.width /
                                          4) +
                                          15,
                                      decoration: new BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                              child: Text(
                                                'ADD',
                                                style: TextStyle(
                                                  color:
                                                  Theme.of(context).buttonColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                          Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).primaryColor,
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
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 20,)
                      ],
                    ),
                    SizedBox(width: 20)
                  ],
                ),
              ),
            );


            //);
          });
        })
        .then((_) => setState(() {
      variddata.clear();
      variationdisplaydata.clear();
    }));
  }

  @override
  Widget build(BuildContext context) {
    bool _isStock = false;

    if(!_isLoading)
      _checkMembership();

    if (widget._fromScreen == "home_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findById(widget.id);
    } else if (widget._fromScreen == "singleproduct_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdnew(widget.id);
    } else if (widget._fromScreen == "Discount") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIddiscount(widget.id);
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
      iconcolor = [];

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
      textcolor = [];
      iconcolor = [];

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
      }
    }

    if (varlength <= 0) {
    } else {
      if (!dialogdisplay) {
        varid = itemvarData[0].varid;
        varcolor = itemvarData[0].varcolor;
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
      facebookAppEvents.logAddToCart(id: int.parse(widget.id).toString(), type: widget.title, currency: _currencyFormat, price: double.parse(varmrp));
    }

    incrementToCart(int _itemCount) async {
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

    if(_isWeb && !ResponsiveLayout.isSmallScreen(context)) {
      return Flexible(
        child: Container(
          width: 210.0,
          height: MediaQuery
              .of(context)
              .size
              .height * 0.50, //aaaaaaaaaaaaaaaaaa
          child: Container(
            margin: EdgeInsets.only(
                left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorCodes.borderColor),
                borderRadius: new BorderRadius.only(
                  topRight: const Radius.circular(4.0),
                  topLeft: const Radius.circular(4.0),
                  bottomLeft: const Radius.circular(4.0),
                  bottomRight: const Radius.circular(4.0),
                )),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _checkmargin
                    ?
                Consumer<Calculations>(
                    builder: (_, cart, ch) =>
                        Align(
                          alignment: Alignment.topLeft,
                          child: BadgeDiscount(
                            child: ch,
                            value: margins,
                          ),
                        ),
                    child: !_isStock
                        ? Column(
                      children: [
                        SizedBox(height: 50),
                        Align(
                          alignment: Alignment.center,
                          child: Consumer<Calculations>(
                            builder: (_, cart, ch) =>
                                BadgeOfStock(
                                  child: ch,
                                  value: margins,
                                  singleproduct: false,
                                  item: true,
                                ),
                            child: Align(
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
                                  //margin: EdgeInsets.only(top: 40.0,bottom: 10),
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
                          ),
                        ),
                      ],
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
                          margin: EdgeInsets.only(top: 40.0, bottom: 12),
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
                    ))
                    : !_isStock
                    ?
                Column(
                  children: [
                    SizedBox(height: 37),
                    Align(

                      alignment: Alignment.center,
                      child: Consumer<Calculations>(

                        builder: (_, cart, ch) =>
                            BadgeOfStock(
                              child: ch,
                              value: margins,
                              singleproduct: false,
                              item: true,

                            ),
                        child: Align(
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
                              //margin: EdgeInsets.only(top: 40.0,bottom: 10),
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
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                )
                    : Column(
                  children: [
                    SizedBox(height: 34,),
                    Align(
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
                          margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
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
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                /* Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.brand,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*/
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    !_isStock && !discountDisplay ?

                    SizedBox(height: 23)
                        :
                    SizedBox.shrink(),
                    Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
                /* Spacer(),*/
                discountDisplay ?
                SizedBox(height: 8,) :
                SizedBox(height: 10,),
                // SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    _checkmembership
                        ? Row(
                      children: <Widget>[
                        Container(
                          width: 12.0,
                          height: 11.0,
                          child: Image.asset(
                            Images.starImg,
                            color: Theme
                                .of(context)
                                .accentColor,
                          ),
                        ),
                        memberpriceDisplay
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(varmemberprice.toString() == varmrp.toString())
                              Text('$varmrp ' + _currencyFormat,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: 12.0)),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Text(
                                    '$varmemberprice ' + _currencyFormat,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text('/$varname', style: TextStyle(
                                    color: ColorCodes.varcolor, fontSize: 16),),
                              ],
                            ),

                          ],
                        )
                        /* new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmemberprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat + '$varmrp ',
                                  style: TextStyle(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*/
                            : discountDisplay
                            ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$varmrp ' + _currencyFormat,
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Text(
                                    '$varprice ' + _currencyFormat,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text(' /$varname', style: TextStyle(
                                    color: ColorCodes.varcolor, fontSize: 16),),
                              ],
                            ),

                          ],
                        )
                        /*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: TextStyle(
                                      decoration: TextDecoration
                                          .lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*/
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /* Text( _currencyFormat + '$varmrp ',
                                style: TextStyle(
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),*/
                            Row(
                              children: [
                                Text(
                                    '$varmrp ' + _currencyFormat,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text('/$varname', style: TextStyle(
                                    color: ColorCodes.varcolor, fontSize: 16),),
                              ],
                            ),

                          ],
                        ) /*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                            ],
                          ),
                        )*/
                      ],
                    )
                        : discountDisplay
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$varmrp ' + _currencyFormat,
                            style: TextStyle(
                                color: Colors.grey,
                                decoration:
                                TextDecoration.lineThrough,
                                fontSize: 12.0)),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text(
                                '$varprice ' + _currencyFormat,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0)),
                            Text(' /$varname', style: TextStyle(
                                color: ColorCodes.varcolor, fontSize: 16),),
                          ],
                        ),

                      ],
                    ) /*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varprice ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: TextStyle(
                                  decoration:
                                  TextDecoration.lineThrough,
                                  fontSize: 12.0)),
                        ],
                      ),
                    )*/
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /*Text( _currencyFormat + '$varmrp ',
                            style: TextStyle(
                                decoration:
                                TextDecoration.lineThrough,
                                fontSize: 12.0)),*/
                        SizedBox(height: 17),
                        Row(
                          children: [
                            Text('$varmrp ' + _currencyFormat,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0)),
                            Text(' /$varname', style: TextStyle(
                                color: ColorCodes.varcolor, fontSize: 16),),
                          ],
                        ),

                      ],
                    ), /*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                        ],
                      ),
                    ),*/
                    // Spacer(),
                    SizedBox(height: 20,),
                    // if(double.parse(varLoyalty.toString()) > 0)
                    //   Container(
                    //     child: Row(
                    //       children: [
                    //         Image.asset(Images.coinImg,
                    //         height: 15.0,
                    //         width: 20.0,),
                    //       SizedBox(width: 4),
                    //       Text(varLoyalty.toString()),
                    //     ],
                    //   ),
                    // ),
                    //  SizedBox(width: 10)
                  ],
                ),
                /*  SizedBox(
                  height: 8,
                ),*/
                /*               _varlength
                    ? GestureDetector(
                  onTap: () {
                    showoptions();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color:  ColorCodes.lightgreen),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                              )),
                          height: 30,
                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "$varname",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 40,
                        decoration: BoxDecoration(
                            color:  ColorCodes.lightgreen,
                            borderRadius: new BorderRadius.only(
                              topRight: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorCodes.darkgreen,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                )
                    : Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(2.0),
                              topRight: const Radius.circular(2.0),
                              bottomLeft: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        height: 30,
                        padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                        child: Text(
                          "$varname",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*/
                !discountDisplay ?
                SizedBox(
                  height: 8,
                ) :
                SizedBox(
                  height: 8,
                )
                ,
                Column(
                  children: [
                    Container(
                      width: (MediaQuery
                          .of(context)
                          .size
                          .width / 2) + 40,

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
                                showoptions();
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
                          ),
                          SizedBox(
                            width: 10,
                          ),
*/
                          _isStock
                              ?
                          Container(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            height: 30.0,
                            width: (MediaQuery
                                .of(context)
                                .size
                                .width / 4) +
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
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width /
                                          4) +
                                          15,
                                      decoration: new BoxDecoration(
                                          color: Color(0xff32B847),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(2.0),
                                            topRight:
                                            const Radius.circular(2.0),
                                            bottomLeft:
                                            const Radius.circular(2.0),
                                            bottomRight:
                                            const Radius.circular(2.0),
                                          )),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                              child: Text(
                                                translate('forconvience.ADD'),
                                                //'ADD',
                                                style: TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .buttonColor,
                                                ),
                                                textAlign: TextAlign.center,
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
                                        ],
                                      ),
                                    ),
                                  );

                                try {
                                  Product item = Hive
                                      .box<Product>(
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
                                              width: 30,
                                              height: 30,
                                              decoration: new BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                    Color(0xff32B847),
                                                  ),
                                                  borderRadius:
                                                  new BorderRadius.only(
                                                    bottomLeft: const Radius
                                                        .circular(2.0),
                                                    topLeft: const Radius
                                                        .circular(2.0),
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
                                        Flexible(
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
                                                int.parse(varstock)) {
                                              if (item.itemQty <
                                                  int.parse(varmaxitem)) {
                                                incrementToCart(
                                                    item.itemQty + 1);
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg:
                                                    translate(
                                                        'forconvience.no more item'),
                                                    //"Sorry, you can\'t add more of this item!",
                                                    backgroundColor:
                                                    Colors.black87,
                                                    textColor:
                                                    Colors.white);
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg:
                                                  translate(
                                                      'forconvience.Out of stock popup'),
                                                  //"Sorry, Out of Stock!",
                                                  backgroundColor:
                                                  Colors.black87,
                                                  textColor: Colors.white);
                                            }
                                          },
                                          child: Container(
                                              //margin: EdgeInsets.only(left: 10, right: 10),
                                              width: 30,
                                              height: 30,
                                              decoration: new BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                    Color(0xff32B847),
                                                  ),
                                                  borderRadius:
                                                  new BorderRadius.only(
                                                    bottomRight:
                                                    const Radius
                                                        .circular(2.0),
                                                    topRight: const Radius
                                                        .circular(2.0),
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
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width /
                                          4) +
                                          15,
                                      decoration: new BoxDecoration(
                                          color: Color(0xff32B847),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(2.0),
                                            topRight:
                                            const Radius.circular(2.0),
                                            bottomLeft:
                                            const Radius.circular(2.0),
                                            bottomRight:
                                            const Radius.circular(2.0),
                                          )),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Center(
                                              child: Text(
                                                translate('forconvience.ADD'),
                                                //'ADD',
                                                style: TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .buttonColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              )),
                                          /*   Spacer(),
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
                                  msg: translate(
                                      'forconvience.Out of stock popup'),
                                  //"You will be notified via SMS/Push notification, when the product is available" "Out Of Stock",
                                  fontSize: 12.0,
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white);
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              margin: EdgeInsets.only(left: 10, right: 10),
                              height: 30.0,
                              width:
                              (MediaQuery
                                  .of(context)
                                  .size
                                  .width / 4) +
                                  15,
                              decoration: new BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  color: Colors.grey,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(2.0),
                                    topRight: const Radius.circular(2.0),
                                    bottomLeft: const Radius.circular(2.0),
                                    bottomRight: const Radius.circular(2.0),
                                  )),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Center(
                                      child: Text(
                                        translate('forconvience.ADD'),
                                        /*'Notify Me'
                                        "ADD"*/
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color:
                                            Colors
                                                .white),
                                        textAlign: TextAlign.center,
                                      )),
                                  /*Spacer(),
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                /* _isStock
                  ? Container(
                height: 30.0,
//                width: MediaQuery.of(context).size.width,
                child: ValueListenableBuilder(
                  valueListenable:
                  Hive.box<Product>(productBoxName).listenable(),
                  builder: (context, Box<Product> box, _) {
                    if (box.values.length <= 0)
                      return GestureDetector(
                        onTap: () {
                          addToCart(int.parse(itemvarData[0].varminitem));
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                decoration: new BoxDecoration(
                                    color:  Theme.of(context).primaryColor,
                                    border: Border.all(color:  Theme.of(context).primaryColor),
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(2.0),
                                      topRight:
                                      const Radius.circular(2.0),
                                      bottomLeft:
                                      const Radius.circular(2.0),
                                      bottomRight:
                                      const Radius.circular(2.0),
                                    )),
                                child: */ /*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*/ /*
                                Center(
                                  child: Text(
                                    translate('forconvience.ADD'),
                                    style: TextStyle(
                                        color: ColorCodes.whiteColor,
                                        fontSize: 12, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                */ /* Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:  ColorCodes.lightgreen,
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
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),*/ /*
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      );

                    try {
                      Product item = Hive.box<Product>(productBoxName)
                          .values
                          .firstWhere(
                              (value) => value.varId == int.parse(varid));
                      return Container(
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () async {
                                if (item.itemQty ==
                                    int.parse(varminitem)) {
                                  for (int i = 0;
                                  i < productBox.values.length;
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
                                    incrementToCart(item.itemQty - 1);
                                  });
                                }
                              },
                              child: Container(
                                  width: 40,
                                  height: 30,
                                  decoration: new BoxDecoration(
                                      border: Border.all(color:  Theme.of(context).primaryColor),
                                      color:   Theme.of(context).primaryColor,
                                      borderRadius: new BorderRadius.only(
                                        topLeft:
                                        const Radius.circular(2.0),
                                        bottomLeft:
                                        const Radius.circular(2.0),
                                      )),
                                  child:Center(
                                    child: Text(
                                      "-",
                                      textAlign:
                                      TextAlign
                                          .center,
                                      style:
                                      TextStyle(
                                        fontSize: 20,
                                        color: ColorCodes.whiteColor,
                                      ),
                                    ),
                                  )),
                            ),
                            // Spacer(),


                            Container(
//                                width: 40,
                                width: 65,
                                height: 30,
                                decoration: new BoxDecoration(
                                    border: Border.all(color:  Theme.of(context).primaryColor),
                                    //color:  ColorCodes.lightgreen,
                                    borderRadius: new BorderRadius.only(
                                      topLeft:
                                      const Radius.circular(2.0),
                                      bottomLeft:
                                      const Radius.circular(2.0),
                                    )),
                                child: Center(
                                  child: Text(
                                    item.itemQty.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color:  ColorCodes.darkgreen,
                                    ),
                                  ),
                                )),


                            //Spacer(),
                            GestureDetector(
                              onTap: () {
                                if (item.itemQty < int.parse(varstock)) {
                                  if (item.itemQty <
                                      int.parse(varmaxitem)) {
                                    incrementToCart(item.itemQty + 1);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                        translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                        backgroundColor: Colors.black87,
                                        textColor: Colors.white);
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Sorry, Out of Stock!",
                                      backgroundColor: Colors.black87,
                                      textColor: Colors.white);
                                }
                              },
                              child: Container(
                                  width: 40,
                                  height: 30,
                                  decoration: new BoxDecoration(
                                      color:  Theme.of(context).primaryColor,
                                      border: Border.all(color:  Theme.of(context).primaryColor),
                                      borderRadius: new BorderRadius.only(
                                        topRight:
                                        const Radius.circular(2.0),
                                        bottomRight:
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
                                        fontSize: 20,
                                        color: ColorCodes.whiteColor,
                                      ),
                                    ),
                                  )),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      );
                    } catch (e) {
                      return GestureDetector(
                        onTap: () {
                          addToCart(int.parse(itemvarData[0].varminitem));
                        },
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                decoration: new BoxDecoration(
                                    color:   Theme.of(context).primaryColor,
                                    border: Border.all(color:  Theme.of(context).primaryColor),
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(2.0),
                                      topRight:
                                      const Radius.circular(2.0),
                                      bottomLeft:
                                      const Radius.circular(2.0),
                                      bottomRight:
                                      const Radius.circular(2.0),
                                    )),
                                child: */ /*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*/ /*
                                Center(
                                  child: Text(
                                    translate('forconvience.ADD'),
                                    style: TextStyle(
                                        color: ColorCodes.whiteColor,
                                        fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                */ /*  Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: ColorCodes.lightgreen,
                                            borderRadius:
                                            new BorderRadius.only(
                                              topRight:
                                              const Radius.circular(
                                                  2.0),
                                              bottomRight:
                                              const Radius.circular(
                                                  2.0),
                                            )),
                                        height: 30,
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),
                                    ],
                                  ),*/ /*
                              ),
                            ),
                            SizedBox(width: 10),
                          ],
                        ),
                      );
                    }
                  },
                ),
              )
                  : GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                      msg: */ /*"You will be notified via SMS/Push notification, when the product is available"*/ /*
                      translate('forconvience.Out of stock popup'),  //"Out Of Stock",
                      fontSize: 12.0,
                      backgroundColor: Colors.black87,
                      textColor: Colors.white);
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                        decoration: new BoxDecoration(
                            color: Colors.grey,
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(2.0),
                              topRight: const Radius.circular(2.0),
                              bottomLeft: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: */ /*Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),*/ /*
                        Center(
                          child: Text(
                            translate('forconvience.ADD'),
                            style: TextStyle(
                                color: ColorCodes.whiteColor,
                                fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        */ /*  Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: new BorderRadius.only(
                                      topRight: const Radius.circular(2.0),
                                      bottomRight:
                                      const Radius.circular(2.0),
                                    )),
                                height: 30,
                                width: 40,
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: ColorCodes.darkgreen,
                                ),
                              ),
                            ],
                          ),*/ /*
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),*/
                SizedBox(height: 5),
                // Spacer(),
                // SizedBox(height: 10,),
                /* Row(
                  children: <Widget>[
                    !_checkmembership
                        ? membershipdisplay
                        ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );
                      },
                      child: Container(
                        height: 25,
                        width: 185,
                        decoration:
                        BoxDecoration(color: Color(0xffefef47)),
                        child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 10),
                            Image.asset(
                              Images.starImg,
                              width: 10,
                              height: 11,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(width: 2),
                            Text(
                                "Membership Price " +
                                    _currencyFormat +
                                    varmemberprice,
                                style: TextStyle(fontSize: 10.0)),
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
                /* !_checkmembership
                    ? membershipdisplay
                    ? SizedBox(
                  height: 10,
                )*/
                /*   : SizedBox(
                  height: 1,
                )
                    :*/ /*SizedBox(
                  height: 1,
                )*/
              ],
            ),
          ),
        ),
      );
    }
    else{
      return
        Expanded(
          child: Container(
            width: 180.0,
            height: MediaQuery.of(context).size.height*0.50,//aaaaaaaaaaaaaaaaaa
            child: Container(
              margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
              decoration: new BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: ColorCodes.borderColor),
                  borderRadius: new BorderRadius.only(
                    topRight: const Radius.circular(4.0),
                    topLeft: const Radius.circular(4.0),
                    bottomLeft: const Radius.circular(4.0),
                    bottomRight: const Radius.circular(4.0),
                  )),
              child:  Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _checkmargin
                      ?
                  Column(
                    children: [
                      Consumer<Calculations>(
                          builder: (_, cart, ch) => Stack(
                            children:[
                              Align(
                                alignment: Alignment.topLeft,
                                child: BadgeDiscount(
                                  child: ch,
                                  value: margins,
                                ),
                              ),
                              if(varLoyalty>0)
                                Align(
                                  alignment: Alignment.topRight,
                                  child:  Padding(
                                    padding: const EdgeInsets.only(top:2.0,right:2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 20.0,
                                          width: 25.0,),
                                        Text('$varLoyalty'),
                                      ],

                                    ),
                                  ),
                                )
                            ]
                          ),
                          child: !_isStock
                              ? Column(
                            children: [
                              SizedBox(height:50),
                              Align(
                                alignment: Alignment.center,
                                child: Consumer<Calculations>(
                                  builder: (_, cart, ch) => BadgeOfStock(
                                    child: ch,
                                    value: margins,
                                    singleproduct: false,
                                    item: true,
                                  ),
                                  child: Align(
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
                                        //margin: EdgeInsets.only(top: 40.0,bottom: 10),
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
                                ),
                              ),
                            ],
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
                                margin: EdgeInsets.only(top: 40.0,bottom: 12),
                                child: CachedNetworkImage(
                                  imageUrl: widget.imageUrl,
                                  placeholder: (context, url) => Image.asset(
                                    Images.defaultProductImg,
                                    width: 100,
                                    height: 80,
                                  ),
                                  width:100,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )),
                    ],
                  )
                      : !_isStock
                      ?
                  Column(
                    children: [
                      SizedBox(height:37),
                      Align(

                        alignment: Alignment.center,
                        child: Consumer<Calculations>(

                          builder: (_, cart, ch) => BadgeOfStock(
                            child: ch,
                            value: margins,
                            singleproduct: false,
                            item: true,

                          ),
                          child: Row(
                            children: [
                              if(varLoyalty>0)
                                Align(
                                  alignment: Alignment.topRight,
                                  child:  Padding(
                                    padding: const EdgeInsets.only(top:2.0,right:2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 20.0,
                                          width: 25.0,),
                                        Text('$varLoyalty'),
                                      ],

                                    ),
                                  ),
                                ),
                              Align(
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
                                    //margin: EdgeInsets.only(top: 40.0,bottom: 10),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      placeholder: (context, url) => Image.asset(
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
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height:10),
                    ],
                  )
                      : Column(
                    children: [
                     // SizedBox(height: 34,),
                      if(varLoyalty>0)
                        Align(
                          alignment: Alignment.topRight,
                          child:  Padding(
                            padding: const EdgeInsets.only(top:2.0,right:2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Image.asset(Images.coinImg,
                                  height: 20.0,
                                  width: 25.0,),
                                Text('$varLoyalty'),
                              ],

                            ),
                          ),
                        ),
                      (varLoyalty>0)?SizedBox(height: 12,):SizedBox(height: 34,),
                      Align(
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
                            margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                            child: CachedNetworkImage(
                              imageUrl: widget.imageUrl,
                              placeholder: (context, url) => Image.asset(
                                Images.defaultProductImg,
                                width: 100,
                                height:80,
                              ),
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      ),

                    ],
                  ),

                  /*_checkmargin
                      ? Column(
                    children: [
                     // SizedBox(height:10),
                      Consumer<Calculations>(
                          builder: (_, cart, ch) => Stack(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: BadgeDiscount(
                                  child: ch,
                                  value: margins,
                                ),
                              ),
                              if(varLoyalty>0)
                                Align(
                                  alignment: Alignment.topRight,
                                  child:  Padding(
                                    padding: const EdgeInsets.only(top:2.0,right:2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(Images.coinImg,
                                          height: 20.0,
                                          width: 25.0,),
                                        Text('$varLoyalty'),
                                      ],

                                    ),
                                  ),
                                )
                            ],
                          ),

                          child: !_isStock
                              ? Consumer<Calculations>(
                            builder: (_, cart, ch) => BadgeOfStock(
                              child: ch,
                              value: margins,
                              singleproduct: false,
                              item: true,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child:MouseRegion(
                                cursor: SystemMouseCursors.click,
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
                                    margin: EdgeInsets.only(top: 40.0,bottom: 12),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                                  placeholder: (context, url) => Image.asset(
                                                        Images.defaultProductImg,
                                                        width: 100,
                                                        height: 80,
                                                      ),
                                                      width:100,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                      //   fit: BoxFit.fill,
                                    ),
                                  ),

                                ),
                              ),
                            ),
                          )
                              : Align(
                            alignment: Alignment.center,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
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
                                  margin: EdgeInsets.only(top: 50.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageUrl,
                                    placeholder: (context, url) => Image.asset(
                                            Images.defaultProductImg,
                                            width: 100,
                                            height: 80,
                                          ),
                                          width:100,
                                          height: 80,
                                          fit: BoxFit.cover,
                                    //fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ],
                  )
                      : !_isStock
                      ? Column(
                    children: [
                      SizedBox(height: 34,),
                      Consumer<Calculations>(
                        builder: (_, cart, ch) => BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                          item: true,
                        ),
                        child: Row(
                          children: [
                            if(varLoyalty>0)
                              Align(
                                alignment: Alignment.topRight,
                                child:  Padding(
                                  padding: const EdgeInsets.only(top:2.0,right:2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.coinImg,
                                        height: 20.0,
                                        width: 25.0,),
                                     Text('$varLoyalty'),
                                    ]),
                                ),
                              ),
                            Align(
                              alignment: Alignment.center,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
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
                                    margin: EdgeInsets.only(top: 10.0),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.imageUrl,
                                      placeholder: (context, url) => Image.asset(
                                        Images.defaultProductImg,
                                        width: 100,
                                        height: 80,
                                      ),
                                      width:100,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      //  SizedBox(height: 8,),
                      Stack(
                        children: [

                          if(varLoyalty>0)
                            Align(
                              alignment: Alignment.topRight,
                              child:   Padding(
                                padding: const EdgeInsets.only(top:2.0,right:2),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Image.asset(Images.coinImg,
                                        height: 20.0,
                                        width: 25.0,),
                                      Text('$varLoyalty'),
                                    ]),
                              ),
                            ),
                          Align(
                            alignment: Alignment.center,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
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
                                  margin: EdgeInsets.only(top: 50.0),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.imageUrl,
                                    placeholder: (context, url) => Image.asset(
                                      Images.defaultProductImg,
                                      width: 100,
                                      height: 80,
                                    ),
                                    width:100,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),*/
                  SizedBox(
                    height: 8,
                  ),
                  /* Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.brand,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*/
                  Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      !_isStock && !discountDisplay?

                      SizedBox(height:23)
                          :
                      SizedBox.shrink(),
                      Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                  /* Spacer(),*/
                  discountDisplay?
                  SizedBox(height: 8,):
                  SizedBox(height: 10,),
                  // SizedBox(height: 20,),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10.0,
                      ),
                      _checkmembership
                          ? Row(
                        children: <Widget>[
                          Container(
                            width: 12.0,
                            height: 11.0,
                            child: Image.asset(
                              Images.starImg,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          memberpriceDisplay
                              ?Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if(varmemberprice.toString() == varmrp.toString())
                                Text( '$varmrp '+_currencyFormat ,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        decoration:
                                        TextDecoration.lineThrough,
                                        fontSize: 12.0)),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Text(
                                      '$varmemberprice '+_currencyFormat ,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.0)),
                                  Text('/$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                                ],
                              ),

                            ],
                          )
                          /* new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmemberprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat + '$varmrp ',
                                  style: TextStyle(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*/
                              : discountDisplay
                              ?
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text( '$varmrp '+_currencyFormat ,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: 12.0)),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Text(
                                      '$varprice '+_currencyFormat ,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.0)),
                                  Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                                ],
                              ),

                            ],
                          )
                          /*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: TextStyle(
                                      decoration: TextDecoration
                                          .lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*/
                              :  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /* Text( _currencyFormat + '$varmrp ',
                                style: TextStyle(
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),*/
                              Row(
                                children: [
                                  Text(
                                      '$varmrp '+_currencyFormat ,
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 16.0)),
                                  Text('/$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                                ],
                              ),

                            ],
                          )/*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                            ],
                          ),
                        )*/
                        ],
                      )
                          : discountDisplay
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$varmrp '+_currencyFormat ,
                              style: TextStyle(
                                  color: Colors.grey,
                                  decoration:
                                  TextDecoration.lineThrough,
                                  fontSize: 12.0)),
                          SizedBox(height: 5,),
                          Row(
                            children: [
                              Text(
                                  '$varprice '+_currencyFormat ,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16.0)),
                              Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                            ],
                          ),

                        ],
                      )/*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varprice ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: TextStyle(
                                  decoration:
                                  TextDecoration.lineThrough,
                                  fontSize: 12.0)),
                        ],
                      ),
                    )*/
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*Text( _currencyFormat + '$varmrp ',
                            style: TextStyle(
                                decoration:
                                TextDecoration.lineThrough,
                                fontSize: 12.0)),*/
                          SizedBox(height:17),
                          Row(
                            children: [
                              Text('$varmrp '+_currencyFormat ,
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16.0)),
                              Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                            ],
                          ),

                        ],
                      ), /*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                        ],
                      ),
                    ),*/
                      // Spacer(),
                      SizedBox(height: 20,),
                      // if(double.parse(varLoyalty.toString()) > 0)
                      //   Container(
                      //     child: Row(
                      //       children: [
                      //         Image.asset(Images.coinImg,
                      //         height: 15.0,
                      //         width: 20.0,),
                      //       SizedBox(width: 4),
                      //       Text(varLoyalty.toString()),
                      //     ],
                      //   ),
                      // ),
                      //  SizedBox(width: 10)
                    ],
                  ),
                  /*  SizedBox(
                  height: 8,
                ),*/
                  /*               _varlength
                    ? GestureDetector(
                  onTap: () {
                    showoptions();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color:  ColorCodes.lightgreen),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                              )),
                          height: 30,
                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "$varname",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 40,
                        decoration: BoxDecoration(
                            color:  ColorCodes.lightgreen,
                            borderRadius: new BorderRadius.only(
                              topRight: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorCodes.darkgreen,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                )
                    : Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(2.0),
                              topRight: const Radius.circular(2.0),
                              bottomLeft: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        height: 30,
                        padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                        child: Text(
                          "$varname",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*/
                  !discountDisplay?
                  SizedBox(
                    height: 8,
                  ):
                  SizedBox(
                    height: 8,
                  )
                  ,
                  _isStock
                      ? Container(
                    height: 30.0,
//                width: MediaQuery.of(context).size.width,
                    child: ValueListenableBuilder(
                      valueListenable:
                      Hive.box<Product>(productBoxName).listenable(),
                      builder: (context, Box<Product> box, _) {
                        if (box.values.length <= 0)
                          return GestureDetector(
                            onTap: () {
                              addToCart(int.parse(itemvarData[0].varminitem));
                            },
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Container(
                                    height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                    decoration: new BoxDecoration(
                                        color:  Theme.of(context).primaryColor,
                                        border: Border.all(color:  Theme.of(context).primaryColor),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(2.0),
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                          bottomRight:
                                          const Radius.circular(2.0),
                                        )),
                                    child: /*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*/
                                    Center(
                                      child: Text(
                                        translate('forconvience.ADD'),
                                        style: TextStyle(
                                            color: ColorCodes.whiteColor,
                                            fontSize: 12, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    /* Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:  ColorCodes.lightgreen,
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
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),*/
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          );

                        try {
                          Product item = Hive.box<Product>(productBoxName)
                              .values
                              .firstWhere(
                                  (value) => value.varId == int.parse(varid));
                          return Container(
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    if (item.itemQty ==
                                        int.parse(varminitem)) {
                                      for (int i = 0;
                                      i < productBox.values.length;
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
                                        incrementToCart(item.itemQty - 1);
                                      });
                                    }
                                  },
                                  child: Container(
                                      width: 40,
                                      height: 30,
                                      decoration: new BoxDecoration(
                                          border: Border.all(color:  Theme.of(context).primaryColor),
                                          color:   Theme.of(context).primaryColor,
                                          borderRadius: new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(2.0),
                                            bottomLeft:
                                            const Radius.circular(2.0),
                                          )),
                                      child:Center(
                                        child: Text(
                                          "-",
                                          textAlign:
                                          TextAlign
                                              .center,
                                          style:
                                          TextStyle(
                                            fontSize: 20,
                                            color: ColorCodes.whiteColor,
                                          ),
                                        ),
                                      )),
                                ),
                                // Spacer(),


                                Container(
//                                width: 40,
                                    width: 65,
                                    height: 30,
                                    decoration: new BoxDecoration(
                                        border: Border.all(color:  Theme.of(context).primaryColor),
                                        //color:  ColorCodes.lightgreen,
                                        borderRadius: new BorderRadius.only(
                                          topLeft:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                        )),
                                    child: Center(
                                      child: Text(
                                        item.itemQty.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color:  ColorCodes.darkgreen,
                                        ),
                                      ),
                                    )),


                                //Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    if (item.itemQty < int.parse(varstock)) {
                                      if (item.itemQty <
                                          int.parse(varmaxitem)) {
                                        incrementToCart(item.itemQty + 1);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                            translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                            backgroundColor: Colors.black87,
                                            textColor: Colors.white);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Sorry, Out of Stock!",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    }
                                  },
                                  child: Container(
                                      width: 40,
                                      height: 30,
                                      decoration: new BoxDecoration(
                                          color:  Theme.of(context).primaryColor,
                                          border: Border.all(color:  Theme.of(context).primaryColor),
                                          borderRadius: new BorderRadius.only(
                                            topRight:
                                            const Radius.circular(2.0),
                                            bottomRight:
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
                                            fontSize: 20,
                                            color: ColorCodes.whiteColor,
                                          ),
                                        ),
                                      )),
                                ),
                                SizedBox(width: 10),
                              ],
                            ),
                          );
                        } catch (e) {
                          return GestureDetector(
                            onTap: () {
                              addToCart(int.parse(itemvarData[0].varminitem));
                            },
                            child: Row(
                              children: [
                                SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                    decoration: new BoxDecoration(
                                        color:   Theme.of(context).primaryColor,
                                        border: Border.all(color:  Theme.of(context).primaryColor),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(2.0),
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                          bottomRight:
                                          const Radius.circular(2.0),
                                        )),
                                    child: /*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*/
                                    Center(
                                      child: Text(
                                        translate('forconvience.ADD'),
                                        style: TextStyle(
                                            color: ColorCodes.whiteColor,
                                            fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    /*  Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: ColorCodes.lightgreen,
                                            borderRadius:
                                            new BorderRadius.only(
                                              topRight:
                                              const Radius.circular(
                                                  2.0),
                                              bottomRight:
                                              const Radius.circular(
                                                  2.0),
                                            )),
                                        height: 30,
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),
                                    ],
                                  ),*/
                                  ),
                                ),
                                SizedBox(width: 10),
                              ],
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
                          translate('forconvience.Out of stock popup'),  //"Out Of Stock",
                          fontSize: 12.0,
                          backgroundColor: Colors.black87,
                          textColor: Colors.white);
                    },
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Container(
                            height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                            decoration: new BoxDecoration(
                                color: Colors.grey,
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(2.0),
                                  topRight: const Radius.circular(2.0),
                                  bottomLeft: const Radius.circular(2.0),
                                  bottomRight: const Radius.circular(2.0),
                                )),
                            child: /*Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),*/
                            Center(
                              child: Text(
                                translate('forconvience.ADD'),
                                style: TextStyle(
                                    color: ColorCodes.whiteColor,
                                    fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            /*  Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: new BorderRadius.only(
                                      topRight: const Radius.circular(2.0),
                                      bottomRight:
                                      const Radius.circular(2.0),
                                    )),
                                height: 30,
                                width: 40,
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: ColorCodes.darkgreen,
                                ),
                              ),
                            ],
                          ),*/
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  // Spacer(),
                  // SizedBox(height: 10,),
                  /* Row(
                  children: <Widget>[
                    !_checkmembership
                        ? membershipdisplay
                        ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );
                      },
                      child: Container(
                        height: 25,
                        width: 185,
                        decoration:
                        BoxDecoration(color: Color(0xffefef47)),
                        child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 10),
                            Image.asset(
                              Images.starImg,
                              width: 10,
                              height: 11,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(width: 2),
                            Text(
                                "Membership Price " +
                                    _currencyFormat +
                                    varmemberprice,
                                style: TextStyle(fontSize: 10.0)),
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
                  /* !_checkmembership
                    ? membershipdisplay
                    ? SizedBox(
                  height: 10,
                )*/
                  /*   : SizedBox(
                  height: 1,
                )
                    :*/ /*SizedBox(
                  height: 1,
                )*/
                ],
              ),
            ),
          ),
        );
    }
  }
}




//mobile......
/*import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/ColorCodes.dart';
import '../data/calculations.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../widgets/badge_discount.dart';

import '../providers/branditems.dart';
import '../providers/itemslist.dart';
import '../providers/sellingitems.dart';
import '../screens/singleproduct_screen.dart';
import '../screens/membership_screen.dart';
import '../widgets/badge_ofstock.dart';
import '../data/hiveDB.dart';
import '../constants/images.dart';
import 'package:flutter_translate/flutter_translate.dart';

class Items extends StatefulWidget {
  final String _fromScreen;
  final String id;
  final String title;
  final String imageUrl;
  final String brand;

  Items(this._fromScreen, this.id, this.title, this.imageUrl, this.brand);

  @override
  _ItemsState createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  Box<Product> productBox;

  bool _varlength = false;
  int varlength = 0;
  var itemvarData;
  bool dialogdisplay = false;
  bool bottomsheetdisplay = false;
  var _currencyFormat = "";
  bool membershipdisplay = true;
  bool _checkmembership = false;
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
  bool discountDisplay;
  bool memberpriceDisplay;
  var margins;
  int _groupValue;

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
  var iconcolor = [];
  var textcolor = [];

  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
        dialogdisplay = true;
      });
    });
    super.initState();
  }

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }

  Widget showoptions() {
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

    incrementToCart(int _itemCount) async {
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

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return  Container(
              //height: 320,
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
                          onTap: ()=> Navigator.pop(context),
                          child: Image(
                            height: 40,
                            width: 40,
                            image: AssetImage(Images.bottomsheetcancelImg),color: Colors.black,)),
                    ],
                  ),

                  Text(
                    'Please select any one option',
                    style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),

                  //Text(
                  //'Size',
                  //style: TextStyle(color: Theme.of(context).primaryColor,
                  // fontSize: 18, fontWeight: FontWeight.bold),
                  //),

                  SizedBox(
                    height: 20,
                  ),
                  SingleChildScrollView(
                    child:  ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: variationdisplaydata.length,
                        itemBuilder: (_, i) {
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                varid = itemvarData[i].varid;
                                varname = itemvarData[i].varname;
                                varmrp = itemvarData[i].varmrp;
                                varprice = itemvarData[i].varprice;
                                varmemberprice =
                                    itemvarData[i].varmemberprice;
                                varminitem = itemvarData[i].varminitem;
                                varmaxitem = itemvarData[i].varmaxitem;
                                varLoyalty = itemvarData[i].varLoyaltydata;
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
                                    var difference =
                                    (double.parse(varmrp) -
                                        double.parse(varmemberprice));
                                    var profit =
                                        difference / double.parse(varmrp);
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
                                    var profit =
                                        difference / double.parse(varmrp);
                                    margins = profit * 100;

                                    //discount price rounding
                                    margins = num.parse(
                                        margins.toStringAsFixed(0));
                                    margins = margins.toString();
                                  }
                                }
                                Future.delayed(Duration(seconds: 0), () {
                                  dialogdisplay = true;
                                  for (int j = 0;
                                  j < variddata.length;
                                  j++) {
                                    if (i == j) {
                                      checkBoxdata[i] = true;
                                      containercolor[i] = 0xFFFFFFFF;
                                      textcolor[i] = 0xFF2966A2;
                                      iconcolor[i] = 0xFF2966A2;
                                    } else {
                                      checkBoxdata[j] = false;
                                      containercolor[i] = 0xFFFFFFFF;
                                      iconcolor[j] = 0xFFC1C1C1;
                                      textcolor[j] = 0xFF060606;
                                    }
                                  }
                                });
                                // Navigator.of(context).pop(true);
                              });
                            },
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.only(right: 10),
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
                                        color: itemvarData[i]
                                            .varcolor,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: varnamedata[i] +
                                              " - ",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(
                                                  textcolor[i]),
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        TextSpan(
                                          text:
                                              varmemberpricedata[
                                              i] +
                                              " "+_currencyFormat ,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(
                                                  textcolor[i]),
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        TextSpan(
                                            text:

                                                varmrpdata[
                                                i]+ _currencyFormat ,
                                            style: TextStyle(
                                              color: Color(
                                                  textcolor[i]),
                                              decoration:
                                              TextDecoration
                                                  .lineThrough,
                                            )),
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
                                          text:
                                              varpricedata[
                                              i] +
                                              " "+ _currencyFormat ,
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
                                            text:
                                                varmrpdata[
                                                i]+ _currencyFormat ,
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
                                          text:

                                              " " +
                                              varmrpdata[
                                              i]+ _currencyFormat ,
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
                                  )
                                      : itemvarData[i].discountDisplay
                                      ? RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: itemvarData[i]
                                            .varcolor,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: varnamedata[i] +
                                              " - ",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(
                                                  textcolor[i]),
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        TextSpan(
                                          text:
                                              varpricedata[
                                              i] +
                                              " "+ _currencyFormat ,
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Color(
                                                  textcolor[i]),
                                              fontWeight:
                                              FontWeight
                                                  .bold),
                                        ),
                                        TextSpan(
                                            text:

                                                varmrpdata[
                                                i]+ _currencyFormat ,
                                            style: TextStyle(
                                              color: Color(
                                                  textcolor[i]),
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
                                        color: itemvarData[i]
                                            .varcolor,
                                      ),
                                      children: <TextSpan>[
                                        new TextSpan(
                                          text: varnamedata[i] +
                                              " - ",
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Color(
                                                textcolor[i]),
                                          ),
                                        ),
                                        new TextSpan(
                                          text:

                                              " " +
                                              varmrpdata[i]+ _currencyFormat ,
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Color(
                                                textcolor[i]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                      Icons.radio_button_checked_outlined,
                                      color: Color(iconcolor[i])),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  // ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 40.0,
                        width: (MediaQuery.of(context).size.width / 3) + 18,
                        child: ValueListenableBuilder(
                          valueListenable: Hive.box<Product>(productBoxName)
                              .listenable(),
                          builder: (context, Box<Product> box, _) {
                            if (box.values.length <= 0)
                              return GestureDetector(
                                onTap: () {
                                  addToCart(
                                      int.parse(itemvarData[0].varminitem));
                                },
                                child: Container(
                                  height: 40.0,
                                  width:
                                  (MediaQuery.of(context).size.width / 3) + 18,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: *//*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*//*
                                      Center(
                                          child: Text(
                                            translate('forconvience.ADD'),
                                            style: TextStyle(
                                              color:
                                              Theme.of(context).buttonColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                     // Spacer(),
                                      *//*Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius:
                                          new BorderRadius.only(
                                            bottomRight:
                                            const Radius.circular(3),
                                            topRight:
                                            const Radius.circular(3),
                                          ),
                                        ),
                                        height: 40,
                                        width: 30,
                                        *//**//*child: Icon(
                                          Icons.add,
                                          size: 14,
                                          color: Colors.white,
                                        ),*//**//*
                                      ),*//*
                                    *//*],
                                  ),*//*

                                ),
                              );

                            try {
                              Product item =
                              Hive.box<Product>(productBoxName)
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
                                          i < productBox.values.length;
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
                                              color: Theme.of(context).primaryColor,
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor,
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
                                              textAlign: TextAlign.center,
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
                                            color: Theme.of(context).primaryColor,
                                          ),
                                          height: 40,
                                          width: 30,
                                          child: Center(
                                            child: Text(
                                              item.itemQty.toString(),
                                              textAlign: TextAlign.center,
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
                                          if (item.itemQty < int.parse(varmaxitem)) {
                                            incrementToCart(item.itemQty + 1);
                                          } else {
                                            Fluttertoast.showToast(
                                                msg:
                                                translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                                backgroundColor:
                                                Colors.black87,
                                                textColor: Colors.white);
                                          }
                                        } else {
                                          Fluttertoast.showToast(msg: "Sorry, Out of Stock!", backgroundColor: Colors.black87, textColor: Colors.white);
                                        }
                                      },
                                      child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: new BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor,
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
                                              textAlign: TextAlign.center,
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
                                  addToCart(
                                      int.parse(itemvarData[0].varminitem));
                                },
                                child: Container(
                                  height: 40.0,
                                  width:
                                  (MediaQuery.of(context).size.width /
                                      4) +
                                      15,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(3),
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
                                              color:
                                              Theme.of(context).buttonColor,
                                            ),
                                            textAlign: TextAlign.center,
                                          )),
                                      Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
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
                      SizedBox(width: 20,)
                    ],
                  ),
                  SizedBox(width: 20)
                ],
              ),
            );
            //);
          });
        })
        .then((_) => setState(() {
      variddata.clear();
      variationdisplaydata.clear();
    }));

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
    } else if (widget._fromScreen == "singleproduct_screen") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIdnew(widget.id);
    } else if (widget._fromScreen == "Discount") {
      itemvarData = null;
      itemvarData = Provider.of<SellingItemsList>(
        context,
        listen: false,
      ).findByIddiscount(widget.id);
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
      iconcolor = [];

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
      textcolor = [];
      iconcolor = [];

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
      }
    }

    if (varlength <= 0) {
    } else {
      if (!dialogdisplay) {
        varid = itemvarData[0].varid;
        varcolor = itemvarData[0].varcolor;
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

    incrementToCart(int _itemCount) async {
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

    return
      Expanded(
        child: Container(
          width: 180.0,
          height: MediaQuery.of(context).size.height*0.50,//aaaaaaaaaaaaaaaaaa
          child: Container(
            margin: EdgeInsets.only(left: 10.0, top: 5.0, right: 2.0, bottom: 5.0),
            decoration: new BoxDecoration(
                color: Colors.white,
                border: Border.all(color: ColorCodes.borderColor),
                borderRadius: new BorderRadius.only(
                  topRight: const Radius.circular(4.0),
                  topLeft: const Radius.circular(4.0),
                  bottomLeft: const Radius.circular(4.0),
                  bottomRight: const Radius.circular(4.0),
                )),
            child:  Column(
             // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _checkmargin
                    ?
                Consumer<Calculations>(
                    builder: (_, cart, ch) => Align(
                      alignment: Alignment.topLeft,
                      child: BadgeDiscount(
                        child: ch,
                        value: margins,
                      ),
                    ),
                    child: !_isStock
                        ? Column(
                          children: [
                            SizedBox(height:50),
                            Align(
                              alignment: Alignment.center,
                              child: Consumer<Calculations>(
                      builder: (_, cart, ch) => BadgeOfStock(
                              child: ch,
                              value: margins,
                              singleproduct: false,
                              item: true,
                      ),
                      child: Align(
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
                                  //margin: EdgeInsets.only(top: 40.0,bottom: 10),
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
                    ),
                            ),
                          ],
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
                          margin: EdgeInsets.only(top: 40.0,bottom: 12),
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            placeholder: (context, url) => Image.asset(
                              Images.defaultProductImg,
                              width: 100,
                              height: 80,
                            ),
                            width:100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ))
                    : !_isStock
                    ?
                Column(
                  children: [
                    SizedBox(height:37),
                    Align(

                      alignment: Alignment.center,
                          child: Consumer<Calculations>(

                      builder: (_, cart, ch) => BadgeOfStock(
                          child: ch,
                          value: margins,
                          singleproduct: false,
                        item: true,

                      ),
                      child: Align(
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
                              //margin: EdgeInsets.only(top: 40.0,bottom: 10),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrl,
                                placeholder: (context, url) => Image.asset(
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
                    ),
                        ),
                    SizedBox(height:10),
                  ],
                )
                    : Column(
                      children: [
                        SizedBox(height: 34,),
                        Align(
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
                          margin: EdgeInsets.only(top: 10.0, bottom: 8.0),
                          child: CachedNetworkImage(
                            imageUrl: widget.imageUrl,
                            placeholder: (context, url) => Image.asset(
                              Images.defaultProductImg,
                              width: 100,
                              height:80,
                            ),
                            width: 100,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                  ),
                ),
                      ],
                    ),
                SizedBox(
                  height: 8,
                ),
               *//* Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Text(
                        widget.brand,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*//*
                Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    !_isStock && !discountDisplay?

                    SizedBox(height:23)
                        :
                    SizedBox.shrink(),
                    Expanded(
                      child: Text(
                        widget.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),
               *//* Spacer(),*//*
                discountDisplay?
                SizedBox(height: 8,):
                SizedBox(height: 10,),
               // SizedBox(height: 20,),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10.0,
                    ),
                    _checkmembership
                        ? Row(
                      children: <Widget>[
                        Container(
                          width: 12.0,
                          height: 11.0,
                          child: Image.asset(
                            Images.starImg,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        memberpriceDisplay
                            ?Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if(varmemberprice.toString() == varmrp.toString())
                            Text( '$varmrp '+_currencyFormat ,
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Text(
                                    '$varmemberprice '+_currencyFormat ,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text('/$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                              ],
                            ),

                          ],
                        )
                        *//* new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
//                            if(varmemberprice.toString() == varmrp.toString())
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmemberprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat + '$varmrp ',
                                  style: TextStyle(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*//*
                            : discountDisplay
                            ?
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( '$varmrp '+_currencyFormat ,
                                style: TextStyle(
                                    color: Colors.grey,
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),
                            SizedBox(height: 5,),
                            Row(
                              children: [
                                Text(
                                    '$varprice '+_currencyFormat ,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                              ],
                            ),

                          ],
                        )
                          *//*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varprice ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,

                                      fontSize: 14.0)),
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: TextStyle(
                                      decoration: TextDecoration
                                          .lineThrough,
                                      fontSize: 12.0)),
                            ],
                          ),
                        )*//*
                            :  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           *//* Text( _currencyFormat + '$varmrp ',
                                style: TextStyle(
                                    decoration:
                                    TextDecoration.lineThrough,
                                    fontSize: 12.0)),*//*
                            Row(
                              children: [
                                Text(
                                    '$varmrp '+_currencyFormat ,
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 16.0)),
                                Text('/$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                              ],
                            ),

                          ],
                        )*//*new RichText(
                          text: new TextSpan(
                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: _currencyFormat +
                                      '$varmrp ',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14.0)),
                            ],
                          ),
                        )*//*
                      ],
                    )
                        : discountDisplay
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$varmrp '+_currencyFormat ,
                            style: TextStyle(
                              color: Colors.grey,
                                decoration:
                                TextDecoration.lineThrough,
                                fontSize: 12.0)),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text(
                                '$varprice '+_currencyFormat ,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0)),
                            Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                          ],
                        ),

                      ],
                    )*//*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varprice ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: TextStyle(
                                  decoration:
                                  TextDecoration.lineThrough,
                                  fontSize: 12.0)),
                        ],
                      ),
                    )*//*
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        *//*Text( _currencyFormat + '$varmrp ',
                            style: TextStyle(
                                decoration:
                                TextDecoration.lineThrough,
                                fontSize: 12.0)),*//*
                        SizedBox(height:17),
                        Row(
                          children: [
                            Text('$varmrp '+_currencyFormat ,
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16.0)),
                            Text(' /$varname',style: TextStyle(color: ColorCodes.varcolor,fontSize: 16),),
                          ],
                        ),

                      ],
                    ), *//*new RichText(
                      text: new TextSpan(
                        style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                        ),
                        children: <TextSpan>[
                          new TextSpan(
                              text: _currencyFormat + '$varmrp ',
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14.0)),
                        ],
                      ),
                    ),*//*
                   // Spacer(),
                    SizedBox(height: 20,),
                    // if(double.parse(varLoyalty.toString()) > 0)
                    //   Container(
                    //     child: Row(
                    //       children: [
                    //         Image.asset(Images.coinImg,
                    //         height: 15.0,
                    //         width: 20.0,),
                    //       SizedBox(width: 4),
                    //       Text(varLoyalty.toString()),
                    //     ],
                    //   ),
                    // ),
                  //  SizedBox(width: 10)
                  ],
                ),
              *//*  SizedBox(
                  height: 8,
                ),*//*
 *//*               _varlength
                    ? GestureDetector(
                  onTap: () {
                    showoptions();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10.0,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color:  ColorCodes.lightgreen),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                              )),
                          height: 30,
                          padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                          child: Text(
                            "$varname",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 40,
                        decoration: BoxDecoration(
                            color:  ColorCodes.lightgreen,
                            borderRadius: new BorderRadius.only(
                              topRight: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: ColorCodes.darkgreen,
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                    ],
                  ),
                )
                    : Row(
                  children: [
                    SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.only(
                              topLeft: const Radius.circular(2.0),
                              topRight: const Radius.circular(2.0),
                              bottomLeft: const Radius.circular(2.0),
                              bottomRight: const Radius.circular(2.0),
                            )),
                        height: 30,
                        padding: EdgeInsets.fromLTRB(5.0, 4.5, 0.0, 4.5),
                        child: Text(
                          "$varname",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                  ],
                ),*//*
                !discountDisplay?
                SizedBox(
                  height: 8,
                ):
                SizedBox(
                  height: 8,
                )
                ,
                _isStock
                    ? Container(
                  height: 30.0,
//                width: MediaQuery.of(context).size.width,
                  child: ValueListenableBuilder(
                    valueListenable:
                    Hive.box<Product>(productBoxName).listenable(),
                    builder: (context, Box<Product> box, _) {
                      if (box.values.length <= 0)
                        return GestureDetector(
                          onTap: () {
                            addToCart(int.parse(itemvarData[0].varminitem));
                          },
                          child: Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Container(
                                  height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                  decoration: new BoxDecoration(
                                      color:  Theme.of(context).primaryColor,
                                      border: Border.all(color:  Theme.of(context).primaryColor),
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight:
                                        const Radius.circular(2.0),
                                        bottomLeft:
                                        const Radius.circular(2.0),
                                        bottomRight:
                                        const Radius.circular(2.0),
                                      )),
                                  child: *//*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*//*
                                      Center(
                                        child: Text(
                                          translate('forconvience.ADD'),
                                          style: TextStyle(
                                              color: ColorCodes.whiteColor,
                                              fontSize: 12, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                     *//* Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color:  ColorCodes.lightgreen,
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
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),*//*
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        );

                      try {
                        Product item = Hive.box<Product>(productBoxName)
                            .values
                            .firstWhere(
                                (value) => value.varId == int.parse(varid));
                        return Container(
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () async {
                                  if (item.itemQty ==
                                      int.parse(varminitem)) {
                                    for (int i = 0;
                                    i < productBox.values.length;
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
                                      incrementToCart(item.itemQty - 1);
                                    });
                                  }
                                },
                                child: Container(
                                    width: 40,
                                    height: 30,
                                    decoration: new BoxDecoration(
                                        border: Border.all(color:  Theme.of(context).primaryColor),
                                        color:   Theme.of(context).primaryColor,
                                        borderRadius: new BorderRadius.only(
                                          topLeft:
                                          const Radius.circular(2.0),
                                          bottomLeft:
                                          const Radius.circular(2.0),
                                        )),
                                    child:Center(
                                      child: Text(
                                        "-",
                                        textAlign:
                                        TextAlign
                                            .center,
                                        style:
                                        TextStyle(
                                          fontSize: 20,
                                          color: ColorCodes.whiteColor,
                                        ),
                                      ),
                                    )),
                              ),
                              // Spacer(),


                              Container(
//                                width: 40,
                                  width: 65,
                                  height: 30,
                                  decoration: new BoxDecoration(
                                      border: Border.all(color:  Theme.of(context).primaryColor),
                                      //color:  ColorCodes.lightgreen,
                                      borderRadius: new BorderRadius.only(
                                        topLeft:
                                        const Radius.circular(2.0),
                                        bottomLeft:
                                        const Radius.circular(2.0),
                                      )),
                                  child: Center(
                                    child: Text(
                                      item.itemQty.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color:  ColorCodes.darkgreen,
                                      ),
                                    ),
                                  )),


                              //Spacer(),
                              GestureDetector(
                                onTap: () {
                                  if (item.itemQty < int.parse(varstock)) {
                                    if (item.itemQty <
                                        int.parse(varmaxitem)) {
                                      incrementToCart(item.itemQty + 1);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                          translate('forconvience.no more item') ,//"Sorry, you can\'t add more of this item!",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Sorry, Out of Stock!",
                                        backgroundColor: Colors.black87,
                                        textColor: Colors.white);
                                  }
                                },
                                child: Container(
                                    width: 40,
                                    height: 30,
                                    decoration: new BoxDecoration(
                                        color:  Theme.of(context).primaryColor,
                                        border: Border.all(color:  Theme.of(context).primaryColor),
                                        borderRadius: new BorderRadius.only(
                                          topRight:
                                          const Radius.circular(2.0),
                                          bottomRight:
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
                                          fontSize: 20,
                                          color: ColorCodes.whiteColor,
                                        ),
                                      ),
                                    )),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        );
                      } catch (e) {
                        return GestureDetector(
                          onTap: () {
                            addToCart(int.parse(itemvarData[0].varminitem));
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                                  decoration: new BoxDecoration(
                                      color:   Theme.of(context).primaryColor,
                                      border: Border.all(color:  Theme.of(context).primaryColor),
                                      borderRadius: new BorderRadius.only(
                                        topLeft: const Radius.circular(2.0),
                                        topRight:
                                        const Radius.circular(2.0),
                                        bottomLeft:
                                        const Radius.circular(2.0),
                                        bottomRight:
                                        const Radius.circular(2.0),
                                      )),
                                  child: *//*Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),*//*
                                      Center(
                                        child: Text(
                                          translate('forconvience.ADD'),
                                          style: TextStyle(
                                              color: ColorCodes.whiteColor,
                                              fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    *//*  Spacer(),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: ColorCodes.lightgreen,
                                            borderRadius:
                                            new BorderRadius.only(
                                              topRight:
                                              const Radius.circular(
                                                  2.0),
                                              bottomRight:
                                              const Radius.circular(
                                                  2.0),
                                            )),
                                        height: 30,
                                        width: 40,
                                        child: Icon(
                                          Icons.add,
                                          size: 20,
                                          color: ColorCodes.darkgreen,
                                        ),
                                      ),
                                    ],
                                  ),*//*
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: *//*"You will be notified via SMS/Push notification, when the product is available"*//*
                        translate('forconvience.Out of stock popup'),  //"Out Of Stock",
                        fontSize: 12.0,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white);
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 30.0,
//                      width: MediaQuery.of(context).size.width,

                          decoration: new BoxDecoration(
                              color: Colors.grey,
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(2.0),
                                topRight: const Radius.circular(2.0),
                                bottomLeft: const Radius.circular(2.0),
                                bottomRight: const Radius.circular(2.0),
                              )),
                          child: *//*Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),*//*
                              Center(
                                child: Text(
                                  translate('forconvience.ADD'),
                                  style: TextStyle(
                                      color: ColorCodes.whiteColor,
                                      fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            *//*  Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: new BorderRadius.only(
                                      topRight: const Radius.circular(2.0),
                                      bottomRight:
                                      const Radius.circular(2.0),
                                    )),
                                height: 30,
                                width: 40,
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: ColorCodes.darkgreen,
                                ),
                              ),
                            ],
                          ),*//*
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5),
                // Spacer(),
               // SizedBox(height: 10,),
               *//* Row(
                  children: <Widget>[
                    !_checkmembership
                        ? membershipdisplay
                        ? GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          MembershipScreen.routeName,
                        );
                      },
                      child: Container(
                        height: 25,
                        width: 185,
                        decoration:
                        BoxDecoration(color: Color(0xffefef47)),
                        child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 10),
                            Image.asset(
                              Images.starImg,
                              width: 10,
                              height: 11,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(width: 2),
                            Text(
                                "Membership Price " +
                                    _currencyFormat +
                                    varmemberprice,
                                style: TextStyle(fontSize: 10.0)),
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
                ),*//*
               *//* !_checkmembership
                    ? membershipdisplay
                    ? SizedBox(
                  height: 10,
                )*//*
                 *//*   : SizedBox(
                  height: 1,
                )
                    :*//* *//*SizedBox(
                  height: 1,
                )*//*
              ],
            ),
          ),
        ),
      );
  }
}*/


