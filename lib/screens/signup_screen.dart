import 'package:flutter/cupertino.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import '../screens/signup_selection_screen.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import '../screens/otpconfirm_screen.dart';
import '../constants/ColorCodes.dart';
import 'location_screen.dart';
import 'package:http/http.dart' as http;
import '../screens/home_screen.dart';
import '../screens/mobile_authentication.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/map_screen.dart';

class SignupScreen extends StatefulWidget {
  static const routeName = '/signup-screen';

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  final _lnameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String fn = "",fn1="",fn2="";
  String ln = "",ln1="",ln2="";
  String ea = "",ea1="",ea2="";
  bool _obscureText = true;
  final TextEditingController namecontroller = new TextEditingController();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  final TextEditingController refercontroller = new TextEditingController();
  bool _isWeb = false;
  bool iphonex = false;

  @override
  void initState() {
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("Email", "");
      if(prefs.getString("referCodeDynamic") == "" ||prefs.getString("referCodeDynamic") == null){
        refercontroller.text = "";
      }else{
        refercontroller.text = prefs.getString("referCodeDynamic");
      }
    });
    super.initState();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    emailcontroller.dispose();
    passwordcontroller.dispose();
    namecontroller.dispose();
    refercontroller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  addEmailToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
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
           Fluttertoast.showToast(msg: translate('forconvience.Email id already exists!!!') //"Email id already exists!!!"
           );
           return   Navigator.of(context).pushReplacementNamed(
              SignupSelectionScreen.routeName);
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


/*
  Future<void> checkemail() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'email-otp?';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "email": prefs.getString('Email'),
        "username":prefs.getString('FirstName'),
      });
      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        prefs.setString('type', responseJson['type'].toString());
        return  Navigator.of(context).pushNamed(
          OtpconfirmScreen.routeName,
        );//SignupUser();
      } else if(responseJson['status'].toString() == "400") {
        Navigator.of(context).pop();
         Fluttertoast.showToast(msg: "Email Already exist!!!");
     return   Navigator.of(context).pushReplacementNamed(
            SignupSelectionScreen.routeName);

      }
      else{
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }
    } catch (error) {
      throw error;
    }
  }
*/



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

  Future<void> LoginEmail() async{
    var url=IConstants.API_PATH + 'customer/password-register';
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
        "username": namecontroller.text,
        "email": emailcontroller.text,
        "path" : "abc",
        "mobileNumber":"",
        "tokenId": prefs.getString('tokenid'),
        "guestUserId" : prefs.getString('guestuserId'),
        "branch":prefs.getString('branch'),
        "password":passwordcontroller.text,
        "device":channel.toString(),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final data = responseJson['data'] as Map<String, dynamic>;

      if (responseJson['status'].toString() == "true") {
        /* prefs.setString('Otp', data['otp'].toString());
      prefs.setString('apiKey', data['apiKey'].toString());
      prefs.setString('userID', data['userID'].toString());
      prefs.setString('type', responseJson['type'].toString());
      prefs.setString('membership', data['membership'].toString());
      prefs.setString("mobile", data['mobile'].toString());
      prefs.setString("latitude", data['latitude'].toString());
      prefs.setString("longitude", data['longitude'].toString());
      prefs.setString('apple', data['apple'].toString());

      if (prefs.getString('prevscreen') != null) {
        if (prefs.getString('prevscreen') == 'signingoogle') {
        } else if (prefs.getString('prevscreen') == 'signinfacebook') {
        } else {
          prefs.setString('FirstName', data['name'].toString());
          prefs.setString('LastName', "");
          prefs.setString('Email', data['email'].toString());
          prefs.setString("photoUrl", "");
        }
      }*/

//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );



      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
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
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (route) => false);
          }


        }
        else if(prefs.getString("isdelivering").toString()=="true"){
          //if(prefs.getString("nopermission").toString()!="null"){
          /*if(prefs.getString("isdelivering").toString()=="true"){*/

          /*Navigator.of(context).pushReplacementNamed(
            HomeScreen.routeName,
          );*/

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
        "device": channel.toString(),
        "referralid":(refercontroller.text),
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
        prefs.setString('referral', prefs.getString('referralCode')??"");

        //Navigator.of(context).pop();
       // if(prefs.getString("latitude").toString()!="null"||prefs.getString("longitude").toString()!="null") {
          if (prefs.getString("ismap").toString() == "true") {

            addprimarylocation();
          } else if (prefs.getString("isdelivering").toString() == "true") {
           // Navigator.of(context).pop();
            addprimarylocation();
          } else {
            Navigator.of(context).pop();
            prefs.setString("formapscreen", "homescreen");
            Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
           /* Navigator.of(context).pushReplacementNamed(
              LocationScreen.routeName,
            );*/
          }
        /*}
        else{
          Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,
          );
        }*/


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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('FirstName', value);
  }

  addReferralToSF(String value)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('referid', value);
  }

  addPasswordToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Password', value);
  }

  _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //checkemail();
    _dialogforProcessing();
    checkemail();
    //SignupUser();
   // LoginEmail();
  }
  _bottomNavigationBar() {
    return SingleChildScrollView(

        child: GestureDetector(
          onTap: () {
            _saveForm();
          },
          child: Container(
            height: 50,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                  translate('forconvience.CONTINUE'),// 'CONTINUE',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ),

    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor:
      //  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: Theme.of(context).primaryColor, // status bar color
    ));
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
             ColorCodes.whiteColor,
              ColorCodes.whiteColor,
            ]),
        title: Text(//'Sign Up',
            translate('forconvience.Sign Up'),
         style: TextStyle(color: ColorCodes.blackColor,fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
            //Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child:
              Form(
                key: _form,
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
                            fn = "  "+translate('forconvience.please enter name');//"  Please Enter Name";
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
                      controller: emailcontroller,
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
                      controller: passwordcontroller,
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

                    SizedBox(height: 20.0),

                    TextFormField(
                      textAlign: TextAlign.left,
                      controller: refercontroller,
                      decoration: InputDecoration(
                        hintText:  translate('appdrawer.referandearn'), //'Refer and Earn',//translate('forconvience.Name'),//'Name',
                        prefixIcon: Icon(Icons.card_giftcard, size: 20,),
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

                      onSaved: (value) {
                        addReferralToSF(value);
                      },
                    ),
                  ],
                ),
              ),
            ),


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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
        child: _bottomNavigationBar(),
      ),
    );
  }
}
