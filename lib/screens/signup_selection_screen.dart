import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:fellahi_e/utils/keyboard.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../constants/ColorCodes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import '../utils/ResponsiveLayout.dart';
import '../constants/IConstants.dart';
import '../screens/location_screen.dart';
import '../screens/policy_screen.dart';
import '../screens/login_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/home_screen.dart';
import '../providers/branditems.dart';
import '../handler/firebase_notification_handler.dart';
import '../screens/otpconfirm_screen.dart';
import '../constants/ColorCodes.dart';
import '../constants/images.dart';
import '../screens/signup_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/mobile_authentication.dart';
import '../screens/map_screen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class SignupSelectionScreen extends StatefulWidget {
  static const routeName = '/signupselection-screen';

  @override
  SignupSelectionScreenState createState() => SignupSelectionScreenState();
}

class SignupSelectionScreenState extends State<SignupSelectionScreen> {
  bool _isAvailable = false;
  SharedPreferences prefs;
  final _form = GlobalKey<FormState>();
  final _formalert = GlobalKey<FormState>();
  final _formreset = GlobalKey<FormState>();
  var countrycode;
  String countryName = "India";
  bool _isLoading = false;
  bool _enabled = true;
  int count = 0;
  String fn = "";
  String ln = "";
  String ea = "";
  String appletoken="";
  String name = "";
  String email = "";
  String mobile = "";
  String tokenid = "";
  FocusNode emailfocus = FocusNode();
  FocusNode passwordfocus = FocusNode();
  final TextEditingController emailcontrolleralert = new TextEditingController();
  final TextEditingController emailcontroller = new TextEditingController();
  final TextEditingController passwordcontroller = new TextEditingController();
  final TextEditingController otpcontroller = new TextEditingController();
  final TextEditingController newpasscontroller = new TextEditingController();
  final TextEditingController referController= new TextEditingController();
  bool _isWeb = false;
  bool navigatpass = false;

  Map<String, dynamic> _userData;
  //AccessToken _accessToken;
  bool _checking = true;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailfocus.dispose();
    passwordfocus.dispose();
    emailcontroller.dispose();
    emailcontrolleralert.dispose();
    passwordcontroller.dispose();
    otpcontroller.dispose();
    newpasscontroller.dispose();
  }
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
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

      prefs = await SharedPreferences.getInstance();

      if(prefs.getString("referCodeDynamic") == "" ||prefs.getString("referCodeDynamic") == null){
        referController.text = "";
      }else{
        referController.text = prefs.getString("referCodeDynamic");
      }
      /*setState(() {
        countrycode = prefs.getString("country_code");
        countryName =
            CountryPickerUtils.getCountryByPhoneCode(countrycode.split('+')[1])
                .name;
        prefs.setString("skip", "no");
      });*/
      await new FirebaseNotifications().setUpFirebase();
      await Provider.of<BrandItemsList>(context,listen: false).GetRestaurant().then((_) {
        if (!prefs.containsKey("deliverylocation")) {
          prefs.setString(
              "deliverylocation", prefs.getString("restaurant_location"));
          prefs.setString("latitude", prefs.getString("restaurant_lat"));
          prefs.setString("longitude", prefs.getString("restaurant_long"));
        }
      }); // only create the future once.
    });
    super.initState();
    _googleSignIn.signInSilently();
  }
  addEmailToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Email', value);
  }
  addPasswordToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Password', value);
  }


  handleDynamicLink() async {

    await FirebaseDynamicLinks.instance.getInitialLink();
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData data) async {
      handleSuccessLinking(data);
    }, onError: (OnLinkErrorException error) async {
    });

  }
  void handleSuccessLinking(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      var isRefer = deepLink.pathSegments.contains('refer');
      if (isRefer) {
        var code = deepLink.queryParameters['code'];

        prefs.setString("referCodeDynamic", code);
      }
    }
  }

  _saveForm() async {
    var shouldAbsorb = true;

    final signcode = SmsAutoFill().getAppSignature;
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();
    //LoginUser();
    //final logindata =
    // Provider.of<BrandItemsList>(context, listen: false).LoginEmail();
    _dialogforProcessing();
    LoginUser();
    //  Login();
    setState(() {
      _isLoading = false;
    });
    //return Navigator.of(context).pushNamed(OtpconfirmScreen.routeName);
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
    // Provider.of<BrandItemsList>(context, listen: false).LoginEmail();
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
    // Provider.of<BrandItemsList>(context, listen: false).LoginEmail();
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
        /* "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,*/
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      // final data = responseJson['data'] as Map<String, dynamic>;
      if (responseJson['status'].toString() == "200") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        //Navigator.pop(context);
        Fluttertoast.showToast(msg: responseJson['data'].toString(),
            timeInSecForIos: 2,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        // Navigator.pop(context);
        //Navigator.of(context).pop();
        // Navigator.of(context).pop();
        /*
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('Otp', responseJson['otp'].toString());
        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['id'].toString());
        prefs.setString('FirstName', data['username'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('LoginStatus', "true");
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
        */

        //Navigator.of(context).pop();
        // _resetpass();
        // Navigator.of(context).pop();
        //_dialogresetforForgotpass();
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/


      } else if (responseJson['status'].toString() == "400") {
        Navigator.pop(context);
        Navigator.of(context).pop(true);
        Fluttertoast.showToast(msg: "Something Went Wrong !!",
            timeInSecForIos: 2,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        // Navigator.pop(context);
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
        // await keyword is used to wait to this operation is complete.
        "email": emailcontrolleralert.text,//prefs.getString('Email'),
        /* "tokenId": prefs.getString('tokenid'),
        "password" : prefs.getString('Password') ,*/
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "200") {
        final data = responseJson['data'] as Map<String, dynamic>;
        //prefs.setString('Otp', data['otp'].toString());
        prefs.setString('Otp', responseJson['otp'].toString());
        //  prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', data['id'].toString());
        /* prefs.setString('FirstName', data['username'].toString());
        prefs.setString("Email", data['email'].toString());
        prefs.setString('membership', data['membership'].toString());
        prefs.setString("mobile", data['mobile'].toString());
        prefs.setString("latitude", data['latitude'].toString());
        prefs.setString("longitude", data['longitude'].toString());
        prefs.setString('apple', data['apple'].toString());
        prefs.setString('branch', data['branch'].toString());
        prefs.setString('LoginStatus', "true");
        if (prefs.getString('prevscreen') != null) {
          if (prefs.getString('prevscreen') == 'signingoogle') {
          } else if (prefs.getString('prevscreen') == 'signinfacebook') {
          } else {
            prefs.setString('Name', data['name'].toString());
            prefs.setString('LastName', "");
            prefs.setString('Email', data['email'].toString());
            prefs.setString("photoUrl", "");
          }
        }*/
        Navigator.of(context).pop();
        //Navigator.of(context).pop();
        //Navigator.of(context).pop();
        _resetpass();
        // Navigator.of(context).pop();
        //_dialogresetforForgotpass();
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );
        /*Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/
      } else if (responseJson['status'].toString() == "400") {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: translate('forconvience.invalid email'), timeInSecForIos: 2);
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
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

     /* if(responseJson['data'].toString()=="Wrong Email!!!"){
        Fluttertoast.showToast(msg: "Wrong email id or password.",
        timeInSecForIos: 2,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        Navigator.of(context).pop(true);
      }*/
      if (responseJson['status'].toString() == "200") {
        final data = responseJson['data'] as Map<String, dynamic>;
        //prefs.setString('Otp', data['otp'].toString());
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
        Fluttertoast.showToast(msg: translate('forconvience.invalid email'),//"Wrong email id or password.",
            timeInSecForIos: 2,
            backgroundColor: Colors.black87,
            textColor: Colors.white);
        Navigator.of(context).pop(true);
      }
         else if(responseJson['data'].toString()=="Wrong Password!!!"){
           Fluttertoast.showToast(msg: translate('forconvience.invalid password'),//"Wrong email id or password.",
               timeInSecForIos: 2,
               backgroundColor: Colors.black87,
               textColor: Colors.white);
           Navigator.of(context).pop(true);
         }
         else {
           Fluttertoast.showToast(msg: responseJson['data'], timeInSecForIos: 2);
           Navigator.of(context).pop();
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

  Future<void> LoginEmail() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'useremail-login';
    //try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final response = await http.post(url, body: {
      // await keyword is used to wait to this operation is complete.
      "email": prefs.getString('Email'),
      "tokenId": prefs.getString('tokenid'),
      "password" : prefs.getString('Password') ,
    });
    final responseJson = json.decode(utf8.decode(response.bodyBytes));
    final data = responseJson['data'] as Map<String, dynamic>;
    if (responseJson['status'].toString() == "200") {
      //prefs.setString('Otp', data['otp'].toString());
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
      if (prefs.getString('prevscreen') != null) {
        if (prefs.getString('prevscreen') == 'signingoogle') {
        } else if (prefs.getString('prevscreen') == 'signinfacebook') {
        } else {

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
                  ModalRoute.withName(SignupSelectionScreen.routeName));
              /*Navigator.of(context).pushReplacementNamed(
                HomeScreen.routeName,);*/
            }
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeScreen.routeName, ModalRoute.withName('/'));
            /*Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,);*/
          }

          prefs.setString('Name', data['name'].toString());
          prefs.setString('LastName', "");
          prefs.setString('Email', data['email'].toString());
          prefs.setString("photoUrl", "");
        }
      }





    } else if (responseJson['status'].toString() == "400") {
      Fluttertoast.showToast(msg: responseJson['data'], timeInSecForIos: 2);
    }
    /*} catch (error) {
      throw error;
    }*/
  }

  Future<void> Login() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + "customer/useremail-login";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "email": prefs.getString('Email'),
            "password": prefs.getString('Password'),
          }
      );
      final responseJson = json.decode(response.body);
      if(responseJson['status'].toString() == "200"){
        final dataJson = json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);

        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) =>
            data.add(dataJsondecode[index] as Map<String, dynamic>)
        );
        /*prefs.setString('id', data[0]['id'].toString());
    prefs.setString('first_name', data[0]['first_name'].toString());
    prefs.setString('last_name', data[0]['last_name'].toString());
    prefs.setString('mobile_number', data[0]['mobile_number'].toString());
    prefs.setString('email', data[0]['email'].toString());
    prefs.setString('address', data[0]['address'].toString());
    prefs.setString("login_status", "true");
    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);*/
      } else {

      }

    } catch (error) {
      setState(() {
      });
      throw error;
    }
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
      final responseJson = json.decode(response.body);

      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          return Fluttertoast.showToast(msg: "Mobile number already exists!!!", timeInSecForIos: 2);
        } else if (responseJson['type'].toString() == "new") {
          Provider.of<BrandItemsList>(context,listen: false).LoginUser();
          return Navigator.of(context).pushNamed(
            OtpconfirmScreen.routeName,
          );
        }
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!", timeInSecForIos: 2);
      }
    } catch (error) {
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
      prefs.setString('skip', "no");
      prefs.setString('prevscreen', "signingoogle");
      checkusertype("Googlesigin");
    } catch (error) {
      Navigator.of(context).pop();
     /* Fluttertoast.showToast(
          msg: "Sign in failed!",
          timeInSecForIos: 2,,
          backgroundColor: Colors.black87,
          textColor: Colors.white);*/
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
         /* Navigator.of(context).pushReplacementNamed(
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
    if (prefs.getString('applesignin') == "yes") {
    appletoken = prefs.getString('apple');
    } else {
    appletoken = "";
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
    // mobile = prefs.getString('Mobilenum');
    tokenid = prefs.getString('tokenid');
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/register';

    try {


    final response = await http.post(url, body: {
    // await keyword is used to wait to this operation is complete.
    "username": name,
    "email": email,
    "mobileNumber": mobile,
    "path": appletoken,
    "tokenId": tokenid,
      "guestUserId" : prefs.getString('guestuserId'),
    "branch": prefs.getString('branch') ,
    "device":channel.toString(),
      "referralid": referController.text,
    });
    final responseJson = json.decode(response.body);
    final data = responseJson['data'] as Map<String, dynamic>;

    if (responseJson['status'].toString() == "true") {

        prefs.setString('apiKey', data['apiKey'].toString());
        prefs.setString('userID', responseJson['userId'].toString());
        prefs.setString('membership', responseJson['membership'].toString());
        prefs.setString('referid', referController.text);
        prefs.setString('LoginStatus', "true");
       /* Navigator.of(context).pop();
        return Navigator.of(context).pushNamedAndRemoveUntil(
            LocationScreen.routeName, ModalRoute.withName('/'));*/
        if(responseJson['type'].toString() == "old"){
        Navigator.of(context).pop();
        return Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName, ModalRoute.withName('/'));
      }
      else {
          /* Navigator.of(context).pop();
        return Navigator.of(context).pushNamedAndRemoveUntil(
            LocationScreen.routeName, ModalRoute.withName('/'));*/
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
        }

    /*Navigator.of(context).pushReplacementNamed(
          LocationScreen.routeName,);*/

    }
    else if (responseJson['status'].toString() == "false") {
    Navigator.of(context).pop();
    return Fluttertoast.showToast(msg: responseJson['data'].toString(),/*'Something Went Wrong..',*/ timeInSecForIos: 2);
    }
    } catch (error) {
    Navigator.of(context).pop();
    return Fluttertoast.showToast(msg: 'Code Invalide', timeInSecForIos: 2);
    throw error;
    }
  }

  /*Future<void> _fblogin() async {
    try {
      // show a circular progress indicator
      setState(() {
        _checking = true;
      });
      _accessToken = await FacebookAuth.instance.login(); // by the fault we request the email and the public profile
      // loginBehavior is only supported for Android devices, for ios it will be ignored
      // _accessToken = await FacebookAuth.instance.login(
      //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
      //   loginBehavior:
      //       LoginBehavior.DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
      // );

      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _userData = userData;
    } on FacebookAuthException catch (e) {
      // if the facebook login fails
      // check the error type
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          break;
        case FacebookAuthErrorCode.CANCELLED:
          break;
        case FacebookAuthErrorCode.FAILED:
          break;
      }
    } catch (e, s) {
    } finally {
      // update the view
      setState(() {
        _checking = false;
      });
    }
  }*/

  _dialogforRefer(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.0)),
              child: Container(
                  height: 200.0,
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        translate('appdrawer.referandearn'), //"Refer And Earn",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextField(
                        controller: referController,
                        decoration: InputDecoration(
                          hintText:  translate('appdrawer.referandearn'), //"Refer and Earn (optional)",//"Reasons (Optional)",
                          contentPadding: EdgeInsets.all(16),
                          border: OutlineInputBorder(),
                        ),
                        minLines: 2,
                        maxLines: 2,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      FlatButton(
                        onPressed: () {
                          _dialogforProcessing();
                          SignupUser();
                        },
                        child: Text(
                          translate('forconvience.Next'), // "Next",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  )),
            );
          });
        });
  }

  void initiateFacebookLogin() async {
    final facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior =  Platform.isIOS ? FacebookLoginBehavior.webViewOnly : FacebookLoginBehavior.nativeWithFallback;//FacebookLoginBehavior.webViewOnly;
    final result = await facebookLogin.logIn(['email']);
    //final result = await facebookLogin.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.error:
        facebookAppEvents.logEvent(name: "fb_login");
        Navigator.of(context).pop();
       /* Fluttertoast.showToast(
            msg: "Sign in failed!",
            timeInSecForIos: 2,
            backgroundColor: Colors.black87,
            textColor: Colors.white);*/
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        Navigator.of(context).pop();
       /* Fluttertoast.showToast(
            msg: "Sign in cancelled by user!",
            timeInSecForIos: 2
            backgroundColor: Colors.black87,
            textColor: Colors.white);*/
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        facebookAppEvents.logEvent(name: "fb_login");
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
          // await
          "email": prefs.getString('Email'),
          "tokenId": prefs.getString('tokenid'),
        });
      }

      final responseJson = json.decode(response.body);
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
        _getprimarylocation();
      } else {
       /* Navigator.of(context).pop();
        Navigator.of(context).pushNamed(
          HomeScreen.routeName,
        );*/
        //SignupUser();
        _dialogforRefer(context);
      }
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  Future<void> _getprimarylocation() async {
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
      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
      index]
      as Map<String, dynamic>)); //store each category values in data list
      for (int i = 0; i < data.length; i++) {
        prefs.setString("deliverylocation", data[i]['area']);
        prefs.setString("branch", data[i]['branch']);
        if (prefs.containsKey("deliverylocation")) {
          Navigator.of(context).pop();
          if (prefs.containsKey("fromcart")) {
            if (prefs.getString("fromcart") == "cart_screen") {
              prefs.remove("fromcart");
              Navigator.of(context).pushNamedAndRemoveUntil(
                  CartScreen.routeName,
                  ModalRoute.withName(HomeScreen.routeName));
            } else {
              //Navigator.of(context).pushReplacementNamed(HomeScreen.routeName,);
              Navigator.pushNamedAndRemoveUntil(
                  context, HomeScreen.routeName, (route) => false);
            }
          } else {
            //Navigator.of(context).pushReplacementNamed(HomeScreen.routeName,);
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.routeName, (route) => false);
          }
        } else {
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
           /* Navigator.of(context).pushReplacementNamed(
              LocationScreen.routeName,
            );*/
          }
         /* Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(
            LocationScreen.routeName,
          );*/
        }
      }
      //Navigator.of(context).pop();
    } catch (error) {
      Navigator.of(context).pop();
      throw error;
    }
  }

  Future<void> facebooklogin() {
    prefs.setString('skip', "no");
    prefs.setString('applesignin', "no");
    initiateFacebookLogin();
  }

  skip() {
    prefs.setString('skip', "yes");
    prefs.setString('applesignin', "no");
    if (prefs.containsKey("deliverylocation")) {
      if (prefs.getString("deliverylocation") != "") {
        if (prefs.containsKey("fromcart")) {
          if (prefs.getString("fromcart") == "cart_screen") {
            prefs.remove("fromcart");
            Navigator.of(context).pushReplacementNamed(
              CartScreen.routeName,
            );
          } else {
            /*Navigator.of(context).pushReplacementNamed(
              HomeScreen.routeName,);*/
            Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.routeName, (route) => false);
          }
        } else {
          /*Navigator.of(context).pushReplacementNamed(
            HomeScreen.routeName,);*/
          Navigator.pushNamedAndRemoveUntil(
              context, HomeScreen.routeName, (route) => false);
        }
      } else {
        prefs.setString("formapscreen", "homescreen");
        Navigator.of(context).pushNamed(MapScreen.routeName);
        /*Navigator.of(context).pushNamed(
          LocationScreen.routeName,
        );*/
      }
    } else {
      prefs.setString("formapscreen", "homescreen");
      Navigator.of(context).pushNamed(MapScreen.routeName);
      /*Navigator.of(context).pushNamed(
        LocationScreen.routeName,
      );*/
    }
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
            final responseJson = json.decode(response.body);
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
                Navigator.of(context).pushReplacementNamed(
                  LoginScreen.routeName,
                );
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
         /* Fluttertoast.showToast(
              msg: "Sign in failed!",
              timeInSecForIos: 2
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
          break;
        case AuthorizationStatus.cancelled:
          Navigator.of(context).pop();
         /* Fluttertoast.showToast(
              msg: "Sign in cancelled by user!",
              timeInSecForIos: 2
              backgroundColor: Colors.black87,
              textColor: Colors.white);*/
          break;
      }
    } else {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Apple SignIn is not available for your device!",
          timeInSecForIos: 2,
          backgroundColor: Colors.black87,
          textColor: Colors.white);
    }
  }


/*  _dialogresetforForgotpass() {
    return _resetpass(context);

  }*/
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
                  height: 350.0,

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
                                       timeInSecForIos: 2
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
                                      timeInSecForIos: 2
                                          backgroundColor: Colors.black87,
                                          textColor: Colors.white);
                                    }*/ /*else if (!regExp.hasMatch(value)) {
                                Fluttertoast.showToast(msg: "Please enter valid Email Address.",
                                timeInSecForIos: 2
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
                          //  _enabled ? _onTap:
                          // clikform();
                          //   _dialogforProcessing();
                          setState(() {
                            _isLoading = true;
                            count + 1;
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
                          /* decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    width: 1.0,
                    color: ColorCodes.greenColor,
                  ),
                ),*/
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
                  height: 240.0,

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
                                    timeInSecForIos: 2,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white);
                              } else if (!regExp.hasMatch(value)) {
                                navigatpass = false;
                                Fluttertoast.showToast(msg: translate('forconvience.Please enter valid Email Address'),//"Please enter valid Email Address.",
                                    backgroundColor: Colors.black87,
                                    timeInSecForIos: 2,
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
                          //  _enabled ? _onTap:
                          // clikform();
                          //   _dialogforProcessing();
                          setState(() {
                            if(navigatpass)
                              _isLoading = true;
                            count + 1;
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor:
      //  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: ColorCodes.whiteColor, // status bar color
    ));
    double deviceWidth = MediaQuery.of(context).size.height;
    int widgetsInRow =  (_isWeb && !ResponsiveLayout.isSmallScreen(context)) ? 2 : 1;

    if (deviceWidth > 1200) {
      widgetsInRow = 1;
    } else if (deviceWidth > 768) {
      widgetsInRow = 1;
    }
    double aspectRatio =   (_isWeb && !ResponsiveLayout.isSmallScreen(context))?
    (deviceWidth - (20 + ((widgetsInRow ) * 10))) / widgetsInRow / 467:
    (deviceWidth - (20 + ((widgetsInRow ) * 10))) / widgetsInRow / 1700;

    return Scaffold(
      body: SafeArea(
        child:
        //     _isLoading?
        //       Center(
        //       child: CircularProgressIndicator(),
        // )
        //     :
      /*  Expanded(
          child: */

          Container(
          //  alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            skip();
                          },
                          child: Container(
                            margin: EdgeInsets.only(top:MediaQuery.of(context).size.height/45,right: 20.0),
                            child: Center(
                                child: Text(
                                  translate('forconvience.SKIP'),// 'SKIP',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: ColorCodes.skipColor),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 30.0, vertical:MediaQuery.of(context).size.height/30),
                      /* width: MediaQuery
                          .of(context)
                          .size
                          .width,*/
                      child: Center(
                        child: Image.asset(
                          Images.logoImg,
                          width: 230.0,
                          height: MediaQuery.of(context).size.height/6,//130.0,
                          fit: BoxFit.scaleDown,

                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Form(
                    key: _form,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                      timeInSecForIos: 2,
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
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height/130, bottom: MediaQuery.of(context).size.height/80),

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
                        KeyboardManager.unFocus(context);
                        //  _enabled ? _onTap:
                        // clikform();
                        //   _dialogforProcessing();
                        setState(() {
                          _isLoading = true;
                          count + 1;
                        });
                        _isLoading
                            ? CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
                        )
                            : prefs.setString('skip', "no");
                        prefs.setString('prevscreen', "mobilenumber");
                        _saveForm();
                      },
                      child:
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width / 1.2,
                        height: 50,
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
                    Column(
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

                            /*if (_isAvailable)
                              Container(
                                margin: EdgeInsets.symmetric(*//*vertical: MediaQuery.of(context).size.height/700,*//* horizontal: 28),
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
                              ),*/
                          ],
                        ),
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
                                         Navigator.of(context)
                                             .pushNamed(SignupScreen.routeName);
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
              ]),
            ),
          ),
       // ),
      ),
    );
  }
}

