import 'dart:convert';

import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/IConstants.dart';
import '../providers/branditems.dart';
import '../screens/otpconfirm_screen.dart';
import '../constants/images.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login-screen';

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var countrycode;
  List<String> countrycodelist;
  String countryName = "India";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        countrycode = prefs.getString("country_code");
        countryName =
            CountryPickerUtils.getCountryByPhoneCode(countrycode.split('+')[1])
                .name;
      });
    });
    super.initState();
  }

  addMobilenumToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    final mobilenum = "+91 $value";
    prefs.setString('Mobilenum', value);
  }

  _saveForm() async {
    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('prevscreen') == "signingoogle" ||
        prefs.getString('prevscreen') == "signInApple" ||
        prefs.getString('prevscreen') == "signinfacebook") {
      checkMobilenum();
    } else {
      Provider.of<BrandItemsList>(context,listen: false).LoginUser();
      Navigator.of(context).pop();
      return Navigator.of(context).pushNamed(
        OtpconfirmScreen.routeName,
      );
    }

//    return LoginUser();
  }

  Future<void> checkMobilenum() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/mobile-check';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          return Fluttertoast.showToast(msg: "Mobile number already exists!!!");
        } else if (responseJson['type'].toString() == "new") {
          Provider.of<BrandItemsList>(context,listen: false).LoginUser();
          Navigator.of(context).pop();
          return Navigator.of(context).pushNamed(
            OtpconfirmScreen.routeName,
          );
        }
      } else {
        Navigator.of(context).pop();
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
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
    //countrycode = "+971";
    countrycodelist = [countrycode];
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

    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ]),
        title: Text(
          'Signup',
          style: TextStyle(fontWeight: FontWeight.normal),
        ),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width / 1.2,
              margin: EdgeInsets.only(top: 40.0, bottom: 20.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please enter your mobile number',
                    style: TextStyle(
                        color: Color(0xFF404040),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ))),
          Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 52,
            margin: EdgeInsets.only(bottom: 8.0),
            padding:
            EdgeInsets.only(left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Country/Region",
                        style: TextStyle(
                          color: Color(0xff808080),
                        )),
                    Text(countryName + " (" + countrycode + ")",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 52.0,
            padding:
            EdgeInsets.only(left: 10.0, top: 5.0, right: 5.0, bottom: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(width: 0.5, color: Color(0xff4B4B4B)),
            ),
            child: Row(
              children: <Widget>[
                Image.asset(Images.phoneImg),
                SizedBox(
                  width: 14,
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Form(
                      key: _form,
                      child: TextFormField(
                        style: TextStyle(fontSize: 16.0),
                        textAlign: TextAlign.left,
                        inputFormatters: [LengthLimitingTextInputFormatter(12)],
                        cursorColor: Theme.of(context).primaryColor,
                        keyboardType: TextInputType.number,
                        //autofocus: true,
                        decoration: new InputDecoration.collapsed(
                            hintText: 'Enter Your Mobile Number',
                            hintStyle: TextStyle(
                              color: Colors.black12,
                            )),
                        validator: (value) {
                          String patttern = r'(^(?:[+0]9)?[0-9]{6,10}$)';
                          RegExp regExp = new RegExp(patttern);
                          if (value.isEmpty) {
                            Navigator.of(context).pop();
                            return 'Please enter a Mobile number.';
                          } else if (!regExp.hasMatch(value)) {
                            Navigator.of(context).pop();
                            return 'Please enter valid mobile number';
                          }
                          return null;
                        }, //it means user entered a valid input
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
              style: TextStyle(fontSize: 13, color: Color(0xff3B3B3B)),
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
                        _saveForm();
                        _dialogforProcessing();
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
                              "OTP Verification",
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
      ),
    );
  }
}
