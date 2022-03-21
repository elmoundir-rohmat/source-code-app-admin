import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/IConstants.dart';
import '../providers/sellingitemsfields.dart';
import '../providers/categoriesfields.dart';
import '../providers/notificationfield.dart';

class FeaturedCategoryList with ChangeNotifier {
  List<CategoriesFields> _catItems = [];
  List<CategoriesFields> _catOneItems = [];
  List<CategoriesFields> _catTwoItems = [];

  Future<void> fetchCategoryItems(String categoryId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-categories/' + categoryId + "/" + prefs.getString('branch');
    _catItems = [];
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        var list = [Color(0xffC6EEF1), Color(0xffC6F1C6), Color(0xffC6D6F1), Color(0xffE9F1C6), Color(0xffE9F1C6), Color(0xffE1C6F1), Color(0xffC6C7F1)];
        final _random = new Random();

        for (int i = 0; i < data.length; i++) {
        /*for (int i = 0; i < (data.length < 3 ? data.length : 3); i++) {
          Color backgroundColor;
          if(i == 0) {
            backgroundColor = Color(0xffC6EEF1);
          } else if(i == 1) {
            backgroundColor = Color(0xffC6F1C6);
          } else {
            backgroundColor = Color(0xffC6D6F1);
          }*/

          _catItems.add(CategoriesFields(
            catid: data[i]['parentId'].toString(),
            subcatid: data[i]['id'].toString(),
            title: data[i]['category_name'].toString(),
            imageUrl: IConstants.API_IMAGE +
                "sub-category/icons/" +
                data[i]['icon_image'].toString(),
            featuredCategoryBColor: list[_random.nextInt(list.length)],
          ));
        }
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<CategoriesFields> get catitems {
    return [..._catItems];
  }

  Future<void> fetchCategoryOne(String categoryId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-categories/' + categoryId + "/" + prefs.getString('branch');
    _catOneItems = [];
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        var list = [Color(0xffC6EEF1), Color(0xffC6F1C6), Color(0xffC6D6F1), Color(0xffE9F1C6), Color(0xffE9F1C6), Color(0xffE1C6F1), Color(0xffC6C7F1)];
        final _random = new Random();

        for (int i = 0; i < data.length; i++) {
        /*for (int i = 0; i < (data.length < 4 ? data.length : 4); i++) {
          Color backgroundColor;
          if(i == 0) {
            backgroundColor = Color(0xffCFEEF5);
          } else if(i == 1) {
            backgroundColor = Color(0xffCFD9F5);
          } else if(i == 2){
            backgroundColor = Color(0xffCFF5D3);
          } else {
            backgroundColor = Color(0xffF5CFE5);
          }*/

          _catOneItems.add(CategoriesFields(
            catid: data[i]['parentId'].toString(),
            subcatid: data[i]['id'].toString(),
            title: data[i]['category_name'].toString(),
            imageUrl: IConstants.API_IMAGE +
                "sub-category/icons/" +
                data[i]['icon_image'].toString(),
            featuredCategoryBColor: list[_random.nextInt(list.length)],
          ));
        }
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<CategoriesFields> get catOneitems {
    return [..._catOneItems];
  }

  Future<void> fetchCategoryTwo(String categoryId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-categories/' + categoryId + "/" + prefs.getString('branch');
    _catTwoItems = [];
    try {
      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          Color backgroundColor;
          if(i == 0) {
            backgroundColor = Color(0xffC6EEF1);
          } else if(i == 1) {
            backgroundColor = Color(0xffC6F1C6);
          } else if(i == 2) {
            backgroundColor = Color(0xffC6D6F1);
          } else if(i == 3) {
            backgroundColor = Color(0xffE9F1C6);
          } else if(i == 4) {
            backgroundColor = Color(0xffE1C6F1);
          } else {
            backgroundColor = Color(0xffC6C7F1);
          }

          _catTwoItems.add(CategoriesFields(
            catid: data[i]['parentId'].toString(),
            subcatid: data[i]['id'].toString(),
            title: data[i]['category_name'].toString(),
            imageUrl: IConstants.API_IMAGE +
                "sub-category/icons/" +
                data[i]['icon_image'].toString(),
            featuredCategoryBColor: backgroundColor,
          ));
        }
      }

      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<CategoriesFields> get catTwoitems {
    return [..._catTwoItems];
  }

}
