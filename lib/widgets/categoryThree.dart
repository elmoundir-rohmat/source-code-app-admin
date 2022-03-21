
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../utils/ResponsiveLayout.dart';
import '../constants/images.dart';
import '../providers/notificationitems.dart';
import '../screens/items_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/featuredCategory.dart';

class CategoryThree extends StatefulWidget {
  @override
  _CategoryThreeState createState() => _CategoryThreeState();
}

class _CategoryThreeState extends State<CategoryThree> {
  bool _isLoading = true;
  String _label = "";
  String _categoryId = "";

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _label = prefs.getString("category_three_label");
        _categoryId = prefs.getString("category_three");
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final subcategoryData = Provider.of<FeaturedCategoryList>(context,listen: false);

    return _isLoading
        ? SizedBox.shrink()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
              left: 10.0, top: 5.0, right: 10.0, bottom: 8.0),
          child: Text(
            _label,
            style: TextStyle(
                fontSize: ResponsiveLayout.isSmallScreen(context)?18.0:24.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: ResponsiveLayout.isSmallScreen(context)? 140.0:180.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: subcategoryData.catitems.length,
                  itemBuilder: (_, i) => MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(ItemsScreen.routeName, arguments: {
                              'maincategory': subcategoryData.catitems[i].title.toString(),
                              'catId': subcategoryData.catitems[i].catid.toString(),
                              'catTitle': subcategoryData.catitems[i].title.toString(),
                              'subcatId': subcategoryData.catitems[i].subcatid.toString(),
                              'indexvalue': i.toString(),
                              'prev': "category_item"
                            }),
                        child: SizedBox(
                          width: ResponsiveLayout.isSmallScreen(context)?120:200,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                            margin: EdgeInsets.all(5),
                            color: subcategoryData.catitems[i].featuredCategoryBColor,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, top: 5.0, right: 5.0, bottom: 5.0),
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15)
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: subcategoryData
                                              .catitems[i].imageUrl,
                                          placeholder: (context, url) =>
                                              Image.asset(
                                                  Images.defaultCategoryImg),
                                          height: ResponsiveLayout.isSmallScreen(context)?60:85,
                                          width: ResponsiveLayout.isSmallScreen(context)?100:180,
                                          fit: BoxFit.fill,
                                        )),
                                  ),
                                  // Spacer(),
                                  SizedBox(height: 5,),
                                  Center(
                                    child: Text(subcategoryData.catitems[i].title,
                                        textAlign: TextAlign.center,
                                        overflow:  TextOverflow.fade,
                                        maxLines: 3,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ResponsiveLayout.isSmallScreen(context)?13.0:16.0)),
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),

                          ),
                        )


                    ),
                  ),

                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
