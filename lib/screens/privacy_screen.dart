import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import '../constants/ColorCodes.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../screens/policy_screen.dart';

class PrivacyScreen extends StatefulWidget {
  static const routeName = '/privacy-screen';
  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isLoading = true;
  SharedPreferences prefs;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: gradientappbarmobile(),
        backgroundColor: Colors.white,//Color(0xffe8e8e8),

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
                  SharedPreferences prefs = await SharedPreferences.getInstance();
/*                  prefs.setString('pressed', "termsuse");
                  Navigator.of(context).pushNamed(
                    PolicyScreen.routeName,
                  );*/
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' :translate('forconvience.Privacy Policy'), //"Privacy Policy",
                        'body' : prefs.getString("privacy"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text(translate('forconvience.Privacy Policy'),//"Privacy Policy",
                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),
              SizedBox(height: 5.0,),
           /*   GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' : "Return",
                        'body' : prefs.getString("returnspolicy"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("Return", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),*/
              /*SizedBox(height: 5.0,),
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' : "Refund",
                        'body' : prefs.getString("refund"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("Refund", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),
              SizedBox(height: 5.0,),
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' : "Wallet",
                        'body' : prefs.getString("wallet"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("Wallet", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),
              SizedBox(height: 5.0,),*/
              GestureDetector(
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' :translate('forconvience.Terms and conditions'), //"Terms of Use",
                        'body' : prefs.getString("restaurant_terms"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text(translate('forconvience.Terms and conditions'),//"Terms and conditions",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
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
                  Text(translate('forconvience.App Version'),//"App version",
                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                ],
              ),
              SizedBox(height: 5.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 10.0,),
                  Text("v1.0.0 Live", style: TextStyle(fontSize: 14.0),),
                ],
              ),
              SizedBox(height: 5.0,),
            ],
          ),
        )
    );
  }

  gradientappbarmobile() {
    return  AppBar(
      brightness: Brightness.dark,
      toolbarHeight: 60.0,
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined,size: 20, color: ColorCodes.backbutton),
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
            return Future.value(false);
          }
      ),
      titleSpacing: 0,
      title: Text(
        translate('forconvience.Privacy & Others'),//'Privacy & Others',
        style: TextStyle(fontWeight: FontWeight.normal,color: ColorCodes.backbutton),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  ColorCodes.whiteColor,
                  ColorCodes.whiteColor,
                ]
            )
        ),
      ),
    );
  }
}
