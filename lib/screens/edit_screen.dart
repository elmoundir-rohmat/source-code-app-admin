import 'dart:io';

import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'dart:convert';

import '../screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import '../screens/editOtp_screen.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';

class EditScreen extends StatefulWidget {
  static const routeName = '/edit-screen';

  @override
  EditScreenState createState() => EditScreenState();
}

class EditScreenState extends State<EditScreen> {
  final _lnameFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String fn = "";
  String ln = "";
  String ea = "";
  String mb = "";
  var name = "", email = "", phone = "";
  SharedPreferences prefs;
  bool _isWeb = false;
  var _address = "";
  var otpvalue = "";
  final TextEditingController firstnamecontroller = new TextEditingController();
  final TextEditingController mobileNumberController = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();

  @override
  void initState() {
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
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
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

        if (prefs.getString('mobile') != null) {
          phone = prefs.getString('mobile');

        } else {
          phone = "";
        }
        if (prefs.getString('Email') != null) {
          email = prefs.getString('Email');
        } else {
          email = "";
        }
        firstnamecontroller.text = name;
        mobileNumberController.text = phone;
        emailController.text = email;
      });
    });
    super.initState();
  }

  /*Future<void> _checkMobilenum() async { // imp feature in adding async is the it automatically wrap into Future.
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
      final responseJson = json.decode(response.body);
      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          return Fluttertoast.showToast(msg: "Mobile Number already exists!");
        } else if (responseJson['type'].toString() == "new") {
          Navigator.of(context).pop();
          _getOtp(mobileNumberController.text);
          Navigator.of(context).pushNamed(EditOtpScreen.routeName,
              arguments: {
                "firstName": firstnamecontroller.text,
                "mobileNum": mobileNumberController.text,
                "email": emailController.text,
              });
        }
      } else {
        return Fluttertoast.showToast(msg: "Something went wrong!!!");
      }

    } catch (error) {
      setState(() {
      });
      throw error;
    }
  }*/

  Future<void> _getOtp(String mobile) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/pre-register';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "mobileNumber": mobile,
        "tokenId": prefs.getString('tokenid'),
        "signature": prefs.containsKey("signature") ? prefs.getString('signature') : "",
      });
      final responseJson = json.decode(response.body);
      final data = responseJson['data'] as Map<String, dynamic>;


      if (responseJson['status'].toString() == "true") {
        if(responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          return Fluttertoast.showToast(msg: translate('forconvience.Mobile number already exists') //"Mobile Number already exists!"
          );
        } else {
          Navigator.of(context).pop();
          prefs.setString('Otp', data['otp'].toString());
          Navigator.of(context).pushNamed(EditOtpScreen.routeName,
              arguments: {
                "firstName": firstnamecontroller.text,
                "mobileNum": mobileNumberController.text,
                "email": emailController.text,
              });
        }
//        Navigator.of(context).pushNamed(
//          OtpconfirmScreen.routeName,
//        );

      } else if (responseJson['status'].toString() == "false") {}
    } catch (error) {
      throw error;
    }
  }

  Future<void> UpdateProfile() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'profile/update-customer-profile';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString('userID'),
        "name": firstnamecontroller.text,
        "mobile": mobileNumberController.text,
        "email": emailController.text,
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson["status"] == 200) {
        prefs.setString('FirstName', firstnamecontroller.text);
        prefs.setString('LastName', "");
        prefs.setString('mobile', mobileNumberController.text);
        prefs.setString('Email', emailController.text);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "Something went wrong",
            backgroundColor: Colors.black87,
            textColor: Colors.white);
      }
    } catch (error) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
          msg: "Something went wrong",
          backgroundColor: Colors.black87,
          textColor: Colors.white);
      throw error;
    }
  }

  @override
  void dispose() {
    firstnamecontroller.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    super.dispose();
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

  _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    } //it will check all validators
    _form.currentState.save();

    if(mobileNumberController.text == prefs.getString("mobile")) {
      _dialogforProcessing();
      UpdateProfile();
    } else {
      _dialogforProcessing();
      checkMobilenum();
      //_getOtp(mobileNumberController.text);
      /* Navigator.of(context).pushNamed(EditOtpScreen.routeName,
          arguments: {
            "firstName": firstnamecontroller.text,
            "mobileNum": mobileNumberController.text,
            "email": emailController.text,
          });*/
    }
  }


  Future<void> checkMobilenum() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/pre-registerwotp';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "mobileNumber": mobileNumberController.text.toString(),//prefs.getString('Mobilenum'),
            "tokenId": prefs.getString('tokenid'),
            "signature":prefs.containsKey("signature") ? prefs.getString('signature') : ""
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "true") {
        if (responseJson['type'].toString() == "old") {
          Navigator.of(context).pop();
          return Fluttertoast.showToast(msg: translate('forconvience.Mobile number already exists'),//"Mobile number already exists!!! Please Try with Different one"
          );
        } else if (responseJson['type'].toString() == "new") {

          prefs.setString('Otp', responseJson['data']['otp'].toString());
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(EditOtpScreen.routeName,
              arguments: {
                "firstName": firstnamecontroller.text,
                "mobileNum": mobileNumberController.text,
                "email": emailController.text,
              });
          //Provider.of<BrandItemsList>(context, listen: false).LoginUser();
         // return _getOtp(mobileNumberController.text);
            /*Navigator.of(context).pushNamed(
            OtpconfirmScreen.routeName,
          );*/
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: ResponsiveLayout.isSmallScreen(context) ?
      gradientappbarmobile() : null,
      backgroundColor: ColorCodes.whiteColor,
      body:  Column(
        children: <Widget>[
          if(_isWeb && !ResponsiveLayout.isSmallScreen(context))
            Header(false),
          _body(),
        ],
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() : _bottomNavigationBar(),
    );
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
              translate('forconvience.Update Profile'),
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
  _body(){
    return Expanded(
      child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(

                margin: EdgeInsets.only(top: 30.0),
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                         translate('forconvience.What should we call you ?'),
                        style: TextStyle(fontSize: 17, color: ColorCodes.closebtncolor),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.left,
                        controller: firstnamecontroller,
                        decoration: InputDecoration(
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
                              fn = translate('forconvience.please enter name');//"  Please enter name";
                            });
                            return '';
                          }
                          setState(() {
                            fn = "";
                          });
                          return null;
                        },
                        onSaved: (value) {
                          //addFirstnameToSF(value);
                        },
                      ),
                      Text(
                        fn,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        translate('forconvience.Mobile number '),
                        style: TextStyle(fontSize: 17, color: ColorCodes.closebtncolor),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.number,
                        controller: mobileNumberController,
                        style: new TextStyle(
                            decorationColor: Theme.of(context).primaryColor),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(12)],
                        decoration: InputDecoration(
                          hintText: translate('forconvience.Mobile number '),//'Your number',
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
                            borderSide:
                            BorderSide(color: Colors.green, width: 1.2),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              mb = translate('forconvience.Please enter your mobile number'); //"  Please enter number";
                            });
                            return '';
                          }
                          setState(() {
                            mb = "";
                          });
                          return null;
                        },
                        onSaved: (value) {
                          //addEmailToSF(value);
                        },
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        mb,
                        textAlign: TextAlign.left,
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        translate('forconvience.Tell us your e-mail'),
                        style: TextStyle(fontSize: 17, color: ColorCodes.closebtncolor),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        style: new TextStyle(
                            decorationColor: Theme.of(context).primaryColor),
                        decoration: InputDecoration(
                          hintText: translate('forconvience.Tell us your e-mail'),//'xyz@gmail.com',
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
                            borderSide:
                            BorderSide(color: Colors.green, width: 1.2),
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
                              ea = translate('forconvience.Please enter valid Email Address');//' Please enter a valid email address';
                            });
                            return '';
                          }
                          setState(() {
                            ea = "";
                          });
                          return null; //it means user entered a valid input
                        },
                        onSaved: (value) {
                          // addEmailToSF(value);
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
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              if(_isWeb)_bottomNavigationBar(),
              SizedBox(height: 30,),
              if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Footer(address: _address),
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
    );


  }
gradientappbarmobile() {
  return  AppBar(
    brightness: Brightness.dark,
    toolbarHeight: 60.0,
    elevation: 1,
    automaticallyImplyLeading: false,
    leading: IconButton(icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),onPressed: ()=>Navigator.of(context).pop()),
    title: Text(translate('forconvience.Edit Profile'),
      style: TextStyle(fontWeight: FontWeight.bold),
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
              ]
          )
      ),
    ),
  );
}
}
