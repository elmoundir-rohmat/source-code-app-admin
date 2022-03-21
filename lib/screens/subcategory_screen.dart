import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import '../widgets/footer.dart';
import '../widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/images.dart';
import '../screens/items_screen.dart';
import 'package:provider/provider.dart';
import '../data/hiveDB.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../main.dart';
import 'package:hive/hive.dart';
import '../data/calculations.dart';
import '../constants/ColorCodes.dart';
import '../screens/cart_screen.dart';
import '../screens/searchitem_screen.dart';
import '../providers/categoryitems.dart';
import 'package:flutter_translate/flutter_translate.dart';

class SubcategoryScreen extends StatefulWidget {
  static const routeName = '/subcategory-screen';
  @override
  _SubcategoryScreenState createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  bool _isLoading = true;
  //var subcategoryData;
  String catTitle = "";
  var currency_format = "";
  bool _checkmembership = false;
  bool _isWeb = false;
  SharedPreferences prefs;
  MediaQueryData queryData;
  double wid;
  double maxwid;
  bool iphonex = false;

  @override
  void initState() {
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
           _isWeb = true;
         });
       }
       prefs = await SharedPreferences.getInstance();
       currency_format=prefs.getString("currency_format");
       final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
       final catId = routeArgs['catId'];
       Provider.of<CategoriesItemsList>(context, listen: false).fetchNestedCategory(catId.toString(), "Subcategory").then((
           _) {
         _isLoading = false;
       });
     });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    _buildBottomNavigationBar() {
      return ValueListenableBuilder(
        valueListenable: Hive.box<Product>(productBoxName).listenable(),
        builder: (context, Box<Product> box, index) {
          if (box.values.isEmpty) return SizedBox.shrink();

          return Container(
            width: MediaQuery.of(context).size.width,
            color: ColorCodes.greenColor,
            height: 50.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
               /* Container(
                  color: Theme.of(context).primaryColor,
                  height: 50,
                  width: MediaQuery.of(context).size.width * 35 / 100,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      _checkmembership
                          ? Text("Total: " +
                          (Calculations.totalMember).toString()+currency_format ,
                        style: TextStyle(color: ColorCodes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      )
                          : Text("Total: "  + (Calculations.total).toString()+ currency_format,
                        style: TextStyle(
                            color: ColorCodes.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      Text(
                        Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
                        style: TextStyle(
                            color: ColorCodes.discount,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      )
                    ],
                  ),
                ),*/
                GestureDetector(
                    onTap: () => {
                      setState(() {
                        Navigator.of(context)
                            .pushNamed(CartScreen.routeName);
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Center(
                            child: Text(
                              Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'),
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
                                        translate('bottomnavigation.viewcart'),
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                " "+
                                    double.parse((Calculations.total).toString()).toStringAsFixed(2)+ currency_format ,
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
                    ),),
              ],
            ),
          );
        },
      );

      /*if(Calculations.itemCount > 0) {
        return Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 50.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                height:50,
                width:MediaQuery.of(context).size.width * 35/100,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15.0,
                    ),
                    _checkmembership
                        ?
                    Text(currency_format + (Calculations.totalMember).toString(), style: TextStyle(color: Colors.black),)
                        :
                    Text(currency_format + (Calculations.total).toString(), style: TextStyle(color: Colors.black),),
                    Text(Calculations.itemCount.toString() + " "+translate('bottomnavigation.items'), style: TextStyle(color:Colors.black,fontWeight: FontWeight.w400,fontSize: 9),)
                  ],
                ),),
              GestureDetector(
                  onTap: () =>
                  {
                    setState(() {
                      Navigator.of(context).pushNamed(CartScreen.routeName);
                    })
                  },
                  child: Container(color: Theme.of(context).primaryColor, height:50,width:MediaQuery.of(context).size.width*65/100,
                      child:Column(children:[
                        SizedBox(height: 17,),
                        Text(translate('bottomnavigation.viewcart'), style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                      ]
                      )
                  )
              ),
            ],
          ),
        );
      }*/
    }

    /*final subcategoryData = Provider.of<CategoriesItemsList>(
      context,
      listen: false,
    ).findById(catId);*/


    return Scaffold(
        appBar: ResponsiveLayout.isSmallScreen(context)
          ? gradientappbarmobile()
          : null,
      backgroundColor: ColorCodes.whiteColor,
        body: Column(
          children: [
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context)) Header(false),

            _body(),
          ],
        ),
        bottomNavigationBar:_isWeb
          ? SizedBox.shrink() : Padding(
          padding: EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: iphonex ? 16.0 : 0.0),
          child:_buildBottomNavigationBar(),
        ),
    );
  }
 /* Widget _body(){
      double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 3;
    double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

    if (deviceWidth > 1200) {
      widgetsInRow = 6;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    } else if (deviceWidth > 650) {
      widgetsInRow = 5;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 140;
    }
      queryData = MediaQuery.of(context);
      wid= queryData.size.width;
      maxwid=wid*0.90;
    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final catId = routeArgs['catId'];
    final catTitle = routeArgs['catTitle'];
    final subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);

    return _isLoading ?
        Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
          ),
        )
            :
        (subcategoryData.bannerSubcat.length <= 0) ?
        Align(
          alignment: Alignment.center,
          child: new Image.asset(
            Images.noCategoryImg, fit: BoxFit.fill,
            height: 200.0,
            width: 200.0,
//                    fit: BoxFit.cover
          ),
        )
            :
        Expanded(
           child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    constraints: (_isWeb && !ResponsiveLayout.isSmallScreen(context))?BoxConstraints(maxWidth: maxwid):null,
                    child: GridView.builder(
                      shrinkWrap: true,
                      controller: new ScrollController(keepScrollOffset: false),
                      padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                      itemCount: subcategoryData.bannerSubcat.length,
                      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                        value: subcategoryData.bannerSubcat[i],
                        child:MouseRegion(
                            cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                                'maincategory': catTitle,
                                'catId': catId,
                                'catTitle': subcategoryData.bannerSubcat[i].title,
                                'subcatId': subcategoryData.bannerSubcat[i].catid,
                                'indexvalue': i.toString(),
                                'prev': "category_item"
                              });
                            },
                            child: Card(
                              color: subcategoryData.bannerSubcat[i].featuredCategoryBColor,
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
                                    height: 10,
                                  ),
                                  CachedNetworkImage(
                                    imageUrl: subcategoryData.bannerSubcat[i].imageUrl,
                                    placeholder: (context, url) => Image.asset(
                                        Images.defaultCategoryImg),
                                    height: 55,
                                    width: 85,
                                    fit: BoxFit.fill,
                                  ),
                                  Spacer(),
                                  Text(subcategoryData.bannerSubcat[i].title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widgetsInRow,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 5,
                      ),
                    ),
                  ),
                ),
                 if (_isWeb)
                      Footer(address: prefs.getString("restaurant_address")),
              ],
            ),
          ),
        );
  }*/

  Widget _body(){
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 3;
    double aspectRatio = (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

    if (deviceWidth > 1200) {
      widgetsInRow = 6;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 140;
    } else if (deviceWidth > 650) {
      widgetsInRow = 5;
      aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;
    }

    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final catId = routeArgs['catId'];
    final catTitle = routeArgs['catTitle'];
    final subcategoryData = Provider.of<CategoriesItemsList>(context, listen: false,);

    return _isLoading ?
    Expanded(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor,),
        ),
      ),
    )
        :
    (subcategoryData.bannerSubcat.length <= 0) ?
    Align(
      alignment: Alignment.center,
      child: new Image.asset(
        Images.noCategoryImg, fit: BoxFit.fill,
        height: 200.0,
        width: 200.0,
//                    fit: BoxFit.cover
      ),
    )
        :
    Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Container(
                constraints: BoxConstraints(maxWidth: 1200),
                child: GridView.builder(
                  shrinkWrap: true,
                  controller: new ScrollController(keepScrollOffset: false),
                  padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
                  itemCount: subcategoryData.bannerSubcat.length,
                  itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                    value: subcategoryData.bannerSubcat[i],
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                          'maincategory': catTitle,
                          'catId': catId,
                          'catTitle': subcategoryData.bannerSubcat[i].title,
                          'subcatId': subcategoryData.bannerSubcat[i].catid,
                          'indexvalue': i.toString(),
                          'prev': "category_item"
                        });
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
                                imageUrl: subcategoryData.bannerSubcat[i].imageUrl,
                                placeholder: (context, url) => Image.asset(
                                    Images.defaultCategoryImg),

                                height: 65,
                                width: 100,
                                //fit: BoxFit.fill,
                              ):
                              CachedNetworkImage(
                                imageUrl: subcategoryData.bannerSubcat[i].imageUrl,
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
                              Text(subcategoryData.bannerSubcat[i].title,
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
                    /*  Card(
                        color: ColorCodes.whiteColor,//subcategoryData.bannerSubcat[i].featuredCategoryBColor,
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
                              height: 10,
                            ),
                            CachedNetworkImage(
                              imageUrl: subcategoryData.bannerSubcat[i].imageUrl,
                              placeholder: (context, url) => Image.asset(
                                  Images.defaultCategoryImg),
                              height: 55,
                              width: 85,
                             // fit: BoxFit.fill,
                            ),
                            Spacer(),
                            Text(subcategoryData.bannerSubcat[i].title,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0)),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),*/
                    ),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widgetsInRow,
                    childAspectRatio: aspectRatio,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 5,
                  ),
                ),
              ),
            ),
            if (_isWeb && !ResponsiveLayout.isSmallScreen(context))
              Footer(address: prefs.getString("restaurant_address")),
          ],
        ),
      ),
    );
  }
  gradientappbarmobile() {
      return AppBar(
        brightness: Brightness.dark,
        toolbarHeight: 60.0,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined, size:20,color: Colors.black),
            onPressed: () => Navigator.of(context).pop()),
        title: Text(
          catTitle == "" ? translate('bottomnavigation.categories') : catTitle,
        ),
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    ColorCodes.whiteColor,
                    ColorCodes.whiteColor,
              ])),
        ),
         actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  SearchitemScreen.routeName,
                );
              },
              child: Icon(Icons.search, size: 22.0,),
            ),
            SizedBox(width: 10.0,),
          ],
      );
    }

}