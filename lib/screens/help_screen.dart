import 'package:flutter/material.dart';
import '../screens/customer_support_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fellahi_e/constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/help-screen';
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _isLoading = true;
  SharedPreferences prefs;
  var name = "", email = "", photourl = "", phone = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoading = false;
        if (prefs.getString('FirstName') != null) {
          if (prefs.getString('LastName') != null) {
            name =  prefs.getString('FirstName') + " " + prefs.getString('LastName');
          } else {
            name =  prefs.getString('FirstName');
          }
        } else {
          name = "";
        }

        if (prefs.getString('Email') != null) {
          email = prefs.getString('Email');
        } else {
          email = "";
        }

        if (prefs.getString('mobile') != null) {
          phone = prefs.getString('mobile');
        } else {
          phone = "";
        }

        if (prefs.getString('photoUrl') != null) {
          photourl = prefs.getString('photoUrl');
        } else {
          photourl = "";
        }
      });
    });
    //initPlatformState();
    super.initState();
  }

  /*Future<void> initPlatformState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstname = prefs.getString("FirstName");
    String lastname = prefs.getString("LastName");
    String email = prefs.getString("Email");
    String countrycode = prefs.getString("country_code");
    String phone = prefs.getString("mobile");

    var response = await FlutterFreshchat.init(
      appID: "80f986ff-2694-4894-b0c5-5daa836fef5c",
      appKey: "b1f41ae0-f004-43c2-a0a1-79cb4e03658a",
      cameraEnabled: true,
      gallerySelectionEnabled: false,
      teamMemberInfoVisible: false,
      responseExpectationEnabled: false,
      showNotificationBanner: true,
    );
    FreshchatUser user = FreshchatUser.initail();
    user.email = email;
    user.firstName = firstname;
    user.lastName = lastname;
    user.phoneCountryCode = countrycode;
    user.phone = phone;

    await FlutterFreshchat.updateUserInfo(user: user);
    // Custom properties can be set by creating a Map<String, String>
    Map<String, String> customProperties = Map<String, String>();
    customProperties["loggedIn"] = "true";

    await FlutterFreshchat.updateUserInfo(user: user, customProperties: customProperties);



    //await FlutterFreshchat.updateUserInfo(user: FreshchatUser);
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [ ColorCodes.whiteColor,
                ColorCodes.whiteColor,]
          ),
          title: Text(
            translate('forconvience.HELP'),
          ),
        ),
        backgroundColor: Colors.white,

        body: _isLoading ? Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        ) : SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 30.0,),
              GestureDetector(
                onTap: () async {
                  //var response = await FlutterFreshchat.showConversations();
                  Navigator.of(context).pushNamed(
                      CustomerSupportScreen.routeName,
                      arguments: {
                        'name' : name,
                        'email' : email,
                        'photourl': photourl,
                        'phone' : phone,
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("Chat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),
              SizedBox(height: 5.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 10.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Call", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                      SizedBox(height: 5.0,),
                      Text(prefs.getString("primary_mobile"), style: TextStyle(fontSize: 14.0),),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      launch("tel: " + prefs.getString("primary_mobile"));
                    },
                      child: Icon(Icons.call, color: Theme.of(context).primaryColor, size: 30.0,),
                  ),
                  SizedBox(width: 10.0,),
                ],
              ),
              SizedBox(height: 5.0,),
              Divider(),
              SizedBox(height: 5.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 10.0,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                      SizedBox(height: 5.0,),
                      Text(prefs.getString("primary_email"), style: TextStyle(fontSize: 14.0),),
                      SizedBox(height: 5.0,),
                      Text(prefs.getString("secondary_email"), style: TextStyle(fontSize: 14.0),),
                    ],
                  ),
                  SizedBox(width: 5.0,),
                ],
              ),
            ],
          ),
        )
    );
  }
}
