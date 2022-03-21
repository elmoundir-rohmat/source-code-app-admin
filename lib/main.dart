import 'dart:io';
//import './screens/mobile_authentication.dart';
import 'package:fellahi_e/screens/refer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import './screens/example_screen.dart';
import 'package:provider/provider.dart';
import './screens/mobile_authentication.dart';
import './data/hiveDB.dart';

import './screens/edit_screen.dart';
import './screens/splash_screen.dart';
import './screens/policy_screen.dart';
import './screens/login_screen.dart';
import './screens/otpconfirm_screen.dart';
import './screens/home_screen.dart';
import './screens/subcategory_screen.dart';
import './screens/items_screen.dart';
import './screens/signup_selection_screen.dart';
import './screens/signup_screen.dart';
import './screens/login_credential_screen.dart';
import './screens/category_screen.dart';
import './screens/brands_screen.dart';
import './screens/cart_screen.dart';
import './screens/searchitem_screen.dart';
import './screens/sellingitem_screen.dart';
import './screens/confirmorder_screen.dart';
import './screens/payment_screen.dart';
import './screens/orderconfirmation_screen.dart';
import './screens/address_screen.dart';
import './screens/location_screen.dart';
import './screens/myorder_screen.dart';
import './screens/orderhistory_screen.dart';
import './screens/map_screen.dart';
import './screens/subscription_screen.dart';
import './screens/wallet_screen.dart';
import './screens/shoppinglist_screen.dart';
import './screens/membership_screen.dart';
import './screens/about_screen.dart';
import './screens/addressbook_screen.dart';
import './screens/shoppinglistitems_screen.dart';
import './screens/return_screen.dart';
import './screens/help_screen.dart';
import './screens/privacy_screen.dart';
import './screens/singleproduct_screen.dart';
import './screens/notification_screen.dart';
import './screens/paytm_screen.dart';
import './screens/not_product_screen.dart';
import './screens/not_subcategory_screen.dart';
import './screens/customer_support_screen.dart';
import './screens/introduction_screen.dart';
import './screens/pickup_screen.dart';
import './screens/map_address_screen.dart';
import './screens/singleproductimage_screen.dart';
import './data/calculations.dart';
import './screens/MultipleImagePicker_screen.dart';
import './screens/unavailablity_screen.dart';
import './screens/orderexample.dart';
import './screens/not_brand_screen.dart';
import './screens/banner_product_screen.dart';
import './screens/editOtp_screen.dart';

import './providers/unavailabilitylist.dart';
import './providers/carouselitems.dart';
import './providers/branditems.dart';
import './providers/categoryitems.dart';
import './providers/advertise1items.dart';
import './providers/sellingitems.dart';
import './providers/itemslist.dart';
import './providers/addressitems.dart';
import './providers/deliveryslotitems.dart';
import './providers/myorderitems.dart';
import './providers/membershipitems.dart';
import './providers/notificationitems.dart';
import './providers/categoriesfields.dart';
import './providers/sellingitemsfields.dart';
import './providers/unavailableproducts_field.dart';
import './providers/featuredCategory.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import './constants/IConstants.dart';

const String productBoxName = "product";

Future<void> main() async {
  /*DefaultCacheManager().emptyCache();
  _deleteCacheDir();*/
  WidgetsFlutterBinding.ensureInitialized();

  try {

    if (Platform.isIOS || Platform.isAndroid) {
      final document = await getApplicationDocumentsDirectory();
      Hive.init(document.path);
      Hive.registerAdapter(ProductAdapter());
      await Hive.openBox<Product>(productBoxName);

    }

  } catch (e) {
    Hive.registerAdapter(ProductAdapter());
    await Hive.openBox<Product>(productBoxName);
  }

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) async {
    var delegate = await LocalizationDelegate.create(
        fallbackLocale: 'fr',
        supportedLocales: ['en_US', 'es', 'fr', 'ar']);

    runApp(LocalizedApp(delegate, MyApp()));
    //runApp(MyApp());
  });
}

Future<void> _deleteCacheDir() async {
  final cacheDir = await getTemporaryDirectory();

  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
}

class MyApp extends StatelessWidget {
  static const Color black = Color(0xff2b6838);

  @override
  Widget build(BuildContext context) {
    /*//SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor:
      //  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: Theme.of(context).primaryColor, // status bar color
    ));*/
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    var localizationDelegate = LocalizedApp.of(context).delegate;

    return  LocalizationProvider(
        state: LocalizationProvider.of(context).state,

        child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: CarouselItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: BrandItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: CategoriesItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: Advertise1ItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: SellingItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: ItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: AddressItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: DeliveryslotitemsList(),
              ),
              ChangeNotifierProvider.value(
                value: MyorderList(),
              ),
              ChangeNotifierProvider.value(
                value: MembershipitemsList(),
              ),
              ChangeNotifierProvider.value(
                value: NotificationItemsList(),
              ),
              ChangeNotifierProvider.value(
                value: CategoriesFields(),
              ),
              ChangeNotifierProvider.value(
                value: SellingItemsFields(),
              ),
              ChangeNotifierProvider.value(
                value: Calculations(),
              ),
              ChangeNotifierProvider.value(
                value: unavailabilitiesfield(),
              ),
              ChangeNotifierProvider.value(
                  value: unavailabilities()
              ),
              ChangeNotifierProvider.value(
                  value: FeaturedCategoryList()
              )
            ],
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: IConstants.APP_NAME,
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  localizationDelegate
                ],
                supportedLocales: localizationDelegate.supportedLocales,
                locale: localizationDelegate.fallbackLocale,
                theme: ThemeData(
                  primarySwatch: MaterialColor(0xFF45B343, {
                    50: Color(0xFF45B34C),
                    100: Color(0xFF45B34C),
                    200: Color(0xFF45B34C),
                    300: Color(0xFF45B34C),
                    400: Color(0xFF45B34C),
                    500: Color(0xFF45B34C),
                    600: Color(0xFF45B34C),
                    700: Color(0xFF45B34C),
                    800: Color(0xFF45B34C),
                    900: Color(0xFF45B34C),
                  }),
                  accentColor: MaterialColor(0xFF65DE6C, {
                    50: Color(0xFF65DE6C),
                    100: Color(0xFF65DE6C),
                    200: Color(0xFF65DE6C),
                    300: Color(0xFF65DE6C),
                    400: Color(0xFF65DE6C),
                    500: Color(0xFF65DE6C),
                    600: Color(0xFF65DE6C),
                    700: Color(0xFF65DE6C),
                    800: Color(0xFF65DE6C),
                    900: Color(0xFF65DE6C),
                  }),
                  buttonColor: Colors.white,
                  textSelectionTheme:
                  TextSelectionThemeData(selectionColor: Colors.black),
                  textSelectionColor: Colors.black,
                  backgroundColor: Color(0xffe8e8e8),
                  fontFamily: 'Lato',
                ),
                home: SplashScreenPage(),
                routes: {
                  SignupSelectionScreen.routeName: (ctx) => SignupSelectionScreen(),
                  PolicyScreen.routeName: (ctx) => PolicyScreen(),
                  SignupScreen.routeName: (ctx) => SignupScreen(),
                  LocationScreen.routeName: (ctx) => LocationScreen(),
                  MapScreen.routeName: (ctx) => MapScreen(),
                  LoginScreen.routeName: (ctx) => LoginScreen(),
                  LoginCredentialScreen.routeName: (ctx) => LoginCredentialScreen(),
                  OtpconfirmScreen.routeName: (ctx) => OtpconfirmScreen(),
                  HomeScreen.routeName: (ctx) => HomeScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  SearchitemScreen.routeName: (ctx) => SearchitemScreen(),
                  ConfirmorderScreen.routeName: (ctx) => ConfirmorderScreen(),
                  CategoryScreen.routeName: (ctx) => CategoryScreen(),
                  BrandsScreen.routeName: (ctx) => BrandsScreen(),
                  SellingitemScreen.routeName: (ctx) => SellingitemScreen(),
                  SubcategoryScreen.routeName: (ctx) => SubcategoryScreen(),
                  ItemsScreen.routeName: (ctx) => ItemsScreen(),
                  PaymentScreen.routeName: (ctx) => PaymentScreen(),
                  OrderconfirmationScreen.routeName: (ctx) =>
                      OrderconfirmationScreen(),
                  AddressScreen.routeName: (ctx) => AddressScreen(),
                  MyorderScreen.routeName: (ctx) => MyorderScreen(),
                  OrderhistoryScreen.routeName: (ctx) => OrderhistoryScreen(),
                  WalletScreen.routeName: (ctx) => WalletScreen(),
                  SubscriptionScreen.routeName: (ctx) => SubscriptionScreen(),
                  ShoppinglistScreen.routeName: (ctx) => ShoppinglistScreen(),
                  MembershipScreen.routeName: (ctx) => MembershipScreen(),
                  AboutScreen.routeName: (ctx) => AboutScreen(),
                  AddressbookScreen.routeName: (ctx) => AddressbookScreen(),
                  ReturnScreen.routeName: (ctx) => ReturnScreen(),
                  ShoppinglistitemsScreen.routeName: (ctx) =>
                      ShoppinglistitemsScreen(),
                  MobileAuthScreen.routeName:(ctx) =>
                      MobileAuthScreen(),
                  PrivacyScreen.routeName: (ctx) => PrivacyScreen(),
                  HelpScreen.routeName: (ctx) => HelpScreen(),
                  SingleproductScreen.routeName: (ctx) => SingleproductScreen(),
                  NotificationScreen.routeName: (ctx) => NotificationScreen(),
                  PaytmScreen.routeName: (ctx) => PaytmScreen(),
                  NotProductScreen.routeName: (ctx) => NotProductScreen(),
                  NotSubcategoryScreen.routeName: (ctx) => NotSubcategoryScreen(),
                  CustomerSupportScreen.routeName: (ctx) => CustomerSupportScreen(),
                  NotBrandScreen.routeName: (ctx) => NotBrandScreen(),
                  introductionscreen.routeName: (ctx) => introductionscreen(),
                  // ExampleScreen.routeName: (ctx) => ExampleScreen(),
                  PickupScreen.routeName: (ctx) => PickupScreen(),
                  MapAddressScreen.routeName: (ctx) => MapAddressScreen(),
                  SingleProductImageScreen.routeName: (ctx) => SingleProductImageScreen(),
                  MultipleImagePicker.routeName: (ctx) => MultipleImagePicker(),
                  orderexample.routeName: (ctx) => orderexample(),
                  EditScreen.routeName: (ctx) => EditScreen(),
                  unavailability.routeName: (ctx) => unavailability(),
                  BannerProductScreen.routeName: (ctx) => BannerProductScreen(),
                  EditOtpScreen.routeName: (ctx) => EditOtpScreen(),
                  ExampleScreen.routeName: (ctx) => ExampleScreen(),
                  ReferEarn.routeName: (ctx) => ReferEarn(),
                })));
  }
}
