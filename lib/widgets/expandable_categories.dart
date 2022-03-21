import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/ColorCodes.dart';
import '../providers/categoryitems.dart';
import 'package:provider/provider.dart';
import '../providers/featuredCategory.dart';
import '../screens/items_screen.dart';

import 'categories_grid.dart';
import '../constants/images.dart';
import '../widgets/categoryTwo.dart';

class ExpansionCategory extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);
    double deviceWidth = MediaQuery.of(context).size.width;
    int widgetsInRow = 3;
    double aspectRatio =
        (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 160;
    Widget itemsInCategoryTwo() {

      final subcategoryData = Provider.of<FeaturedCategoryList>(context, listen: false);
      final categoriesData = Provider.of<CategoriesItemsList>(context,listen: false);
      double deviceWidth = MediaQuery.of(context).size.width;
      int widgetsInRow = 3;
      double aspectRatio =
          (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 120;

      if (deviceWidth > 1200) {
        widgetsInRow = 6;
        aspectRatio =
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 210;
      } else if (deviceWidth > 650) {
        widgetsInRow = 5;
        aspectRatio =
            (deviceWidth - (20 + ((widgetsInRow - 1) * 10))) / widgetsInRow / 145;
      }

      return GridView.builder(
        shrinkWrap: true,
        controller: new ScrollController(keepScrollOffset: false),
        // padding: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0.0),
        itemCount: subcategoryData.catTwoitems.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          value: subcategoryData.catTwoitems[i],
          child: MouseRegion(
           /// cursor: SystemMouseCursors.click,
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
             /* ClipPath(
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
                      Container(
                        width: 100,
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: ColorCodes.whiteColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5.0),
                              bottomRight: Radius.circular(5.0)),
                        ),


                        child: Text(subcategoryData.catTwoitems[i].title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?13.0:16.0)
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),*/

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
          crossAxisSpacing: 2,
          mainAxisSpacing: 5,
        ),
      );
    }

    return Container(
      child: Column(
        children: <Widget>[
          itemsInCategoryTwo(),
//          SizedBox(height:20.0),
         // customCategories(context),
        ],
      ),
    );
  }

  Widget customCategories(context) {
    
    final categoriesData = Provider.of<CategoriesItemsList>(context, listen: false);

    return ListView.builder(
      shrinkWrap: true,
      controller: new ScrollController(keepScrollOffset: false),
      padding: const EdgeInsets.all(5.0),
      itemCount: categoriesData.items.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: categoriesData.items[i],
        child: Container(
          padding: const EdgeInsets.only(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: ColorCodes.lightGreyWebColor),
            color: Color(0xFFD2E8FE),
          ),
          margin: EdgeInsets.all(5),
          child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
              backgroundColor: Color(0xFFA2E6BE),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      color: Colors.white, child: Icon(Icons.keyboard_arrow_down)),
                  if(ResponsiveLayout.isSmallScreen(context))
                    SizedBox(height: 20,),

                ],
              ),
              title: IntrinsicHeight(
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: categoriesData.items[i].imageUrl,
                      placeholder: (context, url) => Image.asset(
                        Images.defaultCategoryImg,
                        height: ResponsiveLayout.isSmallScreen(context)?70:100,
                        width: ResponsiveLayout.isSmallScreen(context)?100:130,
                        fit: BoxFit.fill,
                      ),
                      height: ResponsiveLayout.isSmallScreen(context)?70:100,
                      width: ResponsiveLayout.isSmallScreen(context)?100:130,
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: Text(
                      categoriesData.items[i].title,
                      style: TextStyle(fontSize:ResponsiveLayout.isSmallScreen(context)? 13:17, fontWeight: FontWeight.bold),
                    )),
                    VerticalDivider(
                      color: Colors.white,
                      thickness: 2,
                      endIndent: 20,
                      indent: 20,
                    ),

                  ],
                ),
              ),
              children: [
                CategoriesGrid(categoriesData.items[i].catid,categoriesData.items[i].title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
