import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/IConstants.dart';
import './sellingitemsfields.dart';

class SellingItemsList with ChangeNotifier {
  List<SellingItemsFields> _items = [];
  List<SellingItemsFields> _itemspricevar = [];

  List<SellingItemsFields> _itemsall = [];
  List<SellingItemsFields> _itemspricevarall = [];

  List<SellingItemsFields> _itemsdiscount = [];
  List<SellingItemsFields> _itemspricevardiscount = [];

  List<SellingItemsFields> _itemsnew = [];
  List<SellingItemsFields> _itemspricevarnew = [];

  var featuredname = "";
  var discountedname = "";
  var newitemname = "";

  Future<void> fetchSellingItems() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-featured';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _items.clear();
      _itemspricevar.clear();
      final response = await http
          .post(
          url,
          body: {
            "rows": "2",
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      featuredname = responseJson["label"].toString();

      final dataJson = json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = [];

      dataJsondecode.asMap().forEach((index, value) =>
          data.add(dataJsondecode[index] as Map<String, dynamic>)
      );

      for (int i = 0; i < data.length; i++){

        _items.add(SellingItemsFields(
          id: data[i]['id'].toString(),
          title: data[i]['item_name'].toString(),
          imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
          brand: data[i]['brand'].toString(),
        ));

        final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories


        pricevarJsondecode.asMap().forEach((index, value) =>
            pricevardata.add(pricevarJsondecode[index] as Map<String, dynamic>)
        );

        for (int j = 0; j < pricevardata.length; j++) {
          bool _discointDisplay = false;
          bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

          if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
            _membershipDisplay = false;
          } else {
            _membershipDisplay = true;
          }

          _itemspricevar.add(SellingItemsFields(
            varid: pricevardata[j]['id'].toString(),
            menuid: data[i]['id'].toString(),
            varname: pricevardata[j]['variation_name'].toString(),
            varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
            varprice: pricevardata[j]['price'].toStringAsFixed(2),
            varmemberprice:pricevardata[j]['membership_price'].toStringAsFixed(2),
            varstock: pricevardata[j]['stock'].toString(),
            varminitem: pricevardata[j]['min_item'].toString(),
            varmaxitem: pricevardata[j]['max_item'].toString(),
            varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
            discountDisplay: _discointDisplay,
            membershipDisplay: _membershipDisplay,
          ),);
        }
      }

      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchNewItems(String id) async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-recent-products/' + id;

    try {
      _itemsnew.clear();
      _itemspricevarnew.clear();
      final response = await http
          .get(
        url,
        /*body: {
          "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }*/
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      newitemname = responseJson["label"].toString();

      final dataJson = json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = [];

      dataJsondecode.asMap().forEach((index, value) =>
          data.add(dataJsondecode[index] as Map<String, dynamic>)
      );

      for (int i = 0; i < data.length; i++){
        _itemsnew.add(SellingItemsFields(
          id: data[i]['id'].toString(),
          title: data[i]['item_name'].toString(),
          imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
          brand: data[i]['brand'].toString(),
        ));

        final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories


        pricevarJsondecode.asMap().forEach((index, value) =>
            pricevardata.add(pricevarJsondecode[index] as Map<String, dynamic>)
        );

        for (int j = 0; j < pricevardata.length; j++) {
          bool _discointDisplay = false;
          bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

          if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
            _membershipDisplay = false;
          } else {
            _membershipDisplay = true;
          }

          _itemspricevarnew.add(SellingItemsFields(
            varid: pricevardata[j]['id'].toString(),
            menuid: data[i]['id'].toString(),
            varname: pricevardata[j]['variation_name'].toString(),
            varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
            varprice: pricevardata[j]['price'].toStringAsFixed(2),
            varmemberprice:pricevardata[j]['membership_price'].toStringAsFixed(2),
            varstock: pricevardata[j]['stock'].toString(),
            varminitem: pricevardata[j]['min_item'].toString(),
            varmaxitem: pricevardata[j]['max_item'].toString(),
            varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
            discountDisplay: _discointDisplay,
            membershipDisplay: _membershipDisplay,
          ),);
        }
      }

/*      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]"){
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>)
        );

        for (int i = 0; i < data.length; i++){
          _items.add(SellingItemsFields(
            id: data[i]['id'].toString(),
            title: data[i]['item_name'].toString(),
            imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
            brand: data[i]['brand'].toString(),
          ));

          final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null){

          } else {
            pricevarJsondecode.asMap().forEach((index, value) =>
                pricevardata.add(
                    pricevarJsondecode[index] as Map<String, dynamic>)
            );

            for (int j = 0; j < pricevardata.length; j++) {
bool _discointDisplay = false;
bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

              if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
                _membershipDisplay = false;
              } else {
                _membershipDisplay = true;
              }

              _itemspricevar.add(SellingItemsFields(
                varid: pricevardata[j]['id'].toString(),
                menuid: pricevardata[j]['menu_item_id'].toString(),
                varname: pricevardata[j]['variation_name'].toString(),
                varmrp: pricevardata[j]['mrp'].toString(),
                varprice: pricevardata[j]['price'].toString(),
                varmemberprice:pricevardata[j]['membership_price'].toString(),
                varstock: pricevardata[j]['stock'].toString(),
                varminitem: pricevardata[j]['min_item'].toString(),
                varmaxitem: pricevardata[j]['max_item'].toString(),
                varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
                discountDisplay: _discointDisplay,
                membershipDisplay: _membershipDisplay,
              ));
            }
          }
        }
      }*/

      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAllSellingItems(String seeallpress) async { // imp feature in adding async is the it automatically wrap into Future.
    var url = "";
    if(seeallpress == "featured") {
      url = IConstants.API_PATH + 'restaurant/get-featured';
    } else {
      url = IConstants.API_PATH + 'restaurant/get-discount';
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _itemsall.clear();
      _itemspricevarall.clear();
      final response = await http
          .post(
          url,
          body: {
            "rows": "0",
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );


      final responseJson = json.decode(utf8.decode(response.bodyBytes));

      final dataJson = json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = [];

      dataJsondecode.asMap().forEach((index, value) =>
          data.add(dataJsondecode[index] as Map<String, dynamic>)
      );

      for (int i = 0; i < data.length; i++){
        _itemsall.add(SellingItemsFields(
          id: data[i]['id'].toString(),
          title: data[i]['item_name'].toString(),
          imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
          brand: data[i]['brand'].toString(),
        ));

        final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories


        pricevarJsondecode.asMap().forEach((index, value) =>
            pricevardata.add(pricevarJsondecode[index] as Map<String, dynamic>)
        );


        for (int j = 0; j < pricevardata.length; j++) {
          bool _discointDisplay = false;
          bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

          if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
            _membershipDisplay = false;
          } else {
            _membershipDisplay = true;
          }

          _itemspricevarall.add(SellingItemsFields(
            varid: pricevardata[j]['id'].toString(),
            menuid: data[i]['id'].toString(),
            varname: pricevardata[j]['variation_name'].toString(),
            varmrp: pricevardata[j]['mrp'].toStringAsFixed(2),
            varprice: pricevardata[j]['price'].toStringAsFixed(2),
            varmemberprice:pricevardata[j]['membership_price'].toStringAsFixed(2),
            varstock: pricevardata[j]['stock'].toString(),
            varminitem: pricevardata[j]['min_item'].toString(),
            varmaxitem: pricevardata[j]['max_item'].toString(),
            varLoyalty: pricevardata[j]['loyalty'].toString() == "" ||
                pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
            discountDisplay: _discointDisplay,
            membershipDisplay: _membershipDisplay,
          ),);
        }
      }
      notifyListeners();

    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchDiscountItems() async { // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'restaurant/get-discount';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _itemsdiscount.clear();
      _itemspricevardiscount.clear();
      final response = await http
          .post(
          url,
          body: {
            //"rows": "4",
            "branch": prefs.getString('branch'),
            // await keyword is used to wait to this operation is complete.
          }
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      discountedname = responseJson["label"].toString();
      final dataJson = json.encode(responseJson['data']); //fetching categories data
      final dataJsondecode = json.decode(dataJson);

      List data = [];

      dataJsondecode.asMap().forEach((index, value) =>
          data.add(dataJsondecode[index] as Map<String, dynamic>)
      );

      for (int i = 0; i < data.length; i++){
        _itemsdiscount.add(SellingItemsFields(
          id: data[i]['id'].toString(),
          title: data[i]['item_name'].toString(),
          imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
          brand: data[i]['brand'].toString(),
        ));

        final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
        final pricevarJsondecode = json.decode(pricevarJson);
        List pricevardata = []; //list for subcategories


        pricevarJsondecode.asMap().forEach((index, value) =>
            pricevardata.add(pricevarJsondecode[index] as Map<String, dynamic>)
        );

        for (int j = 0; j < pricevardata.length; j++) {
          bool _discointDisplay = false;
          bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

          if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
            _membershipDisplay = false;
          } else {
            _membershipDisplay = true;
          }

          _itemspricevardiscount.add(SellingItemsFields(
            varid: pricevardata[j]['id'].toString(),
            menuid: data[i]['id'].toString(),
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
          ),);
        }
      }

/*      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson.toString() == "[]"){
      } else {
        List data = [];

        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>)
        );

        for (int i = 0; i < data.length; i++){
          _items.add(SellingItemsFields(
            id: data[i]['id'].toString(),
            title: data[i]['item_name'].toString(),
            imageUrl: IConstants.API_IMAGE + "items/images/" + data[i]['item_featured_image'].toString(),
            brand: data[i]['brand'].toString(),
          ));

          final pricevarJson = json.encode(data[i]['price_variation']); //fetching sub categories data
          final pricevarJsondecode = json.decode(pricevarJson);
          List pricevardata = []; //list for subcategories

          if (pricevarJsondecode == null){

          } else {
            pricevarJsondecode.asMap().forEach((index, value) =>
                pricevardata.add(
                    pricevarJsondecode[index] as Map<String, dynamic>)
            );

            for (int j = 0; j < pricevardata.length; j++) {
bool _discointDisplay = false;
bool _membershipDisplay = false;

          if(double.parse(pricevardata[j]['price'].toString()) <= 0 || pricevardata[j]['price'].toString() == "" || double.parse(pricevardata[j]['price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())){
            _discointDisplay = false;
          } else {
            _discointDisplay = true;
          }

              if(pricevardata[j]['membership_price'].toString() == '-' || pricevardata[j]['membership_price'].toString() == "0" || double.parse(pricevardata[j]['membership_price'].toString()) == double.parse(pricevardata[j]['mrp'].toString())) {
                _membershipDisplay = false;
              } else {
                _membershipDisplay = true;
              }

              _itemspricevar.add(SellingItemsFields(
                varid: pricevardata[j]['id'].toString(),
                menuid: pricevardata[j]['menu_item_id'].toString(),
                varname: pricevardata[j]['variation_name'].toString(),
                varmrp: pricevardata[j]['mrp'].toString(),
                varprice: pricevardata[j]['price'].toString(),
                varmemberprice:pricevardata[j]['membership_price'].toString(),
                varstock: pricevardata[j]['stock'].toString(),
                varminitem: pricevardata[j]['min_item'].toString(),
                varmaxitem: pricevardata[j]['max_item'].toString(),
                pricevardata[j]['loyalty'].toString() == "" ||
                pricevardata[j]['loyalty'].toString() == "null" ? 0 : int.parse(pricevardata[j]['loyalty'].toString()),
                discountDisplay: _discointDisplay,
                membershipDisplay: _membershipDisplay,
              ));
            }
          }
        }
      }*/

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

  List<SellingItemsFields> get itemsall {
    return [..._itemsall];
  }

  List<SellingItemsFields> findByIdall(String menuid) {
    return [..._itemspricevarall.where((pricevar) => pricevar.menuid == menuid)];
  }

  List<SellingItemsFields> get itemsdiscount {
    return [..._itemsdiscount];
  }

  List<SellingItemsFields> findByIddiscount(String menuid) {
    return [..._itemspricevardiscount.where((pricevar) => pricevar.menuid == menuid)];
  }

  List<SellingItemsFields> get itemsnew {
    return [..._itemsnew];
  }

  List<SellingItemsFields> findByIdnew(String menuid) {
    return [..._itemspricevarnew.where((pricevar) => pricevar.menuid == menuid)];
  }
}