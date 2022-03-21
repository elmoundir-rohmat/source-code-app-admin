import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import 'package:provider/provider.dart';

import '../providers/notificationitems.dart';
import '../screens/items_screen.dart';
import '../providers/categoriesfields.dart';
import '../screens/subcategory_screen.dart';
import '../constants/images.dart';

class CategoriesItem extends StatelessWidget {
  final String previousScreen;
  final String maincategory;
  final String mainCategoryId;
  final String subCatId;
  final String subCatTitle;
  final int indexvalue;
  final String imageUrl;

  CategoriesItem(this.previousScreen, this.maincategory, this.mainCategoryId,
      this.subCatId, this.subCatTitle, this.indexvalue, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    var categoriesData;
    bool _isNotSubCategory = false;
    bool _isSubCategory = false;

    if (previousScreen == "NotSubcategoryScreen") {
      categoriesData = Provider.of<NotificationItemsList>(context, listen: false);
      _isNotSubCategory = true;
    } else {
      categoriesData = Provider.of<CategoriesFields>(context, listen: false);
      _isNotSubCategory = false;
    }

    if (previousScreen == "SubcategoryScreen") {
      _isSubCategory = true;
    } else {
      _isSubCategory = false;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (previousScreen == "SubcategoryScreen") {
            Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
              'maincategory': maincategory,
              /*'catId' : categoriesData.catid.toString(),
              'catTitle': categoriesData.title.toString(),
              'subcatId' : categoriesData.subcatid.toString(),*/
              'catId': mainCategoryId,
              'catTitle': subCatTitle,
              'subcatId': subCatId,
              'indexvalue': indexvalue.toString(),
              'prev': "category_item"
            });
          } else if (previousScreen == "NotSubcategoryScreen") {
            Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
              'maincategory': maincategory,
              'catId': categoriesData.catitems[indexvalue].catid.toString(),
              'catTitle': categoriesData.catitems[indexvalue].title.toString(),
              'subcatId': categoriesData.catitems[indexvalue].subcatid.toString(),
              'indexvalue': indexvalue.toString(),
              'prev': "category_item"
            });
          } else {
            Navigator.of(context)
                .pushNamed(SubcategoryScreen.routeName, arguments: {
              'catId': categoriesData.catid.toString(),
              'catTitle': categoriesData.title.toString(),
            });

            //  Navigator.of(context).pushNamed(
            //   SubcategoryScreen.routeName,
            //  );
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              padding: ResponsiveLayout.isLargeScreen(context)?const EdgeInsets.only(left: 5.0, top: 30.0, right: 5.0,bottom: 5.0):const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0,bottom: 5.0),
              child: ClipRRect(
                 /* borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),*/
                  child: _isNotSubCategory
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) => Image.asset(
                              Images.defaultCategoryImg),
                    height: 65,//ResponsiveLayout.isSmallScreen(context)?55:110,
                    width: 100,//ResponsiveLayout.isSmallScreen(context)?85:140,
                    //fit: BoxFit.fill,
                        )
                      : _isSubCategory
                          ?
                  CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => Image.asset(
                                  Images.defaultCategoryImg),
                    height:65,//ResponsiveLayout.isSmallScreen(context)? 55:110,
                    width:100,//ResponsiveLayout.isSmallScreen(context)? 85:140,
                             // fit: BoxFit.fill,
                            )
                          :
                  CachedNetworkImage(
                              imageUrl: categoriesData.imageUrl,
                              placeholder: (context, url) => Image.asset(
                                  Images.defaultCategoryImg),
                    height:65,//ResponsiveLayout.isSmallScreen(context)? 55:110,
                    width:100,//ResponsiveLayout.isSmallScreen(context)? 85:140,
                             // fit: BoxFit.fill,
                            )),
            ),
            SizedBox(
              height: 8,
            ),

            Center(
                child: _isNotSubCategory
                    ? Text(categoriesData.catitems[indexvalue].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold,
                            fontSize: ResponsiveLayout.isSmallScreen(context)?12:15))
                    : _isSubCategory
                        ? Text(subCatTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?12:15))
                        : Text(categoriesData.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize:ResponsiveLayout.isSmallScreen(context)?12:15))),
          ],
        ),
      ),
    );
  }
}
