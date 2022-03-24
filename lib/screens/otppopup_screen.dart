import 'dart:convert';
import 'dart:async'; // for Timer class
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../constants/ColorCodes.dart';
import '../constants/images.dart';
import '../providers/branditems.dart';
import '../screens/map_screen.dart';
import '../screens/otpconfirm_screen.dart';
import '../screens/policy_screen.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/header.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_credential_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/cart_screen.dart';
import '../constants/IConstants.dart';


GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);


class OtpPopup extends StatefulWidget {
  @override
  _OtpPopupState createState() => _OtpPopupState();
}

class _OtpPopupState extends State<OtpPopup> {
  var countrycode = "";
  String mobile = "";
  TextEditingController controller = TextEditingController();
  var otpvalue = "";
  bool _showOtp = false;
  bool _isWeb = false;
  var _isLoading = false;
  int _timeRemaining = 30;
  String fn = "";
  String ln = "";
  String ea = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;

  @override
  void initState() {
    // TODO: implement initState


  }



  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return _dialogforotp();
    throw UnimplementedError();
  }
  _dialogforotp(){
  return  showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(

                height:(_isWeb && ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.height:MediaQuery.of(context).size.width / 3,
                width:(_isWeb && ResponsiveLayout.isSmallScreen(context)) ?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width / 2.5,
                color: Colors.white,
                child: _otp(),

              ),
            );
          });
        });
  }
  _dialogforAddInfo() {
    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.90;
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
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
                           // key: _form,
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
                                 // controller: firstnamecontroller,
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
                                   // FocusScope.of(context).requestFocus(_lnameFocusNode);
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
                                  //  addFirstnameToSF(value);
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
                                    //addEmailToSF(value);
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
                          ),
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
                       //   _saveAddInfoForm();
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


  Widget _otp(){
    return Column(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: 50.0,
        color: ColorCodes.lightGreyWebColor,
        padding: EdgeInsets.only(left: 20.0),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Signup using OTP",
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
              SizedBox(height: 25.0),
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

                     _dialogforAddInfo();
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
                    )),
              ]),
              SizedBox(
                height: 20,
              ),
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
                        ?
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior:
                        HitTestBehavior.translucent,
                        onTap: () {
                         // otpCall();
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
                        //Otpin30sec();
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
            //  _verifyOtp();
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
                  "LOGIN",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).buttonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
      ),
    ]);
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
}