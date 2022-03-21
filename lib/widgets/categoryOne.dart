
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

class CategoryOne extends StatefulWidget {

  @override
  _CategoryOneState createState() => _CategoryOneState();
}

class _CategoryOneState extends State<CategoryOne> {
  bool _isLoading = true;
  String _label = "";
  String _categoryId = "";
  var subcategoryData;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _label = prefs.getString("category_label");
        _categoryId = prefs.getString("category");
        _isLoading = false;
        /*Provider.of<FeaturedCategoryList>(context, listen: false).fetchCategoryOne(_categoryId).then((_) {
          final subcategoryData = Provider.of<FeaturedCategoryList>(context, listen: false);
          if (subcategoryData.catOneitems.length <= 0) {
            _isLoading = false;
          } else {
            _isLoading = false;
          }
        });*/
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subcategoryData = Provider.of<FeaturedCategoryList>(context,listen: false);

    return _isLoading ? SizedBox.shrink()
        :
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: ResponsiveLayout.isSmallScreen(context)?EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0):null,
          child: Text(
            _label,
            style: TextStyle(
                fontSize: ResponsiveLayout.isSmallScreen(context)?18.0:24.0,
                fontWeight: FontWeight.bold,
                color: ColorCodes.blackColor),
          ),
        ),
        SizedBox(
          //width: MediaQuery.of(context).size.width,
          height: ResponsiveLayout.isSmallScreen(context)? 150.0:190.0,
          child: ListView.builder(
              shrinkWrap: true,
              scrollDirection:
              Axis.horizontal,
              itemCount:  subcategoryData.catOneitems.length,
              padding: EdgeInsets.all(0.0),
              itemBuilder: (_, i) =>

                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                          'maincategory': subcategoryData.catOneitems[i].title.toString(),
                          'catId': subcategoryData.catOneitems[i].catid.toString(),
                          'catTitle': subcategoryData.catOneitems[i].title.toString(),
                          'subcatId': subcategoryData.catOneitems[i].subcatid.toString(),
                          'indexvalue': i.toString(),
                          'prev': "category_item"
                        });
                      },
                      child: Container(

                        width: ResponsiveLayout.isSmallScreen(context)?110:200,
                        child:  Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          //elevation: 1,
                          //margin: EdgeInsets.only(left: 10.0, bottom: 5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                color: subcategoryData.catOneitems[i].featuredCategoryBColor,
                                padding: const EdgeInsets.all(12.0),
                                //height: 70,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: subcategoryData.catOneitems[i].imageUrl,
                                      placeholder: (context, url) => Image.asset(
                                          Images.defaultCategoryImg),
                                      height: ResponsiveLayout.isSmallScreen(context)?55:85,
                                      width: ResponsiveLayout.isSmallScreen(context)?85:150,
                                      fit: BoxFit.fill,
                                    )
                                ),
                              ),
                              // Spacer(),
                              SizedBox(height: 5,),
                              Container(height: 40,

                                child: Center(
                                  child: Text(

                                      subcategoryData.catOneitems[i].title,
                                      overflow: TextOverflow.visible,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: ResponsiveLayout.isSmallScreen(context)?13.0:16.0)),
                                ),
                              ),
                              SizedBox(height: 15.0,),
                            ],
                          ),
                        ) ,
                        // )
                      ),
                    ),
                  )
          ),
        ),

      ],
    );
  }




}

