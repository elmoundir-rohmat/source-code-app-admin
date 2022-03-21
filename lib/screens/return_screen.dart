import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../providers/addressitems.dart';
import '../providers/myorderitems.dart';
import '../providers/deliveryslotitems.dart';

import '../screens/address_screen.dart';
import '../screens/myorder_screen.dart';
import '../constants/images.dart';
import '../screens/example_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ReturnScreen extends StatefulWidget {
  static const routeName = '/return-screen';

  @override
  ReturnScreenState createState() => ReturnScreenState();
}

class ReturnScreenState extends State<ReturnScreen> {
  int _groupValue = 0;
  SharedPreferences prefs;
  var _checkaddress = false;
  var _currencyFormat = "";
  List popupItems = [];
  var addressitemsData;
  var deliveryslotData;
  var addtype;
  var address;
  IconData addressicon;
  var _checkslots = false;
  var date, qty;
  var orderitemData;
  bool _isLoading = true;
  var box_color = Color(0xffDFEFFF);
  bool _isWeb = false;
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool w = true;
  bool x = false;
  bool y = false;
  bool z = false;
  var note = TextEditingController();

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
    note.text = "";
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, String>;

      final orderid = routeArgs['orderid'];
      Provider.of<MyorderList>(context,listen: false).Vieworders(orderid).then((_) {
        setState(() {
          orderitemData = Provider.of<MyorderList>(
            context,
            listen: false,
          );
          debugPrint("Orders. . . . . . . .. .. . ");
          debugPrint(orderitemData.vieworder1[0].returnTime);
          debugPrint(orderitemData.vieworder1[0].deliveryOn);
          DateTime today = new DateTime.now();
          DateTime fiftyDaysAgo = today.subtract(new Duration(hours: 2));
          debugPrint(today.toString());
          debugPrint(fiftyDaysAgo.toString());
          _isLoading = false;
        });
      });

      setState(() {
//        prefs.setString("returning_reason", "");
        prefs.setString("returning_reason", "Quality not adequate");
        _currencyFormat = prefs.getString("currency_format");
      });
      addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
      if (addressitemsData.items.length > 0) {
        _checkaddress = true;
        prefs.setString("addressId",
            addressitemsData.items[addressitemsData.items.length - 1].userid);
        addtype = addressitemsData
            .items[addressitemsData.items.length - 1].useraddtype;
        address = addressitemsData
            .items[addressitemsData.items.length - 1].useraddress;
        addressicon = addressitemsData
            .items[addressitemsData.items.length - 1].addressicon;
      } else {
        _checkaddress = false;
      }
      calldeliverslots("1");
    });
    super.initState();
  }

  Future<void> calldeliverslots(String addressid) async {
    Provider.of<DeliveryslotitemsList>(context,listen: false)
        .fetchDeliveryslots(prefs.getString("addressId"))
        .then((_) {
      deliveryslotData =
          Provider.of<DeliveryslotitemsList>(context, listen: false);
      if (deliveryslotData.items.length <= 0) {
        _checkslots = false;
      } else {
        _checkslots = true;
        date = deliveryslotData.items[0].dateformat;
        prefs.setString("fixdate", date);
      }
    });
  }

  Widget _myRadioButton({String title, int value, Function onChanged}) {
    return RadioListTile(
      controlAffinity: ListTileControlAffinity.trailing,
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, String>;

    final itemLeftCount = routeArgs['itemLeftCount'];

    void _settingModalBottomSheet(context) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SingleChildScrollView(
              child: Container(
                child: new Wrap(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      color: Color(0xffCADBEB),
                      child: Column(
                        children: <Widget>[
                          Spacer(),
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                "Choose a pickup address",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      child: new ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: addressitemsData.items.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  prefs.setString("addressId",
                                      addressitemsData.items[i].userid);
                                  addtype =
                                      addressitemsData.items[i].useraddtype;
                                  address =
                                      addressitemsData.items[i].useraddress;
                                  addressicon =
                                      addressitemsData.items[i].addressicon;
                                  calldeliverslots(
                                      addressitemsData.items[i].userid);
                                });
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Icon(addressitemsData.items[i].addressicon),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Text(
                                          addressitemsData.items[i].useraddtype,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(
                                          addressitemsData.items[i].useraddress,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Divider(
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 20.0),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Divider(color: Colors.black,),
                    GestureDetector(
                      onTap: () {
                        prefs.setString("formapscreen", "returnscreen");
                        Navigator.of(context)
                            .pushNamed(ExampleScreen.routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'delieveryLocation': "",
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 10.0,
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 15.0,
                                ),
                                Text(
                                  "Add new Address",
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 16.0),
                                ),
                                SizedBox(
                                  height: 15.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
            );
          });
    }

    _dialogforReturning(BuildContext context) {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
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
                        Text('Processing...'),
                      ],
                    )),
              );
            });
          });
    }

    gradientappbarmobile() {
      return AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Return or Exchange',
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    ColorCodes.whiteColor,
                    ColorCodes.whiteColor,
              ])),
        ),
      );
    }
    Widget _bodyWeb(){

       Widget itemsExchange() {
      return Container(
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 20,
              alignment: Alignment.centerLeft,
              height: 50,
              child: Text("Items to Exchange",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: new ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: int.parse(orderitemData.vieworder[0].itemsCount),
                  itemBuilder: (_, i) => Column(
                        children: [
                          Row(
                          children: <Widget>[
                            Container(
                                child: CachedNetworkImage(
                              imageUrl: orderitemData.vieworder1[i].itemImage,
                              placeholder: (context, url) => Image.asset(
                                Images.defaultProductImg,
                                width: 50,
                                height: 50,
                              ),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *0.30,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          orderitemData
                                                  .vieworder1[i].itemname +
                                              " , " +
                                              orderitemData
                                                  .vieworder1[i].varname,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(fontSize: 12),
                                        )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Price: "  +
                                        orderitemData.vieworder1[i].price+
                                        _currencyFormat,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Container(
                                    height: 30,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: PopupMenuButton(
                                      onSelected: (selectedValue) {
                                        setState(() {
                                          orderitemData.vieworder1[i]
                                              .qtychange = selectedValue;
//                                                        prefs.setString("fixdate", date);
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Qty: " +
                                                orderitemData
                                                    .vieworder1[i].qtychange,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                      /*icon: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text("Qty: " + orderitemData.vieworder1[i].qtychange,style: TextStyle(fontSize: 12),),
                                                      Icon(Icons.arrow_drop_down,size: 12,),
                                                    ],
                                                  ),*/
                                      itemBuilder: (_) =>
                                          <PopupMenuItem<String>>[
                                        for (int j = int.parse(orderitemData
                                                .vieworder1[i].qty);
                                            j >= 1;
                                            j--)
                                          new PopupMenuItem<String>(
                                              child: Text(j.toString()),
                                              value: j.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Checkbox(
                              value: orderitemData.vieworder1[i].checkboxval,
                              onChanged: (bool value) {
                                setState(() {
                                  orderitemData.vieworder1[i].checkboxval =
                                      value;
                                });
                              },
                            ),
                          ],
                            ),
                          Divider(),
                        ],
                      )),
            ),
//                              SizedBox(height: 10.0,),
          ],
        ),
      );
    }
       Widget proceed() {
      return Column(
        children: [
           Container(
                width: MediaQuery.of(context).size.width - 20,
                    alignment: Alignment.centerLeft,
                      height: 50,
                          child: Text("Why are you returning this?",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
//                      SizedBox(height: 10.0,),
                        Container(
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                              color: Theme.of(context).buttonColor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prefs.setString("returning_reason",
                                              "Quality not adequate");
                                          w = true;
                                          x = false;
                                          y = false;
                                          z = false;
                                        });
                                      },
                                      child: w
                                          ? Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width*0.20,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Quality not adequate",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width*0.20,
                                              decoration: BoxDecoration(
                                                color: box_color,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text("Quality not adequate"),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                       child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            prefs.setString("returning_reason",
                                                "Wrong item was sent");
                                            w = false;
                                            x = true;
                                            y = false;
                                            z = false;
                                          });
                                        },
                                        child: x
                                            ? Container(
                                                padding: EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    12,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width*0.20,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  borderRadius: new BorderRadius
                                                          .all(
                                                      new Radius.circular(5.0)),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Wrong item was sent",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )
                                            : Container(
                                                padding: EdgeInsets.all(10),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    12,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width*0.20,
                                                decoration: BoxDecoration(
                                                  color: box_color,
                                                  borderRadius: new BorderRadius
                                                          .all(
                                                      new Radius.circular(5.0)),
                                                ),
                                                alignment: Alignment.center,
                                                child:
                                                    Text("Wrong item was sent"),
                                              )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                     child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prefs.setString("returning_reason",
                                              "Item defective");
                                          w = false;
                                          x = false;
                                          y = true;
                                          z = false;
                                        });
                                      },
                                      child: y
                                          ? Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *0.20,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Item defective",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width*0.20,
                                              decoration: BoxDecoration(
                                                color: box_color,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text("Item defective"),
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prefs.setString("returning_reason",
                                              "Product damaged");
                                          w = false;
                                          x = false;
                                          y = false;
                                          z = true;
                                        });
                                      },
                                      child: z
                                          ? Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width*0.20,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Product damaged",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width*0.20,
                                              decoration: BoxDecoration(
                                                color: box_color,
                                                borderRadius:
                                                    new BorderRadius.all(
                                                        new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text("Product damaged"),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
//                                        Text(prefs.getString('returning_reason')),
                            ],
                          ),
                        ),

                        Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Pickup address",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
//                      SizedBox(height: 10.0,),
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            children: [
                              _checkaddress
                                  ? Container(
                                      height: 80,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
//                            SizedBox(width: 10.0,),
                                          Expanded(
                                              child: Text(
                                            address,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          MouseRegion(
                                             cursor: SystemMouseCursors.click,
                                               child: GestureDetector(
                                                onTap: () {
                                                  _settingModalBottomSheet(
                                                      context);
                                                },
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "CHANGE",
                                                      style: TextStyle(
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "---------",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 12.0,
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ),
//                            SizedBox(width: 10.0,),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      color: Colors.white,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            color:
                                                Theme.of(context).primaryColor,
                                            textColor:
                                                Theme.of(context).buttonColor,
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      3.0),
                                            ),
                                            onPressed: () => {
                                              Navigator.of(context).pushNamed(
                                                  ExampleScreen.routeName,
                                                  arguments: {
                                                    'addresstype': "new",
                                                    'addressid': "",
                                                    'delieveryLocation': "",
                                                  })
                                            },
                                            child: Text(
                                              'Add Address',
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                              Divider(),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(10.0),
                                leading: Image.asset(
                                  Images.shoppinglistsImg,
                                  width: 25.0,
                                  height: 35.0,
                                ),
                                title: Transform(
                                  transform:
                                      Matrix4.translationValues(-16, 0.0, 0.0),
                                  child: TextField(
                                    controller: note,
                                    decoration: InputDecoration.collapsed(
                                        hintText:
                                            "Any store request? We will try our best to co-operate",
                                        hintStyle: TextStyle(fontSize: 12.0),
                                        //contentPadding: EdgeInsets.all(16),
                                        //border: OutlineInputBorder(),
                                        fillColor: Color(0xffD5D5D5)),
                                    //minLines: 3,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

//                      SizedBox(height: 10.0,),

                        Container(
                          decoration: BoxDecoration(color: Color(0xffE5ECFF)),
                          child: ExpansionTile(
                            backgroundColor: Colors.white,
                            trailing: Container(
                                child: Icon(Icons.keyboard_arrow_down)),
                            title: IntrinsicHeight(
                              child: Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Choose date',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.black),
                                  )),
                            ),
                            children: [
//                            Text(prefs.getString('fixdate')),
                              _checkslots
                                  ? new ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: deliveryslotData.items.length,
                                      itemBuilder: (_, i) => Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child: _myRadioButton(
                                                  title: deliveryslotData
                                                      .items[i].dateformat,
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _groupValue = i;
                                                      date = deliveryslotData
                                                          .items[i].dateformat;
                                                      prefs.setString(
                                                          "fixdate", date);
                                                    });
                                                  },
                                                ),
                                              ),
//                                    Text(deliveryslotData.items[i].dateformat),
                                            ],
                                          ))
                                  : Text(
                                      "Currently there is no slots available",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ),

                        Row(
                          children: <Widget>[
                            Spacer(),
                            MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                onTap: () {
                                  List array = [];
                                  String orderid;
                                  String itemname;
                                  bool _selectitem = false;
                                  for (int i = 0;
                                      i <
                                          int.parse(orderitemData
                                              .vieworder[0].itemsCount);
                                      i++) {
                                    if (orderitemData.vieworder1[i].checkboxval) {
                                      setState(() {
                                        _selectitem = true;
                                        orderid = orderitemData
                                            .vieworder1[i].itemorderid;
                                        itemname = orderitemData
                                                .vieworder1[i].itemname +
                                            " - " +
                                            orderitemData.vieworder1[i].varname;
                                        //itemvar = orderitemData[i].varname;
                                      });
                                      var value = {};
//                                          value["\"itemId\""] = "\"" + orderitemData[i].itemid + "\"";
                                      value["\"itemId\""] = "\"" +
                                          orderitemData.vieworder1[i]
                                              .customerorderitemsid +
                                          "\"";
                                      value["\"qty\""] = "\"" +
                                          orderitemData.vieworder1[i].qty +
                                          "\"";
                                      //value["\"itemname\""] = "\"" + itemname + "\"";
                                      array.add(value.toString());
                                    }
                                  }
                                  if (_selectitem) {
                                    _dialogforReturning(context);
                                    Provider.of<MyorderList>(context,listen: false)
                                        .ReturnItem(
                                            array.toString(), orderid, itemname)
                                        .then((_) {
                                      Provider.of<MyorderList>(context,listen: false)
                                          .Vieworders(orderid)
                                          .then((_) {
                                        setState(() {
                                          Navigator.of(context).pop();
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                            MyorderScreen.routeName,
                                          );
                                        });
                                      });
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Please select the item!!!");
                                  }
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width*0.43,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Center(
                                      child: Text(
                                    'PROCEED',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )),
                                ),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
        ],
      );
    }
       queryData = MediaQuery.of(context);
       wid= queryData.size.width;
       maxwid=wid*0.90;
    return _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            )
          : Expanded(
             child: SingleChildScrollView(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                    child: Container(
                      constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

                      child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20,),
                        Flexible(child: itemsExchange()),
                        SizedBox(width: 30,),
                        Flexible(child: proceed()),
                        SizedBox(width: 20,),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10.0,),
                if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                  Footer(
                      address: prefs.getString("restaurant_address")),
              ],
            ),
            ),
          );
    }

    Widget _bodyMobile(){

       Widget itemsExchange() {
      return Container(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 20,
              alignment: Alignment.centerLeft,
              height: 50,
              child: Text("Items to Exchange",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.all(10),
              child: new ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: int.parse(orderitemData.vieworder[0].itemsCount),
                  itemBuilder: (_, i) => Column(
                        children: [
                          Row(
                          children: <Widget>[
                            Container(
                                child: CachedNetworkImage(
                              imageUrl: orderitemData.vieworder1[i].itemImage,
                              placeholder: (context, url) => Image.asset(
                                Images.defaultProductImg,
                                width: 50,
                                height: 50,
                              ),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width/2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          orderitemData
                                                  .vieworder1[i].itemname +
                                              " , " +
                                              orderitemData
                                                  .vieworder1[i].varname,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(fontSize: 12),
                                        )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    "Price: " +
                                        orderitemData.vieworder1[i].price +
                                        _currencyFormat,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  Container(
                                    height: 30,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: PopupMenuButton(
                                      onSelected: (selectedValue) {
                                        setState(() {
                                          orderitemData.vieworder1[i]
                                              .qtychange = selectedValue;
//                                                        prefs.setString("fixdate", date);
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Qty: " +
                                                orderitemData
                                                    .vieworder1[i].qtychange,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            size: 12,
                                          ),
                                        ],
                                      ),
                                      /*icon: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text("Qty: " + orderitemData.vieworder1[i].qtychange,style: TextStyle(fontSize: 12),),
                                                      Icon(Icons.arrow_drop_down,size: 12,),
                                                    ],
                                                  ),*/
                                      itemBuilder: (_) =>
                                          <PopupMenuItem<String>>[
                                        for (int j = int.parse(orderitemData
                                                .vieworder1[i].qty);
                                            j >= 1;
                                            j--)
                                          new PopupMenuItem<String>(
                                              child: Text(j.toString()),
                                              value: j.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Checkbox(
                              value: orderitemData.vieworder1[i].checkboxval,
                              onChanged: (bool value) {
                                setState(() {
                                  orderitemData.vieworder1[i].checkboxval =
                                      value;
                                });
                              },
                            ),
                          ],
                            ),
                          Divider(),
                        ],
                      )),
            ),
//                              SizedBox(height: 10.0,),
          ],
        ),
      );
    }
       Widget proceed() {
      return Column(
        children: [
           Container(
                width: MediaQuery.of(context).size.width - 20,
                    alignment: Alignment.centerLeft,
                      height: 50,
                          child: Text("Why are you returning this?",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
//                      SizedBox(height: 10.0,),
                        Container(
                          height: MediaQuery.of(context).size.height / 4,
                          decoration: BoxDecoration(
                              color: Theme.of(context).buttonColor),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        prefs.setString("returning_reason",
                                            "Quality not adequate");
                                        w = true;
                                        x = false;
                                        y = false;
                                        z = false;
                                      });
                                    },
                                    child: w
                                        ? Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Quality not adequate",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: box_color,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Quality not adequate"),
                                          ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          prefs.setString("returning_reason",
                                              "Wrong item was sent");
                                          w = false;
                                          x = true;
                                          y = false;
                                          z = false;
                                        });
                                      },
                                      child: x
                                          ? Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.4,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "Wrong item was sent",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            )
                                          : Container(
                                              padding: EdgeInsets.all(10),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  12,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.4,
                                              decoration: BoxDecoration(
                                                color: box_color,
                                                borderRadius: new BorderRadius
                                                        .all(
                                                    new Radius.circular(5.0)),
                                              ),
                                              alignment: Alignment.center,
                                              child:
                                                  Text("Wrong item was sent"),
                                            )),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        prefs.setString("returning_reason",
                                            "Item defective");
                                        w = false;
                                        x = false;
                                        y = true;
                                        z = false;
                                      });
                                    },
                                    child: y
                                        ? Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Item defective",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: box_color,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Item defective"),
                                          ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        prefs.setString("returning_reason",
                                            "Product damaged");
                                        w = false;
                                        x = false;
                                        y = false;
                                        z = true;
                                      });
                                    },
                                    child: z
                                        ? Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Product damaged",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          )
                                        : Container(
                                            padding: EdgeInsets.all(10),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                12,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            decoration: BoxDecoration(
                                              color: box_color,
                                              borderRadius:
                                                  new BorderRadius.all(
                                                      new Radius.circular(5.0)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text("Product damaged"),
                                          ),
                                  ),
                                ],
                              ),
//                                        Text(prefs.getString('returning_reason')),
                            ],
                          ),
                        ),

                        Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: 50,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Pickup address",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
//                      SizedBox(height: 10.0,),
                        Container(
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            children: [
                              _checkaddress
                                  ? Container(
                                      height: 80,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      color: Colors.white,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
//                            SizedBox(width: 10.0,),
                                          Expanded(
                                              child: Text(
                                            address,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.0,
                                            ),
                                          )),
                                          GestureDetector(
                                              onTap: () {
                                                _settingModalBottomSheet(
                                                    context);
                                              },
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "CHANGE",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "---------",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontSize: 12.0,
                                                    ),
                                                  ),
                                                ],
                                              )),
//                            SizedBox(width: 10.0,),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(10.0),
                                      color: Colors.white,
                                      child: Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Spacer(),
                                          FlatButton(
                                            color:
                                                Theme.of(context).primaryColor,
                                            textColor:
                                                Theme.of(context).buttonColor,
                                            shape: new RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      3.0),
                                            ),
                                            onPressed: () => {
                                              Navigator.of(context).pushNamed(
                                                  ExampleScreen.routeName,
                                                  arguments: {
                                                    'addresstype': "new",
                                                    'addressid': "",
                                                    'delieveryLocation': "",
                                                  })
                                            },
                                            child: Text(
                                              'Add Address',
                                              style: TextStyle(fontSize: 12.0),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                              Divider(),
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(10.0),
                                leading: Image.asset(
                                  Images.shoppinglistsImg,
                                  width: 25.0,
                                  height: 35.0,
                                ),
                                title: Transform(
                                  transform:
                                      Matrix4.translationValues(-16, 0.0, 0.0),
                                  child: TextField(
                                    controller: note,
                                    decoration: InputDecoration.collapsed(
                                        hintText:
                                            "Any store request? We will try our best to co-operate",
                                        hintStyle: TextStyle(fontSize: 12.0),
                                        //contentPadding: EdgeInsets.all(16),
                                        //border: OutlineInputBorder(),
                                        fillColor: Color(0xffD5D5D5)),
                                    //minLines: 3,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

//                      SizedBox(height: 10.0,),

                        Container(
                          decoration: BoxDecoration(color: Color(0xffE5ECFF)),
                          child: ExpansionTile(
                            backgroundColor: Colors.white,
                            trailing: Container(
                                child: Icon(Icons.keyboard_arrow_down)),
                            title: IntrinsicHeight(
                              child: Container(
                                  width: MediaQuery.of(context).size.width - 20,
                                  height: 50,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Choose date',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.black),
                                  )),
                            ),
                            children: [
//                            Text(prefs.getString('fixdate')),
                              _checkslots
                                  ? new ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: deliveryslotData.items.length,
                                      itemBuilder: (_, i) => Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.3,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.grey),
                                                ),
                                                child: _myRadioButton(
                                                  title: deliveryslotData
                                                      .items[i].dateformat,
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      _groupValue = i;
                                                      date = deliveryslotData
                                                          .items[i].dateformat;
                                                      prefs.setString(
                                                          "fixdate", date);
                                                    });
                                                  },
                                                ),
                                              ),
//                                    Text(deliveryslotData.items[i].dateformat),
                                            ],
                                          ))
                                  : Text(
                                      "Currently there is no slots available",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ),

                        Row(
                          children: <Widget>[
                            Spacer(),
                            GestureDetector(
                              onTap: () {
                                List array = [];
                                String orderid;
                                String itemname;
                                bool _selectitem = false;
                                for (int i = 0;
                                    i <
                                        int.parse(orderitemData
                                            .vieworder[0].itemsCount);
                                    i++) {
                                  if (orderitemData.vieworder1[i].checkboxval) {
                                    setState(() {
                                      _selectitem = true;
                                      orderid = orderitemData
                                          .vieworder1[i].itemorderid;
                                      itemname = orderitemData
                                              .vieworder1[i].itemname +
                                          " - " +
                                          orderitemData.vieworder1[i].varname;
                                      //itemvar = orderitemData[i].varname;
                                    });
                                    var value = {};
//                                          value["\"itemId\""] = "\"" + orderitemData[i].itemid + "\"";
                                    value["\"itemId\""] = "\"" +
                                        orderitemData.vieworder1[i]
                                            .customerorderitemsid +
                                        "\"";
                                    value["\"qty\""] = "\"" +
                                        orderitemData.vieworder1[i].qty +
                                        "\"";
                                    //value["\"itemname\""] = "\"" + itemname + "\"";
                                    array.add(value.toString());
                                  }
                                }
                                if (_selectitem) {
                                  _dialogforReturning(context);
                                  Provider.of<MyorderList>(context,listen: false)
                                      .ReturnItem(
                                          array.toString(), orderid, itemname)
                                      .then((_) {
                                    Provider.of<MyorderList>(context,listen: false)
                                        .Vieworders(orderid)
                                        .then((_) {
                                      setState(() {
                                        Navigator.of(context).pop();
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                          MyorderScreen.routeName,
                                        );
                                      });
                                    });
                                  });
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Please select the item!!!");
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Center(
                                    child: Text(
                                  'PROCEED',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                            ),
                            Spacer(),
                          ],
                        ),
        ],
      );
    }
    return _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            )
          : Expanded(
             child: SingleChildScrollView(
             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                itemsExchange(),
                proceed(),
                SizedBox(height: 10.0,),
                if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                  Footer(
                      address: prefs.getString("restaurant_address")),
              ],
            ),
            ),
          );
    }

    

    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context)
          ? gradientappbarmobile()
          : null,
      backgroundColor: Colors.white,//Theme.of(context).backgroundColor,
      body: Column(
        children: [
          if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
          Header(false),
          (_isWeb && !ResponsiveLayout.isSmallScreen(context))?_bodyWeb():_bodyMobile(),
        ],
      ),
    );
  }
}
