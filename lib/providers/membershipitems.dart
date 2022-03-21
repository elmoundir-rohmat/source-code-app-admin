import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import '../providers/membershipfields.dart';

class MembershipitemsList with ChangeNotifier {
  List<MembershipFields> _items = [];
  List<MembershipFields> _typesitems = [];

  Future<void> Getmembership () async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'get-membership';
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      _items.clear();
      _typesitems.clear();
      var membershiptext = "Select";
      var membershipbackground = Color(0xff35a2df);
      var membershiptextcolor = Colors.white;

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['data'].toString() != "[]") {
        final dataJson = json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);


        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) =>
            data.add(dataJsondecode[index] as Map<String, dynamic>)
        ); //store each category values in data list

        for (int i = 0; i < data.length; i++){
          _items.add(MembershipFields(
            name: data[i]['name'].toString(),
            description: data[i]['description'].toString(),
            avator: IConstants.API_IMAGE + data[i]['avator'].toString(),

          ));

          final membertypesJson = json.encode(data[i]['types']); //fetching sub categories data
          final membertypesJsondecode = json.decode(membertypesJson);
          List pricevardata = []; //list for subcategories

          if (membertypesJsondecode == null){

          } else {
            membertypesJsondecode.asMap().forEach((index, value) =>
                pricevardata.add(
                    membertypesJsondecode[index] as Map<String, dynamic>)
            );
            for (int j = 0; j < pricevardata.length; j++) {
              _typesitems.add(MembershipFields(
                typesid: pricevardata[j]['id'].toString(),
                typesexpdate:pricevardata[j]['expiry_date'].toString(),
                typesname: pricevardata[j]['name'].toString(),
                typesprice: pricevardata[j]['price'].toString(),
                typesdiscountprice: pricevardata[j]['discounted_price'].toString(),
                typesduration: pricevardata[j]['duration'].toString(),
                text: membershiptext,
                backgroundcolor: membershipbackground,
                textcolor: membershiptextcolor,
              ));
            }
          }
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> Getmembershipdetails () async { // imp feature in adding async is the it automatically wrap into Future.

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var url = IConstants.API_PATH + 'get-membership_detail';
    try {

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "userid": prefs.getString('userID'),
            "branch": prefs.getString('branch'),
          }
      );

      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      if (responseJson.toString() != "[]") {
        prefs.setString("orderid", responseJson['orderId']);
        prefs.setString("orderdate", responseJson['orderDate']);
        prefs.setString("expirydate", responseJson['expiry_date']);
        prefs.setString("membershipname", responseJson['name']);
        prefs.setString("duration", responseJson['duration']);
        prefs.setString("membershipprice", responseJson['price']);
        prefs.setString("membershipaddress", responseJson['address']);
        prefs.setString("memebershippaytype", responseJson['paymentType']);
        prefs.setString("membershipuser", responseJson['user']);

      }
    } catch (error) {
      throw error;
    }
  }

  List<MembershipFields> get items {
    return [..._items];
  }

  List<MembershipFields> get typesitems {
    return [..._typesitems];
  }


}