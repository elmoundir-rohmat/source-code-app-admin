import 'dart:convert';
import 'dart:async'; // for Timer class
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sms_autofill/sms_autofill.dart';

import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/login_credential_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/cart_screen.dart';
import '../constants/IConstants.dart';

class EditOtpScreen extends StatefulWidget {
  static const routeName = '/editotp-confirm';

  @override
  EditOtpScreenState createState() => EditOtpScreenState();
}

class EditOtpScreenState extends State<EditOtpScreen> {
  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  var _isLoading = false;
  int _timeRemaining = 30;
  var _showCall = false;
  Timer _timer;
  var countrycode = "";
  String otp1, otp2, otp3, otp4;
  TextEditingController controller = TextEditingController();
  var otpvalue = "";
  SharedPreferences prefs;

  @override
  void initState() {
//    LoginUser();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        countrycode = prefs.getString("country_code");
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





  Future<void> UpdateProfile() async {
    // imp feature in adding async is the it automatically wrap into Future.

    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

    var url = IConstants.API_PATH + 'profile/update-customer-profile';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString('userID'),
        "name": routeArgs['firstName'],
        "mobile": routeArgs['mobileNum'],
        "email": routeArgs['email'],
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      debugPrint("response"+responseJson.toString());
      if (responseJson["status"] == 200) {
        prefs.setString('FirstName', routeArgs['firstName']);
        prefs.setString('LastName', "");
        prefs.setString('mobile', routeArgs['mobileNum']);
        prefs.setString('Email', routeArgs['email']);
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

  _verifyOtp() async {
    //var otpval = otp1 + otp2 + otp3 + otp4;
debugPrint("otp value"+otpvalue.toString());
debugPrint("otp pref"+prefs.getString('Otp').toString());
    if (otpvalue == prefs.getString('Otp')) {
      _dialogforProcessing();
      UpdateProfile();
    } else {
      return Fluttertoast.showToast(msg: translate('forconvience.invalidotp')//"Please enter a valid otp!!!"
      );
    }
  }

  Future<void> Otpin30sec() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-30';
    try {

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(response.body);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  Future<void> OtpCall() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'customer/resend-otp-call';
    try {

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "resOtp": prefs.getString('Otp'),
        "mobileNumber": prefs.getString('Mobilenum'),
      });
      final responseJson = json.decode(response.body);
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
//    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;

    return Scaffold(
      body: SafeArea(
        child: Material(
            color: Colors.white,
            child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            child: GestureDetector(
                              onTap: () {
                               Navigator.of(context).pop();
                              },
                              child: new IconButton(
                                color: Theme.of(context).textSelectionColor,
                                icon: new Icon(
                                  Icons.arrow_back,
                                  color: Theme.of(context).textSelectionColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 10.0, 20.0, 0.0),
                        child: RichText(
                          text: new TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent

                            style: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                              height: 2.0,
                            ),
                            children: <TextSpan>[
                              new TextSpan(
                                text: translate('forconvience.Enter verification code'),//'Enter Verification Code',
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20.0),
                          Text(translate('forconvience.We have sent a verification code to'),//"We have sent a verification code to ",
                              style: new TextStyle(fontSize: 16.0)),
                        ],
                      ),
                      SizedBox(height: 10.0,),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 20.0),
                          Text(
                            countrycode + '  ' + routeArgs['mobileNum'],
                            style: new TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 16.0),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.0),
                      Row(children: [
                        SizedBox(
                          width: 21,
                        ),
                        // Auto Sms
                        Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            padding: EdgeInsets.zero,
                            child:

                            // Pinfield controller
                            PinFieldAutoFill(
                              controller: controller,
                              onCodeChanged: (text) {
                                otpvalue = text;
                                SchedulerBinding.instance.addPostFrameCallback(
                                        (_) => setState(() {}));
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
/*                      PinCodeTextField(
//                    autofocus: false,
                      pinBoxRadius: 5,
                      controller: controller,
                      highlight: true,
                      highlightColor: Theme.of(context).primaryColor,
                      defaultBorderColor: Colors.grey,
                      hasTextBorderColor: Colors.grey,
                      maxLength: 4,
                      pinBoxWidth: 70.0,
                      pinBoxHeight: 45.0,



                      onTextChanged: (text) {
                        setState(() {
                          //hasError = false;
                        });
                      },
                      onDone: (text){
                        setState(() {
                          otpvalue = text;
                        });
                      },
                      wrapAlignment: WrapAlignment.center,
                      ),*/
                      SizedBox(
                        height: 25,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 21,
                        ),
                        _showCall == true
                            ? _timeRemaining == 0
                            ? Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width *
                              16 /
                              100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                          ),
                          padding: EdgeInsets.fromLTRB(12, 6, 2, 2),
                          child: GestureDetector(
                              onTap: () {
                                OtpCall();
                                _timeRemaining = 60;
                              },
                              child: Text(
                                'Call',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              )),
                        )
                            : Container(
                          padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                  text: 'Call in',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.green),
                                ),
                                new TextSpan(
                                  text: '   00:$_timeRemaining',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xffdbdbdb),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : _timeRemaining == 0
                            ? Container(
                          height: 30,
                          width: MediaQuery.of(context).size.width *
                              26 /
                              100,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(color: Colors.green)),
                          padding: EdgeInsets.fromLTRB(2, 5, 2, 2),
                          child: GestureDetector(
                              onTap: () {
                                _showCall = true;
                                _timeRemaining += 30;
                                Otpin30sec();
                              },
                              child: Text(
                                translate('forconvience.resendOtp'),//'Resend Otp',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                    color: Colors.white),
                              )),
                        )
                            : Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border.all(color: Colors.green)),
                          padding: EdgeInsets.fromLTRB(2, 2, 2, 2),
                          child: new RichText(
                            text: new TextSpan(
                              // Note: Styles for TextSpans must be explicitly defined.
                              // Child text spans will inherit styles from parent
                              style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                new TextSpan(
                                  text: translate('forconvience.Resend Otp in'),//'Resend Otp in',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white),
                                ),
                                new TextSpan(
                                  text: '   00:$_timeRemaining',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Color(0xffdbdbdb),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ])
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
                                _verifyOtp();
                                _isLoading = true;
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
                                      translate('forconvience.VERIFY'),//"Verify",
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Theme.of(context).buttonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ])
        ),
      ),
    );
  }
}
