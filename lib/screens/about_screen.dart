import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import '../screens/policy_screen.dart';

class AboutScreen extends StatefulWidget {
  static const routeName = '/about-screen';
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
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
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  Navigator.of(context).pushNamed(
                      PolicyScreen.routeName,
                      arguments: {
                        'title' : "About Us",
                        'body' : prefs.getString("description"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("About Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
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
                        'title' : "Contact Us",
                        'body' : "",
                        'businessname': prefs.getString("restaurant_name"),
                        'address': prefs.getString("restaurant_address"),
                        'contactnum': prefs.getString("primary_mobile"),
                        'pemail': prefs.getString("primary_email"),
                        'semail': prefs.getString("secondary_email"),
                      }
                  );
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10.0,),
                    Text("Contact Us", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right, color: Colors.grey,),
                    SizedBox(width: 5.0,),
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              Divider(),
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
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).popUntil(ModalRoute.withName(HomeScreen.routeName,));
            return Future.value(false);
          }
      ),
      titleSpacing: 0,
      title: Text(
        'About',
        style: TextStyle(fontWeight: FontWeight.normal),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Theme
                      .of(context)
                      .accentColor,
                  Theme
                      .of(context)
                      .primaryColor
                ]
            )
        ),
      ),
    );
  }
}
