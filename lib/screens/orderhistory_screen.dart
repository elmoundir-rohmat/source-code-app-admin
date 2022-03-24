import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/return_screen.dart';
import '../screens/home_screen.dart';
import '../screens/address_screen.dart';
import '../widgets/orderhistory_display.dart';
import '../screens/example_screen.dart';
import '../providers/myorderitems.dart';
import '../providers/addressitems.dart';
import '../providers/notificationitems.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OrderhistoryScreen extends StatefulWidget {
  static const routeName = '/orderhistory-screen';
  @override
  _OrderhistoryScreenState createState() => _OrderhistoryScreenState();
}

class _OrderhistoryScreenState extends State<OrderhistoryScreen> {
  var _showreorder = false;
  var _currencyFormat = "";
  int _groupValue = -1;
  SharedPreferences prefs;
  bool _isreturn = false;
  String appbartext = "Order Summary";
  bool _isLoading = true;
  var orderitemData;
  String orderdate;
  String paytype;
  String orderType;
  String promocode = "";
  double loyalty = 0;
  double wallet = 0;
  String totalDiscount = "";
  String orderstatus;
  String oaddress;
  String odeltime;
  String odelivery;
  bool isdeltime;
  String ostatustext;
  bool _isWillpop = false;

  String id;
  String oid;
  String itemid;
  String itemname;
  String varname;
  String price;
  String qty;
  String itemoactualamount;
  String discount;
  String subtotal;
  String itemImage;
  String menuid;
  String barcode;
  //BuildContext context;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {

      prefs = await SharedPreferences.getInstance();
      setState(() {
        _currencyFormat = prefs.getString("currency_format");
      });

      final routeArgs = ModalRoute
          .of(context)
          .settings
          .arguments as Map<String, String>;
      if(routeArgs['fromScreen'] == "pushNotification") {
        Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" );
      } else {
        if(routeArgs['notificationStatus'] == "0"){
          Provider.of<NotificationItemsList>(context, listen: false).updateNotificationStatus(routeArgs['notificationId'], "1" ).then((value){
            setState(() {
              Provider.of<NotificationItemsList>(context, listen: false).fetchNotificationLogs(

                  prefs.getString('userID'));
            });
            });

        }
      }
      final orderid = routeArgs['orderid'];
      if(routeArgs['fromScreen'] == "pushNotification" || routeArgs['fromScreen'] == "pushNotificationScreen") {
        _isWillpop = true;
        Provider.of<MyorderList>(context, listen: false).Vieworders(orderid).then((_) {
          setState(() {
            orderitemData = Provider.of<MyorderList>(context, listen: false,);

            id = orderitemData[0].id;
            oid = orderitemData[0].order_d;
            itemid = orderitemData[0].itemId;
            itemname = orderitemData[0].itemName;
            varname = orderitemData[0].priceVariavtion;
            price = orderitemData[0].price;
            qty = orderitemData[0].toString();
            itemoactualamount = orderitemData[0].actualAmount;
            discount = orderitemData[0].discount;
            subtotal = orderitemData[0].subTotal;
            itemImage = orderitemData[0].image;
            menuid = orderitemData[0].menuid;
            barcode = orderitemData[0].barcode;
          });


         /* orderdate = orderitemData[0].odate;
          paytype = orderitemData[0].opaytype;
          orderType = orderitemData[0].orderType;
          promocode = orderitemData[0].promocode;
          loyalty = orderitemData[0].loyalty;
          wallet = orderitemData[0].wallet;
          totalDiscount = orderitemData[0].totalDiscount;
          orderstatus = orderitemData[0].ostatus;
          oaddress = orderitemData[0].oaddress;
          odeltime = orderitemData[0].odeltime;
          odelivery = orderitemData[0].odelivery;
          isdeltime = orderitemData[0].isdeltime;
          ostatustext = orderitemData[0].ostatustext;*/

          setState(() {
            _isLoading = false;
            if (ostatustext == "RETURN STATUS") {
              _isreturn = true;
              appbartext = "Return Summary";
            } else {
              appbartext = "Order Summary";
              _isreturn = false;
            }
          });
        });
      } else {
        _isWillpop = false;
        orderitemData = Provider.of<MyorderList>(
          context,
          listen: false,
        );
setState(() {
  id = orderitemData[0].id;
  oid = orderitemData[0].order_d;
  itemid = orderitemData[0].itemId;
  itemname = orderitemData[0].itemName;
  varname = orderitemData[0].priceVariavtion;
  price = orderitemData[0].price;
  qty = orderitemData[0].toString();
  itemoactualamount = orderitemData[0].actualAmount;
  discount = orderitemData[0].discount;
  subtotal = orderitemData[0].subTotal;
  itemImage = orderitemData[0].image;
  menuid = orderitemData[0].menuid;
  barcode = orderitemData[0].barcode;
});


        /*orderdate = orderitemData[0].odate;
        paytype = orderitemData[0].opaytype;
        orderType = orderitemData[0].orderType;
        promocode = orderitemData[0].promocode;
        loyalty = orderitemData[0].loyalty;
        wallet = orderitemData[0].wallet;
        totalDiscount = orderitemData[0].totalDiscount;
        orderstatus = orderitemData[0].ostatus;
        oaddress = orderitemData[0].oaddress;
        odeltime = orderitemData[0].odeltime;
        odelivery = orderitemData[0].odelivery;
        isdeltime = orderitemData[0].isdeltime;
        ostatustext = orderitemData[0].ostatustext;*/

        setState(() {
          _isLoading = false;
          if (ostatustext == "RETURN STATUS") {
            _isreturn = true;
            appbartext = "Return Summary";
          } else {
            appbartext = "Order Summary";
            _isreturn = false;
          }
        });
      }
    });
    super.initState();
  }

  Widget _myRadioButton({String title, int value, Function onChanged}) {
    final addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
    final routeArgs = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;
    final orderid = routeArgs['orderid'];

    if(_groupValue == 0) {
      prefs.setString("return_type", "0"); // 0 => Return
      Future.delayed(Duration.zero, () async {
        Navigator.pop(context);
        _groupValue = -1;

        if (addressitemsData.items.length > 0) {
          Navigator.of(context).pushNamed(ReturnScreen.routeName,
              arguments: {
                'orderid' : orderid,
              }
          );
        } else {
          prefs.setString("addressbook", "myorderdisplay");
          Navigator.of(context).pushNamed(
              ExampleScreen.routeName,
              arguments: {
                'addresstype' : "new",
                'addressid': "",
                'delieveryLocation': "",
              }
          );
        }

      });

    } else if(_groupValue == 1) {
      prefs.setString("return_type", "1"); // 1 => Exchange
      Future.delayed(Duration.zero, () async {
        Navigator.pop(context);
        _groupValue = -1;
        if (addressitemsData.items.length > 0) {
          Navigator.of(context).pushNamed(ReturnScreen.routeName,
              arguments: {
                'orderid' : orderid,
              }
          );
        } else {
          prefs.setString("addressbook", "myorderdisplay");
          Navigator.of(context).pushNamed(
              ExampleScreen.routeName,
              arguments: {
                'addresstype' : "new",
                'addressid': "",
                'orderid' : orderid,
                'delieveryLocation': "",
              }
          );
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

  _dialogforReturn(BuildContext context) {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0)
                  ),
                  child: Container(
                      height: 150.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 10.0,),
                          Text("Do you want to return or exchange", style: TextStyle(color: Colors.black,),),
                          _myRadioButton(
                            title: "Return",
                            value: 0,
                            onChanged: (newValue) => setState(() => _groupValue = newValue),
                          ),
                          _myRadioButton(
                            title: "Exchange",
                            value: 1,
                            onChanged: (newValue) => setState(() => _groupValue = newValue),
                          ),
                        ],
                      )
                  ),
                );
              }
          );
        });
  }

  _buildBottomNavigationBar() {
    return _showreorder ?
    SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          //performReorder();
          _dialogforReturn(context);
        },
        child: Container(
          height: 80.0,
          color: Theme.of(context).backgroundColor,
          child: Container(
            margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 20.0),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(3.0),
                border: Border(
                  top: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                  bottom: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                  left: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                  right: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                )),
            height: 60.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text("Return or Exchange items", style: TextStyle(color: Colors.white, fontSize: 16.0),),
                /*Text("Repeat Order", style: TextStyle(color: Colors.white, fontSize: 16.0),),
                Text("View cart on next step", style: TextStyle(color: Colors.white, fontSize: 12.0),),*/
              ],
            ),
          ),
        ),
      ),
    )
        :
    Container();
  }

  @override
  Widget build(BuildContext context) {
    var returnitemData;

    final routeArgs = ModalRoute
        .of(context)
        .settings
        .arguments as Map<String, String>;
    final orderid = routeArgs['orderid'];

    if(ostatustext == "RETURN STATUS") {
      returnitemData = Provider.of<MyorderList>(
        context,
        listen: false,
      ).findByreturnId(orderid);
    }


    if(orderstatus == "delivered" || orderstatus == "completed") {
      _showreorder = true;
    }

    Widget design() {
      return Scaffold(
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [ ColorCodes.whiteColor,
                ColorCodes.whiteColor,]
          ),
          automaticallyImplyLeading: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded,size: 20, color: ColorCodes.backbutton),
              onPressed: () {
                Navigator.of(context).pop();
                return Future.value(false);
              }
          ),
          title: Text(
            appbartext,
          ),
        ),
        backgroundColor: Colors.white,//Theme.of(context).backgroundColor,
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        _isreturn ?
        Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 80.0),
                color: Theme.of(context).backgroundColor,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Return items", style: TextStyle(color: Colors.black, fontSize: 18.0),),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(height: 5.0,),
                      SizedBox(
                        child: new ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: returnitemData.length,
                          itemBuilder: (_, i) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(returnitemData[i].returnitemname + " - " + returnitemData[i].returnvarname, style: TextStyle(color: Colors.black, fontSize: 16.0),),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text("Qty: " + returnitemData[i].returnitemqty, style: TextStyle(fontSize: 14.0),),
                              SizedBox(
                                height: 10.0,
                              ),
                              /*OrderhistoryDisplay(
                            orderitemData[i].itemname,
                            orderitemData[i].varname,
                            orderitemData[i].price,
                            orderitemData[i].qty,
                            orderitemData[i].subtotal,
                          ),*/
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Text("Return Details", style: TextStyle(color: Colors.black, fontSize: 18.0),),
                      Divider(
                        color: Colors.grey,
                      ),
                      SizedBox(height: 5.0,),
                      Text("Reference number", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                      SizedBox(height: 5.0,),
                      Text(returnitemData[0].returnref, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                      SizedBox(height: 15.0,),
                      Text("Return date", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                      SizedBox(height: 5.0,),
                      Text(returnitemData[0].returndate, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                      SizedBox(height: 15.0,),
                      Text("Reason", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                      SizedBox(height: 5.0,),
                      Text(returnitemData[0].returnreason, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                      SizedBox(height: 15.0,),
                      Text("Pickup address", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                      SizedBox(height: 5.0,),
                      Text(returnitemData[0].returnaddress, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isreturn = false;
                            appbartext = "Order Summary";
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Spacer(),
                            Container(
                              width: 150.0,
                              height: 40.0,
                              margin: EdgeInsets.only(top: 15.0, bottom: 15.0),
                              decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.circular(3.0),),
                              child: Center(
                                  child: Text('Order Summary', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            :
        Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  //height: MediaQuery.of(context).size.height,
                  margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0, bottom: 80.0),
                  color: Theme.of(context).backgroundColor,
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 16
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Your Order", style: TextStyle(color: Colors.black, fontSize: 18.0),),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5.0,),
                          SizedBox(
                            child: new ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: orderitemData.length,
                              itemBuilder: (_, i) => Column(children: [
                                OrderhistoryDisplay(
                                  orderitemData[i].itemname,
                                  orderitemData[i].varname,
                                  orderitemData[i].price,
                                  orderitemData[i].qty,
                                  orderitemData[i].subtotal,
                                  orderitemData[i].itemImage,

                                ),
                              ],
                              ),
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Text("Item Total", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14.0),),
                              Spacer(),
                              Text( " " + orderitemData[0].itemoactualamount+_currencyFormat , style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          (orderType.toLowerCase() == "pickup") ? Container() : Row(
                            children: <Widget>[
                              Text("Delivery Charge", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                              Spacer(),
                              Text(" " + orderitemData[0].itemodelcharge+_currencyFormat , style: TextStyle(color: Colors.grey, fontSize: 11.0),),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          if(promocode != "")
                            Row(
                              children: <Widget>[
                                Text("Promo - ($promocode)", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0),),
                                Spacer(),
                                Text("you save " + " " + totalDiscount+ _currencyFormat , style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),),
                              ],
                            ),
                          SizedBox(
                            height: 5.0,
                          ),
                          if(loyalty > 0)
                            Row(
                              children: <Widget>[
                                Text("Discount Applied (loyalty)", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0),),
                                Spacer(),
                                Text("you save "  + " " + loyalty.toString()+ _currencyFormat, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),),
                              ],
                            ),
                          SizedBox(
                            height: 5.0,
                          ),
                          if(wallet > 0)
                            Row(
                              children: <Widget>[
                                Text("Wallet", style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14.0),),
                                Spacer(),
                                Text("you save "  + " " + wallet.toString()+ _currencyFormat, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12.0),),
                              ],
                            ),
                          Divider(
                            color: Colors.grey,
                          ),
                          Row(
                            children: <Widget>[
                              Text("Total", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14.0),),
                              Spacer(),
                              Text( " " + orderitemData[0].itemototalamount+_currencyFormat , style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 16.0),),
                            ],
                          ),
                          SizedBox(
                            height: 30.0,
                          ),
                          Text("Order Details", style: TextStyle(color: Colors.black, fontSize: 18.0),),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(height: 5.0,),
                          Text("Order number", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(orderid, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                          Text("Order date", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(orderdate, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                          Text("Payment", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(paytype.toUpperCase(), style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                          if(isdeltime)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(odelivery, style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                                SizedBox(height: 5.0,),
                                Text(odeltime, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                                SizedBox(height: 15.0,),
                              ],
                            ),
                          Text("Order status", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(orderstatus, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                          Text("Phone number", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(orderitemData[0].omobilenum, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                          (orderType.toLowerCase() == "pickup") ?
                          Text("Pickup from", style: TextStyle(color: Colors.grey, fontSize: 12.0),)
                              :
                          Text("Deliver to", style: TextStyle(color: Colors.grey, fontSize: 12.0),),
                          SizedBox(height: 5.0,),
                          Text(oaddress, style: TextStyle(color: Colors.black, fontSize: 12.0),),
                          SizedBox(height: 15.0,),
                        ],
                      )),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomNavigationBar(),
              ),
            ]
        ),
      );
    }

    return _isWillpop ?
    design()
        :
    design();
  }
}