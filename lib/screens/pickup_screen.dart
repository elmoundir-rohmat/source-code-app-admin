import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../data/calculations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/branditems.dart';
import '../providers/deliveryslotitems.dart';
import '../screens/payment_screen.dart';
import '../constants/ColorCodes.dart';
import 'cart_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class PickupScreen extends StatefulWidget {
  static const routeName = '/pickup-screen';

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  bool _isLoading = true;
  SharedPreferences _prefs;
  var pickuplocItem;
  var pickupTime;
  int _groupValue = 0;
  DateTime pickedDate;
  String selectTime = "";
  String selectDate = "";
  var times;
  bool _checkStoreLoc = false;
  bool _isPickupSlots = false;
  String _currencyFormat = "";
  int minorderamount = 0;
  int deliverycharge = 0;
  double _cartTotal = 0.0;
  int z=0;
  bool _isWeb = false;
  var _message = TextEditingController();
  bool iphonex = false;

  @override
  void initState() {
    pickedDate = DateTime.now();
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
      _prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_prefs.getString("membership") == "1") {
          _cartTotal = Calculations.totalMember;
        } else {
          _cartTotal = Calculations.total;
        }
      });

      _currencyFormat = _prefs.getString("currency_format");
      minorderamount = int.parse(_prefs.getString("min_order_amount"));
      deliverycharge = int.parse(_prefs.getString("delivery_charge"));

      Provider.of<BrandItemsList>(context,listen: false).fetchPickupfromStore().then((_) {
        pickuplocItem = Provider.of<BrandItemsList>(context, listen: false);
        if (pickuplocItem.itemspickuploc.length > 0) {
          setState(() {
            _checkStoreLoc = true;
            Provider.of<DeliveryslotitemsList>(context,listen: false)
                .fetchPickupslots(pickuplocItem.itemspickuploc[0].id)
                .then((_) {
              pickupTime =
                  Provider.of<DeliveryslotitemsList>(context, listen: false);
              if (pickupTime.itemsPickup.length > 0) {
                _isPickupSlots = true;
                selectTime = pickupTime.itemsPickup[0].time;
                selectDate = pickupTime.itemsPickup[0].date;
                _isLoading = false;
              } else {
                _isLoading = false;
                _isPickupSlots = false;
              }
            });
          });
        } else {
          setState(() {
            _checkStoreLoc = false;
            _isLoading = false;
          });
        }
      });

      Provider.of<BrandItemsList>(context,listen: false).fetchWalletBalance();
      Provider.of<BrandItemsList>(context,listen: false).fetchPaymentMode();
    });
    super.initState();
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

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }

  Iterable<TimeOfDay> getTimes(
      TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;

    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour ||
        (hour == endTime.hour && minute <= endTime.minute));
  }

  changeStore(String storeId) {
    _dialogforProcessing();
    Provider.of<DeliveryslotitemsList>(context,listen: false)
        .fetchPickupslots(storeId)
        .then((_) {
      setState(() {
        pickupTime = Provider.of<DeliveryslotitemsList>(context, listen: false);
        if (pickupTime.itemsPickup.length > 0) {
          _isPickupSlots = true;
          selectTime = pickupTime.itemsPickup[0].time;
          selectDate = pickupTime.itemsPickup[0].date;
        } else {
          _isPickupSlots = false;
        }
      });
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    _buildBottomNavigationBar() {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            !_checkStoreLoc
                ? GestureDetector(
                    onTap: () => {
                      Fluttertoast.showToast(
                          msg: "currently there is no store address available"),
                    },
                    child: Row(
                      children: [
                        Container(
                          color:Colors.grey,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 40 / 100,
                          child: Center(
                            child: Text(
                              'Total: '  + " " + _cartTotal.toStringAsFixed(2)+   _currencyFormat,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                          ),
                        Container(
                         // padding: EdgeInsets.symmetric(horizontal: 30),
                          color: Colors.grey,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 60 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center ,
                          children: [
                              Text(
                                'CONFIRM ORDER',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : _isPickupSlots
                    ? GestureDetector(
                        onTap: () {
                          _prefs.setString("isPickup", "yes");
                          _prefs.setString('fixtime', selectTime);
                          _prefs.setString("fixdate", selectDate);
                          _prefs.setString(
                              "addressId",
                              pickuplocItem.itemspickuploc[_groupValue].id
                                  .toString());
                          Navigator.of(context)
                              .pushNamed(PaymentScreen.routeName, arguments: {
                            'minimumOrderAmountNoraml': "0",
                            'deliveryChargeNormal': "0",
                            'minimumOrderAmountPrime': "0",
                            'deliveryChargePrime': "0",
                            'minimumOrderAmountExpress': "0",
                            'deliveryChargeExpress': "0",
                            'deliveryType': "pickup",
                            'note': _message.text,
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              color:Theme.of(context).primaryColor,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 40 / 100,
                              child: Center(
                                child: Text(
                                  'Total: '  + " " + _cartTotal.toStringAsFixed(2)+   _currencyFormat,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.symmetric(horizontal: 30),
                              color:Theme.of(context).primaryColor,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 60 / 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center ,
                                children: [
                                  Text(
                                    'CONFIRM ORDER',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),

                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => {
                          Fluttertoast.showToast(
                              msg:
                                  "currently there is no slots available for this address"),
                        },
                        child: Row(
                          children: [
                            Container(
                              color:Colors.grey,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 40 / 100,
                              child: Center(
                                child: Text(
                                  'Total: ' + " " + _cartTotal.toStringAsFixed(2) +   _currencyFormat,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.symmetric(horizontal: 30),
                              color: Colors.grey,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 60 / 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center ,
                                children: [
                                  Text(
                                    'CONFIRM ORDER',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
          ],
        ),
      );
    }

    Future<void> openMap(double latitude, double longitude) async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }

    return Scaffold(
      appBar: ResponsiveLayout.isSmallScreen(context)
          ?gradientappbarmobile():null,
      backgroundColor: Colors.white,
      body: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?CartScreen():_isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  !_checkStoreLoc
                      ? Center(
                          child: Container(
                            width:MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(
                                left: 10.0, top: 30.0, bottom: 10.0),
                            child: Text(
                              "Currently there is no store address available",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        )
                      : Container(
                        width:MediaQuery.of(context).size.width,
                          margin: EdgeInsets.only(
                              left: 10.0, top: 30.0, bottom: 10.0),
                          child: Text(
                            "Select Store for Pickup",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                   Container(
                     width:MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(
                          width: 1.0,
                          color: ColorCodes.lightGreyWebColor,
                        ),
                      )),
                      child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, bottom: 10),
                              child: SizedBox(
                                child: new ListView.separated(
                                  separatorBuilder: (context, index) => Divider(
                                    color: ColorCodes.lightGreyColor,
                                  ),
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: pickuplocItem.itemspickuploc.length,
                                  itemBuilder: (_, i) => GestureDetector(
                                    onTap: () {
                                      if (_groupValue != i)
                                        setState(() {
                                          _groupValue = i;
                                          changeStore(pickuplocItem.itemspickuploc[i].id);
                                        });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                        ),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.only(right: 0.0),
                                          title:  Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                  height: 20.0,
                                                  child:
                                                  _myRadioButton(
                                                    value: i,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        _groupValue = newValue;
                                                      });
                                                     // print("aaaaaaa"+z.toString());
                                                      //print("aaaaaaaaaa"+ _groupValue.toString());
                                                      changeStore(pickuplocItem.itemspickuploc[i].id);
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 15.0,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                   /* width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        70 /
                                                        100,*/
                                                    //color: Theme.of(context).backgroundColor,
                                                    decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                    ),
                                                    margin: EdgeInsets.only(bottom: 10.0),
                                                    padding: EdgeInsets.all(10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          pickuplocItem
                                                              .itemspickuploc[i].name,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight.w900),
                                                        ),
                                                        SizedBox(
                                                          height: 2.0,
                                                        ),
                                                        if (pickuplocItem
                                                                .itemspickuploc[i].contact
                                                                .toString() ==
                                                            "")
                                                          Text(
                                                            pickuplocItem
                                                                .itemspickuploc[i]
                                                                .address,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.w300,
                                                                fontSize: 12.0),
                                                          )
                                                        else
                                                          Text(
                                                            pickuplocItem
                                                                    .itemspickuploc[i]
                                                                    .address +
                                                                "\n" +
                                                                "Ph: " +
                                                                pickuplocItem
                                                                    .itemspickuploc[i]
                                                                    .contact,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.w300,
                                                                fontSize: 12.0),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                             /*   SizedBox(
                                                  width: 5.0,
                                                ),*/
                                                Container(
                                                  width: 35,
                                                  height: 35,
                                                  child: FlatButton(
                                                    padding: EdgeInsets.all(0),
                                                    color: Colors.white,
                                                    disabledColor: Theme.of(context)
                                                        .focusColor
                                                        .withOpacity(0.4),
                                                    //shape: ShapeBorder(),
                                                    child: Icon(
                                                      Icons.near_me,
                                                      color: Theme.of(context)
                                                          .accentColor
                                                          .withOpacity(0.9),
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      openMap(
                                                          pickuplocItem
                                                              .itemspickuploc[i]
                                                              .latitude,
                                                          pickuplocItem
                                                              .itemspickuploc[i]
                                                              .longitude);
                                                    },
                                                    //color: Theme.of(context).accentColor.withOpacity(0.9),
                                                    shape: StadiumBorder(
                                                      side: BorderSide(
                                                        color: Color(0xff707070),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ),
                                      ),
                                    
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ),
                  Container(
                    width:MediaQuery.of(context).size.width,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.only(left: 10.0),
                      leading: Icon(Icons.list_alt_outlined,
                          color: ColorCodes.lightGreyColor),
                      title: Transform(
                        transform: Matrix4.translationValues(-16, 0.0, 0.0),
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration.collapsed(
                              hintText: "Any request? We promise to pass it on",
                              hintStyle: TextStyle(fontSize: 12.0),
                              //contentPadding: EdgeInsets.all(16),
                              //border: OutlineInputBorder(),
                              fillColor: Color(0xffD5D5D5)),
                          //minLines: 3,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  _checkStoreLoc && _isPickupSlots
                      ? Container(
                          margin: EdgeInsets.only(left: 10.0, top: 25.0),
                          child: Text(
                            "Select Your Time Slot",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  _isPickupSlots && pickupTime.itemsPickup.length > 0
                      //Container()
                      ? Container(
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      'Date: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 15.0,
                                        color: ColorCodes.blackColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      pickupTime.itemsPickup[0].date,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w300,
                                          fontSize: 15.0,
                                          color: Color(0xff9B9B9B)),
                                    ),
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 40),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Text('Select your pickup slot', style: TextStyle(
                              //       fontSize: 20,
                              //       fontWeight: FontWeight.w700,
                              //     ),),
                              //   ],
                              // ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 35.0,
                                  decoration: BoxDecoration(
                                      color: ColorCodes.lightGreyWebColor,
                                      borderRadius: BorderRadius.circular(3.0),
                                      border: Border(
                                        top: BorderSide(
                                          width: 1.0,
                                          color: ColorCodes.lightGreyWebColor,
                                        ),
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color: ColorCodes.lightGreyWebColor,
                                        ),
                                        left: BorderSide(
                                          width: 1.0,
                                          color: ColorCodes.lightGreyWebColor,
                                        ),
                                        right: BorderSide(
                                          width: 1.0,
                                          color: ColorCodes.lightGreyWebColor,
                                        ),
                                      )),
                                  child: PopupMenuButton(
                                    onSelected: (selectedValue) {
                                      setState(() {
                                        selectTime = selectedValue;
                                        selectDate =
                                            pickupTime.itemsPickup[0].date;
                                      });
                                    },
                                    padding: EdgeInsets.all(0.0),
                                    icon: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            selectTime,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15.0,
                                                color: ColorCodes.greyColor),
                                          ),
                                          Icon(
                                            Icons.access_time,
                                            color: ColorCodes
                                                .mediumBlueColor, /*size: 5.0,*/
                                          ),
                                        ],
                                      ),
                                    ),
                                    itemBuilder: (_) => <PopupMenuItem<Widget>>[
                                      for (int j = 0;
                                          j < pickupTime.itemsPickup.length;
                                          j++)
                                        new PopupMenuItem<Widget>(
                                          // value:
                                          //     pickupTime.itemsPickup[j].time,

                                          value: Row(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Text(pickupTime
                                                    .itemsPickup[j].time),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                              pickupTime.itemsPickup[j].time),
                                          //   ),
                                          //   ],
                                          // ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _checkStoreLoc
                          ? Center(
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: 10.0, top: 30.0, bottom: 10.0),
                                child: Text(
                                  "Currently there is no slots available for this address",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          : Container(),
                          if(_isWeb&&!ResponsiveLayout.isLargeScreen(context))
                          Container(
               width: MediaQuery.of(context).size.width,
              height: 50.0,
             child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              !_checkStoreLoc
                ? GestureDetector(
                    onTap: () => {
                      Fluttertoast.showToast(
                          msg: "currently there is no store address available"),
                    },
                    child: Row(
                      children: [
                        Container(
                          color:Colors.grey,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 40 / 100,
                          child: Center(
                            child: Text(
                              'Total: '  + " " + _cartTotal.toStringAsFixed(2)+   _currencyFormat,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                          ),
                        Container(
                         // padding: EdgeInsets.symmetric(horizontal: 30),
                          color: Colors.grey,
                          height: 50,
                          width: MediaQuery.of(context).size.width * 60 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center ,
                          children: [
                              Text(
                                'CONFIRM ORDER',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.arrow_right,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : _isPickupSlots
                    ? GestureDetector(
                        onTap: () {
                          _prefs.setString("isPickup", "yes");
                          _prefs.setString('fixtime', selectTime);
                          _prefs.setString("fixdate", selectDate);
                          _prefs.setString(
                              "addressId",
                              pickuplocItem.itemspickuploc[_groupValue].id
                                  .toString());
                          Navigator.of(context)
                              .pushNamed(PaymentScreen.routeName, arguments: {
                            'minimumOrderAmountNoraml': "0",
                            'deliveryChargeNormal': "0",
                            'minimumOrderAmountPrime': "0",
                            'deliveryChargePrime': "0",
                            'minimumOrderAmountExpress': "0",
                            'deliveryChargeExpress': "0",
                            'deliveryType': "pickup",
                            'note': _message.text,
                          });
                        },
                        child: Row(
                          children: [
                            Container(
                              color:Theme.of(context).primaryColor,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 40 / 100,
                              child: Center(
                                child: Text(
                                  'Total: ' + " " + _cartTotal.toStringAsFixed(2)+ _currencyFormat ,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.symmetric(horizontal: 30),
                              color:Theme.of(context).primaryColor,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 60 / 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center ,
                                children: [
                                  Text(
                                    'CONFIRM ORDER',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),

                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => {
                          Fluttertoast.showToast(
                              msg:
                                  "currently there is no slots available for this address"),
                        },
                        child: Row(
                          children: [
                            Container(
                              color:Colors.grey,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 40 / 100,
                              child: Center(
                                child: Text(
                                  'Total: '  + " " + _cartTotal.toStringAsFixed(2)+   _currencyFormat,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.symmetric(horizontal: 30),
                              color: Colors.grey,
                              height: 50,
                              width: MediaQuery.of(context).size.width * 60 / 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center ,
                                children: [
                                  Text(
                                    'CONFIRM ORDER',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
          ],
        ),
      ),
                  if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                    Footer(address: _prefs.getString("restaurant_address")),
                ],
              ),
            ),
      bottomNavigationBar: _isWeb
          ? SizedBox.shrink() : Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child:_buildBottomNavigationBar(),

      ),
    );
  }
  gradientappbarmobile() {
      return AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'Checkout',
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ])),
        ),
      );
    }
}
