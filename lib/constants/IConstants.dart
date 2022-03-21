import 'package:flutter/material.dart';

class IConstants {
/*  static String API_PATH = "https://admin.grocbay.com/api/app-manager/get-functionality/";
  static String API_IMAGE = "https://admin.grocbay.com/uploads/";*/



   /*static String API_PATH = "https://login.grocbay.com/api/app-manager/get-functionality/";
   static String API_IMAGE = "https://login.grocbay.com/uploads/";*/
  static String API_PATH = "https://login.fellahi.ma/api/app-manager/get-functionality/";
  static String API_IMAGE = "https://login.fellahi.ma/uploads/";

  // static String API_PATH = "https://test.fellahi.ma/api/app-manager/get-functionality/";
  // static String API_IMAGE = "https://test.fellahi.ma/uploads/";

 /* static String API_PATH = "https://multi.grocbay.com/api/app-manager/get-functionality/";
  static String API_IMAGE = "https://multi.grocbay.com/uploads/";*/
  static String APP_NAME = "Fellahi";
  static String API_PAYTM = "https://pay.fellahi.ma/";

  static String appleId = "1563407384";
  static String androidId = "com.fellahi.store";

  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  //static  ValueNotifier<String> deliverylocationmain;
  static final deliverylocationmain =
  ValueNotifier<String>("");
  static final currentdeliverylocation =
  ValueNotifier<String>("");
}
