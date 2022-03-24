import 'dart:convert';
import 'dart:async'; // for Timer class
import 'dart:io';
import '../constants/ColorCodes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_credential_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/cart_screen.dart';
import '../constants/IConstants.dart';
import '../screens/confirmorder_screen.dart';
import '../screens/address_screen.dart';
import '../providers/addressitems.dart';
import 'package:provider/provider.dart';
import '../screens/example_screen.dart';
import '../screens/mobile_authentication.dart';
import '../screens/MultipleImagePicker_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class OtpconfirmScreen extends StatefulWidget {
  static const routeName = '/otp-confirm';

  @override
  OtpconfirmScreenState createState() => OtpconfirmScreenState();
}

class OtpconfirmScreenState extends State<OtpconfirmScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  var _isLoading = false;
  int _timeRemaining = 30;
  var _showCall = false;
  Timer _timer;
  var mobilenum = "";
  var _mobilenum="";
  var countrycode = "";
  String otp1, otp2, otp3, otp4;
  TextEditingController controller = TextEditingController();
  var otpvalue = "";
  bool _showOtp = false;

  String apple = "";
  String name = "";
  String email = "";
  String mobile = "";
  String tokenid = "";
  var addressitemsData;

  _getmobilenum() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance();
    mobilenum = prefs.getString('Mobilenum');*/
    /*mobilenum=await PrefUtils.getMobileNum();

   */
  }

  @override
  void initState() {
//    LoginUser();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _getmobilenum();

    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        addressitemsData =
            Provider.of<AddressItemsList>(context, listen: false);

        countrycode = prefs.getString("country_code");

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
        mobile =prefs.getString('Mobilenum');
        tokenid = prefs.getString('tokenid');
      });
    });
    super.initState();
    _listenotp();
  }

  void _listenotp() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _getTime() {
    setState(() {
      _timeRemaining == 0 ? _timeRemaining = 0 : _timeRemaining--;
    });
  }

  addOtpval1(String value) {
    otp1 = value;
  }

  addOtpval2(String value) {
    otp2 = value;
  }

  addOtpval3(String value) {
    otp3 = value;
  }

  addOtpval4(String value) {
    otp4 = value;
  }

  addOtpvalToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('Otpval') == null) {
      prefs.setString('Otpval', value);
    } else {
      String otp = prefs.getString('Otpval') + value;
      prefs.setString('Otpval', otp);
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
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                ),
              ),
            );
          });
        });
  }

  Future<void> SignupUser() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/password-register';
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
        "device":channel.toString(),
      });
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        final data = responseJson['data'] as Map<String, dynamic>;
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));

        prefs.setString('LoginStatus', "true");
        Navigator.of(context).pop();

        return Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,
        );

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
  _verifyOtp() async {
    //var otpval = otp1 + otp2 + otp3 + otp4;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (otpvalue == prefs.getString('Otp')) {
verifynum();
      /*if (prefs.getString('type') == "old") {
        prefs.setString('LoginStatus', "true");
        _getprimarylocation();
        *//*return Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,);*//*
        *//*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*//*
      } else {
        return SignupUser();
        *//* if (prefs.getString('prevscreen') == 'signingoogle' ||
            prefs.getString('prevscreen') == 'signupselectionscreen' ||
            prefs.getString('prevscreen') == 'signInAppleNoEmail' ||
            prefs.getString('prevscreen') == 'signInApple' ||
            prefs.getString('prevscreen') == 'signinfacebook') {
          return signupUser();
        } else {
          prefs.setString('prevscreen', "otpconfirmscreen");
          Navigator.of(context).pop();
          return Navigator.of(context).pushNamedAndRemoveUntil(
              SignupScreen.routeName,
              ModalRoute.withName(CartScreen.routeName));
          *//**//*Navigator.of(context).pushReplacementNamed(
            SignupScreen.routeName,
          );*//**//*
        }*//*
//        return signupUser();
      }*/
    } else {
      Navigator.of(context).pop();
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
          Navigator.of(context).pushReplacementNamed(
              ConfirmorderScreen.routeName,
              arguments: {"prev": "address_screen"});
        } else {

          if (prefs.getString('frommultiple').toString() ==
              "multipleimagepicker") {
            Navigator.of(
                context)
                .pushReplacementNamed(
                MultipleImagePicker
                    .routeName, arguments: {
              'subject': "Click & Send",
              'type': "click",
            }
            );
          }
          else {
           // Navigator.of(context).pop();
           // Navigator.of(context).pop();
            prefs.setString("fromcart", "cart_screen");
            Navigator.of(context).pushNamedAndRemoveUntil(
                ExampleScreen.routeName,
                ModalRoute.withName(CartScreen.routeName), arguments: {
              'addresstype': "new",
              'addressid': "",
              'delieveryLocation': "",
              'latitude': "",
              'longitude': "",
              'branch': ""
            });
            //  }
          }
        }
       /*return  Navigator.of(context).pushReplacementNamed(
           ConfirmorderScreen.routeName,
           arguments: {
             "prev": "address_screen",
           });*/

      }
      else{
        Navigator.of(context).pop();
        return Fluttertoast.showToast(msg: 'Something Went Wrong..');
      }

    }
    catch (error) {
      throw error;
    }

    }
  Future<void> _getprimarylocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'customer/get-profile';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
      });

      final responseJson = json.decode(response.body);

      final dataJson =
      json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      /*if(dataJsondecode.containsKey('area')){*/
      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list
      //prefs.setString('LoginStatus', "true");
      /*if(data.contains("area")) {*/
      for (int i = 0; i < data.length; i++) {
        prefs.setString("deliverylocation", data[i]['area']);
        prefs.setString("branch", data[i]['branch']);
        Navigator.of(context).pop();
        if (prefs.containsKey("deliverylocation")) {
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  CartScreen.routeName,
                  ModalRoute.withName(HomeScreen.routeName));
              /*Navigator.of(context).pushReplacementNamed(
                CartScreen.routeName,);*/
            } else {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  HomeScreen.routeName,
                  ModalRoute.withName(OtpconfirmScreen.routeName));
              /*Navigator.of(context).pushReplacementNamed(
                HomeScreen.routeName,);*/
            }
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, ModalRoute.withName('/'));
            /*Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,);*/
          }
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              LocationScreen.routeName, ModalRoute.withName('/'));
          /*Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,);*/
        }
      }

      /* } else {
          Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,);
        }*/
      /*} else {
        Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,);
      }*/

    } catch (error) {
      throw error;
    }
  }

  Future<void> Otpin30sec() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-30';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
//      var Mobilenum = prefs.getString('Mobilenum');

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobile":prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> otpCall() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-call';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobile":prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
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

      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "username": name,
        "email": email,
        "mobileNumber": mobile,
        "path": apple,
        "tokenId": tokenid,
        "branch": prefs.getString('branch'),
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
        prefs.setString('mobile', prefs.getString('Mobilenum'));

        prefs.setString('LoginStatus', "true");
        Navigator.of(context).pop();

        return Navigator.of(context).pushNamedAndRemoveUntil(
            LocationScreen.routeName, ModalRoute.withName('/'));
        /*Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,);*/

      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor:
      //  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: Theme.of(context).primaryColor, // status bar color
    ));

    return Scaffold(
      key: _scaffoldKey,
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      // appBar: GradientAppBar(
      //   gradient: LinearGradient(
      //       begin: Alignment.topRight,
      //       end: Alignment.bottomLeft,
      //       colors: [
      //         Theme.of(context).accentColor,
      //         Theme.of(context).primaryColor
      //       ]),
      //   title: Text(
      //     'Signup using OTP',
      //     style: TextStyle(fontWeight: FontWeight.normal),
      //   ),
      // ),
      backgroundColor: Colors.white,
      body:
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 25.0),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                translate('forconvience.check OTP'), //'Please check OTP sent to your mobile number',
                style: TextStyle(
                    color: Color(0xFF404040),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0),
                // textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 20.0),
                Text(
                  countrycode + '  $mobile',
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontSize: 16.0),
                ),
               // SizedBox(width: 50.0),
                Spacer(),
                GestureDetector(
                  onTap: () {
                   /* Navigator.of(context).pushNamedAndRemoveUntil(
                        LoginCredentialScreen.routeName,
                        ModalRoute.withName('/'));*/
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right:38.0),
                    child: Container(

                      height: 35,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: ColorCodes.backbutton, width: 0.5),
                      ),
                      child: Center(
                          child: Text(
                              translate('header.change'),
                              //'CHANGE',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor, fontSize: 13))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                translate('forconvience.enterotp'), //Enter OTP',
                style: TextStyle(color: Color(0xFF727272), fontSize: 14),
                //textAlign: TextAlign.left,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              // Auto Sms
              Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 95 / 100,
                  padding: EdgeInsets.only(left: 20.0),
                  child: PinFieldAutoFill(
                    controller: controller,
                    decoration: UnderlineDecoration(
                      //gapSpace: 30.0,
                        textStyle: TextStyle(fontSize: 18, color: Colors.black),
                        colorBuilder: FixedColorBuilder(Color(0xFF707070))),
                    onCodeChanged: (text) {
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
                    currentCode: otpvalue,
                  ))
            ]),
            SizedBox(
              height: 35,
            ),

            // GrocBay new Resend OTP buttons

            _showOtp
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(

                      height: 40,
                      width: MediaQuery.of(context).size.width * 38 / 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Color(0xFF6D6D6D), width: 1.5),
                      ),
                      child: Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            translate('forconvience.resendOtp'), //'Resend OTP',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    /*Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Color(0xFF6D6D6D), width: 1.5),
                      ),
                      child: Center(
                          child: Text(
                            'OR',
                            style: TextStyle(
                                fontSize: 7, color: Color(0xFF727272)),
                          )),
                    ),*/
                    /*_timeRemaining == 0
                        ? GestureDetector(
                      onTap: () {
                        otpCall();
                        _timeRemaining = 60;
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width *
                            38 /
                            100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: Colors.green, width: 1.5),
                        ),
                        child: Center(
                            child: Text(
                              'CALL ME INSTEAD',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black),
                            )),
                      ),
                    )
                        : Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width *
                          38 /
                          100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Color(0xFF6D6D6D), width: 1.5),
                      ),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                  text: 'Call in',
                                  style:
                                  TextStyle(color: Colors.black)),
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
                    )*/
                  ]),
                )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                  _timeRemaining == 0
                      ? GestureDetector(
                    onTap: () {
                      // _showCall = true;
                      _showOtp = true;
                      _timeRemaining += 30;
                      Otpin30sec();
                    },
                    child: Container(

                      height: 40,
                      width: MediaQuery.of(context).size.width *
                          38 /
                          100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.green, width: 1.5),
                      ),
                      child: Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(

                            translate('forconvience.resendOtp'), //'RESEND OTP',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: ColorCodes.whiteColor),
                          ),
                        ),
                      ),
                    ),
                  )
                      : Container(
                    height: 40,
                    width:
                    MediaQuery.of(context).size.width * 38 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: Color(0x707070B8), width: 1.5),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            new TextSpan(
                                text: translate('forconvience.Resend Otp in'),//'Resend Otp in',
                                style:
                                TextStyle(color: Colors.black)),
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
               /* Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                      Border.all(color: Color(0xFF6D6D6D), width: 1.5),
                    ),
                    child: Center(
                        child: Text(
                          'OR',
                          style: TextStyle(fontSize: 10),
                        )),
                  ),*/
               /* Container(
                    height: 40,
                    width: MediaQuery.of(context).size.width * 38 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border:
                      Border.all(color: Color(0xFF6D6D6D), width: 1.5),
                    ),
                    child: Center(child: Text('CALL ME INSTEAD')),
                  ),*/
              ],
            ),
                ),
            // This expands the row element vertically because it's inside a column
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  // This makes the blue container full width.
                  Expanded(
                    child: GestureDetector(
                        onTap: () {
                          _dialogforProcessing();
                          _verifyOtp();
                        },
                        child: Container(
//                          padding: EdgeInsets.all(20),
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
                                translate('forconvience.VERIFY MY NUMBER'), //"VERIFY MY NUMBER",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Theme.of(context).buttonColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ]),
    );
  }

  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(


          icon: Icon(Icons.arrow_back_ios_outlined, color: ColorCodes.blackColor),


          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
            return Future.value(false);
          }
      ),
      titleSpacing: 0,
      title: Text(
        translate('forconvience.OTP Verification'), //'OTP Verification',
        style: TextStyle(color:ColorCodes.blackColor,fontWeight: FontWeight.normal),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.whiteColor,
                  ColorCodes.whiteColor
                ]
            )
        ),
      ),
    );
  }
}
