import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/IConstants.dart';
import '../providers/branditems.dart';
import '../screens/login_screen.dart';
import '../screens/otpconfirm_screen.dart';

class LoginCredentialScreen extends StatefulWidget {
  static const routeName = '/logincredential-screen';

  @override
  LoginCredentialScreenState createState() => LoginCredentialScreenState();
}

class LoginCredentialScreenState extends State<LoginCredentialScreen> {
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var countrycode;
  List<String> countrycodelist;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        countrycode = prefs.getString("country_code");

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
    final isValid =_form.currentState.validate();
    if (!isValid) {
      return;
    }//it will check all validators
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('prevscreen') == "signingoogle" ||
        prefs.getString('prevscreen') == "signInApple" ||
        prefs.getString('prevscreen') == "signinfacebook"){
      checkMobilenum();
    } else {
      Provider.of<BrandItemsList>(context,listen: false).LoginUser();
      return Navigator.of(context).pushNamed(
        OtpconfirmScreen.routeName,
      );
    }

//    return LoginUser();


  }

  Future<void> checkMobilenum() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/mobile-check';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "mobileNumber": prefs.getString('Mobilenum'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          return Fluttertoast.showToast(msg: "Mobile number already exists!!!");
        } else if (responseJson['type'].toString() == "new") {
          Provider.of<BrandItemsList>(context,listen: false).LoginUser();
          return Navigator.of(context).pushNamed(
            OtpconfirmScreen.routeName,
          );
        }
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }

    } catch (error) {
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    //countrycode = "+971";
    countrycodelist = [countrycode];

    return Scaffold(
      body: SafeArea(
        child: Material(
            child: Column(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            child: new IconButton(
                              color: Theme.of(context).textSelectionTheme.selectionColor,
                              icon: new Icon(Icons.arrow_back, color: Theme.of(context).textSelectionTheme.selectionColor,),
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
                              },
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.fromLTRB(20, 20.0, 20.0, 0.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Please enter your mobile number',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey
                            ),
                            color: Colors.black12,
                          ),
                          height: 60.0,
                          width: MediaQuery.of(context).size.width,
                          child:  Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              CountryCodePicker(
                                onChanged: null,
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: countrycode,
                                //customList: countrycodelist,
                                //favorite: [countrycode,'FR'],
                                //countryFilter: ["AE"],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: false,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                              Text(
                                "|   ",
                                style: TextStyle(
                                  fontSize: 25.0,
                                  color: Theme.of(context).buttonColor,
                                ),
                              ),
                              Container(
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
                                        if (value.isEmpty) {
                                          return 'Please enter a Mobile number.';
                                        }
                                        return null; //it means user entered a valid input
                                      },
                                      onSaved: (value) {
                                        addMobilenumToSF(value);
                                      },
                                    ),
                                  )
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),


                  // This expands the row element vertically because it's inside a column
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // This makes the blue container full width.
                        Expanded(
                          child:  GestureDetector(
                              onTap: () {
                                _saveForm();
                                _isLoading = true;
                                if(_isLoading) {
                                  Center(
                                    child: CircularProgressIndicator(
                                      valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                                    ),
                                  );
                                }

                              }, child: Container(
//                          padding: EdgeInsets.all(20),
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  border: Border.all(color: Theme.of(context).primaryColor,)
                              ),
                              height: 60.0,
                              child: Center(
                                child: Text(
                                  "Next",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    color: Theme.of(context).buttonColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
            )
        ),
      ),
    );
  }
}
