import 'dart:io';

import 'package:fellahi_e/providers/addressitems.dart';
import 'package:fellahi_e/screens/return_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/myorder_screen.dart';
import '../providers/myorderitems.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/orderhistory_display.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../screens/help_screen.dart';
import 'address_screen.dart';
import 'home_screen.dart';
import '../constants/ColorCodes.dart';
import '../screens/example_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_translate/flutter_translate.dart';

class orderexample extends StatefulWidget {
  static const routeName = '/orderexample-screen';
  @override
  _orderexampleState createState() => _orderexampleState();
}

class _orderexampleState extends State<orderexample> {
  SharedPreferences prefs;
  var _currencyFormat = "";
  var _address = "";

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
  String ordertype;
  var orderitemData;
  bool _isLoading = true;
  var phone = "";
  var _isWeb = false;
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool _showReturn = false;
  int _groupValue = -1;
  String orderid,orderstatus;
  var fromscreen;

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
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
      _currencyFormat = prefs.getString("currency_format");
      if (prefs.getString('mobile') != null) {
        phone = prefs.getString('mobile');
      } else {
        phone = "";
      }

      final routeArgs =
      ModalRoute.of(context).settings.arguments as Map<String, String>;

      final orderid = routeArgs['orderid'];
       fromscreen=routeArgs['fromScreen'];


      Provider.of<MyorderList>(context, listen: false).Vieworders(orderid).then((_) {
        setState(() {
          orderitemData = Provider.of<MyorderList>(
            context,
            listen: false,
          );
          if(orderitemData.vieworder1[0].deliveryOn!=""){
            DateTime today = new DateTime.now();
            DateTime orderAdd =DateTime.parse(orderitemData.vieworder1[0].deliveryOn).add(Duration(hours:int.parse (orderitemData.vieworder1[0].returnTime)));
            if((orderAdd.isAtSameMomentAs(today)||orderAdd.isAfter(today))&& orderitemData.vieworder1[0].ostatustext== "DELIVERED") {
              if(orderitemData.vieworder1[0].returnTime!="")
                setState(() {
                  _showReturn = true;
                });
            }
          }
          _isLoading = false;
        });
      });
    });
    super.initState();
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
            'orderid': orderid,
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
            'orderid': orderid,
          });
        } else {
          prefs.setString("addressbook", "myorderdisplay");
          Navigator.of(context).pushNamed(ExampleScreen.routeName, arguments: {
            'addresstype': "new",
            'addressid': "",
            'orderid': orderid,
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // this is the block you need
       /* Navigator.pushNamedAndRemoveUntil(
            context, MyorderScreen.routeName, (route) => false)*/
        if(fromscreen=="pushNotification")
          {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home-screen', (Route<dynamic> route) => false);
          }else {
          Navigator.of(context).pop();
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
        //GradientAppBar(
        //gradient: LinearGradient(
        //  begin: Alignment.topRight,
        //end: Alignment.bottomLeft,
        //colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
        // ),
        //title: Row(
        //children: [
        //Text(
        // Order Details",
//    Spacer(),
        //   GestureDetector(
        //  onTap: (){
        // Navigator.of(context).pushNamed(
        //  HelpScreen.routeName,
        //  );
        //  },
        //   child: Text(
        //  translate('forconvience.HELP'),
        // ),
        //  ),
        //   ],
        //   ),
        //   ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Header(false),
            _isLoading ?
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            ):
            (_isWeb && !ResponsiveLayout.isSmallScreen(context))?_bodyweb():
            _body(),
           // _body(),
          ],
        ),
      ),
    );
  }
_bodyweb(){
  queryData = MediaQuery.of(context);
  wid= queryData.size.width;
  maxwid=wid*0.95;
  final routeArgs =
  ModalRoute.of(context).settings.arguments as Map<String, String>;
  final itemLeftCount = routeArgs['itemLeftCount'];
  return Expanded(
    child: Container(
      constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: _isWeb && !ResponsiveLayout.isSmallScreen(context)?ColorCodes.whiteColor:Color(0xffF1F1F1),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            )
                :
            // (_isWeb && !ResponsiveLayout.isSmallScreen(context))
            //     ? bodyweb()
            //     :
            vieworderweb(),
            SizedBox(height: 40,),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Footer(address: _address/*prefs.getString("restaurant_address")*/),
          ],
        ),
      ),
    ),
  );
}
  _body() {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.95;
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, String>;
    final itemLeftCount = routeArgs['itemLeftCount'];
    return Expanded(
      child: Container(
        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _isWeb && !ResponsiveLayout.isSmallScreen(context)?ColorCodes.whiteColor:Color(0xffF1F1F1),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _isLoading
                  ? Container(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                  ),
                ),
              )
                  :
              // (_isWeb && !ResponsiveLayout.isSmallScreen(context))
              //     ? bodyweb()
              //     :
              viewOrder(),
              SizedBox(height: 40,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(address: _address/*prefs.getString("restaurant_address")*/),
            ],
          ),
        ),
      ),
    );
  }
vieworderweb(){
  queryData = MediaQuery.of(context);
  wid= queryData.size.width;
  maxwid=wid*0.90;
  double total;
  if(orderitemData.vieworder[0].itemodelcharge != "0"){
    total= double.parse(orderitemData.vieworder[0].itemoactualamount) +
        double.parse(orderitemData.vieworder[0].itemodelcharge) - orderitemData.vieworder[0].wallet
        - double.parse(orderitemData.vieworder[0].totalDiscount);
  }
  else{
    total= double.parse(orderitemData.vieworder[0].itemoactualamount) - (orderitemData.vieworder[0].wallet + double.parse(orderitemData.vieworder[0].totalDiscount)) ;
  }


  if(orderitemData.vieworder[0].ostatus=="CANCELLED"){
    orderstatus=translate('forconvience.CANCELLED');
  }
  else if(orderitemData.vieworder[0].ostatus=="COMPLETED"){
    orderstatus=translate('forconvience.COMPLETED');
  }

  else if(orderitemData.vieworder[0].ostatus=="DELIVERED"){
    orderstatus=translate('forconvience.DELIVERED');
  }

  else if(orderitemData.vieworder[0].ostatus=="DISPATCHED"){
    orderstatus=translate('forconvience.DISPATCHED');
  }
  else if(orderitemData.vieworder[0].ostatus=="PROCESSING"){
    orderstatus=translate('forconvience.PROCESSING');
  }
  else if(orderitemData.vieworder[0].ostatus=="PICK"){
    orderstatus="PICK";//translate('forconvience.DISPATCHED');
  }
  else if(orderitemData.vieworder[0].ostatus=="RECEIVED"){
    orderstatus=translate('forconvience.RECEIVED');
  }
  else if(orderitemData.vieworder[0].ostatus=="READY"){
    orderstatus="READY";//translate('forconvience.DISPATCHED');
  }
  else if(orderitemData.vieworder[0].ostatus=="RESCHEDULE"){
    orderstatus=translate('forconvience.RESCHEDULE');
  }
  else if(orderitemData.vieworder[0].ostatus=="ONWAY"){
    orderstatus=translate('forconvience.ONWAY');
  }
  else if(orderitemData.vieworder[0].ostatus=="FAILED"){
    orderstatus=translate('forconvience.FAILED');
  }
  if(orderitemData.vieworder[0].opaytype == "cod"){
    ordertype=translate('forconvience.cod');
  }
  else  if(orderitemData.vieworder[0].opaytype == "sod"){
    ordertype=translate('forconvience.Sod');
  }
  else  if(orderitemData.vieworder[0].opaytype == "wallet"){
    ordertype=translate('bottomnavigation.wallet');
  }
  else  {
    ordertype=translate('forconvience.online');
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Flexible(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width/2 ,//- 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Delivery Slot'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0),
              child: Container(
                width: MediaQuery.of(context).size.width/2,// - 20,
                decoration: BoxDecoration(color: Theme.of(context).buttonColor,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(width: 0.5, color: ColorCodes.borderColor,//Color(0xff4B4B4B)
                  ),),
                padding: EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(translate('forconvience.Ordered on')+"  : " + orderitemData.vieworder[0].odate),
                      SizedBox(
                        height: 10,
                      ),
                      Text(translate('forconvience.Delivery on')+" : " + orderitemData.vieworder[0].odeltime),
                      SizedBox(
                        height: 10,
                      ),
                      Text(translate('forconvience.Order Status')+" : " + orderstatus,//orderitemData.vieworder[0].ostatus
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Container(
              width: MediaQuery.of(context).size.width/2 ,//- 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Address'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0),
              child: Container(
                width: MediaQuery.of(context).size.width/2,// - 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonColor,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(width: 0.5, color: ColorCodes.borderColor,//Color(0xff4B4B4B)
                  ),
                 // color: Colors.white,
  ),
                padding: EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal:25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderitemData.vieworder[0].customerName,
                        style: TextStyle(color: ColorCodes.blackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        orderitemData.vieworder[0].oaddress,
                        style: TextStyle(color: Color(0xff6A6A6A)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        phone,
                        style: TextStyle(color: Color(0xff6A6A6A)),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      //Spacer(),
      Flexible(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:25.0),
            child: Column(
            children: [

               Container(
    width: MediaQuery.of(context).size.width/2,// - 20,
    height: 50,

    alignment: Alignment.centerLeft,
    child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:25.0),
            child: Text(translate('forconvience.Payment Details'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  ),
                Container(
    width: MediaQuery.of(context).size.width/2,// - 20,
    decoration: BoxDecoration(color: Theme.of(context).buttonColor,
      borderRadius: BorderRadius.circular(4.0),
      border: Border.all(width: 0.5, color: ColorCodes.borderColor,//Color(0xff4B4B4B)
      ),),
    padding: EdgeInsets.all(15),
    child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      translate('forconvience.Ordere Id') +" : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(
                      orderitemData.vieworder[0].itemorderid,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      translate('forconvience.Invoice No')+" : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(
                      orderitemData.vieworder[0].invoiceno,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      translate('forconvience.Payment Options')+ " : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(
                      ordertype, //orderitemData.vieworder[0].opaytype,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      translate('forconvience.Ordered Items')+" : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(
                      orderitemData.vieworder[0].itemsCount +" "+translate('bottomnavigation.items'), //" items",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      translate('forconvience.Sub-Total')+ " : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(

                      " " +
                          orderitemData.vieworder[0].itemoactualamount+ _currencyFormat ,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
                /* SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                translate('bottomnavigation.wallet') : ",
                                style: TextStyle(color: Color(0xff6A6A6A)),
                              ),
                              Spacer(),
                              Text(

                                " " +
                                    orderitemData.vieworder[0].itemototalamount+ _currencyFormat ,
                                style: TextStyle(color: Color(0xff6A6A6A)),
                              ),
                            ],
                          ),*/
                if(orderitemData.vieworder[0].wallet != 0.0 )
                  SizedBox(
                    height: 10,
                  ),
                if(orderitemData.vieworder[0].wallet != 0.0 )
                  Row(
                    children: [
                      Text(
                        translate('bottomnavigation.wallet') +" : ",
                        style: TextStyle(color: Color(0xff6A6A6A)),
                      ),
                      Spacer(),
                      Text(

                        "- "+(orderitemData.vieworder[0].wallet).toStringAsFixed(2)+""+_currencyFormat,

                        style: TextStyle(color: Color(0xff6A6A6A)),
                      ),
                    ],
                  ),
                if(double.parse(orderitemData.vieworder[0].totalDiscount) != 0 )
                  SizedBox(
                    height: 10,
                  ),
                if(double.parse(orderitemData.vieworder[0].totalDiscount) != 0 )
                  Row(
                    children: [
                      Text(
                        translate('forconvience.Discount')+" ", //"Discount " ,
                        style: TextStyle(color: Color(0xff6A6A6A)),
                      ),
                      Spacer(),
                      Text("-"+ " "+


                          orderitemData.vieworder[0].totalDiscount+"" + _currencyFormat ,
                        style: TextStyle(color: Color(0xff6A6A6A)),
                      ),

                    ],
                  ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      translate('forconvience.Delivery Charges') +  " : ",
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    Spacer(),
                    Text(

                      "+ " +
                          orderitemData.vieworder[0].itemodelcharge+ _currencyFormat ,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                  ],
                ),
              ],
            ),
    ),
  ),
                Container(
    width: MediaQuery.of(context).size.width/2,// - 20,
    alignment: Alignment.centerLeft,
    decoration: BoxDecoration(color: Color(0xffc9f8d3)),
    padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
    child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:25.0),
            child: Row(
              children: [
                Text(
                  translate('forconvience.Total'),//"Total",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  " " + total.toStringAsFixed(2)+ _currencyFormat ,/*orderitemData.vieworder[0].itemototalamount,*/
                  style: TextStyle(
                      color:ColorCodes.totalColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
    ),
  ),
                Container(
                    width: MediaQuery.of(context).size.width/2,// - 20,
                    height: 50,
                    alignment: Alignment.centerLeft,
                    child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:25.0),
                    child: Text(translate('forconvience.Item Details '),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
        ),
        Container(
            width: MediaQuery.of(context).size.width,// - 20,
            decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(width: 0.5, color: ColorCodes.borderColor),
                  color: Colors.white,
        ),
      //  padding: EdgeInsets.only(left:15,right: 15),
      child: new ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: ColorCodes.borderColor,

            /* indent: 250,
                      endIndent: 250,*/
          ),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: int.parse(orderitemData.vieworder[0].itemsCount),
          itemBuilder: (_, i) => Column(
            children: [
              OrderhistoryDisplay(
                orderitemData.vieworder1[i].itemname,
                orderitemData.vieworder1[i].varname,
                orderitemData.vieworder1[i].price,
                orderitemData.vieworder1[i].qty,
                orderitemData.vieworder1[i].subtotal,
                orderitemData.vieworder1[i].itemImage,
              ),
              //  Divider(),
              /*   SizedBox(
                          height: 10,
                        )*/
            ],
          ),
      ),
      //),
  ),
  SizedBox(
    height: 10.0,
  ),
  _showReturn?GestureDetector(
    onTap: () {
        _dialogforReturn(context);
    },
    child: Container(
        height:50 ,
        width: MediaQuery.of(context).size.width - 20,
        color: Theme.of(context).primaryColor,
        child: Center(child: Text('Return or Exchange',style: TextStyle(color:ColorCodes.whiteColor))),
    ),
  ):SizedBox.shrink(),
],

            ),
          ),
        ),
      )
         ],
  );



}

  Widget viewOrder() {

    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    double total;
    if(orderitemData.vieworder[0].itemodelcharge != "0"){
      total= double.parse(orderitemData.vieworder[0].itemoactualamount) +
          double.parse(orderitemData.vieworder[0].itemodelcharge) - orderitemData.vieworder[0].wallet - orderitemData.vieworder[0].loyalty
          - double.parse(orderitemData.vieworder[0].totalDiscount);
    }
    else{
      total= double.parse(orderitemData.vieworder[0].itemoactualamount) - (orderitemData.vieworder[0].wallet  + double.parse(orderitemData.vieworder[0].totalDiscount)) - orderitemData.vieworder[0].loyalty ;
    }


    if(orderitemData.vieworder[0].ostatus=="CANCELLED"){
      orderstatus=translate('forconvience.CANCELLED');
    }
    else if(orderitemData.vieworder[0].ostatus=="COMPLETED"){
      orderstatus=translate('forconvience.COMPLETED');
    }

    else if(orderitemData.vieworder[0].ostatus=="DELIVERED"){
      orderstatus=translate('forconvience.DELIVERED');
    }

    else if(orderitemData.vieworder[0].ostatus=="DISPATCHED"){
      orderstatus=translate('forconvience.DISPATCHED');
    }
    else if(orderitemData.vieworder[0].ostatus=="PROCESSING"){
      orderstatus=translate('forconvience.PROCESSING');
    }
    else if(orderitemData.vieworder[0].ostatus=="PICK"){
      orderstatus="PICK";//translate('forconvience.DISPATCHED');
    }
    else if(orderitemData.vieworder[0].ostatus=="RECEIVED"){
      orderstatus=translate('forconvience.RECEIVED');
    }
    else if(orderitemData.vieworder[0].ostatus=="READY"){
      orderstatus="READY";//translate('forconvience.DISPATCHED');
    }
    else if(orderitemData.vieworder[0].ostatus=="RESCHEDULE"){
      orderstatus=translate('forconvience.RESCHEDULE');
    }
    else if(orderitemData.vieworder[0].ostatus=="ONWAY"){
      orderstatus=translate('forconvience.ONWAY');
    }
    else if(orderitemData.vieworder[0].ostatus=="FAILED"){
      orderstatus=translate('forconvience.FAILED');
    }
    if(orderitemData.vieworder[0].opaytype == "cod"){
      ordertype=translate('forconvience.cod');
    }
    else  if(orderitemData.vieworder[0].opaytype == "sod"){
      ordertype=translate('forconvience.Sod');
    }
    else  if(orderitemData.vieworder[0].opaytype == "wallet"){
      ordertype=translate('bottomnavigation.wallet');
    }
    else  {
      ordertype=translate('forconvience.online');
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width ,//- 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Delivery Slot'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              decoration: BoxDecoration(color: Theme.of(context).buttonColor),
              padding: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(translate('forconvience.Ordered on')+"  : " + orderitemData.vieworder[0].odate),
                    SizedBox(
                      height: 10,
                    ),
                    Text(translate('forconvience.Delivery on')+" : " + orderitemData.vieworder[0].odeltime),
                    SizedBox(
                      height: 10,
                    ),
                    Text(translate('forconvience.Order Status')+" : " + orderstatus,//orderitemData.vieworder[0].ostatus
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width ,//- 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Address'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              decoration: BoxDecoration(color: Theme.of(context).buttonColor),
              padding: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderitemData.vieworder[0].customerName,
                      style: TextStyle(color: ColorCodes.blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      orderitemData.vieworder[0].oaddress,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      phone,
                      style: TextStyle(color: Color(0xff6A6A6A)),
                    )
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Payment Details'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              decoration: BoxDecoration(color: Theme.of(context).buttonColor),
              padding: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Ordere Id') +" : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(
                          orderitemData.vieworder[0].itemorderid,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Invoice No')+" : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(
                          orderitemData.vieworder[0].invoiceno,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Payment Options')+ " : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(
                         ordertype, //orderitemData.vieworder[0].opaytype,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Ordered Items')+" : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(
                          orderitemData.vieworder[0].itemsCount +" "+translate('bottomnavigation.items'), //" items",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Sub-Total')+ " : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(

                              " " +
                              orderitemData.vieworder[0].itemoactualamount+ _currencyFormat ,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                   /* SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('bottomnavigation.wallet') : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(

                          " " +
                              orderitemData.vieworder[0].itemototalamount+ _currencyFormat ,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),*/

                    if(orderitemData.vieworder[0].loyalty != 0.0 )
                      SizedBox(
                        height: 10,
                      ),
                    if(orderitemData.vieworder[0].loyalty != 0.0 )
                      Row(
                        children: [
                          Text(
                            translate('appdrawer.loyalty'),
                            style: TextStyle(color: Color(0xff6A6A6A),),
                          ),
                          Spacer(),
                          Text(

                            "- "+(orderitemData.vieworder[0].loyalty).toStringAsFixed(2)+""+_currencyFormat,

                            style: TextStyle(color: Color(0xff6A6A6A)),
                          ),
                        ],
                      ),
                    if(orderitemData.vieworder[0].wallet != 0.0 )
                      SizedBox(
                        height: 10,
                      ),
                    if(orderitemData.vieworder[0].wallet != 0.0 )
                      Row(
                        children: [
                          Text(
                            translate('bottomnavigation.wallet') +" : ",
                            style: TextStyle(color: Color(0xff6A6A6A)),
                          ),
                          Spacer(),
                          Text(

                               "- "+(orderitemData.vieworder[0].wallet).toStringAsFixed(2)+""+_currencyFormat,

    style: TextStyle(color: Color(0xff6A6A6A)),
                          ),
                        ],
                      ),
                    if(double.parse(orderitemData.vieworder[0].totalDiscount) != 0 )
                      SizedBox(
                        height: 10,
                      ),
                    if(double.parse(orderitemData.vieworder[0].totalDiscount) != 0 )
                      Row(
                        children: [
                          Text(
                        translate('forconvience.Discount')+" ", //"Discount " ,
                            style: TextStyle(color: Color(0xff6A6A6A)),
                          ),
                          Spacer(),
                          Text("-"+ " "+


                              orderitemData.vieworder[0].totalDiscount+"" + _currencyFormat ,
    style: TextStyle(color: Color(0xff6A6A6A)),
                          ),

                        ],
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          translate('forconvience.Delivery Charges') +  " : ",
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                        Spacer(),
                        Text(

                              "+ " +
                              orderitemData.vieworder[0].itemodelcharge+ _currencyFormat ,
                          style: TextStyle(color: Color(0xff6A6A6A)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(color: Color(0xffc9f8d3)),
              padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Row(
                  children: [
                    Text(
                    translate('forconvience.Total'),//"Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    Text(
                     " " + total.toStringAsFixed(2)+ _currencyFormat ,/*orderitemData.vieworder[0].itemototalamount,*/
                      style: TextStyle(
                        color:ColorCodes.totalColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,// - 20,
              height: 50,
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal:25.0),
                child: Text(translate('forconvience.Item Details '),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:25.0),
              child: Container(
                width: MediaQuery.of(context).size.width,// - 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(width: 0.5, color: ColorCodes.borderColor),
                  color: Colors.white,
                ),
              //  padding: EdgeInsets.only(left:15,right: 15),
                child: new ListView.separated(
                  separatorBuilder: (context, index) => Divider(
                    color: ColorCodes.borderColor,
                   /* indent: 250,
                    endIndent: 250,*/
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: int.parse(orderitemData.vieworder[0].itemsCount),
                  itemBuilder: (_, i) => Column(
                    children: [
                      OrderhistoryDisplay(
                        orderitemData.vieworder1[i].itemname,
                        orderitemData.vieworder1[i].varname,
                        orderitemData.vieworder1[i].price,
                        orderitemData.vieworder1[i].qty,
                        orderitemData.vieworder1[i].subtotal,
                        orderitemData.vieworder1[i].itemImage,
                      ),
                 //  Divider(),
                   /*   SizedBox(
                        height: 10,
                      )*/
                    ],
                  ),
                ),
                //),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            _showReturn?GestureDetector(
              onTap: () {
                _dialogforReturn(context);
              },
              child: Container(
                height:50 ,
                width: MediaQuery.of(context).size.width - 20,
                color: Theme.of(context).primaryColor,
                child: Center(child: Text('Return or Exchange',style: TextStyle(color:ColorCodes.whiteColor))),
              ),
            ):SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void launchWhatsApp() async {
    String phone = /*"+212652-655363"*/prefs.getString("secondary_mobile");
    String url() {
      if (Platform.isIOS) {
        return "whatsapp://wa.me/$phone/?text=${Uri.parse(translate('forconvience.hello'))}";
      } else {
        return "whatsapp://send?phone=$phone&text=${Uri.parse(translate('forconvience.hello'))}";
        const url = "https://wa.me/?text=YourTextHere";

      }
    }

    if (await canLaunch(url())) {
      await launch(url());
    } else {
      throw 'Could not launch ${url()}';
    }
  }


  gradientappbarmobile() {
    return AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,size: 18, color: ColorCodes.backbutton,),
          onPressed: () {
            if (fromscreen == "pushNotification") {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home-screen', (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pop();
            }
          }
              //Navigator.of(context).pop()
              /*Navigator.pushNamedAndRemoveUntil(
              context, MyorderScreen.routeName, (route) => false)*/),
      title: Text(translate('forconvience.Orders Details'),style: TextStyle(fontSize:18,color: ColorCodes.backbutton,fontWeight: FontWeight.bold)),
      actions: [
        GestureDetector(
          onTap: () {
            launchWhatsApp();
            //FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", "Hello");
            /*Navigator.of(context).pushNamed(
              HelpScreen.routeName,
            );*/
          },
          child: Container(
            height: 30,
            width: 100,
            child: Center(
                child: Text(
                  translate('forconvience.HELP'),

                  style: TextStyle(fontSize: 15,
                      color: ColorCodes.blackColor,
                      fontWeight: FontWeight.bold),
                )),
          ),
        )
      ],

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
}
