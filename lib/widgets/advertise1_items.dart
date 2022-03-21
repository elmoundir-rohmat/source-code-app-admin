import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/categoryitems.dart';
import '../screens/items_screen.dart';
import '../screens/subcategory_screen.dart';
import '../screens/not_brand_screen.dart';
import '../screens/banner_product_screen.dart';
import '../constants/images.dart';

class Advertise1Items extends StatelessWidget {
  final String imageUrl;
  final String bannerFor;
  final String bannerData;
  final String clickLink;
  final String _isvertical;


  Advertise1Items(this.imageUrl, this.bannerFor, this.bannerData, this.clickLink, this._isvertical);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (bannerFor == "1") {
            // Specific product
            /*Navigator.of(context)
                .pushNamed(SingleproductScreen.routeName, arguments: {
              "itemid": bannerData,
            });*/
            Navigator.of(context).pushNamed(
                BannerProductScreen.routeName,
                arguments: {
                  "id" : bannerData,
                  'type': "product"
                }
            );
          } else if (bannerFor == "2") {
            //Category

            final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
            String cattitle = "";
            for (int j = 0; j < categoriesData.items.length; j++) {
              if (bannerData == categoriesData.items[j].catid) {
                cattitle = categoriesData.items[j].title;
              }
            }
            Navigator.of(context)
                .pushNamed(SubcategoryScreen.routeName, arguments: {
              'catId': bannerData,
              'catTitle': cattitle,
            });
          } else if (bannerFor == "3") {
            String maincategory = "";
            String catid = "";
            String subTitle = "";
            String index = "";

            /*for(int j = 0; j < categoriesData.itemssubcat.length; j++) {
              if(bannerData == categoriesData.itemssubcat[j].subcatid) {
                catid = categoriesData.itemssubcat[j].catid;
                subTitle = categoriesData.itemssubcat[j].title;
                for(int k = 0; k < categoriesData.items.length; k++) {
                  if(categoriesData.itemssubcat[j].catid == categoriesData.items[k].catid) {
                    maincategory = categoriesData.items[k].title;
                  }
                }
              }
            }

            final subcategoryData = Provider.of<CategoriesItemsList>(
              context,
              listen: false,
            ).findById(catid);
            for(int j = 0; j < subcategoryData.length; j++){
              if(bannerData == subcategoryData[j].subcatid) {
                index = j.toString();
              }
            }*/

            Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
              'maincategory': maincategory,
              'catId': catid,
              'catTitle': subTitle,
              'subcatId': bannerData,
              'indexvalue': index,
              'prev': "advertise"
              /*'maincategory' : subTitle,
                  'catId' : "",
                  'catTitle': subTitle,
                  'subcatId' : bannerData,
                  'indexvalue' : "0",*/
            });
          } else if(bannerFor == "5") {
            //brands
            Navigator.of(context).pushNamed(NotBrandScreen.routeName,
                arguments: {
                  'brandsId' : bannerData,
                  'fromScreen' : "Banner",
                  'notificationId' : "",
                  'notificationStatus': ""
                }
            );
          } else if(bannerFor == "4") {
            //Subcategory and nested category
            Navigator.of(context).pushNamed(BannerProductScreen.routeName,
                arguments: {
                  'id' : bannerData,
                  'type': "category"
                }
            );
          } else if(bannerFor == "6") {
            String url = clickLink;
            if (canLaunch(url) != null)
              launch(url);
            else
              // can't launch url, there is some error
              throw "Could not launch $url";
          }
        },
        child: Container(
          margin: _isvertical == "horizontal" ? EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0) : EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: (_isvertical == "top") ?
           CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width * 0.6,) : (_isvertical == "bottom") ?
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.fill,
      width: MediaQuery.of(context).size.width * 0.46,)
              :
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.fill, width: MediaQuery.of(context).size.width,placeholder: (context, url) =>
              Image.asset(
                  Images.defaultBrandImg),),
        ),
      ),
    );
  }
}
