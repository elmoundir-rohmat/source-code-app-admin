import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_translate/flutter_translate.dart';
import '../constants/IConstants.dart';
import '../screens/location_screen.dart';


class EmailScreen extends StatefulWidget {
  static const routeName = '/email-screen';

  @override
  EmailScreenState createState() => EmailScreenState();
}

class EmailScreenState extends State<EmailScreen> {
  final _form = GlobalKey<FormState>();

  addEmailToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
  }

  _saveForm() async {
    final isValid =_form.currentState.validate();
    if (!isValid) {
      return;
    }//it will check all validators


    _form.currentState.save();
//    return Navigator.of(context).pushNamed(
//        LoginCredentialScreen.routeName);

    _dialogforProcessing();
    checkemail();

    /*if(prefs.getString('prevscreen') == 'signupselectionscreen') {
      return Navigator.of(context).pushNamed(
          LoginCredentialScreen.routeName);
    } else {
      return SignupUser();
    }*/
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
          return Fluttertoast.showToast(msg:  translate('forconvience.Email id already exists!!!') //"Email id already exists!!!"
          );
        } else if (responseJson['type'].toString() == "new") {
          return SignupUser();
        }
      } else {
        Navigator.of(context).pop();
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }

    } catch (error) {
      throw error;
    }
  }

  Future<void> SignupUser() async { // imp feature in adding async is the it automatically wrap into Future.
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
      String apple = "";
      if(prefs.getString('applesignin') == "yes") {
        apple = prefs.getString('apple');
      } else {
        apple = "";
      }

      String name = prefs.getString('FirstName') + " " + prefs.getString('LastName');

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "username": name,
            "email": prefs.getString('Email'),
            "mobileNumber": prefs.getString('Mobilenum'),
            "path": apple,
            "tokenId": prefs.getString('tokenid'),
            "branch": prefs.getString('branch'),
            "device":channel.toString(),
            "signature" : prefs.containsKey("signature") ? prefs.getString('signature') : "",
          }
      );
      final responseJson = json.decode(response.body);
      final data = responseJson['data'] as Map<String, dynamic>;

      if(responseJson['status'].toString() == "true"){
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString("mobile", prefs.getString('Mobilenum'));

        prefs.setString('LoginStatus', "true");
        Navigator.of(context).pop();
        return Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,);

        /*Navigator.of(context).pushReplacementNamed(
          HomeScreen.routeName,
        );*/

      } else  if(responseJson['status'].toString() == "false") {
        Navigator.of(context).pop();
      }


    } catch (error) {
      setState(() {
      });
      throw error;
    }
  }

  _dialogforProcessing() {
    return showDialog(context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return AbsorbPointer(
                  child: Container(
                    color: Colors.transparent,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),),
                  ),
                );
              }
          );
        });
  }

  @override
  Widget build(BuildContext context) {
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
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 80.0,
                            height: 80.0,
                            child: new Image.asset( "assets/images/email.png",
                                fit: BoxFit.fill
                            ),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.only(left: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "What\'s your email?",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 40.0,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 0.0, 20.0, 0.0),
                        child: Form(
                          key: _form,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
//                        style: new TextStyle(decorationColor: Theme.of(context).primaryColor),
                                decoration: InputDecoration(
                                    labelText: "Email address",
                                    labelStyle: new TextStyle(
                                      fontSize: 16.0,
                                      color: Theme.of(context).primaryColor,
                                    )
                                ),
                                validator: (value) {
                                  bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);

                                  if (value.isEmpty) {
                                    return 'Please enter a email address.';
                                  } else if(!emailValid) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null; //it means user entered a valid input
                                },
                                onSaved: (value) {
                                  addEmailToSF(value);
                                },
                              ),
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
                          child: GestureDetector(
                              onTap: () {
                                _saveForm();
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)
                                  ),
                                  height: 50.0,
                                  child: Center(
                                    child: Text(
                                      "NEXT",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).primaryColor,
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
