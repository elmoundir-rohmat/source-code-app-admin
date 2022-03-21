import 'dart:convert';
import 'dart:io';

import 'package:fellahi_e/utils/ResponsiveLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share/share.dart';
import '../data/calculations.dart';
import '../main.dart';
import '../providers/branditems.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../constants/ColorCodes.dart';
import '../constants/IConstants.dart';
import '../data/hiveDB.dart';
import '../screens/map_screen.dart';
import '../widgets/badge.dart';
import '../providers/addressitems.dart';
import '../providers/deliveryslotitems.dart';
import '../screens/mobile_authentication.dart';
import '../screens/address_screen.dart';
import '../screens/payment_screen.dart';
import '../constants/images.dart';
import 'cart_screen.dart';
import 'searchitem_screen.dart';
import 'package:http/http.dart' as http;
import '../screens/example_screen.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ConfirmorderScreen extends StatefulWidget {
  static const routeName = '/confirmorder-screen';

  @override
  _ConfirmorderScreenState createState() => _ConfirmorderScreenState();
}

class _ConfirmorderScreenState extends State<ConfirmorderScreen>
    with SingleTickerProviderStateMixin {
  var addressitemsData;
  var deliveryslotData;
  var delChargeData;
  var timeslotsData;
  var boxwidth = 1.0;
  SharedPreferences prefs;
  var totlamount;
  var mobilenum;
  var width = 1.0;
  var addtype;
  var address;
  bool _showAppbar = true;
  IconData addressicon;
  var day, date, time = "10 AM - 1 PM";
  var _checkaddress = false;
  var currency_format = "";
  var _loading = true;
  bool _loadingSlots = true;
  bool _loadingDelCharge = true;
  var timeslotsindex = "0";
  var _checkslots = false;
  bool _slotsLoading = false;
  bool _checkmembership = false;
  var _message = TextEditingController();
  int _radioValue = 1;
  bool _isLoading = true;
  int index = 0;
  bool _isChangeAddress = false;

  String _minimumOrderAmountNoraml = "0.0";
  String _deliveryChargeNormal = "0.0";
  String _minimumOrderAmountPrime = "0.0";
  String _deliveryChargePrime = "0.0";
  String _minimumOrderAmountExpress = "0.0";
  String _deliveryChargeExpress = "0.0";
  String _deliveryDurationExpress = "0.0 ";
  String deliverlocation = "";
  String value;
  String mobile="";
  Box<Product> productBox;
  List checkBoxdata = [];
  List titlecolor = [];
  List iconcolor = [];
  int _index = 0;
  int _count;
String otp="";
  String prev;
 // final String defaultLocale = Platform.localeName;
  TabController _tabController;
  String localeName = "ar";
  bool iphonex = false;

  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    // _message.text = "";
    //tabbar controller
    _tabController = new TabController(length: 2, vsync: this);

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      try {
        if (Platform.isIOS) {
          setState(() {
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        }
      } catch (e) {
      }
      setState(() {
        currency_format = prefs.getString("currency_format");
        deliverlocation = prefs.getString("deliverylocation");
        /*mobile=prefs.getString('mobile');
        debugPrint("mobileinit"+mobile);*/
        prefs.setString('fixtime', "");
        prefs.setString("fixdate", "");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
        _isLoading = false;
      });


      Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
        setState(() {
          addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
          if (addressitemsData.items.length > 0) {
            _checkaddress = true;
            checkLocation();
          } else {
            /*_checkaddress = false;
            _loading = false;*/
//Navigator.of(context).pop();
              debugPrint("confirmorder address.......");
            Navigator.of(context).pushReplacementNamed(
                ExampleScreen.routeName,
                arguments: {
                  'addresstype': "new",
                  'addressid': "",
                  'delieveryLocation': "",
                  'latitude': "",
                  'longitude': "",
                  'branch': ""
                });
          }
        });
      });
      /*Provider.of<AddressItemsList>(context, listen: false).fetchAddress().then((_) {
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);
        if (addressitemsData.items.length > 0) {
          _checkaddress = true;
          addtype = addressitemsData
              .items[addressitemsData.items.length - 1].useraddtype;
          address = addressitemsData
              .items[addressitemsData.items.length - 1].useraddress;
          addressicon = addressitemsData
              .items[addressitemsData.items.length - 1].addressicon;
          prefs.setString("addressId",
              addressitemsData.items[addressitemsData.items.length - 1].userid);
          calldeliverslots(
              addressitemsData.items[addressitemsData.items.length - 1].userid);
          deliveryCharge(
              addressitemsData.items[addressitemsData.items.length - 1].userid);
        } else {
          _checkaddress = false;
        }
      });*/
      /*addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
      checkLocation();
      Provider.of<BrandItemsList>(context,listen: false).fetchWalletBalance();
      debugPrint("confirmorder init......");*/

      //Provider.of<BrandItemsList>(context, listen: false).fetchPaymentMode();

      /*initializeDateFormatting(localeName);

      weekDays(localeName);*/
    });


    super.initState();
  }

  static List<String> weekDays(String localeName) {
    DateFormat formatter = DateFormat(DateFormat.WEEKDAY, localeName);
    debugPrint("days"+formatter.format(DateTime.now()).toString());
    return [DateTime(2000, 1, 3, 1), DateTime(2000, 1, 4, 1), DateTime(2000, 1, 5, 1),
      DateTime(2000, 1, 6, 1), DateTime(2000, 1, 7, 1), DateTime(2000, 1, 8, 1),
      DateTime(2000, 1, 9, 1)].map((day) => formatter.format(day)).toList();
  }

  Future<void> checkLocation() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'check-location';
    addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "lat":
        addressitemsData.items[addressitemsData.items.length - 1].userlat,
        "long":
        addressitemsData.items[addressitemsData.items.length - 1].userlong,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "yes") {
        if (prefs.getString("branch") == responseJson['branch'].toString()) {
          final routeArgs =
          ModalRoute.of(context).settings.arguments as Map<String, String>;
          //final
          prev = routeArgs['prev'];
          if (prev == "address_screen") {
            _dialogforProcessing();
            cartCheck(
              prefs.getString("addressId"),
              addressitemsData.items[0].userid,
              addressitemsData
                  .items[0].useraddtype,
              addressitemsData
                  .items[0].useraddress,
              addressitemsData
                  .items[0].addressicon,
            );
          } else {
            if (addressitemsData.items.length > 0) {
              _checkaddress = true;
              addtype = addressitemsData
                  .items[0].useraddtype;
              address = addressitemsData
                  .items[0].useraddress;
              addressicon = addressitemsData
                  .items[0].addressicon;
              prefs.setString(
                  "addressId",
                  addressitemsData
                      .items[0].userid);
              calldeliverslots(addressitemsData
                  .items[0].userid);
              deliveryCharge(addressitemsData
                  .items[0].userid);
            } else {
              _checkaddress = false;
            }
          }
        } else {
          setState(() {
            _isChangeAddress = true;
            _loading = false;
            _slotsLoading = false;
          });
        }
      } else {
        setState(() {
          _isChangeAddress = true;
          _loading = false;
          _slotsLoading = false;
        });
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> calldeliverslots(String addressid) async {
    Provider.of<DeliveryslotitemsList>(context,listen: false)
        .fetchDeliveryslots(addressid)
        .then((_) {
      deliveryslotData = Provider.of<DeliveryslotitemsList>(context, listen: false);
      for(int i=0;i<deliveryslotData.items.length; i++){
        setState((){
          print("call deliver slot i ....."+i.toString());
          if(i==0){
            deliveryslotData.items[i].selectedColor=Color(0xFF45B343);
            deliveryslotData.items[i].borderColor=Color(0xFF45B343);
            deliveryslotData.items[i].textColor=ColorCodes.whiteColor;
            deliveryslotData.items[i].isSelect = true;
          }else{
            deliveryslotData.items[i].selectedColor=ColorCodes.whiteColor;
            deliveryslotData.items[i].borderColor=Color(0xffBEBEBE);
            deliveryslotData.items[i].textColor=ColorCodes.blackColor;
            deliveryslotData.items[i].isSelect = false;
          }
        });
      }
     /* final timeData = Provider.of<DeliveryslotitemsList>(context, listen: false);
      for(int i = 0; i < timeData.times.length; i++) {
        setState(() {
          if(i == 0) {
            timeData.times[i].selectedColor=Color(0xFF45B343);
            timeData.times[i].borderColor=Color(0xFF45B343);
            timeData.times[i].textColor=ColorCodes.whiteColor;
            timeData.times[i].isSelect = true;
          } else {
            timeData.times[i].selectedColor=ColorCodes.whiteColor;
            timeData.times[i].borderColor=Color(0xffBEBEBE);
            timeData.times[i].textColor=ColorCodes.blackColor;
            timeData.times[i].isSelect = false;
          }
        });
      }*/
      setState(() {
        if (deliveryslotData.items.length <= 0) {
          _checkslots = false;
          _loadingSlots = false;
          _slotsLoading = false;
        } else {
          _checkslots = true;
          day = deliveryslotData.items[0].day;
          date = deliveryslotData.items[0].date;
          timeslotsData = Provider.of<DeliveryslotitemsList>(
            context,
            listen: false,
          ).findById(timeslotsindex);
          for(int i = 0; i < timeslotsData.length; i++) {
            setState(() {
              prefs.setString("fixdate", deliveryslotData.items[0].dateformat);
              print("call time slot i ....."+i.toString());
              if (timeslotsData[i].status == "1") {
                debugPrint("status.....1");
                timeslotsData[i].selectedColor = ColorCodes.dividerColor;
                timeslotsData[i].borderColor = ColorCodes.dividerColor;
                timeslotsData[i].isSelect = false;
                timeslotsData[i].textColor = Colors.white;
                prefs.setString('fixtime', "");
              }
              else {
               // prefs.setString("fixdate", deliveryslotData.items[0].dateformat);
                prefs.setString('fixtime', timeslotsData[0].time);
                if (i == 0) {
                  timeslotsData[i].selectedColor = Color(0xFF45B343);
                  timeslotsData[i].borderColor = Color(0xFF45B343);
                  timeslotsData[i].textColor = ColorCodes.whiteColor;
                  timeslotsData[i].isSelect = true;
                }
                else {
                  timeslotsData[i].selectedColor = ColorCodes.whiteColor;
                  timeslotsData[i].borderColor = Color(0xffBEBEBE);
                  timeslotsData[i].textColor = ColorCodes.blackColor;
                  timeslotsData[i].isSelect = false;
                }
              }
            });

            _loadingSlots = false;
            _slotsLoading = false;
          }
          for (int j = 0; j < timeslotsData.length; j++) {
            //timedata.add(timeslotsData[j].time);
            /* if (j == 0) {
              checkBoxdata.add(true);
              titlecolor.add(0xFF2966A2);
              iconcolor.add(0xFF2966A2);
            } else {
              checkBoxdata.add(false);
              titlecolor.add(0xffBEBEBE);
              iconcolor.add(0xFFFFFFFF);
            }*/
          }
          // time = timeslotsData[0].time;
          /*for (int j = 0; j < timeslotsData.length; j++) {
              if (j == 0) {
                timeslotsData[j].titlecolor = Color(0xFF2966A2);
                timeslotsData[j].iconcolor = Color(0xFF2966A2);
              } else {
                timeslotsData[j].titlecolor = Color(0xffBEBEBE);
                timeslotsData[j].iconcolor = Color(0xFFFFFFFF);
              }
            }*/
          prefs.setString("fixdate", deliveryslotData.items[0].dateformat);
          prefs.setString('fixtime', timeslotsData[0].time);
          _loadingSlots = false;
          _slotsLoading = false;
        }
      });
    });
  }

  Future<void> deliveryCharge(String addressid) async {
    Provider.of<BrandItemsList>(context,listen: false).deliveryCharges(addressid).then((_) {
      setState(() {
        delChargeData = Provider.of<BrandItemsList>(context, listen: false);
        if (delChargeData.itemsDelCharges.length <= 0) {
          _loadingDelCharge = false;
        } else {
          _minimumOrderAmountNoraml =
              delChargeData.itemsDelCharges[0].minimumOrderAmountNoraml;
          _deliveryChargeNormal =
              delChargeData.itemsDelCharges[0].deliveryChargeNormal;
          _minimumOrderAmountPrime =
              delChargeData.itemsDelCharges[0].minimumOrderAmountPrime;
          _deliveryChargePrime =
              delChargeData.itemsDelCharges[0].deliveryChargePrime;
          _minimumOrderAmountExpress =
              delChargeData.itemsDelCharges[0].minimumOrderAmountExpress;
          _deliveryChargeExpress =
              delChargeData.itemsDelCharges[0].deliveryChargeExpress;
          _deliveryDurationExpress =
              delChargeData.itemsDelCharges[0].deliveryDurationExpress;
          _loadingDelCharge = false;
        }
      });
    });
  }

  int _groupValue = 0;

  Widget _myRadioButton({int value, Function onChanged}) {
    //prefs.setString('fixtime', timeslotsData[_groupValue].time);

    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
    );
  }

  void setDefaultAddress(String addressid) {
    bool _addresscheck = false;
    Provider.of<AddressItemsList>(context, listen: false)
        .setDefaultAddress(addressid)
        .then((_) {
      /*Provider.of<AddressItemsList>(context, listen: false).fetchAddress().then((_) {*/
      setState(() {
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);
        if (addressitemsData.items.length <= 0) {
          _addresscheck = false;
          _isLoading = false;
        } else {
          _addresscheck = true;
          _isLoading = false;
        }
      });
    });
  }
  Future<void> cartCheck(String prevAddressid, String addressid,
      String addressType, String adressSelected, IconData adressIcon) async {
    // imp feature in adding async is the it automatically wrap into Future.
    setDefaultAddress(addressid);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String itemId = "";
    for (int i = 0; i < productBox.length; i++) {
      if (itemId == "") {
        itemId = productBox.values.elementAt(i).itemId.toString();
      } else {
        itemId =
            itemId + "," + productBox.values.elementAt(i).itemId.toString();
      }
    }

    var url = IConstants.API_PATH + 'cart-check/' + addressid + "/" + itemId;
    try {
      final response = await http.get(
        url,
      );

      final responseJson = json.decode(response.body);

      //if status = 0 for reset cart and status = 1 for default
      if (responseJson["status"].toString() == "1") {
        setState(() {
          setDefaultAddress(addressid);
          _isChangeAddress = false;
          _checkaddress = true;
          _slotsLoading = true;
          prefs.setString("addressId", addressid);
          addtype = addressType;
          address = adressSelected;
          addressicon = adressIcon;
          calldeliverslots(addressid);
          deliveryCharge(addressid);
        });
        Navigator.of(context).pop();
      } else {
        _dialogforAvailability(
          prevAddressid,
          addressid,
          addressType,
          adressSelected,
          adressIcon,
        );
        /*Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName,
            ModalRoute.withName(HomeScreen.routeName));*/
      }
    } catch (error) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Something went wrong!",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
      throw error;
    }
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
                child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
              ),
            );
          });
        });
  }

  _dialogforAvailability(String prevAddOd, String addressId, String addressType,
      String adressSelected, IconData adressIcon) {
    String itemCount = "";
    itemCount = "   " + productBox.length.toString() + " " + "items";
    var currency_format = "";
    bool _checkMembership = false;

    currency_format = prefs.getString("currency_format");
    if (prefs.getString("membership") == "1") {
      _checkMembership = true;
    } else {
      _checkMembership = false;
    }

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              insetPadding: EdgeInsets.only(left: 20.0, right: 20.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: MediaQuery.of(context).size.height * 85 / 100,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      new RichText(
                        text: new TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: "Availability Check",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                            new TextSpan(
                                text: itemCount,
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12.0)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Changing area",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Product prices, availability and promos are area specific and may change accordingly. Confirm if you wish to continue.",
                        style: TextStyle(fontSize: 12.0),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(),
                      SizedBox(
                        height: 5.0,
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 53.0,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "Items",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12.0),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 15.0,
                                ),
                                Text(
                                  "Reason",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0),
                                ),
                              ],
                            ),
                          ),
                          /*Expanded(
                                  flex: 2,
                                  child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold),),),*/
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Divider(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 30 / 100,
                        child: new ListView.builder(
                          //physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: productBox.length,
                            itemBuilder: (_, i) => Row(
                              children: <Widget>[
                                FadeInImage(
                                  image: NetworkImage(productBox.values
                                      .elementAt(i)
                                      .itemImage),
                                  placeholder:
                                  AssetImage(Images.defaultProductImg),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  width: 3.0,
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          productBox.values
                                              .elementAt(i)
                                              .itemName,
                                          style: TextStyle(fontSize: 12.0)),
                                      SizedBox(
                                        height: 3.0,
                                      ),
                                      _checkmembership
                                          ? (productBox.values
                                          .elementAt(i)
                                          .membershipPrice ==
                                          '-' ||
                                          productBox.values
                                              .elementAt(i)
                                              .membershipPrice ==
                                              "0")
                                          ? (productBox.values.elementAt(i).itemPrice <=
                                          0 ||
                                          productBox.values
                                              .elementAt(i)
                                              .itemPrice
                                              .toString() ==
                                              "" ||
                                          productBox.values
                                              .elementAt(i)
                                              .itemPrice ==
                                              productBox.values
                                                  .elementAt(i)
                                                  .varMrp)
                                          ? Text(

                                              " " +
                                              productBox.values
                                                  .elementAt(i)
                                                  .varMrp
                                                  .toString()+currency_format,
                                          style: TextStyle(fontSize: 12.0))
                                          : Text(" " + productBox.values.elementAt(i).itemPrice.toString()+currency_format , style: TextStyle(fontSize: 12.0))
                                          : Text( " " + productBox.values.elementAt(i).membershipPrice+currency_format , style: TextStyle(fontSize: 12.0))
                                          : (productBox.values.elementAt(i).itemPrice <= 0 || productBox.values.elementAt(i).itemPrice.toString() == "" || productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp)
                                          ? Text( " " + productBox.values.elementAt(i).varMrp.toString()+currency_format , style: TextStyle(fontSize: 12.0))
                                          : Text( " " + productBox.values.elementAt(i).itemPrice.toString()+currency_format , style: TextStyle(fontSize: 12.0))
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 4,
                                    child: Text("Not available",
                                        style: TextStyle(fontSize: 12.0))),
                              ],
                            )),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(),
                      SizedBox(
                        height: 20.0,
                      ),
                      new RichText(
                        text: new TextSpan(
                          // Note: Styles for TextSpans must be explicitly defined.
                          // Child text spans will inherit styles from parent
                          style: new TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                          children: <TextSpan>[
                            new TextSpan(
                                text: 'Note: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                )),
                            new TextSpan(
                              text:
                              'By clicking on confirm, we will remove the unavailable items from your basket.',
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: new Container(
                              width:
                              MediaQuery.of(context).size.width * 35 / 100,
                              height: 30.0,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: new Center(
                                child: Text("CANCEL"),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          GestureDetector(
                            onTap: () async {
                              Hive.box<Product>(productBoxName).clear();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              prefs.setString("formapscreen", "homescreen");
                              Navigator.of(context)
                                  .pushNamed(MapScreen.routeName);
                            },
                            child: new Container(
                                height: 30.0,
                                width: MediaQuery.of(context).size.width *
                                    35 /
                                    100,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    )),
                                child: new Center(
                                  child: Text(
                                    "CONFIRM",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  )),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    int deliveryamount = 0;
    String minOrdAmount = "0.0";
    String delCharge = "0.0";
    /* for (int j = 0; j < timeslotsData.length; j++) {
     // time.add(timeslotsData[j].time);
      if (j == 0) {
        checkBoxdata.add(true);
        titlecolor.add(0xFF2966A2);
        iconcolor.add(0xFF2966A2);
      } else {
        checkBoxdata.add(false);
        titlecolor.add(0xffBEBEBE);
        iconcolor.add(0xFFFFFFFF);
      }
    }*/
    /* for (int j = 0; j < timeslotsData.length; j++) {
      timedata.add(timeslotsData[j].time);
      if (j == 0) {
        checkBoxdata.add(true);
        textcolor.add(0xFF2966A2);
        iconcolor.add(0xFF2966A2);
      } else {
        checkBoxdata.add(false);
        textcolor.add(0xffBEBEBE);
        iconcolor.add(0xFFFFFFFF);
      }
    }*/
    if (!_isLoading) {
      if (_radioValue == 1) {
        if (_checkmembership) {
          minOrdAmount = _minimumOrderAmountPrime;
          delCharge = _deliveryChargePrime;
        } else {
          minOrdAmount = _minimumOrderAmountNoraml;
          delCharge = _deliveryChargeNormal;
        }
      } else {
        minOrdAmount = _minimumOrderAmountExpress;
        delCharge = _deliveryChargeExpress;
      }

      if (_checkmembership
          ? (Calculations.totalMember < double.parse(minOrdAmount))
          : (Calculations.total < double.parse(minOrdAmount))) {
        deliveryamount = int.parse(delCharge);
      }

      if (!_loadingSlots && !_loadingDelCharge) {
        _loading = false;
      }
    }

    Widget _deliveryTimeSlotText() {
      return Container(
        //height: MediaQuery.of(context).size.height * 0.11,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        //color: Color(0xFFF1F1F1),
        child: Column(
          children: [
            Row(
              children: [
                Image(
                  image: AssetImage(Images.scooterImg),
                  width: 30,
                  height: 30,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  translate('forconvience.Delivery'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Text(
      translate('forconvience.pleaseselecttimeslot') ,
     // Please select a time slot as per your convenience. Your order will be delivered during the time slot //'Please select a time slot as per your convience. Your order will be delivered during the time slot.',
              style: TextStyle(
                fontSize: 11,
                color: ColorCodes.greyColor,
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    }

    _buildBottomNavigationBar() {
      return _isLoading
          ? null
          : !_checkslots
          ? GestureDetector(
        onTap: () => {
          Fluttertoast.showToast(
              msg: translate('forconvience.Currently there is no slot available'),//"currently there are no slots available"),
          )},
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.grey,
          height: 50.0,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkmembership
                  ? Text(
                  translate('forconvience.Amount Payable')+":" // 'Total: '

                     + " " +
                      (Calculations.totalMember)
                          .toStringAsFixed(2)+currency_format ,
                      /*(Calculations.totalMember + deliveryamount)
                          .toStringAsFixed(2)+currency_format ,*/
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
                  : Text(
                translate('forconvience.Amount Payable')+":"//'Total: '

                   + " " +
                    (Calculations.total )
                        .toStringAsFixed(2)+currency_format ,
                /*(Calculations.totalMember + deliveryamount)
                    .toStringAsFixed(2)+currency_format ,*/
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                child: Row(
                  children: [
                    Text(
                     translate('forconvience.CONFIRM ORDER'),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                   /* SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    )*/
                  ],
                ),
              )
            ],
          ),
        ),
      )
          : GestureDetector(
        onTap: () {
          if (_isChangeAddress) {
            Fluttertoast.showToast(
                msg: "Please select delivery address!",
                backgroundColor: Colors.black87,
                textColor: Colors.white);
          } else {
            if (!_checkaddress) {
              Fluttertoast.showToast(msg: "Please provide a address");
            }
            else if(prefs.getString('fixtime') == ""){
              debugPrint("timeslotfull" );
              Fluttertoast.showToast(
                  msg: "Please select Time slot",
                  fontSize: MediaQuery
                      .of(context)
                      .textScaleFactor * 13,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white);
            }

            else {
              debugPrint("mobile"+prefs.getString('mobile').toString());
mobile=prefs.getString('mobile').toString();
              if (prefs.getString('mobile').toString()!="null") {
                debugPrint("present");
                prefs.setString("isPickup", "no");
                Navigator.of(context)
                    .pushNamed(PaymentScreen.routeName, arguments: {
                'minimumOrderAmountNoraml': _minimumOrderAmountNoraml,
                'deliveryChargeNormal': _deliveryChargeNormal,
                'minimumOrderAmountPrime': _minimumOrderAmountPrime,
                'deliveryChargePrime': _deliveryChargePrime,
                'minimumOrderAmountExpress':
                _minimumOrderAmountExpress,
                'deliveryChargeExpress': _deliveryChargeExpress,
                'deliveryType':
                "standard",
                  'note': _message.text,
                });
              }
              else{
                debugPrint(" not present");
                debugPrint("mobile" +"if");
                //prefs.setString('prevscreen', "confirmorder");
                Navigator.of(context)
                    .pushNamed(MobileAuthScreen.routeName,);
              }


           /*   if (prefs.getString('mobile') != "null") {
                debugPrint("mobile" +"if else");
                prefs.setString("isPickup", "no");
                Navigator.of(context)
                    .pushNamed(PaymentScreen.routeName, arguments: {
                  'minimumOrderAmountNoraml': _minimumOrderAmountNoraml,
                  'deliveryChargeNormal': _deliveryChargeNormal,
                  'minimumOrderAmountPrime': _minimumOrderAmountPrime,
                  'deliveryChargePrime': _deliveryChargePrime,
                  'minimumOrderAmountExpress':
                  _minimumOrderAmountExpress,
                  'deliveryChargeExpress': _deliveryChargeExpress,
                  'deliveryType': *//*(_tabController.index == 0)*//*
                  "standard",
                  *//* : "express",*//*
                  'note': _message.text,
                });

              }


            else{

          debugPrint("mobile" +"if");
          //prefs.setString('prevscreen', "confirmorder");
          Navigator.of(context)
              .pushNamed(MobileAuthScreen.routeName,);
      }*/

            }
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: _isChangeAddress
              ? ColorCodes.greyColor
              : Theme.of(context).primaryColor,
          height: 50.0,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _checkmembership
                  ? Text(
                  translate('forconvience.Amount Payable')+":" // 'Total: '
                     + " " +
                      (Calculations.totalMember )
                          .toStringAsFixed(2)+currency_format,
                  /*(Calculations.totalMember + deliveryamount)
                      .toStringAsFixed(2)+currency_format,*/
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold))
                  : Text(
                translate('forconvience.Amount Payable')+":"//'Total: '
                   + " " +
                    (Calculations.total )
                        .toStringAsFixed(2)+currency_format,
              /*  (Calculations.totalMember + deliveryamount)
                    .toStringAsFixed(2)+currency_format,*/
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              //Spacer(),
              Container(
                child: Row(
                  children: [
                    Text(
                     translate('forconvience.CONFIRM ORDER'),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                   /* SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    )*/
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    void _settingModalBottomSheet(context, String from) {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext bc) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
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
                                translate('forconvience.Choose a delivery address'), //"Choose a delivery address",
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
                                String addsId = "";
                                setState(() {
                                  addsId = prefs.getString("addressId");
                                  /* _slotsLoading = true;
                               prefs.setString("addressId", addressitemsData.items[i].userid);
                               addtype = addressitemsData.items[i].useraddtype;
                               address = addressitemsData.items[i].useraddress;
                               addressicon = addressitemsData.items[i].addressicon;
                               calldeliverslots(addressitemsData.items[i].userid);
                               deliveryCharge(addressitemsData.items[i].userid);*/
                                });
                                if (from == "selectAddress") {
                                  Navigator.of(context).pop();
                                  _dialogforProcessing();
                                  cartCheck(
                                    prefs.getString("addressId"),
                                    addressitemsData.items[i].userid,
                                    addressitemsData.items[i].useraddtype,
                                    addressitemsData.items[i].useraddress,
                                    addressitemsData.items[i].addressicon,
                                  );
                                  /*setState(() {
                                 _checkaddress = true;
                                 addtype = addressitemsData.items[i].useraddtype;
                                 address = addressitemsData.items[i].useraddress;
                                 addressicon = addressitemsData.items[i].addressicon;
                                 prefs.setString("addressId", addressitemsData.items[i].userid);
                                 _slotsLoading = true;
                                 _isChangeAddress = false;
                                 calldeliverslots(addressitemsData.items[i].userid);
                                 deliveryCharge(addressitemsData.items[i].userid);
                               });*/
                                } else {
                                  Navigator.of(context).pop();
                                  if (addsId !=
                                      addressitemsData.items[i].userid) {
                                    /* _dialogforAvailability(
                                   addsId,
                                   addressitemsData.items[i].userid,
                                   addressitemsData.items[i].useraddtype,
                                   addressitemsData.items[i].useraddress,
                                   addressitemsData.items[i].addressicon,
                               );*/
                                    _dialogforProcessing();
                                    cartCheck(
                                      prefs.getString("addressId"),
                                      addressitemsData.items[i].userid,
                                      addressitemsData.items[i].useraddtype,
                                      addressitemsData.items[i].useraddress,
                                      addressitemsData.items[i].addressicon,
                                    );
                                  } else {
                                    setState(() {
                                      _checkaddress = true;
                                      addtype =
                                          addressitemsData.items[i].useraddtype;
                                      address =
                                          addressitemsData.items[i].useraddress;
                                      addressicon =
                                          addressitemsData.items[i].addressicon;
                                      prefs.setString("addressId",
                                          addressitemsData.items[i].userid);
                                      //_slotsLoading = true;
                                      _isChangeAddress = false;
                                      //calldeliverslots(addressitemsData.items[i].userid);
                                      //deliveryCharge(addressitemsData.items[i].userid);
                                    });
                                  }
                                }
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
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(ExampleScreen.routeName, arguments: {
                          'addresstype': "new",
                          'addressid': "",
                          'delieveryLocation': "",
                          'latitude': "",
                          'longitude': "",
                          'branch': ""
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
                                  translate('forconvience.Add new Address'), //"Add new Address",
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

    /*SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff95552b),
      //statusBarIconBrightness: Brightness.dark,//or set color with: Color(0xFF0000FF)
    ));*/
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 2;
    double aspectRatio =
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 55;

    if (deviceWidth > 1200) {
      widgetsInRow = 2;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 210;
    } else if (deviceWidth > 650) {
      widgetsInRow = 2;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 145;
    }
    debugPrint("prev confirm "+prev.toString());
    return  WillPopScope(
      onWillPop: () {
      //  SchedulerBinding.instance.addPostFrameCallback((_) {

           /* if(prev == "cart_screen"){
              debugPrint("if");
              Navigator.pushNamedAndRemoveUntil(
                  context, CartScreen.routeName, (route) => false);
            }
            else {*/
              debugPrint("else");
              Navigator.of(context).pop();
           // }
         // });
          //Navigator.of(context).pop();

        // this is the block you need
       /* Navigator.pushNamedAndRemoveUntil(
            context, CartScreen.routeName, (route) => false);*/
      //  Navigator.of(context).pop();
        //Navigator.of(context).popUntil(ModalRoute.withName('/cart-screen'));
        return Future.value(false);
      },
      child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
        /*(_checkaddress)? GradientAppBar(
          elevation: 1,
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
               ColorCodes.whiteColor,
                ColorCodes.whiteColor,
              ]),
          title: Text(
            "Checkout",style: TextStyle(color: ColorCodes.backbutton),
          ),
          leading:  IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color:ColorCodes.backbutton),
              onPressed: () {
               // SchedulerBinding.instance.addPostFrameCallback((_) {
                  *//*if(prev == "address_screen"){
                      debugPrint("if");
                    Navigator.pushNamedAndRemoveUntil(
                        context, CartScreen.routeName, (route) => false);
                  }
                  else {*//*
                    debugPrint("else");
                    Navigator.of(context).pop();
                  //}
               // });
               // Navigator.of(context).pop();
               *//* Navigator.pushNamedAndRemoveUntil(
                    context, CartScreen.routeName, (route) => false);*//*
             //   Navigator.of(context).popUntil(ModalRoute.withName('/cart-screen'));
              }
          ),
         *//* actions: [
            Container(
              height: 25,
              width: 25,
              margin: EdgeInsets.only(top: 15, bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    SearchitemScreen.routeName,
                  );
                },
                child: Icon(
                  Icons.search,
                  size: 18,
                  color: ColorCodes.blackColor,
                ),
              ),
            ),
            SizedBox(width: 10),
            // Container(
            //   height: 35,
            //   width: 35,
            //   margin: EdgeInsets.only(top: 10, bottom: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(100),
            //   ),
            //   child: GestureDetector(
            //     behavior: HitTestBehavior.translucent,
            //     onTap: () {
            //       if (Platform.isIOS) {
            //         Share.share('Download ' +
            //             IConstants.APP_NAME +
            //             ' from App Store https://apps.apple.com/us/app/id1563407384');
            //       } else {
            //         Share.share('Download ' +
            //             IConstants.APP_NAME +
            //             ' from Google Play Store https://play.google.com/store/apps/details?id=com.fellahi.store');
            //       }
            //     },
            //     child: Icon(
            //       Icons.share_outlined,
            //       color: Color(0xFF124475),
            //     ),
            //   ),
            // ),
            // SizedBox(width: 10),
            // Container(
            //   margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            //   child: ValueListenableBuilder(
            //     valueListenable: Hive.box<Product>(productBoxName).listenable(),
            //     builder: (context, Box<Product> box, index) {
            //       if (box.values.isEmpty)
            //         return Container(
            //           width: 35,
            //           height: 35,
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(100),
            //               color: Theme.of(context).buttonColor),
            //           child: GestureDetector(
            //             onTap: () {
            //               Navigator.of(context).pushNamed(CartScreen.routeName);
            //             },
            //             child: Icon(
            //               Icons.shopping_cart_outlined,
            //               size: 20,
            //               color: Theme.of(context).primaryColor,
            //             ),
            //           ),
            //         );
            //       int cartCount = 0;
            //       for (int i = 0;
            //           i < Hive.box<Product>(productBoxName).length;
            //           i++) {
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
            //             color: Colors.green,
            //             value: cartCount.toString(),
            //           ),
            //           child: Container(
            //             width: 35,
            //             height: 35,
            //             //margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
            //             decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(100),
            //                 color: Theme.of(context).buttonColor),
            //             child: GestureDetector(
            //               onTap: () {
            //                 Navigator.of(context).pushNamed(CartScreen.routeName);
            //               },
            //               child: Icon(
            //                 Icons.shopping_cart_outlined,
            //                 color: Theme.of(context).primaryColor,
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            // SizedBox(width: 10),
          ],*//*
        ):null,*/

        backgroundColor: Colors.white,
        body: _loading
            ? Center(
          child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
        )
            :

        _loading
            ? Center(
          child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
        )
            :
            SingleChildScrollView(
              child: Container(
                //height: MediaQuery.of(context).size.height,
                color: ColorCodes.whiteColor,
                // padding: EdgeInsets.only(left: 10.0, top: 10.0, ),
                child: Column(
                  children: <Widget>[
                    !_isChangeAddress?
                    _checkaddress
                        ? Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Row(
                        children: <Widget>[

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        color: ColorCodes.blackColor, size: 16),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: Text(
                                        translate('forconvience.Select delivery address'),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0,
                                            color: ColorCodes.blackColor),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left:18.0,right:10),
                                        child: Text(
                                          address,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                   /* SizedBox(
                                      width: 40.0,
                                    ),*/
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () {
                                          _settingModalBottomSheet(context, "change");
                                        },
                                        child: Container(
                                          //margin:EdgeInsets.only(right:),
                                          height: 30,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: ColorCodes.lightGreyColor),
                                          ),
                                          child: Center(
                                            child: Text(
                                              translate('header.change'),// "CHANGE",
                                              style: TextStyle(
                                                //decoration: TextDecoration.underline,
                                                  decorationStyle:
                                                  TextDecorationStyle.dashed,
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 12.0),
                                            ),
                                          ),
                                        )),
                                   /* SizedBox(
                                      width: 10.0,
                                    ),*/
                                  ],
                                ),
                              ],
                            ),
                          ),


                        ],
                      ),
                    )
                        :

                    Row(
                      children: <Widget>[
                        SizedBox(
                          width: 5.0,
                        ),
                        Spacer(),
                        FlatButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Theme.of(context).buttonColor,
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(3.0),
                          ),
                          onPressed: () => {
                            Navigator.of(context).pushNamed(
                                ExampleScreen.routeName,
                                arguments: {
                                  'addresstype': "new",
                                  'addressid': "",
                                  'delieveryLocation': "",
                                  'latitude': "",
                                  'longitude': "",
                                  'branch': ""
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
                    )
                    :Container(
                      margin: EdgeInsets.all(5.0),
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              Icon(Icons.location_on),
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
                                      "You are in a new location!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.0),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      deliverlocation,
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _settingModalBottomSheet(
                                      context, "selectAddress");
                                },
                                child: Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width *
                                      43 /
                                      100,
                                  margin: EdgeInsets.only(
                                      left: 10.0, right: 5.0, bottom: 10.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(5.0),
                                      border: Border(
                                        top: BorderSide(width: 1.0, color: Theme
                                            .of(context)
                                            .accentColor,),
                                        bottom: BorderSide(
                                          width: 1.0, color: Theme
                                            .of(context)
                                            .accentColor,),
                                        left: BorderSide(width: 1.0, color: Theme
                                            .of(context)
                                            .accentColor,),
                                        right: BorderSide(width: 1.0, color: Theme
                                            .of(context)
                                            .accentColor,),
                                      )),
                                  height: 40.0,
                                  child: Center(
                                    child: Text(
                                      'Select Address',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color:
                                        Theme
                                            .of(context)
                                            .accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed(
                                      ExampleScreen.routeName,
                                      arguments: {
                                        'addresstype': "new",
                                        'addressid': "",
                                        'delieveryLocation': "",
                                        'latitude': "",
                                        'longitude': "",
                                        'branch': ""
                                      });
                                },
                                child: Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 43 / 100,
                                  margin: EdgeInsets.only(
                                      left: 5.0, right: 10.0, bottom: 10.0),
                                  decoration: BoxDecoration(
                                      color: Theme
                                          .of(context)
                                          .accentColor,
                                      borderRadius:
                                      BorderRadius.circular(5.0),
                                      border: Border(
                                        top: BorderSide(width: 1.0, color:
                                        Theme
                                            .of(context)
                                            .accentColor,
                                        ),
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color:
                                          Theme
                                              .of(context)
                                              .accentColor,
                                        ),
                                        left: BorderSide(
                                          width: 1.0,
                                          color:
                                          Theme
                                              .of(context)
                                              .accentColor,
                                        ),
                                        right: BorderSide(
                                          width: 1.0,
                                          color:
                                          Theme
                                              .of(context)
                                              .accentColor,
                                        ),
                                      )),
                                  height: 40.0,
                                  child: Center(
                                    child: Text(
                                      'Add Address',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    //SizedBox(height: 8.0,),
                    Divider(
                      color: ColorCodes.lightGreyColor,
                    ),
                    //SizedBox(height: 8.0,),
                    /*ListTile(
                      dense:true,
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
                    ),*/
/*
                    SizedBox(
                      height: 10.0,
                    ),*/

                    // Delivery time slot banner with text
                    _deliveryTimeSlotText(),
                    if(!_isChangeAddress)
                    !_slotsLoading
                        ? _checkslots
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height*0.065,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(left: 18),
                          color: ColorCodes.tabcolor,
                          child:Align(
                             alignment: Alignment.centerLeft,
                              child: Text(translate('forconvience.Select day to deliver'),style: TextStyle(fontSize: 16),))
                        ),
                        SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.only(left:18.0,right:18),
                          child: SizedBox(
                            child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 2,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 6,
                                ),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                              itemCount: deliveryslotData.items.length,
                                itemBuilder:(ctx, i){
                                return GestureDetector(
                                  onTap: (){
                                    print('hello');
                                    setState(() {
                                      prefs.setString("fixdate", deliveryslotData.items[i].dateformat);
                                      day = deliveryslotData.items[i].day;
                                      date = deliveryslotData.items[i].date;
                                      for (int j = 0; j < deliveryslotData.items.length; j++) {
                                        if (i != j) {
                                          deliveryslotData.items[j].width = 1.0;
                                        }
                                      }
                                      deliveryslotData.items[i].width = 3.0;
                                      timeslotsindex = deliveryslotData.items[i].id;
                                      timeslotsData = Provider.of<DeliveryslotitemsList>(context, listen: false,).findById(timeslotsindex);

                                      for(int j=0;j<deliveryslotData.items.length;j++){
                                        if(i==j){
                                          print("day j = i");
                                          deliveryslotData.items[j].selectedColor=Color(0xFF45B343);
                                          deliveryslotData.items[j].borderColor=Color(0xFF45B343);
                                          deliveryslotData.items[j].textColor=ColorCodes.whiteColor;
                                          deliveryslotData.items[j].isSelect = true;

                                        }
                                        else{
                                          print("day not j = i");
                                          deliveryslotData.items[j].selectedColor=ColorCodes.whiteColor;
                                          deliveryslotData.items[j].borderColor=Color(0xffBEBEBE);
                                          deliveryslotData.items[j].textColor=ColorCodes.blackColor;
                                          deliveryslotData.items[j].isSelect = false;
                                         /* prefs.setString('fixtime',
                                              "");*/
                                        }
                                      }
                                      for(int j=0;j<timeslotsData.length; j++){
                                        debugPrint("dellength"+deliveryslotData.items.length.toString());
                                        debugPrint("timlength"+timeslotsData.length.toString());
                                        debugPrint("i"+i.toString()+"j"+(j-1).toString());
                                        setState((){


                                          if(j == 0){
                                            debugPrint("j equal zero"+timeslotsData.length.toString());
                                            debugPrint("j equal "+timeslotsData[0].time.toString());
                                            debugPrint("j equal "+prefs.getString('fixtime').toString());
                                           //  timeslotsData[0].selectedColor=Color(0xFF45B343);
                                           // // deliveryslotData.items[i].selectedColor=Color(0xFF45B343);
                                           //  timeslotsData[0].borderColor=Color(0xFF45B343);
                                           //  timeslotsData[0].textColor=ColorCodes.whiteColor;
                                           //  timeslotsData[0].isSelect = true;

                                            prefs.setString('fixtime',
                                                timeslotsData[j].time);
                                              if (timeslotsData[0].status =="1") {

                                                timeslotsData[0]
                                                    .selectedColor =
                                                    ColorCodes.dividerColor;
                                                timeslotsData[0]
                                                    .borderColor =
                                                    ColorCodes.dividerColor;
                                                timeslotsData[0].isSelect =
                                                false;
                                                timeslotsData[0].textColor =
                                                    Colors.white;
                                                prefs.setString(
                                                    'fixtime', "");
                                                // Fluttertoast.showToast(
                                                //     msg: "Complet",//"Slot is Full",
                                                //     fontSize: MediaQuery
                                                //         .of(context)
                                                //         .textScaleFactor * 13,
                                                //     backgroundColor: Colors.black87,
                                                //     textColor: Colors.white);

                                              }
                                              else {
                                                timeslotsData[0]
                                                    .selectedColor =
                                                    Color(0xFF45B343);
                                                timeslotsData[0]
                                                    .borderColor =
                                                    Color(0xFF45B343);
                                                timeslotsData[0].textColor =
                                                    ColorCodes.whiteColor;
                                                timeslotsData[0].isSelect =
                                                true;
                                                prefs.setString('fixtime',
                                                    timeslotsData[j].time);


                                              }
                                            debugPrint("j equal end"+prefs.getString('fixtime').toString());


                                          }else{

                                            // timeslotsData[j].selectedColor=ColorCodes.whiteColor;
                                            // timeslotsData[j].borderColor=Color(0xffBEBEBE);
                                            // timeslotsData[j].textColor=ColorCodes.blackColor;
                                            // timeslotsData[j].isSelect = false;
                                            if (timeslotsData[j].status =="1") {

                                              timeslotsData[j]
                                                  .selectedColor =
                                                  ColorCodes.dividerColor;
                                              timeslotsData[j]
                                                  .borderColor =
                                                  ColorCodes.dividerColor;
                                              timeslotsData[j].isSelect =
                                              false;
                                              timeslotsData[j].textColor =
                                                  Colors.white;
                                              prefs.setString(
                                                  'fixtime', "");
                                              // Fluttertoast.showToast(
                                              //     msg: "Complet",//"Slot is Full",
                                              //     fontSize: MediaQuery
                                              //         .of(context)
                                              //         .textScaleFactor * 13,
                                              //     backgroundColor: Colors.black87,
                                              //     textColor: Colors.white);

                                            }
                                            else {
                                              timeslotsData[j].selectedColor=ColorCodes.whiteColor;
                                              timeslotsData[j].borderColor=Color(0xffBEBEBE);
                                              timeslotsData[j].textColor=ColorCodes.blackColor;
                                              timeslotsData[j].isSelect = false;

                                            }
                                          }
                                        });
                                      }
                                    });
                                  },
                                  child: Container(
                                   // height: MediaQuery.of(context).size.height*0.065,
                                   // padding: EdgeInsets.only(left: 10),
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: deliveryslotData.items[i].selectedColor,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color:deliveryslotData.items[i].borderColor)
                                    ),
                                   child: Column(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text(deliveryslotData.items[i].day,style: TextStyle(color: deliveryslotData.items[i].textColor),),
                                       Text(deliveryslotData.items[i].date,style: TextStyle(color: deliveryslotData.items[i].textColor),),
                                     ],
                                   )
                                  ),
                                );
                                }
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Container(
                            height: MediaQuery.of(context).size.height*0.070,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(left: 18,),
                            color: ColorCodes.tabcolor,
                            child:Align(
                                alignment: Alignment.centerLeft,
                                child: Text(translate('forconvience.Select time slot'),style: TextStyle(fontSize: 16),))
                        ),
                        SizedBox(height: 10,),
                        Padding(
                            padding: const EdgeInsets.only(right:18.0,left:18),
                            child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widgetsInRow,
                                  childAspectRatio: aspectRatio,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 0.5,
                                ),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: timeslotsData.length,
                                //physics: ScrollPhysics(),
                                itemBuilder:(ctx, i){
                                  return GestureDetector(
                                    onTap: (){
                                      debugPrint("i clicl"+i.toString());
                                      debugPrint("fixtimei"+timeslotsData[i].time);
                                      print("fixtime....click"+prefs.getString("fixtime").toString());
                                      setState(() {

                                        for(int j = 0; j< timeslotsData.length; j++) {
                                          setState(() {
                                            //prefs.setString('fixtime', timeslotsData[i].time);
                                            final timeData = Provider.of<DeliveryslotitemsList>(context, listen: false);
                                              // if (timeslotsData[j].status == "1") {
                                              // debugPrint("status.....1");
                                              // timeslotsData[j].selectedColor = Colors.grey;
                                              // timeslotsData[j].borderColor = Colors.grey;
                                              // timeslotsData[j].isSelect = false;
                                              // timeslotsData[j].textColor = Colors.grey;
                                              // prefs.setString('fixtime', "");
                                              // }
                                              // else {

                                                if (i == j) {
                                                  if (timeslotsData[j].status ==
                                                      "1") {
                                                    debugPrint("status.....1");
                                                    timeslotsData[j]
                                                        .selectedColor =
                                                        ColorCodes.dividerColor;
                                                    timeslotsData[j]
                                                        .borderColor =
                                                        ColorCodes.dividerColor;
                                                    timeslotsData[j].isSelect =
                                                    false;
                                                    timeslotsData[j].textColor =
                                                        Colors.white;
                                                    prefs.setString(
                                                        'fixtime', "");
                                                    Fluttertoast.showToast(
                                                        msg: "Complet",//"Slot is Full",
                                                        fontSize: MediaQuery
                                                            .of(context)
                                                            .textScaleFactor * 13,
                                                        backgroundColor: Colors.black87,
                                                        textColor: Colors.white);

                                                  }
                                                  else {
                                                    timeslotsData[j]
                                                        .selectedColor =
                                                        Color(0xFF45B343);
                                                    timeslotsData[j]
                                                        .borderColor =
                                                        Color(0xFF45B343);
                                                    timeslotsData[j].textColor =
                                                        ColorCodes.whiteColor;
                                                    timeslotsData[j].isSelect =
                                                    true;
                                                    prefs.setString('fixtime',
                                                        timeslotsData[j].time);

                                                  }
                                                }else {
                                                  if (timeslotsData[j].status ==
                                                      "1") {
                                                    debugPrint("status.....1");
                                                    timeslotsData[j]
                                                        .selectedColor =
                                                        ColorCodes.dividerColor;
                                                    timeslotsData[j]
                                                        .borderColor =
                                                        ColorCodes.dividerColor;
                                                    timeslotsData[j].isSelect =
                                                    false;
                                                    timeslotsData[j].textColor =
                                                        Colors.white;

                                                  }
                                                  else {
                                                    timeslotsData[j]
                                                        .selectedColor =
                                                        ColorCodes.whiteColor;
                                                    timeslotsData[j]
                                                        .borderColor =
                                                        Color(0xffBEBEBE);
                                                    timeslotsData[j].textColor =
                                                        ColorCodes.blackColor;
                                                    timeslotsData[j].isSelect =
                                                    false;
                                                  }
                                                }

                                                // setState(() {
                                                //   prefs.setString('fixtime', timeslotsData[i].time);
                                                // });

                                              //}

                                          });

                                          /*day = deliveryslotData.items[i].day;
                                          date = deliveryslotData.items[i].date;*/
                                        }
                                        print("fixtime....click"+prefs.getString("fixtime").toString());

                                      });

                                    },
                                    child: Container(
                                        // height: 40,
                                        // padding: EdgeInsets.only(left: 10),
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color:timeslotsData[i].selectedColor,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color:timeslotsData[i].borderColor),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(timeslotsData[i].time,style: TextStyle(color:timeslotsData[i].textColor),),
                                          ],
                                        )
                                    ),
                                  );
                                }
                            ),
                          ),
                        SizedBox(height: 10,),

                      ],
                    )
                    /*Expanded(
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding:
                            EdgeInsets.symmetric(horizontal: 20),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: ColorCodes.blackColor,
                              indicatorColor: Colors.white,
                              unselectedLabelColor:
                              ColorCodes.lightGreyColor,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              tabs: [
                                Tab(text: 'SLOT BASED DELIVERY'),
                                Tab(
                                  text: 'EXPRESS DELIVERY',
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: TabBarView(
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                slotBasedDelivery(),
                                expressDelivery(),
                              ],
                              controller: _tabController,
                            ),
                          ),

                        ],
                      ),
                    )*/
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 5.0,
                        ),
                        if(_checkaddress)
                        Text(
                          translate('forconvience.Currently there is no slot available'), //"Currently there is no slots available",
                          style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                        : Center(
                      child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                    )
                  ],
                ),
              ),
            ),

        bottomNavigationBar: (_checkaddress)? Container(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
              child: _buildBottomNavigationBar()
          ),
        ) : null,
      ),
    );
  }


  gradientappbarmobile() {
    return _checkaddress?
    AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      title: Text(
        "Checkout",style: TextStyle(color: ColorCodes.backbutton),
      ),
      leading:  IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color:ColorCodes.backbutton),
          onPressed: () {
            // SchedulerBinding.instance.addPostFrameCallback((_) {
            /*if(prev == "address_screen"){
                      debugPrint("if");
                    Navigator.pushNamedAndRemoveUntil(
                        context, CartScreen.routeName, (route) => false);
                  }
                  else {*/
            debugPrint("else");
            Navigator.of(context).pop();
            //}
            // });
            // Navigator.of(context).pop();
            /* Navigator.pushNamedAndRemoveUntil(
                    context, CartScreen.routeName, (route) => false);*/
            //   Navigator.of(context).popUntil(ModalRoute.withName('/cart-screen'));
          }
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
                ]),),
      ),
    ):null;
  }


/*Widget _customScroll(){
  NestedScrollView(
    physics: NeverScrollableScrollPhysics(),
    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
      return <Widget>[
        SliverAppBar(
            pinned: false,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            expandedHeight: MediaQuery.of(context).size.height*0.4,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  !_isChangeAddress
                      ? _checkaddress
                      ? Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                translate('forconvience.Select delivery address'),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: ColorCodes.blackColor),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Text(
                                address,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 40.0,
                        ),
                        GestureDetector(
                            onTap: () {
                              _settingModalBottomSheet(
                                  context, "change");
                            },
                            child: Text(
                              "CHANGE",
                              style: TextStyle(
                                //decoration: TextDecoration.underline,
                                  decorationStyle:
                                  TextDecorationStyle.dashed,
                                  color: ColorCodes.mediumBlueColor,
                                  fontSize: 12.0),
                            )),
                        SizedBox(
                          width: 10.0,
                        ),
                      ],
                    ),
                  )
                      : Row(
                    children: <Widget>[
                      SizedBox(
                        width: 5.0,
                      ),
                      Spacer(),
                      FlatButton(
                        color: Theme
                            .of(context)
                            .primaryColor,
                        textColor: Theme
                            .of(context)
                            .buttonColor,
                        shape: new RoundedRectangleBorder(
                          borderRadius:
                          new BorderRadius.circular(3.0),
                        ),
                        onPressed: () =>
                        {
                          Navigator.of(context).pushNamed(
                              AddressScreen.routeName,
                              arguments: {
                                'addresstype': "new",
                                'addressid': "",
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
                  )
                      : Container(
                    margin: EdgeInsets.all(5.0),
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(Icons.location_on),
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
                                    "You are in a new location!",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    deliverlocation,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15.0,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                _settingModalBottomSheet(
                                    context, "selectAddress");
                              },
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width *
                                    43 /
                                    100,
                                margin: EdgeInsets.only(
                                    left: 10.0, right: 5.0, bottom: 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    border: Border(
                                      top: BorderSide(width: 1.0, color: Theme
                                          .of(context)
                                          .accentColor,),
                                      bottom: BorderSide(
                                        width: 1.0, color: Theme
                                          .of(context)
                                          .accentColor,),
                                      left: BorderSide(width: 1.0, color: Theme
                                          .of(context)
                                          .accentColor,),
                                      right: BorderSide(width: 1.0, color: Theme
                                          .of(context)
                                          .accentColor,),
                                    )),
                                height: 40.0,
                                child: Center(
                                  child: Text(
                                    'Select Address',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color:
                                      Theme
                                          .of(context)
                                          .accentColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pushNamed(
                                    AddressScreen.routeName,
                                    arguments: {
                                      'addresstype': "new",
                                      'addressid': "",
                                      'delieveryLocation': "",
                                      'latitude': "",
                                      'longitude': "",
                                      'branch': ""
                                    });
                              },
                              child: Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 43 / 100,
                                margin: EdgeInsets.only(
                                    left: 5.0, right: 10.0, bottom: 10.0),
                                decoration: BoxDecoration(
                                    color: Theme
                                        .of(context)
                                        .accentColor,
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    border: Border(
                                      top: BorderSide(width: 1.0, color:
                                      Theme
                                          .of(context)
                                          .accentColor,
                                      ),
                                      bottom: BorderSide(
                                        width: 1.0,
                                        color:
                                        Theme
                                            .of(context)
                                            .accentColor,
                                      ),Opacity(opacity: 0.0,child: Container(
                      height: 2,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: ColorCodes.whiteColor,
                        indicatorColor: ColorCodes.whiteColor,
                        unselectedLabelColor:
                        ColorCodes.whiteColor,
                        labelStyle: TextStyle(
                          fontSize: 0,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: 'SLOT BASED DELIVERY'),
                          Tab(
                            text: 'EXPRESS DELIVERY',
                          ),
                        ],
                      ),
                    ),),

                                      left: BorderSide(
                                        width: 1.0,
                                        color:
                                        Theme
                                            .of(context)
                                            .accentColor,
                                      ),
                                      right: BorderSide(
                                        width: 1.0,
                                        color:
                                        Theme
                                            .of(context)
                                            .accentColor,
                                      ),
                                    )),
                                height: 40.0,
                                child: Center(
                                  child: Text(
                                    'Add Address',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  //SizedBox(height: 8.0,),
                  Divider(
                    color: ColorCodes.lightGreyColor,
                  ),
                  ListTile(
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
                            fillColor: Color(0xffD5D5D5)),
                        //minLines: 3,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),

                  // Delivery time slot banner with text
                  _deliveryTimeSlotText(),
                ],
              ),
            ),

            bottom: TabBar(
              physics: NeverScrollableScrollPhysics(),
              indicatorColor: Colors.white,
              labelColor: Colors.black,
              unselectedLabelColor:
              ColorCodes.lightGreyColor,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(text: 'SLOT BASED DELIVERY'),
                Tab(text: 'EXPRESS DELIVERY',),

              ],
              controller: _tabController,
            )
        )
      ];
    },
    body: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        //this is for removing scroll glow of listview
        overscroll.disallowGlow();
      },
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height*0.5,
        color: ColorCodes.whiteColor,
        child: Column(
          children: <Widget>[
            if (!_isChangeAddress)
              !_slotsLoading
                  ? _checkslots
                  ? Expanded(
                child: Column(
                  children: <Widget>[
                    Opacity(opacity: 0.0,child: Container(
                      height: 2,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: ColorCodes.whiteColor,
                        indicatorColor: ColorCodes.whiteColor,
                        unselectedLabelColor:
                        ColorCodes.whiteColor,
                        labelStyle: TextStyle(
                          fontSize: 0,
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: [
                          Tab(text: 'SLOT BASED DELIVERY'),
                          Tab(
                            text: 'EXPRESS DELIVERY',
                          ),
                        ],
                      ),
                    ),),

                    Expanded(
                      child:
                      TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          slotBasedDelivery(),
                          expressDelivery(),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "Currently there is no slots available",
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
                  : Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    ),

  ),
}*/
//******************************* new listview design**********
  Widget slotBasedDelivery() {
    int index = 0;
    /*for (int i = 0; i < deliveryslotData.items.length; i++) {
      for (int j = 1; j <= timeslotsData.length; j++) {
        index = index + j;
      }
    }*/

    debugPrint("slotBasedDelivery . . . . . .. " + deliveryslotData.items.length.toString());

    return


      Container(

      child:
        NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
      //this is for removing scroll glow of listview
      overscroll.disallowGlow();
    },
          child:  ListView.builder(
              shrinkWrap: true,
              physics: new AlwaysScrollableScrollPhysics(),

              //physics: NeverScrollableScrollPhysics(),
              //controller: _controller,
              // physics: NeverScrollableScrollPhysics(),
              itemCount: deliveryslotData.items.length,
              //shrinkWrap: true,
              itemBuilder: (_, i) => Column(
                children: [
                  Container(
                    color: ColorCodes.slotTab,
                    height: 50,
                    child: Container(
                      color: ColorCodes.slotTab,
                      margin: EdgeInsets.only(left: 45, right: 68),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Container(
                            child: Text(deliveryslotData.items[i].date,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),

                          //Spacer(flex: 1,)
                        ],
                      ),
                    ),
                  ),

                  timeSlot(deliveryslotData.items[i].id, i,),
                  // if ( i < deliveryslotData.items.length ) Divider(
                  //   color: Colors.black,
                  // ),
                ],
              )),

        )



    );
  }

  Widget timeSlot(String id, int i) {
    timeslotsData = Provider.of<DeliveryslotitemsList>(
      context,
      listen: false,
    ).findById(id);

    return new ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: ColorCodes.lightGreyColor,
      ),
      physics:new NeverScrollableScrollPhysics(),
     shrinkWrap: true,
      itemCount: timeslotsData.length,
      itemBuilder: (_, j) => GestureDetector(
        onTap: () async {
          // value:
          // _index = (i == 0 && j == 0) ? 0 : _index + 1;
          setState(() {
            //_groupValue = _index = (i == 0 && j == 0) ? 0 : _index + 1;
            //_index = (i == 0 && j == 0) ? 0 : _index + 1;
            time = timeslotsData[j].time;
            /*for (int k = 0; k < timeslotsData.length; k++) {
              setState(() {
                if (timeslotsData[j].id == timeslotsData[k].id) {
                  //checkBoxdata[j] = true;
                  timeslotsData[k].selectedColor = Color(0xFF2966A2);
                  timeslotsData[k].isSelect = true;
                } else {
                  //checkBoxdata[k] = false;
                  timeslotsData[k].selectedColor = Color(0xffBEBEBE);
                  timeslotsData[k].isSelect = false;
                }
              });
            }*/
            final timeData = Provider.of<DeliveryslotitemsList>(context, listen: false);
            prefs.setString("fixdate", deliveryslotData.items[i].dateformat);
            prefs.setString('fixtime', timeslotsData[i].time);

            _index = (i == 0 && j == 0) ? 0 : _index + 1;
            for(int i = 0; i < timeData.times.length; i++) {
              //debugPrint("compare .  .. . . .. " + j.toString() + "............" + timeslotsData[j].time + "      " + _index.toString() + ". . . . . ." + timeslotsData[j].index + "     " + timeData.times[i].index);
              setState(() {
                if(/*timeData.times[_index].index*/(int.parse(id) + j).toString() == timeData.times[i].index) {
                  timeData.times[i].selectedColor = Color(0xFF2966A2);
                  timeData.times[i].isSelect = true;
                } else {
                  timeData.times[i].selectedColor = Color(0xffBEBEBE);
                  timeData.times[i].isSelect = false;
                }
              });
            }
            /*   for (int k = 0; k < timeslotsData.length; k++) {
              if (j == k) {
                timeslotsData[j].titlecolor = Color(0xFF2966A2);
                timeslotsData[j].iconcolor = Color(0xFF2966A2);
              } else {
                timeslotsData[k].titlecolor = Color(0xffBEBEBE);
                timeslotsData[k].iconcolor = Color(0xFFFFFFFF);
              }
            }*/
          });
        },
        child: Container(
          height: 40,
          color: Colors.white,
          margin: EdgeInsets.only(left: 5.0, right: 5.0),
          //child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  timeslotsData[j].time,
                  style: TextStyle(color: timeslotsData[j].selectedColor, fontWeight: timeslotsData[j].isSelect ? FontWeight.bold : FontWeight.normal),
                ),
              ),
              SizedBox(width: 40),
              timeslotsData[j].isSelect ?
              Icon(Icons.check, color: timeslotsData[j].selectedColor) : Icon(Icons.check, color: Colors.transparent),
              /* _myRadioButton(
                value: _index = (i == 0 && j == 0) ? 0 : _index + 1,
                onChanged: (newValue) {
                  setState(() {
                    _groupValue = newValue;
                    prefs.setString(
                        "fixdate", deliveryslotData.items[i].dateformat);
                    day = deliveryslotData.items[i].day;
                    date = deliveryslotData.items[i].date;
                    prefs.setString('fixtime', timeslotsData[j].time);
                  });

                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  //******************** new code tab bar express delivery *************

  Widget expressDelivery() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 300,
            decoration: BoxDecoration(
                border: Border.all(
                  color: ColorCodes.lightGreyColor,
                  width: 1.2,
                )),
            child: Center(child: Text(_deliveryDurationExpress)),
          )
        ],
      ),
    );
  }
}