import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fellahi_e/utils/ResponsiveLayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import '../providers/advertise1items.dart';
import '../screens/singleproduct_screen.dart';
import '../screens/items_screen.dart';
import '../providers/categoryitems.dart';
import '../screens/subcategory_screen.dart';
import 'package:provider/provider.dart';
import '../constants/images.dart';
import '../screens/banner_product_screen.dart';
import '../screens/not_brand_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteSlider extends StatefulWidget {

  @override
  _WebsiteSliderState createState() => _WebsiteSliderState();
}

class _WebsiteSliderState extends State<WebsiteSlider> {
  var _carauselslider = false;
  bool _isWeb = false;
@override
  void initState() {
  try {
    if (Platform.isIOS) {
      setState(() {
        _isWeb = false;
      });
    } else {
      setState(() {
        _isWeb = false;
      });
    }
  } catch (e) {
    setState(() {
      _isWeb = true;
    });
  }
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final bannerData = Provider.of<Advertise1ItemsList>(context, listen: false);


    if (bannerData.websiteItems.length > 0) {
      _carauselslider = true;
    } else {
      _carauselslider = false;
    }

    return _carauselslider ? GFCarousel(
      autoPlay: true,
      viewportFraction: 1.0,
      height: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?480.0:182,
      aspectRatio: 1,
      pagination: true,
      passiveIndicator: Colors.white,
      activeIndicator: Theme.of(context).accentColor,
      autoPlayInterval: Duration(seconds: 8),
//        initialPage: 0,
//        enableInfiniteScroll: true,
//        reverse: false,
//        autoPlay: true,
//        autoPlayInterval: Duration(seconds: 3),
//        autoPlayAnimationDuration: Duration(milliseconds: 800),
//        pauseAutoPlayOnTouch: Duration(seconds: 10),
//        enlargeCenterPage: true,
//        scrollDirection: Axis.horizontal,
      items: <Widget>[
        for (var i = 0; i < bannerData.websiteItems.length; i++)
          Builder(
            builder: (BuildContext context) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (bannerData.websiteItems[i].bannerFor == "1") {
                      Navigator.of(context).pushNamed(
                          BannerProductScreen.routeName,
                          arguments: {
                            "id" : bannerData.websiteItems[i].bannerData,
                            'type': "product"
                          }
                      );
                    } else if (bannerData.websiteItems[i].bannerFor == "2") {
                      //Category

                     /* final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
                      String cattitle = "";
                      for (int j = 0; j < categoriesData.items.length; j++) {
                        if (bannerData.websiteItems[i].bannerData == categoriesData.items[j].catid) {
                          cattitle = categoriesData.items[j].title;
                        }
                      }
                      Navigator.of(context)
                          .pushNamed(SubcategoryScreen.routeName, arguments: {
                        'catId': bannerData.websiteItems[i].bannerData,
                        'catTitle': cattitle,
                      });*/

                      String maincategory = "";
                      String catid = "";
                      String subTitle = "";
                      String index = "";

                      Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                        'maincategory': maincategory,
                        'catId': catid,
                        'catTitle': subTitle,
                        'subcatId': bannerData.websiteItems[i].bannerData,
                        'indexvalue': index,
                        'prev': "advertise"

                      });
                    } else if (bannerData.websiteItems[i].bannerFor == "3") {
                      String maincategory = "";
                      String catid = "";
                      String subTitle = "";
                      String index = "";

                      Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                        'maincategory': maincategory,
                        'catId': catid,
                        'catTitle': subTitle,
                        'subcatId': bannerData.websiteItems[i].bannerData,
                        'indexvalue': index,
                        'prev': "advertise"

                      });
                    } else if(bannerData.websiteItems[i].bannerFor == "5") {
                      //brands
                      Navigator.of(context).pushNamed(NotBrandScreen.routeName,
                          arguments: {
                            'brandsId' : bannerData.websiteItems[i].bannerData,
                            'fromScreen' : "Banner",
                            'notificationId' : "",
                            'notificationStatus': ""
                          }
                      );
                    } else if(bannerData.websiteItems[i].bannerFor == "4") {
                      //Subcategory and nested category
                      Navigator.of(context).pushNamed(BannerProductScreen.routeName,
                          arguments: {
                            'id' : bannerData.websiteItems[i].bannerData,
                            'type': "category"
                          }
                      );
                    } else if(bannerData.websiteItems[i].bannerFor == "6") {
                      String url = bannerData.websiteItems[i].clickLink;
                      if (canLaunch(url) != null)
                        launch(url);
                      else
                        // can't launch url, there is some error
                        throw "Could not launch $url";
                    }
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                          imageUrl: bannerData.websiteItems[i].imageUrl,
                          placeholder: (context, url) => Image.asset(Images.defaultSliderImg),
                          fit: BoxFit.fill)
                  ),
                ),
              );
            },
          )
      ],
    ) : Container() ;
  }
}