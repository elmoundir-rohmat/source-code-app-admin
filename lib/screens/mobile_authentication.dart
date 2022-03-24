import 'package:flutter/material.dart';
import '../constants/ColorCodes.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../screens/cart_screen.dart';
import '../constants/IConstants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:async'; // for Timer class
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
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_credential_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/cart_screen.dart';
import '../constants/IConstants.dart';
import '../providers/branditems.dart';
import '../screens/login_screen.dart';
import '../screens/otpconfirm_screen.dart';
import '../screens/confirmorder_screen.dart';
import 'package:flutter_translate/flutter_translate.dart';

class MobileAuthScreen extends StatefulWidget {
  static const routeName = '/mobileauth-screen';
  @override
  _MobileAuthScreenState createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _form = GlobalKey<FormState>();
  bool _isLoading = false;
  int count = 0;
  var countrycode = "";
  SharedPreferences prefs;
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      countrycode = prefs.getString("country_code");
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
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
      Container(
        margin: EdgeInsets.only(left:26,right: 26),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
            /*  Padding(
                padding: const EdgeInsets.only(top:10.0,bottom: 10),

                child: Text(
                  'Personal Details',
                  style: TextStyle(
                      color: ColorCodes.seeallcolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                  // textAlign: TextAlign.center,
                ),
              ),*/
             /* Text(
                'Name',
                style: TextStyle(fontSize: 17, color: ColorCodes.closebtncolor),
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
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly,LengthLimitingTextInputFormatter(12)],
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
             /* Form(
                key: _form,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                     // margin: EdgeInsets.symmetric(vertical: 5,horizontal: 40),
                      child:
                        TextFormField(
                          textAlign: TextAlign.left,
                          keyboardType: TextInputType.number,
                          //controller: namecontroller,
                          decoration: InputDecoration(
                            hintText: 'Enter your mobile number',
                            prefixIcon: Icon(Icons.phone, size: 20,),
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
                            String patttern = r'(^(?:[+0]9)?[0-9]{6,10}$)';
                            RegExp regExp = new RegExp(patttern);
                            if (value.isEmpty) {
                              return 'Please enter a Mobile number.';
                            } else if (!regExp.hasMatch(value)) {
                              return 'Please enter valid mobile number';
                            }
                            return null;
                          },

                          //controller: emailcontroller,
                          //focusNode: emailfocus,


                         *//* decoration: InputDecoration(
                            hintText: 'Enter your mobile number',
                            prefixIcon: Icon(Icons.phone, size: 20,),
                            hoverColor: Colors.green,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),*//*
                          *//*onFieldSubmitted: (_) {
                            // emailfocus.unfocus();
                            //FocusScope.of(context).requestFocus(passwordfocus);
                          },*//*

                          onSaved: (value) {
                          addMobilenumToSF(value);
                          },
                        ),


                    ),


                  ],
                ),


              ),

              Padding(
                padding: const EdgeInsets.only(top:15.0),
                child: Text('We\'ll call or text you to confirm your number.\nStandard message data rates apply.',
                style: TextStyle(color: ColorCodes.textorcallcolor,fontSize: 14),),
              ),*/

              Padding(
                padding: const EdgeInsets.only(top:20.0),
                child:
                GestureDetector(
                  onTap: (){
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
                    FocusScope.of(context).unfocus();
                    _saveForm();
                  },

                  child: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width ,
                    height: 50,
                   // padding: EdgeInsets.all(5.0),

                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(4))
                    ),

                    child: Center(
                      child: Text(
                        translate('forconvience.VERIFY'), //"VERIFY",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,

                            color: ColorCodes.whiteColor),

                      ),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  addMobilenumToSF(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('Mobilenum', value);
  }
  _saveForm() async {
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
          return Fluttertoast.showToast(msg: translate('forconvience.Mobile number already exists'),//"Mobile number already exists!!! Please Try with Different one"
               );
        } else if (responseJson['type'].toString() == "new") {
          prefs.setString('Otp', responseJson['data']['otp'].toString());
          Navigator.of(context).pop();
          //Provider.of<BrandItemsList>(context, listen: false).LoginUser();
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
  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(


          icon: Icon(Icons.arrow_back_ios_outlined, color: ColorCodes.locationColor),


          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
            return Future.value(false);
          }
      ),
      titleSpacing: 0,
      title: Text(
        translate('forconvience.Personal Details'),//'Personal Details',
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
