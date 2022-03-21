import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/IConstants.dart';
import '../providers/addressfields.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_translate/flutter_translate.dart';

class AddressItemsList with ChangeNotifier {
  List<AddressFields> _items = [];
  String stringValue;

  Future<void> NewAddress(
      String latitude, String longitude, String branch) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // imp feature in adding async is the it automatically wrap into Future.
    var name;
    var url = IConstants.API_PATH + 'customer/address/add-new';
    try {

      if (prefs.getString('FirstName') != null) {
        if (prefs.getString('LastName') != null) {
          name =
              prefs.getString('FirstName') + " " + prefs.getString('LastName');
        } else {
          name = prefs.getString('FirstName');
        }
      } else {
        name = "";
      }
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
        "addressType": prefs.getString('newaddresstype'),
        "fullName": name,
        "address": prefs.getString('newaddress'),
        "longitude": longitude,
        "latitude": latitude,
        "branch": branch,
        "default":"1"
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw error;
    }
  }

  Future<void> UpdateAddress(String addressid, String latitude,
      String longitude, String branch) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var name;
    var url = IConstants.API_PATH + 'customer/address/update';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString('FirstName') != null) {
        if (prefs.getString('LastName') != null) {
          name =
              prefs.getString('FirstName') + " " + prefs.getString('LastName');
        } else {
          name = prefs.getString('FirstName');
        }
      } else {
        name = "";
      }

      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
        "addressId": addressid,
        "addressType": prefs.getString('newaddresstype'),
        "fullName": name,
        "address": prefs.getString('newaddress'),
        "longitude": longitude,
        "latitude": latitude,
        "branch": branch,
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAddress() async {
    // imp feature in adding async is the it automatically wrap into Future.

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-address';
    try {
      _items.clear();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "customer": prefs.getString('apiKey'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      final dataJson = json.encode(responseJson); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = []; //list for categories

      dataJsondecode.asMap().forEach((index, value) => data.add(dataJsondecode[
              index]
          as Map<String, dynamic>)); //store each category values in data list

      for (int j = 0; j < data.length; j++) {
       // prefs.setString("deliverylocation", data[j]['address'].toString());
       // prefs.setString("lat", data[j]['lattitude'].toString());
      //  prefs.setString("long",data[j]['logingitude'].toString());
        IconData icon;
        if (data[j]['addresstype'].toString().toLowerCase() == "work") {
          data[j]['addresstype'] = translate('forconvience.Work');//"Work";
          icon = Icons.work_outline;
        } else if (data[j]['addresstype'].toString().toLowerCase() == "home") {
          data[j]['addresstype'] =translate('forconvience.Home'); //"Home";
          icon = Icons.home_outlined;
        } else {
          data[j]['addresstype'] = translate('forconvience.Other');//"Other";
          icon = Icons.location_pin;
        }
        _items.add(AddressFields(
          userid: data[j]['id'].toString(),
          useraddtype: data[j]['addresstype'].toString(),
          username: data[j]['customername'].toString(),
          useraddress: data[j]['address'].toString(),
          userlat: data[j]['lattitude'].toString(),
          userlong: data[j]['logingitude'].toString(),
          addressdefault: data[j]['default'].toString(),
          addressicon: icon,
        ));

      }

      //}
      //}
      //}
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Future<void> fetchAddress () async { // imp feature in adding async is the it automatically wrap into Future.
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var url = IConstants.API_PATH + 'customer/get-profile';
  //   //var url = IConstants.API_PATH + 'get-address';
  //   try {
  //     _items.clear();
  //     final response = await http
  //         .post(
  //         url,
  //         body: { // await keyword is used to wait to this operation is complete.
  //           "apiKey": prefs.getString('apiKey'),
  //         }
  //     );
  //
  //     final responseJson = json.decode(utf8.decode(response.bodyBytes));
  //
  //     final dataJson = json.encode(responseJson['data']); //fetching categories data
  //     final dataJsondecode = json.decode(dataJson);
  //
  //
  //     List data = []; //list for categories
  //
  //     dataJsondecode.asMap().forEach((index, value) =>
  //         data.add(dataJsondecode[index] as Map<String, dynamic>)
  //     ); //store each category values in data list
  //
  //     for (int i = 0; i < data.length; i++) {
  //       if (data[i]['billingAddress'].toString() != "[]") {
  //         final addressJson = json.encode(
  //             data[i]['billingAddress']); //fetching sub categories data
  //         final addressJsondecode = json.decode(addressJson);
  //
  //
  //         List addressdata = []; //list for subcategories
  //
  //         if (addressJsondecode == null) {} else {
  //           addressJsondecode.asMap().forEach((index, value) =>
  //               addressdata.add(
  //                   addressJsondecode[index] as Map<String, dynamic>)
  //           ); //store each sub category values in data list
  //
  //           for (int j = 0; j < addressdata.length; j++) {
  //             IconData icon;
  //             prefs.setString("addressId", addressdata[0]['id'].toString());
  //             if (
  //             addressdata[j]['addressType'].toString().toLowerCase() == "work") {
  //               addressdata[j]['addressType'] = "Work";
  //               icon = Icons.work;
  //             } else if (addressdata[j]['addressType'].toString().toLowerCase() == "home") {
  //               addressdata[j]['addressType'] = "Home";
  //               icon = Icons.home;
  //             } else {
  //               addressdata[j]['addressType'] = "Other";
  //               icon = Icons.location_on;
  //             }
  //             _items.add(AddressFields(
  //               userid: addressdata[j]['id'].toString(),
  //               useraddtype: addressdata[j]['addressType'].toString(),
  //               username: addressdata[j]['fullName'].toString(),
  //               useraddress: addressdata[j]['address'].toString(),
  //               userlat: addressdata[j]['lattitude'].toString(),
  //               userlong: addressdata[j]['logingitude'].toString(),
  //               addressicon: icon,
  //             ));
  //           }
  //         }
  //       }
  //     }
  //     notifyListeners();
  //
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  Future<void> setDefaultAddress(String addressid) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'set-default-address';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": addressid,
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw error;
    }
  }

  Future<void> deleteAddress(String addressid) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'customer/address/remove';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "apiKey": prefs.getString('apiKey'),
        "addressId": addressid,
        "branch": prefs.getString('branch'),
      });

      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "true") {
      } else {}
    } catch (error) {
      throw error;
    }
  }

  List<AddressFields> get items {
    return [..._items];
  }
}
