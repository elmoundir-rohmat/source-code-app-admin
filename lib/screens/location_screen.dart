import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/map_screen.dart';
import '../constants/images.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LocationScreen extends StatefulWidget {
  static const routeName = '/location-screen';

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  Location location = new Location();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 150.0,),
          Container(
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
            width: MediaQuery.of(context).size.width, height: 190.0,
            child: Center(
              child: Image.asset(
                Images.logoImg,
                width: 200,
                height: 200,
              ),
            ),
          ),
          SizedBox(height: 50.0,),
          Spacer(),
          Container(
            margin: EdgeInsets.only(left: 15.0, right: 15.0),
            child: Center(
              child: Text(
                'Let\'s first check that we deliver to your address',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 40.0,),
          Text(
            'Ready to order from our shop?',
            style: TextStyle(
                fontSize: 10.0,
                color: Colors.grey
            ),
          ),
          GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString("formapscreen", "");
              Navigator.of(context).pushReplacementNamed(MapScreen.routeName);
            },
            child: Container(
                width: 260.0,
                height: 40.0,
                margin: EdgeInsets.only(top: 5.0),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(3.0),
                    border: Border(
                      top: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                      bottom: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                      left: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                      right: BorderSide(width: 1.0, color: Theme.of(context).primaryColor,),
                    )),
                child: Center(
                  child: Text(
                    'SET DELIVERY LOCATION',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),),
                )
            ),
          ),
          SizedBox(height: 60.0,),
        ],
      ),
    );
  }
}