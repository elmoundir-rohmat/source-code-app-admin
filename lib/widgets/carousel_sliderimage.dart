import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/carouselitems.dart';
import '../providers/categoryitems.dart';
import '../constants/images.dart';
import '../screens/not_brand_screen.dart';
import '../screens/items_screen.dart';
import '../screens/subcategory_screen.dart';
import '../screens/banner_product_screen.dart';

class CarouselSliderimage extends StatefulWidget {

  @override
  _CarouselSliderimageState createState() => _CarouselSliderimageState();
}

class _CarouselSliderimageState extends State<CarouselSliderimage> {
  var _carauselslider = false;

  @override
  Widget build(BuildContext context) {
    final bannerData = Provider.of<CarouselItemsList>(context, listen: false);


    if (bannerData.items.length > 0) {
      _carauselslider = true;
    } else {
      _carauselslider = false;
    }

    return _carauselslider ? Container(
      child: GFCarousel(
        autoPlay: true,
        viewportFraction: 1.0,
        height: 182,
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
          for (var i = 0; i < bannerData.items.length; i++)
            Builder(
              builder: (BuildContext context) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if(bannerData.items[i].banner_for == "1" ) {
                        // Specific product
                        Navigator.of(context).pushNamed(
                            BannerProductScreen.routeName,
                            arguments: {
                              "id" : bannerData.items[i].banner_data,
                              'type': "product",
                            }
                        );

                      } else if(bannerData.items[i].banner_for == "2") {
                        //Category
                        final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
                        String cattitle = "";
                        for(int j = 0; j < categoriesData.items.length; j++) {
                          if(bannerData.items[i].banner_data == categoriesData.items[j].catid) {
                            cattitle = categoriesData.items[j].title;
                          }
                        }
                        Navigator.of(context).pushNamed(
                            SubcategoryScreen.routeName,
                            arguments: {
                              'catId' : bannerData.items[i].banner_data,
                              'catTitle': cattitle,
                            }
                        );
                      } else if(bannerData.items[i].banner_for == "3") {
                        //subcategory
                        String subTitle = "";

                        Navigator.of(context).pushNamed(
                            ItemsScreen.routeName,
                            arguments: {
                              'maincategory' : subTitle.toString(),
                              'catId' : "",
                              'catTitle': subTitle.toString(),
                              'subcatId' : bannerData.items[i].banner_data,
                              'indexvalue' : "0",
                              'prev' : "carousel"
                            }
                        );
                      } else if(bannerData.items[i].banner_for == "5") {
                        //brands
                        Navigator.of(context).pushNamed(NotBrandScreen.routeName,
                            arguments: {
                              'brandsId' : bannerData.items[i].banner_data,
                              'fromScreen' : "Banner",
                              'notificationId' : "",
                              'notificationStatus': ""
                            }
                        );
                      } else if(bannerData.items[i].banner_for == "4") {
                        //Subcategory and nested category
                        Navigator.of(context).pushNamed(BannerProductScreen.routeName,
                            arguments: {
                              'id' : bannerData.items[i].banner_data,
                              'type': "category"
                            }
                        );
                      } else if(bannerData.items[i].banner_for == "6") {
                        String url = bannerData.items[i].clickLink;
                        if (canLaunch(url) != null)
                          launch(url);
                      else
                      // can't launch url, there is some error
                      throw "Could not launch $url";
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            child: CachedNetworkImage(
                                imageUrl: bannerData.items[i].imageUrl,
                                placeholder: (context, url) => Image.asset(Images.defaultSliderImg),
                                fit: BoxFit.fitWidth)
                        )
                    ),
                  ),
                );
              },
            )
        ],
      ),
    ) : Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: Image.asset(Images.defaultSliderImg)
    );
  }
}