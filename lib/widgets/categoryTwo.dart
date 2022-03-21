
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/images.dart';
import '../screens/items_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/featuredCategory.dart';
import '../constants/ColorCodes.dart';
import '../providers/categoryitems.dart';
class CategoryTwo extends StatefulWidget {

  @override
  _CategoryTwoState createState() => _CategoryTwoState();
}

class _CategoryTwoState extends State<CategoryTwo> {
  bool _isLoading = true;
  String _label = "";
  String _categoryId = "";
  var subcategoryData;
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

    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _label = prefs.getString("category_two_label");
        _categoryId = prefs.getString("category_two");
        _isLoading = false;
      });
    });


    super.initState();
  }

  Widget itemsInCategoryTwo() {

    final subcategoryData = Provider.of<FeaturedCategoryList>(context, listen: false);
    final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 4;
    double aspectRatio =
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 125;

    if (deviceWidth > 1200) {
      widgetsInRow = 6;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 210;
    } else if (deviceWidth > 650) {
      widgetsInRow = 4;
      aspectRatio =
          _isWeb?(deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160:(deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 145;
    }

      return SizedBox(
        height: _isWeb?190:120,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: subcategoryData.catTwoitems.length,
          itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
            value: subcategoryData.catTwoitems[i],
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                  'maincategory': subcategoryData.catTwoitems[i].title.toString(),
                  'catId': subcategoryData.catTwoitems[i].catid.toString(),
                  'catTitle': subcategoryData.catTwoitems[i].title.toString(),
                  'subcatId': subcategoryData.catTwoitems[i].subcatid.toString(),
                  'indexvalue': i.toString(),
                  'prev': "category_item"});
              },
              child:
              ClipPath(
                clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    )
                ),
                child: Container(
                  //color: ColorCodes.greenColor,
                  child: Column(
                    children: [

                      SizedBox(
                        height: 15,
                      ),
                      (MediaQuery.of(context).size.width <= 600) ?
                      CachedNetworkImage(
                        imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                        placeholder: (context, url) => Image.asset(
                            Images.defaultCategoryImg),

                        height: 65,
                        width: 100,
                        //fit: BoxFit.fill,
                      ):
                      CachedNetworkImage(
                        imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                        placeholder: (context, url) => Image.asset(
                            Images.defaultCategoryImg),

                        height: ResponsiveLayout.isSmallScreen(context)?100:120,
                        width: ResponsiveLayout.isSmallScreen(context)?115:160,
                        //fit: BoxFit.fill,
                      ) ,

                      SizedBox(
                        height: 10.0,
                      ),
                      //Spacer(),
                      Text(subcategoryData.catTwoitems[i].title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?14.0:16.0)
                      ),
                     /* SizedBox(
                        height: 10,
                      ),*/
                    ],
                  ),
                ),
              ),
            ),
        ),
          )),
      );
      /*  GridView.builder(
        shrinkWrap: true,
        controller: new ScrollController(keepScrollOffset: false),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        itemCount: subcategoryData.catTwoitems.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: subcategoryData.catTwoitems[i],
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                  'maincategory': subcategoryData.catTwoitems[i].title.toString(),
                  'catId': subcategoryData.catTwoitems[i].catid.toString(),
                  'catTitle': subcategoryData.catTwoitems[i].title.toString(),
                  'subcatId': subcategoryData.catTwoitems[i].subcatid.toString(),
                  'indexvalue': i.toString(),
                  'prev': "category_item"});
              },
              child: ClipPath(
                clipper: ShapeBorderClipper(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                    )
                ),
                child: Container(
                  //color: ColorCodes.greenColor,
                  child: Column(
                    children: [

                      SizedBox(
                        height: 15,
                      ),
                      (MediaQuery.of(context).size.width <= 600) ?
                      CachedNetworkImage(
                        imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                        placeholder: (context, url) => Image.asset(
                            Images.defaultCategoryImg),

                        height: 65,
                        width: 100,
                        //fit: BoxFit.fill,
                      ):
                      CachedNetworkImage(
                        imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                        placeholder: (context, url) => Image.asset(
                            Images.defaultCategoryImg),

                        height: ResponsiveLayout.isSmallScreen(context)?100:120,
                        width: ResponsiveLayout.isSmallScreen(context)?115:160,
                        //fit: BoxFit.fill,
                      ) ,

                    SizedBox(
                      height: 5.0,
                    ),
                    Spacer(),
                Material(
                 // elevation: 1,
                  child: Container(
                    width: 100,
                    padding: EdgeInsets.all(3.0),

                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0)),
                       ),


                    child: Text(subcategoryData.catTwoitems[i].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?14.0:16.0)
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                    ],
                  ),
                ),
              ),

           /*   Card(
                color:ColorCodes.whiteColor, //subcategoryData.catTwoitems[i].featuredCategoryBColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
                margin: EdgeInsets.all(5),
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    (MediaQuery.of(context).size.width <= 600) ?
                    CachedNetworkImage(
                      imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                      placeholder: (context, url) => Image.asset(
                          Images.defaultCategoryImg),

                      height: 65,
                      width: 100,
                      //fit: BoxFit.fill,
                    ):
                    CachedNetworkImage(
                      imageUrl: subcategoryData.catTwoitems[i].imageUrl,
                      placeholder: (context, url) => Image.asset(
                          Images.defaultCategoryImg),

                      height: ResponsiveLayout.isSmallScreen(context)?100:120,
                      width: ResponsiveLayout.isSmallScreen(context)?115:160,
                      //fit: BoxFit.fill,
                    ) ,
                    *//*SizedBox(
                      height: 5.0,
                    ),*//*
                    Spacer(),
                    Text(subcategoryData.catTwoitems[i].title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?13.0:16.0)
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),*/
            ),
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widgetsInRow,
          childAspectRatio: aspectRatio,
          crossAxisSpacing: 4,
          mainAxisSpacing: 5,
        ),
      );*/
}

  @override
  Widget build(BuildContext context) {
    return _isLoading ? SizedBox.shrink()
        :
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
     // mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: 10.0,
                  //right: 10.0, bottom: 8.0, top: 12
                ),
              child: Text(
                _label,
                style: TextStyle(
                    fontSize: ResponsiveLayout.isSmallScreen(context)?18.0:24.0,
                    color: ColorCodes.locationColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),

        itemsInCategoryTwo(),

      ],
    );
  }
}
