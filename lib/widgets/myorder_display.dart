import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/ColorCodes.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/orderexample.dart';
import '../screens/example_screen.dart';
import '../screens/help_screen.dart';
import '../main.dart';
import 'package:http/http.dart' as http;

import '../providers/myorderitems.dart';
import '../providers/addressitems.dart';

import '../screens/orderhistory_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/return_screen.dart';
import '../screens/address_screen.dart';
import '../constants/IConstants.dart';
import '../screens/myorder_screen.dart';
import '../constants/images.dart';
import 'package:flutter_translate/flutter_translate.dart';

class MyorderDisplay extends StatefulWidget {
  final String id;
  final String oid;
  final String itemid;
  final String itemname;
  final String varname;
  final String price;
  final String qty;
  final String itemoactualamount;
  final String discount;
  final String subtotal;
  final String menuid;
  final String odeltime;
  final String itemImage;
  final String odate;
  final String itemPrice;
  final String itemQuantity;
  final String itemLeftCount;
  final String odelivery;
  final bool isdeltime;
  final String ostatustext;
  final String ototal;
  final String orderType;
  final String ostatus;
  final String itemmodelcharge;
  final double loyalty;
  final String totaldiscount;
  final double wallet;
  final String currenycyformat;

  MyorderDisplay(
    this.id,
    this.oid,
    this.itemid,
    this.itemname,
    this.varname,
    this.price,
    this.qty,
    this.itemoactualamount,
    this.discount,
    this.subtotal,
    this.menuid,
    this.odeltime,
    this.itemImage,
    this.odate,
    this.itemPrice,
    this.itemQuantity,
    this.itemLeftCount,
    this.odelivery,
    this.isdeltime,
    this.ostatustext,
    this.ototal,
    this.orderType,
    this.ostatus,
      this.itemmodelcharge,
      this.loyalty,
      this.wallet,
      this.totaldiscount,
      this.currenycyformat,

  );

  @override
  _MyorderDisplayState createState() => _MyorderDisplayState();
}

class _MyorderDisplayState extends State<MyorderDisplay> {
  bool _showreorder = false;
  bool _showCancelled = false;
  bool _showReturn = false;
  int _groupValue = -1;
  SharedPreferences prefs;
  var _message = TextEditingController();

  var _isWeb = false;
  var _total;
  var orderitemData;
  double total;
  String orderstatus;

  performReorder() async {
    //await Hive.box<Product>(productBoxName).deleteFromDisk();
    Hive.box<Product>(productBoxName).clear();
    if (Calculations.itemCount > 0) Navigator.of(context).pop();
    Navigator.of(context).pushNamed(CartScreen.routeName);
  }

  _dialogforOrdermsg(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: 110.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20.0),
                          Flexible(
                              child: Text(
                            "This will delete all items in the cart!!!",
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          )),
                          SizedBox(width: 20.0),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          performReorder();
                        },
                        child: Text(
                          'OK!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ],
                  )),
            );
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
   setState(() {
     _message.text = "";
   });


    super.initState();
  }


  Widget _myRadioButton({String title, int value, Function onChanged}) {
    final addressitemsData =
        Provider.of<AddressItemsList>(context, listen: false);

    if (_groupValue == 0) {
      prefs.setString("return_type", "0"); // 0 => Return
      Future.delayed(Duration.zero, () async {
        Navigator.pop(context);
        _groupValue = -1;

        if (addressitemsData.items.length > 0) {
          Navigator.of(context).pushNamed(ReturnScreen.routeName, arguments: {
            'orderid': widget.oid,
          });
        } else {
          prefs.setString("addressbook", "myorderdisplay");
          Navigator.of(context).pushNamed(ExampleScreen.routeName, arguments: {
            'addresstype': "new",
            'addressid': "",
            'delieveryLocation': "",
          });
        }
      });
    } else if (_groupValue == 1) {
      prefs.setString("return_type", "1"); // 1 => Exchange
      Future.delayed(Duration.zero, () async {
        Navigator.pop(context);
        _groupValue = -1;
        if (addressitemsData.items.length > 0) {
          Navigator.of(context).pushNamed(ReturnScreen.routeName, arguments: {
            'orderid': widget.oid,
          });
        } else {
          prefs.setString("addressbook", "myorderdisplay");
          Navigator.of(context).pushNamed(ExampleScreen.routeName, arguments: {
            'addresstype': "new",
            'addressid': "",
            'orderid': widget.oid,
            'delieveryLocation': "",
          });
        }
      });
    }

    return RadioListTile(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  _dialogforProcessing() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AbsorbPointer(
              child: Container(
                color: Colors.transparent,
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            );
          });
        });
  }

  Future<void> cancelOrder(String oid) async {
    prefs = await SharedPreferences.getInstance();
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'cancel-order';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": oid,
        "note": _message.text,
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(response.body);
      Navigator.pop(context);
      Navigator.pop(context);
      if (responseJson['status'].toString() == "200") {
        Navigator.of(context).pushReplacementNamed(
          MyorderScreen.routeName,
        );
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
      Navigator.pop(context);
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Something went wrong!!!");
      throw error;
    }
  }

  _dialogforReturn(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: 150.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Do you want to return or exchange",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      _myRadioButton(
                        title: "Return",
                        value: 0,
                        onChanged: (newValue) =>
                            setState(() => _groupValue = newValue),
                      ),
                      _myRadioButton(
                        title: "Exchange",
                        value: 1,
                        onChanged: (newValue) =>
                            setState(() => _groupValue = newValue),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforCancel(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: 250.0,
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        translate('forconvience.Ordere Id')+" : " + widget.oid,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        controller: _message,
                        decoration: InputDecoration(
                          hintText: translate('forconvience.Reasons (Optional)'),//"Reasons (Optional)",
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(),
                        ),
                        minLines: 3,
                        maxLines: 5,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      FlatButton(
                        onPressed: () {
                          _dialogforProcessing();
                          cancelOrder(widget.oid);
                        },
                        child: Text(
                          translate('forconvience.Next'), // "Next",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  )),
            );
          });
        });
  }

  Future<void> _ordersDetails() async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'view-customer-order-details/' + widget.oid;
    String varIds;
    int quantity;
    try {
      final response = await http.post(url, body: {});

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        final itemJson = json.encode(responseJson['items']);
        final itemJsondecode = json.decode(itemJson);
        List data = [];
List qty=[];
List variationId=[];
        itemJsondecode.asMap().forEach((index, value) =>
            data.add(itemJsondecode[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          quantity=int.parse(data[i]['quantity']);
          //varIds=data[i]['itemId'];
          variationId.add(data[i]['itemId']);
          qty.add(quantity);
          if(i == 0) {
            varIds = data[i]['itemId'].toString();
          } else {
            varIds = varIds + "," + data[i]['itemId'].toString();
          }
        }
        _repeatOrder(varIds,qty,variationId);

      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> _repeatOrder(String varIds,List quantity,List variationId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String qty;
    var url = IConstants.API_PATH + 'get-items-for-reorder/' + varIds;
    try {
      final response = await http.get(url);

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];
        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));
        final fruitMap = quantity.asMap();
        final varid= variationId.asMap();
        for (int i = 0; i < data.length; i++) {

          final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories
          if (pricevarJsondecode == null) {
          }
          else {
            pricevarJsondecode.asMap().forEach((index, value) => pricevardata
                .add(pricevarJsondecode[index] as Map<String, dynamic>));

            for (int j = 0; j < pricevardata.length; j++) {
              if(int.parse(pricevardata[j]['stock'].toString()) > 0) {
                final multiimagesJson = json.encode(
                    pricevardata[j]['images']); //fetching sub categories data
                final multiimagesJsondecode = json.decode(multiimagesJson);
                List multiimagesdata = [];
                String imageurl = "";
                if (multiimagesJsondecode.toString() == "[]") {
                  imageurl = IConstants.API_IMAGE +
                      "items/images/" +
                      data[i]['item_featured_image'].toString();
                } else {
                  multiimagesJsondecode.asMap().forEach((index, value) =>
                      multiimagesdata.add(
                          multiimagesJsondecode[index] as Map<String,
                              dynamic>));
                  imageurl = IConstants.API_IMAGE +
                      "items/images/" +
                      multiimagesdata[0]['image'].toString();
                }
                int count = 0;
                for (int k = 0; k < quantity.length; k++){
                  if (pricevardata[j]['id'].toString() == variationId[k]) {
                    count = quantity[k];
                    break;
                  }
                }

                try {
                  Product item = Hive
                      .box<Product>(
                      productBoxName)
                      .values
                      .firstWhere((value) =>
                  value.varId == int.parse(pricevardata[j]['id'].toString()));
                  {
                    Product products = Product(
                        itemId: int.parse(
                            pricevardata[j]['menu_item_id'].toString()),
                        varId: int.parse(pricevardata[j]['id'].toString()),
                        varName: pricevardata[j]['variation_name'].toString(),
                        varMinItem: int.parse(
                            pricevardata[j]['min_item'].toString()),
                        varMaxItem: int.parse(
                            pricevardata[j]['max_item'].toString()),
                        itemLoyalty: pricevardata[j]['loyalty'].toString() ==
                            "" ||
                            pricevardata[j]['loyalty'].toString() == "null"
                            ? 0
                            : int.parse(pricevardata[j]['loyalty'].toString()),
                        varStock: int.parse(
                            pricevardata[j]['stock'].toString()),
                        varMrp: double.parse(pricevardata[j]['mrp'].toString()),
                        itemName: data[i]['item_name'].toString(),
                        itemQty: count,
                        //int.parse(qty),//2,//int.parse(quantity),//2, //data[i]['item_name'].toString(),
                        itemPrice: double.parse(
                            pricevardata[j]['price'].toString()),
                        membershipPrice: pricevardata[j]['membership_price']
                            .toString(),
                        itemActualprice: double.parse(
                            pricevardata[j]['mrp'].toString()),
                        itemImage: imageurl,
                        membershipId: 0,
                        mode: 0);

                    var items = Hive.box<Product>(productBoxName);

                    for (int i = 0; i < items.length; i++) {
                      if (Hive
                          .box<Product>(productBoxName)
                          .values
                          .elementAt(i)
                          .varId ==
                          int.parse(pricevardata[j]['id'].toString())) {
                        Hive.box<Product>(productBoxName).putAt(i, products);
                      }
                    }
                  }
                } catch (e) {
                  Product products = Product(
                      itemId: int.parse(
                          pricevardata[j]['menu_item_id'].toString()),
                      varId: int.parse(pricevardata[j]['id'].toString()),
                      varName: pricevardata[j]['variation_name'].toString(),
                      varMinItem: int.parse(
                          pricevardata[j]['min_item'].toString()),
                      varMaxItem: int.parse(
                          pricevardata[j]['max_item'].toString()),
                      itemLoyalty: pricevardata[j]['loyalty'].toString() ==
                          "" ||
                          pricevardata[j]['loyalty'].toString() == "null"
                          ? 0
                          : int.parse(pricevardata[j]['loyalty'].toString()),
                      varStock: int.parse(pricevardata[j]['stock'].toString()),
                      varMrp: double.parse(pricevardata[j]['mrp'].toString()),
                      itemName: data[i]['item_name'].toString(),
                      itemQty: count,
                      itemPrice: double.parse(
                          pricevardata[j]['price'].toString()),
                      membershipPrice: pricevardata[j]['membership_price']
                          .toString(),
                      itemActualprice: double.parse(
                          pricevardata[j]['mrp'].toString()),
                      itemImage: imageurl,
                      membershipId: 0,
                      mode: 0);

                  Hive.box<Product>(productBoxName).add(products);
                }
              }
            }
          }
        }
      }
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(CartScreen.routeName);
    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {

    if(widget.ostatus=="CANCELLED"){
      orderstatus=translate('forconvience.CANCELLED');
    }
    else if(widget.ostatus=="COMPLETED"){
      orderstatus=translate('forconvience.COMPLETED');
    }

    else if(widget.ostatus=="DELIVERED"){
      orderstatus=translate('forconvience.DELIVERED');
    }

    else if(widget.ostatus=="DISPATCHED"){
      orderstatus=translate('forconvience.DISPATCHED');
    }
    else if(widget.ostatus=="PROCESSING"){
      orderstatus=translate('forconvience.PROCESSING');
    }
    else if(widget.ostatus=="PICK"){
      orderstatus="PICK";//translate('forconvience.DISPATCHED');
    }
    else if(widget.ostatus=="RECEIVED"){
      orderstatus=translate('forconvience.RECEIVED');
    }
    else if(widget.ostatus=="READY"){
      orderstatus="READY";//translate('forconvience.DISPATCHED');
    }
    else if(widget.ostatus=="RESCHEDULE"){
      orderstatus=translate('forconvience.RESCHEDULE');
    }
    else if(widget.ostatus=="ONWAY"){
      orderstatus=translate('forconvience.ONWAY');
    }
    else if(widget.ostatus=="FAILED"){
      orderstatus=translate('forconvience.FAILED');
    }
    if(widget.itemmodelcharge != "0"){
      total= double.parse(widget.itemoactualamount) +
          double.parse(widget.itemmodelcharge) -widget.wallet
          - widget.loyalty- double.parse(widget.totaldiscount);
    }
    else{
      total= double.parse(widget.itemoactualamount) -(widget.wallet
          + double.parse(widget.totaldiscount)) - widget.loyalty;
    }

    if (widget.ostatus.toLowerCase() == "received" ||
        widget.ostatus.toLowerCase() == "ready") {
      _showreorder = true;
      _showCancelled = true;
    } else if (widget.ostatus.toLowerCase() == "delivered" ||
        widget.ostatus.toLowerCase() == "completed") {
      _showreorder = true;
      _showReturn = true;
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
        color: Colors.white,
      ),
      margin: EdgeInsets.all(12),
     // color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0,),
        child: Column(
          children: <Widget>[
            if (widget.ostatus != "CANCELLED")
              SizedBox(
                height: 10,
              ),
           // if (widget.ostatus != "CANCELLED")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:18.0),
                child: Row(
                  children: [
                   /* Text(
                      widget.odelivery,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold),
                    ),*/
                    /*SizedBox(
                      width: 5,
                    ),*/
                    Text(
                      translate('forconvience.order') + " #" + widget.oid,
                      style: TextStyle(
                          color: ColorCodes.blackColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                   /* SizedBox(
                      width: 10,
                    ),*/
                    Spacer(),
                    Text(
                      widget.odate,
                      style: TextStyle(
                          color: ColorCodes.closebtncolor,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:18.0),
              child: Row(
                children: [
                  /*Container(
                    width: 75,
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.itemImage,
                          placeholder: (context, url) => Image.asset(
                            Images.defaultProductImg,
                            width: 75,
                            height: 75,
                          ),
                          width: 75,
                          height: 75,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),*/
                  Expanded(
                    child: Container(
                      width: (_isWeb&&ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width -300:MediaQuery.of(context).size.width-350 ,
                      child: Column(
                        children: [
                         /* Row(

                            children: [
                              Expanded(
                                child: Container(
                                  width: (_isWeb&&ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width - 600:MediaQuery.of(context).size.width - 350,
                                  child: Text(
                                    widget.itemname,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(color: ColorCodes.backbutton,fontSize: 16),
                                  ),
                                ),
                              ),
                              //Spacer(),

                            ],
                          ),*/
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /*Text(
                                    "Items :"+widget.varname,
                                    style: TextStyle(color: ColorCodes.closebtncolor),
                                  ),*/

                                    Text(
                              translate('forconvience.items')+" :"  +  (int.parse(widget.itemLeftCount)+1).toString(),
                                      style: TextStyle(color: ColorCodes.closebtncolor),
                                    ),

                                ],
                              ),
                              Spacer(),
                              Text(translate('forconvience.Total Price') +" : "+ ' ' + total.toStringAsFixed(2)+
                                  widget.currenycyformat ,
                                style: TextStyle(fontWeight: FontWeight.bold,
    color: ColorCodes.closebtncolor,
                                  fontSize: ResponsiveLayout.isSmallScreen(context) ? 12 : ResponsiveLayout.isMediumScreen(context) ? 14 : 16,  ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(color: ColorCodes.greyColor),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:8.0),
              child: Row(
                children: [
                 MouseRegion(
                   cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                      onTap: () {
                        if (widget.odelivery == "DELIVERY ON") {
                        } else {}
                        /*Navigator.of(context).pushNamed(OrderhistoryScreen.routeName,
                            arguments: {
                              'orderid' : widget.oid,
                              'fromScreen' : "myOrders",
                            }
                        );*/
                        Navigator.of(context).pushNamed(
                            orderexample.routeName,
                            arguments: {
                              'orderid': widget.oid,
                              'fromScreen': "myOrders",
                            });
                      },
                      child: Container(
                        height: 30,
                        //width: 100,
                        padding: const EdgeInsets.symmetric(horizontal:5.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            border:
                                Border.all(color: ColorCodes.closebtncolor),
                            ),
                        child: Center(
                            child: Text(
                              translate('forconvience.VIEW DETAILS') ,//"VIEW DETAILS",
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: ColorCodes.closebtncolor,),
                        )),
                      ),
                    ),
                  ),
                //  SizedBox(width: 8,),
                // if(widget.ostatus=="COMPLETED")
                   Spacer(),


                  if(widget.ostatus == "CANCELLED"||widget.ostatus == "FAILED"||widget.ostatus == "DELIVERED"||widget.ostatus=="COMPLETED")

                    //Spacer(),
                  MouseRegion(
                   cursor: SystemMouseCursors.click,
                       child: GestureDetector(
                      onTap: () {
                        _dialogforProcessing();
                        _ordersDetails();
                        /*Navigator.of(context).pushNamed(
                          HelpScreen.routeName,
                        );*/
                      },
                     /* child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal:12.0),
                        child:*/

                       child: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              border:
                                  Border.all(color: Theme.of(context).primaryColor),
                              color: ColorCodes.darkgreen),
                          child: Center(
                              child: Text(
                                translate('forconvience.RE-ORDER') , //"RE-ORDER",
                            style: TextStyle(fontSize: 13,
                                color: ColorCodes.whiteColor,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      //),
                    ),
                  ),
                  //SizedBox(width: 5,),
                  Spacer(),
                  (widget.orderType.toLowerCase() == "pickup")
                      ?
                  Row(
                    children: [
                      Text(
                        widget.ostatustext,
                        style:
                        TextStyle(color: Colors.black, fontSize: 14.0,
                          fontWeight: FontWeight.bold,),
                      ),
                      Spacer(),
                      Text(widget.ostatus,
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  )
                      :

                /*  Row(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            _dialogforReturn(context);
                          },
                          child: Container(
                            height: 30,
                            width: 125,
                            margin: EdgeInsets.only(top: 5.0),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3.0),
                                border: Border(
                                  top: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  bottom: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  left: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  right: BorderSide(
                                    width: 1.0,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )),
                            child: Center(
                                child: Text(
                                  'Return or Exchange',
                                  *//*'Re-order',*//*
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0),
                                )),
                          ),
                        ),
                      ),
                    ],
                  )
                      :*/ _showCancelled
                      ? /*Padding(
                        padding: const EdgeInsets.symmetric(horizontal:12.0),
                        child: */
                        Row(
                    children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              _dialogforCancel(context);
                            },
                            child: Container(
                              width: 100.0,
                              height: 30.0,
                            //  margin: EdgeInsets.only(top: 5.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3.0),
                                  border: Border(
                                    top: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    bottom: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    left: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    right: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  )),
                              child: Center(
                                  child: Text(
                                    translate('forconvience.Cancel') ,//'Cancel',
                                    /*'Re-order',*/
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ),
                        ),
                    ],
                  )
                      //)
                      : Row(
                    children: [
//                  Text(widget.ostatustext, style: TextStyle(color: Colors.black, fontSize: 16.0),),
                    /*  Text(
                        "ORDER STATUS:",
                        style:
                        TextStyle(fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),*/
                     // Spacer(),
                      if (widget.ostatus == "CANCELLED")
                        Text(
                          orderstatus,
                            //widget.ostatus,
                            style: TextStyle(
                                color: ColorCodes.redColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      if (widget.ostatus != "CANCELLED")
                        widget.ostatus=="COMPLETED"?
                            /*Padding(
                              padding: const EdgeInsets.only(right:12.0),
                              child: */
                              Text(
                                orderstatus,
                                 // widget.ostatus,
                                 // textAlign: TextAlign.end,
                                  style: TextStyle(
                                      color: ColorCodes.greenColor,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold))
                          //  )

                            :
                        Text(
                          orderstatus,
                           // widget.ostatus,
                            style: TextStyle(
                                color: ColorCodes.greenColor,
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),

                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
           /* Divider(
              color: Color(0xffA9A9A9),
            ),*/
           /* SizedBox(
              height: 10,
            ),

            SizedBox(
              height: 10.0,
            ),*/
          ],
        ),
      ),
    );
  }
}
