import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/hiveDB.dart';
import '../main.dart';
import '../constants/images.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';

class CartitemsDisplay extends StatefulWidget {
  final String id;
  final String varid;
  final String title;
  final String imageUrl;
  final String varname;
  final String varprice;
  int itemcount;
  final String varminitem;
  final String varmaxitem;
  final String varstock;
  final String varmrp;
  final String varmemberprice;
  final int mode;

  CartitemsDisplay(
    this.id,
    this.varid,
    this.title,
    this.imageUrl,
    this.varname,
    this.varprice,
    this.itemcount,
    this.varminitem,
    this.varmaxitem,
    this.varstock,
    this.varmrp,
    this.varmemberprice,
    this.mode,
  );

  @override
  _CartitemsDisplayState createState() => _CartitemsDisplayState();
}

class _CartitemsDisplayState extends State<CartitemsDisplay> {
  Box<Product> productBox;

  var _currencyFormat = "";
  var checkmembership = false;
  String _itemPrice = "";
  bool _checkMembership = false;
  SharedPreferences prefs;
  bool _isLoading = true;
  var margins;
  bool _checkmargin = true;

  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    debugPrint("var stock itemcount"+widget.itemcount.toString());
    debugPrint("var stock i"+widget.varstock.toString());
    debugPrint("item name"+widget.title);
    /*List<String> numbers =[];//widget.title.toString();//[]; //['one', 'two', 'three', 'four'];
    numbers.add(widget.title.toString());
    numbers.sort();
    print(numbers);
    List<String> sortstring =[];
    for(int i=0;i<numbers.length;i++){

      sortstring.add(numbers[i]);
      print("sort list"+sortstring.toString());
    }
    sortstring.sort();
    print("sort list"+sortstring.toString());
    final List<String> fruits = <String>[widget.title];
    fruits.sort();
    print(fruits);*/
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == 1) {
      checkmembership = true;
    } else {
      checkmembership = false;
    }

    if (!_isLoading) if (prefs.getString("membership") == "1") {
      _checkMembership = true;
    } else {
      _checkMembership = false;
    }

    incrementToCart(itemCount) async {
      Product products = Product(
          itemId: int.parse(widget.id),
          varId: int.parse(widget.varid),
          varName: widget.varname,
          varMinItem: int.parse(widget.varminitem),
          varMaxItem: int.parse(widget.varmaxitem),
          varStock: int.parse(widget.varstock),
          varMrp: double.parse(widget.varmrp),
          itemName: widget.title,
          itemQty: itemCount,
          itemPrice: double.parse(widget.varprice),
          membershipPrice: widget.varmemberprice,
          itemActualprice: double.parse(widget.varmrp),
          itemImage: widget.imageUrl,
          membershipId: 0,
          mode: 0);

      var items = Hive.box<Product>(productBoxName);

      for (int i = 0; i < items.length; i++) {
        if (Hive.box<Product>(productBoxName).values.elementAt(i).varId ==
            int.parse(widget.varid)) {
          Hive.box<Product>(productBoxName).putAt(i, products);
        }
      }
    }

    /*deleteFromCart() async {
      if(widget.mode == 1) {
        prefs.setString("membership", "0");
      }
      await DBProvider.db.deleteItem(int.parse(widget.id), int.parse(widget.varid));
      var membershipitem = await DBProvider.db.checkmembershipItem(1);
      if (membershipitem == Null) {
        final membershipData = Provider.of<MembershipitemsList>(context, listen: false);
        for(int i = 0; i < membershipData.typesitems.length; i++) {
          membershipData.typesitems[i].text = "Select";
          membershipData.typesitems[i].backgroundcolor = Theme.of(context).accentColor;
          membershipData.typesitems[i].textcolor = Theme.of(context).buttonColor;
        }
      }
    }*/
    if (_checkMembership) {
      if (widget.varmemberprice.toString() == '-' ||
          double.parse(widget.varmemberprice) <= 0) {
        if (double.parse(widget.varprice) <= 0 || double.parse(widget.varprice) <= 0) {
          margins = "0";
        } else {
          var difference = (double.parse(widget.varmrp) - double.parse(widget.varprice));
          var profit = difference / double.parse(widget.varmrp);
          margins = profit * 100;

          //discount price rounding
          margins = num.parse(margins.toStringAsFixed(0));
          margins = margins.toString();
        }
      } else {
        var difference =
        (double.parse(widget.varmrp) - double.parse(widget.varmemberprice));
        var profit = difference / double.parse(widget.varmrp);
        margins = profit * 100;

        //discount price rounding
        margins = num.parse(margins.toStringAsFixed(0));
        margins = margins.toString();
      }
    } else {
      if (double.parse(widget.varmrp) <= 0 || double.parse(widget.varprice) <= 0) {
        margins = "0";
      } else {
        var difference = (double.parse(widget.varmrp) - double.parse(widget.varprice));
        var profit = difference / double.parse(widget.varmrp);
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
    if (_checkMembership) {
      if (widget.varmemberprice == '-' || widget.varmemberprice == "0") {
        if (double.parse(widget.varprice) <= 0 ||
            widget.varprice.toString() == "") {
          _itemPrice = widget.varmrp;
        } else {
          _itemPrice = widget.varprice;
        }
      } else {
        _itemPrice = widget.varmemberprice;
      }
    } else {
      if (double.parse(widget.varprice) <= 0 ||
          widget.varprice.toString() == "") {
        _itemPrice = widget.varmrp;
      } else {
        _itemPrice = widget.varprice;
      }
    }
debugPrint("Widget mrp"+widget.varmrp.toString());
    return Stack(

      children: [

       Container(
        margin: EdgeInsets.only(bottom:5 ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ColorCodes.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8),
          child: Row(
            children: <Widget>[

              checkmembership
                  ? Image.asset(
                      Images.membershipImg,
                      width: 100,
                      height: 80,
                      color: Theme.of(context).primaryColor,
                    )
                  : FadeInImage(
                      image: NetworkImage(widget.imageUrl),
                      placeholder: AssetImage(
                        Images.defaultProductImg,
                      ),
                      width: 100,
                      height: 80,
                  fit: BoxFit.cover
                    ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical:8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),

                              /*IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.grey,
                            onPressed: () {
                              for (int i = 0; i < productBox.values.length; i++) {
                                if (productBox.values.elementAt(i).varId ==
                                    int.parse(widget.varid)) {
                                  productBox.deleteAt(i);
                                  break;
                                }
                              }
                            },
                          ),*/
                              // SizedBox(
                              //   width: 120,
                              // )
                            ],
                          ),
                        ),
                    //SizedBox(height: 10,),
                        Row(
  //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //Text( (double.parse(_itemPrice)*(widget.itemcount)).toString()+ _currencyFormat,

                           // SizedBox(width: 5,),
                            if(_checkmargin)
                            Text(
                              double.parse(widget.varmrp).toStringAsFixed(2)+_currencyFormat,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
Spacer(),
                            /*if (_checkmargin)
                              Container(
                                  margin: EdgeInsets.only(left: 5.0),
                                  padding: EdgeInsets.all(3.0),
                                  // color: Theme.of(context).accentColor,
                                  decoration: BoxDecoration(
                                    borderRadius:BorderRadius.circular(3),
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
*/
                          ],
                        ),


                  /*  SizedBox(
                      height: 5,
                    ),*/

                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(double.parse(_itemPrice).toStringAsFixed(2)+ " "+_currencyFormat,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        Text(" /" +widget.varname,style: TextStyle(color:ColorCodes
                            .varcolor, fontSize: 16),),
                        Spacer(),

                        // SizedBox(
                        //   width: 5,
                        // ),
                        ValueListenableBuilder(
                          valueListenable:
                              Hive.box<Product>(productBoxName).listenable(),
                          builder: (context, Box<Product> box, _) {
                            Product item = Hive.box<Product>(productBoxName)
                                .values
                                .firstWhere((value) =>
                                    value.varId == int.parse(widget.varid));
                            return Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    if (item.itemQty == int.parse(widget.varminitem)) {
                                      for (int i = 0; i < productBox.values.length; i++) {
                                        if (productBox.values.elementAt(i).mode == 1) {
                                          prefs.setString("membership", "0");
                                        }
                                        if (productBox.values.elementAt(i).varId == int.parse(widget.varid)) {productBox.deleteAt(i);
                                          break;
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        widget.itemcount = widget.itemcount - 1;
                                        incrementToCart(item.itemQty - 1);
                                      });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1.0, color: Colors.green),
                                          bottom: BorderSide(
                                              width: 1.0, color: Colors.green),
                                          left: BorderSide(
                                              width: 1.0, color: Colors.green),
                                        ),
                                      ),
                                      width: 30,
                                      height: 25,
                                      child: Center(
                                        child: Text(
                                          "-",
                                          textAlign: TextAlign.center,
                                          style:
                                              TextStyle(color: Color(0xffffffff)),
                                        ),
                                      )),
                                ),
                                Container(
                                    width: 35,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            width: 1.0, color: Colors.green),
                                        bottom: BorderSide(
                                            width: 1.0, color: Colors.green),
                                        left: BorderSide(
                                            width: 1.0, color: Colors.green),
                                        right: BorderSide(
                                            width: 1.0, color: Colors.green),
                                      ),
                                    ),
                                    // decoration: BoxDecoration(color: Colors.green,border: Border.),
                                    child: Center(
                                      child: Text(
                                        item.itemQty.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.itemcount <
                                        int.parse(widget.varstock)) {
                                      if (widget.itemcount <
                                          int.parse(widget.varmaxitem)) {
                                        widget.itemcount = widget.itemcount + 1;
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
                                      width: 30,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        border: Border(
                                          top: BorderSide(
                                              width: 1.0, color: Colors.green),
                                          bottom: BorderSide(
                                              width: 1.0, color: Colors.green),
                                          right: BorderSide(
                                              width: 1.0, color: Colors.green),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "+",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Color(0xfffffffff)
                                              //color: Theme.of(context).buttonColor,
                                              ),
                                        ),
                                      )),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          width: 1,
                        )
                      ],
                    )

                    /* , Row(
                  children: <Widget>[
                    Container(width: MediaQuery.of(context).size.width*50/130,
                        child:Column(children:[
                          SizedBox(height: 10,),
                          Row(children:[
                            Expanded(
                                child: Text(
                                    widget.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 13,fontWeight: FontWeight.w400
                                )
                                )
                            )
                          ]
                          ),
                          Row(
                              children:[
                            Text(widget.varname,style: TextStyle(fontWeight: FontWeight.w300,fontSize: 11),)

                          ] )])
                    ),
                    SizedBox(
                        width: 2
                    ),
                    ValueListenableBuilder(
                      valueListenable: Hive.box<Product>(productBoxName).listenable(),
                      builder: (context, Box<Product> box, _) {
                        Product item = Hive.box<Product>(productBoxName)
                            .values
                            .firstWhere((value) => value.varId == int.parse(widget.varid));
                        return Row(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                if (item.itemQty == int.parse(widget.varminitem)){
                                  for(int i = 0; i < productBox.values.length; i++) {
                                    if(productBox.values.elementAt(i).varId == int.parse(widget.varid)) {
                                      productBox.deleteAt(i);
                                      break;
                                    }
                                  }
                                } else {
                                  setState(() {
                                    widget.itemcount = widget.itemcount - 1;
                                    incrementToCart(item.itemQty - 1);
                                  });
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).primaryColor),
                                      borderRadius: BorderRadius.circular(2)
                                  ),
                                  width: 22,
                                  height: 20,
                                  child: Center(
                                    child: Text(
                                      "-",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:Color(0xff808080)
                                      ),
                                    ),
                                  )
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Container(
                                width: 23,
                                height: 20,
                                child: Center(
                                  child: Text(
                                    item.itemQty.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            GestureDetector(
                              onTap: () {
                                if(widget.itemcount < int.parse(widget.varstock)) {
                                  if (widget.itemcount < int.parse(widget.varmaxitem)) {
                                    widget.itemcount = widget.itemcount + 1;
                                    incrementToCart(item.itemQty + 1);
                                  } else {
                                    Fluttertoast.showToast(msg: "Sorry, you can\'t add more of this item!", backgroundColor: Colors.black87, textColor: Colors.white);
                                  }
                                } else {
                                  Fluttertoast.showToast(msg: "Sorry, Out of Stock!", backgroundColor: Colors.black87, textColor: Colors.white);
                                }
                              },
                              child: Container(
                                  width: 22,
                                  height: 20,
                                  decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor),borderRadius:BorderRadius.circular(2)),
                                  color: Theme.of(context).accentColor,
                                  child: Center(
                                    child: Text(
                                      "+",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:Color(0xff808080)
                                        //color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: Text(_currencyFormat + " " + (double.parse(_itemPrice) * widget.itemcount).toStringAsFixed(2),
                          textAlign: TextAlign.end, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 13.0),
                      ),
                    ),
                  ],
                ),*/
                  ])),
            ],
          ),
        ),
      ),
       /* if (_checkmargin)
          Positioned(
            right: 1,
            top: 1,
            child:
            Container(
              margin: EdgeInsets.only(left: 5.0),
              padding: EdgeInsets.all(3.0),
              // color: Theme.of(context).accentColor,
              decoration: BoxDecoration(
                borderRadius:BorderRadius.circular(3),
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
          )*/
      ],
    );
  }
}
