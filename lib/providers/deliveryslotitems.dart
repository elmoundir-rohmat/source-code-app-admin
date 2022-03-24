import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import 'package:http/http.dart' as http;

import 'deliveryslotfields.dart';
import '../constants/ColorCodes.dart';
import 'package:intl/date_symbol_data_local.dart';

class DeliveryslotitemsList with ChangeNotifier {

 static DateTime date = DateTime.now();
 var date1 = DateTime.now();

 static final now = DateTime.now();
 static final today = DateTime(now.year, now.month, now.day);
 static final tomorrow = DateTime(now.year, now.month, now.day + 1);
 static final dayaftertomorrow = DateTime(now.year, now.month, now.day + 2);

 var prevMonth = new DateTime(date.year, date.month, date.day + 1);
 String finalday;
 String finalmonth;

 List<DeliveryslotFields> _items = [ ];
 List<DeliveryslotFields> _time = [];
 List<DeliveryslotFields> _itemsPickup = [ ];
 var dayformatter,monthformatter;
 Future<void> fetchDeliveryslots (String addressid) async { // imp feature in adding async is the it automatically wrap into Future.
  _items.clear();
  _time.clear();

  var url = IConstants.API_PATH + 'v2-get-delivery-slots';//'get-delivery-slots';
  SharedPreferences prefs = await SharedPreferences.getInstance();

  try {
   _items.clear();
   _time.clear();
   final response = await http
       .post(
       url,
       body: { // await keyword is used to wait to this operation is complete.
        "address": addressid,
        "branch": prefs.getString('branch'),
       }
   );

   final responseJson = json.decode(utf8.decode(response.bodyBytes));
   if(responseJson.toString() == "[]") {

   } else {
    List data = [];
    List frdate=[];
    responseJson.asMap().forEach((index, value) =>
        data.add(responseJson[index] as Map<String, dynamic>)
    );
    var prevdate = "";
    var index = "";
    for (int i = 0; i < data.length; i++) {
     if (prevdate != data[i]['date'].toString()) {
      String locale;

      final f = new DateFormat('dd-MM-yyyy');
      var parsedDate = f.parse(data[i]['date']);

      dayformatter = DateFormat.EEEE('fr');
      monthformatter=DateFormat.MMMd('fr');

      finalday = dayformatter.format(parsedDate).toUpperCase();
      finalmonth=monthformatter.format(parsedDate).toUpperCase();
      List<String> month =finalmonth.split(".");

      var width = 3.0;
      if (i == 0) {
       width = 3.0;
      } else {
       width = 1.0;
      }
      index = i.toString();

      _items.add(DeliveryslotFields(
       id: i.toString(),
       day:finalday.toString(),//DateFormat('EEEEEEE').format(parsedDate).toUpperCase(),
       date: month[0].toString(),//DateFormat('d MMM').format(parsedDate),
       dateformat: data[i]['date'],
       width: width,
      ));


      prevdate = data[i]['date'].toString();
     }

     Color selectedColor;
     Color textColor;
     Color borderColor;
     bool isSelect;
     if(i == 0) {
      selectedColor = Color(0xFF45B343);
      borderColor=  Color(0xFF45B343);
      textColor=ColorCodes.whiteColor;
      isSelect = true;
     } else {
      selectedColor = ColorCodes.whiteColor;
      borderColor= Color(0xffBEBEBE);
      textColor=ColorCodes.blackColor;
      isSelect = false;
     }

     List<String> time = data[i]['time'].toString().split(" - ");
     _time.add(DeliveryslotFields(
      time: DateFormat("HH").format(DateFormat.jm().parse(time[0])).toString() + "h" + DateFormat("mm").format(DateFormat.jm().parse(time[0])).toString() + "-" + DateFormat("HH").format(DateFormat.jm().parse(time[1])).toString() + "h" + DateFormat("mm").format(DateFormat.jm().parse(time[1])).toString(),
      id: index,
      index: i.toString(),
      status:data[i]['status'].toString(),
      /*selectedColor: selectedColor,
      isSelect: isSelect,*/
     ));
    }
   }
   notifyListeners();
  } catch (error) {
   throw error;
  }
 }

 List<DeliveryslotFields> get items {
  return [..._items];
 }

 List<DeliveryslotFields> findById(String timeslotsid) {
  // ignore: unrelated_type_equality_checks
  return [..._time.where((id) => id.id == timeslotsid)];
 }

 List<DeliveryslotFields> get times {
  return [..._time];
 }

 Future<void> fetchPickupslots (String addressid) async { // imp feature in adding async is the it automatically wrap into Future.
  _itemsPickup.clear();

  var url = IConstants.API_PATH + 'get-pickup-slot/$addressid';
  try {
   _itemsPickup.clear();
   final response = await http
       .get(url,);

   final responseJson = json.decode(utf8.decode(response.bodyBytes));
   if(responseJson.toString() == "[]") {

   } else {
    List data = [];

    responseJson.asMap().forEach((index, value) =>
        data.add(responseJson[index] as Map<String, dynamic>)
    );

    for (int i = 0; i < data.length; i++) {
     _itemsPickup.add(DeliveryslotFields(
      date: data[i]['date'].toString(),
      time: data[i]['time'].toString(),
     ));
    }
   }

   notifyListeners();
  } catch (error) {
   throw error;
  }
 }

 List<DeliveryslotFields> get itemsPickup {
  return [..._itemsPickup];
 }

}