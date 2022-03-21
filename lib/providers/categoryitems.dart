import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import './categoriesfields.dart';

class CategoriesItemsList with ChangeNotifier {
  List<CategoriesFields> _items = [];
  List<CategoriesFields> _itemssubcat = [];
  List<CategoriesFields> _itemNested = [];
  List<CategoriesFields> _itemsubNested = [];
  List<CategoriesFields> _bannerSubcat = [];

  Future<void> fetchCategory() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-categories';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _items.clear();
      _itemssubcat.clear();
      final response = await http
          .post(
          url,
          body: {
            "mode": "getAll",
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.containsKey("data")) {
        final dataJson =
            json.encode(responseJson['data']); //fetching categories data
        final dataJsondecode = json.decode(dataJson);

        List data = []; //list for categories

        dataJsondecode.asMap().forEach((index, value) => data.add(
            dataJsondecode[index] as Map<String,
                dynamic>)); //store each category values in data list

        for (int i = 0; i < data.length; i++) {
          _items.add(CategoriesFields(
            catid: data[i]['id'].toString(),
            title: data[i]['category_name'].toString(),
            imageUrl: IConstants.API_IMAGE +
                "sub-category/icons/" +
                data[i]['icon_image'].toString(),
          )); //add each category values into _items

          final subcatJson = json
              .encode(data[i]['SubCategory']); //fetching sub categories data
          final subcatJsondecode = json.decode(subcatJson);
          List subcatdata = []; //list for subcategories

          if (subcatJsondecode == null) {
          } else {
            subcatJsondecode.asMap().forEach((index, value) => subcatdata.add(
                subcatJsondecode[index] as Map<String,
                    dynamic>)); //store each sub category values in data list

            for (int j = 0; j < subcatdata.length; j++) {
              _itemssubcat.add(CategoriesFields(
                catid: data[i]['id'].toString(),
                subcatid: subcatdata[j]['id'].toString(),
                title: subcatdata[j]['category_name'].toString(),
                imageUrl: IConstants.API_IMAGE +
                    "sub-category/icons/" +
                    subcatdata[j]['icon_image'].toString(),
              ));
            }
          }
        }

        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchNestedCategory(String id, String prevScreen) async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-sub-category/' + id.toString();
    try {
      if (prevScreen == "itemScreen") {
        _itemNested.clear();
      } else if (prevScreen == "subitemScreen") {
        _itemsubNested.clear();
      } else {
        _bannerSubcat.clear();
      }

      final response = await http
          .post(
          url,
          body: { // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() != "[]") {
        List data = []; //list for categories

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        for (int i = 0; i < data.length; i++) {
          if (prevScreen == "itemScreen") {
            _itemNested.add(CategoriesFields(
              catid: data[i]['id'].toString(),
              title: data[i]['category_name'].toString(),
              type: data[i]['type'].toString(),
              imageUrl: IConstants.API_IMAGE +
                  "sub-category/icons/" +
                  data[i]['icon_image'].toString(),
              parentId: data[i]['parentId'].toString(),
            ));
          } else if(prevScreen == "subitemScreen") { //....new subitemScreen.......
            _itemsubNested.add(CategoriesFields(
             catid: data[i]['id'].toString(),
             title: data[i]['category_name'].toString(),
             imageUrl: IConstants.API_IMAGE +
                  "sub-category/icons/" +
                  data[i]['icon_image'].toString(), 
             parentId: data[i]['parentId'].toString(),
            ));
          }else {
            var list = [Color(0xffC6EEF1), Color(0xffC6F1C6), Color(0xffC6D6F1), Color(0xffE9F1C6), Color(0xffE9F1C6), Color(0xffE1C6F1), Color(0xffC6C7F1)];

// generates a new Random object
            final _random = new Random();

// generate a random index based on the list length
// and use it to retrieve the element
            var element = list[_random.nextInt(list.length)];

            if (i != 0) {
              _bannerSubcat.add(CategoriesFields(
                catid: data[i]['id'].toString(),
                title: data[i]['category_name'].toString(),
                type: data[i]['type'].toString(),
                imageUrl: IConstants.API_IMAGE +
                    "sub-category/icons/" +
                    data[i]['icon_image'].toString(),
                parentId: data[i]['parentId'].toString(),
                featuredCategoryBColor: list[_random.nextInt(list.length)],
              ));
            }
          }
        }
        

        notifyListeners();
      }
    } catch (error) {
      throw error;
    }
  }

  List<CategoriesFields> get items {
    return [..._items];
  }

  List<CategoriesFields> get itemssubcat {
    return [..._itemssubcat];
  }

  List<CategoriesFields> get bannerSubcat {
    return [..._bannerSubcat];
  }

  List<CategoriesFields> findById(String catid) {
    return [..._itemssubcat.where((subcat) => subcat.catid == catid)];
  }

  List<CategoriesFields> get itemNested {
    return [..._itemNested];
  }

  List<CategoriesFields> get itemsubNested {
    return [..._itemsubNested];
  }
}
