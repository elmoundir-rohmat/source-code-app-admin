import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'package:package_info/package_info.dart';
import '../constants/ColorCodes.dart';
import '../data/hiveDB.dart';
import '../main.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:hive/hive.dart';
import '../data/calculations.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import '../providers/branditems.dart';
import '../screens/orderconfirmation_screen.dart';
import '../constants/images.dart';
import '../screens/paytm_screen.dart';
import '../constants/IConstants.dart';
import 'package:flutter_translate/flutter_translate.dart';

class PaymentScreen extends StatefulWidget {
  static const routeName = '/payment-screen';
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  Box<Product> productBox;
  SharedPreferences prefs;
  int _groupValue = -1;
  var totlamount;
  var _checkpromo = false;
  var _displaypromo = false;
  var _promocode = "";
  var _currencyFormat = "";
  double minorderamount = 0;
  double deliverycharge = 0;
  var walletbalance = "0";
  var loyaltyPoints = "0";
  bool _ischeckbox = true;
  bool _ischeckboxshow = true;
  double deliveryamount = 0;
  final myController = TextEditingController();
  String _savedamount = "";
  String _promoamount = "";
  String promovarprice;
  String promomessage = "";
  String promocashbackmsg = "";
  bool _isWallet = false;
  bool _isLoayalty = false;
  var paymentData;
  bool _isRemainingAmount = false;
  double walletAmount = 0.0;
  double remainingAmount = 0.0;
  double remLoyaltyPoint = 0;
  bool _isPickup = false;
  int pickupValue = -1;
  double cartTotal = 0.0;
  double carttotalfinal = 0.0;
  bool _showDeliveryinfo = false;
  bool _isLoading = true;
  bool _checkmembership = false;
  var _message = TextEditingController();
  bool _isLoyaltyToast = false;
  bool _isSwitch = false;
  double loyaltyPointsUser = 0;
  double loyaltyAmount = 0.0;
  String note;
  bool _isWeb = false;
  PackageInfo packageInfo;
  var _address = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool _isCOD = false;
  bool _isOnline = false;
  bool _isSod = false;
  bool iphonex = false;
  bool _isorder = false;

  @override
  void initState() {

    productBox = Hive.box<Product>(productBoxName);
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
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
      final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
      if(prefs.containsKey("orderId")) {
        await _cancelOrder();
      }


      Provider.of<BrandItemsList>(context,listen: false).fetchWalletBalance().then((_) async {
        setState(() {
          if (prefs.getString("isPickup") == "yes") {
            _isPickup = true;
          } else {
            _isPickup = false;
          }
          _currencyFormat = prefs.getString("currency_format");
          if (routeArgs['deliveryType'] == "express") {
            minorderamount = double.parse(routeArgs['minimumOrderAmountExpress']);
            deliverycharge = double.parse(routeArgs['deliveryChargeExpress']);
            note = routeArgs['note'];
          } else {
            if (prefs.getString("membership") == "1") {
              _checkmembership = true;
              minorderamount = double.parse(routeArgs['minimumOrderAmountPrime']);
              deliverycharge = double.parse(routeArgs['deliveryChargePrime']);
              note = routeArgs['note'];
            } else {
              _checkmembership = false;
              minorderamount = double.parse(routeArgs['minimumOrderAmountNoraml']);
              deliverycharge = double.parse(routeArgs['deliveryChargeNormal']);
              note = routeArgs['note'];
            }
          }

          walletbalance = prefs.getString("wallet_balance"); //user wallet balance
          loyaltyPoints = double.parse(prefs.getString("loyalty_balance")).toStringAsFixed(2); // user loyalty points
          if (prefs.getString("membership") == "1") {
            cartTotal = Calculations.totalMember;
          } else {
            cartTotal = Calculations.total;
          }
          if (cartTotal < minorderamount) {
            deliveryamount = deliverycharge;
          }

          paymentData = Provider.of<BrandItemsList>(context,listen: false);
          for(int i = 0; i < paymentData.itemspayment.length; i++){
            //if payment mode is wallet
            if(paymentData.itemspayment[i].paymentMode == "2") {
              _isWallet = true;
              break;
            } else {
              _isWallet = false;
            }
          }
          for(int i = 0; i < paymentData.itemspayment.length; i++){
            //if payment mode is Loyalty

            if(paymentData.itemspayment[i].paymentMode == "4") {
              _isLoayalty = true;
              break;
            } else {
              _isLoayalty = false;
            }
          }
        });

        double totalAmount = 0.0; //Order amount
        !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
        final loyaltyData = Provider.of<BrandItemsList>(context,listen: false);
        /*if(loyaltyData.itemsLoyalty.length > 0) {

        } else {
          setState(() {
            _isLoayalty = false;
          });
        }
*/
        await Provider.of<BrandItemsList>(context, listen: false).getLoyalty().then((_) async {
          final loyaltyData = Provider.of<BrandItemsList>(
              context, listen: false);
          if (loyaltyData.itemsLoyalty.length > 0) {

          } else {
            setState(() {
              _isLoayalty = false;
            });
          }
          if (_isLoayalty) {
            await Provider.of<BrandItemsList>(context, listen: false)
                .checkLoyalty(totalAmount.toString())
                .then((_) {
              setState(() {
                _isLoading = false;
                _isSwitch = true;


                //check user eligible to use Loyalty points or not
                final loyaltyData = Provider.of<BrandItemsList>(
                    context, listen: false);
                if (double.parse(
                    loyaltyData.itemsLoyalty[0].minimumOrderAmount) <=
                    totalAmount) {
                  _isSwitch = true;
                  _isLoyaltyToast = false;
                  //Compare user loyalty balance to apply loyalty points
                  if (prefs.getDouble("loyaltyPointsUser") <=
                      double.parse(loyaltyPoints)) {
                    loyaltyPointsUser = prefs.getDouble("loyaltyPointsUser");
                    loyaltyAmount = ((loyaltyPointsUser * 1) /
                        double.parse(loyaltyData.itemsLoyalty[0].points));
                    if (loyaltyAmount.toString() == "NaN") {
                      loyaltyAmount = 0.0;
                    }
                  } else {
                    /*loyaltyPointsUser = prefs.getDouble("loyaltyPointsUser") - double.parse(loyaltyPoints);
                loyaltyAmount = ((loyaltyPointsUser * 1) / int.parse(loyaltyData.itemsLoyalty[0].points));*/
                    loyaltyPointsUser = double.parse(loyaltyPoints);
                    loyaltyAmount = ((loyaltyPointsUser * 1) /
                        int.parse(loyaltyData.itemsLoyalty[0].points));
                    if (loyaltyAmount.toString() == "NaN") {
                      loyaltyAmount = 0.0;
                    }
                  }
                } else {
                  _isSwitch = true;
                  _isLoyaltyToast = true;
                }
              });
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        });

        setState(() {

          if(_isWallet) {
            double totalAmount = 0.0;
            !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));

            if (double.parse(walletbalance) <= 0
           ) {
              _isRemainingAmount = false;
              _ischeckboxshow = false;
              _ischeckbox = false;
            } else if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
              _isRemainingAmount = false;
              _groupValue = -1;
              prefs.setString("payment_type", "wallet");
              walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
            } else if (_isSwitch ? totalAmount > (double.parse(walletbalance) + loyaltyAmount) : totalAmount > double.parse(walletbalance)) {

              for(int i = 0; i < paymentData.itemspayment.length; i++) {
                if(paymentData.itemspayment[i].paymentMode == "1") {
                  _groupValue = i;
                  _isOnline = true;
                  break;
                } else if(paymentData.itemspayment[i].paymentMode == "0") {
                  _groupValue = i;
                  _isSod = true;
                  break;
                }else if(paymentData.itemspayment[i].paymentMode == "6") {
                  _groupValue = i;
                  _isCOD = true;
                  break;
                }
              }
              if(_isOnline || _isCOD || _isSod) {
                _groupValue = -1;
                _isRemainingAmount = true;
                walletAmount = double.parse(walletbalance);
                remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) && double.parse(loyaltyPointsUser.toString()) >=100 ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - double.parse(walletbalance));
              } else {
                _isWallet = false;
                _ischeckbox = false;
              }
              for(int i = 0; i < paymentData.itemspayment.length; i++) {
                if(paymentData.itemspayment[i].paymentMode == "1" || paymentData.itemspayment[i].paymentMode == "6" || paymentData.itemspayment[i].paymentMode == "0") {
                  _groupValue = i;
                  break;
                }
              }
            }
          } else {
            _ischeckbox = false;
          }

          //if both wallet is not there in payment method
          if(!_isWallet) {
            _groupValue = 0;
            if(paymentData.itemspayment[0].paymentMode == "1") {
              prefs.setString("payment_type", "paytm");
            } else {
              prefs.setString("payment_type", paymentData.itemspayment[0].paymentType);
            }
          }

        });
      });
      packageInfo = await PackageInfo.fromPlatform();
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    _message.dispose();
    super.dispose();
  }
  _customToast(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
          );
        });
  }
  Future<void> _cancelOrder() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'cancel-order';
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "id": prefs.getString('orderId'),
            "note": "Payment cancelled by user",
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(response.body);
      if(responseJson['status'].toString() == "200"){
        prefs.remove("orderId");
        await Provider.of<BrandItemsList>(context,listen: false).fetchWalletBalance().then((_) {
          setState(() {

          });
        });
      }

    } catch (error) {
      //_customToast("Something went wrong!!!");
      Fluttertoast.showToast(msg: "Something went wrong!!!");
      throw error;
    }
  }

  Widget _myRadioButton({String title, int value, Function onChanged}) {
    if (_groupValue != -1) {
      if (paymentData.itemspayment[_groupValue].paymentType == "online") {
        prefs.setString("payment_type", "paytm");
      } /*else if (paymentData.itemspayment[_groupValue].paymentType == "pickupfromstore") {
        prefs.setString("payment_type", "pickup");
      }*/
      else {
        prefs.setString(
            "payment_type", paymentData.itemspayment[_groupValue].paymentType);
      }
    }
    prefs.setString("amount", "0");
    prefs.setString("wallet_type", "4");

    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
      //title: Text(title),
    );
  }

  Future<void> Orderfood() async {
    // imp feature in adding async is the it automatically wrap into Future.
    final routeArgs =
    ModalRoute.of(context).settings.arguments as Map<String, String>;

    var url = IConstants.API_PATH + 'order/new-order';
    String channel = "";
    var membership = "";
    var index = "";

    for (int i = 0; i < productBox.length; i++) {
      if (productBox.values.elementAt(i).mode == 1) {
        index = i.toString();
        membership = productBox.values.elementAt(i).membershipId.toString();
      }
    }

    try {
      if (Platform.isIOS) {
        channel = "IOS";
      } else {
        channel = "Android";
      }
    } catch (e) {
      channel = "Web";
    }

    try {
      final loyaltyData = Provider.of<BrandItemsList>(context,listen: false);
      var resBody = {};
      resBody["userId"] = prefs.getString('userID');
      resBody["walletType"] = prefs.getString("wallet_type");
      resBody["walletBalance"] = prefs.getString('amount');
      resBody["apiKey"] = prefs.getString('apiKey');
      resBody["restId"] = /*prefs.getString('resId')*/ "0";
      resBody["addressId"] = prefs.getString('addressId');
      resBody["orderType"] = _isPickup ? "pickup" : (routeArgs['deliveryType'] == "express") ? "express" : "Delivery";
      resBody["paymentType"] = prefs.getString('payment_type');
      resBody["promocode"] = _promocode;
      resBody["fix_time"] = _isPickup ? prefs.getString('fixtime')
          : /*(routeArgs['deliveryType'] == "express") ? "" :*/ prefs.getString('fixtime');
      resBody["fixdate"] = _isPickup ? prefs.getString('fixdate') : /*(routeArgs['deliveryType'] == "express") ? "" :*/ prefs.getString('fixdate');
      resBody["promo"] = _promocode;
//      resBody["membership"] = prefs.getString('fixtime');
      resBody["channel"] = channel;
      resBody["membership"] = membership;
      resBody["membership_active"] = prefs.getString("membership");
      resBody["note"] = note;
      resBody["branch"] = prefs.getString("branch");
      resBody["loyalty"] = (_isSwitch && _isLoayalty && (double.parse(loyaltyPoints) > 0) && double.parse(loyaltyPointsUser.toString()) >=100) ? "1" : "0";
      resBody["loyalty_points"] = loyaltyPointsUser./*roundToDouble().*/toStringAsFixed(2);
      resBody["point"] = (loyaltyData.itemsLoyalty.length > 0) ? loyaltyData.itemsLoyalty[0].points.toString() : "0";
      resBody["version"] = _isWeb ? "web 1.0.0" : packageInfo.version + "+" + packageInfo.buildNumber;
      for (int i = 0; i < productBox.length; i++) {
        if (index != "") {
          if (int.parse(index) == i) {
          } else {
            resBody["items[" + i.toString() + "][productId]"] =
                productBox.values.elementAt(i).itemId.toString();
            resBody["items[" + i.toString() + "][priceVariation]"] =
                productBox.values.elementAt(i).varId.toString();
            resBody["items[" + i.toString() + "][quantity]"] =
                productBox.values.elementAt(i).itemQty.toString();
          }
        } else {
          resBody["items[" + i.toString() + "][productId]"] =
              productBox.values.elementAt(i).itemId.toString();
          resBody["items[" + i.toString() + "][priceVariation]"] =
              productBox.values.elementAt(i).varId.toString();
          resBody["items[" + i.toString() + "][quantity]"] =
              productBox.values.elementAt(i).itemQty.toString();
        }
      }

      final response = await http.post(
        url,
        body: resBody,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      _isorder = true;
      if (responseJson['status'].toString() == "true") {
        if (prefs.getString('payment_type') == "paytm") {
          final orderencode = json.encode(responseJson['order']);
          final orderdecode = json.decode(orderencode);
          String orderAmount = orderdecode['orderAmount'].toString();
          String wallet=orderdecode['wallet'].toString();
          String deliverycharge=orderdecode['deliveryCharge'].toString();
          String actualamount=orderdecode['actualAmount'].toString();
          String totaldiscount=orderdecode['totalDiscount'].toString();
          double total;
          if(deliverycharge !=0){
            total= double.parse(actualamount) +
                double.parse(deliverycharge) -double.parse(wallet)
                - double.parse(totaldiscount);
          }
          else{
            total= double.parse(orderAmount)-double.parse(wallet)
                - double.parse(totaldiscount);
          }
          prefs.setString("orderId", orderdecode['id'].toString());

          final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
          Navigator.of(context).pop();
          Navigator.of(context)
              .pushReplacementNamed(PaytmScreen.routeName, arguments: {
            'orderId': orderdecode['id'].toString(),
            'orderAmount': total.toStringAsFixed(2),
            'minimumOrderAmountNoraml': routeArgs['minimumOrderAmountNoraml'],
            'deliveryChargeNormal': routeArgs['deliveryChargeNormal'],
            'minimumOrderAmountPrime': routeArgs['minimumOrderAmountPrime'],
            'deliveryChargePrime': routeArgs['deliveryChargePrime'],
            'minimumOrderAmountExpress': routeArgs['minimumOrderAmountExpress'],
            'deliveryChargeExpress': routeArgs['deliveryChargeExpress'],
            'deliveryType': routeArgs['deliveryType'],
            'note': routeArgs['note'],
          });
        } else {
          for (int i = 0; i < productBox.length; i++) {
            if (productBox.values.elementAt(i).mode == 1) {
              prefs.setString("membership", "2");
            }
          }
          //productBox.deleteFromDisk();
          productBox.clear();
          //await DBProvider.db.deleteAllItem();
          Navigator.of(context).pushReplacementNamed(
              OrderconfirmationScreen.routeName,
              arguments: {
                'orderstatus': "success",
              });
        }
      } else {
        setState(() {
          _checkpromo = false;
          Navigator.of(context).pop();
         // _customToast("Something went wrong!!!");
          return Fluttertoast.showToast(msg: "Something went wrong!!!");
        });
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> checkPromo() async {
    // imp feature in adding async is the it automatically wrap into Future.
    if (myController.text == "") {
      setState(() {
        _checkpromo = false;
        // Navigator.of(context).pop();
      });
     if(_isWeb && !ResponsiveLayout.isSmallScreen(context)) {
       Navigator.of(context).pop();
      // _customToast(translate('forconvience.validpromo'));
     }
     else {
       return Fluttertoast.showToast(msg: translate(
           'forconvience.validpromo'), //"Please enter a valid Promocode!!!"

       );
     }
    } else {
      var item = [];
      for (int i = 0; i < productBox.length; i++) {
        if (_checkmembership) {
          if (productBox.values.elementAt(i).itemPrice <= 0 ||
              productBox.values.elementAt(i).itemPrice.toString() == "" ||
              productBox.values.elementAt(i).itemPrice ==
                  productBox.values.elementAt(i).varMrp) {
            promovarprice = productBox.values.elementAt(i).varMrp.toString();
          } else {
            promovarprice = productBox.values.elementAt(i).itemPrice.toString();
          }
        } else {
          if (double.parse(productBox.values.elementAt(i).membershipPrice) <=
              0 ||
              productBox.values.elementAt(i).membershipPrice == "" ||
              double.parse(productBox.values.elementAt(i).membershipPrice) ==
                  productBox.values.elementAt(i).varMrp) {
            promovarprice = productBox.values.elementAt(i).varMrp.toString();
          } else {
            promovarprice = productBox.values.elementAt(i).membershipPrice;
          }
        }
        var item1 = {};
        item1["\"itemid\""] =
            "\"" + productBox.values.elementAt(i).varId.toString() + "\"";
        item1["\"qty\""] = productBox.values.elementAt(i).itemQty.toString();
        item1["\"price\""] = promovarprice;
        item.add(item1);
      }

      var url = IConstants.API_PATH + 'check-promocode';
      try {
        setState(() {
          _promocode = myController.text;
        });
        final response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "promocode": myController.text,
          "items": item.toString(),
          "user": prefs.getString('userID'),
          "total": cartTotal.toString(),
          "delivery": _isPickup ? "0.0" : deliveryamount.toString(),
          "branch": prefs.getString('branch'),
        });
        final responseJson = json.decode(response.body);

        if (responseJson['status'].toString() == "done") {
          if (responseJson['prmocodeType'].toString() == "cashback")
            setState(() {
              _checkpromo = false;
              _displaypromo = true;
              _savedamount = "0.0";
              if (_isPickup)
                _promoamount = (cartTotal).toString();
              else
                _promoamount = ((cartTotal + deliveryamount)).toString();
              _promocode = myController.text;

              walletAmount = double.parse(walletbalance);
              remainingAmount = double.parse(_promoamount) - double.parse(walletbalance);
            });
          else
            setState(() {
              _checkpromo = false;
              _displaypromo = true;
              _savedamount = responseJson['amount'].toString();
              if (_isPickup)
                _promoamount = (cartTotal -
                    double.parse(responseJson['amount'].toString()))
                    .toString();
              else
                _promoamount = ((cartTotal + deliveryamount) -
                    double.parse(responseJson['amount'].toString()))
                    .toString();

              _promocode = myController.text;

              walletAmount = double.parse(walletbalance);
              if(walletAmount >= (cartTotal + deliveryamount)){
                walletAmount= double.parse(walletbalance) + ( double.parse(_promoamount) - double.parse(walletbalance));
              }
              else {
                remainingAmount =
                    double.parse(_promoamount) - double.parse(walletbalance);
                if(remainingAmount < 0){
                  walletAmount= double.parse(walletbalance) + ( double.parse(_promoamount) - double.parse(walletbalance));
                  remainingAmount =
                      walletAmount - double.parse(_promoamount);
                  setState(() {
                    if (_isWallet) {
                      double totalAmount = 0.0;
                      !_displaypromo ?
                      _isPickup ? totalAmount = cartTotal : totalAmount =
                      (cartTotal + deliveryamount) : totalAmount =
                      (double.parse(_promoamount));

                      if (double.parse(walletbalance) <= 0
                      /*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*/) {
                        _isRemainingAmount = false;
                        _ischeckboxshow = false;
                        _ischeckbox = false;
                      } else if (_isSwitch
                          ? totalAmount <=
                          (double.parse(walletbalance) /*+ loyaltyAmount*/)
                          : totalAmount <= (double.parse(walletbalance))) {
                        _isRemainingAmount = false;
                        _groupValue = -1;
                        prefs.setString("payment_type", "wallet");
                        walletAmount =
                        _isSwitch ? (totalAmount /*- loyaltyAmount*/) : totalAmount;
                      } else if (_isSwitch
                          ? totalAmount >
                          (double.parse(walletbalance) /*+ loyaltyAmount*/)
                          : totalAmount > double.parse(walletbalance)) {

                        for (int i = 0; i < paymentData.itemspayment
                            .length; i++) {
                          if (paymentData.itemspayment[i].paymentMode == "1") {
                            _groupValue = i;
                            _isOnline = true;
                            break;
                          } else if (paymentData.itemspayment[i].paymentMode ==
                              "0") {
                            _groupValue = i;
                            _isSod = true;
                            break;
                          } else if (paymentData.itemspayment[i].paymentMode ==
                              "6") {
                            _groupValue = i;
                            _isCOD = true;
                            break;
                          }
                        }
                        if (_isOnline || _isCOD || _isSod) {
                          //_groupValue = -1;
                          _isRemainingAmount = true;
                          walletAmount = double.parse(walletbalance);
                          remainingAmount = _isSwitch && !_isLoyaltyToast &&
                              _isLoayalty && (double.parse(loyaltyPoints) > 0)
                              ? totalAmount - double.parse(walletbalance) -
                              loyaltyAmount
                              : (totalAmount - double.parse(walletbalance));
                        } else {
                          _isWallet = false;
                          _ischeckbox = false;
                        }
                        for (int i = 0; i < paymentData.itemspayment
                            .length; i++) {
                          if (paymentData.itemspayment[i].paymentMode == "1" ||
                              paymentData.itemspayment[i].paymentMode == "6" ||
                              paymentData.itemspayment[i].paymentMode == "0") {
                            _groupValue = i;
                            break;
                          }
                        }
                      }
                    } else {
                      _ischeckbox = false;
                    }
                  });
                }
                else{
                  remainingAmount =
                      double.parse(_promoamount) - double.parse(walletbalance);
                }
              }
              promocashbackmsg = responseJson['msg'].toString();
              promomessage = responseJson['prmocodeType'].toString();
            });

          //Apply loaylty after applied promocde
          if (_isLoayalty &&
              responseJson['prmocodeType'].toString() != "cashback") {
            await Provider.of<BrandItemsList>(context,listen: false)
                .checkLoyalty(_promoamount)
                .then((_) {
              setState(() {
                _isSwitch = true;
                double totalAmount = 0.0; //Order amount
                !_displaypromo
                    ? _isPickup
                    ? totalAmount = cartTotal
                    : totalAmount = (cartTotal + deliveryamount)
                    : totalAmount = (double.parse(_promoamount));

                //check user eligible to use Loyalty points or not
                final loyaltyData = Provider.of<BrandItemsList>(context,listen: false);
                if (double.parse(
                    loyaltyData.itemsLoyalty[0].minimumOrderAmount) <=
                    totalAmount) {
                  _isSwitch = true;
                  _isLoyaltyToast = false;
                  //Compare user loyalty balance to apply loyalty points
                  if (prefs.getDouble("loyaltyPointsUser") <=
                      double.parse(loyaltyPoints)) {
                    loyaltyPointsUser = prefs.getDouble("loyaltyPointsUser");
                    loyaltyAmount = ((loyaltyPointsUser * 1) /
                        double.parse(loyaltyData.itemsLoyalty[0].points));
                  } else {
                    /*loyaltyPointsUser = prefs.getDouble("loyaltyPointsUser") - int.parse(loyaltyPoints);
                    loyaltyAmount = ((loyaltyPointsUser * 1) / int.parse(loyaltyData.itemsLoyalty[0].points));*/

                    loyaltyPointsUser = double.parse(loyaltyPoints);
                    loyaltyAmount = ((loyaltyPointsUser * 1) /
                        double.parse(loyaltyData.itemsLoyalty[0].points));
                  }
                } else {
                  _isSwitch = true;
                  _isLoyaltyToast = true;
                }


                //Consider wallet and loyalty
                if (_isWallet) {
                  double totalAmount = 0.0;
                  !_displaypromo
                      ? _isPickup
                      ? totalAmount = cartTotal
                      : totalAmount = (cartTotal + deliveryamount)
                      : totalAmount = (double.parse(_promoamount));

                  if (double.parse(walletbalance) <=
                      0 /*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*/) {
                    _isRemainingAmount = false;
                    _ischeckboxshow = false;
                    _ischeckbox = false;
                    _isRemainingAmount = false;
                  } else if (_isSwitch &&
                      !_isLoyaltyToast &&
                      _isLoayalty &&
                      (double.parse(loyaltyPoints) > 0)
                      ? totalAmount <=
                      (double.parse(walletbalance) + loyaltyAmount)
                      : totalAmount <= (double.parse(walletbalance))) {
                    _isRemainingAmount = false;
                    _groupValue = -1;
                    prefs.setString("payment_type", "wallet");
                    walletAmount = _isSwitch &&
                        !_isLoyaltyToast &&
                        _isLoayalty &&
                        (double.parse(loyaltyPoints) > 0)
                        ? (totalAmount /*- loyaltyAmount*/)
                        : totalAmount;
                  } else if (_isSwitch &&
                      !_isLoyaltyToast &&
                      _isLoayalty &&
                      (double.parse(loyaltyPoints) > 0)
                      ? totalAmount > (double.parse(walletbalance) /*+ loyaltyAmount*/)
                      : totalAmount > double.parse(walletbalance)) {
                    bool _isOnline = false;
                    bool _isSod = false;
                    for (int i = 0; i < paymentData.itemspayment.length; i++) {
                      if (paymentData.itemspayment[i].paymentMode == "1") {
                        _groupValue = i;
                        _isOnline = true;
                        break;
                      }
                     else if (paymentData.itemspayment[i].paymentMode == "0") {
                        _groupValue = i;
                        _isSod = true;
                        break;
                      }
                      else if (paymentData.itemspayment[i].paymentMode == "6") {
                        _groupValue = i;
                        _isCOD = true;
                        break;
                      }
                    }
                    if (_isOnline||_isSod || _isCOD) {
                      //_groupValue = -1;
                      _isRemainingAmount = true;
                      walletAmount = double.parse(walletbalance);
                      remainingAmount = _isSwitch &&
                          !_isLoyaltyToast &&
                          _isLoayalty &&
                          (double.parse(loyaltyPoints) > 0)
                          ? totalAmount -
                          double.parse(walletbalance) /*-
                          loyaltyAmount*/
                          : (totalAmount - double.parse(walletbalance));
                    } else {
                      _isWallet = false;
                      _ischeckbox = false;
                    }
                    for (int i = 0; i < paymentData.itemspayment.length; i++) {
                      if (paymentData.itemspayment[i].paymentMode == "1") {
                        _groupValue = i;
                        break;
                      }
                    }
                  }
                } else {
                  _ischeckbox = false;
                }

                // Navigator.of(context).pop();
              });
            });
            _isSwitch = false;
          } else {
            //  Navigator.of(context).pop();
          }
        } else if (responseJson['status'].toString() == "error") {
          setState(() {
            _checkpromo = false;
            _displaypromo = false;
            _savedamount = "";
            _promoamount = "";
            _promocode = "";
            _isSwitch = false;
          });
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context)) {
            Navigator.of(context).pop();
          }else {
            return Fluttertoast.showToast(msg: responseJson['msg'].toString());
          }
        }
      } catch (error) {
        throw error;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isPaymentMethod = false;
    paymentData = Provider.of<BrandItemsList>(context,listen: false);
    final loyaltyData = Provider.of<BrandItemsList>(context,listen: false);

    if (paymentData.itemspayment.length <= 0) {
      _isPaymentMethod = false;
    } else {
      _isPaymentMethod = true;
    }

    if (_ischeckbox && _isRemainingAmount) {
      _isRemainingAmount = true;
    } else {
      _isRemainingAmount = false;
    }

    double deliveryamount = 0;

    if (cartTotal < minorderamount) {
      deliveryamount = deliverycharge;
    }

    String deliverychargetext;
    if (!_isLoading) if (_checkmembership
        ? (Calculations.totalMember < minorderamount)
        : (Calculations.total < minorderamount)) {
      if (deliverycharge <= 0) {
        deliverychargetext =  translate('forconvience.FREE');//"FREE";
      } else {
        deliverychargetext =
            "+ "  + " " + deliverycharge.toStringAsFixed(2) + _currencyFormat;
      }
    } else {
      deliverychargetext =  translate('forconvience.FREE');//"FREE";
    }
    void _handleRadioValueChange1(int value) {
      setState(() {
        _groupValue = value;
        _ischeckbox = false;
      });
    }
    _dialogforPromo(BuildContext context) {
      return showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                child: Container(
                    width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width,
                    height: 180.0,
                    child: !_checkpromo
                        ? Column(
                      children: <Widget>[
                        SizedBox(height: 20.0),
                        Text(
                            translate('forconvience.Enter Promo'),//"Apply promo code",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: 120.0,
                          //height: 10.0,
                          child: TextField(
                            controller: myController,
                            onSubmitted: (String newVal) {
                              /*prefs.setString("promovalue", newVal);
                                  setState(() {
                                    _checkpromo = true;
                                    _promocode = newVal;
                                  });*/
                              setState(() {
                                _isLoayalty = false;
                                _checkpromo = true;
                              });
                              checkPromo();
                            },
                          ),
                        ),
                        SizedBox(height: 20.0),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLoayalty = false;
                                _checkpromo = true;
                              });
                              checkPromo();
                            },
                            child: Container(
                              width: 120.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(3.0),
                                  border: Border(
                                    top: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,
                                    ),
                                    bottom: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,
                                    ),
                                    left: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,
                                    ),
                                    right: BorderSide(
                                      width: 1.0,
                                      color: Colors.grey,
                                    ),
                                  )),
                              child: Center(
                                  child: Text(
                                    translate('forconvience.Apply'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Center(
                      child: CircularProgressIndicator(
                        valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                      ),
                    )),
              );
            });
          });
    }

    _dialogforOrdering(BuildContext context) {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return StatefulBuilder(builder: (context, setState) {
              return AbsorbPointer(
                child: WillPopScope(
                  onWillPop: (){
                    return Future.value(false);
                  },
                  child: Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.0)),
                    child: Container(
                        width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.20:MediaQuery.of(context).size.width,
                        // color: Theme.of(context).primaryColor,
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
                            Text(translate('forconvience.Placing order'),),//'Placing order...'),
                          ],
                        )),
                  ),
                ),
              );
            });
          });
    }

    _buildBottomNavigationBar() {
      return SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: Row(
            children: <Widget>[
              Container(
                  color: Theme.of(context).primaryColor,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 40 / 100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:37.0),
                        child: Row(

                          children: [
                            !_displaypromo
                                ? _isPickup
                                ? _isSwitch &&
                                !_isLoyaltyToast &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0)
                                ?
                            Text(
                              /*"Total: " +*/
                              translate('forconvience.Amount Payable')+":"//'Total: '
                              +" " +
                                  (cartTotal - loyaltyAmount)
                                      /*.roundToDouble()*/
                                      .toStringAsFixed(2)+  _currencyFormat ,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                                : Text(
                              /* "Total: " +
*/
                              translate('forconvience.Amount Payable')+":"+
                              " " +
                                  cartTotal.toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                                :
                            (_ischeckboxshow && _ischeckbox && _isSwitch &&
                            !_isLoyaltyToast &&
                            _isLoayalty &&
            (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100))?
                            Text(
                              /*  "Total: " +*/
                              translate('forconvience.Amount Payable')+":"+
                              " " +
                                  (remainingAmount )
                                      .toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(

                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ):

                            _isSwitch &&
                                !_isLoyaltyToast &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100)
                                ?
                            Text(
                              /* "Total: " +*/
                              translate('forconvience.Amount Payable')+":"+
                              " " +
                                 /* (cartTotal + deliveryamount)
                                      .toStringAsFixed(2)+ _currencyFormat,*/
                              /*(remainingAmount )
                                      .toStringAsFixed(2)+ _currencyFormat*/
                              (cartTotal +
                                      deliveryamount -
                                      loyaltyAmount)
                                      /*.roundToDouble()*/
                                      .toStringAsFixed(2)+ _currencyFormat,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                                :
                            (_ischeckboxshow && _ischeckbox)?
                            Text(
                              /*  "Total: " +*/
                              translate('forconvience.Amount Payable')+":"+
                              " " +
                                  (remainingAmount )
                                      .toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(

                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ):
                            Text(
                              /*  "Total: " +*/
                              translate('forconvience.Amount Payable')+":"+
                              " " +
                                  (cartTotal + deliveryamount)
                                      .toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                                : Row(
                                 // mainAxisAlignment: MainAxisAlignment.center,
                                    //crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                            /*  SizedBox(
                                width: 10,
                              ),*/
                              if (promomessage.toLowerCase() == 'cashback')
                                _isSwitch &&
                                    !_isLoyaltyToast &&
                                    _isLoayalty &&
                                    (double.parse(loyaltyPoints) > 0)
                                    ? Text(
                                  /* "Total: " +*/
                                  translate('forconvience.Amount Payable')+":"+
                                  " " +
                                      (cartTotal +
                                          deliveryamount -
                                          loyaltyAmount)
                                          /*.roundToDouble()*/
                                          .toStringAsFixed(2)+ _currencyFormat ,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                 // textAlign: TextAlign.center,
                                )
                                    : Text(
                                  /*  "Total: " +*/
                                  translate('forconvience.Amount Payable')+":"+
                                  " " +
                                      (cartTotal + deliveryamount)
                                          .toStringAsFixed(2)+ _currencyFormat ,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  //textAlign: TextAlign.center,
                                )
                              else
                                _isSwitch &&
                                    !_isLoyaltyToast &&
                                    _isLoayalty &&
                                    (double.parse(loyaltyPoints) > 0)
                                    ? Text(
                                  /*"Total: " +*/
                                  translate('forconvience.Amount Payable')+":"+
                                    " " +
                                        (double.parse(_promoamount) -
                                            loyaltyAmount)
                                            /*.roundToDouble()*/
                                            .toStringAsFixed(2)+ _currencyFormat ,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                    //textAlign: TextAlign.center
      )
                                    : Text(
                                  /* "Total: " +*/
                                  translate('forconvience.Amount Payable')+":"+
                                    " " +
                                        remainingAmount
                                            .toStringAsFixed(2)+ _currencyFormat ,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                   // textAlign: TextAlign.center
                                ),
                              /*_isWallet?Text(
                                *//*"Total: " +*//*

                                  " " +
                                      remainingAmount.toStringAsFixed(2)+ _currencyFormat ,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)
                                  :
                              Text(
                                *//*"Total: " +*//*

                                  " " +
                                      (double.parse(_promoamount) -
                                          loyaltyAmount)
                                          .roundToDouble()
                                          .toString()+ _currencyFormat ,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center)*/
//Spacer(),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  )),
              !_isPaymentMethod
                  ? GestureDetector(
                onTap: () {
                //  _customToast("currently there are no payment methods available");
                  Fluttertoast.showToast(
                      msg:
                      "currently there are no payment methods available");
                },
                child: Container(
                  color: Colors.grey,
                  width: MediaQuery.of(context).size.width * 60 / 100,
                  height: 50,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 17,
                      ),
                      Center(
                        child: Text(
                          translate('forconvience.PROCEED TO PAY'),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              )
                  : GestureDetector(
                onTap: () {
                  if (!_ischeckbox && _groupValue == -1) {
                    if(_isWeb && !ResponsiveLayout.isSmallScreen(context)) {
                    //  _customToast(translate('forconvience.select payment'));
                    }else {
                      Fluttertoast.showToast(
                          msg: translate(
                              'forconvience.select payment') //"Please select a payment method!!!"

                      );
                    }
                  } else {
                    if (_ischeckbox && _isRemainingAmount && _isOnline) {
                      prefs.setString("payment_type", "paytm");
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    else if(_ischeckbox && _isRemainingAmount && _isSod){
                      prefs.setString("payment_type", "sod");
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }

                    else if(_ischeckbox && _isRemainingAmount && _isCOD){
                      prefs.setString("payment_type", "cod");
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    else if (_ischeckbox) {
                      prefs.setString("payment_type", "wallet");
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    _dialogforOrdering(context);
                    Orderfood();
                  }
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width * 60 / 100,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                    //  SizedBox(width: 100,),
                      Padding(
                        padding: const EdgeInsets.only(right:37.0),
                        child: Center(
                          child: Text(
                            translate('forconvience.PROCEED TO PAY'),

                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),

                        ),
                      ),
                     /* Center(
                        child: Icon(
                          Icons.arrow_right,
                          color: ColorCodes.whiteColor,
                        ),
                      ),*/
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    gradientappbarmobile() {
      return AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
            onPressed: () => 
                // _isorder?Fluttertoast.showToast(msg: "Order Processing...") :
                Navigator.of(context).pop()),
        title: Text(
          translate('forconvience.Payment Options'),style: TextStyle(color: ColorCodes.backbutton,fontWeight: FontWeight.bold),
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    ColorCodes.whiteColor,
                    ColorCodes.whiteColor
                  ])),
        ),
      );
    }

    Widget _bodyWeb() {

      double amountPayable = 0.0;

      Widget promocodeMethod() {
        if ((Calculations.totalmrp - amountPayable) > 0) {
          return Column(
            children: [
              SizedBox(
                height: 10.0,
              ),
              /*DottedBorder(
                padding: EdgeInsets.zero,
                color: ColorCodes.mediumBlueColor,
                //strokeWidth: 1,
                dashPattern: [3.0],
                child: Container(
                  padding: EdgeInsets.only(left: 6.0, right: 6.0),
                  height: 30.0,
                  color: ColorCodes.lightBlueColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Your savings",
                        style: TextStyle(
                            fontSize: 12.0,
                            color: ColorCodes.mediumBlueColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(

                        " " +
                            (Calculations.totalmrp - amountPayable)
                                .toStringAsFixed(2)+ _currencyFormat ,
                        style: TextStyle(
                            fontSize: 12.0,
                            color: ColorCodes.mediumBlueColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),*/
              SizedBox(
                height: 10.0,
              ),
              Divider(color: ColorCodes.blackColor),
            ],
          );
        } else {
          return Container();
        }
      }

      Widget paymentDetails() {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.40,
              color: ColorCodes.whiteColor,
              padding: EdgeInsets.only(
                  top: 8.0, left: 10.0, right: 10.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.40,
                    margin: EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        /*Text(
                          translate('forconvience.Amount Payable'),
                          style: TextStyle(
                              fontSize: 15.0,
                              color: ColorCodes.blackColor,
                              fontWeight: FontWeight.bold),
                        ),*/
                      /*  Text(
                          "(Incl. of all taxes)",
                          style: TextStyle(
                              fontSize: 10.0, color: ColorCodes.blackColor),
                        ),*/
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate('forconvience.Sub-Total'),
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: ColorCodes.mediumBlackColor),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            if (!_isPickup)
                              Text(
                                translate('forconvience.Delivery charges'),
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            if (!_isPickup)
                              SizedBox(
                                height: 10.0,
                              ),
                           /* if ((Calculations.totalmrp - cartTotal) > 0)
                              Text(
                                "Discount applied:",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            if ((Calculations.totalmrp - cartTotal) > 0)
                              SizedBox(
                                height: 10.0,
                              ),*/


                            if (_isPaymentMethod)
                              if (_isWallet)
                                if(_ischeckboxshow)
                                  GestureDetector(
                                    // behavior: HitTestBehavior.translucent,
                                    /* onTap: () {
                                      setState(() {
                                        _ischeckbox = !_ischeckbox;
                                        double totalAmount = 0.0;
                                        !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                        if(_isWallet) {
                                          if (int.parse(walletbalance) <= 0 *//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//*) {
                                            _isRemainingAmount = false;
                                            _ischeckboxshow = false;
                                            _ischeckbox = false;
                                          } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                            _isRemainingAmount = false;
                                            _groupValue = -1;
                                            prefs.setString("payment_type", "wallet");
                                            walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                          } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                            bool _isOnline = false;
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _isOnline = true;
                                                break;
                                              }
                                            }
                                            if(_isOnline) {
                                              _groupValue = -1;
                                              _isRemainingAmount = true;
                                              walletAmount = double.parse(walletbalance);
                                              remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                            } else {
                                              _isWallet = false;
                                              _ischeckbox = false;
                                            }
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _groupValue = i;
                                                break;
                                              }
                                            }

                                          }
                                        } else {
                                          _ischeckbox = false;
                                        }
                                      });
                                    },*/
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*0.30,
                                      color: ColorCodes.whiteColor,
                                     /* padding: EdgeInsets.only(
                                        // top: 10.0,
                                        right: 5.0, ),*/
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,

                                        children: <Widget>[
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                _ischeckbox
                                                    ? SizedBox.shrink()
                                                    : Icon(
                                                      Icons.check_box_outline_blank,
                                                      size: 15.0,
                                                      color: ColorCodes.whiteColor,
                                                    ),
                                                Text(
                                                  // IConstants.APP_NAME +
                                                  translate('bottomnavigation.wallet'),//" Wallet",
                                                  style: TextStyle(
                                                    color: ColorCodes.blackColor,
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,),
                                                ),
                                                /* if (_ischeckboxshow && _ischeckbox)
                                                Image.asset(Images.walletImg,
                                                    height: 15.0,
                                                    width: 18.0,
                                                    color: Theme.of(context).primaryColor),*/
                                                if (_ischeckboxshow && _ischeckbox)
                                                  SizedBox(
                                                    width: 3.0,
                                                  ),

                                                //SizedBox(width: 20.0),

                                              ],
                                            ),
                                          ),
                                          /*   Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              IConstants.APP_NAME + " Wallet",
                                              style: TextStyle(
                                                  color: ColorCodes.blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Balance:  ",
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                                Image.asset(Images.walletImg,
                                                    height: 13.0,
                                                    width: 16.0,
                                                    color: Theme.of(context).primaryColor),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  _currencyFormat + " " + walletbalance,
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),*/

                                        ],
                                      ),
                                    ),
                                  ),
                            if(_ischeckboxshow)
                              (_ischeckbox)?
                              SizedBox(
                                height: 10.0,
                              ): SizedBox(
                                height: 20.0,
                              )
                            ,

                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              new RichText(
                                text: new TextSpan(
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: ColorCodes.mediumBlackColor),
                                  children: <TextSpan>[
                                    new TextSpan(text: translate('forconvience.Discount Applied (HELLO)')+"("),//'Promo ('),
                                    new TextSpan(
                                      text: _promocode,
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: ColorCodes.orangeColor),
                                    ),
                                    new TextSpan(text: ')'),
                                  ],
                                ),
                              ),
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              SizedBox(
                                height: 10.0,
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0))
                              new RichText(
                                text: new TextSpan(
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: ColorCodes.mediumBlackColor),
                                  children: <TextSpan>[
                                    new TextSpan(text: 'You saved ('),
                                    new TextSpan(
                                      text: 'Coins',
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: ColorCodes.orangeColor),
                                    ),
                                    new TextSpan(text: ')'),
                                  ],
                                ),
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0))
                              SizedBox(
                                height: 10.0,
                              ),
                            Text(
                              translate('forconvience.Amount Payable'), //"Amount payable:",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: ColorCodes.mediumBlackColor),
                            ),
                          ],
                        ),
                        Container(
                            child: VerticalDivider(
                                color: ColorCodes.dividerColor)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(

                              " " +
                                  cartTotal.toStringAsFixed(2)+  _currencyFormat ,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: ColorCodes.mediumBlackColor),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            if (!_isPickup)
                              Text(
                                deliverychargetext,
                                style: TextStyle(
                                    fontSize: 12.0, color: ColorCodes.redColor),
                              ),
                            if (!_isPickup)
                              SizedBox(
                                height: 10.0,
                              ),
                            /*if ((Calculations.totalmrp - cartTotal) > 0)
                              Text(
                                "- " +
                                    (Calculations.totalmrp - cartTotal)
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            if ((Calculations.totalmrp - cartTotal) > 0)
                              SizedBox(
                                height: 10.0,
                              ),*/


                            if (_ischeckboxshow && _ischeckbox)
                              Text(
                                " " +
                                    walletAmount.toStringAsFixed(2)+  _currencyFormat,
                                style: TextStyle(
                                    color: ColorCodes.blackColor,
                                    fontSize: 12.0),
                              ),
                            if(_ischeckboxshow)
                              (_ischeckbox)?
                              SizedBox(
                                height: 10.0,
                              ): SizedBox(
                                height: 20.0,
                              )
                            ,
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              Text(
                                "- " +

                                    " " +
                                    double.parse(_savedamount)
                                        .toStringAsFixed(2)+ _currencyFormat ,
                                style: TextStyle(
                                    fontSize: 10.0,
                                    color: ColorCodes.greenColor),
                              ),
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              SizedBox(
                                height: 10.0,
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0))
                              Text(
                                "- " +
                                    " " +
                                    loyaltyAmount.toStringAsFixed(2) +
                                    _currencyFormat,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.greenColor),
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0))
                              SizedBox(
                                height: 10.0,
                              ),
                            (_ischeckboxshow && _ischeckbox)?
                            Text(

                              " " +
                                  remainingAmount.toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorCodes.mediumBlackColor),
                            ):

                            Text(

                              " " +
                                  amountPayable.toStringAsFixed(2)+ _currencyFormat ,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorCodes.mediumBlackColor),
                            ),
                           /* _isWallet?
                            Text(

                              " " +
                                  remainingAmount.toStringAsFixed(2)+  _currencyFormat ,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorCodes.mediumBlackColor),
                            ):
                            Text(

                              " " +
                                  amountPayable.toStringAsFixed(2)+  _currencyFormat ,
                              style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: ColorCodes.mediumBlackColor),
                            ),*/
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Divider(
                    color: ColorCodes.dividerColor,
                    thickness: 0.8,
                  ),

                  // promocodeMethod() goes here
                  promocodeMethod(),
                ],
              ),
            ),
            (productBox.length == 1 && productBox.values.elementAt(0).mode == 1)
                ? SizedBox.shrink()
                :MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _dialogforPromo(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  color: ColorCodes.whiteColor,
                  padding:
                  EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
        translate('forconvience.Enter Promo'),  // "Apply Promo Code",
                        style: TextStyle(
                            color: ColorCodes.blackColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: ColorCodes.greyColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            (productBox.length == 1 && productBox.values.elementAt(0).mode == 1)
                ? SizedBox.shrink()
                : Divider(
              color: ColorCodes.lightGreyColor,
              thickness: 2.5,
              indent: 450,
              endIndent: 450,
            ),
            !_isPaymentMethod
                ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                 // _customToast("currently there are no payment methods available");
                  Fluttertoast.showToast(
                      msg:
                      "currently there are no payment methods available");
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width * 0.40,
                  height: 50,
                  child: Center(
                    child: Text(
                      translate('forconvience.PROCEED TO PAY'),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
                : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (!_ischeckbox && _groupValue == -1) {
                  //  _customToast(translate('forconvience.select payment'));
                    Fluttertoast.showToast(
                        msg: translate('forconvience.select payment'),//"Please select a payment method!!!"
                    );
                  } else {
                    if (_ischeckbox && _isRemainingAmount && _isOnline) {
                      prefs.setString("payment_type", "paytm");
                      //prefs.setString("amount", walletbalance);
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    else if(_ischeckbox && _isRemainingAmount && _isSod){
                      prefs.setString("payment_type", "sod");
                      //prefs.setString("amount", walletbalance);
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    else if(_ischeckbox && _isRemainingAmount && _isCOD){
                      prefs.setString("payment_type", "cod");
                      //prefs.setString("amount", walletbalance);
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }else if (_ischeckbox) {
                      prefs.setString("payment_type", "wallet");
                      //prefs.setString("amount", (cartTotal + deliveryamount).toStringAsFixed(2));
                      prefs.setString(
                          "amount", walletAmount.toStringAsFixed(2));
                      prefs.setString("wallet_type", "0");
                    }
                    _dialogforOrdering(context);
                    Orderfood();
                    /*if(prefs.containsKey("orderId")) {
                            _cancelOrder().then((value) async {
                              Orderfood();
                            });
                          } else {
                            Orderfood();
                          }*/
                  }
                },
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width * 0.40,
                  height: 50,
                  child: Center(
                    child: Text(
                      translate('forconvience.PROCEED TO PAY'),
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      Widget paymentSelection() {
        return Column(
          children: [
            if (_isLoayalty && (double.parse(loyaltyPoints) > 0))
              Container(
                width: MediaQuery.of(context).size.width * 0.40,
                color: ColorCodes.whiteColor,
                padding: EdgeInsets.only(
                    top: 8.0, left: 10.0, right: 10.0, bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pay Using Saving Coins",
                          style: TextStyle(
                              color: ColorCodes.blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              "Balance:  ",
                              style: TextStyle(
                                  color: ColorCodes.blackColor, fontSize: 10.0),
                            ),
                            Image.asset(
                              Images.coinImg,
                              height: 10.0,
                              width: 12.0,
                            ),
                            Text(
                              loyaltyPoints,
                              style: TextStyle(
                                  color: ColorCodes.blackColor, fontSize: 10.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _isLoyaltyToast ?
                             // (_isWeb)? _customToast("Minimum order amount should be " + loyaltyData.itemsLoyalty[0].minimumOrderAmount.toString()):
                          Fluttertoast.showToast(msg: "Minimum order amount should be " + loyaltyData.itemsLoyalty[0].minimumOrderAmount.toString(), backgroundColor: Colors.black87, textColor: Colors.white)
                              :(double.parse(loyaltyPointsUser.toString()) <100)? Fluttertoast.showToast(msg: translate('forconvience.minimum_loyalty')/*"Minimum of dh100 Loyalty Points Required To Use Loyalty for Payment"*//*"Minimum order amount should be "*/ ,  fontSize: MediaQuery.of(context).textScaleFactor *13,backgroundColor: Colors.black87, textColor: Colors.white)//_dialogforloyalty(context)
                          :
                          _isSwitch = !_isSwitch;
                          if(_isWallet) {
                            double totalAmount = 0.0;
                            !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));

                            if (double.parse(walletbalance) <= 0 /*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*/) {
                              _isRemainingAmount = false;
                              _ischeckboxshow = false;
                              _ischeckbox = false;
                            } else if (_isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                              _isRemainingAmount = false;
                              _groupValue = -1;
                              prefs.setString("payment_type", "wallet");
                              walletAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? (totalAmount - loyaltyAmount) : totalAmount;
                            } else if (_isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount > (double.parse(walletbalance) + loyaltyAmount) : totalAmount > double.parse(walletbalance)) {
                              bool _isOnline = false;
                              bool _isSod = false;
                              for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                if(paymentData.itemspayment[i].paymentMode == "1") {
                                  _groupValue = i;
                                  _isOnline = true;
                                  break;
                                }
                                else  if(paymentData.itemspayment[i].paymentMode == "0") {
                                  _groupValue = i;
                                  _isSod = true;
                                  break;
                                }
                              }
                              if(_isOnline || _isSod) {
                                _groupValue = -1;
                                _isRemainingAmount = true;
                                walletAmount = double.parse(walletbalance);
                                remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - double.parse(walletbalance));
                              } else {
                                _isWallet = false;
                                _ischeckbox = false;
                              }
                              for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                if(paymentData.itemspayment[i].paymentMode == "1") {
                                  _groupValue = i;
                                  break;
                                }
                              }
                            }
                          } else {
                            _ischeckbox = false;
                          }
                        });
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            Images.coinImg,
                            height: 12.0,
                            width: 14.0,
                          ),
                          Text(
                            " " +
                                loyaltyPointsUser.toStringAsFixed(2)
                                    /*.roundToDouble()
                                    .toStringAsFixed(0)*/,
                            style: TextStyle(
                                color: ColorCodes.blackColor, fontSize: 12.0),
                          ),
                          SizedBox(width: 20.0),
                          _isLoyaltyToast
                              ? Icon(
                            Icons.radio_button_off,
                            size: 20.0,
                          )
                              : _isSwitch
                              ? Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: ColorCodes.whiteColor,
                              border: Border.all(
                                color: ColorCodes.darkBlueColor,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              margin: EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: ColorCodes.mediumBlueColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check,
                                  color: ColorCodes.whiteColor,
                                  size: 15.0),
                            ),
                          )
                              : Icon(
                            Icons.radio_button_off,
                            size: 20.0,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (_isLoayalty && (double.parse(loyaltyPoints) > 0))
              Divider(
                color: ColorCodes.lightGreyColor,
                thickness: 2.5,
              ),
            if (_isPaymentMethod)
            if (_isPaymentMethod)
              if (_isWallet)
                Divider(
                  color: ColorCodes.lightGreyColor,
                  indent: 450,
                  endIndent: 450,
                ),
            _isPaymentMethod
                ?
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        top:10, bottom: 20.0,right:37,left:37),
                    child: Text(
                      translate('forconvience.Payment Methods'),
                      style: TextStyle(
                          fontSize: 15.0,
                          color: ColorCodes.blackColor,
                          fontWeight: FontWeight.bold),
                    )),
                Divider(
                  height:  0.5,
                  color: ColorCodes.lightGreyColor,

                ),

                Padding(
                  padding: const EdgeInsets.only(left:37.0,right:37,
                      top:15),
                  child:
                  new ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: paymentData.itemspayment.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        if (paymentData.itemspayment[i].paymentMode == "1")

                          _isRemainingAmount && !_isCOD && !_isSod
                              ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = true;
                                _isSod = false;
                                _isCOD = false;
                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }
                                else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) > 0)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                // right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData.itemspayment[i]
                                            .paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes
                                                .blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset(Images.onlineImg),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if(remainingAmount>0)
                                        Text(
                                            remainingAmount
                                                .toStringAsFixed(2) +
                                                " " + _currencyFormat
                                            ,
                                            style: TextStyle(
                                                color: ColorCodes
                                                    .blackColor,
                                                fontSize: 12.0)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                        child: _myRadioButton(
                                          title: "",
                                          value: i,
                                          onChanged: (newValue) {
                                            setState(() {
                                              //  _groupValue = newValue;
                                              //_ischeckbox = false;
                                              double totalAmount = 0.0;
                                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                              if (_isWallet && _ischeckboxshow) {
                                                _isOnline = true;
                                                _isSod = false;
                                                _isCOD = false;
                                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                  _isRemainingAmount = false;
                                                  _groupValue = -1;
                                                  prefs.setString("payment_type", "wallet");
                                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                }else {
                                                  if (_isOnline || _isCOD || _isSod) {
                                                    setState(() {
                                                      _groupValue = -1;
                                                      _isRemainingAmount = true;
                                                      walletAmount =
                                                          double.parse(
                                                              walletbalance);
                                                      remainingAmount =
                                                      _isSwitch &&
                                                          !_isLoyaltyToast &&
                                                          _isLoayalty &&
                                                          (double.parse(
                                                              loyaltyPoints) >
                                                              0)
                                                          ? totalAmount -
                                                          double.parse(
                                                              walletbalance) -
                                                          loyaltyAmount
                                                          : (totalAmount -
                                                          int.parse(
                                                              walletbalance));
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isWallet = false;
                                                      _ischeckbox = false;
                                                    });
                                                  }
                                                  setState(() {
                                                    _groupValue = i;
                                                  });
                                                }
                                              } else {
                                                _handleRadioValueChange1(i);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                              : GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = true;
                                _isCOD = false;
                                _isSod = false;

                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) > 0)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                //right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData.itemspayment[i]
                                            .paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes
                                                .blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset(Images.onlineImg),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                    child: _myRadioButton(
                                      title: "",
                                      value: i,
                                      onChanged: (newValue) {
                                        setState(() {
                                          //  _groupValue = newValue;
                                          //   _ischeckbox = false;

                                          double totalAmount = 0.0;
                                          !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                          if (_isWallet && _ischeckboxshow) {
                                            _isOnline = true;
                                            _isSod = false;
                                            _isCOD = false;

                                            if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                              _isRemainingAmount = false;
                                              _groupValue = -1;
                                              prefs.setString("payment_type", "wallet");
                                              walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                            }else {
                                              if (_isOnline || _isCOD || _isSod) {
                                                setState(() {
                                                  _groupValue = -1;
                                                  _isRemainingAmount = true;
                                                  walletAmount = double.parse(
                                                      walletbalance);
                                                  remainingAmount =
                                                  _isSwitch &&
                                                      !_isLoyaltyToast &&
                                                      _isLoayalty &&
                                                      (double.parse(
                                                          loyaltyPoints) > 0)
                                                      ? totalAmount -
                                                      double.parse(
                                                          walletbalance) -
                                                      loyaltyAmount
                                                      : (totalAmount - int
                                                      .parse(walletbalance));
                                                });
                                              } else {
                                                setState(() {
                                                  _isWallet = false;
                                                  _ischeckbox = false;
                                                });
                                              }
                                              setState(() {
                                                _groupValue = i;
                                              });
                                            }
                                          } else {
                                            _handleRadioValueChange1(i);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),




                        if (paymentData.itemspayment[i].paymentMode == "0")
                          _isRemainingAmount && !_isCOD && !_isOnline?
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = false;
                                _isSod = true;
                                _isCOD = false;
                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }
                                else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) > 0)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                // right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(Images.swipe,
                                            width: 26.0,
                                            height: 26.0,),
                                          Center(
                                            child: Text(
                                              paymentData.itemspayment[i]
                                                  .paymentName,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: ColorCodes
                                                      .blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(Images.swipecard,
                                        width: 100.0,
                                        height: 30.0,),
                                    ],
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      if(remainingAmount>0)
                                        Text(
                                            remainingAmount
                                                .toStringAsFixed(2) +
                                                " " + _currencyFormat
                                            ,
                                            style: TextStyle(
                                                color: ColorCodes
                                                    .blackColor,
                                                fontSize: 12.0)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      //Spacer(),
                                      SizedBox(
                                        width: 20.0,
                                        child: _myRadioButton(
                                          title: "",
                                          value: i,
                                          onChanged: (newValue) {
                                            setState(() {
                                              //  _groupValue = newValue;
                                              //_ischeckbox = false;
                                              double totalAmount = 0.0;
                                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                              if (_isWallet && _ischeckboxshow) {
                                                _isOnline = false;
                                                _isSod = true;
                                                _isCOD = false;
                                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                  _isRemainingAmount = false;
                                                  _groupValue = -1;
                                                  prefs.setString("payment_type", "wallet");
                                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                }else {
                                                  if (_isOnline || _isCOD || _isSod) {
                                                    setState(() {
                                                      _groupValue = -1;
                                                      _isRemainingAmount = true;
                                                      walletAmount =
                                                          double.parse(
                                                              walletbalance);
                                                      remainingAmount =
                                                      _isSwitch &&
                                                          !_isLoyaltyToast &&
                                                          _isLoayalty &&
                                                          (double.parse(
                                                              loyaltyPoints) >
                                                              0)
                                                          ? totalAmount -
                                                          double.parse(
                                                              walletbalance) -
                                                          loyaltyAmount
                                                          : (totalAmount -
                                                          int.parse(
                                                              walletbalance));
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isWallet = false;
                                                      _ischeckbox = false;
                                                    });
                                                  }
                                                  setState(() {
                                                    _groupValue = i;
                                                  });
                                                }
                                              } else {
                                                _handleRadioValueChange1(i);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ):
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = false;
                                _isCOD = false;
                                _isSod = true;

                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) > 0)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                //right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(Images.swipe,
                                            width: 26.0,
                                            height: 26.0,),
                                          Center(
                                            child: Text(
                                              paymentData.itemspayment[i]
                                                  .paymentName,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: ColorCodes
                                                      .blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(Images.swipecard,
                                        width: 100.0,
                                        height: 30.0,),
                                    ],
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 20.0,
                                    child: _myRadioButton(
                                      title: "",
                                      value: i,
                                      onChanged: (newValue) {
                                        setState(() {
                                          double totalAmount = 0.0;
                                          !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                          if (_isWallet && _ischeckboxshow) {
                                            _isOnline = false;
                                            _isSod = true;
                                            _isCOD = false;

                                            if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                              _isRemainingAmount = false;
                                              _groupValue = -1;
                                              prefs.setString("payment_type", "wallet");
                                              walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                            }else {
                                              if (_isOnline || _isCOD || _isSod) {
                                                setState(() {
                                                  _groupValue = -1;
                                                  _isRemainingAmount = true;
                                                  walletAmount = double.parse(
                                                      walletbalance);
                                                  remainingAmount =
                                                  _isSwitch &&
                                                      !_isLoyaltyToast &&
                                                      _isLoayalty &&
                                                      (double.parse(
                                                          loyaltyPoints) > 0)
                                                      ? totalAmount -
                                                      double.parse(
                                                          walletbalance) -
                                                      loyaltyAmount
                                                      : (totalAmount - int
                                                      .parse(walletbalance));
                                                });
                                              } else {
                                                setState(() {
                                                  _isWallet = false;
                                                  _ischeckbox = false;
                                                });
                                              }
                                              setState(() {
                                                _groupValue = i;
                                              });
                                            }
                                          } else {
                                            _handleRadioValueChange1(i);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  /* new ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: paymentData.itemspayment.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        if (paymentData.itemspayment[i].paymentMode ==
                            "1")
                          _isRemainingAmount
                              ?
                          Container(
                            width:
                            MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentData.itemspayment[i]
                                          .paymentName,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: ColorCodes
                                              .blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Image.asset(Images.onlineImg),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        " " +
                                            remainingAmount
                                                .toStringAsFixed(2)+ _currencyFormat ,
                                        style: TextStyle(
                                            color: ColorCodes
                                                .blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : Container(
                            width:
                            MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentData.itemspayment[i]
                                          .paymentName,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: ColorCodes
                                              .blackColor,fontWeight: FontWeight.bold),
                                    ),
                                    Image.asset(Images.onlineImg),
                                  ],
                                ),
                                SizedBox(
                                  width: 20.0,
                                  child: _myRadioButton(
                                    title: "",
                                    value: i,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _groupValue = newValue;
                                        _ischeckbox = false;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (paymentData.itemspayment[i].paymentMode ==
                            "0")
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                top: 20.0,
                                // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData
                                            .itemspayment[i].paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes.blackColor),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                              Images.cardMachineImg),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                              child: Text(
                                                "Our delivery personnel will carry a swipe machine & orders can be paid via Debit/Credit card at the time of delivery.",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                    ColorCodes.greyColor),
                                              )),
                                          SizedBox(width: 50.0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20.0,
                                  child: _myRadioButton(
                                    title: "",
                                    value: i,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _groupValue = newValue;
                                        _ischeckbox = false;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),*/
                ),
                Divider(
                  height:  0.5,
                  color: ColorCodes.lightGreyColor,

                ),
                Padding(
                  padding: const EdgeInsets.only(left:37.0,right:37,top:10),
                  child: SizedBox(
                    child: new ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paymentData.itemspayment.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          /* if (paymentData.itemspayment[i].paymentMode ==
                                      "6")
                                    Container(
                                      color: ColorCodes.lightGreyWebColor,
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          top: 20.0,
                                          left: 10.0,
                                          right: 10.0,
                                          bottom: 20.0),
                                      child: Text(
                                        paymentData.itemspayment[i].paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes.blackColor),
                                      ),
                                    ),*/
                          if (paymentData.itemspayment[i].paymentMode ==
                              "6")
                            _isRemainingAmount && !_isOnline
                                && !_isSod ?
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                double totalAmount = 0.0;
                                !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                if (_isWallet && _ischeckboxshow) {
                                  _isOnline = false;
                                  _isCOD = true;
                                  _isSod = false;
                                  if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                    _isRemainingAmount = false;
                                    _groupValue = -1;
                                    prefs.setString("payment_type", "wallet");
                                    walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                  }
                                  else {
                                    if (_isOnline || _isCOD || _isSod) {
                                      setState(() {
                                        _groupValue = -1;
                                        _isRemainingAmount = true;
                                        walletAmount =
                                            double.parse(walletbalance);
                                        remainingAmount =
                                        _isSwitch && !_isLoyaltyToast &&
                                            _isLoayalty &&
                                            (double.parse(loyaltyPoints) > 0)
                                            ? totalAmount -
                                            double.parse(walletbalance) -
                                            loyaltyAmount
                                            : (totalAmount -
                                            double.parse(walletbalance));
                                      });
                                    } else {
                                      setState(() {
                                        _isWallet = false;
                                        _ischeckbox = false;
                                      });
                                    }
                                    setState(() {
                                      _groupValue = i;
                                    });
                                  }
                                } else {
                                  _handleRadioValueChange1(i);
                                }
                              },
                              child: Container(

                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  //left: 10.0,
                                  // left: 10.0,

                                  // right: 10.0,
                                    bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [

                                    /*Image.asset(
                                              Images.cashImg,
                                              width: 26.0,
                                              height: 26.0,
                                            ),
                                            SizedBox(width: 5,),*/
                                    Expanded(
                                      child:
                                      Center(
                                        child: Container(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(
                                            //top: 20.0,
                                            //left: 10.0,
                                            //right: 10.0,
                                              bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                Images.cashImg,
                                                width: 26.0,
                                                height: 26.0,
                                              ),
                                              Center(
                                                child: Text(
                                                  translate('forconvience.Cash on Delivery'),
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color:
                                                      ColorCodes.blackColor,

                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Spacer(),
                                              if(remainingAmount>0)
                                                Text(
                                                    remainingAmount
                                                        .toStringAsFixed(2) +
                                                        " " +_currencyFormat
                                                    ,
                                                    style: TextStyle(
                                                        color: ColorCodes
                                                            .blackColor,
                                                        fontSize: 12.0)),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              SizedBox(
                                                width: 20.0,
                                                child: _myRadioButton(
                                                  title: "",
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      double totalAmount = 0.0;
                                                      !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                                      if (_isWallet && _ischeckboxshow) {
                                                        _isOnline = false;
                                                        _isCOD = true;
                                                        _isSod = false;
                                                        if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                          _isRemainingAmount = false;
                                                          _groupValue = -1;
                                                          prefs.setString("payment_type", "wallet");
                                                          walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                        }
                                                        else {
                                                          if (_isOnline || _isCOD || _isSod) {
                                                            setState(() {
                                                              _groupValue = -1;
                                                              _isRemainingAmount = true;
                                                              walletAmount = double.parse(
                                                                  walletbalance);
                                                              remainingAmount =
                                                              _isSwitch &&
                                                                  !_isLoyaltyToast &&
                                                                  _isLoayalty &&
                                                                  (double.parse(
                                                                      loyaltyPoints) > 0)
                                                                  ? totalAmount -
                                                                  double.parse(
                                                                      walletbalance) -
                                                                  loyaltyAmount
                                                                  : (totalAmount -
                                                                  int.parse(
                                                                      walletbalance));
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _isWallet = false;
                                                              _ischeckbox = false;
                                                            });
                                                          }
                                                          setState(() {
                                                            _groupValue = i;
                                                          });
                                                        }
                                                      } else {
                                                        _handleRadioValueChange1(i);
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                :
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                double totalAmount = 0.0;
                                !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                if (_isWallet && _ischeckboxshow) {
                                  _isOnline = false;
                                  _isCOD = true;
                                  _isSod = false;

                                  if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                    _isRemainingAmount = false;
                                    _groupValue = -1;
                                    prefs.setString("payment_type", "wallet");
                                    walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                  }else {
                                    if (_isOnline || _isCOD || _isSod) {
                                      setState(() {
                                        _groupValue = -1;
                                        _isRemainingAmount = true;
                                        walletAmount =
                                            double.parse(walletbalance);
                                        remainingAmount =
                                        _isSwitch && !_isLoyaltyToast &&
                                            _isLoayalty &&
                                            (double.parse(loyaltyPoints) > 0)
                                            ? totalAmount -
                                            double.parse(walletbalance) -
                                            loyaltyAmount
                                            : (totalAmount -
                                            double.parse(walletbalance));
                                      });
                                    } else {
                                      setState(() {
                                        _isWallet = false;
                                        _ischeckbox = false;
                                      });
                                    }
                                    setState(() {
                                      _groupValue = i;
                                    });
                                  }
                                } else {
                                  _handleRadioValueChange1(i);
                                }
                              },
                              child: Container(

                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  //left: 10.0,
                                  //right: 10.0,
                                    bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    /*Image.asset(
                                              Images.cashImg,
                                              width: 26.0,
                                              height: 26.0,
                                            ),
                                            SizedBox(width: 5,),*/
                                    Expanded(
                                      child:
                                      Center(
                                        child: Container(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(
                                            //top: 20.0,
                                            //left: 10.0,
                                            //right: 10.0,
                                              bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                Images.cashImg,
                                                width: 26.0,
                                                height: 26.0,
                                              ),
                                              Center(
                                                child: Text(
                                                  translate('forconvience.Cash on Delivery'),
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color:
                                                      ColorCodes.blackColor,

                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 20.0,
                                                child: _myRadioButton(
                                                  title: "",
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {

                                                      double totalAmount = 0.0;
                                                      !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                                      if (_isWallet && _ischeckboxshow) {
                                                        _isOnline = false;
                                                        _isCOD = true;
                                                        _isSod = false;
                                                        if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                          _isRemainingAmount = false;
                                                          _groupValue = -1;
                                                          prefs.setString("payment_type", "wallet");
                                                          walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                        }
                                                        else {
                                                          if (_isOnline || _isCOD || _isSod) {
                                                            setState(() {
                                                              _groupValue = -1;
                                                              _isRemainingAmount = true;
                                                              walletAmount = double.parse(
                                                                  walletbalance);
                                                              remainingAmount =
                                                              _isSwitch &&
                                                                  !_isLoyaltyToast &&
                                                                  _isLoayalty &&
                                                                  (double.parse(
                                                                      loyaltyPoints) > 0)
                                                                  ? totalAmount -
                                                                  double.parse(
                                                                      walletbalance) -
                                                                  loyaltyAmount
                                                                  : (totalAmount -
                                                                  int.parse(
                                                                      walletbalance));
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _isWallet = false;
                                                              _ischeckbox = false;
                                                            });
                                                          }
                                                          setState(() {
                                                            _groupValue = i;
                                                          });
                                                        }
                                                      } else {
                                                        _handleRadioValueChange1(i);
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                              /*SizedBox(
                                                        height: 10.0,
                                                      ),*/
                                              /* Row(
                                                        children: [
                                                          *//*Image.asset(
                                                            Images.cashImg,
                                                            width: 26.0,
                                                            height: 26.0,
                                                          ),*//*
                                                          SizedBox(width: 10.0),
                                                          Expanded(
                                                              child: Text(
                                                            "Tip: To ensure a contactless delivery, we recommend you use an online payment method.",
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: ColorCodes
                                                                    .greyColor),
                                                          )),
                                                          SizedBox(width: 50.0),
                                                        ],
                                                      ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    /* SizedBox(width: 50.0),
                                    Text(
                                        _currencyFormat +
                                            " " +
                                            remainingAmount
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            color: ColorCodes
                                                .blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    )*/

                                    /* SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    )*/
                                  ],
                                ),
                              ),
                            )

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  "Currently there is no payment methods",
                  style: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      }

      if (!_displaypromo) {
        if (_isPickup) {
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0)) {
            amountPayable = (cartTotal - loyaltyAmount)/*.roundToDouble()*/;
          } else {
            amountPayable = cartTotal;
          }
        } else {
          // else statement for _isPickup
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0)) {
            amountPayable =
                (cartTotal + deliveryamount - loyaltyAmount)/*.roundToDouble()*/;
          } else {
            amountPayable = (cartTotal + deliveryamount);
          }
        }
      } else {
        //else statement for !_displaypromo
        if (_isPickup) {
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0)) {
            amountPayable =
                (cartTotal - double.parse(_savedamount) - loyaltyAmount)
                   /* .roundToDouble()*/;
          } else {
            amountPayable = (cartTotal - double.parse(_savedamount));
          }
        } else {
          // else statement for _isPickup
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0)) {
            amountPayable = (cartTotal +
                deliveryamount -
                double.parse(_savedamount) -
                loyaltyAmount)
                /*.roundToDouble()*/;
          } else {
            amountPayable =
            (cartTotal + deliveryamount - double.parse(_savedamount));
          }
        }
      }
      queryData = MediaQuery.of(context);
      wid= queryData.size.width;
      maxwid=wid*0.90;
      return (_isWeb && !ResponsiveLayout.isSmallScreen(context))
          ?  Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
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
              Align(
                alignment: Alignment.center,
                child: Container(
                  color: ColorCodes.whiteColor,
                  constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: paymentSelection()),
                      Flexible(child: paymentDetails()),
                    ],
                  ),
                ),
              ),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(
                    address: _address),
            ],
          ),
        ),
      )
          : null;
    }

    Widget _bodyMobile() {
      double amountPayable = 0.0;

      Widget promocodeMethod() {
        if( deliverychargetext== translate('forconvience.FREE')//"FREE"
         ){
          if ((Calculations.totalmrp - (amountPayable-deliverycharge)) > 0) {
            double savings=(Calculations.totalmrp - (amountPayable-deliverycharge));
            return Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                DottedBorder(
                  padding: EdgeInsets.zero,
                  color: ColorCodes.mediumBlueColor,
                  //strokeWidth: 1,
                  dashPattern: [3.0],
                  child: Container(
                    padding: EdgeInsets.only(left: 6.0, right: 6.0),
                    height: 30.0,
                    color: ColorCodes.lightBlueColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your savings",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorCodes.mediumBlueColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(

                          " " +
                              (Calculations.totalmrp - amountPayable).toStringAsFixed(2)+  _currencyFormat,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorCodes.mediumBlueColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(color: ColorCodes.blackColor),
              ],
            );
          } else {
            return Container();
          }
        }else{
          if ((Calculations.totalmrp - (amountPayable-deliverycharge)) > 0) {
            double savings=(Calculations.totalmrp - (amountPayable-deliverycharge));
            return Column(
              children: [
                SizedBox(
                  height: 10.0,
                ),
                DottedBorder(
                  padding: EdgeInsets.zero,
                  color: ColorCodes.mediumBlueColor,
                  //strokeWidth: 1,
                  dashPattern: [3.0],
                  child: Container(
                    padding: EdgeInsets.only(left: 6.0, right: 6.0),
                    height: 30.0,
                    color: ColorCodes.lightBlueColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your savings",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorCodes.mediumBlueColor,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(

                          " " + (Calculations.totalmrp - (amountPayable-deliverycharge)).toStringAsFixed(2)+ _currencyFormat ,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: ColorCodes.mediumBlueColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Divider(color: ColorCodes.blackColor),
              ],
            );
          } else {
            return Container();
          }}
      }

      Widget paymentDetails() {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: ColorCodes.whiteColor,
              /* padding: EdgeInsets.only(
                  top: 14.0, left: 37.0,right: 37.0, bottom: 8.0),*/
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 16.0,left: 37.0,right: 37.0, top: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                       /* Text(
                          translate('forconvience.Total'),
                          style: TextStyle(
                              fontSize: 15.0,
                              color: ColorCodes.blackColor,
                              fontWeight: FontWeight.bold),
                        ),*/
                        /* Text(
                          "(Incl. of all taxes)",
                          style: TextStyle(
                              fontSize: 10.0, color: ColorCodes.blackColor),
                        ),*/
                      ],
                    ),
                  ),
                  IntrinsicHeight(
                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                              child: Text(
                                translate('forconvience.Sub-Total'),
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            if (!_isPickup)
                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: Text(
                                  translate('forconvience.Delivery charges'),
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: ColorCodes.mediumBlackColor),
                                ),
                              ),
                            if (!_isPickup)
                              SizedBox(
                                height: 10.0,
                              ),
                            /*if ((Calculations.totalmrp - cartTotal) > 0)
                              Text(
                                "Discount applied:",
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),*/
                            /*  SizedBox(
                              height: 10.0,
                            ),*/
                            if (_isPaymentMethod)
                              if (_isWallet)
                                if(_ischeckboxshow)
                                  GestureDetector(
                                    // behavior: HitTestBehavior.translucent,
                                    /* onTap: () {
                                      setState(() {
                                        _ischeckbox = !_ischeckbox;
                                        double totalAmount = 0.0;
                                        !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                        if(_isWallet) {
                                          if (int.parse(walletbalance) <= 0 *//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//*) {
                                            _isRemainingAmount = false;
                                            _ischeckboxshow = false;
                                            _ischeckbox = false;
                                          } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                            _isRemainingAmount = false;
                                            _groupValue = -1;
                                            prefs.setString("payment_type", "wallet");
                                            walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                          } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                            bool _isOnline = false;
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _isOnline = true;
                                                break;
                                              }
                                            }
                                            if(_isOnline) {
                                              _groupValue = -1;
                                              _isRemainingAmount = true;
                                              walletAmount = double.parse(walletbalance);
                                              remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                            } else {
                                              _isWallet = false;
                                              _ischeckbox = false;
                                            }
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _groupValue = i;
                                                break;
                                              }
                                            }

                                          }
                                        } else {
                                          _ischeckbox = false;
                                        }
                                      });
                                    },*/
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width/2,
                                      color: ColorCodes.whiteColor,
                                      padding: EdgeInsets.only(
                                       // top: 10.0,
                                        right: 10.0, ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,

                                        children: <Widget>[
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () {
                                              setState(() {
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                _ischeckbox
                                                    ? Padding(
                                                  padding: const EdgeInsets.only(left: 18.0, ),
                                                  child: Icon(
                                                    Icons.check_box,
                                                    size: 15.0,
                                                    color: ColorCodes.whiteColor,
                                                  ),
                                                )
                                                    : Padding(
                                                  padding: const EdgeInsets.only(left: 18.0,),
                                                  child: Icon(
                                                    Icons.check_box_outline_blank,
                                                    size: 15.0,
                                                    color: ColorCodes.whiteColor,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left:3.0),
                                                  child: Text(
                                                    // IConstants.APP_NAME +
                                                    translate('bottomnavigation.wallet'),//" Wallet",
                                                    style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      // fontWeight: FontWeight.bold,
                                                      fontSize: 12.0,),
                                                  ),
                                                ),
                                                /* if (_ischeckboxshow && _ischeckbox)
                                                Image.asset(Images.walletImg,
                                                    height: 15.0,
                                                    width: 18.0,
                                                    color: Theme.of(context).primaryColor),*/
                                                if (_ischeckboxshow && _ischeckbox)
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),

                                                SizedBox(width: 20.0),

                                              ],
                                            ),
                                          ),
                                          /*   Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              IConstants.APP_NAME + " Wallet",
                                              style: TextStyle(
                                                  color: ColorCodes.blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Balance:  ",
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                                Image.asset(Images.walletImg,
                                                    height: 13.0,
                                                    width: 16.0,
                                                    color: Theme.of(context).primaryColor),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  _currencyFormat + " " + walletbalance,
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),*/

                                        ],
                                      ),
                                    ),
                                  ),
                            //:
                            /*GestureDetector(
                                  // behavior: HitTestBehavior.translucent,
                                  *//* onTap: () {
                                      setState(() {
                                        _ischeckbox = !_ischeckbox;
                                        double totalAmount = 0.0;
                                        !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                        if(_isWallet) {
                                          if (int.parse(walletbalance) <= 0 *//**//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//**//*) {
                                            _isRemainingAmount = false;
                                            _ischeckboxshow = false;
                                            _ischeckbox = false;
                                          } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                            _isRemainingAmount = false;
                                            _groupValue = -1;
                                            prefs.setString("payment_type", "wallet");
                                            walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                          } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                            bool _isOnline = false;
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _isOnline = true;
                                                break;
                                              }
                                            }
                                            if(_isOnline) {
                                              _groupValue = -1;
                                              _isRemainingAmount = true;
                                              walletAmount = double.parse(walletbalance);
                                              remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                            } else {
                                              _isWallet = false;
                                              _ischeckbox = false;
                                            }
                                            for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                              if(paymentData.itemspayment[i].paymentMode == "1") {
                                                _groupValue = i;
                                                break;
                                              }
                                            }

                                          }
                                        } else {
                                          _ischeckbox = false;
                                        }
                                      });
                                    },*//*
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    setState(() {
                                      _ischeckbox = !_ischeckbox;
                                      double totalAmount = 0.0;
                                      !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                      if(_isWallet) {
                                        if (int.parse(walletbalance) <= 0 *//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//*) {
                                          _isRemainingAmount = false;
                                          _ischeckboxshow = false;
                                          _ischeckbox = false;
                                        } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                          _isRemainingAmount = false;
                                          _groupValue = -1;
                                          prefs.setString("payment_type", "wallet");
                                          walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                        } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                          for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                            if(paymentData.itemspayment[i].paymentMode == "1") {
                                              _groupValue = i;
                                              _isOnline = true;
                                              break;
                                            } else if(paymentData.itemspayment[i].paymentMode == "6") {
                                              _groupValue = i;
                                              _isCOD = true;
                                              break;
                                            }
                                          }
                                          if(_isOnline || _isCOD) {
                                            _groupValue = -1;
                                            _isRemainingAmount = true;
                                            walletAmount = double.parse(walletbalance);
                                            remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                          } else {
                                            _isWallet = false;
                                            _ischeckbox = false;
                                          }
                                          for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                            if(paymentData.itemspayment[i].paymentMode == "1" || paymentData.itemspayment[i].paymentMode == "6") {
                                              _groupValue = i;
                                              break;
                                            }
                                          }

                                        }
                                      } else {
                                        _ischeckbox = false;
                                      }
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width/2,
                                    color: ColorCodes.whiteColor,
                                    padding: EdgeInsets.only(
                                      top: 10.0, right: 10.0, ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,

                                      children: <Widget>[
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () {
                                            setState(() {
                                              _ischeckbox = !_ischeckbox;
                                              double totalAmount = 0.0;
                                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                              if(_isWallet) {
                                                if (int.parse(walletbalance) <= 0 *//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//*) {
                                                  _isRemainingAmount = false;
                                                  _ischeckboxshow = false;
                                                  _ischeckbox = false;
                                                } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                                  _isRemainingAmount = false;
                                                  _groupValue = -1;
                                                  prefs.setString("payment_type", "wallet");
                                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                                  bool _isOnline = false;
                                                  for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                                    if(paymentData.itemspayment[i].paymentMode == "1") {
                                                      _isOnline = true;
                                                      break;
                                                    }
                                                  }
                                                  if(_isOnline) {
                                                    _groupValue = -1;
                                                    _isRemainingAmount = true;
                                                    walletAmount = double.parse(walletbalance);
                                                    remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                                  } else {
                                                    _isWallet = false;
                                                    _ischeckbox = false;
                                                  }
                                                  for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                                    if(paymentData.itemspayment[i].paymentMode == "1") {
                                                      _groupValue = i;
                                                      break;
                                                    }
                                                  }

                                                }
                                              } else {
                                                _ischeckbox = false;
                                              }
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              _ischeckbox
                                                  ? Padding(
                                                padding: const EdgeInsets.only(left: 18.0, ),
                                                child: Icon(
                                                  Icons.check_box,
                                                  size: 15.0,
                                                  color: ColorCodes.greenColor,
                                                ),
                                              )
                                                  : Padding(
                                                padding: const EdgeInsets.only(left: 18.0,),
                                                child: Icon(
                                                  Icons.check_box_outline_blank,
                                                  size: 15.0,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left:3.0),
                                                child: Text(
                                                  // IConstants.APP_NAME +
                                                  " Wallet",
                                                  style: TextStyle(
                                                    color: ColorCodes.blackColor,
                                                    // fontWeight: FontWeight.bold,
                                                    fontSize: 12.0,),
                                                ),
                                              ),
                                              *//* if (_ischeckboxshow && _ischeckbox)
                                                Image.asset(Images.walletImg,
                                                    height: 15.0,
                                                    width: 18.0,
                                                    color: Theme.of(context).primaryColor),*//*
                                              if (_ischeckboxshow && _ischeckbox)
                                                SizedBox(
                                                  width: 5.0,
                                                ),

                                              SizedBox(width: 20.0),

                                            ],
                                          ),
                                        ),
                                        *//*   Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              IConstants.APP_NAME + " Wallet",
                                              style: TextStyle(
                                                  color: ColorCodes.blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Balance:  ",
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                                Image.asset(Images.walletImg,
                                                    height: 13.0,
                                                    width: 16.0,
                                                    color: Theme.of(context).primaryColor),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  _currencyFormat + " " + walletbalance,
                                                  style: TextStyle(
                                                      color: ColorCodes.blackColor,
                                                      fontSize: 10.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),*//*

                                      ],
                                    ),
                                  ),
                                ),*/

                            // if (_isPaymentMethod)

                            /*Text(
                              "Wallet",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: ColorCodes.mediumBlackColor),
                            ),*/
                            /* SizedBox(
                              height: 10.0,
                            ),*/

                            if (_ischeckboxshow && _ischeckbox)
                              SizedBox(
                                height: 10.0,
                              ),

                           /* if ((Calculations.totalmrp - cartTotal) > 0)
                              SizedBox(
                                height: 10.0,
                              ),*/
                            /*if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              SizedBox(
                                height: 10.0,
                              ),*/
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')

                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: new RichText(
                                  text: new TextSpan(
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: ColorCodes.mediumBlackColor),
                                    children: <TextSpan>[
                                      new TextSpan(text: translate('forconvience.Discount Applied (HELLO)')+"("),//'Discount applied ('),
                                      new TextSpan(
                                        text: _promocode,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: ColorCodes.orangeColor),
                                      ),
                                      new TextSpan(text: ')'),
                                    ],
                                  ),
                                ),
                              ),
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              SizedBox(
                                height: 10.0,
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100))
                              Padding(
                                padding:const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: new RichText(
                                  text: new TextSpan(
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        color: ColorCodes.mediumBlackColor),
                                    children: <TextSpan>[
                                      new TextSpan(text: 'Points de fidélité',),
                                      // new TextSpan(
                                      //   text: 'Coins',
                                      //   style: TextStyle(
                                      //       fontSize: 12.0,
                                      //       color: ColorCodes.orangeColor),
                                      // ),
                                      // new TextSpan(text: ')'),
                                    ],
                                  ),
                                ),
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100))
                              SizedBox(
                                height: 10.0,
                              ),
                           /* SizedBox(
                              height: 10.0,
                            ),*/
                            Padding(
                              padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                              child: Text(
                                translate('forconvience.Total'),//"Amount payable:",
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: ColorCodes.mediumBlackColor,fontWeight: FontWeight.bold),
                              ),
                            ),



                            /* : Container(
                                  width: MediaQuery.of(context).size.width/2,
                                  padding: EdgeInsets.only(
                                      top: 20.0, left: 10.0, right: 10.0, bottom: 20.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            IConstants.APP_NAME + " Wallet",
                                            style: TextStyle(
                                                color: ColorCodes.greyColor,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Balance:  ",
                                                style: TextStyle(
                                                    color: ColorCodes.greyColor,
                                                    fontSize: 10.0),
                                              ),
                                              SizedBox(
                                                height: 2.0,
                                              ),
                                              Image.asset(Images.walletImg,
                                                  height: 13.0,
                                                  width: 16.0,
                                                  color: Theme.of(context).primaryColor),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Text(
                                                _currencyFormat + " " + walletbalance,
                                                style: TextStyle(
                                                    color: ColorCodes.greyColor,
                                                    fontSize: 10.0),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.radio_button_off,
                                              size: 20.0, color: ColorCodes.greyColor)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),*/
                            if (_isPaymentMethod)
                              if (_isWallet)
                                Divider(
                                  color: ColorCodes.lightGreyColor,
                                ),
                          ],
                        ),
                        /* Container(
                            child: VerticalDivider(
                                color: ColorCodes.dividerColor)
                        ),*/
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(
                              padding:const EdgeInsets.only(left: 37.0,right: 37.0, ),
                              child: Text(
                                " " +
                                    cartTotal.toStringAsFixed(2)+  _currencyFormat ,
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            if (!_isPickup)
                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: Text(
                                  deliverychargetext,
                                  style: TextStyle(
                                      fontSize: 12.0, color: ColorCodes.greenColor),
                                ),
                              ),
                            if (!_isPickup)
                              SizedBox(
                                height: 10.0,
                              ),
                            /* if ((Calculations.totalmrp - cartTotal) > 0)
                              Text(
                                "- " +
                                    (Calculations.totalmrp - cartTotal)
                                        .toStringAsFixed(2),
                                style: TextStyle(
                                    fontSize: 12.0,
                                    color: ColorCodes.mediumBlackColor),
                              ),*/
                            /* if ((Calculations.totalmrp - cartTotal) > 0)
                              SizedBox(
                                height: 10.0,
                              ),*/

                            if (_ischeckboxshow && _ischeckbox)
                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: Text(
                                  " " +
                                      walletAmount.toStringAsFixed(2)+  _currencyFormat,
                                  style: TextStyle(
                                      color: ColorCodes.blackColor,
                                      fontSize: 12.0),
                                ),
                              ),
                            if(_ischeckboxshow)
                              (_ischeckbox)?
                              SizedBox(
                                height: 10.0,
                              ): SizedBox(
                                height: 20.0,
                              )
                            ,

                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: Text(
                                  "- " +

                                      " " +
                                      double.parse(_savedamount)
                                          .toStringAsFixed(2)+ _currencyFormat ,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: ColorCodes.greenColor),
                                ),
                              ),
                            if (_displaypromo &&
                                promomessage.toString().toLowerCase() !=
                                    'cashback')
                              SizedBox(
                                height: 10.0,
                              ),
                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100))
                              Padding(
                                padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                                child: Text(
                                  "- "  +
                                      " " +
                                      loyaltyAmount.toStringAsFixed(2)+
                                      _currencyFormat,
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      color: ColorCodes.greenColor),
                                ),
                              ),


                            if (!_isLoyaltyToast &&
                                _isSwitch &&
                                _isLoayalty &&
                                (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100))
                              SizedBox(
                                height: 10.0,
                              ),
                          /*  if(!_isPaymentMethod)
                              SizedBox(height: 0,),*/
                            Padding(
                              padding: const EdgeInsets.only(left: 37.0,right: 37.0, ),
                              child:
                              (_ischeckboxshow && _ischeckbox)?
                              Text(

                                " " +
                                    remainingAmount.toStringAsFixed(2)+ _currencyFormat ,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: ColorCodes.mediumBlackColor),
                              ):

                              Text(

                                " " +
                                    amountPayable.toStringAsFixed(2)+ _currencyFormat ,
                                style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: ColorCodes.mediumBlackColor),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),


                  // promocodeMethod() goes here
                  // promocodeMethod(),
                ],
              ),
            ),
            Divider(
              color: ColorCodes.lightGreyColor,
              thickness: 0.5,
            ),
            (productBox.length == 1 && productBox.values.elementAt(0).mode == 1)
                ? SizedBox.shrink()
                : !_checkpromo?
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              /*onTap: () {
                //_dialogforPro
                mo(context);
                setState(() {
                  _checkpromo = true;
                });
                checkPromo();

              },*/
              child: Padding(
                padding: const EdgeInsets.only(left:37.0,right:37),
                child: Material(
                  elevation: 1,
                  child: Container(
                    padding: EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      color: ColorCodes.whiteColor,
                      borderRadius: BorderRadius.circular(6),
                      /* boxShadow:  [BoxShadow(
                              color: ColorCodes.greyColor,
                              blurRadius: 5.0,
                            ),]*/
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          width: 170,
                          child: TextField(
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: translate('forconvience.Enter Promo')),
                            controller: myController,
                            onSubmitted: (String newVal) {
                              /*prefs.setString("promovalue", newVal);
                                        setState(() {
                                          _checkpromo = true;
                                          _promocode = newVal;
                                        });*/
                              setState(() {
                                _isSwitch = false;
                                _checkpromo = true;
                              });
                              checkPromo();
                            },
                          ),
                        ),
                        // SizedBox(width: 20.0),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSwitch = false;
                                _checkpromo = true;
                              });
                              checkPromo();
                            },
                            child: Container(
                              width: 100.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Center(
                                  child: Text(
                                    translate('forconvience.Apply'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white),
                                  )),
                            ),
                          ),
                        ),
                        /* Text(
                                "Apply Promo Code",
                                style: TextStyle(
                                    color: ColorCodes.blackColor,
                                    fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                color: ColorCodes.greyColor,
                              ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ):Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
              ),
            ),
            (productBox.length == 1 && productBox.values.elementAt(0).mode == 1)
                ? SizedBox.shrink()
                : Divider(
              color: ColorCodes.lightGreyColor,
              thickness: 0.5,
            ),
          ],
        );
      }

      Widget paymentSelection() {
        return Column(
          children: [
            if (_isLoayalty && (double.parse(loyaltyPoints) > 0))
              Padding(
                padding: const EdgeInsets.only(left:37.0,right:37),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: ColorCodes.whiteColor,
                  padding: EdgeInsets.only(
                      top: 8.0, /*left: 10.0, right: 10.0,*/ bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Points de fidélité",
                            style: TextStyle(
                                color: ColorCodes.blackColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                "Balance:  ",
                                style: TextStyle(
                                    color: ColorCodes.blackColor, fontSize: 10.0),
                              ),
                              Image.asset(
                                Images.coinImg,
                                height: 10.0,
                                width: 12.0,
                              ),
                              Text(
                                loyaltyPoints,
                                style: TextStyle(
                                    color: ColorCodes.blackColor, fontSize: 10.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          setState(() {

                            _isLoyaltyToast ?
                           // (_isWeb)?_customToast("Minimum order amount should be " + loyaltyData.itemsLoyalty[0].minimumOrderAmount.toString()):
                            Fluttertoast.showToast(msg: "Minimum order amount should be " + loyaltyData.itemsLoyalty[0].minimumOrderAmount.toString(), backgroundColor: Colors.black87, textColor: Colors.white)
                                :
                            _displaypromo?"":(double.parse(loyaltyPointsUser.toString()) <100)? Fluttertoast.showToast(msg: translate('forconvience.minimum_loyalty')/*"Minimum of dh100 Loyalty Points Required To Use Loyalty for Payment"*//*"Minimum order amount should be "*/ ,  fontSize: MediaQuery.of(context).textScaleFactor *13,backgroundColor: Colors.black87, textColor: Colors.white)//_dialogforloyalty(context)
                            :
                            _displaypromo?_isSwitch = _isSwitch:_isSwitch = _isSwitch;
                            if(_isWallet) {
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));

                              if (double.parse(walletbalance) <= 0 /*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*/) {
                                _isRemainingAmount = false;
                                _ischeckboxshow = false;
                                _ischeckbox = false;
                              } else if (_isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0)  && double.parse(loyaltyPointsUser.toString()) >=100 ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                _isRemainingAmount = false;
                                _groupValue = -1;
                                prefs.setString("payment_type", "wallet");
                                walletAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? (totalAmount - loyaltyAmount) : totalAmount;
                              }
                              else if (_isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) && double.parse(loyaltyPointsUser.toString()) >=100? totalAmount > (double.parse(walletbalance) + loyaltyAmount) : totalAmount > double.parse(walletbalance))
                              {
                                bool _isOnline = false;
                                bool _isSod = false;
                                for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                  if(paymentData.itemspayment[i].paymentMode == "1") {
                                    _groupValue = i;
                                    _isOnline = true;
                                    break;
                                  }
                                  if(paymentData.itemspayment[i].paymentMode == "0") {
                                    _groupValue = i;
                                    _isSod = true;
                                    break;
                                  }
                                  else if(paymentData.itemspayment[i].paymentMode == "6") {
                                    _groupValue = i;
                                    _isCOD = true;
                                    break;
                                  }
                                }
                                if(_isOnline || _isSod || _isCOD) {
                                  _isRemainingAmount = true;
                                  walletAmount = double.parse(walletbalance);
                                  remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) && double.parse(loyaltyPointsUser.toString()) >=100 ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - double.parse(walletbalance));
                                } else {
                                  _isWallet = false;
                                  _ischeckbox = false;
                                }
                                for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                  if(paymentData.itemspayment[i].paymentMode == "1") {
                                    _groupValue = i;
                                    break;
                                  }
                                }
                              }
                            } else {
                              _ischeckbox = false;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              Images.coinImg,
                              height: 12.0,
                              width: 14.0,
                            ),
                            Text(
                              " " + loyaltyPointsUser.toStringAsFixed(2)
                                  /*loyaltyPointsUser
                                      .roundToDouble()
                                      .toStringAsFixed(0)*/,
                              style: TextStyle(
                                  color: ColorCodes.blackColor, fontSize: 12.0),
                            ),
                            SizedBox(width: 20.0),
                            _isLoyaltyToast
                                ? Icon(
                              Icons.radio_button_off,
                              size: 20.0,
                            )
                                :
                            _isSwitch && (double.parse(loyaltyPointsUser.toString()) >=100)
                                ? Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: ColorCodes.whiteColor,
                                border: Border.all(
                                  color: ColorCodes.darkBlueColor,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                margin: EdgeInsets.all(1.5),
                                decoration: BoxDecoration(
                                  color: ColorCodes.mediumBlueColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.check,
                                    color: ColorCodes.whiteColor,
                                    size: 15.0),
                              ),
                            )
                                : Icon(
                              Icons.radio_button_off,
                              size: 20.0,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoayalty && (double.parse(loyaltyPoints) > 0))
              Divider(
                color: ColorCodes.lightGreyColor,
                thickness: 0.5,
              ),
            /*  if (_isPaymentMethod)
              if (_isWallet)
                _ischeckboxshow
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorCodes.whiteColor,
                        padding: EdgeInsets.only(
                            top: 20.0, left: 10.0, right: 10.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  IConstants.APP_NAME + " Wallet",
                                  style: TextStyle(
                                      color: ColorCodes.blackColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Balance:  ",
                                      style: TextStyle(
                                          color: ColorCodes.blackColor,
                                          fontSize: 10.0),
                                    ),
                                    Image.asset(Images.walletImg,
                                        height: 13.0,
                                        width: 16.0,
                                        color: ColorCodes.darkBlueColor),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      " " + walletbalance+ _currencyFormat ,
                                      style: TextStyle(
                                          color: ColorCodes.blackColor,
                                          fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _ischeckbox = !_ischeckbox;
                                  double totalAmount = 0.0;
                                  !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                  if(_isWallet) {
                                    if (int.parse(walletbalance) <= 0 *//*|| double.parse((cartTotal + deliveryamount).toStringAsFixed(2)) > int.parse(walletbalance)*//*) {
                                      _isRemainingAmount = false;
                                      _ischeckboxshow = false;
                                      _ischeckbox = false;
                                    } else if (_isSwitch ? totalAmount <= (int.parse(walletbalance) + loyaltyAmount) : totalAmount <= (int.parse(walletbalance))) {
                                      _isRemainingAmount = false;
                                      _groupValue = -1;
                                      prefs.setString("payment_type", "wallet");
                                      walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                    } else if (_isSwitch ? totalAmount > (int.parse(walletbalance) + loyaltyAmount) : totalAmount > int.parse(walletbalance)) {
                                      bool _isOnline = false;
                                      for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                        if(paymentData.itemspayment[i].paymentMode == "1") {
                                          _isOnline = true;
                                          break;
                                        }
                                      }
                                      if(_isOnline) {
                                        _groupValue = -1;
                                        _isRemainingAmount = true;
                                        walletAmount = double.parse(walletbalance);
                                        remainingAmount = _isSwitch && !_isLoyaltyToast && _isLoayalty && (double.parse(loyaltyPoints) > 0) ? totalAmount - double.parse(walletbalance) - loyaltyAmount: (totalAmount - int.parse(walletbalance));
                                      } else {
                                        _isWallet = false;
                                        _ischeckbox = false;
                                      }
                                      for(int i = 0; i < paymentData.itemspayment.length; i++) {
                                        if(paymentData.itemspayment[i].paymentMode == "1") {
                                          _groupValue = i;
                                          break;
                                        }
                                      }

                                    }
                                  } else {
                                    _ischeckbox = false;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  if (_ischeckboxshow && _ischeckbox)
                                    Image.asset(Images.walletImg,
                                        height: 15.0,
                                        width: 18.0,
                                        color: ColorCodes.darkBlueColor),
                                  if (_ischeckboxshow && _ischeckbox)
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                  if (_ischeckboxshow && _ischeckbox)
                                    Text(

                                          " " +
                                          walletAmount.toStringAsFixed(2)+ _currencyFormat ,
                                      style: TextStyle(
                                          color: ColorCodes.blackColor,
                                          fontSize: 12.0),
                                    ),
                                  SizedBox(width: 20.0),
                                  _ischeckbox
                                      ? Icon(
                                          Icons.radio_button_checked,
                                          size: 20.0,
                                          color: ColorCodes.mediumBlueColor,
                                        )
                                      : Icon(
                                          Icons.radio_button_off,
                                          size: 20.0,
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                            top: 20.0, left: 10.0, right: 10.0, bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  IConstants.APP_NAME + " Wallet",
                                  style: TextStyle(
                                      color: ColorCodes.greyColor,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Balance:  ",
                                      style: TextStyle(
                                          color: ColorCodes.greyColor,
                                          fontSize: 10.0),
                                    ),
                                    SizedBox(
                                      height: 2.0,
                                    ),
                                    Image.asset(Images.walletImg,
                                        height: 13.0,
                                        width: 16.0,
                                        color: ColorCodes.darkBlueColor),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                     " " + walletbalance+  _currencyFormat ,
                                      style: TextStyle(
                                          color: ColorCodes.greyColor,
                                          fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.radio_button_off,
                                    size: 20.0, color: ColorCodes.greyColor)
                              ],
                            ),
                          ],
                        ),
                      ),
            if (_isPaymentMethod)
              if (_isWallet)
                Divider(
                  color: ColorCodes.lightGreyColor,
                ),*/
            _isPaymentMethod
                ? /*Padding(
                  padding: const EdgeInsets.only(left:37.0,right: 37),
                  child: */
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        top:10, bottom: 20.0,right:37,left:37),
                    child: Text(
                      translate('forconvience.Payment Methods'),
                      style: TextStyle(
                          fontSize: 15.0,
                          color: ColorCodes.blackColor,
                          fontWeight: FontWeight.bold),
                    )),
                Divider(
                  height:  0.5,
                  color: ColorCodes.lightGreyColor,

                ),

                Padding(
                  padding: const EdgeInsets.only(left:37.0,right:37,
                      top:15),
                  child:
                  new ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: paymentData.itemspayment.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        if (paymentData.itemspayment[i].paymentMode == "1")

                          _isRemainingAmount && !_isCOD && !_isSod
                              ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = true;
                                _isSod = false;
                                _isCOD = false;
                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }
                                else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) >= 100)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                 // left: 10.0,
                                 // right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData.itemspayment[i]
                                            .paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes
                                                .blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset(Images.onlineImg),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if(remainingAmount>0)
                                        Text(
                                            remainingAmount
                                                .toStringAsFixed(2) +
                                                " " + _currencyFormat
                                            ,
                                            style: TextStyle(
                                                color: ColorCodes
                                                    .blackColor,
                                                fontSize: 12.0)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      SizedBox(
                                        width: 20.0,
                                        child: _myRadioButton(
                                          title: "",
                                          value: i,
                                          onChanged: (newValue) {
                                            setState(() {
                                              double totalAmount = 0.0;
                                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                              if (_isWallet && _ischeckboxshow) {
                                                _isOnline = true;
                                                _isSod = false;
                                                _isCOD = false;
                                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                  _isRemainingAmount = false;
                                                  _groupValue = -1;
                                                  prefs.setString("payment_type", "wallet");
                                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                }else {
                                                  if (_isOnline || _isCOD || _isSod) {
                                                    setState(() {
                                                      _groupValue = -1;
                                                      _isRemainingAmount = true;
                                                      walletAmount =
                                                          double.parse(
                                                              walletbalance);
                                                      remainingAmount =
                                                      _isSwitch &&
                                                          !_isLoyaltyToast &&
                                                          _isLoayalty &&
                                                          (double.parse(
                                                              loyaltyPoints) >=
                                                              100)
                                                          ? totalAmount -
                                                          double.parse(
                                                              walletbalance) -
                                                          loyaltyAmount
                                                          : (totalAmount -
                                                          int.parse(
                                                              walletbalance));
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isWallet = false;
                                                      _ischeckbox = false;
                                                    });
                                                  }
                                                  setState(() {
                                                    _groupValue = i;
                                                  });
                                                }
                                              } else {
                                                _handleRadioValueChange1(i);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                              : GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = true;
                                _isCOD = false;
                                _isSod = false;

                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) >= 100)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData.itemspayment[i]
                                            .paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes
                                                .blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Image.asset(Images.onlineImg),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                    child: _myRadioButton(
                                      title: "",
                                      value: i,
                                      onChanged: (newValue) {
                                        setState(() {
                                          double totalAmount = 0.0;
                                          !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                          if (_isWallet && _ischeckboxshow) {
                                            _isOnline = true;
                                            _isSod = false;
                                            _isCOD = false;

                                            if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                              _isRemainingAmount = false;
                                              _groupValue = -1;
                                              prefs.setString("payment_type", "wallet");
                                              walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                            }else {
                                              if (_isOnline || _isCOD || _isSod) {
                                                setState(() {
                                                  _groupValue = -1;
                                                  _isRemainingAmount = true;
                                                  walletAmount = double.parse(
                                                      walletbalance);
                                                  remainingAmount =
                                                  _isSwitch &&
                                                      !_isLoyaltyToast &&
                                                      _isLoayalty &&
                                                      (double.parse(
                                                          loyaltyPoints) >= 100)
                                                      ? totalAmount -
                                                      double.parse(
                                                          walletbalance) -
                                                      loyaltyAmount
                                                      : (totalAmount - int
                                                      .parse(walletbalance));
                                                });
                                              } else {
                                                setState(() {
                                                  _isWallet = false;
                                                  _ischeckbox = false;
                                                });
                                              }
                                              setState(() {
                                                _groupValue = i;
                                              });
                                            }
                                          } else {
                                            _handleRadioValueChange1(i);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),




                        if (paymentData.itemspayment[i].paymentMode == "0")
                          _isRemainingAmount && !_isCOD && !_isOnline?
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = false;
                                _isSod = true;
                                _isCOD = false;
                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }
                                else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) >=100)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                // right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [

                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(Images.swipe,
                                            width: 26.0,
                                            height: 26.0,),
                                          Center(
                                            child: Text(
                                              paymentData.itemspayment[i]
                                                  .paymentName,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: ColorCodes
                                                      .blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(Images.swipecard,
                                        width: 100.0,
                                        height: 30.0,),
                                    ],
                                  ),
                                  Spacer(),
                                  Row(
                                    children: [
                                      if(remainingAmount>0)
                                        Text(
                                            remainingAmount
                                                .toStringAsFixed(2) +
                                                " " + _currencyFormat
                                            ,
                                            style: TextStyle(
                                                color: ColorCodes
                                                    .blackColor,
                                                fontSize: 12.0)),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      //Spacer(),
                                      SizedBox(
                                        width: 20.0,
                                        child: _myRadioButton(
                                          title: "",
                                          value: i,
                                          onChanged: (newValue) {
                                            setState(() {
                                              //  _groupValue = newValue;
                                              //_ischeckbox = false;
                                              double totalAmount = 0.0;
                                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                              if (_isWallet && _ischeckboxshow) {
                                                _isOnline = false;
                                                _isSod = true;
                                                _isCOD = false;
                                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                  _isRemainingAmount = false;
                                                  _groupValue = -1;
                                                  prefs.setString("payment_type", "wallet");
                                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                }else {
                                                  if (_isOnline || _isCOD || _isSod) {
                                                    setState(() {
                                                      _groupValue = -1;
                                                      _isRemainingAmount = true;
                                                      walletAmount =
                                                          double.parse(
                                                              walletbalance);
                                                      remainingAmount =
                                                      _isSwitch &&
                                                          !_isLoyaltyToast &&
                                                          _isLoayalty &&
                                                          (double.parse(
                                                              loyaltyPoints) >=
                                                              100)
                                                          ? totalAmount -
                                                          double.parse(
                                                              walletbalance) -
                                                          loyaltyAmount
                                                          : (totalAmount -
                                                          int.parse(
                                                              walletbalance));
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _isWallet = false;
                                                      _ischeckbox = false;
                                                    });
                                                  }
                                                  setState(() {
                                                    _groupValue = i;
                                                  });
                                                }
                                              } else {
                                                _handleRadioValueChange1(i);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ):
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              double totalAmount = 0.0;
                              !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                              if (_isWallet && _ischeckboxshow) {
                                _isOnline = false;
                                _isCOD = false;
                                _isSod = true;

                                if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                  _isRemainingAmount = false;
                                  _groupValue = -1;
                                  prefs.setString("payment_type", "wallet");
                                  walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                }else {
                                  if (_isOnline || _isCOD || _isSod) {
                                    setState(() {
                                      _groupValue = -1;
                                      _isRemainingAmount = true;
                                      walletAmount =
                                          double.parse(walletbalance);
                                      remainingAmount =
                                      _isSwitch && !_isLoyaltyToast &&
                                          _isLoayalty &&
                                          (double.parse(loyaltyPoints) >= 100)
                                          ? totalAmount -
                                          double.parse(walletbalance) -
                                          loyaltyAmount
                                          : (totalAmount -
                                          double.parse(walletbalance));
                                    });
                                  } else {
                                    setState(() {
                                      _isWallet = false;
                                      _ischeckbox = false;
                                    });
                                  }
                                  setState(() {
                                    _groupValue = i;
                                  });
                                }
                              } else {
                                _handleRadioValueChange1(i);
                              }
                            },
                            child: Container(
                              width:
                              MediaQuery.of(context).size.width,
                              padding: EdgeInsets.only(
                                // left: 10.0,
                                //right: 10.0,
                                  bottom: 20.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(Images.swipe,
                                            width: 26.0,
                                            height: 26.0,),
                                          Center(
                                            child: Text(
                                              paymentData.itemspayment[i]
                                                  .paymentName,
                                              style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: ColorCodes
                                                      .blackColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Image.asset(Images.swipecard,
                                        width: 100.0,
                                        height: 30.0,),
                                    ],
                                  ),
                                  Spacer(),
                                  SizedBox(
                                    width: 20.0,
                                    child: _myRadioButton(
                                      title: "",
                                      value: i,
                                      onChanged: (newValue) {
                                        setState(() {
                                          //  _groupValue = newValue;
                                          //   _ischeckbox = false;

                                          double totalAmount = 0.0;
                                          !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                          if (_isWallet && _ischeckboxshow) {
                                            _isOnline = false;
                                            _isSod = true;
                                            _isCOD = false;

                                            if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                              _isRemainingAmount = false;
                                              _groupValue = -1;
                                              prefs.setString("payment_type", "wallet");
                                              walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                            }else {
                                              if (_isOnline || _isCOD || _isSod) {
                                                setState(() {
                                                  _groupValue = -1;
                                                  _isRemainingAmount = true;
                                                  walletAmount = double.parse(
                                                      walletbalance);
                                                  remainingAmount =
                                                  _isSwitch &&
                                                      !_isLoyaltyToast &&
                                                      _isLoayalty &&
                                                      (double.parse(
                                                          loyaltyPoints) >= 100)
                                                      ? totalAmount -
                                                      double.parse(
                                                          walletbalance) -
                                                      loyaltyAmount
                                                      : (totalAmount - int
                                                      .parse(walletbalance));
                                                });
                                              } else {
                                                setState(() {
                                                  _isWallet = false;
                                                  _ischeckbox = false;
                                                });
                                              }
                                              setState(() {
                                                _groupValue = i;
                                              });
                                            }
                                          } else {
                                            _handleRadioValueChange1(i);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                  /* new ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: paymentData.itemspayment.length,
                    itemBuilder: (_, i) => Column(
                      children: [
                        if (paymentData.itemspayment[i].paymentMode ==
                            "1")
                          _isRemainingAmount
                              ?
                          Container(
                            width:
                            MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentData.itemspayment[i]
                                          .paymentName,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: ColorCodes
                                              .blackColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Image.asset(Images.onlineImg),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                        " " +
                                            remainingAmount
                                                .toStringAsFixed(2)+ _currencyFormat ,
                                        style: TextStyle(
                                            color: ColorCodes
                                                .blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                              : Container(
                            width:
                            MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                              // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paymentData.itemspayment[i]
                                          .paymentName,
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          color: ColorCodes
                                              .blackColor,fontWeight: FontWeight.bold),
                                    ),
                                    Image.asset(Images.onlineImg),
                                  ],
                                ),
                                SizedBox(
                                  width: 20.0,
                                  child: _myRadioButton(
                                    title: "",
                                    value: i,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _groupValue = newValue;
                                        _ischeckbox = false;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                        if (paymentData.itemspayment[i].paymentMode ==
                            "0")
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                top: 20.0,
                                // left: 10.0,
                                right: 10.0,
                                bottom: 20.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paymentData
                                            .itemspayment[i].paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes.blackColor),
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                              Images.cardMachineImg),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                              child: Text(
                                                "Our delivery personnel will carry a swipe machine & orders can be paid via Debit/Credit card at the time of delivery.",
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color:
                                                    ColorCodes.greyColor),
                                              )),
                                          SizedBox(width: 50.0),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 20.0,
                                  child: _myRadioButton(
                                    title: "",
                                    value: i,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _groupValue = newValue;
                                        _ischeckbox = false;
                                      });
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),*/
                ),
                Divider(
                  height:  0.5,
                  color: ColorCodes.lightGreyColor,

                ),
                Padding(
                  padding: const EdgeInsets.only(left:37.0,right:37,top:10),
                  child: SizedBox(
                    child: new ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paymentData.itemspayment.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          /* if (paymentData.itemspayment[i].paymentMode ==
                                      "6")
                                    Container(
                                      color: ColorCodes.lightGreyWebColor,
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                          top: 20.0,
                                          left: 10.0,
                                          right: 10.0,
                                          bottom: 20.0),
                                      child: Text(
                                        paymentData.itemspayment[i].paymentName,
                                        style: TextStyle(
                                            fontSize: 14.0,
                                            color: ColorCodes.blackColor),
                                      ),
                                    ),*/
                          if (paymentData.itemspayment[i].paymentMode ==
                              "6")
                            _isRemainingAmount && !_isOnline
                                && !_isSod ?
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                double totalAmount = 0.0;
                                !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                if (_isWallet && _ischeckboxshow) {
                                  _isOnline = false;
                                  _isCOD = true;
                                  _isSod = false;
                                  if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                    _isRemainingAmount = false;
                                    _groupValue = -1;
                                    prefs.setString("payment_type", "wallet");
                                    walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                  }
                                  else {
                                    if (_isOnline || _isCOD || _isSod) {
                                      setState(() {
                                        _groupValue = -1;
                                        _isRemainingAmount = true;
                                        walletAmount =
                                            double.parse(walletbalance);
                                        remainingAmount =
                                        _isSwitch && !_isLoyaltyToast &&
                                            _isLoayalty &&
                                            (double.parse(loyaltyPoints) >=100)
                                            ? totalAmount -
                                            double.parse(walletbalance) -
                                            loyaltyAmount
                                            : (totalAmount -
                                            double.parse(walletbalance));
                                      });
                                    } else {
                                      setState(() {
                                        _isWallet = false;
                                        _ischeckbox = false;
                                      });
                                    }
                                    setState(() {
                                      _groupValue = i;
                                    });
                                  }
                                } else {
                                  _handleRadioValueChange1(i);
                                }
                              },
                              child: Container(

                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                  //left: 10.0,
                                   // left: 10.0,

                                   // right: 10.0,
                                    bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [

                                    /*Image.asset(
                                              Images.cashImg,
                                              width: 26.0,
                                              height: 26.0,
                                            ),
                                            SizedBox(width: 5,),*/
                                    Expanded(
                                      child:
                                      Center(
                                        child: Container(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(
                                            //top: 20.0,
                                            //left: 10.0,
                                            //right: 10.0,
                                              bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                Images.cashImg,
                                                width: 26.0,
                                                height: 26.0,
                                              ),
                                              Center(
                                                child: Text(
                                             translate('forconvience.Cash on Delivery'),
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color:
                                                      ColorCodes.blackColor,

                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Spacer(),
                                              if(remainingAmount>0)
                                                Text(
                                                    remainingAmount
                                                        .toStringAsFixed(2) +
                                                        " " +_currencyFormat
                                                    ,
                                                    style: TextStyle(
                                                        color: ColorCodes
                                                            .blackColor,
                                                        fontSize: 12.0)),
                                              SizedBox(
                                                width: 10.0,
                                              ),
                                              SizedBox(
                                                width: 20.0,
                                                child: _myRadioButton(
                                                  title: "",
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      double totalAmount = 0.0;
                                                      !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                                      if (_isWallet && _ischeckboxshow) {
                                                        _isOnline = false;
                                                        _isCOD = true;
                                                        _isSod = false;
                                                        if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                          _isRemainingAmount = false;
                                                          _groupValue = -1;
                                                          prefs.setString("payment_type", "wallet");
                                                          walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                        }
                                                        else {
                                                          if (_isOnline || _isCOD || _isSod) {
                                                            setState(() {
                                                              _groupValue = -1;
                                                              _isRemainingAmount = true;
                                                              walletAmount = double.parse(
                                                                  walletbalance);
                                                              remainingAmount =
                                                              _isSwitch &&
                                                                  !_isLoyaltyToast &&
                                                                  _isLoayalty &&
                                                                  (double.parse(
                                                                      loyaltyPoints) >= 100)
                                                                  ? totalAmount -
                                                                  double.parse(
                                                                      walletbalance) -
                                                                  loyaltyAmount
                                                                  : (totalAmount -
                                                                  int.parse(
                                                                      walletbalance));
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _isWallet = false;
                                                              _ischeckbox = false;
                                                            });
                                                          }
                                                          setState(() {
                                                            _groupValue = i;
                                                          });
                                                        }
                                                      } else {
                                                        _handleRadioValueChange1(i);
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                              /*SizedBox(
                                                        height: 10.0,
                                                      ),*/
                                              /* Row(
                                                        children: [
                                                          *//*Image.asset(
                                                            Images.cashImg,
                                                            width: 26.0,
                                                            height: 26.0,
                                                          ),*//*
                                                          SizedBox(width: 10.0),
                                                          Expanded(
                                                              child: Text(
                                                            "Tip: To ensure a contactless delivery, we recommend you use an online payment method.",
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: ColorCodes
                                                                    .greyColor),
                                                          )),
                                                          SizedBox(width: 50.0),
                                                        ],
                                                      ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                :
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                double totalAmount = 0.0;
                                !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                if (_isWallet && _ischeckboxshow) {
                                  _isOnline = false;
                                  _isCOD = true;
                                  _isSod = false;

                                  if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                    _isRemainingAmount = false;
                                    _groupValue = -1;
                                    prefs.setString("payment_type", "wallet");
                                    walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                  }else {
                                    if (_isOnline || _isCOD || _isSod) {
                                      setState(() {
                                        _groupValue = -1;
                                        _isRemainingAmount = true;
                                        walletAmount =
                                            double.parse(walletbalance);
                                        remainingAmount =
                                        _isSwitch && !_isLoyaltyToast &&
                                            _isLoayalty &&
                                            (double.parse(loyaltyPoints) >= 100)
                                            ? totalAmount -
                                            double.parse(walletbalance) -
                                            loyaltyAmount
                                            : (totalAmount -
                                            double.parse(walletbalance));
                                      });
                                    } else {
                                      setState(() {
                                        _isWallet = false;
                                        _ischeckbox = false;
                                      });
                                    }
                                    setState(() {
                                      _groupValue = i;
                                    });
                                  }
                                } else {
                                  _handleRadioValueChange1(i);
                                }
                              },
                              child: Container(

                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.only(
                                    //left: 10.0,
                                    //right: 10.0,
                                    bottom: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    /*Image.asset(
                                              Images.cashImg,
                                              width: 26.0,
                                              height: 26.0,
                                            ),
                                            SizedBox(width: 5,),*/
                                    Expanded(
                                      child:
                                      Center(
                                        child: Container(
                                          width:
                                          MediaQuery.of(context).size.width,
                                          padding: EdgeInsets.only(
                                            //top: 20.0,
                                            //left: 10.0,
                                              //right: 10.0,
                                              bottom: 20.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                Images.cashImg,
                                                width: 26.0,
                                                height: 26.0,
                                              ),
                                              Center(
                                                child: Text(
                                                 translate('forconvience.Cash on Delivery'),
                                                  style: TextStyle(
                                                      fontSize: 14.0,
                                                      color:
                                                      ColorCodes.blackColor,

                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Spacer(),
                                              SizedBox(
                                                width: 20.0,
                                                child: _myRadioButton(
                                                  title: "",
                                                  value: i,
                                                  onChanged: (newValue) {
                                                    setState(() {

                                                      double totalAmount = 0.0;
                                                      !_displaypromo ? _isPickup ? totalAmount = cartTotal : totalAmount = (cartTotal + deliveryamount) : totalAmount = (double.parse(_promoamount));
                                                      if (_isWallet && _ischeckboxshow) {
                                                        _isOnline = false;
                                                        _isCOD = true;
                                                        _isSod = false;
                                                        if (_isSwitch ? totalAmount <= (double.parse(walletbalance) + loyaltyAmount) : totalAmount <= (double.parse(walletbalance))) {
                                                          _isRemainingAmount = false;
                                                          _groupValue = -1;
                                                          prefs.setString("payment_type", "wallet");
                                                          walletAmount = _isSwitch ? (totalAmount - loyaltyAmount) : totalAmount;
                                                        }
                                                        else {
                                                          if (_isOnline || _isCOD || _isSod) {
                                                            setState(() {
                                                              _groupValue = -1;
                                                              _isRemainingAmount = true;
                                                              walletAmount = double.parse(
                                                                  walletbalance);
                                                              remainingAmount =
                                                              _isSwitch &&
                                                                  !_isLoyaltyToast &&
                                                                  _isLoayalty &&
                                                                  (double.parse(
                                                                      loyaltyPoints) >= 100)
                                                                  ? totalAmount -
                                                                  double.parse(
                                                                      walletbalance) -
                                                                  loyaltyAmount
                                                                  : (totalAmount -
                                                                  int.parse(
                                                                      walletbalance));
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _isWallet = false;
                                                              _ischeckbox = false;
                                                            });
                                                          }
                                                          setState(() {
                                                            _groupValue = i;
                                                          });
                                                        }
                                                      } else {
                                                        _handleRadioValueChange1(i);
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                              /*SizedBox(
                                                        height: 10.0,
                                                      ),*/
                                              /* Row(
                                                        children: [
                                                          *//*Image.asset(
                                                            Images.cashImg,
                                                            width: 26.0,
                                                            height: 26.0,
                                                          ),*//*
                                                          SizedBox(width: 10.0),
                                                          Expanded(
                                                              child: Text(
                                                            "Tip: To ensure a contactless delivery, we recommend you use an online payment method.",
                                                            style: TextStyle(
                                                                fontSize: 12.0,
                                                                color: ColorCodes
                                                                    .greyColor),
                                                          )),
                                                          SizedBox(width: 50.0),
                                                        ],
                                                      ),*/
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    /* SizedBox(width: 50.0),
                                    Text(
                                        _currencyFormat +
                                            " " +
                                            remainingAmount
                                                .toStringAsFixed(2),
                                        style: TextStyle(
                                            color: ColorCodes
                                                .blackColor,
                                            fontSize: 12.0)),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    )*/

                                    /* SizedBox(
                                      width: 20.0,
                                      child: _myRadioButton(
                                        title: "",
                                        value: i,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                            _ischeckbox = false;
                                          });
                                        },
                                      ),
                                    )*/
                                  ],
                                ),
                              ),
                            )

                        ],
                      ),
                    ),
                  ),
                ),
                _isWeb
                    ? !_isPaymentMethod
                    ? GestureDetector(
                  onTap: () {
                   // _customToast("currently there are no payment methods available");
                        Fluttertoast.showToast(
                        msg:
                        "currently there are no payment methods available");
                  },
                  child: Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 10),
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Center(
                      child: Text(
                        translate('forconvience.PROCEED TO PAY'),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () {
                    if (!_ischeckbox && _groupValue == -1) {
                     // _customToast(translate('forconvience.select payment'));
                      Fluttertoast.showToast(
                          msg:
                          translate('forconvience.select payment')//"Please select a payment method!!!"
                      );
                    } else {
                      if (_ischeckbox && _isRemainingAmount && _isOnline) {
                        prefs.setString(
                            "payment_type", "paytm");
                        //prefs.setString("amount", walletbalance);
                        prefs.setString("amount",
                            walletAmount.toStringAsFixed(2));
                        prefs.setString("wallet_type", "0");
                      }
                      else if(_ischeckbox && _isRemainingAmount && _isCOD){
                        prefs.setString("payment_type", "cod");
                        //prefs.setString("amount", walletbalance);
                        prefs.setString(
                            "amount", walletAmount.toStringAsFixed(2));
                        prefs.setString("wallet_type", "0");
                      }

                      else if (_ischeckbox) {
                        prefs.setString(
                            "payment_type", "wallet");
                        //prefs.setString("amount", (cartTotal + deliveryamount).toStringAsFixed(2));
                        prefs.setString("amount",
                            walletAmount.toStringAsFixed(2));
                        prefs.setString("wallet_type", "0");
                      }
                      _dialogforOrdering(context);
                      Orderfood();
                      /*if(prefs.containsKey("orderId")) {
                                          _cancelOrder().then((value) async {
                                            Orderfood();
                                          });
                                        } else {
                                          Orderfood();
                                        }*/
                    }
                  },
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    padding:
                    EdgeInsets.symmetric(horizontal: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Center(
                      child: Text(
                        translate('forconvience.PROCEED TO PAY'),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
                    : SizedBox.shrink(),
                SizedBox(
                  height: 20,
                ),
              ],
            )
            //)
                : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  "Currently there is no payment methods",
                  style: TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      }

      if (!_displaypromo) {
        if (_isPickup) {
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100)) {
            amountPayable = (cartTotal - loyaltyAmount)/*.roundToDouble()*/;
          } else {
            amountPayable = cartTotal;
          }
        } else {
          // else statement for _isPickup
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0)  && (double.parse(loyaltyPointsUser.toString()) >=100)) {
            amountPayable =
                (cartTotal + deliveryamount - loyaltyAmount)/*.roundToDouble()*/;
          } else {
            amountPayable = (cartTotal + deliveryamount);
          }
        }
      } else {
        //else statement for !_displaypromo
        if (_isPickup) {
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100)) {
            amountPayable =
                (cartTotal - double.parse(_savedamount) - loyaltyAmount)
                    /*.roundToDouble()*/;
          } else {
            amountPayable = (cartTotal - double.parse(_savedamount));
          }
        } else {
          // else statement for _isPickup
          if (_isSwitch &&
              !_isLoyaltyToast &&
              _isLoayalty &&
              (double.parse(loyaltyPoints) > 0) && (double.parse(loyaltyPointsUser.toString()) >=100)) {
            amountPayable = (cartTotal +
                deliveryamount -
                double.parse(_savedamount) -
                loyaltyAmount)
                /*.roundToDouble()*/;
          } else {
            amountPayable =
            (cartTotal + deliveryamount - double.parse(_savedamount));
          }
        }
      }

      return _isLoading
          ? Expanded(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        ),
      )
          : Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              paymentDetails(),
              paymentSelection(),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                Footer(address: _address),
            ],
          ),
        ),
      );
    }

    return
      WillPopScope(
        onWillPop: () { // this is the block you need
          Navigator.of(context).pop();
          return Future.value(false);
        },
        child: Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
            ? gradientappbarmobile()
            : null,
        backgroundColor: _isWeb?ColorCodes.whiteColor:null,
        body: Column(
          children: [
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),
            // !_isWeb ? _bodyMobile() : _bodyWeb(),
            (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ? _bodyWeb() : _bodyMobile(),
            // if (_isWeb && !ResponsiveLayout.isLargeScreen(context)) _bodyMobile(),
          ],
        ),
        bottomNavigationBar:
        _isWeb ? SizedBox.shrink() : Container(
          color: Colors.white,
          child: Padding(
              padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
              child: _buildBottomNavigationBar()
          ),
        ),
    ),
      );
  }
}
