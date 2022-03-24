import 'dart:async';
import 'dart:io';
import '../screens/myorder_screen.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_svg/svg.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../screens/mobile_authentication.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/notificationitems.dart';
import '../screens/policy_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../constants/ColorCodes.dart';
import '../providers/deliveryslotitems.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../utils/ResponsiveLayout.dart';
import '../screens/example_screen.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../main.dart';
import '../providers/addressitems.dart';
import '../providers/branditems.dart';
import '../constants/images.dart';
import '../screens/unavailablity_screen.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/address_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../screens/home_screen.dart';
import '../screens/pickup_screen.dart';
import '../widgets/cartitems_display.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import '../constants/IConstants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_translate/flutter_translate.dart';
import '../providers/unavailableproducts_field.dart';
import '../providers/sellingitemsfields.dart';
import '../providers/unavailabilitylist.dart';
import 'category_screen.dart';
import 'customer_support_screen.dart';
import 'map_screen.dart';
import 'membership_screen.dart';
import 'payment_screen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class CartScreen extends StatefulWidget {
  static const routeName = '/cart-screen';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  Box<Product> productBox;
  List<Product> items;
  var _currencyFormat = "";
  double minorderamount = 0;
  double minimumOrderAmount = 0;
  double deliverycharge = 0;
  var addressitemsData;
  SharedPreferences prefs;
  var shoplistData;
  final _form = GlobalKey<FormState>();
  bool _checkmembership = false;
  int _groupValue = 1;
  bool _isLoading = true;
  bool productunavailability;
  bool _isDelivering = false;
  bool checkskip = false;
  bool _isWeb = false;
  //pickup
  bool _checkStoreLoc = false;
  bool _isPickupSlots = false;
  DateTime pickedDate;
  double _cartTotal = 0.0;
  var pickuplocItem;
  var pickupTime;
  String selectTime = "";
  String selectDate = "";
  bool checkSkip = false;
  var _message = TextEditingController();
  //confirmorder
  TabController _tabController;
  String deliverlocation = "";
  bool _loading = true;
  var _checkaddress = false;
  var addtype;
  var address;
  IconData addressicon;
  //var addressitemsData;
  var deliveryslotData;
  var delChargeData;
  var timeslotsData;
  bool _isChangeAddress = false;
  bool _slotsLoading = false;
  var _checkslots = false;
  bool _loadingDelCharge = true;
  var currency_format = "";
  int _index = 0;
  int _radioValue = 1;
  String _deliveryDurationExpress = "0.0 ";
  var day, date, time = "10 AM - 1 PM";
  bool _loadingSlots = true;
  String _minimumOrderAmountNoraml = "0.0";
  String _deliveryChargeNormal = "0.0";
  String _minimumOrderAmountPrime = "0.0";
  String _deliveryChargePrime = "0.0";
  String _minimumOrderAmountExpress = "0.0";
  String _deliveryChargeExpress = "0.0";
  var timeslotsindex = "0";
  List checkBoxdata = [];
  List titlecolor = [];
  List iconcolor = [];
  int _count;
  var _address = "";
  var otpvalue = "";

  MediaQueryData queryData;
  double wid;
  double maxwid;
  String countryName = " ";
  String countrycode = " ";
  String photourl = "";
  String name = "";
  String phone = "";
  String apple = "";
  String email = "";
  String mobile = "";
  String tokenid = "";
  bool _isAvailable = false;
  bool _isSkip = false;
  String _deliverLocation = "";
  bool _isUnreadNot = false;
  int unreadCount = 0;
  Timer _timer;
  int _timeRemaining = 30;
  StreamController<int> _events;
  TextEditingController controller = TextEditingController();
  bool _showOtp = false;
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController lastnamecontroller = new TextEditingController();

  bool _obscureText = true;
  FocusNode emailfocus = FocusNode();
  FocusNode passwordfocus = FocusNode();
  final TextEditingController emailcontrolleralert = new TextEditingController();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  final TextEditingController otpcontroller = new TextEditingController();
  final TextEditingController newpasscontroller = new TextEditingController();

  final TextEditingController namecontroller = new TextEditingController();
  final TextEditingController emailcontrollersignup = new TextEditingController();
  final TextEditingController passwordcontrollersignup = new TextEditingController();
  final _formalert = GlobalKey<FormState>();
  final _formreset = GlobalKey<FormState>();
  final _lnameFocusNode = FocusNode();
  final _formsignup = GlobalKey<FormState>();
  bool navigatpass = false;

  String fn = "";
  String ln = "";
  String ea = "";
  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  List nlist = [4,2,1,5];
  var _showCall = false;

  var mobilenum = "";

  String otp1, otp2, otp3, otp4;


  String fnsignup = "";
  String lnsignup = "";
  String easignup = "";
  bool iphonex = false;

  //String _deliveryDurationExpress = "0.0 ";
  @override
  void initState() {
    productBox = Hive.box<Product>(productBoxName);
    _events = new StreamController<int>.broadcast();


    _events.add(30);
    _getmobilenum();
    pickedDate = DateTime.now();
    _tabController = new TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
          AppleSignIn.onCredentialRevoked.listen((_) {});
          if (await AppleSignIn.isAvailable()) {
            setState(() {
              _isAvailable = true;
            });
          } else {
            setState(() {
              _isAvailable = false;
            });
          }
        }
      } catch (e) {}
      if (!_isWeb) _listenotp();

      prefs = await SharedPreferences.getInstance();

      await Provider.of<BrandItemsList>(context, listen: false)
          .GetRestaurant()
          .then((_) {
        if (!prefs.containsKey("deliverylocation")) {
          setState(() {
            countrycode = prefs.getString("country_code");
            countryName = CountryPickerUtils.getCountryByPhoneCode(
                countrycode.split('+')[1])
                .name;
          });
        }
      });
    if(_isWeb)
      Provider.of<AddressItemsList>(context,listen: false).fetchAddress().then((_) {
        setState(() {
          addressitemsData = Provider.of<AddressItemsList>(context, listen: false);
          if (addressitemsData.items.length > 0) {
            _checkaddress = true;
            _loading = false;
            _isLoading = false;
            checkLocation();
          } else {
            _checkaddress = false;
            _loading = false;
            _isLoading = false;

          }
        });
      });
      //await itemcheck();



      setState(() {
        setState(() {
          if (prefs.containsKey("LoginStatus")) {
            if (prefs.getString('LoginStatus') == "true") {
              prefs.setString('skip', "no");
              checkskip = false;
            } else {
              prefs.setString('skip', "yes");
              checkskip = true;
            }
          } else {
            prefs.setString('skip', "yes");
            checkskip = true;
          }

          if (prefs.getString('applesignin') == "yes") {
            apple = prefs.getString('apple');
          } else {
            apple = "";
          }
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');
        });

        if (prefs.getString('mobile') != null) {
          phone = prefs.getString('mobile');
        } else {
          phone = "";
        }
        if (prefs.getString('photoUrl') != null) {
          photourl = prefs.getString('photoUrl');
        } else {
          photourl = "";
        }

        if (prefs.getString('skip') == "yes") {
          _isSkip = true;
        } else {
          _isSkip = false;
        }
        _deliverLocation = prefs.getString("deliverylocation");
        if (prefs.getString('skip') == "yes") {
          _isUnreadNot = false;
        } else {
          Provider.of<NotificationItemsList>(context, listen: false)
              .fetchNotificationLogs(prefs.getString('userID'))
              .then((_) {
            final notificationData =
            Provider.of<NotificationItemsList>(context, listen: false);
            if (notificationData.notItems.length <= 0) {
              setState(() {
                _isUnreadNot = false;
              });
            } else {
              if (notificationData
                  .notItems[notificationData.notItems.length - 1]
                  .unreadcount <=
                  0) {
                setState(() {
                  _isUnreadNot = false;
                });
              } else {
                setState(() {
                  _isUnreadNot = true;
                  unreadCount = notificationData
                      .notItems[notificationData.notItems.length - 1]
                      .unreadcount;
                });
              }
            }
          });
        }
      });
    });



    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      _address = prefs.getString("restaurant_address");
      setState(() {
        if (prefs.containsKey("LoginStatus")) {
          if (prefs.getString('LoginStatus') == "true") {
            prefs.setString('skip', "no");
            checkskip = false;
          } else {
            prefs.setString('skip', "yes");
            checkskip = true;
          }
        } else {
          prefs.setString('skip', "yes");
          checkskip = true;
        }
        _isLoading = false;
        _loading = false;
        productunavailability = false;
        _currencyFormat = prefs.getString("currency_format");
        minorderamount = double.parse(prefs.getString("min_order_amount"));
        deliverycharge = double.parse(prefs.getString("delivery_charge"));
        minimumOrderAmount =
            double.parse(prefs.getString("minimum_order_amount"));
        currency_format = prefs.getString("currency_format");
        deliverlocation = prefs.getString("deliverylocation");
        prefs.setString('fixtime', "");
        prefs.setString("fixdate", "");
        if (prefs.getString("membership") == "1") {
          _checkmembership = true;
        } else {
          _checkmembership = false;
        }
        _isLoading = false;
        _loading = false;
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);
        //checkLocation();
        //pickup screen
        if (prefs.getString("membership") == "1") {
          _cartTotal = Calculations.totalMember;
        } else {
          _cartTotal = Calculations.total;
        }
        Provider.of<BrandItemsList>(context, listen: false).fetchWalletBalance();
        Provider.of<BrandItemsList>(context, listen: false).fetchPickupfromStore().then((_) {
          pickuplocItem = Provider.of<BrandItemsList>(context, listen: false);
          if (pickuplocItem.itemspickuploc.length > 0) {
            setState(() {
              _checkStoreLoc = true;
              Provider.of<DeliveryslotitemsList>(context, listen: false)
                  .fetchPickupslots(pickuplocItem.itemspickuploc[0].id)
                  .then((_) {
                pickupTime =
                    Provider.of<DeliveryslotitemsList>(context, listen: false);
                if (pickupTime.itemsPickup.length > 0) {
                  _isPickupSlots = true;
                  selectTime = pickupTime.itemsPickup[0].time;
                  selectDate = pickupTime.itemsPickup[0].date;
                  _isLoading = false;
                  _loading = false;
                } else {
                  _isLoading = false;
                  _loading = false;
                  _isPickupSlots = false;
                }
              });
            });
          } else {
            setState(() {
              _checkStoreLoc = false;
              _isLoading = false;
              _loading = false;
            });
          }
        });

        Provider.of<BrandItemsList>(context, listen: false).fetchWalletBalance();
        Provider.of<BrandItemsList>(context, listen: false).fetchPaymentMode();
      });
      //await itemcheck();
    });
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
    _googleSignIn.signInSilently();
    super.initState();
  }
  _getmobilenum() async {
    prefs = await SharedPreferences.getInstance();
    mobilenum = prefs.getString("Mobilenum");
  }
  void _listenotp() async {
    await SmsAutoFill().listenForCode;
  }
  _saveFormmobile() async {
    var shouldAbsorb = true;

    //  final signcode = SmsAutoFill().getAppSignature;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context, listen: false).LoginEmail();
    _dialogforProcessing();
    checkMobilenum();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }


  Future<void> checkMobilenum() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/pre-registerwotp';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "mobileNumber": prefs.getString('Mobilenum'),
            "tokenId": prefs.getString('tokenid'),
            "signature":prefs.containsKey("signature") ? prefs.getString('signature') : ""
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          return _customToast(translate('forconvience.Mobile number already exists'));
          /*return Fluttertoast.showToast(msg: translate('forconvience.Mobile number already exists'),//"Mobile number already exists!!! Please Try with Different one"
          );*/
        } else if (responseJson['type'].toString() == "new") {
          prefs.setString('Otp', responseJson['data']['otp'].toString());
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          _dialogforOtp();
          //Provider.of<BrandItemsList>(context, listen: false).LoginUser();
          // _verifyOtp();
          /*return Navigator.of(context).pushNamed(
            OtpconfirmScreen.routeName,
          );*/
        }
      } else {
        Navigator.of(context).pop();
        return _customToast("Something went wrong!!!");
        // return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }

    } catch (error) {
      throw error;
    }
  }

  void aler_dialofortmobile(BuildContext ctx) {
    mobile=prefs.getString("Mobilenum");
    var alert = AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        content: StreamBuilder<int>(
            stream: _events.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return
                Container(
                    height:(_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3,
                    width:(_isWeb && ResponsiveLayout.isSmallScreen(context)) ?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.5,
                    child:
                    Column(children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        padding: EdgeInsets.only(left: 20.0),
                        color: ColorCodes.lightGreyWebColor,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              translate('forconvience.Personal Details'),//"Signup using OTP",
                              style: TextStyle(
                                  color: ColorCodes.mediumBlackColor,
                                  fontSize: 20.0),
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child:

                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /* SizedBox(height: 25.0),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Please check OTP sent to your mobile number',
                                style: TextStyle(
                                    color: Color(0xFF404040),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),

                                // textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 20.0),
                                Text(
                                  countrycode + '  $mobile',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 16.0),
                                ),
                                SizedBox(width: 30.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _dialogforSignIn();

                                  },
                                  child: Container(
                                    height: 35,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Color(0x707070B8), width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text('Change',
                                            style: TextStyle(
                                                color: Color(0xFF070707), fontSize: 13))),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                'Enter OTP',
                                style: TextStyle(color: Color(0xFF727272), fontSize: 14),
                                //textAlign: TextAlign.left,
                              ),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                              // Auto Sms
                              Container(
                                  height: 40,
                                  //width: MediaQuery.of(context).size.width*80/100,
                                  width:(_isWeb && ResponsiveLayout.isSmallScreen(context)) ?MediaQuery.of(context).size.width/2:MediaQuery.of(context).size.width / 3,
                                  //padding: EdgeInsets.zero,
                                  child: PinFieldAutoFill(
                                      controller: controller,
                                      decoration: UnderlineDecoration(
                                          colorBuilder:
                                          FixedColorBuilder(Color(0xFF707070))),
                                      onCodeChanged: (text){
                                        otpvalue = text;
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) => setState(() {}));
                                      },
                                      onCodeSubmitted: (text) {
                                        SchedulerBinding.instance
                                            .addPostFrameCallback((_) => setState(() {
                                          otpvalue = text;
                                        }));
                                      },
                                      codeLength: 4,
                                      currentCode: otpvalue
                                  )),
                            ]),
                            SizedBox(
                              height: 20,
                            ),
                            _showOtp
                                ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*50/100:MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child:
                                      Center(child: Text('Resend OTP')),
                                    ),
                                  ),
                                  Container(
                                    height: 28,
                                    width: 28,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(
                                          'OR',
                                          style: TextStyle(fontSize: 10),
                                        )),
                                  ),
                                  _timeRemaining == 0
                                      ?
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      behavior:
                                      HitTestBehavior.translucent,
                                      onTap: () {
                                        otpCall();
                                        _timeRemaining = 60;
                                      },
                                      child: Expanded(
                                        child: Container(
                                          height: 40,
                                          //width: MediaQuery.of(context).size.width*32/100,
                                          decoration: BoxDecoration(

                                            borderRadius:
                                            BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.green,
                                                width: 1.5),
                                          ),

                                          child: Center(
                                              child: Text('Call me Instead')),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Expanded(
                                    child: Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child: Center(
                                        child: RichText(
                                          text: TextSpan(
                                            children: <TextSpan>[
                                              new TextSpan(
                                                  text: 'Call in',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                              new TextSpan(text: ' 00:$_timeRemaining',
                                                style: TextStyle(
                                                  color: Color(
                                                      0xffdbdbdb),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ])
                                : Row(
                              mainAxisAlignment:

                              MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _timeRemaining == 0
                                    ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      //  _showCall = true;
                                      _showOtp = true;
                                      _timeRemaining += 30;
                                      Otpin30sec();
                                    },
                                    child: Expanded(
                                      child: Container(
                                        height: 40,
                                        width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*30/100:MediaQuery.of(context).size.width*15/100,
                                        //width: MediaQuery.of(context).size.width*32/100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                              color: Colors.green, width: 1.5),
                                        ),
                                        child: Center(
                                            child: Text('Resend OTP')),
                                      ),
                                    ),
                                  ),
                                )
                                    : Expanded(
                                  child: Container(
                                    height: 40,
                                    //width: MediaQuery.of(context).size.width*40/100,
                                    decoration: BoxDecoration(
                                      borderRadius:BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Color(0x707070B8),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                      child: RichText(
                                        text: TextSpan(
                                          children: <TextSpan>[
                                            new TextSpan(
                                                text: 'Resend Otp in',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            new TextSpan(
                                              text: ' 00:$_timeRemaining',
                                              style: TextStyle(
                                                color: Color(0xffdbdbdb),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 28,
                                  width: 28,
                                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),

                                    border: Border.all(
                                        color: Color(0xFF6D6D6D),
                                        width: 1.5),
                                  ),
                                  child: Center(
                                      child: Text(
                                        'OR',
                                        style: TextStyle(fontSize: 10),
                                      )),
                                ),

                                Expanded(
                                  child: Container(
                                    height: 40,
                                    //width: MediaQuery.of(context).size.width*32/100,
                                    decoration: BoxDecoration(
                                      borderRadius:BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text('Call me Instead')),
                                  ),
                                ),
                              ],
                            ),*/

                              SizedBox(height: 20,),
                              Container(
                                //padding: EdgeInsets.symmetric(vertical: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(translate('forconvience.Please enter your mobile number'),//'Please enter your mobile number',
                                      style:TextStyle(color: ColorCodes.seeallcolor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,)
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top:20),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius:BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.grey
                                    ),
                                    color: Colors.white,
                                  ),
                                  height: 60.0,
                                  width: MediaQuery.of(context).size.width,
                                  child:  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CountryCodePicker(
                                        onChanged: null,
                                        enabled: false,
                                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                        initialSelection: countrycode,
                                        //customList: countrycodelist,
                                        //  favorite: [countrycode,'MA'],

                                        countryFilter: [countrycode,'MA'],
                                        // optional. Shows only country name and flag
                                        showCountryOnly: false,
                                        // optional. Shows only country name and flag when popup is closed.
                                        showOnlyCountryWhenClosed: false,
                                        // optional. aligns the flag and the Text left
                                        alignLeft: false,
                                      ),
                                      /* Text(
                    countrycode,
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                    ),
                  ),*/
                                      Text(
                                        "|   ",
                                        style: TextStyle(
                                          fontSize: 25.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top:10.0),
                                        child: Container(
                                            height: 60.0,
                                            width: 170.0,
                                            child: Form(
                                              key: _form,
                                              child: TextFormField(
                                                style: TextStyle(fontSize: 16.0),
                                                textAlign: TextAlign.left,
                                                inputFormatters: [LengthLimitingTextInputFormatter(12)],
                                                cursorColor: Theme.of(context).primaryColor,
                                                keyboardType: TextInputType.number,
                                                autofocus: true,
                                                decoration: new InputDecoration.collapsed(
                                                  //hintText: '9876543210',
                                                    hintStyle: TextStyle(color: Colors.black12, )
                                                ),
                                                validator: (value) {
                                                  String patttern = r'(^(?:[+0])?[0-9]{6,12}$)';
                                                  RegExp regExp = new RegExp(patttern);
                                                  if (value.isEmpty) {
                                                    return  translate('forconvience.Please enter your mobile number');//'Please enter a Mobile number.';
                                                  } else if (!regExp.hasMatch(value)) {
                                                    return 'Please enter valid mobile number';
                                                  }
                                                  return null; //it means user entered a valid input
                                                },
                                                onSaved: (value) {
                                                  addMobilenumToSF(value);
                                                },
                                              ),
                                            )
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(height: 25.0),

                              SizedBox(height: 20.0),
                            ]),
                      ),

                      /* Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 40.0),
                      Center(
                          child: Text(
                        'Please check OTP sent to your mobile number',
                        style: TextStyle(
                            color: Color(0xFF404040),
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(width: 20.0),
                          Text(
                            countrycode + '  $mobile',
                            style: new TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: 18.0),
                          ),
                          SizedBox(width: 40.0),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).pop();
                                _dialogforSignIn();

                              },
                              child: Container(
                                height: 35,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Color(0x707070B8), width: 1.5),
                                ),
                                child: Center(
                                    child: Text('Change',
                                        style: TextStyle(
                                            color: Color(0xFF070707)))),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.0),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Text('Enter OTP',
                            style: TextStyle(
                                color: Color(0xFF727272), fontSize: 18)),
                      ),
                      Row(children: [
                        SizedBox(
                          width: 30,
                        ),
                        // Auto Sms
                        Container(
                            height: 40,
                            //width: MediaQuery.of(context).size.width*80/100,
                            width: MediaQuery.of(context).size.width / 3.5,
                            //padding: EdgeInsets.zero,
                            child: PinFieldAutoFill(
                              controller: controller,
                              decoration: UnderlineDecoration(
                                  colorBuilder:
                                      FixedColorBuilder(Color(0xFF707070))),
                              onCodeChanged: (text){
                                otpvalue = text;
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) => setState(() {}));
                              },
                              onCodeSubmitted: (text) {
                                SchedulerBinding.instance
                                    .addPostFrameCallback((_) => setState(() {
                                  otpvalue = text;
                                }));
                              },
                              codeLength: 4,
                                currentCode: otpvalue
                            ))
                      ]),
                      SizedBox(
                        height: 25,
                      ),

                   //   GrocBay new Resend OTP buttons

                      _showOtp
                          ? Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*50/100:MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Color(0xFF6D6D6D),
                                            width: 1.5),
                                      ),
                                      child:
                                          Center(child: Text('Resend OTP')),
                                    ),
                                  ),
                                  Container(
                                    height: 28,
                                    width: 28,
                                    margin: EdgeInsets.only(
                                        left: 20.0, right: 20.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(
                                      'OR',
                                      style: TextStyle(fontSize: 10),
                                    )),
                                  ),
                                  _timeRemaining == 0
                                      ? MouseRegion(
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            behavior:
                                                HitTestBehavior.translucent,
                                            onTap: () {
                                              otpCall();
                                              _timeRemaining = 60;
                                            },
                                            child: Expanded(
                                              child: Container(
                                                height: 40,
                                                //width: MediaQuery.of(context).size.width*32/100,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6),
                                                  border: Border.all(
                                                      color: Colors.green,
                                                      width: 1.5),
                                                ),
                                                child: Center(
                                                    child: Text(
                                                        'Call me Instead')),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          child: Container(
                                            height: 40,
                                            //width: MediaQuery.of(context).size.width*32/100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Color(0xFF6D6D6D),
                                                  width: 1.5),
                                            ),
                                            child: Center(
                                              child: RichText(
                                                text: TextSpan(
                                                  children: <TextSpan>[
                                                    new TextSpan(
                                                        text: 'Call in',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black)),
                                                    new TextSpan(
                                                      text:
                                                          ' 00:$_timeRemaining',
                                                      style: TextStyle(
                                                        color: Color(
                                                            0xffdbdbdb),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                ])
                          : Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _timeRemaining == 0
                                    ? MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          behavior:
                                              HitTestBehavior.translucent,
                                          onTap: () {
                                            // _showCall = true;
                                            _showOtp = true;
                                            _timeRemaining += 30;
                                            Otpin30sec();
                                          },
                                          child: Expanded(
                                            child: Container(
                                              height: 40,
                                               width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*30/100:MediaQuery.of(context).size.width*15/100,
                                              //width: MediaQuery.of(context).size.width*32/100,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        6),
                                                border: Border.all(
                                                    color: Colors.green,
                                                    width: 1.5),
                                              ),
                                              child: Center(
                                                  child:
                                                      Text('Resend OTP')),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: Container(
                                          height: 40,
                                          //width: MediaQuery.of(context).size.width*40/100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Color(0x707070B8),
                                                width: 1.5),
                                          ),
                                          child: Center(
                                            child: RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                      text: 'Resend Otp in',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black)),
                                                  new TextSpan(
                                                    text:
                                                        ' 00:$_timeRemaining',
                                                    style: TextStyle(
                                                      color:
                                                          Color(0xffdbdbdb),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                Container(
                                  height: 28,
                                  width: 28,
                                  margin: EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Color(0xFF6D6D6D),
                                        width: 1.5),
                                  ),
                                  child: Center(
                                      child: Text(
                                    'OR',
                                    style: TextStyle(fontSize: 10),
                                  )),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 40,
                                    //width: MediaQuery.of(context).size.width*32/100,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text('Call me Instead')),
                                  ),
                                ),
                              ],
                            ),
                     // This expands the row element vertically because it's inside a column


                    ]),*/


                      Spacer(),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {

                              setState(() {
                                _isLoading = true;
                                //count + 1;
                              });
                              _isLoading
                                  ? CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                              )
                                  : prefs.setString('skip', "no");
                              prefs.setString('prevscreen', "mobilenumber");
                              FocusScope.of(context).unfocus();
                              _saveFormmobile();

                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  )),
                              height: 60.0,
                              child: Center(
                                child: Text(
                                  translate('forconvience.VERIFY'),  //"LOGIN",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).buttonColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                      ),
                    ])
                );
            }));
    _startTimer();
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return alert;
        });
  }

  Future<void> _getprimarylocation() async {
    var url = IConstants.API_PATH + 'customer/get-profile';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);
      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list
      for (int i = 0; i < data.length; i++) {
        prefs.setString("deliverylocation", data[i]['area']);

        if (prefs.containsKey("deliverylocation")) {
          Navigator.of(context).pop();
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  CartScreen.routeName,
                  ModalRoute.withName(HomeScreen.routeName));
            } else {
              Navigator.of(context).popUntil(ModalRoute.withName(
                HomeScreen.routeName,
              ));
            }
          } else {
            Navigator.of(context).pushNamed(
              HomeScreen.routeName,
            );
          }
        } else {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
        }
      }
      //Navigator.of(context).pop();
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  void initiateFacebookLogin() async {
    final facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.nativeWithFallback;
    final result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.error:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Sign in failed!",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          //msg: "Sign in cancelled by user!",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,picture,email&access_token=${token}');
        final profile = json.decode(graphResponse.body);

        prefs.setString("FBAccessToken", token);

        prefs.setString('FirstName', profile['first_name'].toString());
        prefs.setString('LastName', profile['last_name'].toString());
        prefs.setString('Email', profile['email'].toString());

        final pictureencode = json.encode(profile['picture']);
        final picturedecode = json.decode(pictureencode);

        final dataencode = json.encode(picturedecode['data']);
        final datadecode = json.decode(dataencode);

        prefs.setString("photoUrl", datadecode['url'].toString());

        prefs.setString('prevscreen', "signinfacebook");
        checkusertype("Facebooksigin");
        //onLoginStatusChanged(true);
        break;
    }
  }

  Future<void> facebooklogin() {
    prefs.setString('skip', "no");
    prefs.setString('applesignin', "no");
    initiateFacebookLogin();
  }

  Future<void> appleLogIn() async {
    prefs.setString('applesignin', "yes");
    _dialogforProcessing();
    prefs.setString('skip', "no");
    if (await AppleSignIn.isAvailable()) {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          var url = IConstants.API_PATH + 'customer/email-login';
          try {
            final response = await http.post(url, body: {
              // await keyword is used to wait to this operation is complete.
              "email": result.credential.user.toString(),
              "tokenId": prefs.getString('tokenid'),
            });
            final responseJson = json.decode(utf8.decode(response.bodyBytes));
            if (responseJson['type'].toString() == "old") {
              if (responseJson['data'] != "null") {
                final data = responseJson['data'] as Map<String, dynamic>;

                if (responseJson['status'].toString() == "true") {
                  prefs.setString('apiKey', data['apiKey'].toString());
                  prefs.setString('userID', data['userID'].toString());
                  prefs.setString('membership', data['membership'].toString());
                  prefs.setString("mobile", data['mobile'].toString());
                  prefs.setString("latitude", data['latitude'].toString());
                  prefs.setString("longitude", data['longitude'].toString());

                  prefs.setString('name', data['name'].toString());
                  prefs.setString('FirstName', data['name'].toString());
                  prefs.setString('FirstName', data['username'].toString());
                  prefs.setString('LastName', "");
                  prefs.setString('Email', data['email'].toString());
                  prefs.setString("photoUrl", "");
                  prefs.setString('apple', data['apple'].toString());
                } else if (responseJson['status'].toString() == "false") {}
              }
              prefs.setString('LoginStatus', "true");
              setState(() {
                checkskip = false;
                if (prefs.getString('FirstName') != null) {
                  if (prefs.getString('LastName') != null) {
                    name = prefs.getString('FirstName') +
                        " " +
                        prefs.getString('LastName');
                  } else {
                    name = prefs.getString('FirstName');
                  }
                } else {
                  name = "";
                }

                //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
                if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
                  email = "";
                } else {
                  email = prefs.getString('Email');
                }
                mobile = prefs.getString('Mobilenum');
                tokenid = prefs.getString('tokenid');

                if (prefs.getString('mobile') != null) {
                  phone = prefs.getString('mobile');
                } else {
                  phone = "";
                }
                if (prefs.getString('photoUrl') != null) {
                  photourl = prefs.getString('photoUrl');
                } else {
                  photourl = "";
                }
              });
              _getprimarylocation();
            } else {
              prefs.setString('apple', result.credential.user.toString());
              prefs.setString(
                  'FirstName', result.credential.fullName?.givenName);
              prefs.setString(
                  'LastName', result.credential.fullName?.familyName);
              prefs.setString("photoUrl", "");

              if (result.credential.email.toString() == "null") {
                prefs.setString('prevscreen', "signInAppleNoEmail");
                Navigator.of(context).pop();
                /*Navigator.of(context).pushReplacementNamed(
                  LoginScreen.routeName,);*/
              } else {
                prefs.setString('Email', result.credential.email);
                prefs.setString('prevscreen', "signInApple");
                checkusertype("signInApple");
              }
            }
          } catch (error) {
            Navigator.of(context).pop();
            throw error;
          }

          break;
        case AuthorizationStatus.error:
          Navigator.of(context).pop();
          Fluttertoast.showToast(
              msg: "Sign in failed!",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          break;
        case AuthorizationStatus.cancelled:
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            //msg: "Sign in cancelled by user!",
              backgroundColor: Colors.black87,
              textColor: Colors.white);
          break;
      }
    } else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Apple SignIn is not available for your device!",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
  }

  Future<void> otpCall() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-call';
    try {
      //SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> Otpin30sec() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-30';
    try {
      //   SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> checkusertype(String prev) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-login';
    try {
      var response;
      if (prev == "signInApple") {
        response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
          "apple": prefs.getString('apple'),
        });
      } else {
        response = await http.post(url, body: {
          // await keyword is used to wait to this operation is complete.
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
        });
      }

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['type'].toString() == "old") {
        if (responseJson['data'] != "null") {
          final data = responseJson['data'] as Map<String, dynamic>;

          if (responseJson['status'].toString() == "true") {
            prefs.setString('apiKey', data['apiKey'].toString());
            prefs.setString('userID', data['userID'].toString());
            prefs.setString('membership', data['membership'].toString());
            prefs.setString("mobile", data['mobile'].toString());
            prefs.setString("latitude", data['latitude'].toString());
            prefs.setString("longitude", data['longitude'].toString());
          } else if (responseJson['status'].toString() == "false") {}
        }

        prefs.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        Navigator.of(context).pop();
        /* Navigator.of(context).pushReplacementNamed(
          LoginScreen.routeName,
        );*/
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  Future<void> _handleSignIn() async {
    prefs.setString('skip', "no");
    prefs.setString('applesignin', "no");
    try {
      final response = await _googleSignIn.signIn();
      response.email.toString();
      response.displayName.toString();
      response.photoUrl.toString();

      prefs.setString('FirstName', response.displayName.toString());
      prefs.setString('LastName', "");
      prefs.setString('Email', response.email.toString());
      prefs.setString("photoUrl", response.photoUrl.toString());

      prefs.setString('prevscreen', "signingoogle");
      checkusertype("Googlesigin");
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Sign in failed!",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
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
          final prev = routeArgs['prev'];
          if (prev == "address_screen") {
            _dialogforProcessing();
            cartCheck(
              prefs.getString("addressId"),
              addressitemsData.items[0].userid,
              addressitemsData
                  .items[0].useraddtype,
              addressitemsData.items[0].useraddress,
              addressitemsData
                  .items[0].addressicon,
            );
            _loading = false;
            _isLoading = false;
          } else {
            if (addressitemsData.items.length > 0) {
              _checkaddress = true;
              addtype = addressitemsData
                  .items[0].useraddtype;
              address = addressitemsData.items[0].useraddress;
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
              _loading = false;
              _isLoading = false;
            } else {
              _checkaddress = false;
              _loading = false;
              _isLoading = false;
            }
          }
        } else {
          setState(() {
            _isChangeAddress = true;
            _loading = false;
            _isLoading = false;
            _slotsLoading = false;
          });
        }
      } else {
        setState(() {
          _isChangeAddress = true;
          _loading = false;
          _isLoading = false;
          _slotsLoading = false;
        });
      }
    } catch (error) {
      throw error;
    }
  }

  /*Future<void> checkLocation() async {
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

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "yes") {
        if (prefs.getString("branch") == responseJson['branch'].toString()) {
          final routeArgs =
              ModalRoute.of(context).settings.arguments as Map<String, String>;
          final prev = routeArgs['prev'];
          if (prev == "address_screen") {
            _dialogforProcessing();
            cartCheck(
              prefs.getString("addressId"),
              addressitemsData.items[addressitemsData.items.length - 1].userid,
              addressitemsData
                  .items[addressitemsData.items.length - 1].useraddtype,
              addressitemsData
                  .items[addressitemsData.items.length - 1].useraddress,
              addressitemsData
                  .items[addressitemsData.items.length - 1].addressicon,
            );
          } else {
            if (addressitemsData.items.length > 0) {
              _checkaddress = true;
              addtype = addressitemsData
                  .items[addressitemsData.items.length - 1].useraddtype;
              address = addressitemsData
                  .items[addressitemsData.items.length - 1].useraddress;
              addressicon = addressitemsData
                  .items[addressitemsData.items.length - 1].addressicon;
              prefs.setString(
                  "addressId",
                  addressitemsData
                      .items[addressitemsData.items.length - 1].userid);
              calldeliverslots(addressitemsData
                  .items[addressitemsData.items.length - 1].userid);
              deliveryCharge(addressitemsData
                  .items[addressitemsData.items.length - 1].userid);
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
  }*/
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
          _loading = false;
        } else {
          _addresscheck = true;
          _isLoading = false;
          _loading = false;
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
          _loading = false;
          _isLoading = false;
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

  Future<void> calldeliverslots(String addressid) async {
    Provider.of<DeliveryslotitemsList>(context,listen: false)
        .fetchDeliveryslots(addressid)
        .then((_) {
      deliveryslotData = Provider.of<DeliveryslotitemsList>(context, listen: false);
      _isLoading = false;
      _loading = false;
      for(int i=0;i<deliveryslotData.items.length; i++){
        setState((){
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
          _isLoading = false;
          _loading = false;
          day = deliveryslotData.items[0].day;
          date = deliveryslotData.items[0].date;
          timeslotsData = Provider.of<DeliveryslotitemsList>(
            context,
            listen: false,
          ).findById(timeslotsindex);
          for(int i = 0; i < timeslotsData.length; i++) {
            setState(() {
              if(i == 0) {

                timeslotsData[i].selectedColor=Color(0xFF45B343);
                timeslotsData[i].borderColor=Color(0xFF45B343);
                timeslotsData[i].textColor=ColorCodes.whiteColor;
                timeslotsData[i].isSelect = true;
              } else {
                timeslotsData[i].selectedColor=ColorCodes.whiteColor;
                timeslotsData[i].borderColor=Color(0xffBEBEBE);
                timeslotsData[i].textColor=ColorCodes.blackColor;
                timeslotsData[i].isSelect = false;
              }
            });
            prefs.setString("fixdate", deliveryslotData.items[0].dateformat);
            prefs.setString('fixtime', timeslotsData[0].time);
            _loadingSlots = false;
            _slotsLoading = false;
            _loading = false;
            _isLoading = false;
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
          _loading = false;
          _isLoading = false;
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
                                                  .toString()+ currency_format ,
                                          style: TextStyle(fontSize: 12.0))
                                          : Text( " " + productBox.values.elementAt(i).itemPrice.toString()+currency_format , style: TextStyle(fontSize: 12.0))
                                          : Text( " " + productBox.values.elementAt(i).membershipPrice+currency_format , style: TextStyle(fontSize: 12.0))
                                          : (productBox.values.elementAt(i).itemPrice <= 0 || productBox.values.elementAt(i).itemPrice.toString() == "" || productBox.values.elementAt(i).itemPrice == productBox.values.elementAt(i).varMrp)
                                          ? Text( " " + productBox.values.elementAt(i).varMrp.toString()+currency_format , style: TextStyle(fontSize: 12.0))
                                          : Text(" " + productBox.values.elementAt(i).itemPrice.toString()+currency_format , style: TextStyle(fontSize: 12.0))
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

  addListnameToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('list_name', value);
  }


  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


  _saveFormsignup() async {
    final isValid = _formsignup.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formsignup.currentState.save();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _dialogforProcessing();
    checkemail();


    setState(() {
      _isLoading = false;
    });

  }


  Future<void> SignupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/password-register';

    String channel = "";
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String apple = "";
      if (prefs.getString('applesignin') == "yes") {
        apple = prefs.getString('apple');
      } else {
        apple = "";
      }

      String name =
      prefs.getString('FirstName') ;

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username":  prefs.getString('FirstName'),
        "email": prefs.getString('Email'),
        "mobileNumber": "",
        "path": apple,
        "tokenId": prefs.getString('tokenid'),
        "guestUserId" : prefs.getString('guestuserId'),
        "branch": prefs.getString('branch'),
        "password" :  prefs.getString('Password') ,
        "device": channel,
      });
      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));
        prefs.setString("skip", "no");
        prefs.setString('LoginStatus', "true");
        setState(() {
          checkSkip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        if (prefs.getString("ismap").toString() == "true") {

          addprimarylocation();
        } else if (prefs.getString("isdelivering").toString() == "true") {
          addprimarylocation();
        } else {
          Navigator.of(context).pop();
          prefs.setString("formapscreen", "homescreen");

          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
        }

      } else if (responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
        _customToast(responseJson['data'].toString());
      }
    } catch (error) {
      setState(() {});
      throw error;
    }
  }


  Future<void> addprimarylocation() async {
    var url = IConstants.API_PATH + 'add-primary-location';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString("userID"),
        "latitude": prefs.getString("latitude"),
        "longitude":prefs.getString("longitude"),
        "area": IConstants.deliverylocationmain.value.toString(),
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(response.body);
      if (responseJson["data"].toString() == "true") {
        if(prefs.getString("ismap").toString()=="true") {
          if(prefs.getString("fromcart").toString()=="cart_screen"){
            // Navigator.of(context).pop();
            Navigator.of(context)
                .pushNamed(MobileAuthScreen.routeName,);

          }
          else{
            /* Navigator.of(context).pop();
            return Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,
            );*/
            setState(() {
              checkSkip = false;
              if (prefs.getString('FirstName') != null) {
                if (prefs.getString('LastName') != null) {
                  name = prefs.getString('FirstName') +
                      " " +
                      prefs.getString('LastName');
                } else {
                  name = prefs.getString('FirstName');
                }
              } else {
                name = "";
              }

              //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
              if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
                email = "";
              } else {
                email = prefs.getString('Email');
              }
              mobile = prefs.getString('Mobilenum');
              tokenid = prefs.getString('tokenid');

              if (prefs.getString('mobile') != null) {
                phone = prefs.getString('mobile');
              } else {
                phone = "";
              }
              if (prefs.getString('photoUrl') != null) {
                photourl = prefs.getString('photoUrl');
              } else {
                photourl = "";
              }
            });
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }


        }
        else if(prefs.getString("isdelivering").toString()=="true"){
          setState(() {
            checkSkip = false;
            if (prefs.getString('FirstName') != null) {
              if (prefs.getString('LastName') != null) {
                name = prefs.getString('FirstName') +
                    " " +
                    prefs.getString('LastName');
              } else {
                name = prefs.getString('FirstName');
              }
            } else {
              name = "";
            }

            //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
            if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
              email = "";
            } else {
              email = prefs.getString('Email');
            }
            mobile = prefs.getString('Mobilenum');
            tokenid = prefs.getString('tokenid');

            if (prefs.getString('mobile') != null) {
              phone = prefs.getString('mobile');
            } else {
              phone = "";
            }
            if (prefs.getString('photoUrl') != null) {
              photourl = prefs.getString('photoUrl');
            } else {
              photourl = "";
            }
          });
          Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);


        }
        else {
          prefs.setString("formapscreen", "homescreen");
          Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
          /*Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,
          );*/
        }
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  _dialogforSignUp() {

    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3.3,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.7,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          translate('forconvience.Sign Up'),//"SignUp",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:
                          Form(
                            key: _formsignup,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                /*Text(
                      '* What should we call you?',
                      style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                    ),
                    SizedBox(height: 10),*/
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: namecontroller,
                                  decoration: InputDecoration(
                                    hintText: translate('forconvience.Name'),//'Name',
                                    prefixIcon: Icon(Icons.person_outline, size: 20,),
                                    hoverColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fnsignup = "  "+translate('forconvience.please enter name');//"  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fnsignup = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fnsignup,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red,fontSize: 12),
                                ),
                                SizedBox(height: 10.0),
                                /* Text(
                      'Tell us your e-mail',
                      style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),*/
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  controller: emailcontrollersignup,
                                  /*style: new TextStyle(
                          decorationColor: Theme.of(context).primaryColor),*/
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.email_outlined, size: 20,),
                                    hintText: translate('forconvience.Email') ,//'Email',
                                    fillColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Email Address'); //'Please enter Email Address.';
                                    } else if (!regExp.hasMatch(value)) {
                                      return translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';
                                    }
                                    return null;
                                  },
                                  /* if (value.isEmpty) {
                          setState(() {
                            fn1 = "  Please Enter Email";
                          });
                          return '';
                        }
                        else if (value == "")
                          emailValid = true;
                        else
                          emailValid = RegExp(
                                  )
                              .hasMatch(value);

                        if (!emailValid) {
                          setState(() {
                            ea1 = ' Please enter a valid email address';
                          });
                          return '';
                        }
                        setState(() {
                          ea2 = "";
                        });
                        return null; //it means user entered a valid input
                      },*/
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                SizedBox(height: 20.0),

                                TextFormField(
                                  controller: passwordcontrollersignup,
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.text,
                                  obscureText: _obscureText,
                                  style: new TextStyle(
                                    //  decorationColor: Theme.of(context).primaryColor
                                  ),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline, size: 20,),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        _toggle();
                                      },
                                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                    ),
                                    hintText: translate('forconvience.Password') , //'Password',
                                    fillColor: Colors.grey,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Password');//'Please enter Password.';
                                    }
                                    return null;
                                    /* if (value.isEmpty) {
                          setState(() {
                            fn2 = "  Please Enter Name";
                          });
                          return '';
                        }
                        setState(() {
                          fn2 = "";
                        });
                        return null;*/
                                  },
                                  onSaved: (value) {
                                    addPasswordToSF(value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          /* Form(
                            key: _form,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  '* '+ translate('forconvience.What should we call you ?'),
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: firstnamecontroller,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    hoverColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fn = "  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fn = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fn,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Tell us your e-mail',
                                  style: TextStyle(fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  style: new TextStyle(
                                      decorationColor: Theme.of(context).primaryColor),
                                  decoration: InputDecoration(
                                    hintText: 'xyz@gmail.com',
                                    fillColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(color: Colors.green, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    if (value == "")
                                      emailValid = true;
                                    else
                                      emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value);

                                    if (!emailValid) {
                                      setState(() {
                                        ea = ' Please enter a valid email address';
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      ea = "";
                                    });
                                    return null; //it means user entered a valid input
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ea,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' We\'ll email you as a reservation confirmation.',
                                  style: TextStyle(fontSize: 15.2, color: Color(0xFF929292)),
                                ),
                              ],
                            ),
                          ),*/
                        ),
                        //  Spacer(),



/*            GestureDetector(
              onTap: () {
                _saveForm();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                color: Color(0xFF2966A2),
                child: Center(
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            )*/
                      ],
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {


                          setState(() {
                            _isLoading = true;
                            // count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              :
                          _saveFormsignup();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          height: 60.0,
                          child: Center(
                            child: Text(
                              translate('forconvience.CONTINUE'),// "CONTINUE",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ),
                ]),
              ),
            );
          });
        });
  }


  _ForgotPassword() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _formalert.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formalert.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    Navigator.of(context).pop(true);
    _dialogforProcessing();
    Forgotpass();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }
  _ResetPassword() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _formreset.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _formreset.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    _dialogforProcessing();
    Resetpass();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }

  Future<void> Resetpass() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'reset-password';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id":prefs.getString('userID'),
        "password": newpasscontroller.text,//prefs.getString('Password'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      // final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == "200") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        _customToast(responseJson['data'].toString());

      } else if (responseJson['status'].toString() == "400") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        _customToast("Something Went Wrong !!");
      }
    } catch (error) {
      Navigator.of(context).pop(true);
      throw error;
    }
  }

  Future<void> Forgotpass() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'forgot-password';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        "email": emailcontrolleralert.text,//prefs.getString('Email'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == "200") {
        prefs.setString('Otp', responseJson['otp'].toString());
        prefs.setString('userID', data['id'].toString());
        Navigator.of(context).pop();
        _resetpass();
      } else if (responseJson['status'].toString() == "400") {}
    } catch (error) {
      throw error;
    }
  }

  _resetpass()
  {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                //  height: 350.0,
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?350:350,//MediaQuery.of(context).size.width / 3.3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/4:MediaQuery.of(context).size.width / 2.7,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:20.0,top: 10,bottom: 10),
                            child: Text(
                              translate('forconvience.Password Reset'),
                              //' Password Reset',
                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap:(){
                                Navigator.pop(context);
                              }
                              ,child: Icon(Icons.close)),
                          SizedBox(width: 5,),
                          //Image.asset(Images.phoneImg),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 10.0,
                      ),
/*
                    Padding(
                      padding: const EdgeInsets.only(left:20.0),
                      child: Text('Enter your email address',style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),*/
                      Form(
                          key: _formreset,
                          child:
                          Column(
                            children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.2,
                                height: 50,
                                margin:  EdgeInsets.only(
                                    left: 20.0, top: 8, right: 20.0, bottom: 8),
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                ),
                                child:
                                TextFormField(
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.number,
                                  //controller: emailcontrolleralert,
                                  /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColor,
                                  // keyboardType: TextInputType.emailAddress,
                                  //autofocus: true,

                                  decoration: new InputDecoration(
                                    //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                      hintText: translate('forconvience.Enter OTP'),//'Enter Otp',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                      )


                                  ),

                                  validator: (value) {
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    String otp=prefs.getString('Otp');
                                    if (value.isEmpty) {
                                      return  translate('forconvience.Please enter OTP');//'Please enter Otp.';//translate('forconvience.Please enter Email Address');//'Please enter Email Address.';

                                    } else if (value!=otp) {
                                      /*Fluttertoast.showToast(msg: "Please enter valid Otp.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);*/
                                      return  translate('forconvience.Please enter valid Otp');//'Please enter valid Otp.';
                                    }
                                    return null;
                                  },
                                  //it means user entered a valid input

                                  /* onSaved: (value) {
                                    addEmailToSF(value);
                                  },*/
                                ),
                              ),
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width / 1.2,
                                height: 50,
                                margin:  EdgeInsets.only(
                                    left: 20.0, top: 8, right: 20.0, bottom: 8),
                                padding: EdgeInsets.only(
                                    left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                  border: Border.all(width: 0.5, color: Colors.grey),
                                ),
                                child:
                                TextFormField(
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.left,
                                  obscureText: true,
                                  keyboardType: TextInputType.text,
                                  controller: newpasscontroller,
                                  /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                                  cursorColor: Theme
                                      .of(context)
                                      .primaryColor,
                                  // keyboardType: TextInputType.emailAddress,
                                  //autofocus: true,

                                  decoration: new InputDecoration(
                                    //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                      hintText: translate('forconvience.New Password'),//'New Password',
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                      )


                                  ),

                                  validator: (value) {
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return  translate('forconvience.Please enter New Password');//'Please enter New Password.';//translate('forconvience.Please enter Email Address');//'Please enter Email Address.';

                                    }
                                    /*  if (value.isEmpty) {
                                      // return 'Please enter Email Address.';

                                      Fluttertoast.showToast(msg: "Please enter New Password.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    }*/ /*else if (!regExp.hasMatch(value)) {
                                Fluttertoast.showToast(msg: "Please enter valid Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                                // return 'Please enter valid Email Address';
                              }*/
                                    return null;
                                  },
                                  //it means user entered a valid input

                                  /* onSaved: (value) {
                                    addPasswordToSF(value);
                                  },*/
                                ),
                              ),

                            ],
                          )


                      ),

                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoading = true;
                            // count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          // Navigator.of(context).pop();
                          _ResetPassword();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 40,
                          padding: EdgeInsets.all(5.0),
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 5, right: 20.0, bottom: 5),
                          decoration: BoxDecoration(
                              color: ColorCodes.darkgreen,
                              border: Border.all(
                                color: ColorCodes.darkgreen,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          child: Center(
                            child: Text(
                              translate('forconvience.Reset Password'), // "Reset Password",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }
  _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    Navigator.of(context).pop();
    _dialogforProceesing(context, "Creating List...");

    Provider.of<BrandItemsList>(context, listen: false).CreateShoppinglist().then((_) {
      Provider.of<BrandItemsList>(context, listen: false).fetchShoppinglist().then((_) {
        shoplistData = Provider.of<BrandItemsList>(context, listen: false);
        Navigator.of(context).pop();
        _dialogforShoppinglist(context);
      });
    });
  }


  _saveFormSignIn() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context).LoginEmail();
    _dialogforProcessing();
    LoginUser();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
  }

  Future<void> LoginUser() async {

    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'useremail-login';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": prefs.getString('Email'),
        "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "200") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['userID'].toString());
        prefs.setString('FirstName', data['name'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('deliverylocation', data['area'].toString());
        IConstants.deliverylocationmain.value=data['area'].toString();
        prefs.setString('LoginStatus', "true");

        setState(() {
          checkSkip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = PrefUtils.prefs.getString('FirstName') + " " + PrefUtils.prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl =prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });



        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('Name', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }

//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*  Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/
        prefs.setString('skip', "no");
        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);

      } else if (responseJson['status'].toString() == "400") {
        if(responseJson['data'].toString()=="Wrong Email!!!"){
          /* Fluttertoast.showToast(msg: translate('forconvience.invalid email'),//"Wrong email id or password.",
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
          //r  Navigator.of(context).pop();
          Navigator.of(context).pop();

          _customToast(translate('forconvience.invalid email'));

        }
        else if(responseJson['data'].toString()=="Wrong Password!!!"){
          /*Fluttertoast.showToast(msg: translate('forconvience.invalid password'),//"Wrong email id or password.",
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
          // Navigator.of(context).pop();
          Navigator.of(context).pop();
          _customToast(translate('forconvience.invalid password'));

        }
        else {
          //Fluttertoast.showToast(msg: responseJson['data']);
          Navigator.of(context).pop();
          _customToast(responseJson['data']);

        }

      }
      /*else if (responseJson['status'].toString() == "400") {
        Navigator.of(context).pop(true);

      }*/
    } catch (error) {
      //  Navigator.of(context).pop(true);
      throw error;
    }

  }

  Future<void> checkemail() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/email-check';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "email": prefs.getString('Email'),
          }
      );
      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          /* Fluttertoast.showToast(msg: translate('forconvience.Email id already exists!!!') //"Email id already exists!!!"
          );*/

          return _customToast(translate('forconvience.Email id already exists!!!'));
          Navigator.of(context).pop(true);
          // Navigator.of(context).pop(true);
          // _dialogforSignIn();
          // Navigator.of(context).pop();
          /*return  _dialogforSignIn();*/
          /* Navigator.of(context).pushReplacementNamed(
              SignupSelectionScreen.routeName);*/
        } else if (responseJson['type'].toString() == "new") {
          return SignupUser();
        }
      } else {
        Navigator.of(context).pop();
        return _customToast("Something went wrong!!!");
        // return Fluttertoast.showToast(msg: "Something went wrong!!!");

      }

    } catch (error) {
      throw error;
    }
  }

  _saveFormLogin() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    Provider.of<BrandItemsList>(context, listen: false).LoginUser();
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    _dialogforOtp();
  }

  /*Future<void> checkMobilenum() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/mobile-check';
    try {
      //  SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          return Fluttertoast.showToast(msg: "Mobile number already exists!!!");
        } else if (responseJson['type'].toString() == "new") {
          Provider.of<BrandItemsList>(context, listen: false).LoginUser();
          Navigator.of(context).pop();
          return _dialogforOtp;
        }
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
      throw error;
    }
  }*/

  void _startTimer() {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //setState(() {
      (_timeRemaining > 0) ? _timeRemaining-- : _timer.cancel();
      //});
      _events.add(_timeRemaining);
    });
  }

  additemtolist() {
    _dialogforProceesing(context, "Add item to list...");
    for (int i = 0; i < shoplistData.itemsshoplist.length; i++) {
      //adding item to multiple list
      if (shoplistData.itemsshoplist[i].listcheckbox) {
        for (int j = 0; j < productBox.length; j++) {
          Provider.of<BrandItemsList>(context, listen: false)
              .AdditemtoShoppinglist(
              productBox.values.elementAt(j).itemId.toString(),
              productBox.values.elementAt(j).varId.toString(),
              shoplistData.itemsshoplist[i].listid)
              .then((_) {
            if (i == (shoplistData.itemsshoplist.length - 1) &&
                j == (productBox.length - 1)) {
              Navigator.of(context).pop();

              Provider.of<BrandItemsList>(context, listen: false)
                  .fetchShoppinglist()
                  .then((_) {
                shoplistData =
                    Provider.of<BrandItemsList>(context, listen: false);
              });
              for (int i = 0; i < shoplistData.itemsshoplist.length; i++) {
                shoplistData.itemsshoplist[i].listcheckbox = false;
              }
            }
          });
        }
      }
    }
  }

  _dialogforForgotpass() {
    /*return  showDialog(
       context: context,
       builder: (context) {
         return StatefulBuilder(builder: (context, setState) {
           return WillPopScope(
             onWillPop: () {
               return Future.value(true);
             },
             child:Column(
               children: [
                 Row(
                   children: [
                     Text('Forgot Password'),
                     Spacer(),
                     Icon(Icons.close),

                     //Image.asset(Images.phoneImg),
                   ],
                 ),

                 Text('Enter your email address'),

                 Container(
                   width: MediaQuery
                       .of(context)
                       .size
                       .width / 1.2,
                   height: 45,
                   margin: EdgeInsets.only(bottom: 8.0),
                   padding: EdgeInsets.only(
                       left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(4.0),
                     border: Border.all(width: 0.5, color: Colors.grey),
                   ),
                   child: TextFormField(
                     style: TextStyle(fontSize: 16.0),
                     textAlign: TextAlign.left,
                     inputFormatters: [
                       LengthLimitingTextInputFormatter(12)
                     ],

                     cursorColor: Theme
                         .of(context)
                         .primaryColor,
                     keyboardType: TextInputType.number,
                     //autofocus: true,

                     decoration: new InputDecoration(
                       //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                         border: InputBorder.none,
                         focusedBorder: InputBorder.none,
                         enabledBorder: InputBorder.none,
                         errorBorder: InputBorder.none,
                         disabledBorder: InputBorder.none,
                         // prefixIcon: Icon(Icons.person_outline, size: 20,),
                         hintText: 'Email',
                         hintStyle: TextStyle(
                           color: Colors.black,
                         )


                     ),

                     validator: (value) {
                       String patttern = r'(^(?:[+0]9)?[0-9]{6,10}$)';
                       RegExp regExp = new RegExp(patttern);
                       if (value.isEmpty) {
                         return 'Please enter a Mobile number.';
                       } else if (!regExp.hasMatch(value)) {
                         return 'Please enter valid mobile number';
                       }
                       return null;
                     },
                     //it means user entered a valid input

                     onSaved: (value) {
                       addMobilenumToSF(value);
                     },
                   ),
                 ),

               ],
             ),


           );
         });



       });*/
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                // height: 240.0,
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?240:240,//MediaQuery.of(context).size.width / 3.3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/4:MediaQuery.of(context).size.width / 2.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left:20.0,top: 10,bottom: 10),
                            child: Text( translate('forconvience.Forgot password?') ,//'Forgot Password',
                              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap:(){
                                Navigator.pop(context);
                              }
                              ,child: Icon(Icons.close,color: ColorCodes.closebtncolor,)),
                          SizedBox(width: 5,),
                          //Image.asset(Images.phoneImg),
                        ],
                      ),
                      Divider(),
                      SizedBox(
                        height: 10.0,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(left:20.0),
                        child: Text( translate('forconvience.Email') ,//'Enter your email address',
                          style:  TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      Form(
                        key: _formalert,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 50,
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 8, right: 20.0, bottom: 8),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(width: 0.5, color: Colors.grey),
                          ),
                          child:
                          TextFormField(
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.emailAddress,
                            controller: emailcontrolleralert,
                            /*inputFormatters: [
                            LengthLimitingTextInputFormatter(12)
                          ],*/

                            cursorColor: Theme
                                .of(context)
                                .primaryColor,
                            // keyboardType: TextInputType.emailAddress,
                            //autofocus: true,

                            decoration: new InputDecoration(
                              //  border:OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                // prefixIcon: Icon(Icons.person_outline, size: 20,),
                                hintText: translate('forconvience.Email') ,//'Email address',
                                hintStyle: TextStyle(
                                  color: Colors.black,
                                )


                            ),

                            validator: (value) {
                              RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                              if (value.isEmpty) {
                                //Navigator.of(context).pop(true);
                                navigatpass = false;
                                return translate('forconvience.Please enter Email Address') ;//'Please enter Email Address.';
                                Fluttertoast.showToast(msg: "Please enter Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                              } else if (!regExp.hasMatch(value)) {
                                navigatpass = false;
                                Fluttertoast.showToast(msg: translate('forconvience.Please enter valid Email Address'),//"Please enter valid Email Address.",
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                                Navigator.of(context).pop(true);
                                return  translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';

                              }else{
                                navigatpass = true;
                              }

                              return null;
                            },
                            //it means user entered a valid input

                            /* onSaved: (value) {
                              addEmailToSF(value);
                            },*/
                          ),
                        ),
                      ),

                      SizedBox(height: 15,),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if(navigatpass)
                              _isLoading = true;
                            // count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          //  Navigator.of(context).pop();
                          _ForgotPassword();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 40,
                          padding: EdgeInsets.all(5.0),
                          margin:  EdgeInsets.only(
                              left: 20.0, top: 5, right: 20.0, bottom: 5),
                          decoration: BoxDecoration(
                              color: ColorCodes.darkgreen,
                              border: Border.all(
                                color: ColorCodes.darkgreen,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),
                          /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                    color: ColorCodes.greenColor,
                  ),
                ),*/
                          child: Center(
                            child: Text(
                              translate('forconvience.SEND') , // "SEND",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforProceesing(BuildContext context, String text) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
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
                      Text(text),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforCreatelist(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  height: 250.0,
                  margin: EdgeInsets.only(
                      left: 20.0, top: 10.0, right: 10.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Create shopping list',
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Form(
                        key: _form,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter a list name.';
                                }
                                return null; //it means user entered a valid input
                              },
                              onSaved: (value) {
                                addListnameToSF(value);
                              },
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: "Shopping list name",
                                labelStyle: TextStyle(
                                    color: Theme.of(context).accentColor),
                                contentPadding: EdgeInsets.all(12),
                                hintText: 'ex: Monthly Grocery',
                                hintStyle: TextStyle(
                                    color: Colors.black12, fontSize: 10.0),
                                //prefixIcon: Icon(Icons.alternate_email, color: Theme.of(context).accentColor),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          _saveForm();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                'Create Shopping List',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme.of(context).buttonColor),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 40.0,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style:
                                TextStyle(color: Theme.of(context).buttonColor),
                              )),
                        ),
                      ),
                    ],
                  )),
            );
          });
        });
  }

  _dialogforShoppinglist(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0)),
                child: Container(
                  width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                      left: 10.0, top: 20.0, right: 10.0, bottom: 30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Add to list',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        SizedBox(
                          child: new ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: shoplistData.itemsshoplist.length,
                            itemBuilder: (_, i) => Row(
                              children: [
                                Checkbox(
                                  value: shoplistData
                                      .itemsshoplist[i].listcheckbox,
                                  onChanged: (bool value) {
                                    setState(() {
                                      shoplistData.itemsshoplist[i]
                                          .listcheckbox = value;
                                    });
                                  },
                                ),
                                Text(shoplistData.itemsshoplist[i].listname,
                                    style: TextStyle(fontSize: 18.0)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _dialogforCreatelist(context);
                            for (int i = 0;
                            i < shoplistData.itemsshoplist.length;
                            i++) {
                              shoplistData.itemsshoplist[i].listcheckbox =
                              false;
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 10.0,
                              ),
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "Create New",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            bool check = false;
                            for (int i = 0;
                            i < shoplistData.itemsshoplist.length;
                            i++) {
                              if (shoplistData.itemsshoplist[i].listcheckbox)
                                setState(() {
                                  check = true;
                                });
                            }
                            if (check) {
                              Navigator.of(context).pop();
                              additemtolist();
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Please select atleast one list!",
                                  backgroundColor: Colors.black87,
                                  textColor: Colors.white);
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  translate('forconvience.ADD'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).buttonColor),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            for (int i = 0;
                            i < shoplistData.itemsshoplist.length;
                            i++) {
                              shoplistData.itemsshoplist[i].listcheckbox =
                              false;
                            }
                          },
                          child: Container(
                            width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width*0.50:MediaQuery.of(context).size.width,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                            child: Center(
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Theme.of(context).buttonColor),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ));
          });
        });
  }

  stockupdation() {}

  Future<void> itemcheck() async {
    // imp feature in adding async is the it automatically wrap into Future.

    SharedPreferences prefs = await SharedPreferences.getInstance();
    productBox = Hive.box<Product>(productBoxName);
    //final cartitemsData = Provider.of<Calculations>(context, listen: false);
    String itemId = "";
    for (int i = 0; i < productBox.length; i++) {
      if (itemId == "") {
        itemId = productBox.values.elementAt(i).varId.toString();
      } else {
        itemId = itemId + "," + productBox.values.elementAt(i).varId.toString();
      }
    }

    var url = IConstants.API_PATH + 'get-cart-items/' + itemId;
    try {
      final response = await http.post(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];

      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>));

      for (int i = 0; i < data.length; i++) {
        final pricevarJson = json
            .encode(data[i]['price_variation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories

        if (pricevarJsondecode == null) {
        } else {
          pricevarJsondecode.asMap().forEach((index, value) => pricevardata
              .add(pricevarJsondecode[index] as Map<String, dynamic>));

          //***********************Membership and discount display ::*********************************//

/*        bool _discointDisplay = false;
        bool _membershipDisplay = false;

        if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
          _discointDisplay = false;
        } else {
          _discointDisplay = true;
        }
        if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
          _membershipDisplay = false;
        } else {
          _membershipDisplay = true;
        }
        */

          //***********************************************//************************************************//

          //  var items = Hive.box<Product>(productBoxName);
          List<unavailabilities> item = [];
          List<unavailabilities> itemvariation = [];
          for (int k = 0; k < pricevardata.length; k++) {
            for (int z = 0; z < productBox.length; z++) {
              /*    Product products = Product(
            varId: int.parse(pricevardata[k]['id'].toString()),
            varName: pricevardata[k]['variation_name'].toString(),
            varMinItem: int.parse(pricevardata[k]['min_item'].toString()),
            varMaxItem: int.parse(pricevardata[k]['max_item'].toString()),
            varStock: int.parse(pricevardata[k]['stock'].toString()),
            varMrp: double.parse(pricevardata[k]['mrp'].toString()),
          );*/
              Product products;
              if (Hive.box<Product>(productBoxName).values.elementAt(z).varId ==
                  int.parse(pricevardata[k]['id'].toString())) {
                if (int.parse(pricevardata[k]['stock'].toString()) <= 0) {
                  /*   products = Product(
              varId: int.parse(pricevardata[k]['id'].toString()),
              varName: pricevardata[k]['variation_name'].toString(),
              varMinItem: int.parse(pricevardata[k]['min_item'].toString()),
              varMaxItem: int.parse(pricevardata[k]['max_item'].toString()),
              varStock: int.parse(pricevardata[k]['stock'].toString()),
              varMrp: double.parse(pricevardata[k]['mrp'].toString()),
              itemId: int.parse(data[i]['id'].toString()),
              itemActualprice: double.parse(
                  pricevardata[k]['mrp'].toString()),
              membershipPrice: pricevardata[k]['membership_price'].toString(),
              itemName: data[i]['item_name'].toString(),
              itemQty: productBox.values
                  .elementAt(z)
                  .itemQty,
              itemPrice: double.parse(pricevardata[k]['price'].toString()),
              mode: productBox.values
                  .elementAt(z)
                  .mode,
              membershipId: productBox.values
                  .elementAt(z)
                  .membershipId,
              itemImage: IConstants.API_IMAGE + "items/images/" +
                  data[i]['item_featured_image'].toString(),


            );*/

                  // Provider.of<unavailability>(context, listen: false).;
                  //productBox.deleteAt(i);

/*

            item.add(unavailabilities(
              id: data[i]['id'].toString(),
              title: data[i]['item_name'].toString(),
              brand: data[i]['brand'].toString(),
            ));

            itemvariation.add(unavailabilities(
              varid: pricevardata[k]['id'].toString(),
              menuid: pricevardata[k]['menu_item_id'].toString(),
              varname: pricevardata[k]['variation_name'].toString(),
              varmrp: pricevardata[k]['mrp'].toString(),
              varprice: pricevardata[k]['price'].toString(),
              varmemberprice:pricevardata[k]['membership_price'].toString(),
              varstock: pricevardata[k]['stock'].toString(),
              varminitem: pricevardata[k]['min_item'].toString(),
              varmaxitem: pricevardata[k]['max_item'].toString(),
              imageUrl: IConstants.API_IMAGE + "items/images/" + pricevardata[k]['item_featured_image'].toString(),
            ));
*/

                  Provider.of<unavailabilities>(context, listen: false).unavailable(
                      data[i]['id'].toString(),
                      data[i]['item_name'].toString(),
                      data[i]['brand'].toString(),
                      pricevardata[k]['id'].toString(),
                      pricevardata[k]['menu_item_id'].toString(),
                      pricevardata[k]['variation_name'].toString(),
                      pricevardata[k]['mrp'].toString(),
                      pricevardata[k]['price'].toString(),
                      pricevardata[k]['membership_price'].toString(),
                      pricevardata[k]['stock'].toString(),
                      pricevardata[k]['min_item'].toString(),
                      pricevardata[k]['max_item'].toString(),
                      IConstants.API_IMAGE +
                          "items/images/" +
                          pricevardata[k]['item_featured_image'].toString());

                  Hive.box<Product>(productBoxName).deleteAt(z);

                  setState(() {
                    productunavailability = true;
                  });

                  /*   List<unavailabilities> get  items{
              return [...item];
            }*/
                } else if (Hive.box<Product>(productBoxName)
                    .values
                    .elementAt(k)
                    .itemQty >
                    int.parse(pricevardata[k]['stock'].toString())) {
                  products = Product(
                    varId: int.parse(pricevardata[k]['id'].toString()),
                    varName: pricevardata[k]['variation_name'].toString(),
                    varMinItem:
                    int.parse(pricevardata[k]['min_item'].toString()),
                    varMaxItem:
                    int.parse(pricevardata[k]['max_item'].toString()),
                    varStock: int.parse(pricevardata[k]['stock'].toString()),
                    varMrp: double.parse(pricevardata[k]['mrp'].toString()),
                    itemQty: int.parse(pricevardata[k]['stock'].toString()),
                    itemId: int.parse(data[i]['id'].toString()),
                    itemActualprice:
                    double.parse(pricevardata[k]['mrp'].toString()),
                    membershipPrice:
                    pricevardata[k]['membership_price'].toString(),
                    itemName: data[i]['item_name'].toString(),
                    itemWeight: double.parse(pricevardata[k]['mrp'].toString()),
                    itemPrice:
                    double.parse(pricevardata[k]['price'].toString()),
                    mode: productBox.values.elementAt(z).mode,
                    membershipId: productBox.values.elementAt(z).membershipId,
                    itemImage: IConstants.API_IMAGE +
                        "items/images/" +
                        data[i]['item_featured_image'].toString(),
                  );
                } else {
                  products = Product(
                    varId: int.parse(pricevardata[k]['id'].toString()),
                    varName: pricevardata[k]['variation_name'].toString(),
                    varMinItem:
                    int.parse(pricevardata[k]['min_item'].toString()),
                    varMaxItem:
                    int.parse(pricevardata[k]['max_item'].toString()),
                    varStock: int.parse(pricevardata[k]['stock'].toString()),
                    varMrp: double.parse(pricevardata[k]['mrp'].toString()),
                    itemId: int.parse(data[i]['id'].toString()),
                    itemActualprice:
                    double.parse(pricevardata[k]['mrp'].toString()),
                    membershipPrice:
                    pricevardata[k]['membership_price'].toString(),
                    itemName: data[i]['item_name'].toString(),
                    itemQty: productBox.values.elementAt(z).itemQty,
                    itemPrice:
                    double.parse(pricevardata[k]['price'].toString()),
                    mode: productBox.values.elementAt(z).mode,
                    membershipId: productBox.values.elementAt(z).membershipId,
                    itemImage: IConstants.API_IMAGE +
                        "items/images/" +
                        data[i]['item_featured_image'].toString(),
                  );

                  Hive.box<Product>(productBoxName).putAt(z, products);
                }
              }
              if (productunavailability == true) {
                Navigator.of(context)
                    .pushNamed(unavailability.routeName, arguments: {
                  'item': item,
                  'priceVariation': itemvariation,
                });
              }
            }
          }
        }
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

  Widget _myRadioButton({int value, Function onChanged}) {
    return Radio(
      value: value,
      groupValue: _groupValue,
      onChanged: onChanged,
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

  //login process
  _dialogforProcess() {
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
    Provider.of<DeliveryslotitemsList>(context, listen: false)
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
  addPasswordToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Password', value);
  }

  _dialogforSignIn() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width /1.9,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 3.0,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          translate('forconvience.Sign in') ,//"Sign in",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Column(
                    children: [
                      Form(
                        key: _form,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20,),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/80,horizontal: 30),
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 5,
                                shadowColor: Colors.grey,
                                child:

                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: emailcontroller,
                                  focusNode: emailfocus,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.go,
                                  decoration: InputDecoration(
                                    hintText:translate('forconvience.Email') ,//'Email',
                                    prefixIcon: Icon(Icons.person_outline, size: 20,),
                                    hoverColor: Colors.green,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (_) {
                                    emailfocus.unfocus();
                                    FocusScope.of(context).requestFocus(passwordfocus);
                                  },
                                  validator: (value) {
                                    String reg=r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    bool emailValid;
                                    RegExp regExp = new RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Email Address') ;//'Please enter Email Address.';
                                    } else if (!regExp.hasMatch(value)) {
                                      Fluttertoast.showToast(msg: translate('forconvience.Please enter valid Email Address'),//"Please enter valid Email Address.",
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                      setState(() {
                                        _isLoading =false;
                                      });
                                      return translate('forconvience.Please enter valid Email Address');//'Please enter valid Email Address';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/170,horizontal: 30),
                              child: Material(

                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 5,

                                shadowColor: Colors.grey,
                                child: TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: passwordcontroller,
                                  focusNode: passwordfocus,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    hintText:translate('forconvience.Password') , //'Password',
                                    prefixIcon: Icon(Icons.lock_outline, size: 20,),
                                    hoverColor: Colors.green,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (_) {
                                    passwordfocus.unfocus();
                                    //FocusScope.of(context).requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {

                                    if (value.isEmpty) {
                                      return translate('forconvience.Please enter Password') ; //'Please enter Password.';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addPasswordToSF(value);
                                  },
                                ),
                              ),
                            ),

                          ],
                        ),


                      ),
                      GestureDetector(
                        onTap:(){
                          _dialogforForgotpass();
                        },
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 1.2,
                          height: 30.0,
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/130, bottom: MediaQuery.of(context).size.height/80,right:30),

                          child: Text(
                            translate('forconvience.Forgot password?') ,
                            //"Forgot Password?",
                            textAlign: TextAlign.right,
                            style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isLoading = true;
                            //count + 1;
                          });
                          _isLoading
                              ? CircularProgressIndicator(
                            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                          )
                              : prefs.setString('skip', "no");
                          prefs.setString('prevscreen', "mobilenumber");
                          _saveFormSignIn();
                        },
                        child:
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width / 2,
                          height: 50,
                          margin:EdgeInsets.symmetric(horizontal:30.0),
                          padding: EdgeInsets.all(5.0),

                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(4))
                          ),

                          child: Center(
                            child: Text(
                              translate('forconvience.Sign in') ,// "SIGN IN",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,

                                  color: ColorCodes.whiteColor),

                            ),
                          ),
                        ),
                      ),
                    ],),
                  Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/20,left: 28.0,right:28,bottom:MediaQuery.of(context).size.height/20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color(
                                  0xff707070,
                                ),
                              ),
                            ),
                            Container(
                              //padding: EdgeInsets.all(4.0),
                              width: 23.0,
                              height: 23.0,
                              /* decoration: BoxDecoration(
                                  border: Border.all(
                                   // color: Color(0xff707070),
                                  ),
                                  shape: BoxShape.circle,
                                ),*/
                              child: Center(
                                  child: Text(
                                    translate('forconvience.OR') , //"OR",
                                    style:
                                    TextStyle(fontSize: 11.0, color: Color(0xff727272)),
                                  )),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Color(
                                  0xff707070,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*     Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 28),
                            child: GestureDetector(
                              onTap: () {
                                _dialogforProcessing();
                                _handleSignIn();
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: Container(

                                  padding: EdgeInsets.only(
                                      left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.only(right:23.0,left:23,),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          SvgPicture.asset(Images.googleImg, width: 25, height: 25,),
                                          //Image.asset(Images.googleImg,width: 20,height: 40,),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Text(
                                            translate('forconvience.Sign in with google') , //"Sign in with Google",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: ColorCodes.signincolor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/70, horizontal: 28),
                            child: GestureDetector(
                              onTap: () {
                                _dialogforProcessing();
                                facebooklogin();
                              },
                              child: Material(
                                borderRadius: BorderRadius.circular(4.0),
                                elevation: 2,
                                shadowColor: Colors.grey,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: 10.0,  right: 5.0, top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),

                                    // border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
                                  ),
                                  child:
                                  Padding(
                                    padding: const EdgeInsets.only(right:23.0,left: 23),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: <Widget>[
                                          SvgPicture.asset(Images.facebookImg, width: 25, height: 25,),
                                          //Image.asset(Images.facebookImg,width: 20,height: 40,),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Text(
                                            translate('forconvience.Sign in with Facebook') ,// "Sign in with Facebook",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: ColorCodes.signincolor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_isAvailable)
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 28),
                              child: GestureDetector(
                                onTap: () {
                                  appleLogIn();
                                },
                                child: Material(
                                  borderRadius: BorderRadius.circular(4.0),
                                  elevation: 2,
                                  shadowColor: Colors.grey,
                                  child: Container(

                                    padding: EdgeInsets.only(
                                        left: 10.0, right: 5.0,top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4.0),),
                                    child:
                                    Padding(
                                      padding: const EdgeInsets.only(right:23.0,left:23,),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            SvgPicture.asset(Images.appleImg, width: 25, height: 25,),
                                            //Image.asset(Images.appleImg, width: 20,height: 40,),
                                            SizedBox(
                                              width: 14,
                                            ),
                                            Text(
                                              translate('forconvience.Sign in with Apple')  , //"Sign in with Apple",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorCodes.signincolor),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          *//*if (_isAvailable)
                              Container(
                                margin: EdgeInsets.symmetric(*//**//*vertical: MediaQuery.of(context).size.height/700,*//**//* horizontal: 28),
                                child: GestureDetector(
                                  onTap: () {
                                    appleLogIn();
                                  },
                                  child: Material(
                                    borderRadius: BorderRadius.circular(4.0),
                                    elevation: 3,

                                    shadowColor: Colors.grey,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 10.0,  right: 5.0, top:MediaQuery.of(context).size.height/130, bottom:MediaQuery.of(context).size.height/130),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.0),),
                                      child:
                                      Padding(
                                        padding: const EdgeInsets.only(right:23.0,left: 23),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: <Widget>[
                                              Image.asset(Images.appleImg),
                                              SizedBox(
                                                width: 14,
                                              ),
                                              Text(
                                                "Se connecter avec Apple",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: ColorCodes.signincolor),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),*//*
                        ],
                      ),*/
                      Container(margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/120),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal:28,
                                //vertical: MediaQuery.of(context).size.height/120
                              ),
                              child: new RichText(
                                textAlign: TextAlign.left,
                                text: new TextSpan(
                                  style: new TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.grey,
                                  ),
                                  children: <TextSpan>[
                                    new TextSpan(text:" "+ translate('forconvience.Not a member yet?' ) ,//' Not a member yet? ',
                                        style: TextStyle(color: ColorCodes.signincolor,
                                            fontWeight:FontWeight.bold,fontSize: 16)),
                                    new TextSpan(
                                        text: " "+translate('forconvience.Signup now') ,//' Signup now',
                                        style: new TextStyle(color: Theme.of(context).primaryColor,fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.of(context).pop();
                                            // _dialogforSignIn();
                                            _dialogforSignUp();
                                            // _dialogforAddInfo();
                                            /*Navigator.of(context)
                                                .pushNamed(SignupScreen.routeName);*/
                                          }),
                                  ],
                                ),
                              ),
                            ),
                            // Spacer(),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(28, MediaQuery.of(context).size.height/22, 28, MediaQuery.of(context).size.height/170),
                                child:

                                new RichText(textAlign: TextAlign.center,
                                  text: new TextSpan(

                                    // Note: Styles for TextSpans must be explicitly defined.
                                    // Child text spans will inherit styles from parent
                                    style: new TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                    ),
                                    children: <TextSpan>[
                                      new TextSpan(text:" "+translate('forconvience.By continuing you agree to') ), //' By continuing you agree to '),
                                      new TextSpan(
                                          text: " "+translate('forconvience.Terms signup'),//' Terms and Conditions',
                                          style: new TextStyle(color: ColorCodes.darkgreen),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context)
                                                  .pushNamed(PolicyScreen.routeName, arguments: {
                                                'title': translate('forconvience.Terms and conditions'),//"Terms of Use",
                                                'body': prefs.getString("restaurant_terms"),
                                              });
                                            }),
                                      new TextSpan(text:" "+translate('forconvience.and to') //' and to'
                                      ),
                                      new TextSpan(
                                          text: " "+translate('forconvience.privacy signup'),//' Privacy Policy',
                                          style: new TextStyle(color: ColorCodes.darkgreen),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.of(context)
                                                  .pushNamed(PolicyScreen.routeName, arguments: {
                                                'title': translate('forconvience.privacy signup'),//"Privacy",
                                                'body': prefs.getString("privacy"),
                                              });
                                            }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),),
                    ],
                  )
                  /*   Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52,
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Images.countryImg,
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Country/Region",
                                      style: TextStyle(
                                        color: Color(0xff808080),
                                      )),
                                  Text(countryName + " (" + countrycode + ")",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52.0,
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Image.asset(Images.phoneImg),
                              SizedBox(
                                width: 14,
                              ),
                              Container(
                                  width:
                                  MediaQuery.of(context).size.width / 4.0,
                                  child: Form(
                                    key: _form,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.left,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12)
                                      ],
                                      cursorColor:
                                      Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: new InputDecoration.collapsed(
                                          hintText: 'Enter Your Mobile Number',
                                          hintStyle: TextStyle(
                                            color: Colors.black12,
                                          )),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter a Mobile number.';
                                        }
                                        return null; //it means user entered a valid input
                                      },
                                      onSaved: (value) {
                                        addMobilenumToSF(value);
                                      },
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 8.0, bottom: 36.0),
                          child: Text(
                            "We'll call or text you to confirm your number. Standard message data rates apply.",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff3B3B3B)),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              prefs.setString('skip', "no");
                              prefs.setString('prevscreen', "mobilenumber");
                              // prefs.setString('Mobilenum', value);

                              _saveForm();
                              _dialogforProcessing();

                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 32,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  width: 1.0,
                                  color: ColorCodes.greenColor,
                                ),
                              ),
                              child: Text(
                                "LOGIN USING OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    color: Color(0xff070707)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 12.0, bottom: 32.0),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: 'By continuing you agree to the '),
                                new TextSpan(
                                    text: ' terms of service',
                                    style:
                                    new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Terms of Use",
                                              'body': prefs.getString(
                                                  "restaurant_terms"),
                                            });
                                      }),
                                new TextSpan(text: ' and'),
                                new TextSpan(
                                    text: ' Privacy Policy',
                                    style:
                                    new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Privacy",
                                              'body':
                                              prefs.getString("privacy"),
                                            });
                                      }),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                              Container(
                                //padding: EdgeInsets.all(4.0),
                                width: 23.0,
                                height: 23.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff707070),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(
                                      "OR",
                                      style: TextStyle(
                                          fontSize: 10.0, color: Color(0xff727272)),
                                    )),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 44,
                          width: MediaQuery.of(context).size.width / 1.2,
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5,
                                color: Color(0xff4B4B4B).withOpacity(1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    _handleSignIn();
                                  },
                                  child: SvgPicture.asset(Images.googleImg, *//*width: 20,height: 30,*//*),),
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    facebooklogin();
                                  },
                                  child: SvgPicture.asset(Images.facebookImg, *//*width: 20,height: 30,*//*),),
                              if (_isAvailable)
                                GestureDetector(
                                    onTap: () {
                                      appleLogIn();
                                    },
                                    child: SvgPicture.asset(Images.appleImg, *//*width: 20,height: 30,*//*),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),*/
                ]),
              ),
            );
          });
        });
  }
  /* _dialogforSignIn() {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width / 2.2,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 3.0,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 32.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52,
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                Images.countryImg,
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text("Country/Region",
                                      style: TextStyle(
                                        color: Color(0xff808080),
                                      )),
                                  Text(countryName + " (" + countrycode + ")",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 52.0,
                          padding: EdgeInsets.only(
                              left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5, color: Color(0xff4B4B4B)),
                          ),
                          child: Row(
                            children: <Widget>[
                              Image.asset(Images.phoneImg),
                              SizedBox(
                                width: 14,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width / 4.0,
                                  child: Form(
                                    key: _form,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 16.0),
                                      textAlign: TextAlign.left,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(12)
                                      ],
                                      cursorColor:
                                          Theme.of(context).primaryColor,
                                      keyboardType: TextInputType.number,
                                      autofocus: true,
                                      decoration: new InputDecoration.collapsed(
                                          hintText: 'Enter Your Mobile Number',
                                          hintStyle: TextStyle(
                                            color: Colors.black12,
                                          )),
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return 'Please enter a Mobile number.';
                                        }
                                        return null; //it means user entered a valid input
                                      },
                                      onSaved: (value) {
                                        addMobilenumToSF(value);
                                      },
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 8.0, bottom: 36.0),
                          child: Text(
                            "We'll call or text you to confirm your number. Standard message data rates apply.",
                            style: TextStyle(
                                fontSize: 13, color: Color(0xff3B3B3B)),
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              prefs.setString('skip', "no");
                              prefs.setString('prevscreen', "mobilenumber");
                              // prefs.setString('Mobilenum', value);
                              _saveFormLogin();
                              _dialogforProcess();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.2,
                              height: 32,
                              padding: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                border: Border.all(
                                  width: 1.0,
                                  color: ColorCodes.greenColor,
                                ),
                              ),
                              child: Text(
                                "LOGIN USING OTP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.0,
                                    color: Color(0xff070707)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 60.0,
                          margin: EdgeInsets.only(top: 12.0, bottom: 32.0),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 13.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: 'By continuing you agree to the '),
                                new TextSpan(
                                    text: ' terms of service',
                                    style:
                                        new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Terms of Use",
                                              'body': prefs.getString(
                                                  "restaurant_terms"),
                                            });
                                      }),
                                new TextSpan(text: ' and'),
                                new TextSpan(
                                    text: ' Privacy Policy',
                                    style:
                                        new TextStyle(color: Color(0xff213b77)),
                                    recognizer: new TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.of(context).pushNamed(
                                            PolicyScreen.routeName,
                                            arguments: {
                                              'title': "Privacy",
                                              'body':
                                                  prefs.getString("privacy"),
                                            });
                                      }),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width / 1.2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                              Container(
                                //padding: EdgeInsets.all(4.0),
                                width: 23.0,
                                height: 23.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Color(0xff707070),
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(
                                  "OR",
                                  style: TextStyle(
                                      fontSize: 10.0, color: Color(0xff727272)),
                                )),
                              ),
                              Expanded(
                                child: Divider(
                                  thickness: 0.5,
                                  color: Color(
                                    0xff707070,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 44,
                          width: MediaQuery.of(context).size.width / 1.2,
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0),
                            border: Border.all(
                                width: 0.5,
                                color: Color(0xff4B4B4B).withOpacity(1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    _handleSignIn();
                                  },
                                  child: SvgPicture.asset(Images.googleImg, *//*width: 20,height: 30,*//*),),
                              GestureDetector(
                                  onTap: () {
                                    _dialogforProcessing();
                                    facebooklogin();
                                  },
                                  child: SvgPicture.asset(Images.facebookImg, *//*width: 20,height: 30,*//*),),
                              if (_isAvailable)
                                GestureDetector(
                                    onTap: () {
                                      appleLogIn();
                                    },
                                    child: SvgPicture.asset(Images.appleImg, *//*width: 20,height: 30,*//*),)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            );
          });
        });
  }*/

  _customToast(String message) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(message),
          );
        });
  }

  addMobilenumToSF(String value) async {
    prefs.setString('Mobilenum', value);
  }
  _verifyOtp() async {
    //var otpval = otp1 + otp2 + otp3 + otp4;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (otpvalue == prefs.getString('Otp')) {
      verifynum();
    } else {
      Navigator.of(context).pop();
      // Navigator.of(context).pop();
      return _customToast(translate('forconvience.invalidotp'));
      return Fluttertoast.showToast(msg: translate('forconvience.invalidotp')//"Please enter a valid otp!!!"
      );
    }
  }
  Future<void> verifynum() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'update-mobile-number';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id":prefs.getString('userID'),
        "mobile":prefs.getString('Mobilenum'),

      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "200") {
        prefs.setString('mobile',prefs.getString('Mobilenum'));

        Navigator.of(context).pop();


        // Fluttertoast.showToast(msg: responseJson['data']);
        if (addressitemsData.items.length > 0) {
          /* Navigator.of(context).pushReplacementNamed(
              ConfirmorderScreen.routeName,
              arguments: {"prev": "address_screen"});*/
          prefs.setString("isPickup", "no");
          Navigator.of(context).pushNamed(
              PaymentScreen.routeName,
              arguments: {
                'minimumOrderAmountNoraml':
                _minimumOrderAmountNoraml,
                'deliveryChargeNormal':
                _deliveryChargeNormal,
                'minimumOrderAmountPrime':
                _minimumOrderAmountPrime,
                'deliveryChargePrime':
                _deliveryChargePrime,
                'minimumOrderAmountExpress':
                _minimumOrderAmountExpress,
                'deliveryChargeExpress':
                _deliveryChargeExpress,
                'deliveryType':
                (_tabController.index == 0)
                    ? "standard"
                    : "express",
                'note': _message.text,
              });

        } else {
          Navigator.of(context).pop(context);
          Navigator.of(context).pop();
        }

      }
      else{
        Navigator.of(context).pop();
        return _customToast("Something Went Wrong..");
        return Fluttertoast.showToast(msg: 'Something Went Wrong..');
      }

    }
    catch (error) {
      throw error;
    }

  }
  /*_verifyOtp() async {
    //var otpval = otp1 + otp2 + otp3 + otp4;

    //SharedPreferences prefs = await SharedPreferences.getInstance();

    if (controller.text == prefs.getString('Otp')) {
      setState(() {
        _isLoading = true;
      });

      if (prefs.getString('type') == "old") {
        prefs.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        _getprimarylocation();
      } else {
        if (prefs.getString('prevscreen') == 'signingoogle' ||
            prefs.getString('prevscreen') == 'signupselectionscreen' ||
            prefs.getString('prevscreen') == 'signInAppleNoEmail' ||
            prefs.getString('prevscreen') == 'signInApple' ||
            prefs.getString('prevscreen') == 'signinfacebook') {
          return signupUser();
        } else {
          prefs.setString('prevscreen', "otpconfirmscreen");
          await Future.delayed(Duration(seconds: 2));
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          _dialogforAddInfo();
        }
      }
    } else {
      await Future.delayed(Duration(seconds: 2));
      Navigator.of(context).pop();
      _customToast();
    }
  }*/

  _saveAddInfoForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //checkemail();
    _dialogforProcessing();
    SignupUserRegister();
  }

  Future<void> signupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/register';

    try {
      String channel = "";
      try {
        if (Platform.isIOS) {
          channel = "IOS";
        } else {
          channel = "Android";
        }
      } catch (e) {
        channel = "Web";
      }

      //  SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": email,
        "mobileNumber": mobile,
        "path": apple,
        "tokenId": tokenid,
        "device":channel.toString(),
        "signature":
        prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;

      if (responseJson['status'].toString() == "true") {
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());

        prefs.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });

        return Navigator.of(context).pushNamedAndRemoveUntil(
            MapScreen.routeName, ModalRoute.withName('/'));
      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> SignupUserRegister() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/register';
    try {
      String channel = "";
      try {
        if (Platform.isIOS) {
          channel = "IOS";
        } else {
          channel = "Android";
        }
      } catch (e) {
        channel = "Web";
      }

      // SharedPreferences prefs = await SharedPreferences.getInstance();
      String apple = "";
      if (prefs.getString('applesignin') == "yes") {
        apple = prefs.getString('apple');
      } else {
        apple = "";
      }

      String name =
          prefs.getString('FirstName') + " " + prefs.getString('LastName');

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": prefs.getString('Email'),
        "mobileNumber": prefs.getString('Mobilenum'),
        "path": apple,
        "tokenId": prefs.getString('tokenid'),
        "branch": prefs.getString('branch'),
        "device":channel.toString(),
        "signature":
        prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));

        prefs.setString('LoginStatus', "true");
        setState(() {
          checkskip = false;
          if (prefs.getString('FirstName') != null) {
            if (prefs.getString('LastName') != null) {
              name = prefs.getString('FirstName') +
                  " " +
                  prefs.getString('LastName');
            } else {
              name = prefs.getString('FirstName');
            }
          } else {
            name = "";
          }

          //name = prefs.getString('FirstName') + " " + prefs.getString('LastName');
          if (prefs.getString('prevscreen') == 'signInAppleNoEmail') {
            email = "";
          } else {
            email = prefs.getString('Email');
          }
          mobile = prefs.getString('Mobilenum');
          tokenid = prefs.getString('tokenid');

          if (prefs.getString('mobile') != null) {
            phone = prefs.getString('mobile');
          } else {
            phone = "";
          }
          if (prefs.getString('photoUrl') != null) {
            photourl = prefs.getString('photoUrl');
          } else {
            photourl = "";
          }
        });
        Navigator.of(context).pop();

        return Navigator.pushNamedAndRemoveUntil(
            context, HomeScreen.routeName, (route) => false);

        /*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*/

      } else if (responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: responseJson['data'].toString(),
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      setState(() {});
      throw error;
    }
  }

  addFirstnameToSF(String value) async {
    //  SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FirstName', value);
  }

  addLastnameToSF(String value) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('LastName', value);
  }

  addEmailToSF(String value) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
  }

  _dialogforAddInfo() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.height
                    : MediaQuery.of(context).size.width / 3.3,
                width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 2.7,
                //padding: EdgeInsets.only(left: 30.0, right: 20.0),
                child: Column(children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50.0,
                    color: ColorCodes.lightGreyWebColor,
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Add your info",
                          style: TextStyle(
                              color: ColorCodes.mediumBlackColor,
                              fontSize: 20.0),
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 30.0, right: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 30.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Form(
                            key: _form,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(height: 10),
                                Text(
                                  '* '+ translate('forconvience.What should we call you ?'),
                                  style: TextStyle(
                                      fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  controller: firstnamecontroller,
                                  decoration: InputDecoration(
                                    hintText: 'Name',
                                    hoverColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onFieldSubmitted: (_) {
                                    FocusScope.of(context)
                                        .requestFocus(_lnameFocusNode);
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        fn = "  Please Enter Name";
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      fn = "";
                                    });
                                    return null;
                                  },
                                  onSaved: (value) {
                                    addFirstnameToSF(value);
                                  },
                                ),
                                Text(
                                  fn,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.red),
                                ),
                                SizedBox(height: 10.0),
                                Text(
                                  'Tell us your e-mail',
                                  style: TextStyle(
                                      fontSize: 17, color: Color(0xFF1D1D1D)),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextFormField(
                                  textAlign: TextAlign.left,
                                  keyboardType: TextInputType.emailAddress,
                                  style: new TextStyle(
                                      decorationColor:
                                      Theme.of(context).primaryColor),
                                  decoration: InputDecoration(
                                    hintText: 'xyz@gmail.com',
                                    fillColor: Colors.green,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.grey),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.green),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                      BorderSide(color: Colors.green),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide: BorderSide(
                                          color: Colors.green, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    bool emailValid;
                                    if (value == "")
                                      emailValid = true;
                                    else
                                      emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value);

                                    if (!emailValid) {
                                      setState(() {
                                        ea =
                                        ' Please enter a valid email address';
                                      });
                                      return '';
                                    }
                                    setState(() {
                                      ea = "";
                                    });
                                    return null; //it means user entered a valid input
                                  },
                                  onSaved: (value) {
                                    addEmailToSF(value);
                                  },
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      ea,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                                Text(
                                  ' We\'ll email you as a reservation confirmation.',
                                  style: TextStyle(
                                      fontSize: 15.2, color: Color(0xFF929292)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //  Spacer(),
                      ],
                    ),
                  ),
                  Spacer(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          _saveAddInfoForm();
                          _dialogforProcessing();
                        },
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                              )),
                          height: 60.0,
                          child: Center(
                            child: Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Theme.of(context).buttonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )),
                  ),
                ]),
              ),
            );
          });
        });
  }

  _dialogforOtp() async {
    return alertOtp(context);
  }

  void alertOtp(BuildContext ctx) {
    mobile = prefs.getString("Mobilenum");
    var alert = AlertDialog(
        contentPadding: EdgeInsets.all(0.0),
        content: StreamBuilder<int>(
            stream: _events.stream,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Container(
                  height: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                      ? MediaQuery.of(context).size.height
                      : MediaQuery.of(context).size.width / 3,
                  width: (_isWeb && ResponsiveLayout.isSmallScreen(context))
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width / 2.5,
                  child: Column(children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
                      padding: EdgeInsets.only(left: 20.0),
                      color: ColorCodes.lightGreyWebColor,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            translate('forconvience.OTP Verification'), //"Signup using OTP",
                            style: TextStyle(
                                color: ColorCodes.mediumBlackColor,
                                fontSize: 20.0),
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 25.0),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                translate('forconvience.check OTP'),//'Please check OTP sent to your mobile number',
                                style: TextStyle(
                                    color: Color(0xFF404040),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0),

                                // textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(width: 20.0),
                                Text(
                                  countrycode + '  $mobile',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 16.0),
                                ),
                                SizedBox(width: 30.0),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    aler_dialofortmobile(context);
                                    //_dialogforSignIn();
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Color(0x707070B8), width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text(translate('header.change'),//'Change',
                                            style: TextStyle(
                                                color: Color(0xFF070707),
                                                fontSize: 13))),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text(
                                translate('forconvience.enterotp'),//'Enter OTP',
                                style: TextStyle(
                                    color: Color(0xFF727272), fontSize: 14),
                                //textAlign: TextAlign.left,
                              ),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Auto Sms
                                  Container(
                                      height: 40,
                                      //width: MediaQuery.of(context).size.width*80/100,
                                      width: (_isWeb &&
                                          ResponsiveLayout.isSmallScreen(
                                              context))
                                          ? MediaQuery.of(context).size.width /
                                          2
                                          : MediaQuery.of(context).size.width /
                                          3,
                                      //padding: EdgeInsets.zero,
                                      child: PinFieldAutoFill(
                                          controller: controller,
                                          decoration: UnderlineDecoration(
                                              colorBuilder: FixedColorBuilder(
                                                  Color(0xFF707070))),
                                          onCodeChanged: (text) {
                                            otpvalue = text;
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (_) => setState(() {}));
                                          },
                                          onCodeSubmitted: (text) {
                                            SchedulerBinding.instance
                                                .addPostFrameCallback(
                                                    (_) => setState(() {
                                                  otpvalue = text;
                                                }));
                                          },
                                          codeLength: 4,
                                          currentCode: otpvalue)),
                                ]),
                            SizedBox(
                              height: 20,
                            ),
                            _showOtp
                                ? Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    height: 40,
                                    width: (_isWeb &&
                                        ResponsiveLayout
                                            .isSmallScreen(context))
                                        ? MediaQuery.of(context)
                                        .size
                                        .width *
                                        50 /
                                        100
                                        : MediaQuery.of(context)
                                        .size
                                        .width *
                                        32 /
                                        100,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Color(0xFF6D6D6D),
                                          width: 1.5),
                                    ),
                                    child: Center(
                                        child: Text( translate('forconvience.resendOtp'),//'Resend OTP'
                                        )
                                    )
                                    ,
                                  ),
                                  /*  Container(
                                          height: 28,
                                          width: 28,
                                          margin: EdgeInsets.only(
                                              left: 20.0, right: 20.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Color(0xFF6D6D6D),
                                                width: 1.5),
                                          ),
                                          child: Center(
                                              child: Text(
                                            'OR',
                                            style: TextStyle(fontSize: 10),
                                          )),
                                        ),*/
                                  /*  _timeRemaining == 0
                                            ? MouseRegion(
                                                cursor:
                                                    SystemMouseCursors.click,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .translucent,
                                                  onTap: () {
                                                    otpCall();
                                                    _timeRemaining = 60;
                                                  },
                                                  child: Expanded(
                                                    child: Container(
                                                      height: 40,
                                                      //width: MediaQuery.of(context).size.width*32/100,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                            color: Colors.green,
                                                            width: 1.5),
                                                      ),

                                                      child: Center(
                                                          child: Text(
                                                              'Call me Instead')),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                child: Container(
                                                  height: 40,
                                                  //width: MediaQuery.of(context).size.width*32/100,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF6D6D6D),
                                                        width: 1.5),
                                                  ),
                                                  child: Center(
                                                    child: RichText(
                                                      text: TextSpan(
                                                        children: <TextSpan>[
                                                          new TextSpan(
                                                              text: 'Call in',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                          new TextSpan(
                                                            text:
                                                                ' 00:$_timeRemaining',
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xffdbdbdb),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )*/
                                ])
                                : Row(
                              mainAxisAlignment:
                              MainAxisAlignment.start,
                              children: <Widget>[
                                _timeRemaining == 0
                                    ? MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior:
                                    HitTestBehavior.translucent,
                                    onTap: () {
                                      //  _showCall = true;
                                      _showOtp = true;
                                      _timeRemaining += 30;
                                      Otpin30sec();
                                    },
                                    child: Container(
                                      height: 40,
                                      width: (_isWeb &&
                                          ResponsiveLayout
                                              .isSmallScreen(
                                              context))
                                          ? MediaQuery.of(context)
                                          .size
                                          .width *
                                          30 /
                                          100
                                          : MediaQuery.of(context)
                                          .size
                                          .width *
                                          15 /
                                          100,
                                      //width: MediaQuery.of(context).size.width*32/100,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                        BorderRadius.circular(
                                            6),
                                        border: Border.all(
                                            color: Colors.green,
                                            width: 1.5),
                                      ),
                                      child: Center(
                                          child:
                                          Text( translate('forconvience.resendOtp'),//'Resend OTP'
                                          )),
                                    ),
                                  ),
                                )
                                    : Container(
                                  height: 40,
                                  //width: MediaQuery.of(context).size.width*40/100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Color(0x707070B8),
                                        width: 1.5),
                                  ),
                                  child: Center(
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          new TextSpan(
                                              text:
                                              translate('forconvience.Resend Otp in'),//'Resend Otp in',
                                              style: TextStyle(
                                                  color: Colors
                                                      .black)),
                                          new TextSpan(
                                            text:
                                            ' 00:$_timeRemaining',
                                            style: TextStyle(
                                              color: Color(
                                                  0xffdbdbdb),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                /*Container(
                                        height: 28,
                                        width: 28,
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: Color(0xFF6D6D6D),
                                              width: 1.5),
                                        ),
                                        child: Center(
                                            child: Text(
                                          'OR',
                                          style: TextStyle(fontSize: 10),
                                        )),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 40,
                                          //width: MediaQuery.of(context).size.width*32/100,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Color(0xFF6D6D6D),
                                                width: 1.5),
                                          ),
                                          child: Center(
                                              child: Text('Call me Instead')),
                                        ),
                                      ),*/
                              ],
                            ),
                          ]),
                    ),
                    Spacer(),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _dialogforProcessing();
                            _verifyOtp();

                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                )),
                            height: 60.0,
                            child: Center(
                              child: Text(
                                translate('forconvience.VERIFY MY NUMBER'),// "LOGIN",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context).buttonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )),
                    ),
                  ]));
            }));
    _startTimer();
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return alert;
        });
  }

  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    wid = queryData.size.width;
    maxwid = wid * 0.90;
    Future<void> openMap(double latitude, double longitude) async {
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }

    if (!_isLoading) if (prefs.getString("membership") == "1") {
      _checkmembership = true;
    } else {
      _checkmembership = false;
    }

    _buildBottomNavigationBar() {


      return ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty) return SizedBox.shrink();


          return Container(
            width: MediaQuery.of(context).size.width,
            height: 50.0,
            child:
            Row(
              children: <Widget>[
                (_checkmembership
                    ? (double.parse(
                    (Calculations.totalMember).toStringAsFixed(2)) <
                    minimumOrderAmount)
                    : (double.parse(
                    (Calculations.total).toStringAsFixed(2)) <
                    minimumOrderAmount))
                    ? GestureDetector(
                  onTap: () => {
                    Fluttertoast.showToast(
                        msg:translate('forconvience.Minimum order amount is')// "Minimum order amount is " +
                            +" "+ minimumOrderAmount.toStringAsFixed(0)+currency_format.toString(),
                        backgroundColor: Colors.black87,
                        textColor: Colors.white),
                  },
                  child:
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(
                            height: 17,
                          ),
                          Center(
                            child: Text(
                              translate('forconvience.proceed to checkout'),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: ColorCodes.whiteColor,
                          ),
                        ]),
                  ),
                )
                    : GestureDetector(
                  onTap: () => {
                    setState(() {
                      if (prefs.getString("skip") == "yes") {
                        prefs.setString("fromcart", "cart_screen");
                        // Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                            SignupSelectionScreen.routeName);
                      } else {
                        if(prefs.getString('mobile').toString() != "null" && prefs.getString('mobile').toString() != "") {
                          prefs.setString("isPickup", "no");
                          Navigator.of(context).pushNamed(
                              ConfirmorderScreen.routeName,
                              arguments: {"prev": "cart_screen"});
                        }
                        else{
                          Navigator.of(context)
                              .pushNamed(MobileAuthScreen.routeName,);
                        }
                      }

                    })
                  },
                  child:
                  Container(
                    color: Theme.of(context).primaryColor,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(
                            height: 17,
                          ),
                          Center(
                            child: Text(
                              translate('forconvience.proceed to checkout'),
                              style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(
                            Icons.arrow_right,
                            color: ColorCodes.whiteColor,
                          ),
                        ]),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    Widget cartScreen() {
      return
        _isLoading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        Column(
          children: [
            /* Container(
                    //margin: EdgeInsets.only(left: 5, right: 5.0),
                    width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                        ? MediaQuery.of(context).size.width * 0.40
                        : MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(
                        left: 10, right: 10, top: 15, bottom: 15),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          "Bill Details",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Spacer(),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if (shoplistData.itemsshoplist.length <= 0) {
                                _dialogforCreatelist(context);
                              } else {
                                _dialogforShoppinglist(context);
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                    height: 15,
                                    child: Image.asset(Images.addToListImg)),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'ADD TO LIST',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 13,
                        ),
                      ],
                    )),*/
            SizedBox(height: 20,),

            ValueListenableBuilder(

                valueListenable: productBox.listenable(),
                builder: (context, Box<Product> box, index) {
                  List taskList =  Hive.box<Product>(productBoxName).values.toList().cast<Product>();
                  taskList.sort((a,b)=>a.itemName.compareTo(b.itemName));
                  return Container(

                    // padding: EdgeInsets.all(5),
                    width:
                    (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                        ? MediaQuery.of(context).size.width * 0.40
                        : MediaQuery.of(context).size.width*0.95,
                    child: new ListView.builder(

                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: productBox.length,
                      itemBuilder: (_, i) => ValueListenableBuilder(
                        valueListenable: productBox.listenable(),
                        builder: (context, Box<Product> box, index) {
                          if (productBox.values.elementAt(i).mode == 1)
                            return CartitemsDisplay(
                              taskList.elementAt(i).itemId.toString(),
                              taskList.elementAt(i).varId.toString(),
                              taskList.elementAt(i).itemName,
                              taskList.elementAt(i).itemImage,
                              taskList.elementAt(i).varName,
                              taskList.elementAt(i).itemPrice.toString(),
                              taskList.elementAt(i).itemQty,
                              taskList.elementAt(i).varMinItem.toString(),
                              taskList.elementAt(i).varMaxItem.toString(),
                              taskList.elementAt(i).varStock.toString(),
                              taskList.elementAt(i).varMrp.toString(),
                              taskList.elementAt(i).membershipPrice,
                              taskList.elementAt(i).mode,
                            );

                          return CartitemsDisplay(
                            taskList.elementAt(i).itemId.toString(),
                            taskList.elementAt(i).varId.toString(),
                            taskList.elementAt(i).itemName,
                            taskList.elementAt(i).itemImage,
                            taskList.elementAt(i).varName,
                            taskList.elementAt(i).itemPrice.toString(),
                            taskList.elementAt(i).itemQty,
                            taskList.elementAt(i).varMinItem.toString(),
                            taskList.elementAt(i).varMaxItem.toString(),
                            taskList.elementAt(i).varStock.toString(),
                            taskList.elementAt(i).varMrp.toString(),
                            taskList.elementAt(i).membershipPrice,
                            taskList.elementAt(i).mode,
                          );
                        },
                      ),
                    ),
                  );
                }),
            SizedBox(height: 10),
            Container(
              height: 40,
              width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                  ? MediaQuery.of(context).size.width * 0.40
                  : MediaQuery.of(context).size.width,
              color: ColorCodes.tabcolor,
              margin: EdgeInsets.only(left: 5, right: 5),

              padding: EdgeInsets.all(8),

              //Initial Column Setup
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 7,
                      ),
                      Text(
                        translate('forconvience.Sub Total'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Spacer(),
                      ValueListenableBuilder(
                        valueListenable: productBox.listenable(),
                        builder: (context, Box<Product> box, index) {
                          return Text(
                            _checkmembership
                                ?
                            (Calculations.totalMember)
                                .toStringAsFixed(2)+_currencyFormat
                                :
                            (Calculations.total).toStringAsFixed(2)+_currencyFormat ,
                            style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      SizedBox(
                        width: 13,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            (_isWeb && ResponsiveLayout.isSmallScreen(context))
                ? Container(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                children: <Widget>[
                  (_checkmembership
                      ? (double.parse((Calculations.totalMember)
                      .toStringAsFixed(2)) <
                      minimumOrderAmount)
                      : (double.parse((Calculations.total)
                      .toStringAsFixed(2)) <
                      minimumOrderAmount))
                      ? GestureDetector(
                    onTap: () => {
                      Fluttertoast.showToast(
                          msg: translate('forconvience.Minimum order amount is')//"Minimum order amount is " +
                              +" "+minimumOrderAmount.toStringAsFixed(0)+currency_format.toString(),
                          backgroundColor: Colors.black87,
                          textColor: Colors.white),
                    },
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Column(children: <Widget>[
                        SizedBox(
                          height: 17,
                        ),
                        Center(
                          child: Text(
                            translate('forconvience.proceed to checkout'),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ]),
                    ),
                  )
                      : GestureDetector(
                    onTap: () => {
                      setState(() {
                        if (prefs.getString("skip") == "yes") {
                          prefs.setString(
                              "fromcart", "cart_screen");
                          Navigator.of(context)
                              .pushReplacementNamed(
                              SignupSelectionScreen
                                  .routeName);
                        } else {
                          //prefs.setString('totalamount', totalAmount);
                          /*  if (addressitemsData.items.length >
                                                0) {*/
                          Navigator.of(context).pushNamed(
                              ConfirmorderScreen.routeName,
                              arguments: {
                                "prev": "cart_screen"
                              });
                          /* } else {
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
                                            }*/
                        }
                      })
                    },
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Column(children: <Widget>[
                        SizedBox(
                          height: 17,
                        ),
                        Center(
                          child: Text(
                            translate('forconvience.proceed to checkout'),
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ]),
                    ),
                  ),
                ],
              ),
            )
                : SizedBox.shrink(),
            /* (checkskip && !ResponsiveLayout.isSmallScreen(context))
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.40,
                        height: 50,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => {_dialogforSignIn()},
                            child: Container(
                              color: ColorCodes.greyColor,
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              child: Column(children: <Widget>[
                                SizedBox(
                                  height: 17,
                                ),
                                Center(
                                  child: Text(
                                    translate('forconvience.proceed to checkout'),
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ]),
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),*/
          ],
        );
    }

    Widget _proceedtocheckwithoutlogin(){
      return (checkskip && !ResponsiveLayout.isSmallScreen(context))
          ? Column(
        children: [
          SizedBox(height:50),
          Container(
            width: MediaQuery.of(context).size.width * 0.40,
            height: 50,
            child: Container(
              // color: Theme.of(context).primaryColor,
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Column(children: <Widget>[

                Center(
                  child: Text(
                    " You are not Logged in, Please Login to Continue with Proceed To Checkout",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ]),
            ),
          ),
          SizedBox(
            height: 17,
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.40,
            height: 50,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => {_dialogforSignIn()},
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  child: Column(children: <Widget>[
                    SizedBox(
                      height: 17,
                    ),
                    Center(
                      child: Text(
                        translate('forconvience.proceed to checkout'),//'PROCEED TO CHECKOUT',
                        style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ],
      )


          : SizedBox.shrink();
    }
    Widget confirmOrder() {
      int deliveryamount = 0;
      String minOrdAmount = "0.0";
      String delCharge = "0.0";
      if (!_loading) {
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
          _isLoading = false;
        }
      }
      /* Widget slotBasedDelivery() {
        int index = 0;
        Widget timeSlot(String id, int i) {
          timeslotsData = Provider.of<DeliveryslotitemsList>(
            context,
            listen: false,
          ).findById(id);

          return new ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: ColorCodes.lightGreyColor,
            ),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: timeslotsData.length,
            itemBuilder: (_, j) => MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () async {
                  setState(() {
                    time = timeslotsData[j].time;
                    final timeData = Provider.of<DeliveryslotitemsList>(context,
                        listen: false);
                    prefs.setString(
                        "fixdate", deliveryslotData.items[i].dateformat);
                    prefs.setString('fixtime', timeslotsData[j].time);

                    _index = (i == 0 && j == 0) ? 0 : _index + 1;
                    for (int i = 0; i < timeData.times.length; i++) {
                      setState(() {
                        if (*//*timeData.times[_index].index*//* (int.parse(id) + j)
                                .toString() ==
                            timeData.times[i].index) {
                          timeData.times[i].selectedColor = Color(0xFF2966A2);
                          timeData.times[i].isSelect = true;
                        } else {
                          timeData.times[i].selectedColor = Color(0xffBEBEBE);
                          timeData.times[i].isSelect = false;
                        }
                      });
                    }
                  });
                },
                child: Container(
                  height: 40,
                  color: Colors.white,
                  margin: EdgeInsets.only(left: 5.0, right: 5.0),
                  //child: Container(
                  width: MediaQuery.of(context).size.width * 0.40,
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Text(
                          timeslotsData[j].time,
                          style: TextStyle(
                              color: timeslotsData[j].selectedColor,
                              fontWeight: timeslotsData[j].isSelect
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                        ),
                      ),
                      timeslotsData[j].isSelect
                          ? Icon(Icons.check,
                              color: timeslotsData[j].selectedColor)
                          : Icon(Icons.check, color: Colors.transparent),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            height: 600,
            width: MediaQuery.of(context).size.width * 0.40,
            child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: deliveryslotData.items.length,
                shrinkWrap: true,
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),

                                //Spacer(flex: 1,)
                              ],
                            ),
                          ),
                        ),
                        timeSlot(
                          deliveryslotData.items[i].id,
                          i,
                        ),
                      ],
                    )),
          ),
        );
      }*/
      //******************** new code tab bar express delivery *************

      /* Widget expressDelivery() {
        return Container(
          width: MediaQuery.of(context).size.width * 0.40,
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
      }*/

      void _settingModalBottomSheet(context, String from) {
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
                                  "Choose a delivery address",
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
                                  } else {
                                    Navigator.of(context).pop();
                                    if (addsId !=
                                        addressitemsData.items[i].userid) {
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
                                        addtype = addressitemsData
                                            .items[i].useraddtype;
                                        address = addressitemsData
                                            .items[i].useraddress;
                                        addressicon = addressitemsData
                                            .items[i].addressicon;
                                        prefs.setString("addressId",
                                            addressitemsData.items[i].userid);
                                        //_slotsLoading = true;
                                        _isChangeAddress = false;
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
                                            addressitemsData
                                                .items[i].useraddtype,
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
                                            addressitemsData
                                                .items[i].useraddress,
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

      Widget _deliveryTimeSlotText() {
        return Container(
          //height: MediaQuery.of(context).size.height * 0.11,
          // width: MediaQuery.of(context).size.width * 0.40,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          color: Color(0xFFF1F1F1),
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
                // 'Please select a time slot as per your convience. Your order will be delivered during the time slot.',
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
      double deviceWidth = MediaQuery.of(context).size.width;
      int widgetsInRow = 3;
      double aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 55;

      if (deviceWidth > 1200) {
        widgetsInRow = 3;
        aspectRatio =
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 210;
      } else if (deviceWidth > 650) {
        widgetsInRow = 3;
        aspectRatio =
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 145;
      }

      return
        _loading
            ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        SingleChildScrollView(
          child:
          Container(
           // height: MediaQuery.of(context).size.height,
            color: ColorCodes.whiteColor,
            // padding: EdgeInsets.only(left: 10.0, top: 10.0, ),
            child:
            Column(
              children: <Widget>[
                !_isChangeAddress?
                _checkaddress
                    ? Container(
                  // width: MediaQuery.of(context).size.width*0.40,
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
                                  width: MediaQuery.of(context).size.width/4,
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
                                //Spacer(),
                                /* SizedBox(
                                    width: 10.0,
                                  ),*/
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 40.0,
                      ),
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


                    GestureDetector(
                      onTap: (){
                        //Navigator.of(context).pop(),
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
                        width: MediaQuery.of(context).size.width * 0.40 ,
                        margin: EdgeInsets.only(
                            left: 5.0, right: 10.0, bottom: 10.0,top:20),
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
                            translate('forconvience.Add Address'),// 'Add Address',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
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
                            child:
                            Container(
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
                                  translate('forconvience.Add Address'),// 'Add Address',
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
                          height: 200,
                          child: GridView.builder(
                              scrollDirection: Axis.vertical,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 6,
                              ),
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: deliveryslotData.items.length,
                              itemBuilder:(ctx, i){
                                return GestureDetector(
                                  onTap: (){
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
                                          deliveryslotData.items[j].selectedColor=Color(0xFF45B343);
                                          deliveryslotData.items[j].borderColor=Color(0xFF45B343);
                                          deliveryslotData.items[j].textColor=ColorCodes.whiteColor;
                                          deliveryslotData.items[j].isSelect = true;
                                        }
                                        else{
                                          deliveryslotData.items[j].selectedColor=ColorCodes.whiteColor;
                                          deliveryslotData.items[j].borderColor=Color(0xffBEBEBE);
                                          deliveryslotData.items[j].textColor=ColorCodes.blackColor;
                                          deliveryslotData.items[j].isSelect = false;
                                        }
                                      }
                                      for(int j=0;j<timeslotsData.length; j++){
                                        setState((){
                                          if(j == 0){

                                            timeslotsData[0].selectedColor=Color(0xFF45B343);
                                            // deliveryslotData.items[i].selectedColor=Color(0xFF45B343);
                                            timeslotsData[0].borderColor=Color(0xFF45B343);
                                            timeslotsData[0].textColor=ColorCodes.whiteColor;
                                            timeslotsData[0].isSelect = true;

                                          }else{

                                            timeslotsData[j].selectedColor=ColorCodes.whiteColor;
                                            timeslotsData[j].borderColor=Color(0xffBEBEBE);
                                            timeslotsData[j].textColor=ColorCodes.blackColor;
                                            timeslotsData[j].isSelect = false;

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
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right:18.0,left:18),
                          child:SizedBox(
                              height: 100,
                              child: GridView.builder(
                                  scrollDirection: Axis.vertical,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: widgetsInRow,
                                    childAspectRatio: aspectRatio,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 0.5,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: timeslotsData.length,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemBuilder:(ctx, i){
                                    return GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          prefs.setString('fixtime', timeslotsData[i].time);
                                          for(int j = 0; j< timeslotsData.length; j++) {
                                            setState(() {

                                              final timeData = Provider.of<DeliveryslotitemsList>(context, listen: false);
                                              if(i == j) {
                                                timeslotsData[j].selectedColor=Color(0xFF45B343);
                                                timeslotsData[j].borderColor=Color(0xFF45B343);
                                                timeslotsData[j].textColor=ColorCodes.whiteColor;
                                                timeslotsData[j].isSelect = true;
                                              } else {
                                                timeslotsData[j].selectedColor=ColorCodes.whiteColor;
                                                timeslotsData[j].borderColor=Color(0xffBEBEBE);
                                                timeslotsData[j].textColor=ColorCodes.blackColor;
                                                timeslotsData[j].isSelect = false;
                                              }
                                            });

                                            /*day = deliveryslotData.items[i].day;
                                        date = deliveryslotData.items[i].date;*/
                                          }

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
                              )),
                        ),
                      ),



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
                      :
                  Row(
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


                  ),

                !_checkslots
                    ? MouseRegion(
                  child: InkWell(
                    onTap: () => {
                      Fluttertoast.showToast(
                          msg:
                          "currently there are no slots available"),
                    },
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width * 0.40,
                      color: Colors.grey,
                      height: 50.0,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        child: Center(
                          child: Text(
                            translate('forconvience.CONFIRM ORDER'),// 'CONFIRM ORDER',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    : MouseRegion(
                  child: InkWell(
                    onTap: () {
                      if (_isChangeAddress) {
                        Fluttertoast.showToast(
                            msg: "Please select delivery address!",
                            backgroundColor: Colors.black87,
                            textColor: Colors.white);
                      } else {
                        if (!_checkaddress) {
                          Fluttertoast.showToast(
                              msg: "Please provide a address");
                        } else {

                          if(prefs.getString('mobile').toString() != "null" && prefs.getString('mobile').toString() != "") {
                            prefs.setString("isPickup", "no");
                            prefs.setString("isPickup", "no");
                            Navigator.of(context).pushNamed(
                                PaymentScreen.routeName,
                                arguments: {
                                  'minimumOrderAmountNoraml':
                                  _minimumOrderAmountNoraml,
                                  'deliveryChargeNormal':
                                  _deliveryChargeNormal,
                                  'minimumOrderAmountPrime':
                                  _minimumOrderAmountPrime,
                                  'deliveryChargePrime':
                                  _deliveryChargePrime,
                                  'minimumOrderAmountExpress':
                                  _minimumOrderAmountExpress,
                                  'deliveryChargeExpress':
                                  _deliveryChargeExpress,
                                  'deliveryType':
                                  (_tabController.index == 0)
                                      ? "standard"
                                      : "express",
                                  'note': _message.text,
                                });

                          }
                          else{
                            aler_dialofortmobile(context);
                          }


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
                      child: Container(
                        child: Center(
                          child: Text(
                            translate('forconvience.CONFIRM ORDER'),//'CONFIRM ORDER',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              ],



            ),




          ),);
    }

    Widget pickUp() {
      return _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            !_checkStoreLoc
                ? Center(
              child: Container(
                //width: MediaQuery.of(context).size.width * 0.40,
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
              width: MediaQuery.of(context).size.width * 0.40,
              margin: EdgeInsets.only(
                  left: 10.0, top: 30.0, bottom: 10.0),
              child: Text(
                "Select Store for Pickup",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.40,
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
                          indent: 250,
                          endIndent: 250,
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
                                changeStore(
                                    pickuplocItem.itemspickuploc[i].id);
                              });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(right: 0.0),
                              title: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 15.0,
                                  ),
                                  SizedBox(
                                    width: 10.0,
                                    height: 20.0,
                                    child: _myRadioButton(
                                      value: i,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _groupValue = newValue;
                                        });
                                        changeStore(pickuplocItem
                                            .itemspickuploc[i].id);
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
                                      margin:
                                      EdgeInsets.only(bottom: 10.0),
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
                                              .itemspickuploc[i]
                                              .contact
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
              width: MediaQuery.of(context).size.width * 0.40,
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
                  translate('forconvience.Currently there is no slot available'),//"Currently there is no slots available for this address",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            )
                : Container(),
            SizedBox(
              height: 20,
            ),
            //bottom tab for pick up
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Container(
                width: MediaQuery.of(context).size.width * 0.40,
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    !_checkStoreLoc
                        ? GestureDetector(
                      onTap: () => {
                        Fluttertoast.showToast(
                            msg:
                            "currently there is no store address available"),
                      },
                      child: Container(
                        // padding: EdgeInsets.symmetric(horizontal: 30),
                        color: Colors.grey,
                        height: 50,
                        width: MediaQuery.of(context).size.width *
                            0.40,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate('forconvience.CONFIRM ORDER'),//'CONFIRM ORDER',
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
                    )
                        : _isPickupSlots
                        ? GestureDetector(
                      onTap: () {
                        prefs.setString("isPickup", "yes");
                        prefs.setString('fixtime', selectTime);
                        prefs.setString("fixdate", selectDate);
                        prefs.setString(
                            "addressId",
                            pickuplocItem
                                .itemspickuploc[_groupValue].id
                                .toString());
                        Navigator.of(context).pushNamed(
                            PaymentScreen.routeName,
                            arguments: {
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
                      child: Container(
                        //padding: EdgeInsets.symmetric(horizontal: 30),
                        color: Theme.of(context).primaryColor,
                        height: 50,
                        width:
                        MediaQuery.of(context).size.width *
                            0.40,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate('forconvience.CONFIRM ORDER'),//'CONFIRM ORDER',
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
                    )
                        : GestureDetector(
                      onTap: () => {
                        Fluttertoast.showToast(
                          msg:
                          translate('forconvience.Currently there is no slot available'),//"currently there is no slots available for this address"
                        ),
                      },
                      child: Container(
                        //padding: EdgeInsets.symmetric(horizontal: 30),
                        color: Colors.grey,
                        height: 50,
                        width:
                        MediaQuery.of(context).size.width *
                            0.40,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Text(
                              translate('forconvience.CONFIRM ORDER'),//'CONFIRM ORDER',
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
                    )
                  ],
                ),
              ),
          ],
        ),
      );
    }

    Widget bodyWeb() {
      return ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, index) {
          if (productBox.length <= 0)
            return Expanded(
              child:
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
              SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        Images.cartEmptyImg,
                        height: 200.0,
                      ),
                      Text(
                        translate('forconvience.Your shopping cart is empty'),//"Your cart is empty!",
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      MouseRegion(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context)
                                .popUntil(ModalRoute.withName(
                              HomeScreen.routeName,
                            ));
                          },
                          child: Container(
                              width:
                              MediaQuery.of(context).size.width * 0.2,
                              padding: EdgeInsets.all(5),
                              height: 40.0,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                  BorderRadius.circular(3.0),
                                  border: Border(
                                    top: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context)
                                            .primaryColor),
                                    bottom: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context)
                                            .primaryColor),
                                    left: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context)
                                            .primaryColor),
                                    right: BorderSide(
                                      width: 1.0,
                                      color:
                                      Theme.of(context).primaryColor,
                                    ),
                                  )),
                              child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      new Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15.0, 0.0, 10.0, 0.0),
                                        child: new Icon(
                                          Icons.shopping_cart_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        translate('forconvience.START SHOPPING'), //'START SHOPPING',
                                        //textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ))),
                        ),
                      ),
                      if (_isWeb) Footer(address: _address),
                    ],
                  ),
                ),
              ),
            );

          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
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
                  checkskip
                      ?
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: (_isWeb &&
                          !ResponsiveLayout.isSmallScreen(
                              context))
                          ? BoxConstraints(maxWidth: maxwid)
                          : null,
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(child: cartScreen()),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: _proceedtocheckwithoutlogin(),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  )
                  /*Center(child: Row(
                            children: [
                              cartScreen(),
                              SizedBox(
                                width: 10,
                              ),
                              Center(
                                child: Text(
                                  translate('forconvience.proceed to checkout'),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ))*/
                      :
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      constraints: (_isWeb &&
                          !ResponsiveLayout.isSmallScreen(
                              context))
                          ? BoxConstraints(maxWidth: maxwid)
                          : null,
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(child: cartScreen()),
                          SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: _groupValue == 2
                                  ? pickUp()
                                  : _loading
                                  ? Container(
                                height: 200,
                                child: Center(
                                  child:
                                  CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                                ),
                              )
                                  : confirmOrder()),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isWeb) Footer(address: _address),
                  //Builder
                ],
              ),
            ),
          );
        },
      );
    }

    Widget bodyMobile() {
      return ValueListenableBuilder(
        valueListenable: productBox.listenable(),
        builder: (context, Box<Product> box, index) {
          if (productBox.length <= 0)
            return SingleChildScrollView(
              child:
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          Images.cartEmptyImg,
                          height: 200.0,
                        ),
                      ),

                      Center(
                        child: Text(
                          translate('forconvience.Your shopping cart is empty'),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          translate('forconvience.Add items you want to shop.'),
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                      SizedBox(

                        height: 20.0,
                      ),
                      // Spacer(),
                      /* GestureDetector(
                             onTap: () {
                               Navigator.of(context).popUntil(ModalRoute.withName(
                                 HomeScreen.routeName,
                               ));
                             },
                             child: Container(
                                 width: MediaQuery.of(context).size.width * 0.7,
                                 padding: EdgeInsets.all(5),
                                 height: 40.0,
                                 decoration: BoxDecoration(
                                     color: Theme.of(context).primaryColor,
                                     borderRadius: BorderRadius.circular(3.0),
                                     border: Border(
                                       top: BorderSide(
                                           width: 1.0,
                                           color: Theme.of(context).primaryColor),
                                       bottom: BorderSide(
                                           width: 1.0,
                                           color: Theme.of(context).primaryColor),
                                       left: BorderSide(
                                           width: 1.0,
                                           color: Theme.of(context).primaryColor),
                                       right: BorderSide(
                                         width: 1.0,
                                         color: Theme.of(context).primaryColor,
                                       ),
                                     )),
                                 child: Center(
                                     child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     new Padding(
                                       padding: const EdgeInsets.fromLTRB(
                                           15.0, 0.0, 10.0, 0.0),
                                       child: new Icon(
                                         Icons.shopping_cart_outlined,
                                         color: Colors.white,
                                       ),
                                     ),
                                     Text(
                                       'START SHOPPING',
                                       //textAlign: TextAlign.center,
                                       style: TextStyle(
                                           color: Colors.white,
                                           fontSize: 15,
                                           fontWeight: FontWeight.bold),
                                     ),
                                   ],
                                 ))),
                           ),*/
                      SizedBox(
                        height: 10,
                      ),
                      if (_isWeb) Footer(address: _address),
                    ],
                  ),
                ),
              ),
            );
          // );

          return Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  cartScreen(),
                  if (_isWeb) Footer(address: _address),
                  //Builder
                ],
              ),
            ),
          );
        },
      );
    }

    shoplistData = Provider.of<BrandItemsList>(context, listen: false);

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


    bottomNavigationbar() {
      return SingleChildScrollView(
        child: Container(
          height: 100,
          color: Colors.white,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil(ModalRoute.withName(
                    HomeScreen.routeName,
                  ));
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(5),
                    height: 40.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border(
                          top: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).primaryColor),
                          bottom: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).primaryColor),
                          left: BorderSide(
                              width: 1.0,
                              color: Theme.of(context).primaryColor),
                          right: BorderSide(
                            width: 1.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        )),
                    child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            new Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  15.0, 0.0, 10.0, 0.0),
                              child: new Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              translate('forconvience.START SHOPPING'),//'START SHOPPING',
                              //textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ))),
              ),
              Row(
                children: <Widget>[

                  Spacer(),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: 7.0,
                      ),
                      CircleAvatar(
                        maxRadius: 11.0,
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.transparent,
                        child: Image.asset(Images.categoriesImg,
                            color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(translate('bottomnavigation.categories'),//"Category",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : Navigator.of(context).popAndPushNamed(
                          WalletScreen.routeName,
                          arguments: {"type": "wallet"});
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.walletImg),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            translate('bottomnavigation.wallet'),
                            //"Wallet",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      /* Navigator.of(context).popAndPushNamed(
                        HomeScreen.routeName,
                      );*/
                      Navigator.of(context).pop(true);
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.homeImg),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            translate('bottomnavigation.home'),
                            //"Home",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  /* Spacer(),
                 GestureDetector(
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : Navigator.of(context).pushNamed(
                        MembershipScreen.routeName,
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            Images.bottomnavMembershipImg,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text("Membership",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(flex: 1),*/
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : Navigator.of(context).popAndPushNamed(
                        MyorderScreen.routeName,
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.shoppinglistsImg),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            translate('bottomnavigation.myorders'),
                            //"My Orders",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : launchWhatsApp();//FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", "Hello");
                      /*Navigator.of(context)
                                .pushNamed(
                                CustomerSupportScreen.routeName, arguments: {
                              'name': name,
                              'email': email,
                              'photourl': photourl,
                              'phone': phone,
                            });*/
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(Images.whatsapp),
                        ),
                        // Icon(Icons.chat, color: Colors.black12,),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                            translate('bottomnavigation.chat'),
                            //"Chat",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                ],
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
            onPressed: () {
              try {

                (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?

                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home-screen', (Route<dynamic> route) => false):


                Navigator.of(context).pop();
              }catch(e){
              }
            }
        ),

        title: Text(
          translate('forconvience.mybasket')//'My Basket'
          ,style: TextStyle(color: ColorCodes.backbutton),
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

    return  WillPopScope(
        onWillPop: () { // this is the block you need


          (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ?

          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home-screen', (Route<dynamic> route) => false)

              :

          Navigator.of(context).pop();

          return Future.value(false);
        },
        child:
        Scaffold(
          appBar: ResponsiveLayout.isSmallScreen(context)
              ? gradientappbarmobile()
              : null,
          backgroundColor: ColorCodes.whiteColor,
          body: Column(
            children: [
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),
              (_isWeb && !ResponsiveLayout.isSmallScreen(context))
                  ? bodyWeb()
                  : bodyMobile(),
            ],
          ),
          bottomNavigationBar: _isWeb
              ? SizedBox.shrink()
              : ValueListenableBuilder(
            valueListenable: productBox.listenable(),
            builder: (context, Box<Product> box, index) {
              if (productBox.length <= 0) {
                if (_isWeb && !ResponsiveLayout.isLargeScreen(context))
                  return SizedBox.shrink();
                return Container(
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
                      child: bottomNavigationbar()
                  ),
                );
              }

              return _isWeb ? SizedBox.shrink() : Container(
                color: Colors.white,
                child: Padding(
                    padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
                    child: _buildBottomNavigationBar()
                ),
              );
            },
          ),
        )
    );
  }
}
