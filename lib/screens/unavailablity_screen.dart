

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/unavailabilitylist.dart';
import '../providers/unavailableproducts_field.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../constants/IConstants.dart';

class unavailability extends StatefulWidget {
  static const routeName = 'unavailability-screen';
  @override
  _unavailabilityState createState() => _unavailabilityState();
}

class _unavailabilityState extends State<unavailability> {
  var productdetails;

  @override
  void initState() {


    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productdetails = Provider.of<unavailabilities>(context,listen: false);
    return Scaffold(
       appBar: AppBar(title: Text(
        translate('forconvience.mybasket') //'My Basket'),
       )),
      body: SingleChildScrollView(
        child: Column(
          children: [
          SizedBox(height: 10,),

            Container(padding: EdgeInsets.all(10),
            child: Text(productdetails.items.length.toString() + 'Products Unavailable'),)
        ],
        ),
      )
       ,
    );
  }
}
