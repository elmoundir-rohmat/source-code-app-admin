import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import '../screens/myorder_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/featuredCategory.dart';
import '../widgets/floatbuttonbadge.dart';
import '../screens/example_screen.dart';
import '../screens/MultipleImagePicker_screen.dart';
import '../screens/cart_screen.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/categoryOne.dart';
import '../widgets/categoryThree.dart';
import '../widgets/expandable_categories.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import '../widgets/websiteSlider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../widgets/items.dart';
import '../widgets/app_drawer.dart';
import '../widgets/carousel_sliderimage.dart';
import '../widgets/brands_items.dart';
import '../widgets/advertise1_items.dart';
import '../widgets/badge.dart';

import '../providers/addressitems.dart';
import '../providers/carouselitems.dart';
import '../providers/branditems.dart';
import '../providers/categoryitems.dart';
import '../providers/advertise1items.dart';
import '../providers/sellingitems.dart';
import '../providers/membershipitems.dart';

import '../constants/images.dart';
import '../screens/map_screen.dart';
import '../screens/sellingitem_screen.dart';
import '../screens/category_screen.dart';
import '../screens/shoppinglist_screen.dart';
import '../screens/wallet_screen.dart';
import '../constants/IConstants.dart';
import '../screens/membership_screen.dart';
import '../screens/signup_selection_screen.dart';
import '../providers/notificationitems.dart';
import '../constants/ColorCodes.dart';
import '../widgets/categoryTwo.dart';
import '../data/calculations.dart';
import '../data/hiveDB.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';

import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:location/location.dart' as loc;

import 'package:search_map_place/search_map_place.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_translate/flutter_translate.dart';

import 'customer_support_screen.dart';

enum SingingCharacter { english, arabic }

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';

  static GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _address = "";
  double _lat, _lng;
  Position position;
  int count = 0;
  bool iphonex = false;
  bool _isDelivering = true;

  bool _isWebsiteSlider = false;
  bool _isWebsiteShimmer = true;

  bool _isCaroselSlider = false;
  bool _isCaroselShimmer = true;

  bool _isCategoryOne = false;
  bool _isCategoryOneShimmer = true;

  bool _isAdsCategoryOne = false;
  bool _isAdsCategoryOneShimmer = true;

  bool _isFeatured = false;
  bool _isFeaturedShimmer = true;

  bool _isFeaturedAdsOne = false;
  bool _isFeaturedAdsOneShimmer = true;

  bool _isCategoryTwo = false;
  bool _isCategoryTwoShimmer = true;

  bool _isFeaturedAdsTwo = false;
  bool _isFeaturedAdsTwoShimmer = true;

  bool _isCategoryThree = false;
  bool _isCategoryThreeShimmer = true;

  bool _isFeaturedAdsVertical = false;
  bool _isFeaturedAdsVerticalShimmer = true;

  bool _isFeaturedAdsThree = false;
  bool _isFeaturedAdsThreeShimmer = true;

  bool _isCategory = false;
  bool _isCategoryShimmer = true;

  bool _isBrands = false;
  bool _isBrandsShimmer = true;

  bool _isDiscounted = false;
  bool _isDiscountedShimmer = true;

  bool _isinternet = true;
  var deliverlocation = "";
  SharedPreferences prefs;
  bool checkskip = false;
  bool _isWeb = false;
  bool _isInit = true;
  var _currencyFormat = "";
  MediaQueryData queryData;
  double wid;
  double maxwid;
  var name = "", email = "", photourl = "", phone = "",mobile="",countrycode="";
  bool _serviceEnabled = false;
  bool _permissiongrant = false;
  String _mapaddress = "",addressLine="";
  static const kGoogleApiKey = "AIzaSyDuSBpFHZO3R32b1kmCFmcVe2uh-GIzItI";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  Future<void> _refreshProducts(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        _isinternet = true;
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        _isinternet = true;
      });
    } else {
      Fluttertoast.showToast(msg: "No internet connection!!!");
      setState(() {
        _isinternet = false;
      });
    }

    await Provider.of<CarouselItemsList>(context,listen: false).fetchBanner();
    //await Provider.of<BrandItemsList>(context, listen: false).fetchBrands();
    await Provider.of<CategoriesItemsList>(context,listen: false).fetchCategory();
    String _categoryTwoId = prefs.getString("category_two");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryTwo(_categoryTwoId)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);

      setState(() {
        if (subcategoryData.catTwoitems.length > 0) {
          _isCategoryTwo = true;
          _isCategoryTwoShimmer = false;
        } else {
          _isCategoryTwoShimmer = false;
        }
      });
    });


    //await Provider.of<Advertise1ItemsList>(context, listen: false).fetchadvertisecategory1();
    //await Provider.of<Advertise1ItemsList>(context, listen: false).fetchAdvertisecategory2();
  /*  await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchAdvertisementVerticalslider();*/
    //await Provider.of<Advertise1ItemsList>(context, listen: false).fetchAdvertisementItem1();
    //await Provider.of<Advertise1ItemsList>(context, listen: false).fetchAdvertisecategory3();
    await Provider.of<SellingItemsList>(context,listen: false).fetchSellingItems();
    await Provider.of<SellingItemsList>(context,listen: false).fetchDiscountItems();
    await Provider.of<BrandItemsList>(context,listen: false).fetchPaymentMode();
    if (!checkskip) {
      Provider.of<BrandItemsList>(context,listen: false).userDetails();
     /* await Provider.of<AddressItemsList>(context,listen: false).fetchAddress();
      Provider.of<MembershipitemsList>(context,listen: false).Getmembership().then((_) {
        final membershipData = Provider.of<MembershipitemsList>(context,listen: false);
        precacheImage(NetworkImage(membershipData.items[0].avator), context);
      });
      await Provider.of<BrandItemsList>(context,listen: false).fetchShoppinglist();*/
    }
    String _categoryTwoId2 = prefs.getString("category_two");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryTwo(_categoryTwoId2)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);

      setState(() {
        if (subcategoryData.catTwoitems.length > 0) {
          _isCategoryTwo = true;
          _isCategoryTwoShimmer = false;
        } else {
          _isCategoryTwoShimmer = false;
        }
      });
    });


    String _categoryId2 = prefs.getString("category");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryOne(_categoryId2)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);
      setState(() {
        if (subcategoryData.catOneitems.length > 0) {
          _isCategoryOne = true;
          _isCategoryOneShimmer = false;
        } else {
          _isCategoryOneShimmer = false;
        }
      });
    });

    await Provider.of<BrandItemsList>(context,listen: false).GetRestaurant().then((_) {
      if (!prefs.containsKey("deliverylocation")) {
        setState(() {
          prefs.setString(
              "deliverylocation", prefs.getString("restaurant_location"));
          prefs.setString("latitude", prefs.getString("restaurant_lat"));
          prefs.setString("longitude", prefs.getString("restaurant_long"));
        });

      }
    });
    await Provider.of<NotificationItemsList>(context,listen: false)
        .fetchNotificationLogs(prefs.getString('userID'));
 //   await Provider.of<BrandItemsList>(context, listen: false).getLoyalty();
  }

  @override
  void initState() {
    // parse date
    DateTime date= DateFormat.jm().parse("6:45 PM");
    DateTime date2= DateFormat("hh:mma").parse("6:45PM"); // think this will work better for you
// format date
    Hive.openBox<Product>(productBoxName);
   // getCurrentLocation();


    Future.delayed(Duration.zero, () async {
      try {
        if (Platform.isIOS) {
          setState(() {
            _isWeb = false;
            iphonex = MediaQuery.of(context).size.height >= 812.0;
          });
        } else {
          setState(() {
            _isWeb = false;
          });
        }
      } catch (e) {
        setState(() {
          checkskip = checkskip;
          _isWeb = true;
        });
      }
      prefs = await SharedPreferences.getInstance();
      _currencyFormat = prefs.getString("currency_format");
      setState(() {
        prefs = prefs;
        if (prefs.getString('FirstName') != null) {
          if (prefs.getString('LastName') != null) {
            name = prefs.getString('FirstName') +
                " " +
                prefs.getString('LastName');
          } else {
            name = prefs.getString('FirstName');
          }
        } else {
          name = "";
        }

        if (prefs.getString('Email') != null) {
          email = prefs.getString('Email');
        } else {
          email = "";
        }

        if (mobile != null) {
          phone = mobile;//prefs.getString('mobile');
        } else {
          phone = "";
        }
        if (prefs.getString('photoUrl') != null) {
          photourl = prefs.getString('photoUrl');
        } else {
          photourl = "";
        }

      });



      await Provider.of<BrandItemsList>(context, listen: false).GetRestaurant().then((_) {
        if (!prefs.containsKey("deliverylocation")) {
          setState(() {
            prefs.setString("deliverylocation", prefs.getString("restaurant_location"));
            prefs.setString("latitude", prefs.getString("restaurant_lat"));
            prefs.setString("longitude", prefs.getString("restaurant_long"));
            deliverlocation = prefs.getString("deliverylocation");
          });
        }
      });

      prefs.setString("addressbook", "");
      setState(() {
        if (prefs.getString('skip') == "yes") {
          checkskip = true;
        } else {
          checkskip = false;
        }
      });
      if (checkskip) {
        await Provider.of<BrandItemsList>(context,listen: false).guestNotification();
      }
      if (!checkskip) {
        await Provider.of<BrandItemsList>(context,listen: false).userDetails();
      }


     // checkLocation();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {



          if (IConstants.currentdeliverylocation != "Not Available")
           _apiCalls();
          setState(() {
            _isinternet = true;
          });

        // I am connected to a mobile network.
      } else {
        Fluttertoast.showToast(msg: "No internet connection!!!");
        setState(() {
          _isinternet = false;
        });
      }
    });
  }


  _apiCalls() async {

    prefs = await SharedPreferences.getInstance();
    _address = prefs.getString("restaurant_address");
  /*  setState(() {
      if (prefs.getString('skip') == "yes") {
        checkskip = true;
         Provider.of<AddressItemsList>(context,listen: false).fetchAddress();
      } else {
        checkskip = false;
      }
    });*/

        await Provider.of<Advertise1ItemsList>(context, listen: false)
            .fetchPopupBanner()
            .then((_) {
          final bannerpopup = Provider.of<Advertise1ItemsList>(
              context, listen: false);
          if (!prefs.containsKey("descriptionCount")) {
           prefs.setString("descriptionCount", "0");
          }
          if (bannerpopup.popupbanner.length > 0) {
            if (prefs.getString("descriptionCount") !=
                bannerpopup.popupbanner[0].description) {
              count = int.parse(prefs.getString("descriptionCount"));
              ShowPopupforbanner();
            }
          }
        });

    if (_isWeb)
      await Provider.of<Advertise1ItemsList>(context,listen: false).websiteSlider().then((_) {
        setState(() {
          final sliderData = Provider.of<Advertise1ItemsList>(context,listen: false);
          if (sliderData.websiteItems.length > 0) {
            _isWebsiteSlider = true;
            _isWebsiteShimmer = false;
          } else {
            _isWebsiteShimmer = false;
          }
        });
      });

    await Provider.of<CarouselItemsList>(context,listen: false).fetchBanner().then((_) {
      setState(() {
        final bannerData = Provider.of<CarouselItemsList>(context,listen: false);
        if (bannerData.items.length > 0) {
          _isCaroselSlider = true;
          _isCaroselShimmer = false;
        } else {
          _isCaroselShimmer = false;
        }
      });
    });

    String _categoryTwoId = prefs.getString("category_two");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryTwo(_categoryTwoId)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);

      setState(() {
        if (subcategoryData.catTwoitems.length > 0) {
          _isCategoryTwo = true;
          _isCategoryTwoShimmer = false;
        } else {
          _isCategoryTwoShimmer = false;
        }
      });
    });


    String _categoryId = prefs.getString("category");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryOne(_categoryId)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);
      setState(() {
        if (subcategoryData.catOneitems.length > 0) {
          _isCategoryOne = true;
          _isCategoryOneShimmer = false;
        } else {
          _isCategoryOneShimmer = false;
        }
      });
    });

    /*await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchadvertisecategory1()
        .then((_) {
      setState(() {
        final advertise1Data =
        Provider.of<Advertise1ItemsList>(context, listen: false);
        if (advertise1Data.items.length > 0) {
          _isAdsCategoryOne = true;
          _isAdsCategoryOneShimmer = false;
        } else {
          _isAdsCategoryOneShimmer = false;
        }
      });
    });*/

    await Provider.of<SellingItemsList>(context, listen: false)
        .fetchSellingItems()
        .then((_) {
      final sellingitemData =
      Provider.of<SellingItemsList>(context, listen: false);
      setState(() {
        if (sellingitemData.items.length > 0) {
          _isFeatured = true;
          _isFeaturedShimmer = false;
        } else {
          _isFeaturedShimmer = false;
        }
      });
    });

   /* await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchAdvertisementItem1()
        .then((_) {
      setState(() {
        final advertise1Data =
        Provider.of<Advertise1ItemsList>(context, listen: false);
        if (advertise1Data.items1.length > 0) {
          _isFeaturedAdsOne = true;
          _isFeaturedAdsOneShimmer = false;
        } else {
          _isFeaturedAdsOneShimmer = false;
        }
      });
    });*/



   /* await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchAdvertisecategory2()
        .then((_) {
      final advertise1Data =
      Provider.of<Advertise1ItemsList>(context, listen: false);

      setState(() {
        if (advertise1Data.items1.length > 0) {
          _isFeaturedAdsTwo = true;
          _isFeaturedAdsTwoShimmer = false;
        } else {
          _isFeaturedAdsTwoShimmer = false;
        }
      });
    });
*/
   /* String _categoryThreeId = prefs.getString("category_three");
    await Provider.of<FeaturedCategoryList>(context, listen: false)
        .fetchCategoryItems(_categoryThreeId)
        .then((_) {
      final subcategoryData =
      Provider.of<FeaturedCategoryList>(context, listen: false);
      setState(() {
        if (subcategoryData.catitems.length > 0) {
          _isCategoryThree = true;
          _isCategoryThreeShimmer = false;
        } else {
          _isCategoryThreeShimmer = false;
        }
      });
    });
*/
  /*  await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchAdvertisecategory3()
        .then((_) {
      final advertise1Data =
      Provider.of<Advertise1ItemsList>(context, listen: false);
      setState(() {
        if (advertise1Data.item3.length > 0) {
          _isFeaturedAdsVertical = true;
          _isFeaturedAdsVerticalShimmer = false;
        } else {
          _isFeaturedAdsVerticalShimmer = false;
        }
      });
    });*/

   /* await Provider.of<Advertise1ItemsList>(context, listen: false)
        .fetchAdvertisementVerticalslider()
        .then((_) {
      final advertise1Data =
      Provider.of<Advertise1ItemsList>(context, listen: false);

      setState(() {
        if (advertise1Data.item4.length > 0) {
          _isFeaturedAdsThree = true;
          _isFeaturedAdsThreeShimmer = false;
        } else {
          _isFeaturedAdsThreeShimmer = false;
        }
      });
    });*/

    await Provider.of<CategoriesItemsList>(context, listen: false)
        .fetchCategory()
        .then((_) {
      final categoriesData =
      Provider.of<CategoriesItemsList>(context, listen: false);
      setState(() {
        if (categoriesData.items.length > 0) {
          _isCategory = true;
          _isCategoryShimmer = false;
        } else {
          _isCategoryShimmer = false;
        }
      });
    });

   /* await Provider.of<BrandItemsList>(context, listen: false)
        .fetchBrands()
        .then((_) {
      final brandsData = Provider.of<BrandItemsList>(context, listen: false);

      setState(() {
        if (brandsData.items.length > 0) {
          _isBrands = true;
          _isBrandsShimmer = false;
        } else {
          _isBrandsShimmer = false;
        }
      });
    });
*/
    await Provider.of<SellingItemsList>(context, listen: false)
        .fetchDiscountItems()
        .then((_) {
      final discountitemData =
      Provider.of<SellingItemsList>(context, listen: false);
      setState(() {
        if (discountitemData.itemsdiscount.length > 0) {
          _isDiscounted = true;
          _isDiscountedShimmer = false;
        } else {
          _isDiscountedShimmer = false;
        }
      });
    });
    /*if (!checkskip) {
      await Provider.of<AddressItemsList>(context, listen: false)
          .fetchAddress();
      await Provider.of<MembershipitemsList>(context, listen: false)
          .Getmembership()
          .then((_) {
        final membershipData =
        Provider.of<MembershipitemsList>(context, listen: false);
        if (membershipData.items.length > 0)
          precacheImage(NetworkImage(membershipData.items[0].avator), context);
      });
      await Provider.of<BrandItemsList>(context, listen: false)
          .fetchShoppinglist();
    }*/

    await Provider.of<BrandItemsList>(context, listen: false)
        .fetchPaymentMode();

   // await Provider.of<BrandItemsList>(context, listen: false).getLoyalty();
    if (prefs.containsKey("orderId")) {
      _cancelOrder();
    }

    /*if (brandsData.items.length > 0 ||
        sellingitemData.items.length > 0 ||
        categoriesData.items.length > 0 ||
        discountitemData.itemsdiscount.length > 0) {
      _isDelivering = true;
    } else {
      _isDelivering = false;
    }*/
  }



  Future<void> _cancelOrder() async {
    // imp feature in adding async is the it automatically wrap into Future.
    var url = IConstants.API_PATH + 'cancel-order';
    try {
      final response = await http.post(url, body: {
        // await keyword is used to wait to this operation is complete.
        "id": prefs.getString('orderId'),
        "note": "Payment cancelled by user",
        "branch": prefs.getString('branch'),
      });
      final responseJson = json.decode(utf8.decode(response.bodyBytes));
      if (responseJson['status'].toString() == "200") {
        prefs.remove("orderId");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: "Something went wrong!!!");
      throw error;
    }
  }

  Widget _sliderShimmer() {
    return /*SizedBox.shrink()*/
      _isWeb?SizedBox.shrink():
      Shimmer.fromColors(
        baseColor: Color(0xffd3d3d3),
        highlightColor: Color(0xffeeeeee),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 10.0,
            ),
            new Container(
              padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
              height: 150.0,
              width: MediaQuery.of(context).size.width - 20.0,
              color: Colors.white,
            ),
          ],
        ));
  }

  Widget _horizontalshimmerslider() {
    return /*SizedBox.shrink()*/

        _isWeb?SizedBox.shrink():

      Row(
      children: <Widget>[
        Expanded(
            child: Card(
          child: SizedBox(
            height: _isWeb && !ResponsiveLayout.isSmallScreen(context)?150: 100,
            child: new ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: _isWeb && !ResponsiveLayout.isSmallScreen(context)?6:4,
              itemBuilder: (_, i) => Column(
                children: [
                  Row(
                    children: <Widget>[
                      Shimmer.fromColors(
                        baseColor: Color(0xffd3d3d3),
                        highlightColor: Color(0xffeeeeee),
                        child: Container(
                          width: _isWeb && !ResponsiveLayout.isSmallScreen(context)?MediaQuery.of(context).size.width/7:90.0,
                          height: _isWeb && !ResponsiveLayout.isSmallScreen(context)?150:90.0,
                          color: Theme.of(context).buttonColor,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget __advertiseCategoryOneShimmer() {
    return /*SizedBox.shrink()*/
      _isWeb?SizedBox.shrink():
      new Row(
      children: <Widget>[
        Expanded(
            child: SizedBox(
          height: 135.0,
          child: new ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(0.0),
            itemCount: 2,
            itemBuilder: (_, i) => Container(
                margin: EdgeInsets.only(left: 10.0, bottom: 10.0),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Shimmer.fromColors(
                  baseColor: Color(0xffd3d3d3),
                  highlightColor: Color(0xffeeeeee),
                  child: Container(
                    width: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?MediaQuery.of(context).size.width/3:90.0,
                    height: 90.0,
                    color: Theme.of(context).buttonColor,
                  ),
                )),
          ),
        )),
      ],
    );
  }

  Widget _websiteSlider() {
    return _isWebsiteSlider
        ? WebsiteSlider()
        : _isWebsiteShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _carouselSlider() {
    return _isCaroselSlider
        ? CarouselSliderimage()
        : _isCaroselShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _websiteSliderSmall() {
    final bannerData = Provider.of<CarouselItemsList>(context, listen: false);
    return _isCaroselSlider
        ? SizedBox(
      height: 280,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: new ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: bannerData.items.length,
          itemBuilder: (_, i) => Container(
            padding: EdgeInsets.all(10.0),
            width: 540.0,
            height: 280.0,
            margin: EdgeInsets.only(right: 10.0),
            child: CachedNetworkImage(
              imageUrl: bannerData.items[i].imageUrl,
              width: 50.0,
              height: 50.0,
              placeholder: (context, url) =>
                  Image.asset(Images.defaultBrandImg),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    )
        : _isCaroselShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _categoryOne() {
    return _isCategoryOne
        ? CategoryOne()
        : _isCategoryOneShimmer
        ? _horizontalshimmerslider()
        : SizedBox.shrink();
  }

  Widget _advertiseCategoryOne() {
    final advertise1Data =
    Provider.of<Advertise1ItemsList>(context, listen: false);

    return _isAdsCategoryOne
        ? new Row(
      children: <Widget>[
        Expanded(
            child: SizedBox(
              height: 135.0,
              child: new ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(0.0),
                itemCount: advertise1Data.items.length,
                itemBuilder: (_, i) => Column(
                  children: [
                    Advertise1Items(
                      advertise1Data.items[i].imageUrl,
                      advertise1Data.items[i].bannerFor,
                      advertise1Data.items[i].bannerData,
                      advertise1Data.items[i].clickLink,
                      "top",
                    ),
                  ],
                ),
              ),
            )),
      ],
    )
        : _isAdsCategoryOneShimmer
        ? __advertiseCategoryOneShimmer()
        : SizedBox.shrink();
  }

  Widget _featuredItem() {
    final sellingitemData =
    Provider.of<SellingItemsList>(context, listen: false);

    return _isFeatured
        ? Container(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      color: Colors.white.withOpacity(0.7),
      child: Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              SizedBox(
                width: 10.0,
              ),
              Text(
                sellingitemData.featuredname,
                style: TextStyle(
                    fontSize: 18,
                    color: ColorCodes.backbutton,
                    fontWeight: FontWeight.bold),
              ),
              Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(SellingitemScreen.routeName, arguments: {
                      'seeallpress': "featured",
                      'title': sellingitemData.featuredname
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        translate('forconvience.See all'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            color: ColorCodes.seeallcolor),
                      ),
                      SizedBox(width: 5,),
                      Icon(Icons.arrow_forward_ios_outlined,size: 13,color: ColorCodes.seeallcolor,)
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(height: 8.0),
          new Row(
            children: <Widget>[
              Expanded(
                  child: SizedBox(
                    height: ResponsiveLayout.isSmallScreen(context) ? 275 : ResponsiveLayout.isMediumScreen(context) ? 300 : 275,
                    child: new ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: sellingitemData.items.length,
                      itemBuilder: (_, i) => Column(
                        children: [
                          Items(
                            "home_screen",
                            sellingitemData.items[i].id,
                            sellingitemData.items[i].title,
                            sellingitemData.items[i].imageUrl,
                            sellingitemData.items[i].brand,
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
    )
        : _isFeaturedShimmer
        ? _horizontalshimmerslider()
        : SizedBox.shrink();
  }

  Widget _featuredAdsOne() {
    final advertise1Data =
    Provider.of<Advertise1ItemsList>(context, listen: false);

    return _isFeaturedAdsOne
        ? SizedBox(
      child: new ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
        //controller: ScrollController(keepScrollOffset: false),
        itemCount: advertise1Data.items1.length,
        itemBuilder: (_, i) => Column(
          children: [
            Advertise1Items(
              advertise1Data.items1[i].imageUrl,
              advertise1Data.items1[i].bannerFor,
              advertise1Data.items1[i].bannerData,
              advertise1Data.items1[i].clickLink,
              "horizontal",
            ),
          ],
        ),
      ),
    )
        : _isFeaturedAdsOneShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _CategoryTwo() {
    return _isCategoryTwo
        ? CategoryTwo()
        : _isCategoryTwoShimmer
        ? _horizontalshimmerslider()
        : SizedBox.shrink();
  }

  Widget _featuredAdsTwo() {
    final advertise1Data =
    Provider.of<Advertise1ItemsList>(context, listen: false);

    return _isFeaturedAdsTwo
        ? SizedBox(
      child: new ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: advertise1Data.items2.length,
        padding: EdgeInsets.zero,
        itemBuilder: (_, i) => Column(
          children: [
            Advertise1Items(
              advertise1Data.items2[i].imageUrl,
              advertise1Data.items2[i].bannerFor,
              advertise1Data.items2[i].bannerData,
              advertise1Data.items2[i].clickLink,
              "horizontal",
            ),
          ],
        ),
      ),
    )
        : _isFeaturedAdsTwoShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _categoryThree() {
    return _isCategoryThree
        ? CategoryThree()
        : _isCategoryThreeShimmer
        ? _horizontalshimmerslider()
        : SizedBox.shrink();
  }

  Widget _featuredAdsVertical() {
    final advertise1Data =
    Provider.of<Advertise1ItemsList>(context, listen: false);

    return _isFeaturedAdsVertical
        ? SizedBox(
      height: 290.0,
      child: new ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: advertise1Data.item3.length,
        itemBuilder: (_, i) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Advertise1Items(
              advertise1Data.item3[i].imageUrl,
              advertise1Data.item3[i].bannerFor,
              advertise1Data.item3[i].bannerData,
              advertise1Data.item3[i].clickLink,
              "bottom"),
        ),
      ),
    )
        : _isFeaturedAdsVerticalShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _featuredAdsThree() {
    final advertise1Data =
    Provider.of<Advertise1ItemsList>(context, listen: false);

    return _isFeaturedAdsThree
        ? SizedBox(
      child: new ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: advertise1Data.item4.length,
        padding: EdgeInsets.zero,
        itemBuilder: (_, i) =>MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Column(
            children: [
              Advertise1Items(
                advertise1Data.item4[i].imageUrl,
                advertise1Data.item4[i].bannerFor,
                advertise1Data.item4[i].bannerData,
                advertise1Data.item4[i].clickLink,
                "horizontal",
              ),
            ],
          ),
        ),
      ),
    )
        : _isFeaturedAdsThreeShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _category() {
    return _isCategory
        ? Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              left: 10.0, top: 10.0, right: 10.0, bottom: 3.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Explore by Category",
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        ExpansionCategory(),
      ],
    )
        : _isCategoryShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _brands() {

    final brandsData = Provider.of<BrandItemsList>(context, listen: false);

    return _isBrands
        ? Container(
      color: Color(0xffE1EFFC),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
          left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Shop by Brands",
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          SizedBox(
            height: 8.0,
          ),
          SizedBox(
            height: 60,
            child: new ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: brandsData.items.length,
              itemBuilder: (_, i) => Column(
                children: [
                  BrandsItems(
                    brandsData.items[i].id,
                    brandsData.items[i].title,
                    brandsData.items[i].imageUrl,
                    i,
                  ),
                ],
              ),
            ),
          ),
          //SizedBox(height: 15.0,),
        ],
      ),
    )
        : _isBrandsShimmer
        ? _sliderShimmer()
        : SizedBox.shrink();
  }

  Widget _discountItem() {
    final sellingitemData = Provider.of<SellingItemsList>(context,listen: false);
    final discountitemData = Provider.of<SellingItemsList>(context,listen: false);

    return _isDiscounted
        ? Container(
        padding: EdgeInsets.only(top: 15.0, bottom: 10.0),
        color: Colors.white.withOpacity(0.7),
        child: Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  sellingitemData.discountedname,
                  style: TextStyle(
                      fontSize: 18.0,
                      color: ColorCodes.blackColor,
                      fontWeight: FontWeight.w700),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(SellingitemScreen.routeName, arguments: {
                      'seeallpress': "discount",
                      'title': sellingitemData.discountedname,
                    });
                  },
                  child: Container(
                    child:Row(
                      children: [
                        Text(
                          translate('forconvience.See all'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 15,
                              color: ColorCodes.seeallcolor),
                        ),
                        SizedBox(width: 5,),
                        Icon(Icons.arrow_forward_ios_outlined,size: 13,color: ColorCodes.seeallcolor,)
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            new Row(
              children: <Widget>[
                Expanded(
                    child: SizedBox(
                      height: ResponsiveLayout.isSmallScreen(context) ? 275 : ResponsiveLayout.isMediumScreen(context) ? 300 : 275,
                      child: new ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: discountitemData.itemsdiscount.length,
                        itemBuilder: (_, i) => Column(
                          children: [
                            Items(
                              "Discount",
                              discountitemData.itemsdiscount[i].id,
                              discountitemData.itemsdiscount[i].title,
                              discountitemData.itemsdiscount[i].imageUrl,
                              discountitemData.itemsdiscount[i].brand,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ))
        : _isDiscountedShimmer
        ? _horizontalshimmerslider()
        : SizedBox.shrink();
  }

  ShowPopupforbanner() {
    final bannerpopup = Provider.of<Advertise1ItemsList>(
        context, listen: false);
    // PrefUtils.prefs!.setString("count", )
    setState(() {
      count++;
    });
    prefs.setString("descriptionCount", count.toString());
    showDialog(
      context: context,
      barrierDismissible: _isWeb ? true : false,
      builder: (BuildContext context) {
        return

          WillPopScope(

            onWillPop: () {
              //SystemNavigator.pop();
              Navigator.of(context).pop();
              return Future.value(false);
            },
            child:
            Center(
              child: Container(
                height: 250,
                width: 300,

                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        bannerpopup.popupbanner[0].imageUrl, height: 250,
                        width: 300,
                        fit: BoxFit.fill,),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: CircleAvatar(
                          radius: 14.0,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.close, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),

              ),
            ),
          );
      },
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: _isinternet
          ?

      ValueListenableBuilder(
        //TODO 2nd: listen playerPointsToAdd
        valueListenable: IConstants.currentdeliverylocation,
        builder: (context, value, widget) {

          //TODO here you can setState or whatever you need
          return  value == "Not Available" ?Center(
                child: Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.only(
                                left: 80.0, right: 80.0),
                            width:
                            MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: 200.0,
                            child: new Image.asset(
                                Images.notDeliveringImg)),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        translate('forconvience.no deliver'),
                          //"Sorry, we don't deliver here "
                      ),
                      GestureDetector(
                        onTap: () {
                          prefs.setString(
                              "formapscreen", "homescreen");
                          Navigator.of(context)
                              .pushNamed(MapScreen.routeName);
                        },
                        child: Container(
                          width: 100.0,
                          height: 40.0,
                          margin: EdgeInsets.only(top: 20.0),
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            borderRadius:
                            BorderRadius.circular(3.0),
                          ),
                          child: Center(
                              child: Text(
                                translate('forconvience.Change Location'), //'Change Location',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      if (_isWeb)
                        Footer(
                          address: prefs
                              .getString("restaurant_address"),
                        ),
                    ],
                  ),
                ),
              )
          :

          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
          /* if (checkskip && !_isWeb)
            Container(
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.green),
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Get membership & other benefits",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          SignupSelectionScreen.routeName,
                        );
                      },
                      child: Text(
                        "LOGIN / REGISTER",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                  SizedBox(width: 10),
                ],
              ),
            ),*/
          if (_isWeb) _websiteSlider(),
          if (!_isWeb) _carouselSlider(),
          SizedBox(height: 5),
          if (_isWeb) _websiteSliderSmall(),
          SizedBox(
          height: 10,
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
            constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
            child: Column(
            children: [
            _CategoryTwo(),
            //_categoryOne(),
         /* SizedBox(
            height: 10,
            ),*/
            /* (MediaQuery.of(context).size.width <=
                        600)
                        ? _advertiseCategoryOne()
                        : SizedBox.shrink(),*/
            //feature item list
            _featuredItem(),
            if(!_isWeb)
            (MediaQuery.of(context).size.width <=
            600)
            ?
            ValueListenableBuilder(
            valueListenable: IConstants.currentdeliverylocation,
            builder: (context, value, widget) {
              if (value != "Not Available")
                return
                  Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      padding: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 8.0),
                      child: Text(
                        translate('forconvience.forconvience'),
                        style: TextStyle(
                            fontSize: 18,
                            color: ColorCodes.blackColor,
                            fontWeight:
                            FontWeight.bold),
                      ));
            }
            )

                : SizedBox.shrink(),
            if(!_isWeb)
            (MediaQuery.of(context).size.width <=
            600)
            ?
            ValueListenableBuilder(
            valueListenable: IConstants.currentdeliverylocation,
            builder: (context, value, widget) {
              if(value != "Not Available" )
              return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin: EdgeInsets.only(
                      left: 10.0,
                      top: 8.0,
                      right: 10.0,
                      bottom: 15.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          checkskip
                              ? Navigator.of(
                              context)
                              .pushNamed(
                            SignupSelectionScreen
                                .routeName,
                          )
                              : Navigator.of(
                              context)
                              .pushNamed(
                              MultipleImagePicker
                                  .routeName, arguments: {
                            'subject': "Click & Send",
                            'type': "click",
                          }
                          );
                        },
                        child: Image.asset(
                          Images.bulkImg,
                          width: (MediaQuery
                              .of(
                              context)
                              .size
                              .width /
                              2) -
                              15,
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {

                          //launch("tel: " + prefs.getString("primary_mobile"));
                          String url = 'tel:' + prefs.getString("primary_mobile");
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                        child: Image.asset(
                          Images.supportImg,
                          width: (MediaQuery
                              .of(
                              context)
                              .size
                              .width /
                              2) -
                              15,
                        ),
                      )
                    ],
                  ),
                );
              return SizedBox.shrink();
            }
            )
                : SizedBox.shrink(),

            // Advertisement for Featured Items 1
            /* _featuredAdsOne(),

                   // _CategoryTwo(),
                    SizedBox(
                      height: 10,
                    ),
                    _featuredAdsTwo(),*/
            /*  SizedBox(
                      height: 15,
                    ),
                    _categoryThree(),*/
            /* SizedBox(
                      height: 10,
                    ),*/
            /* (MediaQuery.of(context).size.width <=
                        600)
                        ? _featuredAdsVertical()
                        : SizedBox.shrink(),
                    _featuredAdsThree(),*/
            // _category(),
            //Categories
            /*SizedBox(
                      height: 15,
                    ),*/
            // Brands items
            //_brands(),
            _discountItem(),
            ],
            ),
            ),
          ),
          /*if (!_isWeb)
            Image.asset(
              Images.footerImg,
            ),*/
          if (_isWeb)
          Footer(address: _address),
          ],
          );

        },
      )
     /*
      _isDelivering
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
         *//* if (checkskip && !_isWeb)
            Container(
              height: 35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.green),
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(5.0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Text(
                    "Get membership & other benefits",
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white),
                  ),
                  Spacer(),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          SignupSelectionScreen.routeName,
                        );
                      },
                      child: Text(
                        "LOGIN / REGISTER",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                  SizedBox(width: 10),
                ],
              ),
            ),*//*
          if (_isWeb) _websiteSlider(),
          if (!_isWeb) _carouselSlider(),
          SizedBox(height: 5),
          if (_isWeb) _websiteSliderSmall(),
          SizedBox(
            height: 10,
          ),

          Align(
            alignment: Alignment.center,
            child: Container(
              constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
              child: Column(
                children: [
                  _CategoryTwo(),
                  //_categoryOne(),
                  SizedBox(
                    height: 10,
                  ),
                 *//* (MediaQuery.of(context).size.width <=
                      600)
                      ? _advertiseCategoryOne()
                      : SizedBox.shrink(),*//*
                  //feature item list
                  _featuredItem(),
                  (MediaQuery.of(context).size.width <=
                      600)
                      ? Container(
                      width: MediaQuery.of(context)
                          .size
                          .width,
                      padding: EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                          bottom: 8.0),
                      child: Text(
                        translate('forconvience.forconvience'),
                        style: TextStyle(
                            fontSize: 18,
                            color: ColorCodes.blackColor,
                            fontWeight:
                            FontWeight.bold),
                      ))
                      : SizedBox.shrink(),

                  (MediaQuery.of(context).size.width <=
                      600)
                      ? Container(
                    width: MediaQuery.of(context)
                        .size
                        .width,
                    margin: EdgeInsets.only(
                        left: 10.0,
                        top: 8.0,
                        right: 10.0,
                        bottom: 15.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            checkskip
                                ? Navigator.of(
                                context)
                                .pushNamed(
                              SignupSelectionScreen
                                  .routeName,
                            )
                                : Navigator.of(
                                context)
                                .pushNamed(
                                MultipleImagePicker
                                    .routeName, arguments: {
                              'subject' : "Click & Send",
                              'type' : "click",
                            }
                            );
                          },
                          child: Image.asset(
                            Images.bulkImg,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                2) -
                                15,
                          ),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            launch("tel: " +
                                prefs.getString(
                                    "primary_mobile"));
                          },
                          child: Image.asset(
                            Images.supportImg,
                            width: (MediaQuery.of(
                                context)
                                .size
                                .width /
                                2) -
                                15,
                          ),
                        )
                      ],
                    ),
                  )
                      : SizedBox.shrink(),

                  // Advertisement for Featured Items 1
                 *//* _featuredAdsOne(),

                 // _CategoryTwo(),
                  SizedBox(
                    height: 10,
                  ),
                  _featuredAdsTwo(),*//*
                *//*  SizedBox(
                    height: 15,
                  ),
                  _categoryThree(),*//*
                 *//* SizedBox(
                    height: 10,
                  ),*//*
                 *//* (MediaQuery.of(context).size.width <=
                      600)
                      ? _featuredAdsVertical()
                      : SizedBox.shrink(),
                  _featuredAdsThree(),*//*
                 // _category(),
                  //Categories
                  *//*SizedBox(
                    height: 15,
                  ),*//*
                  // Brands items
                  //_brands(),
                  _discountItem(),
                ],
              ),
            ),
          ),
          *//*if (!_isWeb)
            Image.asset(
              Images.footerImg,
            ),*//*
          if (_isWeb)
            Footer(address: _address),
        ],
      )
          :
      Center(
        child: Container(
          height: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        left: 80.0, right: 80.0),
                    width:
                    MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: new Image.asset(
                        Images.notDeliveringImg)),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text("Sorry, we don't deliver in " +
                  deliverlocation),
              GestureDetector(
                onTap: () {
                  prefs.setString(
                      "formapscreen", "homescreen");
                  Navigator.of(context)
                      .pushNamed(MapScreen.routeName);
                },
                child: Container(
                  width: 100.0,
                  height: 40.0,
                  margin: EdgeInsets.only(top: 20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius:
                    BorderRadius.circular(3.0),
                  ),
                  child: Center(
                      child: Text(
                        'Change Location',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
              if (_isWeb)
                Footer(
                  address: prefs
                      .getString("restaurant_address"),
                ),
            ],
          ),
        ),
      )*/
          : Center(
        child: Container(
          height: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                        left: 80.0, right: 80.0),
                    width: MediaQuery.of(context).size.width,
                    height: 200.0,
                    child: new Image.asset(
                        Images.noInternetImg)),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text("No internet connection"),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Ugh! Something's not right with your internet",
                style: TextStyle(
                    fontSize: 12.0, color: Colors.grey),
              ),
              SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  _refreshProducts(context);
                },
                child: Container(
                  width: 90.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                  child: Center(
                      child: Text(
                        'Try Again',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
              if (_isWeb)
                Footer(
                  address:
                  prefs.getString("restaurant_address"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //systemNavigationBarColor:
      //  Theme.of(context).primaryColor, // navigation bar color
      statusBarColor: Theme.of(context).primaryColor, // status bar color
    ));

    queryData = MediaQuery.of(context);
    wid= queryData.size.width;
    maxwid=wid*0.95;
    //Hive.box<Product>(productBoxName).listenable()

    void launchWhatsApp() async {
      String phone = /*"+212652-655363"*/prefs.getString("secondary_mobile");
      String url() {
        if (Platform.isIOS) {
          return "whatsapp://wa.me/$phone/?text=${Uri.parse(translate('forconvience.hello'))}";
        } else {
          return "whatsapp://send?phone=$phone&text=${Uri.parse(translate('forconvience.hello'))}";
          const url = "https://wa.me/?text=YourTextHere";

        }
      }

      if (await canLaunch(url())) {
        await launch(url());
      } else {
        throw 'Could not launch ${url()}';
      }
    }


    bottomNavigationbar() {
      return _isDelivering
          ?
      ValueListenableBuilder(
          valueListenable: Hive.box<Product>(productBoxName).listenable(),

          builder: (context, Box<Product> box, index) {
            return SingleChildScrollView(
              child: Container(
                height:(box.values.isEmpty) ?60:100,
                color: Colors.white,
                child:


                Column(
                  children: [
                    ValueListenableBuilder(
                    valueListenable: IConstants.currentdeliverylocation,
                    builder: (context, valuemain, widget) {
                      return Container(
                        color: ColorCodes.greenColor,
                        child:
                        ValueListenableBuilder(
                          valueListenable: Hive.box<Product>(productBoxName)
                              .listenable(),
                          builder: (context, Box<Product> box, index) {
                            if (box.values.isEmpty) return SizedBox.shrink();

                            return
                              GestureDetector(
                                onTap: () =>
                                {
                                  if (valuemain != "Not Available" )
                                    if (_isDelivering)
                                    setState(() {
                                      Navigator.of(context).pushNamed(
                                          CartScreen.routeName,
                                          arguments: {"prev": "home_screen"});
                                    })
                                },
                                child:
                                Container(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: 50.0,
                                  padding: EdgeInsets.symmetric(horizontal: 13),
                                  child: Row(
                                    // mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: <Widget>[
                                      Center(
                                        child: Text(
                                          Calculations.itemCount.toString() +
                                              " " + translate(
                                              'bottomnavigation.items'),
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: ColorCodes
                                                  .whiteColor,
                                              fontWeight: FontWeight
                                                  .bold),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          /* color: Theme
                                              .of(context)
                                              .primaryColor,*/
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(
                                                    translate(
                                                        'bottomnavigation.viewcart'),
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        color: ColorCodes
                                                            .whiteColor,
                                                        fontWeight: FontWeight
                                                            .bold),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  /*   Icon(
                                                  Icons.arrow_right,
                                                  color: ColorCodes.whiteColor,
                                                ),*/
                                                ])),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: <Widget>[

                                          /* _checkmembership
                                      ? Text(
                                    "Total: " +
                                        _currencyFormat +
                                        (Calculations.totalMember).toString(),
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 16
                                    ),
                                    )
                                      : */
                                          Text(
                                            /* "Total: " +*/
                                            " " +
                                                double.parse(
                                                    (Calculations.total)
                                                        .toString())
                                                    .toStringAsFixed(2) +
                                                _currencyFormat,
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: ColorCodes
                                                    .whiteColor,
                                                fontWeight: FontWeight
                                                    .bold),
                                            textAlign: TextAlign.center,
                                          ),


                                          /*  Text(
                                          "Saved: " +
                                              _currencyFormat +
                                              Calculations.discount.toString(),
                                          style: TextStyle(
                                              color: ColorCodes.discount,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14),
                                        ),*/
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                          },
                        ),
                      );
                    }
                    ),
                    Row(
                      children: <Widget>[

                        Spacer(),

                        ValueListenableBuilder(
                          //TODO 2nd: listen playerPointsToAdd
                          valueListenable: IConstants.currentdeliverylocation,
                          builder: (context, value, widget) {

                            //TODO here you can setState or whatever you need
                            return GestureDetector(
                              onTap: () {
                                if(value != "Not Available" )
                                Navigator.of(context).pushNamed(
                                  CategoryScreen.routeName,
                                );
                              },
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 7.0,
                                  ),
                                  CircleAvatar(
                                    radius: 11.0,
                                    backgroundColor: Colors.transparent,
                                    child: Image.asset(Images.categoriesImg),
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(translate('bottomnavigation.categories'),//"Categories",
                                      style: TextStyle(
                                          color: ColorCodes.grey, fontSize: 10.0)),
                                ],
                              ),
                            );


                          },
                        ),



                        Spacer(),
                  ValueListenableBuilder(
                    //TODO 2nd: listen playerPointsToAdd
                      valueListenable: IConstants.currentdeliverylocation,
                      builder: (context, value, widget) {
                      return GestureDetector(
                          onTap: () {
                            if(value != "Not Available" )
                            checkskip
                                ? Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )
                                : Navigator.of(context).pushNamed(
                                WalletScreen.routeName,
                                arguments: {"type": "wallet"});
                          },
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 7.0,
                              ),
                              CircleAvatar(
                                radius: 11.0,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(Images.walletImg),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(translate('bottomnavigation.wallet'),//"Wallet",
                                  style: TextStyle(
                                      color: ColorCodes.grey, fontSize: 10.0)),
                            ],
                          ),
                        );

                      }),
                        Spacer(),
                        Column(
                          children: <Widget>[
                            SizedBox(
                              height: 7.0,
                            ),
                            CircleAvatar(
                              maxRadius: 11.0,
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.transparent,
                              child: Image.asset(Images.homeImg,
                                  color: Theme
                                      .of(context)
                                      .primaryColor),
                            ),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                                translate('bottomnavigation.home'),
                              //"Home",
                                style: TextStyle(
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        /* Spacer(),
                 GestureDetector(
                    onTap: () {
                      checkskip
                          ? Navigator.of(context).pushNamed(
                        SignupSelectionScreen.routeName,
                      )
                          : Navigator.of(context).pushNamed(
                        MembershipScreen.routeName,
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 7.0,
                        ),
                        CircleAvatar(
                          radius: 11.0,
                          backgroundColor: Colors.transparent,
                          child: Image.asset(
                            Images.bottomnavMembershipImg,
                          ),
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text("Membership",
                            style: TextStyle(
                                color: ColorCodes.grey, fontSize: 10.0)),
                      ],
                    ),
                  ),
                  Spacer(flex: 1),*/
                        Spacer(),
                  ValueListenableBuilder(
                    //TODO 2nd: listen playerPointsToAdd
                      valueListenable: IConstants.currentdeliverylocation,
                      builder: (context, value, widget) {
                        return
                          GestureDetector(

                            onTap: () {
                              if (value != "Not Available")
                                checkskip
                                    ? Navigator.of(context).pushNamed(
                                  SignupSelectionScreen.routeName,
                                )
                                    : Navigator.of(context).pushNamed(
                                  MyorderScreen.routeName,
                                );
                            },
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 7.0,
                                ),
                                CircleAvatar(
                                  radius: 11.0,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset(Images.shoppinglistsImg),
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(translate('bottomnavigation.myorders'),//"My Orders",
                                    style: TextStyle(
                                        color: ColorCodes.grey,
                                        fontSize: 10.0)),
                              ],
                            ),
                          );
                      }),
                        Spacer(
                          flex: 1,
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            checkskip
                                ? Navigator.of(context).pushNamed(
                              SignupSelectionScreen.routeName,
                            )
                                : launchWhatsApp();/*FlutterOpenWhatsapp.sendSingleMessage("+212652-655363", "Hello");*/
                            /*Navigator.of(context)
                                .pushNamed(
                                CustomerSupportScreen.routeName, arguments: {
                              'name': name,
                              'email': email,
                              'photourl': photourl,
                              'phone': phone,
                            });*/
                          },
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 7.0,
                              ),
                              CircleAvatar(
                                radius: 11.0,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(Images.whatsapp),
                              ),
                             // Icon(Icons.chat, color: Colors.black12,),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(translate('bottomnavigation.chat'),//"Chat",
                                  style: TextStyle(
                                      color: ColorCodes.grey, fontSize: 10.0)),
                            ],
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                      ],
                    ),


                  ],
                ),
              ),
            );
          }
      )
          : SingleChildScrollView(child: Container());
    }

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    final sliderData = Provider.of<Advertise1ItemsList>(context,listen: false);
_loadcurrency();
    return Scaffold(
      key: HomeScreen.scaffoldKey,
      drawer: ResponsiveLayout.isSmallScreen(context)
          ?
      AppDrawer()
          : SizedBox.shrink(),

      backgroundColor: Theme.of(context).primaryColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[

              Header(true),
              if (sliderData.websiteItems.length <= 0) SizedBox(height: 5),
              Expanded(
                child: _isWeb ? _body() : RefreshIndicator(
                  onRefresh: () => _refreshProducts(context),
                  child: _body(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _isWeb ? SizedBox.shrink() :
      Container(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
            child: bottomNavigationbar()
        ),
      ),
      /*floatingActionButton: _isWeb
          ? SizedBox.shrink()
          : Container(
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width - 80,
          bottom: 80,
        ),
        //margin: EdgeInsets.all(10),
        child: customfloatingbutton(),
      ),*/
    );
  }

  customfloatingbutton() {
    return
      ValueListenableBuilder(
      valueListenable: Hive.box<Product>(productBoxName).listenable(),
      builder: (context, Box<Product> box, index) {
        if (box.values.isEmpty)
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
            child: Container(
              margin: EdgeInsets.only(left: 80.0, top: 80.0, bottom: 10.0),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).accentColor),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                child: Image.asset(
                  Images.fcartImg,
                  height: 12,
                  // width: 3,
                ),
              ),
            ),
          );

        int cartCount = 0;
        for (int i = 0; i < Hive.box<Product>(productBoxName).length; i++) {
          cartCount = cartCount +
              Hive.box<Product>(productBoxName).values.elementAt(i).itemQty;
        }
        return Consumer<Calculations>(
          builder: (_, cart, ch) => FloatButtonBadge(
            child: ch,
            color: Colors.green,
            value: cartCount.toString(),
          ),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Theme.of(context).accentColor),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                child: Image.asset(
                  Images.fcartImg,
                  height: 12,
                  // width:3,
                  // fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        );
      },
    );
    // Consumer<NotificationItemsList>(
    //   builder: (_, cart, ch) => Badge(
    //     child: ch,
    //     color: Colors.green,
    //     value: unreadCount.toString(),
    //   ),
    //   child: GestureDetector(
    //     onTap: () {
    //       Navigator.of(context)
    //           .pushNamed(NotificationScreen.routeName);
    //     },
    //
    //     child: Container(
    //         width: 50,
    //         height: 50,
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(100),
    //             color: Theme.of(context).primaryColor),
    //         child: GestureDetector(
    //             onTap: () {
    //               // Navigator.of(context)
    //               //     .pushNamed(NotificationScreen.routeName);
    //             },
    //             child: Image.asset(
    //               Images.fcartImg,
    //               height: 10,
    //             ))
    //     ),
    //   ),
    // )
  }

  //Future<void>
  _loadcurrency() async {
    prefs = await SharedPreferences.getInstance();
    _currencyFormat = prefs.getString("currency_format");

  }


}
