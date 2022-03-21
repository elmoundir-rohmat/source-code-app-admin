import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/IConstants.dart';
import './advertise1fields.dart';


class Advertise1ItemsList with ChangeNotifier {
  List<Advertise1Fields> _items = [];
  List<Advertise1Fields> _items1 = [];
  List<Advertise1Fields> _items2 = [];
  List<Advertise1Fields> _items3 = [];
  List<Advertise1Fields> _items4 = [];
  List<Advertise1Fields> _websiteSlider = [];
  List<Advertise1Fields> _popupbanner = [];
  SharedPreferences prefs;
  Future<void> fetchadvertisecategory1 () async { // imp feature in adding async is the it automatically wrap into Future.
   prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-ads/2/' +  prefs.getString('branch');
    try {
      _items.clear();
      final response = await http
          .get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++)
      {
        _items.add(Advertise1Fields(
          id: data[i]['id'].toString(),
          imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
          bannerFor: data[i]['banner_for'].toString(),
          bannerData: data[i]['data'].toString(),
          clickLink: data[i]['click_link'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAdvertisecategory2 () async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-ads/9/' +  prefs.getString('branch');
    try {
      _items2.clear();
      final response = await http
          .get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++)
      {
        _items2.add(Advertise1Fields(
          id: data[i]['id'].toString(),
          imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
          bannerFor: data[i]['banner_for'].toString(),
          bannerData: data[i]['data'].toString(),
          clickLink: data[i]['click_link'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  Future<void> fetchAdvertisecategory3 () async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-ads/10/' +  prefs.getString('branch');
    try {
      _items3.clear();
      final response = await http
          .get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++)
      {
        _items3.add(Advertise1Fields(
          id: data[i]['id'].toString(),
          imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
          bannerFor: data[i]['banner_for'].toString(),
          bannerData: data[i]['data'].toString(),
          clickLink: data[i]['click_link'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  Future<void> fetchAdvertisementItem1 () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url1 = IConstants.API_PATH + 'restaurant/get-ads/5/' +  prefs.getString('branch');
    try {
      _items1.clear();
      final response = await http
          .get(
        url1,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++){
        _items1.add(Advertise1Fields(
          id: data[i]['id'].toString(),
          imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
          bannerFor: data[i]['banner_for'].toString(),
          bannerData: data[i]['data'].toString(),
          clickLink: data[i]['click_link'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  Future<void> fetchAdvertisementVerticalslider() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url1 = IConstants.API_PATH + 'restaurant/get-ads/11/' +  prefs.getString('branch');
    try {
      _items4.clear();
      final response = await http
          .get(
        url1,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++){
        _items4.add(Advertise1Fields(
          id: data[i]['id'].toString(),
          imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
          bannerFor: data[i]['banner_for'].toString(),
          bannerData: data[i]['data'].toString(),
          clickLink: data[i]['click_link'].toString(),
        ));
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchPopupBanner () async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _isWeb = false;

    try {
      if (Platform.isIOS) {
        _isWeb = false;
      } else {
        _isWeb = false;
      }
    } catch (e) {
      _isWeb = true;
    }

    try {
      _popupbanner.clear();
      var url = IConstants.API_PATH + 'restaurant/get-ads/16/' +  prefs.getString('branch');
      final response = await http.get(url);
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      List data = [];
      responseJson.asMap().forEach((index, value) =>
          data.add(responseJson[index] as Map<String, dynamic>)
      );
      for (int i = 0; i < data.length; i++){
        if(_isWeb){
          if(data[i]['display_for'].toString().contains("0")){//web
            _popupbanner.add(Advertise1Fields(
              id: data[i]['id'].toString(),
              imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
              bannerFor: data[i]['banner_for'].toString(),
              bannerData: data[i]['data'].toString(),
              clickLink: data[i]['click_link'].toString(),
              displayFor: data[i]['display_for'].toString(),
              description: data[i]['description'].toString(),
            ));
          }
        } else {
          if(data[i]['display_for'].toString().contains("1")){//App
            _popupbanner.add(Advertise1Fields(
              id: data[i]['id'].toString(),
              imageUrl: IConstants.API_IMAGE + "banners/banner/" + data[i]['banner_image'].toString(),
              bannerFor: data[i]['banner_for'].toString(),
              bannerData: data[i]['data'].toString(),
              clickLink: data[i]['click_link'].toString(),
              displayFor: data[i]['display_for'].toString(),
              description: data[i]['description'].toString(),
            ));
          }
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  List<Advertise1Fields> get items {
    return [..._items];
  }
  List<Advertise1Fields> get items1 {
    return [..._items1];
  }
  List<Advertise1Fields> get items2 {
    return [..._items2];
  }
  List<Advertise1Fields> get item3 {
    return [..._items3];
  }
  List<Advertise1Fields> get item4 {
    return [..._items4];
  }
  Future<void> websiteSlider() async { // imp feature in adding async is the it automatically wrap into Future.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = IConstants.API_PATH + 'restaurant/get-ads/3/' +  prefs.getString('branch');
    try {
      _websiteSlider.clear();
      final response = await http
          .get(
        url,
      );
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if(responseJson.toString() != "[]") {
        List data = [];
        responseJson.asMap().forEach((index, value) =>
            data.add(responseJson[index] as Map<String, dynamic>)
        );
        for (int i = 0; i < data.length; i++) {
          _websiteSlider.add(Advertise1Fields(
            id: data[i]['id'].toString(),
            imageUrl: IConstants.API_IMAGE + "banners/banner/" +
                data[i]['banner_image'].toString(),
            bannerFor: data[i]['banner_for'].toString(),
            bannerData: data[i]['data'].toString(),
            clickLink: data[i]['click_link'].toString(),
          ));
        }
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
  List<Advertise1Fields> get websiteItems {
    return [..._websiteSlider];
  }

  List<Advertise1Fields> get popupbanner {
    return [..._popupbanner];
  }
}