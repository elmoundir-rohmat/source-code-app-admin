import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/ColorCodes.dart';
import '../providers/brandfields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../constants/IConstants.dart';
import '../providers/sellingitemsfields.dart';
import '../providers/categoriesfields.dart';
import '../providers/notificationfield.dart';

class NotificationItemsList with ChangeNotifier {
  List<SellingItemsFields> _items = [];
  List<SellingItemsFields> _itemspricevar = [];
  List<CategoriesFields> _bannerSubcat = [];
  List<CategoriesFields> _catItems = [];
  List<NotificationFields> _notItems = [];
  List<NotificationFields> _notUpdate = [];
  List<BrandsFields> _brandItems = [];
  Color featuredCategoryBColor;

  Future<void> fetchProductItems(String productId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-items/' + productId;
    _items = [];
    _itemspricevar = [];
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
          _items.add(SellingItemsFields(
            id: data[i]['id'].toString(),
            title: data[i]['item_name'].toString(),
            imageUrl: IConstants.API_IMAGE +
                "items/images/" +
                data[i]['item_featured_image'].toString(),
            brand: data[i]['brand'].toString(),
          ));

          final pricevarJson = json.encode(
              data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null) {
          } else {
            pricevarJsondecode.asMap().forEach((index, value) => pricevardata
                .add(pricevarJsondecode[index] as Map<String, dynamic>));

            for (int j = 0; j < pricevardata.length; j++) {
              final multiimagesJson = json.encode(
                  pricevardata[j]['images']); //fetching sub categories data
              final multiimagesJsondecode = json.decode(multiimagesJson);
              List multiimagesdata = [];
              String imageurl = "";

              if (multiimagesJsondecode.toString() == "[]") {
                imageurl = IConstants.API_IMAGE +
                    "items/images/" +
                    data[i]['item_featured_image'].toString();
              } else {
                multiimagesJsondecode.asMap().forEach((index, value) =>
                    multiimagesdata.add(
                        multiimagesJsondecode[index] as Map<String, dynamic>));
                imageurl = IConstants.API_IMAGE +
                    "items/images/" +
                    multiimagesdata[0]['image'].toString();
              }
              bool _discointDisplay = false;
              bool _membershipDisplay = false;

              if (double.parse(pricevardata[j]['price'].toString()) <= 0 ||
                  pricevardata[j]['price'].toString() == "" ||
                  double.parse(pricevardata[j]['price'].toString()) ==
                      double.parse(pricevardata[j]['mrp'].toString())) {
                _discointDisplay = false;
              } else {
                _discointDisplay = true;
              }
              if (pricevardata[j]['membership_price'].toString() == '-' ||
                  pricevardata[j]['membership_price'].toString() == "0") {
                _membershipDisplay = false;
              } else {
                _membershipDisplay = true;
              }

              _itemspricevar.add(SellingItemsFields(
                varid: pricevardata[j]['id'].toString(),
                menuid: pricevardata[j]['menu_item_id'].toString(),
                varname: pricevardata[j]['variation_name'].toString(),
                varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
                varprice: pricevardata[j]['price'].toStringAsFixed(2),
                varmemberprice: pricevardata[j]['membership_price'].toStringAsFixed(2),
                varstock: pricevardata[j]['stock'].toString(),
                varminitem: pricevardata[j]['min_item'].toString(),
                varmaxitem: pricevardata[j]['max_item'].toString(),
                varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                    pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
                discountDisplay: _discointDisplay,
                membershipDisplay: _membershipDisplay,
                imageUrl: imageurl,
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

  List<SellingItemsFields> get items {
    return [..._items];
  }

  List<SellingItemsFields> findById(String menuid) {
    return [..._itemspricevar.where((pricevar) => pricevar.menuid == menuid)];
  }

  Future<void> fetchCategoryItems(String categoryId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-categories/' + categoryId + "/" + prefs.getString('branch');
    _catItems = [];
    try {
      final response = await http
          .post(
          url,
          body: {
            "mode": "getAll",// await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));
        var list = [
          Color(0xffC6EEF1),
          Color(0xffC6F1C6),
          Color(0xffC6D6F1),
          Color(0xffE9F1C6),
          Color(0xffE9F1C6),
          Color(0xffE1C6F1),
          Color(0xffC6C7F1),
        ];

// generates a new Random object
        final _random = new Random();

// generate a random index based on the list length
// and use it to retrieve the element
        var element = list[_random.nextInt(list.length)];

        for (int i = 0; i < data.length; i++) {
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

  Future<void> fetchBrandsItems(String brandsId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-brands-data/' + brandsId;
    _catItems = [];
    try {
      _brandItems.clear();
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "branch": prefs.getString('branch')
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
//      var idlist = responseJson.map<int>((m) => m['id'] as int).toList();
//      var imagelist = responseJson.map<String>((m) => m['banner_image'] as String).toList();

      var data = [];

      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>));
      Color boxbackcolor;
      Color boxsidecolor;
      Color textcolor;
      for (int i = 0; i < data.length; i++) {
        if (i != 0)         {
          boxbackcolor = ColorCodes.mediumBlackColor;
          boxsidecolor = ColorCodes.blackColor;
          textcolor = ColorCodes.blackColor;
        } else {
          boxbackcolor = ColorCodes.mediumBlueColor;
          boxsidecolor = ColorCodes.mediumBlueColor;
          textcolor = ColorCodes.whiteColor;
        }
        _brandItems.add(BrandsFields(
          id: data[i]['id'].toString(),
          title: data[i]['category_name'].toString(),
          imageUrl: IConstants.API_IMAGE +
              "sub-category/icons/" +
              data[i]['icon_image'].toString(),
          // featuredCategoryBColor: list[_random.nextInt(list.length)]
          boxbackcolor: boxbackcolor,
          boxsidecolor: boxsidecolor,
          textcolor: textcolor,
        ));

      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<BrandsFields> get brands {
    return [..._brandItems];
  }

  Future<void> fetchNotificationLogs(String userId) async {
    // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'get-notification/$userId/' + prefs.getString("branch");
    _notItems = [];
    try {
      final response = await http.get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]") {
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>));

        int unreadCount = 0;
        for (int i = 0; i < data.length; i++) {
          if (data[i]['status'].toString() == "0") unreadCount++;
          _notItems.add(NotificationFields(
            id: data[i]['id'].toString(),
            title: data[i]['title'].toString(),
            status: data[i]['status'].toString(),
            date: data[i]['date'].toString(),
            notificationFor: data[i]['notificationFor'].toString(),
            dateTime: data[i]['dateTime'].toString(),
            data: data[i]['data'].toString(),
            message: data[i]['message'].toString(),
            unreadcount: unreadCount,
          ));
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<NotificationFields> get notItems {
    return [..._notItems];
  }

  Future<void> updateNotificationStatus(
      String notificationId, String status) async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'update-notification/' + notificationId + "/" + status;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final response = await http
          .post(
          url,
          body: {
            // await keyword is used to wait to this operation is complete.
            "branch": prefs.getString('branch'),
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "200") {}
    } catch (error) {
      throw error;
    }
  }
}
