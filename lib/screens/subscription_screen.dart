import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SubscriptionScreen extends StatefulWidget {
  static const routeName = '/subscription-screen';
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    return SafeArea(
      child: Scaffold(
          appBar: GradientAppBar(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
            ),
            title: Text(
              "Subscription",
            ),
          ),
//        drawer: AppDrawer(),
          backgroundColor: Colors.white,//Theme.of(context).backgroundColor,
          body: Center(
            child: Text(
              "Coming soon...",
              style: TextStyle(
                  fontSize: 25.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold
              ),
            ),
          )
      ),
    );
  }
}
